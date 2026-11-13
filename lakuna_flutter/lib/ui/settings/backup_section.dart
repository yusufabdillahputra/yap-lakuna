import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show outletLocalTime;
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
        vm.backupNow.running || vm.pickRestore.running || vm.restore.running;
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FButton(
                    key: const ValueKey('backup-now'),
                    mainAxisSize: .min,
                    onPress: busy ? null : vm.backupNow.execute,
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
    return switch (vm.lastDelivery) {
      BackupSaved(:final path) => l10n.backupSavedTo(path),
      BackupShared() => l10n.backupShared,
      BackupDismissed() => l10n.backupDismissed,
      null => null,
    };
  }
}

/// Pesan galat pulihkan (Pengaturan dan onboarding).
String backupRestoreError(AppLocalizations l10n, Exception error) =>
    switch (error) {
      BackupTooNew() => l10n.backupTooNew,
      BackupInvalid() => l10n.backupInvalid,
      StoreAlreadySetUp() => l10n.setupRestoreAlreadySetUp,
      _ => l10n.backupRestoreFailed,
    };

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
