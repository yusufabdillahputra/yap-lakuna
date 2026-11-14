import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../data/services/table_file.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/import_template.dart';
import '../customers/customer_import_view_model.dart' show ImportFileProblem;
import 'product_form_view.dart' show productErrorMessage;
import 'product_import_view_model.dart';

/// Dialog import produk (1.15, F1-07b). Hasil `true` bila ada import tersimpan.
Future<bool> showProductImport(
  BuildContext context,
  CatalogRepository repository, {
  required TableFilePicker picker,
  SpreadsheetExporter exporter = const PlatformSpreadsheetExporter(),
}) async {
  // Hasil dari callback: dialog bisa ditutup lewat latar setelah tersimpan.
  var saved = false;
  await showFDialog<void>(
    context: context,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
      builder: (context, style) => ProductImportDialog(
        repository: repository,
        picker: picker,
        exporter: exporter,
        onSaved: () => saved = true,
      ),
    ),
  );
  return saved;
}

String productImportReasonLabel(
  AppLocalizations l10n,
  ProductImportRejectReason reason,
) => switch (reason) {
  ProductImportRejectReason.name => l10n.importReasonName,
  ProductImportRejectReason.price => l10n.productImportReasonPrice,
  ProductImportRejectReason.cost => l10n.productImportReasonCost,
  ProductImportRejectReason.stock => l10n.productImportReasonStock,
  ProductImportRejectReason.kind => l10n.productImportReasonKind,
  ProductImportRejectReason.text => l10n.importReasonText,
  ProductImportRejectReason.sample => l10n.importReasonSample,
  ProductImportRejectReason.duplicateCode => l10n.productImportReasonCode,
  ProductImportRejectReason.duplicateName => l10n.productImportReasonName,
};

/// Nomor baris ringkas: sepuluh pertama lalu "…".
String _lines(List<int> lines) =>
    lines.length <= 10 ? lines.join(', ') : '${lines.take(10).join(', ')}, …';

class ProductImportDialog extends StatefulWidget {
  const ProductImportDialog({
    super.key,
    required this.repository,
    required this.picker,
    this.onSaved,
    this.exporter = const PlatformSpreadsheetExporter(),
  });

  final CatalogRepository repository;
  final TableFilePicker picker;
  final VoidCallback? onSaved;
  final SpreadsheetExporter exporter;

  @override
  State<ProductImportDialog> createState() => _ProductImportDialogState();
}

class _ProductImportDialogState extends State<ProductImportDialog> {
  late final _vm = ProductImportViewModel(
    repository: widget.repository,
    picker: widget.picker,
    onSaved: widget.onSaved,
  );

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = _vm;
      final muted = theme.typography.body.sm.copyWith(
        color: theme.colors.mutedForeground,
      );
      final problem = switch (vm.problem) {
        ImportFileProblem.tooLarge => l10n.importTooLarge,
        ImportFileProblem.unreadable => l10n.importUnreadable,
        ImportFileProblem.missingName => l10n.productImportMissingColumns,
        ImportFileProblem.empty => l10n.productImportEmpty,
        null => null,
      };
      final done = switch (vm.run.result) {
        Ok(:final value) => value,
        _ => null,
      };
      final rejected = vm.rejected;
      // Selama menyimpan, dialog tidak bisa ditutup (tombol, latar, atau
      // tombol kembali): transaksi tetap berjalan dan ringkasan harus tampil.
      return PopScope(
        canPop: !vm.run.running,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              key: const ValueKey('product-import'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  l10n.productImportTitle,
                  style: theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(l10n.productImportIntro, style: muted),
                ImportFileActions(
                  pick: FButton(
                    key: const ValueKey('product-import-pick'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: vm.pick.running || vm.run.running
                        ? null
                        : vm.pick.execute,
                    prefix: const Icon(TablerIcons.fileSpreadsheet),
                    child: Flexible(child: Text(l10n.importPick)),
                  ),
                  kind: ImportTemplateKind.products,
                  exporter: widget.exporter,
                  enabled: !vm.run.running,
                ),
                if (vm.fileName case final name?)
                  Text(
                    name,
                    key: const ValueKey('product-import-file'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (problem != null)
                  FAlert(
                    key: const ValueKey('product-import-problem'),
                    variant: .destructive,
                    title: Text(problem),
                  ),
                if (vm.result != null && vm.problem == null) ...[
                  Text(
                    l10n.importReady(vm.rows.length),
                    key: const ValueKey('product-import-ready'),
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  FSwitch(
                    key: const ValueKey('product-import-update'),
                    label: Text(l10n.productImportUpdate),
                    value: vm.updateExisting,
                    onChange: done == null && !vm.run.running
                        ? vm.setUpdateExisting
                        : null,
                  ),
                  Text(
                    vm.updateExisting
                        ? l10n.productImportUpdateNote
                        : l10n.productImportSkipNote,
                    key: const ValueKey('product-import-note'),
                    style: muted,
                  ),
                ],
                if (rejected.isNotEmpty &&
                    vm.problem != ImportFileProblem.missingName)
                  Column(
                    key: const ValueKey('product-import-rejected'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        l10n.importRejected(rejected.length),
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.destructive,
                        ),
                      ),
                      for (final r in rejected.take(20))
                        Text(
                          l10n.importRejectLine(
                            r.line,
                            productImportReasonLabel(l10n, r.reason),
                          ),
                          style: muted,
                        ),
                      if (rejected.length > 20)
                        Text(
                          l10n.importMoreRejected(rejected.length - 20),
                          style: muted,
                        ),
                    ],
                  ),
                if (done != null)
                  FAlert(
                    key: const ValueKey('product-import-done'),
                    title: Text(
                      vm.updateExisting
                          ? l10n.productImportDoneUpdate(
                              done.created,
                              done.updated,
                              done.unchanged,
                              done.skippedLines.length,
                            )
                          : l10n.productImportDone(
                              done.created,
                              done.skippedLines.length,
                            ),
                    ),
                    subtitle: done.skippedLines.isEmpty
                        ? null
                        : Text(
                            vm.updateExisting
                                ? l10n.productImportSkippedUnclear(
                                    _lines(done.skippedLines),
                                  )
                                : l10n.productImportSkippedLines(
                                    _lines(done.skippedLines),
                                  ),
                          ),
                  ),
                if (vm.run.result case Error(:final error))
                  Text(
                    productErrorMessage(l10n, error),
                    key: const ValueKey('product-import-error'),
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.destructive,
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    FButton(
                      key: const ValueKey('product-import-close'),
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: vm.run.running
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Text(
                        done != null
                            ? l10n.importClose
                            : l10n.productImportCancel,
                      ),
                    ),
                    if (done == null)
                      FButton(
                        key: const ValueKey('product-import-run'),
                        mainAxisSize: .min,
                        onPress: vm.canRun ? vm.run.execute : null,
                        child: Flexible(
                          child: Text(l10n.productImportRun(vm.rows.length)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
