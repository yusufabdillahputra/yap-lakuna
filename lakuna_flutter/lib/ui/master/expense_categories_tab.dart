import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/confirm_discard.dart';
import '../expenses/expense_labels.dart';
import '../products/product_widgets.dart';
import '../expenses/expense_categories_view_model.dart';

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

/// Tab Master data › Jenis pengeluaran (F1-15, izin `expenses:manage`).
class ExpenseCategoriesTab extends StatelessWidget {
  const ExpenseCategoriesTab({super.key, required this.viewModel});

  final ExpenseCategoriesViewModel viewModel;

  Future<void> _edit(BuildContext context, {ExpenseCategoryRow? row}) {
    // Dikosongkan sebelum dialog dibangun (bukan di initState) agar tidak
    // memberi tahu pendengar saat framework sedang membangun.
    viewModel.save.clearResult();
    return showFDialog<void>(
      context: context,
      // Menutupi menu samping; ketukan di luar / Esc bertanya dulu
      // (F1-09b).
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (context, style, animation) => TapOutsideToPop(
        child: FDialog(
          animation: animation,
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
          builder: (context, style) =>
              _CategoryDialog(viewModel: viewModel, row: row),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = viewModel;
      return SectionCard(
        title: l10n.masterTabExpenseCategories,
        trailing: FButton(
          key: const ValueKey('expense-categories-new'),
          size: .sm,
          mainAxisSize: .min,
          onPress: () => _edit(context),
          prefix: const Icon(TablerIcons.plus),
          child: Text(l10n.expenseCategoriesNew),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text(l10n.expenseCategoriesHint, style: _muted(context)),
            if (vm.load.error)
              LoadFailedAlert(
                message: l10n.expenseErrGeneric,
                onRetry: vm.load.execute,
              )
            else if (vm.rows.isEmpty)
              Text(
                l10n.expenseCategoriesEmpty,
                key: const ValueKey('expense-categories-empty'),
                style: _muted(context),
              ),
            for (final r in vm.rows)
              DecoratedBox(
                key: ValueKey('expense-category-${r.category.id.uuid}'),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: theme.colors.border)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 4,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.category.name,
                                  style: theme.typography.body.sm.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  l10n.expenseCategoriesUsage(r.usage),
                                  style: _muted(context),
                                ),
                              ],
                            ),
                          ),
                          FButton.icon(
                            key: ValueKey(
                              'expense-category-edit-${r.category.id.uuid}',
                            ),
                            variant: .ghost,
                            onPress: () => _edit(context, row: r),
                            child: const Icon(TablerIcons.pencil),
                          ),
                          FButton.icon(
                            key: ValueKey(
                              'expense-category-delete-${r.category.id.uuid}',
                            ),
                            variant: .ghost,
                            onPress: vm.delete.running
                                ? null
                                : () => vm.delete.execute(r.category.id),
                            child: Icon(
                              TablerIcons.trash,
                              color: theme.colors.destructive,
                            ),
                          ),
                        ],
                      ),
                      if (vm.deleteFailedId == r.category.id)
                        if (vm.delete.result case Error(:final error))
                          Text(
                            expenseErrorMessage(l10n, error),
                            key: const ValueKey(
                              'expense-category-delete-error',
                            ),
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.destructive,
                            ),
                          ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({required this.viewModel, this.row});

  final ExpenseCategoriesViewModel viewModel;
  final ExpenseCategoryRow? row;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late var _name = widget.row?.category.name ?? '';
  var _submitted = false;

  /// Nama saat dialog dibuka (F1-09b).
  late final _initial = (widget.row?.category.name ?? '').trim();

  /// `true` bila tersimpan (dialog tertutup, F1-09c). Isian yang salah
  /// menjawab `false` langsung: simpan tidak berjalan, jadi hasil `save`
  /// view model bukan milik isian ini.
  Future<bool> _save() async {
    setState(() => _submitted = true);
    if (!validateExpenseCategoryName(_name)) return false;
    await widget.viewModel.save.execute((
      id: widget.row?.category.id,
      name: _name,
    ));
    if (!mounted || widget.viewModel.save.result is! Ok) return false;
    Navigator.of(context).pop();
    return true;
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = widget.viewModel;
      final invalid = _submitted && !validateExpenseCategoryName(_name);
      return DiscardChangesScope(
        dirty: _name.trim() != _initial,
        busy: vm.save.running,
        body: l10n.expenseCategoryDiscardBody,
        dialogKey: 'expense-category-discard',
        onSave: _save,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('expense-category-form'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                widget.row == null
                    ? l10n.expenseCategoriesNewTitle
                    : l10n.expenseCategoriesEditTitle,
                style: theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              FTextField(
                key: const ValueKey('expense-category-name'),
                label: Text(l10n.expenseCategoriesName),
                autofocus: true,
                maxLength: ExpenseLimits.categoryName,
                error: invalid
                    ? Text(
                        l10n.expenseCategoryErrName(ExpenseLimits.categoryName),
                      )
                    : null,
                control: .managed(
                  initial: TextEditingValue(text: _name),
                  onChange: (v) => setState(() => _name = v.text),
                ),
              ),
              if (vm.save.result case Error(:final error))
                Text(
                  expenseErrorMessage(l10n, error),
                  key: const ValueKey('expense-category-error'),
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
                    key: const ValueKey('expense-category-cancel'),
                    variant: .outline,
                    mainAxisSize: .min,
                    // Ikut ditanyakan bila isian berubah (F1-09b).
                    onPress: () => Navigator.of(context).maybePop(),
                    child: Text(l10n.expenseCancel),
                  ),
                  FButton(
                    key: const ValueKey('expense-category-save'),
                    mainAxisSize: .min,
                    onPress: vm.save.running ? null : _save,
                    child: Text(l10n.expenseCategorySave),
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
