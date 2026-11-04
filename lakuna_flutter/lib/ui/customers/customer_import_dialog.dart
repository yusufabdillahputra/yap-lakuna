import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/customers_repository.dart';
import '../../data/services/table_file.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import 'customer_import_view_model.dart';
import 'customer_labels.dart';

/// Dialog import pelanggan. Hasil `true` bila ada data tersimpan.
Future<bool> showCustomerImport(
  BuildContext context,
  CustomersRepository repository, {
  required TableFilePicker picker,
}) async =>
    await showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
        builder: (context, style) =>
            CustomerImportDialog(repository: repository, picker: picker),
      ),
    ) ??
    false;

String importRejectReasonLabel(
  AppLocalizations l10n,
  ImportRejectReason reason,
) => switch (reason) {
  ImportRejectReason.name => l10n.importReasonName,
  ImportRejectReason.phone => l10n.importReasonPhone,
  ImportRejectReason.creditLimit => l10n.importReasonLimit,
  ImportRejectReason.text => l10n.importReasonText,
  ImportRejectReason.duplicatePhone => l10n.importReasonDuplicate,
};

class CustomerImportDialog extends StatefulWidget {
  const CustomerImportDialog({
    super.key,
    required this.repository,
    required this.picker,
  });

  final CustomersRepository repository;
  final TableFilePicker picker;

  @override
  State<CustomerImportDialog> createState() => _CustomerImportDialogState();
}

class _CustomerImportDialogState extends State<CustomerImportDialog> {
  late final _vm = CustomerImportViewModel(
    repository: widget.repository,
    picker: widget.picker,
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
        ImportFileProblem.empty => l10n.importEmpty,
        null => null,
      };
      final done = switch (vm.run.result) {
        Ok(:final value) => value,
        _ => null,
      };
      final rejected = vm.rejected;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('customer-import'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                l10n.importTitle,
                style: theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(l10n.importIntro, style: muted),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FButton(
                  key: const ValueKey('customer-import-pick'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: vm.pick.running || vm.run.running
                      ? null
                      : vm.pick.execute,
                  prefix: const Icon(TablerIcons.fileSpreadsheet),
                  child: Flexible(child: Text(l10n.importPick)),
                ),
              ),
              if (vm.fileName case final name?)
                Text(
                  name,
                  key: const ValueKey('customer-import-file'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (problem != null)
                FAlert(
                  key: const ValueKey('customer-import-problem'),
                  variant: .destructive,
                  title: Text(problem),
                ),
              if (vm.result != null && vm.problem == null) ...[
                Text(
                  l10n.importReady(vm.rows.length),
                  key: const ValueKey('customer-import-ready'),
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(l10n.importUpdateNote, style: muted),
              ],
              if (rejected.isNotEmpty &&
                  vm.problem != ImportFileProblem.missingName)
                Column(
                  key: const ValueKey('customer-import-rejected'),
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
                          importRejectReasonLabel(l10n, r.reason),
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
                  key: const ValueKey('customer-import-done'),
                  title: Text(l10n.importDone(done.created, done.updated)),
                ),
              if (vm.run.result case Error(:final error))
                Text(
                  customerErrorMessage(l10n, error),
                  key: const ValueKey('customer-import-error'),
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
                    key: const ValueKey('customer-import-close'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: () => Navigator.of(context).pop(done != null),
                    child: Flexible(
                      child: Text(
                        done != null ? l10n.importClose : l10n.customerCancel,
                      ),
                    ),
                  ),
                  if (done == null)
                    FButton(
                      key: const ValueKey('customer-import-run'),
                      mainAxisSize: .min,
                      onPress: vm.canRun ? vm.run.execute : null,
                      child: Flexible(
                        child: Text(l10n.importRun(vm.rows.length)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
