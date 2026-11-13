import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/services/spreadsheet_exporter.dart';
import '../../l10n/gen/app_localizations.dart';

/// Templat import yang bisa diunduh (F1-07g).
enum ImportTemplateKind {
  products('templat-import-produk.xlsx', 'Produk', productImportTemplate),
  customers(
    'templat-import-pelanggan.xlsx',
    'Pelanggan',
    customerImportTemplate,
  ),
  suppliers('templat-import-supplier.xlsx', 'Supplier', supplierImportTemplate);

  const ImportTemplateKind(this.fileName, this.sheetName, this.rows);

  final String fileName;
  final String sheetName;
  final List<List<String>> rows;

  /// Isi `.xlsx` templat: judul tebal & dibekukan, lebar kolom menurut isi.
  Uint8List get bytes => buildXlsx(
    sheetName,
    rows,
    widths: [
      for (var c = 0; c < rows.first.length; c++)
        [for (final r in rows) r[c].length].reduce((a, b) => a > b ? a : b) + 4,
    ],
  );
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
      path = await widget.exporter.save(
        widget.kind.bytes,
        fileName: widget.kind.fileName,
      );
    } on Exception {
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
