import 'package:barcode/barcode.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Kode QR hitam di atas putih (juga di mode gelap, agar terbaca kamera).
class QrImage extends StatelessWidget {
  const QrImage(this.data, {super.key, this.size = 200});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    final svg = Barcode.qrCode(
      errorCorrectLevel: BarcodeQRCorrectionLevel.medium,
    ).toSvg(data, width: size, height: size, drawText: false);
    return Semantics(
      image: true,
      label: 'QR',
      child: Container(
        color: const Color(0xFFFFFFFF),
        padding: const EdgeInsets.all(12),
        child: SvgPicture.string(svg, width: size, height: size),
      ),
    );
  }
}
