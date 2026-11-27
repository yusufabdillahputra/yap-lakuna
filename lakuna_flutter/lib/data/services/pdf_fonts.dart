import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

const _regular = 'assets/fonts/pdf/DMSans-Regular.ttf';
const _semiBold = 'assets/fonts/pdf/DMSans-SemiBold.ttf';
const _heading = 'assets/fonts/pdf/Montserrat-Bold.ttf';

/// Byte font PDF yang dibundel. Dimuat di isolate utama (aset hanya bisa
/// dibaca di sana) lalu dikirim ke isolate pembuat PDF (F1-19f).
typedef PdfFontBytes = ({ByteData regular, ByteData semi, ByteData heading});

/// Font PDF siap pakai.
typedef PdfFonts = ({pw.Font regular, pw.Font semi, pw.Font heading});

Future<PdfFontBytes> loadPdfFontBytes() async => (
  regular: await rootBundle.load(_regular),
  semi: await rootBundle.load(_semiBold),
  heading: await rootBundle.load(_heading),
);

PdfFonts pdfFonts(PdfFontBytes bytes) => (
  regular: pw.Font.ttf(bytes.regular),
  semi: pw.Font.ttf(bytes.semi),
  heading: pw.Font.ttf(bytes.heading),
);
