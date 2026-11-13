import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';

/// Satu printer Bluetooth di daftar pilihan: nama, alamat, *Pilih* /
/// *Terpilih*.
class PrinterDeviceRow extends StatelessWidget {
  const PrinterDeviceRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onChoose,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? theme.colors.primary : theme.colors.border,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          spacing: 10,
          children: [
            const Icon(TablerIcons.printer, size: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Text(
                l10n.printerSelected,
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              FButton(
                variant: .outline,
                size: .sm,
                mainAxisSize: .min,
                onPress: onChoose,
                child: Text(l10n.printerChoose),
              ),
          ],
        ),
      ),
    );
  }
}
