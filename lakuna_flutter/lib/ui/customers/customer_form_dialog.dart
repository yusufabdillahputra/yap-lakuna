import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart' show CustomerInvalid;
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/customers_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/format.dart';
import 'customer_form_view_model.dart';
import 'customer_labels.dart';

/// Dialog tambah/ubah pelanggan. Hasil = pelanggan tersimpan, `null` bila
/// dibatalkan. [initialName] / [initialPhone] mengisi form pelanggan baru
/// (mis. dari kata pencarian Kasir, F1-04f).
Future<Customer?> showCustomerForm(
  BuildContext context,
  CustomersRepository repository, {
  Customer? customer,
  String initialName = '',
  String initialPhone = '',
}) => showFDialog<Customer>(
  context: context,
  builder: (context, style, animation) => FDialog(
    animation: animation,
    constraints: const BoxConstraints(minWidth: 280, maxWidth: 520),
    builder: (context, style) => CustomerFormDialog(
      repository: repository,
      customer: customer,
      initialName: initialName,
      initialPhone: initialPhone,
    ),
  ),
);

/// Kata pencarian → isian awal pelanggan baru: nomor (angka dengan `+`,
/// spasi, `-`, `.`, atau kurung; minimal 6 digit) = HP yang dinormalisasi,
/// selain itu nama.
({String name, String phone}) customerDraftFromQuery(String query) {
  final q = query.trim();
  if (q.isEmpty) return (name: '', phone: '');
  final digits = q.replaceAll(RegExp(r'\D'), '');
  final isPhone = RegExp(r'^[0-9+\s().-]+$').hasMatch(q) && digits.length >= 6;
  return isPhone ? (name: '', phone: normalizePhone(q)) : (name: q, phone: '');
}

/// Membawa repositori pelanggan ke layar lain (Kasir) agar bisa membuka form
/// *Pelanggan baru* (F1-04f).
class CustomerFormScope extends InheritedWidget {
  const CustomerFormScope({
    super.key,
    required this.repository,
    required super.child,
  });

  final CustomersRepository repository;

  static CustomersRepository? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<CustomerFormScope>()
      ?.repository;

  @override
  bool updateShouldNotify(CustomerFormScope oldWidget) =>
      repository != oldWidget.repository;
}

class CustomerFormDialog extends StatefulWidget {
  const CustomerFormDialog({
    super.key,
    required this.repository,
    this.customer,
    this.initialName = '',
    this.initialPhone = '',
  });

  final CustomersRepository repository;
  final Customer? customer;
  final String initialName;
  final String initialPhone;

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  late final _vm = CustomerFormViewModel(
    repository: widget.repository,
    customer: widget.customer,
    initialName: widget.initialName,
    initialPhone: widget.initialPhone,
  )..load.execute();

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
      Text? err(CustomerIssue i) =>
          issues.contains(i) ? Text(customerIssueMessage(l10n, i)) : null;
      final saveError = switch (vm.save.result) {
        Error(:final error) when error is! CustomerInvalid =>
          customerErrorMessage(
            l10n,
            error,
          ),
        _ => null,
      };
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('customer-form'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                vm.isEdit ? l10n.customerFormEdit : l10n.customerFormNew,
                style: theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              FTextField(
                key: const ValueKey('customer-form-name'),
                label: Text(l10n.customerFieldName),
                autofocus: true,
                error: err(CustomerIssue.name),
                control: .managed(
                  initial: TextEditingValue(text: vm.name),
                  onChange: (v) => vm.setName(v.text),
                ),
              ),
              FTextField(
                key: const ValueKey('customer-form-phone'),
                label: Text(l10n.customerFieldPhone),
                hint: '0812-3456-7890',
                keyboardType: TextInputType.phone,
                error: err(CustomerIssue.phone),
                control: .managed(
                  initial: TextEditingValue(text: formatPhone(vm.phone)),
                  onChange: (v) => vm.setPhone(v.text),
                ),
              ),
              FSelect<String>(
                key: ValueKey('customer-form-group-${vm.groups.length}'),
                label: Text(l10n.customerFieldGroup),
                items: {
                  l10n.customerGroupNone: customerNoGroupKey,
                  for (final g in vm.groups)
                    l10n.customerGroupOption(g.group.name, g.group.termDays):
                        g.group.id.uuid,
                  l10n.customerGroupNew: customerNewGroupKey,
                },
                control: .managed(
                  initial: vm.groupKey,
                  onChange: (v) {
                    if (v != null) vm.setGroup(v);
                  },
                ),
              ),
              if (vm.groupKey == customerNewGroupKey)
                FTextField(
                  key: const ValueKey('customer-form-new-group'),
                  label: Text(l10n.customerFieldNewGroup),
                  hint: l10n.customerNewGroupHint,
                  error: err(CustomerIssue.group),
                  control: .managed(
                    initial: TextEditingValue(text: vm.newGroup),
                    onChange: (v) => vm.setNewGroup(v.text),
                  ),
                ),
              FTextField(
                key: const ValueKey('customer-form-limit'),
                label: Text(l10n.customerFieldLimit),
                description: Text(l10n.customerLimitHint),
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: const [RupiahInputFormatter()],
                error: err(CustomerIssue.creditLimit),
                control: .managed(
                  initial: TextEditingValue(
                    text: vm.creditLimit.value == 0
                        ? ''
                        : groupThousands(vm.creditLimit.value, '.'),
                  ),
                  onChange: (v) => vm.setCreditLimit(parseSignedRupiah(v.text)),
                ),
              ),
              FTextField(
                key: const ValueKey('customer-form-address'),
                label: Text(l10n.customerFieldAddress),
                maxLines: 2,
                error: err(CustomerIssue.address),
                control: .managed(
                  initial: TextEditingValue(text: vm.address),
                  onChange: (v) => vm.setAddress(v.text),
                ),
              ),
              FTextField(
                key: const ValueKey('customer-form-note'),
                label: Text(l10n.customerFieldNote),
                error: err(CustomerIssue.note),
                control: .managed(
                  initial: TextEditingValue(text: vm.note),
                  onChange: (v) => vm.setNote(v.text),
                ),
              ),
              if (saveError != null)
                Text(
                  saveError,
                  key: const ValueKey('customer-form-error'),
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
                    key: const ValueKey('customer-form-cancel'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: () => Navigator.of(context).pop(),
                    child: Text(l10n.customerCancel),
                  ),
                  FButton(
                    key: const ValueKey('customer-form-save'),
                    mainAxisSize: .min,
                    onPress: vm.save.running ? null : _save,
                    child: Text(l10n.customerSave),
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
