import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show Permission;
import 'package:material_ui/material_ui.dart' show SelectableText;
import 'package:provider/provider.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../app_root.dart';
import '../../config/app_environment.dart';
import '../../data/repositories/backup_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../routing/routes.dart';
import '../login/login_view.dart' show roleLabel;

/// Beranda: sambutan, pengingat backup (F1-19), toko aktif, dan informasi
/// perangkat.
class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.store,
    required this.session,
    this.backup,
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  final StoreRepository store;
  final SessionRepository session;

  /// Sumber waktu backup terakhir; pengingat hanya untuk staf dengan
  /// `backup:manage`.
  final BackupRepository? backup;
  final DateTime Function() clock;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  var _backupLoaded = false;
  DateTime? _lastBackup;

  @override
  void initState() {
    super.initState();
    final backup = widget.backup;
    if (backup != null &&
        (widget.session.current?.can(Permission.backupManage) ?? false)) {
      backup
          .lastBackupAt()
          .then((at) {
            if (!mounted) return;
            setState(() {
              _backupLoaded = true;
              _lastBackup = at;
            });
          })
          .catchError((Object e) => debugPrint('Backup terakhir: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final env = context.read<AppEnvironment>();
    final theme = context.theme;
    final ctx = widget.store.current;
    final staff = widget.session.current;
    final now = widget.clock().toUtc();
    final remind = _backupLoaded && backupOverdue(_lastBackup, now);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Text(l10n.homeWelcomeTitle, style: theme.typography.display.xl2),
              Text(l10n.homeWelcomeBody, style: theme.typography.body.md),
              if (AppRestart.maybeOf(context)?.restoreFailed ?? false)
                FAlert(
                  key: const ValueKey('home-restore-failed'),
                  variant: .destructive,
                  icon: const Icon(TablerIcons.alertTriangle),
                  title: Text(l10n.homeRestoreFailedTitle),
                  subtitle: Text(l10n.homeRestoreFailedBody),
                ),
              if (remind)
                FAlert(
                  key: const ValueKey('home-backup-reminder'),
                  variant: .destructive,
                  icon: const Icon(TablerIcons.alertTriangle),
                  title: Text(l10n.homeBackupTitle),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Text(switch (_lastBackup) {
                        final t? => l10n.homeBackupDays(
                          now.difference(t).inDays,
                        ),
                        null => l10n.homeBackupNever,
                      }),
                      FButton(
                        key: const ValueKey('home-backup-action'),
                        variant: .outline,
                        size: .sm,
                        mainAxisSize: .min,
                        onPress: () => context.go(Routes.settingsBackup),
                        prefix: const Icon(TablerIcons.databaseExport),
                        child: Flexible(child: Text(l10n.homeBackupAction)),
                      ),
                    ],
                  ),
                ),
              FCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      if (ctx != null)
                        _InfoRow(
                          label: l10n.homeStoreLabel,
                          value:
                              '${ctx.tenant.name} · ${ctx.outlet.name} · '
                              '${ctx.device.code}',
                        ),
                      if (staff != null)
                        _InfoRow(
                          label: l10n.homeStaffLabel,
                          value:
                              '${staff.name} · '
                              '${roleLabel(l10n, staff.roleKey, staff.roleName)}',
                        ),
                      _InfoRow(
                        label: l10n.homeVersionLabel,
                        value: env.version,
                      ),
                      _InfoRow(
                        label: l10n.homeDeviceLabel,
                        value: env.deviceId,
                      ),
                      _InfoRow(
                        label: l10n.homeDataLabel,
                        value: env.databasePath,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        SelectableText(value, style: theme.typography.body.md),
      ],
    );
  }
}
