import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../l10n/gen/app_localizations.dart';
import '../core/menu.dart';

/// Halaman sementara untuk modul yang belum dibangun.
class ComingSoonView extends StatelessWidget {
  const ComingSoonView({super.key, required this.moduleKey});

  final String moduleKey;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entry = menuEntryByKey(moduleKey);
    final name = entry?.label(l10n) ?? moduleKey;
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            if (entry != null)
              Icon(entry.icon, size: 48, color: theme.colors.mutedForeground),
            Text(
              l10n.comingSoonTitle(name),
              style: theme.typography.display.lg,
              textAlign: TextAlign.center,
            ),
            Text(
              l10n.comingSoonBody,
              style: theme.typography.body.md,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
