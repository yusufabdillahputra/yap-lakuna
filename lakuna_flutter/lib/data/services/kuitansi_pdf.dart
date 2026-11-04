import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const _regular = 'assets/fonts/pdf/DMSans-Regular.ttf';
const _semiBold = 'assets/fonts/pdf/DMSans-SemiBold.ttf';
const _italic = 'assets/fonts/pdf/DMSans-Italic.ttf';
const _heading = 'assets/fonts/pdf/Montserrat-Bold.ttf';

/// Satu baris isian kuitansi: *Telah terima dari*, *Uang sejumlah*, ….
@immutable
class KuitansiField {
  const KuitansiField(this.label, this.value, {this.italic = false});

  final String label;
  final String value;
  final bool italic;
}

/// Isi kuitansi A5 (1.20b) yang sudah diterjemahkan dan diformat.
@immutable
class KuitansiDocument {
  const KuitansiDocument({
    required this.title,
    required this.number,
    required this.storeName,
    required this.storeLine,
    required this.fields,
    required this.placeDate,
    required this.amount,
    required this.signName,
    required this.signRole,
    this.banner,
    this.tableHead = const [],
    this.tableRows = const [],
    this.footnote,
  });

  /// `KUITANSI`.
  final String title;
  final String number;
  final String storeName;

  /// Cabang · alamat · telepon.
  final String storeLine;

  /// Tanda cetak ulang, mis. `SALINAN`.
  final String? banner;
  final List<KuitansiField> fields;

  /// Judul tiga kolom rincian (nota, sisa sebelum, dibayar); kosong =
  /// rincian disembunyikan.
  final List<String> tableHead;
  final List<List<String>> tableRows;

  /// `Purwokerto, 3 November 2026`.
  final String placeDate;

  /// `Rp 800.000`.
  final String amount;
  final String signName;
  final String signRole;

  /// Sisa piutang setelah pembayaran; `null` = disembunyikan.
  final String? footnote;
}

/// PDF kuitansi ukuran A5 tegak.
Future<Uint8List> buildKuitansiPdf(KuitansiDocument k) async =>
    (await kuitansiPdfDocument(k)).save();

/// Dokumen PDF kuitansi. Tabel nota panjang (pelunasan puluhan nota)
/// berlanjut ke halaman berikutnya; jumlah dan tanda tangan ikut di akhir.
Future<pw.Document> kuitansiPdfDocument(KuitansiDocument k) async {
  final regular = pw.Font.ttf(await rootBundle.load(_regular));
  final semi = pw.Font.ttf(await rootBundle.load(_semiBold));
  final italic = pw.Font.ttf(await rootBundle.load(_italic));
  final heading = pw.Font.ttf(await rootBundle.load(_heading));
  const ink = PdfColor.fromInt(0xFF18181B);
  const muted = PdfColor.fromInt(0xFF52525B);
  const rule = PdfColor.fromInt(0xFFD4D4D8);
  pw.TextStyle body({pw.Font? font, double size = 9, PdfColor color = ink}) =>
      pw.TextStyle(font: font ?? regular, fontSize: size, color: color);

  final doc = pw.Document(title: k.number, creator: 'Lakuna');
  doc.addPage(
    pw.MultiPage(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      pageFormat: PdfPageFormat.a5.copyWith(
        marginLeft: 14 * PdfPageFormat.mm,
        marginRight: 14 * PdfPageFormat.mm,
        marginTop: 14 * PdfPageFormat.mm,
        marginBottom: 14 * PdfPageFormat.mm,
      ),
      build: (_) => [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(k.storeName, style: body(font: heading, size: 13)),
                  pw.SizedBox(height: 2),
                  pw.Text(k.storeLine, style: body(size: 8, color: muted)),
                ],
              ),
            ),
            pw.SizedBox(width: 12),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(k.title, style: body(font: heading, size: 15)),
                pw.SizedBox(height: 2),
                pw.Text(k.number, style: body(size: 8, color: muted)),
                if (k.banner case final banner?) ...[
                  pw.SizedBox(height: 4),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: ink, width: 0.8),
                    ),
                    child: pw.Text(banner, style: body(font: semi, size: 8)),
                  ),
                ],
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(height: 1.6, color: ink),
        pw.SizedBox(height: 12),
        for (final f in k.fields)
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 105,
                  child: pw.Text(f.label, style: body(color: muted)),
                ),
                pw.Expanded(
                  child: pw.Text(
                    f.value,
                    style: body(font: f.italic ? italic : semi),
                  ),
                ),
              ],
            ),
          ),
        if (k.tableHead.length == 3) ...[
          pw.SizedBox(height: 10),
          pw.Table(
            columnWidths: const {
              0: pw.FlexColumnWidth(5),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(3),
            },
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(color: rule, width: 0.6),
              top: pw.BorderSide(color: rule, width: 0.6),
              bottom: pw.BorderSide(color: rule, width: 0.6),
            ),
            children: [
              for (final (i, row) in [k.tableHead, ...k.tableRows].indexed)
                pw.TableRow(
                  children: [
                    for (final (c, cell) in row.indexed)
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 4),
                        child: pw.Text(
                          cell,
                          textAlign: c == 0
                              ? pw.TextAlign.left
                              : pw.TextAlign.right,
                          style: body(
                            size: 8,
                            color: i == 0 ? muted : ink,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
        pw.SizedBox(height: 10),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(k.placeDate, style: body(size: 8, color: muted)),
        ),
        pw.SizedBox(height: 18),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: ink, width: 1.4),
              ),
              child: pw.Text(k.amount, style: body(font: heading, size: 14)),
            ),
            pw.Spacer(),
            pw.SizedBox(
              width: 120,
              child: pw.Column(
                children: [
                  pw.SizedBox(height: 28),
                  pw.Text(k.signName, style: body(font: semi)),
                  pw.Text(k.signRole, style: body(size: 8, color: muted)),
                ],
              ),
            ),
          ],
        ),
        if (k.footnote case final note?) ...[
          pw.SizedBox(height: 12),
          pw.Text(note, style: body(size: 8, color: muted)),
        ],
      ],
    ),
  );
  return doc;
}
