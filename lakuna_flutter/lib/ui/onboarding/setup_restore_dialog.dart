import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show outletLocalTime;
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/backup_repository.dart';
import '../../data/services/backup_files.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/format.dart';
import '../settings/backup_section.dart'
    show BackupUnlockFields, backupRestoreError;
import 'setup_restore_view_model.dart';

/// Dialog *Pulihkan dari backup* di onboarding (F1-19b). [restart] memuat
/// ulang aplikasi setelah backup disiapkan.
Future<void> showSetupRestore(
  BuildContext context, {
  required BackupRepository repository,
  required BackupFiles files,
  Future<void> Function()? restart,
}) => showFDialog<void>(
  context: context,
  // Ditutup hanya lewat Batal: ketukan latar tidak melewati `PopScope`.
  barrierDismissible: false,
  builder: (context, style, animation) => FDialog(
    animation: animation,
    constraints: const BoxConstraints(minWidth: 280, maxWidth: 520),
    builder: (context, style) => SetupRestoreDialog(
      repository: repository,
      files: files,
      restart: restart,
    ),
  ),
);

class SetupRestoreDialog extends StatefulWidget {
  const SetupRestoreDialog({
    super.key,
    required this.repository,
    required this.files,
    this.restart,
  });

  final BackupRepository repository;
  final BackupFiles files;
  final Future<void> Function()? restart;

  @override
  State<SetupRestoreDialog> createState() => _SetupRestoreDialogState();
}

class _SetupRestoreDialogState extends State<SetupRestoreDialog> {
  late final _vm = SetupRestoreViewModel(
    repository: widget.repository,
    files: widget.files,
    restart: widget.restart,
  );

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = _vm;
      final muted = theme.typography.body.sm.copyWith(
        color: theme.colors.mutedForeground,
      );
      final m = vm.manifest;
      final error = switch ((vm.pick.result, vm.restore.result)) {
        (_, Error(:final error)) || (Error(:final error), _) => error,
        _ => null,
      };
      // Selama backup disiapkan dialog tidak bisa ditutup: aplikasi segera
      // dimuat ulang.
      return PopScope(
        canPop: !vm.restore.running && !vm.staged,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              key: const ValueKey('setup-restore'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  l10n.backupRestoreTitle,
                  style: theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(l10n.setupRestoreIntro, style: muted),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FButton(
                    key: const ValueKey('setup-restore-pick'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: vm.busy ? null : vm.pick.execute,
                    prefix: const Icon(TablerIcons.fileZip),
                    child: Flexible(child: Text(l10n.setupRestorePick)),
                  ),
                ),
                if (vm.needsPassword) ...[
                  Text(
                    l10n.backupUnlockTitle,
                    key: const ValueKey('setup-restore-locked'),
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(l10n.backupUnlockBody, style: muted),
                  BackupUnlockFields(
                    key: ValueKey('setup-restore-unlock-${vm.unlockRevision}'),
                    keyPrefix: 'setup-restore-unlock',
                    enabled: !vm.unlock.running,
                    onChanged: vm.setUnlockPassword,
                    onSubmit: vm.canUnlock ? vm.unlock.execute : null,
                    error: switch (vm.unlock.result) {
                      Error(:final error) => error,
                      _ => null,
                    },
                  ),
                ],
                if (m != null) ...[
                  Text(
                    l10n.backupRestoreSummary(
                      m.tenantName,
                      m.outletName,
                      m.deviceCode,
                    ),
                    key: const ValueKey('setup-restore-summary'),
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.backupRestoreMade(
                      '${formatDayMonth(m.createdAt, null)}/'
                      '${outletLocalTime(m.createdAt, null).year} '
                      '${formatClock(m.createdAt, null)}',
                      m.sales,
                      m.products,
                    ),
                    style: theme.typography.body.sm,
                  ),
                  FAlert(title: Text(l10n.setupRestoreWarning)),
                  FTextField(
                    key: const ValueKey('setup-restore-confirm'),
                    label: Text(l10n.backupRestoreConfirmLabel(m.tenantName)),
                    enabled: !vm.restore.running,
                    control: .managed(
                      onChange: (v) => vm.setConfirmText(v.text),
                    ),
                  ),
                ],
                if (vm.staged)
                  FAlert(
                    key: const ValueKey('setup-restore-staged'),
                    title: Text(l10n.setupRestoreReopen),
                  ),
                if (error != null)
                  FAlert(
                    key: const ValueKey('setup-restore-error'),
                    variant: .destructive,
                    title: Text(backupRestoreError(l10n, error)),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    FButton(
                      key: const ValueKey('setup-restore-cancel'),
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: vm.restore.running || vm.staged
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Flexible(child: Text(l10n.backupRestoreCancel)),
                    ),
                    if (vm.needsPassword)
                      FButton(
                        key: const ValueKey('setup-restore-unlock'),
                        mainAxisSize: .min,
                        onPress: vm.canUnlock ? vm.unlock.execute : null,
                        prefix: vm.unlock.running
                            ? const FCircularProgress()
                            : const Icon(TablerIcons.lockOpen),
                        child: Flexible(child: Text(l10n.backupUnlock)),
                      ),
                    if (m != null)
                      FButton(
                        key: const ValueKey('setup-restore-submit'),
                        mainAxisSize: .min,
                        onPress: vm.canConfirm ? vm.restore.execute : null,
                        prefix: vm.restore.running
                            ? const FCircularProgress()
                            : null,
                        child: Flexible(
                          child: Text(l10n.backupRestoreConfirm),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
