import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../l10n/gen/app_localizations.dart';

/// Dialog *Buang perubahan?* dengan isi [body]; `true` bila pengguna
/// memilih buang. Kunci widget memakai awalan [key] (`<key>`,
/// `<key>-cancel`, `<key>-confirm`).
Future<bool> confirmDiscardChanges(
  BuildContext context, {
  required String body,
  required String key,
}) async {
  final l10n = AppLocalizations.of(context);
  final result = await showFDialog<bool>(
    context: context,
    // Menutupi menu samping juga, agar ketukan menu kedua tidak membuka
    // dialog kedua.
    useRootNavigator: true,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      builder: (context, style) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          key: ValueKey(key),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              l10n.floorDiscardTitle,
              style: context.theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(body),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                FButton(
                  key: ValueKey('$key-cancel'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(context).pop(false),
                  child: Text(l10n.floorDiscardKeep),
                ),
                FButton(
                  key: ValueKey('$key-confirm'),
                  variant: .destructive,
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(context).pop(true),
                  child: Text(l10n.floorDiscardConfirm),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
