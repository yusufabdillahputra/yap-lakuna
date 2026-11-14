import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/services/spreadsheet_exporter.dart';
import '../../l10n/gen/app_localizations.dart';

/// Templat import yang bisa diunduh (F1-07g), dalam bahasa aplikasi:
/// Inggris untuk `en`, selain itu Indonesia (F1-07p).
enum ImportTemplateKind {
  products(
    ('templat-import-produk.xlsx', 'import-template-products.xlsx'),
    ('Produk', 'Products'),
    (productImportTemplate, productImportTemplateEn),
  ),
  customers(
    ('templat-import-pelanggan.xlsx', 'import-template-customers.xlsx'),
    ('Pelanggan', 'Customers'),
    (customerImportTemplate, customerImportTemplateEn),
  ),
  suppliers(
    ('templat-import-supplier.xlsx', 'import-template-suppliers.xlsx'),
    ('Supplier', 'Suppliers'),
    (supplierImportTemplate, supplierImportTemplateEn),
  );

  const ImportTemplateKind(this._fileNames, this._sheetNames, this._rows);

  final (String, String) _fileNames;
  final (String, String) _sheetNames;
  final (List<List<String>>, List<List<String>>) _rows;

  static bool _en(String languageCode) => languageCode == 'en';

  String fileNameFor(String languageCode) =>
      _en(languageCode) ? _fileNames.$2 : _fileNames.$1;

  String sheetNameFor(String languageCode) =>
      _en(languageCode) ? _sheetNames.$2 : _sheetNames.$1;

  List<List<String>> rowsFor(String languageCode) =>
      _en(languageCode) ? _rows.$2 : _rows.$1;

  /// Judul kolom yang berisi kode/nomor: berformat teks di Excel agar nol
  /// di depan (telepon rumah, barcode) tidak hilang.
  static const _textHeaders = {'hp', 'telepon', 'phone', 'sku', 'barcode'};

  /// Isi `.xlsx` templat: judul tebal & dibekukan, lebar kolom menurut isi,
  /// kolom kode berformat teks, angka contoh ditulis sebagai angka.
  Uint8List bytesFor(String languageCode) {
    final rows = rowsFor(languageCode);
    final sheetName = sheetNameFor(languageCode);
    final header = rows.first;
    final text = {
      for (var c = 0; c < header.length; c++)
        if (_textHeaders.contains(header[c].toLowerCase())) c,
    };
    final number = RegExp(r'^(0|[1-9]\d{0,14})$');
    return buildXlsx(
      sheetName,
      [
        header,
        for (final r in rows.skip(1))
          [
            for (var c = 0; c < r.length; c++)
              !text.contains(c) && number.hasMatch(r[c])
                  ? int.parse(r[c])
                  : r[c],
          ],
      ],
      textColumns: text,
      widths: [
        for (var c = 0; c < header.length; c++)
          [
                for (final r in rows) c < r.length ? r[c].length : 0,
              ].reduce((a, b) => a > b ? a : b) +
              4,
      ],
    );
  }
}

/// Baris tombol di dialog import: [pick] (*Pilih berkas*) lalu *Unduh
/// templat*. Desktop: lokasi berkas templat tampil di bawah baris;
/// Android/iOS: share sheet.
class ImportFileActions extends StatefulWidget {
  const ImportFileActions({
    super.key,
    required this.pick,
    required this.kind,
    required this.exporter,
    this.enabled = true,
  });

  final Widget pick;
  final ImportTemplateKind kind;
  final SpreadsheetExporter exporter;
  final bool enabled;

  @override
  State<ImportFileActions> createState() => _ImportFileActionsState();
}

class _ImportFileActionsState extends State<ImportFileActions> {
  var _running = false;
  String? _savedPath;
  var _failed = false;

  Future<void> _save() async {
    setState(() {
      _running = true;
      _savedPath = null;
      _failed = false;
    });
    String? path;
    var failed = false;
    try {
      // Bahasa aplikasi saat tombol ditekan (F1-07p).
      final lang = Localizations.localeOf(context).languageCode;
      path = await widget.exporter.save(
        widget.kind.bytesFor(lang),
        fileName: widget.kind.fileNameFor(lang),
      );
    } on Object {
      // Termasuk Error dari share sheet; tombol tidak boleh terkunci.
      failed = true;
    }
    if (!mounted) return;
    setState(() {
      _running = false;
      _savedPath = path;
      _failed = failed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final key = widget.kind.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            widget.pick,
            FButton(
              key: ValueKey('import-template-$key'),
              variant: .ghost,
              mainAxisSize: .min,
              onPress: widget.enabled && !_running ? _save : null,
              prefix: const Icon(TablerIcons.download),
              child: Flexible(child: Text(l10n.importTemplateDownload)),
            ),
          ],
        ),
        if (_savedPath case final path?)
          Text(
            l10n.importTemplateSaved(path),
            key: ValueKey('import-template-saved-$key'),
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        if (_failed)
          Text(
            l10n.importTemplateFailed,
            key: ValueKey('import-template-failed-$key'),
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.destructive,
            ),
          ),
      ],
    );
  }
}
