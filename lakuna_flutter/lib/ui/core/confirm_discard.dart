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

/// Menahan penutupan dialog form yang [dirty] (F1-13e): ketukan di luar
/// dialog, Esc, tombol kembali sistem, dan `Navigator.maybePop` (mis. tombol
/// Batal) menampilkan [confirmDiscardChanges] lebih dulu. Selama [busy]
/// dialog tidak bisa ditutup. `Navigator.pop` (hasil simpan) tidak ditahan.
class DiscardChangesScope extends StatelessWidget {
  const DiscardChangesScope({
    super.key,
    required this.dirty,
    required this.busy,
    required this.body,
    required this.dialogKey,
    required this.child,
  });

  final bool dirty;
  final bool busy;
  final String body;

  /// Awalan kunci widget dialog konfirmasi.
  final String dialogKey;
  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: !dirty && !busy,
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop || busy) return;
      final discard = await confirmDiscardChanges(
        context,
        body: body,
        key: dialogKey,
      );
      // Hanya menutup dialog ini, bukan rute lain yang kebetulan di atas.
      if (discard && context.mounted && _isCurrent(context)) {
        Navigator.of(context).pop();
      }
    },
    child: child,
  );
}

/// Latar dialog form yang bisa diketuk untuk menutup lewat
/// `Navigator.maybePop`, sehingga [DiscardChangesScope] ikut bertanya.
/// Penghalang bawaan Forui memanggil `Navigator.pop` langsung (melewati
/// `PopScope`), jadi dialog memakai `barrierDismissible: false` dan
/// membungkus [FDialog]-nya dengan widget ini (F1-13e). Esc juga
/// diteruskan ke `maybePop`.
class TapOutsideToPop extends StatelessWidget {
  const TapOutsideToPop({super.key, required this.child});

  final Widget child;

  void _dismiss(BuildContext context) {
    // Rute yang sedang ditutup (animasi keluar) tidak meneruskan ke rute
    // di bawahnya.
    if (_isCurrent(context)) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) => Actions(
    // Esc: rute dengan `barrierDismissible: false` mematikan aksi tutup
    // bawaan, jadi dipasang ulang lewat `maybePop`.
    actions: {
      DismissIntent: CallbackAction<DismissIntent>(
        onInvoke: (_) => _dismiss(context),
      ),
    },
    child: Stack(
      children: [
        Positioned.fill(
          child: Semantics(
            label: FLocalizations.of(context)?.barrierLabel,
            onTap: () => _dismiss(context),
            child: GestureDetector(
              key: const ValueKey('dialog-outside'),
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTap: () => _dismiss(context),
            ),
          ),
        ),
        child,
      ],
    ),
  );
}

bool _isCurrent(BuildContext context) =>
    ModalRoute.of(context)?.isCurrent ?? false;
