import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/expenses_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/format.dart';
import '../products/product_widgets.dart';
import '../purchases/purchase_labels.dart' show formatCalendarDate;
import 'expense_detail_view_model.dart';
import 'expense_labels.dart';

/// Dialog *Rincian pengeluaran*. Hasil `true` bila pengeluaran dibatalkan.
Future<bool> showExpenseDetail(
  BuildContext context,
  ExpensesRepository repository,
  UuidValue expenseId,
) async =>
    await showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 520),
        builder: (context, style) =>
            ExpenseDetailDialog(repository: repository, expenseId: expenseId),
      ),
    ) ??
    false;

class ExpenseDetailDialog extends StatefulWidget {
  const ExpenseDetailDialog({
    super.key,
    required this.repository,
    required this.expenseId,
  });

  final ExpensesRepository repository;
  final UuidValue expenseId;

  @override
  State<ExpenseDetailDialog> createState() => _ExpenseDetailDialogState();
}

class _ExpenseDetailDialogState extends State<ExpenseDetailDialog> {
  late final _vm = ExpenseDetailViewModel(
    repository: widget.repository,
    expenseId: widget.expenseId,
  )..load.execute();
  var _cancelled = false;

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _cancel() async {
    await _vm.cancel.execute();
    if (_vm.cancel.result is Ok) _cancelled = true;
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final muted = theme.typography.body.sm.copyWith(
        color: theme.colors.mutedForeground,
      );
      final row = _vm.row;
      final error = _vm.error;
      Widget field(String label, String value, {Key? key}) => Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: muted),
          Text(
            value,
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
      final cancelError = switch (_vm.cancel.result) {
        Error(:final error) => expenseErrorMessage(l10n, error),
        _ => null,
      };
      final receipt = _vm.receipt;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  key: const ValueKey('expense-detail'),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    Text(
                      l10n.expenseDetailTitle,
                      style: theme.typography.display.lg.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (error != null && row == null)
                      LoadFailedAlert(
                        message: expenseErrorMessage(l10n, error),
                        onRetry: _vm.load.execute,
                      )
                    else if (row == null)
                      const Center(child: FCircularProgress())
                    else ...[
                      Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: Text(
                              row.expense.description,
                              style: theme.typography.body.md.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (row.voided)
                            FBadge(
                              key: const ValueKey('expense-detail-voided'),
                              variant: .destructive,
                              child: Text(l10n.expenseVoided),
                            ),
                        ],
                      ),
                      Text(
                        formatMoney(context, Money(row.expense.amount)),
                        key: const ValueKey('expense-detail-amount'),
                        style: theme.typography.display.md.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Wrap(
                        spacing: 24,
                        runSpacing: 12,
                        children: [
                          field(l10n.expenseColNumber, row.expense.number),
                          field(
                            l10n.expenseColDate,
                            formatCalendarDate(row.expense.spentOn),
                          ),
                          field(l10n.expenseColCategory, row.categoryName),
                          field(
                            l10n.expenseColFunding,
                            expenseFundingText(l10n, row),
                          ),
                          field(l10n.expenseRecordedBy, row.staffName),
                        ],
                      ),
                      if (row.voided)
                        FAlert(
                          key: const ValueKey('expense-detail-void-info'),
                          variant: .destructive,
                          title: Text(
                            l10n.expenseVoidInfo(
                              row.voidedByName ?? '',
                              row.expense.voidReason ?? '',
                            ),
                          ),
                        ),
                      if (receipt != null)
                        ClipRRect(
                          key: const ValueKey('expense-detail-receipt'),
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            receipt,
                            fit: BoxFit.contain,
                            height: 280,
                          ),
                        )
                      else
                        Text(
                          row.hasReceipt
                              ? l10n.expenseReceiptMissing
                              : l10n.expenseNoReceipt,
                          style: muted,
                        ),
                      if (_vm.confirming) ...[
                        FTextField(
                          key: const ValueKey('expense-void-reason'),
                          label: Text(l10n.expenseVoidReason),
                          hint: l10n.expenseVoidReasonHint,
                          maxLength: ExpenseLimits.voidReason,
                          autofocus: true,
                          error: _vm.reasonInvalid
                              ? Text(
                                  l10n.expenseErrReason(
                                    ExpenseLimits.voidReason,
                                  ),
                                )
                              : null,
                          control: .managed(
                            onChange: (v) => _vm.setReason(v.text),
                          ),
                        ),
                        if (row.expense.fundingSource == FundingSource.drawer)
                          Text(l10n.expenseVoidDrawerHint, style: muted),
                      ],
                      if (cancelError != null && !_vm.reasonInvalid)
                        Text(
                          cancelError,
                          key: const ValueKey('expense-void-error'),
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.destructive,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  if (_vm.confirming) ...[
                    FButton(
                      key: const ValueKey('expense-void-back'),
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: _vm.stopCancel,
                      child: Text(l10n.expenseCancel),
                    ),
                    FButton(
                      key: const ValueKey('expense-void-confirm'),
                      variant: .destructive,
                      mainAxisSize: .min,
                      onPress: _vm.cancel.running ? null : _cancel,
                      child: Flexible(child: Text(l10n.expenseVoidConfirm)),
                    ),
                  ] else ...[
                    if (_vm.canCancel)
                      FButton(
                        key: const ValueKey('expense-void'),
                        variant: .outline,
                        mainAxisSize: .min,
                        onPress: _vm.startCancel,
                        prefix: Icon(
                          TablerIcons.ban,
                          color: theme.colors.destructive,
                        ),
                        child: Flexible(child: Text(l10n.expenseVoid)),
                      ),
                    FButton(
                      key: const ValueKey('expense-detail-close'),
                      mainAxisSize: .min,
                      onPress: () => Navigator.of(context).pop(_cancelled),
                      child: Text(l10n.expenseClose),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
