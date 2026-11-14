import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart'
    show
        BackupPasswordProblem,
        backupPasswordMaxLength,
        backupPasswordMinLength,
        outletLocalTime;
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/backup_repository.dart';
import '../../data/services/backup_files.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/format.dart';
import 'backup_view_model.dart';
import 'settings_card.dart';

/// Ukuran berkas ringkas: `18,2 MB`, `640 KB`.
String formatFileSize(int bytes, {String decimal = ','}) {
  const kb = 1024;
  const mb = kb * 1024;
  const gb = mb * 1024;
  String one(int value, int unit) {
    final tenths = (value * 10 / unit).round();
    final whole = tenths ~/ 10;
    final frac = tenths % 10;
    return frac == 0 ? '$whole' : '$whole$decimal$frac';
  }

  if (bytes >= gb) return '${one(bytes, gb)} GB';
  if (bytes >= mb) return '${one(bytes, mb)} MB';
  if (bytes >= kb) return '${(bytes / kb).round()} KB';
  return '$bytes B';
}

/// Bagian *Data & backup* di Pengaturan (1.13 / 1.26, F1-19).
class BackupSection extends StatelessWidget {
  const BackupSection({super.key, required this.viewModel, this.timezone});

  final BackupViewModel viewModel;
  final String? timezone;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => _build(context),
  );

  Widget _build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    final stats = vm.stats;
    final days = vm.daysSinceBackup;
    final busy =
        vm.backupNow.running ||
        vm.pickRestore.running ||
        vm.restore.running ||
        vm.unlock.running;
    return Column(
      key: const ValueKey('backup-section'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        SettingsCard(
          title: l10n.settingsSectionBackup,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(l10n.backupModeLabel, style: muted),
                      Text(
                        l10n.backupModeFree,
                        key: const ValueKey('backup-mode'),
                        style: theme.typography.body.md.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(l10n.backupModeBody, style: muted),
                    ],
                  ),
                ),
              ),
              if (stats != null)
                Row(
                  spacing: 8,
                  children: [
                    for (final (key, label, value) in [
                      ('sales', l10n.backupStatSales, '${stats.sales}'),
                      (
                        'products',
                        l10n.backupStatProducts,
                        '${stats.products}',
                      ),
                      (
                        'size',
                        l10n.backupStatSize,
                        formatFileSize(
                          stats.sizeBytes,
                          decimal: qtyDecimalSeparator(context),
                        ),
                      ),
                    ])
                      Expanded(
                        child: _Stat(
                          key: ValueKey('backup-stat-$key'),
                          label: label,
                          value: value,
                        ),
                      ),
                  ],
                ),
              Row(
                spacing: 8,
                children: [
                  Icon(
                    vm.overdue
                        ? TablerIcons.alertTriangle
                        : TablerIcons.circleCheck,
                    size: 18,
                    color: vm.overdue
                        ? theme.colors.destructive
                        : theme.colors.primary,
                  ),
                  Expanded(
                    child: Text(
                      switch (days) {
                        null => l10n.backupLastNever,
                        0 => l10n.backupLastToday,
                        final d => l10n.backupLastDays(d),
                      },
                      key: const ValueKey('backup-last'),
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              FSwitch(
                key: const ValueKey('backup-lock'),
                label: Text(l10n.backupLock),
                value: vm.lockEnabled,
                onChange: busy ? null : vm.setLock,
              ),
              if (vm.lockEnabled) _PasswordFields(viewModel: vm, busy: busy),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FButton(
                    key: const ValueKey('backup-now'),
                    mainAxisSize: .min,
                    onPress: vm.canBackup ? vm.backupNow.execute : null,
                    prefix: vm.backupNow.running
                        ? const FCircularProgress()
                        : const Icon(TablerIcons.download),
                    child: Flexible(child: Text(l10n.backupNow)),
                  ),
                  FButton(
                    key: const ValueKey('backup-restore'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: busy ? null : vm.pickRestore.execute,
                    prefix: const Icon(TablerIcons.restore),
                    child: Flexible(child: Text(l10n.backupRestore)),
                  ),
                ],
              ),
              if (_deliveryText(l10n, vm) case final text?)
                Text(
                  text,
                  key: const ValueKey('backup-result'),
                  style: theme.typography.body.sm.copyWith(
                    color:
                        vm.backupNow.error || vm.lastDelivery is BackupDismissed
                        ? theme.colors.destructive
                        : theme.colors.primary,
                  ),
                ),
              if (vm.pickRestore.result case Error(:final error))
                FAlert(
                  key: const ValueKey('backup-restore-error'),
                  variant: .destructive,
                  title: Text(backupRestoreError(l10n, error)),
                ),
              Text(l10n.backupFileNote, style: muted),
            ],
          ),
        ),
        if (vm.autoSupported && vm.autoBackup != null)
          _AutoBackupCard(viewModel: vm),
        if (vm.needsPassword) _UnlockPanel(viewModel: vm),
        if (vm.pendingRestore case final m?)
          _RestorePanel(
            viewModel: vm,
            manifest: m,
            timezone: timezone,
          ),
        const _HostingCard(),
      ],
    );
  }

  String? _deliveryText(AppLocalizations l10n, BackupViewModel vm) {
    if (vm.backupNow.error) return l10n.backupFailed;
    final locked = vm.lastBackupLocked;
    return switch (vm.lastDelivery) {
      BackupSaved(:final path) =>
        locked ? l10n.backupSavedLockedTo(path) : l10n.backupSavedTo(path),
      BackupShared() => locked ? l10n.backupSharedLocked : l10n.backupShared,
      BackupDismissed() => l10n.backupDismissed,
      null => null,
    };
  }
}

/// Backup otomatis harian di desktop (F1-19d).
class _AutoBackupCard extends StatelessWidget {
  const _AutoBackupCard({required this.viewModel});

  final BackupViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final state = vm.autoBackup!;
    return SettingsCard(
      key: const ValueKey('backup-auto-card'),
      title: l10n.backupAutoTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          FSwitch(
            key: const ValueKey('backup-auto'),
            label: Text(l10n.backupAutoSwitch),
            description: Text(l10n.backupAutoHint(vm.autoFolderPath ?? '')),
            value: state.enabled,
            onChange: vm.setAuto.running ? null : vm.setAuto.execute,
          ),
          Text(
            switch (vm.daysSinceAutoBackup) {
              null => l10n.backupAutoLastNever,
              0 => l10n.backupAutoLastToday,
              final d => l10n.backupAutoLastDays(d),
            },
            key: const ValueKey('backup-auto-last'),
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (state.failed && state.enabled)
            Text(
              l10n.backupAutoFailed,
              key: const ValueKey('backup-auto-failed'),
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.destructive,
              ),
            ),
          if (vm.setAuto.error)
            Text(
              l10n.backupAutoSaveFailed,
              key: const ValueKey('backup-auto-error'),
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.destructive,
              ),
            ),
        ],
      ),
    );
  }
}

/// Pesan galat pulihkan (Pengaturan dan onboarding).
String backupRestoreError(AppLocalizations l10n, Exception error) =>
    switch (error) {
      BackupTooNew() => l10n.backupTooNew,
      BackupInvalid() => l10n.backupInvalid,
      BackupWrongPassword() => l10n.backupWrongPassword,
      BackupLocked() => l10n.backupUnlockBody,
      StoreAlreadySetUp() => l10n.setupRestoreAlreadySetUp,
      _ => l10n.backupRestoreFailed,
    };

/// Pesan isian kata sandi backup (F1-19c).
String backupPasswordMessage(
  AppLocalizations l10n,
  BackupPasswordProblem problem,
) => switch (problem) {
  BackupPasswordProblem.tooShort => l10n.backupPasswordTooShort(
    backupPasswordMinLength,
  ),
  BackupPasswordProblem.tooLong => l10n.backupPasswordTooLong(
    backupPasswordMaxLength,
  ),
  BackupPasswordProblem.mismatch => l10n.backupPasswordMismatch,
};

/// Kata sandi + ulangi untuk mengunci backup (F1-19c). Dibuat ulang lewat
/// [BackupViewModel.passwordRevision] saat isian dikosongkan.
class _PasswordFields extends StatelessWidget {
  const _PasswordFields({required this.viewModel, required this.busy});

  final BackupViewModel viewModel;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final problem = vm.passwordProblem;
    // Pesan baru tampil setelah isiannya diketik.
    final passwordError =
        vm.password.isNotEmpty && problem != BackupPasswordProblem.mismatch
        ? problem
        : null;
    final retypeError =
        vm.passwordRetype.isNotEmpty &&
            problem == BackupPasswordProblem.mismatch
        ? problem
        : null;
    return KeyedSubtree(
      key: ValueKey('backup-password-fields-${vm.passwordRevision}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          FTextField(
            key: const ValueKey('backup-password'),
            label: Text(l10n.backupPassword),
            obscureText: true,
            enabled: !busy,
            error: passwordError == null
                ? null
                : Text(backupPasswordMessage(l10n, passwordError)),
            control: .managed(
              initial: TextEditingValue(text: vm.password),
              onChange: (v) => vm.setPassword(v.text),
            ),
          ),
          FTextField(
            key: const ValueKey('backup-password-retype'),
            label: Text(l10n.backupPasswordRetype),
            obscureText: true,
            enabled: !busy,
            error: retypeError == null
                ? null
                : Text(backupPasswordMessage(l10n, retypeError)),
            control: .managed(
              initial: TextEditingValue(text: vm.passwordRetype),
              onChange: (v) => vm.setPasswordRetype(v.text),
            ),
          ),
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                TablerIcons.lock,
                size: 16,
                color: theme.colors.mutedForeground,
              ),
              Expanded(
                child: Text(
                  l10n.backupLockNote,
                  key: const ValueKey('backup-lock-note'),
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Panel kata sandi untuk membuka backup terkunci (F1-19c), juga dipakai
/// dialog pulihkan di onboarding.
class BackupUnlockFields extends StatelessWidget {
  const BackupUnlockFields({
    super.key,
    required this.keyPrefix,
    required this.enabled,
    required this.onChanged,
    required this.onSubmit,
    this.error,
  });

  final String keyPrefix;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSubmit;
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        FTextField(
          key: ValueKey('$keyPrefix-password'),
          label: Text(l10n.backupPassword),
          obscureText: true,
          enabled: enabled,
          autofocus: true,
          onSubmit: (_) => onSubmit?.call(),
          control: .managed(onChange: (v) => onChanged(v.text)),
        ),
        if (error case final e?)
          FAlert(
            key: ValueKey('$keyPrefix-error'),
            variant: .destructive,
            title: Text(backupRestoreError(l10n, e)),
          ),
      ],
    );
  }
}

class _UnlockPanel extends StatelessWidget {
  const _UnlockPanel({required this.viewModel});

  final BackupViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final running = vm.unlock.running;
    return SettingsCard(
      key: const ValueKey('backup-unlock-panel'),
      title: l10n.backupUnlockTitle,
      subtitle: l10n.backupUnlockBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          BackupUnlockFields(
            key: ValueKey('backup-unlock-fields-${vm.unlockRevision}'),
            keyPrefix: 'backup-unlock',
            enabled: !running,
            onChanged: vm.setUnlockPassword,
            onSubmit: vm.canUnlock ? vm.unlock.execute : null,
            error: switch (vm.unlock.result) {
              Error(:final error) => error,
              _ => null,
            },
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              FButton(
                key: const ValueKey('backup-unlock-cancel'),
                variant: .outline,
                mainAxisSize: .min,
                onPress: running ? null : vm.cancelRestore,
                child: Flexible(child: Text(l10n.backupRestoreCancel)),
              ),
              FButton(
                key: const ValueKey('backup-unlock'),
                mainAxisSize: .min,
                onPress: vm.canUnlock ? vm.unlock.execute : null,
                prefix: running
                    ? const FCircularProgress()
                    : const Icon(TablerIcons.lockOpen),
                child: Flexible(child: Text(l10n.backupUnlock)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestorePanel extends StatelessWidget {
  const _RestorePanel({
    required this.viewModel,
    required this.manifest,
    this.timezone,
  });

  final BackupViewModel viewModel;
  final BackupManifest manifest;
  final String? timezone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final m = manifest;
    final created = m.createdAt;
    final date =
        '${formatDayMonth(created, timezone)}/'
        '${outletLocalTime(created, timezone).year} '
        '${formatClock(created, timezone)}';
    return SettingsCard(
      key: const ValueKey('backup-restore-panel'),
      title: l10n.backupRestoreTitle,
      subtitle: l10n.backupRestoreSummary(
        m.tenantName,
        m.outletName,
        m.deviceCode,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            l10n.backupRestoreMade(date, m.sales, m.products),
            key: const ValueKey('backup-restore-made'),
            style: theme.typography.body.sm,
          ),
          FAlert(
            variant: .destructive,
            title: Text(l10n.backupRestoreWarning),
          ),
          FTextField(
            key: const ValueKey('backup-restore-confirm'),
            label: Text(l10n.backupRestoreConfirmLabel(m.tenantName)),
            enabled: !vm.restore.running,
            control: .managed(onChange: (v) => vm.setConfirmText(v.text)),
          ),
          if (vm.restore.result case Error(:final error))
            FAlert(
              key: const ValueKey('backup-restore-failed'),
              variant: .destructive,
              title: Text(backupRestoreError(l10n, error)),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              FButton(
                key: const ValueKey('backup-restore-cancel'),
                variant: .outline,
                mainAxisSize: .min,
                onPress: vm.restore.running ? null : vm.cancelRestore,
                child: Flexible(child: Text(l10n.backupRestoreCancel)),
              ),
              FButton(
                key: const ValueKey('backup-restore-submit'),
                variant: .destructive,
                mainAxisSize: .min,
                onPress: vm.canConfirmRestore && !vm.restore.running
                    ? vm.restore.execute
                    : null,
                prefix: vm.restore.running ? const FCircularProgress() : null,
                child: Flexible(child: Text(l10n.backupRestoreConfirm)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HostingCard extends StatelessWidget {
  const _HostingCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return SettingsCard(
      key: const ValueKey('backup-hosting'),
      title: l10n.backupHostingTitle,
      subtitle: l10n.backupHostingBody,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          FTextField(
            label: Text(l10n.backupHostingServer),
            enabled: false,
            hint: 'https://',
          ),
          FTextField(label: Text(l10n.backupHostingCode), enabled: false),
          Align(
            alignment: Alignment.centerLeft,
            child: FButton(
              variant: .outline,
              mainAxisSize: .min,
              onPress: null,
              child: Flexible(child: Text(l10n.backupHostingConnect)),
            ),
          ),
          Text(
            l10n.backupHostingSoon,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}
