import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/suppliers_repository.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../data/services/table_file.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/import_template.dart';
import '../customers/customer_import_view_model.dart' show ImportFileProblem;
import 'supplier_import_view_model.dart';
import 'supplier_labels.dart';

/// Dialog import supplier (F1-14b). Hasil `true` bila ada data tersimpan.
Future<bool> showSupplierImport(
  BuildContext context,
  SuppliersRepository repository, {
  required TableFilePicker picker,
  SpreadsheetExporter exporter = const PlatformSpreadsheetExporter(),
}) async {
  // Hasil dari callback, bukan dari nilai pop: dialog bisa ditutup lewat
  // latar atau tombol kembali setelah import tersimpan.
  var saved = false;
  await showFDialog<void>(
    context: context,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
      builder: (context, style) => SupplierImportDialog(
        repository: repository,
        picker: picker,
        exporter: exporter,
        onSaved: () => saved = true,
      ),
    ),
  );
  return saved;
}

String supplierImportReasonLabel(
  AppLocalizations l10n,
  SupplierImportRejectReason reason,
) => switch (reason) {
  SupplierImportRejectReason.name => l10n.importReasonName,
  SupplierImportRejectReason.phone => l10n.supplierImportReasonPhone,
  SupplierImportRejectReason.termDays => l10n.supplierImportReasonTerm,
  SupplierImportRejectReason.text => l10n.importReasonText,
  SupplierImportRejectReason.duplicateName =>
    l10n.supplierImportReasonDuplicate,
};

class SupplierImportDialog extends StatefulWidget {
  const SupplierImportDialog({
    super.key,
    required this.repository,
    required this.picker,
    this.onSaved,
    this.exporter = const PlatformSpreadsheetExporter(),
  });

  final SuppliersRepository repository;
  final TableFilePicker picker;
  final VoidCallback? onSaved;
  final SpreadsheetExporter exporter;

  @override
  State<SupplierImportDialog> createState() => _SupplierImportDialogState();
}

class _SupplierImportDialogState extends State<SupplierImportDialog> {
  late final _vm = SupplierImportViewModel(
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
        ImportFileProblem.missingName => l10n.importMissingName,
        ImportFileProblem.empty => l10n.supplierImportEmpty,
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
              key: const ValueKey('supplier-import'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  l10n.supplierImportTitle,
                  style: theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(l10n.supplierImportIntro, style: muted),
                ImportFileActions(
                  pick: FButton(
                    key: const ValueKey('supplier-import-pick'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: vm.pick.running || vm.run.running
                        ? null
                        : vm.pick.execute,
                    prefix: const Icon(TablerIcons.fileSpreadsheet),
                    child: Flexible(child: Text(l10n.importPick)),
                  ),
                  kind: ImportTemplateKind.suppliers,
                  exporter: widget.exporter,
                  enabled: !vm.run.running,
                ),
                if (vm.fileName case final name?)
                  Text(
                    name,
                    key: const ValueKey('supplier-import-file'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (problem != null)
                  FAlert(
                    key: const ValueKey('supplier-import-problem'),
                    variant: .destructive,
                    title: Text(problem),
                  ),
                if (vm.result != null && vm.problem == null) ...[
                  Text(
                    l10n.importReady(vm.rows.length),
                    key: const ValueKey('supplier-import-ready'),
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    l10n.supplierImportUpdateNote(
                      SupplierLimits.defaultTermDays,
                    ),
                    style: muted,
                  ),
                ],
                if (rejected.isNotEmpty &&
                    vm.problem != ImportFileProblem.missingName)
                  Column(
                    key: const ValueKey('supplier-import-rejected'),
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
                            supplierImportReasonLabel(l10n, r.reason),
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
                    key: const ValueKey('supplier-import-done'),
                    title: Text(
                      l10n.supplierImportDone(
                        done.created,
                        done.updated,
                        vm.rejected.length,
                      ),
                    ),
                  ),
                if (vm.run.result case Error(:final error))
                  Text(
                    supplierErrorMessage(l10n, error),
                    key: const ValueKey('supplier-import-error'),
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
                      key: const ValueKey('supplier-import-close'),
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: vm.run.running
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: Flexible(
                        child: Text(
                          done != null ? l10n.importClose : l10n.supplierCancel,
                        ),
                      ),
                    ),
                    if (done == null)
                      FButton(
                        key: const ValueKey('supplier-import-run'),
                        mainAxisSize: .min,
                        onPress: vm.canRun ? vm.run.execute : null,
                        child: Flexible(
                          child: Text(l10n.supplierImportRun(vm.rows.length)),
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
