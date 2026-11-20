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
///
/// Selama terpasang, dialog ini juga ditanya saat aplikasi diminta ditutup
/// lewat [canDiscardAll] (F1-02d).
class DiscardChangesScope extends StatefulWidget {
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

  /// Dialog yang sedang terpasang, urutan dipasang. Dialog form memakai
  /// navigator akar, di luar pohon `ExitGuard`, jadi tidak terjangkau
  /// lewat widget leluhur.
  static final _open = <_DiscardChangesScopeState>[];

  /// Semua dialog yang berubah boleh dibuang sekaligus (menutup jendela
  /// aplikasi, F1-02d). Dialog teratas ditanya lebih dulu; berhenti pada
  /// jawaban `false`. Dialog form tidak ditutup di sini: bila penjaga lain
  /// menolak, isiannya tetap ada.
  ///
  /// Dialog yang sedang menyimpan langsung `false` tanpa bertanya: form
  /// menutup dirinya dengan `Navigator.pop` setelah simpan, yang akan
  /// mengenai pertanyaan bila pertanyaan itu ada di atasnya.
  static Future<bool> canDiscardAll() async {
    for (final scope in _open.reversed.toList()) {
      if (scope.widget.busy) return false;
      if (!scope.widget.dirty || scope._closing) continue;
      if (!await scope._ask()) return false;
    }
    return true;
  }

  @override
  State<DiscardChangesScope> createState() => _DiscardChangesScopeState();
}

class _DiscardChangesScopeState extends State<DiscardChangesScope> {
  /// Pertanyaan yang sedang tampil dipakai ulang: Esc lalu tutup jendela
  /// tidak membuka dialog kedua.
  Future<bool>? _asking;

  /// Rute dialog ini sedang ditutup (animasi keluar setelah *Buang* atau
  /// simpan): isiannya sudah dilepas, tidak perlu ditanya lagi.
  bool get _closing =>
      ModalRoute.of(context)?.animation?.status == AnimationStatus.reverse;

  Future<bool> _ask() => _asking ??= confirmDiscardChanges(
    context,
    body: widget.body,
    key: widget.dialogKey,
  ).whenComplete(() => _asking = null);

  @override
  void initState() {
    super.initState();
    DiscardChangesScope._open.add(this);
  }

  @override
  void dispose() {
    DiscardChangesScope._open.remove(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: !widget.dirty && !widget.busy,
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop || widget.busy) return;
      final discard = await _ask();
      // Hanya menutup dialog ini, bukan rute lain yang kebetulan di atas.
      if (discard && mounted && _isCurrent(this.context)) {
        Navigator.of(this.context).pop();
      }
    },
    child: widget.child,
  );
}

/// Latar dialog form yang bisa diketuk untuk menutup lewat
/// `Navigator.maybePop`, sehingga [DiscardChangesScope] ikut bertanya.
/// Penghalang bawaan Forui memanggil `Navigator.pop` langsung (melewati
/// `PopScope`), jadi dialog memakai `barrierDismissible: false` dan
/// membungkus [FDialog]-nya dengan widget ini (F1-13e). Esc juga
/// diteruskan ke `maybePop`, termasuk saat tidak ada isian berfokus
/// (F1-09b).
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
    // Aksi Esc dicari dari fokus utama ke atas. Lingkup fokus sendiri di
    // bawah `Actions` menjaga fokus tetap di sini walau tidak ada isian
    // berfokus: dialog tanpa autofokus mengambil fokus lingkup ini, isian
    // yang dilepas fokusnya mengembalikan fokus ke lingkup ini, dan setelah
    // pertanyaan ditutup fokus kembali ke dalamnya (F1-09b).
    child: FocusScope(
      autofocus: true,
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
    ),
  );
}

bool _isCurrent(BuildContext context) =>
    ModalRoute.of(context)?.isCurrent ?? false;
