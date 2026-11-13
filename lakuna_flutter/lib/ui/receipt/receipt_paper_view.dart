import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

/// Kertas struk di layar: baris yang sama dengan cetakan, font DM Mono,
/// latar putih di tema apa pun (seperti kertas).
class ReceiptPaperView extends StatelessWidget {
  const ReceiptPaperView({
    super.key,
    required this.lines,
    required this.paper,
    this.logo,
  });

  final List<ReceiptLine> lines;
  final ReceiptPaper paper;

  /// Logo struk di tengah atas (F1-06b); gambar rusak dilewati.
  final Uint8List? logo;

  static const _fontSize = 12.0;

  /// DM Mono: lebar karakter 0,6 em.
  static const _charWidth = _fontSize * 0.6;
  static const _ink = Color(0xFF111111);
  static const _rule = Color(0xFF9F9FA9);

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(
      fontFamily: 'DM Mono',
      fontSize: _fontSize,
      height: 1.45,
      color: _ink,
      decoration: TextDecoration.none,
    );
    final columns = paper.columns;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFFE4E4E7)),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: columns * _charWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (logo case final bytes?)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: columns * _charWidth * 0.6,
                        maxHeight: 56,
                      ),
                      child: Image.memory(
                        bytes,
                        key: const ValueKey('receipt-paper-logo'),
                        fit: BoxFit.contain,
                        cacheWidth: 400,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              for (final line in lines)
                Text(
                  line.text,
                  maxLines: 1,
                  // Kolom tetap; FittedBox yang menyesuaikan ukuran.
                  textScaler: TextScaler.noScaling,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  textAlign: switch (line.align) {
                    ReceiptAlign.left => TextAlign.left,
                    ReceiptAlign.center => TextAlign.center,
                    ReceiptAlign.right => TextAlign.right,
                  },
                  style: line.text == '-' * columns
                      ? base.copyWith(color: _rule)
                      : line.bold
                      ? base.copyWith(fontWeight: FontWeight.w500)
                      : base,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
