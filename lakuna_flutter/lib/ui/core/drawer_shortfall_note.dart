import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import 'format.dart';

/// Peringatan uang keluar dari laci melebihi perkiraan uang di laci
/// (F1-03c). Hanya peringatan: simpan tetap bisa. Kunci widget:
/// `<keyPrefix>-drawer-short`.
class DrawerShortfallNote extends StatelessWidget {
  const DrawerShortfallNote({
    super.key,
    required this.keyPrefix,
    required this.drawerCash,
    required this.shortfall,
  });

  final String keyPrefix;

  /// Perkiraan uang di laci (*Kas seharusnya*).
  final Money drawerCash;

  /// Kelebihan jumlah di atas perkiraan.
  final Money shortfall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FAlert(
      key: ValueKey('$keyPrefix-drawer-short'),
      icon: const Icon(TablerIcons.alertTriangle),
      title: Text(
        l10n.drawerShortfallWarning(
          formatMoney(context, drawerCash),
          formatMoney(context, shortfall),
        ),
      ),
    );
  }
}
