import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';

/// Penanda bahwa aplikasi bekerja offline dengan data di perangkat. Selalu
/// terlihat di bilah atas.
class OfflineBadge extends StatelessWidget {
  const OfflineBadge({super.key, this.compact = false});

  /// Di layar sempit hanya ikon yang tampil; teks tetap ada untuk pembaca layar.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (compact) {
      return Semantics(
        label: l10n.offlineBadge,
        child: FTooltip(
          tipBuilder: (context, _) => Text(l10n.offlineBadge),
          child: FBadge(
            variant: .secondary,
            child: const Icon(TablerIcons.cloudOff, size: 14),
          ),
        ),
      );
    }
    return FBadge(
      variant: .secondary,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          const Icon(TablerIcons.cloudOff, size: 14),
          Text(l10n.offlineBadge),
        ],
      ),
    );
  }
}
