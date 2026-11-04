import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart' show SupplierInvalid;
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/suppliers_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../customers/customer_labels.dart' show formatPhone;
import 'supplier_form_view_model.dart';
import 'supplier_labels.dart';

/// Dialog tambah/ubah supplier. Hasil = supplier tersimpan, `null` bila
/// dibatalkan.
Future<Supplier?> showSupplierForm(
  BuildContext context,
  SuppliersRepository repository, {
  Supplier? supplier,
}) => showFDialog<Supplier>(
  context: context,
  builder: (context, style, animation) => FDialog(
    animation: animation,
    constraints: const BoxConstraints(minWidth: 280, maxWidth: 520),
    builder: (context, style) =>
        SupplierFormDialog(repository: repository, supplier: supplier),
  ),
);

class SupplierFormDialog extends StatefulWidget {
  const SupplierFormDialog({
    super.key,
    required this.repository,
    this.supplier,
  });

  final SuppliersRepository repository;
  final Supplier? supplier;

  @override
  State<SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends State<SupplierFormDialog> {
  late final _vm = SupplierFormViewModel(
    repository: widget.repository,
    supplier: widget.supplier,
  );

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await _vm.save.execute();
    if (!mounted) return;
    if (_vm.save.result case Ok(:final value)) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = _vm;
      final issues = vm.issues;
      Text? err(SupplierIssue i) =>
          issues.contains(i) ? Text(supplierIssueMessage(l10n, i)) : null;
      final saveError = switch (vm.save.result) {
        Error(:final error) when error is! SupplierInvalid =>
          supplierErrorMessage(l10n, error),
        _ => null,
      };
      Widget field(
        String key,
        String label,
        String initial,
        void Function(String) onChange, {
        SupplierIssue? issue,
        String? hint,
        String? description,
        int maxLines = 1,
        bool autofocus = false,
        TextInputType? keyboard,
        List<TextInputFormatter>? formatters,
      }) => FTextField(
        key: ValueKey('supplier-form-$key'),
        label: Text(label),
        hint: hint,
        description: description == null ? null : Text(description),
        autofocus: autofocus,
        maxLines: maxLines,
        keyboardType: keyboard,
        inputFormatters: formatters,
        error: issue == null ? null : err(issue),
        control: .managed(
          initial: TextEditingValue(text: initial),
          onChange: (v) => onChange(v.text),
        ),
      );
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('supplier-form'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                vm.isEdit ? l10n.supplierFormEdit : l10n.supplierFormNew,
                style: theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              field(
                'name',
                l10n.supplierFieldName,
                vm.name,
                vm.setName,
                issue: SupplierIssue.name,
                autofocus: true,
              ),
              field(
                'contact',
                l10n.supplierFieldContact,
                vm.contactName,
                vm.setContactName,
                issue: SupplierIssue.contactName,
              ),
              field(
                'phone',
                l10n.supplierFieldPhone,
                formatPhone(vm.phone),
                vm.setPhone,
                issue: SupplierIssue.phone,
                hint: '021-555-0101',
                keyboard: TextInputType.phone,
              ),
              field(
                'category',
                l10n.supplierFieldCategory,
                vm.category,
                vm.setCategory,
                issue: SupplierIssue.category,
                hint: l10n.supplierCategoryHint,
              ),
              field(
                'term',
                l10n.supplierFieldTerm,
                vm.termDays < 0 ? '' : '${vm.termDays}',
                vm.setTermDays,
                issue: SupplierIssue.termDays,
                description: l10n.supplierTermHint,
                keyboard: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
              ),
              field(
                'address',
                l10n.supplierFieldAddress,
                vm.address,
                vm.setAddress,
                issue: SupplierIssue.address,
                maxLines: 2,
              ),
              field(
                'note',
                l10n.supplierFieldNote,
                vm.note,
                vm.setNote,
                issue: SupplierIssue.note,
              ),
              if (saveError != null)
                Text(
                  saveError,
                  key: const ValueKey('supplier-form-error'),
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
                    key: const ValueKey('supplier-form-cancel'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: () => Navigator.of(context).pop(),
                    child: Text(l10n.supplierCancel),
                  ),
                  FButton(
                    key: const ValueKey('supplier-form-save'),
                    mainAxisSize: .min,
                    onPress: vm.save.running ? null : _save,
                    child: Text(l10n.supplierSave),
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
