import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart' show SelectableText;
import 'package:provider/provider.dart';

import '../../config/app_environment.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../login/login_view.dart' show roleLabel;

/// Beranda: sambutan, toko aktif, dan informasi perangkat.
class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.store, required this.session});

  final StoreRepository store;
  final SessionRepository session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final env = context.read<AppEnvironment>();
    final theme = context.theme;
    final ctx = store.current;
    final staff = session.current;
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
                              '${roleLabel(l10n, staff.roleKey)}',
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
