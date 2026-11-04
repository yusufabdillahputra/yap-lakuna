import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/format.dart';
import '../core/photo_attach_field.dart';
import '../purchases/purchase_labels.dart' show formatCalendarDate;
import 'expense_form_view_model.dart';
import 'expense_labels.dart';

Widget _rpPrefix(
  BuildContext context,
  FTextFieldStyle style,
  Set<FTextFieldVariant> _,
) => Padding(
  padding: const EdgeInsetsDirectional.only(start: 12),
  child: Text(
    'Rp',
    style: context.theme.typography.body.sm.copyWith(
      color: context.theme.colors.mutedForeground,
    ),
  ),
);

/// Isian *Catat pengeluaran* (1.22). Dipakai di kartu kanan (layar lebar)
/// dan di dialog (layar sempit). [onSaved] dipanggil setelah tersimpan.
class ExpenseForm extends StatelessWidget {
  const ExpenseForm({
    super.key,
    required this.viewModel,
    required this.onSaved,
    this.onCancel,
    this.onFailed,
  });

  final ExpenseFormViewModel viewModel;
  final Future<void> Function(Expense expense) onSaved;

  /// Tombol *Batal* (hanya di dialog).
  final VoidCallback? onCancel;

  /// Dipanggil saat simpan ditolak di luar validasi isian (mis. sesi kasir
  /// sudah ditutup), agar layar memuat ulang setup.
  final VoidCallback? onFailed;

  Future<void> _save() async {
    await viewModel.save.execute();
    switch (viewModel.save.result) {
      case Ok(:final value):
        await onSaved(value);
      case Error(:final error) when error is! ExpenseInvalid:
        onFailed?.call();
      default:
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = viewModel;
      final gen = vm.generation;
      final issues = vm.issues;
      final drawerIssue = vm.drawerIssue;
      final saveError = switch (vm.save.result) {
        // Galat validasi sudah tampil di field-nya.
        Error(:final error) when error is! ExpenseInvalid =>
          expenseErrorMessage(l10n, error),
        _ => null,
      };
      final categories = vm.setup.categories;
      return Column(
        key: const ValueKey('expense-form'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          FTextField(
            key: ValueKey('expense-description-$gen'),
            label: Text(l10n.expenseDescription),
            hint: l10n.expenseDescriptionHint,
            maxLength: ExpenseLimits.description,
            error: issues.contains(ExpenseIssue.description)
                ? Text(expenseIssueMessage(l10n, ExpenseIssue.description))
                : null,
            control: .managed(
              initial: TextEditingValue(text: vm.description),
              onChange: (v) => vm.setDescription(v.text),
            ),
          ),
          FSelect<String>(
            key: ValueKey('expense-category-$gen-${categories.length}'),
            label: Text(l10n.expenseCategory),
            hint: l10n.expenseCategoryHint,
            items: {for (final c in categories) c.name: c.id.uuid},
            forceErrorText: issues.contains(ExpenseIssue.category)
                ? expenseIssueMessage(l10n, ExpenseIssue.category)
                : null,
            control: .managed(
              initial: vm.categoryId?.uuid,
              onChange: (v) =>
                  vm.setCategory(v == null ? null : UuidValue.fromString(v)),
            ),
          ),
          FTextField(
            key: ValueKey('expense-amount-$gen'),
            label: Text(l10n.expenseAmount),
            hint: '0',
            keyboardType: TextInputType.number,
            inputFormatters: const [RupiahInputFormatter()],
            prefixBuilder: _rpPrefix,
            error: issues.contains(ExpenseIssue.amount)
                ? Text(expenseIssueMessage(l10n, ExpenseIssue.amount))
                : null,
            control: .managed(
              initial: TextEditingValue(
                text: vm.amount.value == 0
                    ? ''
                    : groupThousands(vm.amount.value, '.'),
              ),
              onChange: (v) => vm.setAmount(parseSignedRupiah(v.text)),
            ),
          ),
          FSelect<String>(
            key: ValueKey('expense-funding-$gen'),
            label: Text(l10n.expenseFunding),
            items: {
              for (final f in expenseFundingOrder)
                f == FundingSource.drawer
                        ? (vm.setup.hasOpenSession
                              ? l10n.expenseFundingDrawerActive
                              : l10n.expenseFundingDrawer)
                        : expenseFundingLabel(l10n, f):
                    f.name,
            },
            control: .managed(
              initial: vm.funding.name,
              onChange: (v) {
                if (v != null) vm.setFunding(FundingSource.values.byName(v));
              },
            ),
          ),
          FDateField.calendar(
            key: ValueKey('expense-date-$gen'),
            label: Text(l10n.expenseDate),
            clearable: false,
            format: (context, value, _) => formatCalendarDate(value),
            forceErrorText: vm.dateInFuture ? l10n.expenseErrDate : null,
            selectionControl: .managedSingle(
              initial: vm.spentOn,
              toggleable: false,
              onChange: (d) {
                if (d != null) vm.setSpentOn(d);
              },
            ),
          ),
          if (drawerIssue != null)
            FAlert(
              key: const ValueKey('expense-drawer-hint'),
              variant: .destructive,
              title: Text(expenseDrawerIssueMessage(l10n, drawerIssue)),
            ),
          PhotoAttachField(
            keyPrefix: 'expense-receipt',
            pickLabel: l10n.expenseReceiptPick,
            cameraLabel: l10n.expenseReceiptCamera,
            bytes: vm.receipt?.bytes,
            fileName: vm.receipt?.fileName,
            busy: vm.pickReceipt.running,
            canTakePhoto: vm.canTakePhoto,
            onPick: vm.pickReceipt.execute,
            onRemove: vm.removeReceipt,
            error: vm.receiptRejected ? l10n.expenseReceiptInvalid : null,
          ),
          if (saveError != null)
            Text(
              saveError,
              key: const ValueKey('expense-save-error'),
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.destructive,
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              if (onCancel != null)
                FButton(
                  key: const ValueKey('expense-cancel'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: onCancel,
                  child: Text(l10n.expenseCancel),
                ),
              FButton(
                key: const ValueKey('expense-save'),
                mainAxisSize: onCancel == null ? .max : .min,
                onPress: vm.save.running ? null : _save,
                prefix: vm.save.running
                    ? const SizedBox.square(
                        dimension: 16,
                        child: FCircularProgress(),
                      )
                    : const Icon(TablerIcons.check),
                child: Flexible(
                  child: Text(
                    l10n.expenseSave,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
