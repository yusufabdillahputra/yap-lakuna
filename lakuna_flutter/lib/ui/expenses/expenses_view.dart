import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/expenses_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/confirm_discard.dart';
import '../core/format.dart';
import '../core/leave_guard.dart';
import '../products/product_widgets.dart';
import '../purchases/purchase_labels.dart' show formatCalendarDayMonth;
import 'expense_detail_dialog.dart';
import 'expense_form.dart';
import 'expense_form_view_model.dart';
import 'expense_labels.dart';
import 'expenses_view_model.dart';

/// Lebar minimum untuk daftar + form berdampingan (1.22).
const expensesTwoPaneWidth = 1000.0;

/// Di bawah lebar ini daftar tampil sebagai kartu, bukan tabel.
const _cardListWidth = 600.0;

const _tabular = [FontFeature.tabularFigures()];

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

/// Layar *Pengeluaran* (1.22, F1-15).
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({
    super.key,
    required this.repository,
    this.imagePicker = const FileSelectorImagePicker(),
    this.exporter = const PlatformSpreadsheetExporter(),
    this.leaveGuard,
  });

  final ExpensesRepository repository;

  /// Penjaga keluar rute: form yang berisi ditanyakan (F1-15c).
  final LeaveGuard? leaveGuard;
  final ImageFilePicker imagePicker;
  final SpreadsheetExporter exporter;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late final _list = ExpensesViewModel(
    repository: widget.repository,
    exporter: widget.exporter,
  );
  ExpenseFormViewModel? _form;

  @override
  void initState() {
    super.initState();
    _list
      ..addListener(_syncForm)
      ..load.execute();
    widget.leaveGuard?.check = _confirmLeave;
  }

  @override
  void didUpdateWidget(ExpensesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.leaveGuard != widget.leaveGuard) {
      if (oldWidget.leaveGuard?.check == _confirmLeave) {
        oldWidget.leaveGuard?.check = null;
      }
      widget.leaveGuard?.check = _confirmLeave;
    }
  }

  /// Form tetap hidup saat dialog ditutup (layar sempit), jadi isiannya
  /// ditanyakan di kedua tata letak (F1-15c).
  Future<bool> _confirmLeave() async {
    final form = _form;
    if (!mounted || isRouteClosing(context) || form == null) return true;
    if (form.busy) return false;
    if (!form.hasUnsavedChanges) return true;
    return confirmDiscardChanges(
      context,
      body: AppLocalizations.of(context).expenseDiscardBody,
      key: 'expense-discard',
      onSave: () => _saveBeforeLeaving(form),
    );
  }

  /// Simpan dari dialog *Buang perubahan?* (F1-15d); `true` bila tercatat
  /// sehingga navigasi yang tertahan diteruskan.
  Future<bool> _saveBeforeLeaving(ExpenseFormViewModel form) async {
    final guard = widget.leaveGuard?..saving = true;
    try {
      await form.save.execute();
    } finally {
      guard?.saving = false;
    }
    switch (form.save.result) {
      case Ok():
        // Layar bisa tetap tampil (mis. tombol kembali Android di halaman
        // tunggal): muat ulang daftar dan saldo laci seperti `onSaved`,
        // tetapi hanya bila halaman tidak sedang ditutup.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !isRouteClosing(context)) unawaited(_list.refresh());
        });
        return true;
      case Error(:final error):
        if (!mounted) return false;
        // Sama dengan tombol Simpan form (`onFailed`): muat ulang setup.
        if (error is! ExpenseInvalid) unawaited(_list.refresh());
        // Layar sempit dengan dialog form tertutup: buka lagi agar pesan
        // isian atau galat simpannya terlihat.
        if (!_twoPane && !_dialogOpen) unawaited(_newDialog());
      case null:
    }
    return false;
  }

  /// Tata letak terakhir yang dibangun: form di samping daftar.
  var _twoPane = false;

  /// Dialog form (layar sempit) sedang terbuka.
  var _dialogOpen = false;

  /// Form dibuat setelah setup (jenis, hari ini) dimuat.
  void _syncForm() {
    final setup = _list.setup;
    if (setup == null) return;
    final form = _form;
    if (form == null) {
      setState(() {
        _form = ExpenseFormViewModel(
          repository: widget.repository,
          setup: setup,
          picker: widget.imagePicker,
        );
      });
    } else if (!identical(form.setup, setup)) {
      form.updateSetup(setup);
    }
  }

  @override
  void dispose() {
    if (widget.leaveGuard?.check == _confirmLeave) {
      widget.leaveGuard?.check = null;
    }
    _list
      ..removeListener(_syncForm)
      ..dispose();
    _form?.dispose();
    super.dispose();
  }

  Future<void> _saved(Expense _) => _list.refresh();

  Future<void> _newDialog() async {
    final form = _form;
    if (form == null) return;
    _dialogOpen = true;
    try {
      await _showFormDialog(form);
    } finally {
      _dialogOpen = false;
    }
  }

  Future<void> _showFormDialog(ExpenseFormViewModel form) async {
    await showFDialog<void>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 520),
        builder: (context, style) => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: SingleChildScrollView(
            key: const ValueKey('expense-form-dialog'),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  AppLocalizations.of(context).expenseFormTitle,
                  style: context.theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ExpenseForm(
                  viewModel: form,
                  onCancel: () => Navigator.of(context).pop(),
                  onFailed: _list.refresh,
                  onSaved: (e) async {
                    Navigator.of(context).pop();
                    await _saved(e);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openDetail(UuidValue id) async {
    await showExpenseDetail(
      context,
      widget.repository,
      id,
      canUseDrawer: _list.setup?.canUseDrawer ?? false,
    );
    if (mounted) await _list.refresh();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final twoPane = _twoPane = constraints.maxWidth >= expensesTwoPaneWidth;
      return ListenableBuilder(
        listenable: _list,
        builder: (context, _) {
          final l10n = AppLocalizations.of(context);
          final vm = _list;
          final rows = vm.rows;
          final form = _form;
          final exportButton = FButton(
            key: const ValueKey('expenses-export'),
            variant: .outline,
            mainAxisSize: .min,
            onPress: rows == null || rows.isEmpty || vm.export.running
                ? null
                : () => vm.export.execute(expenseWorkbook(l10n, rows)),
            prefix: vm.export.running
                ? const SizedBox.square(
                    dimension: 16,
                    child: FCircularProgress(),
                  )
                : const Icon(TablerIcons.fileSpreadsheet),
            child: Flexible(child: Text(l10n.expensesExport)),
          );
          final list = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              _Filters(viewModel: vm),
              if (vm.error != null)
                LoadFailedAlert(
                  key: const ValueKey('expenses-error'),
                  message: expenseErrorMessage(l10n, vm.error!),
                  onRetry: vm.load.execute,
                )
              else if (rows == null)
                const Center(child: FCircularProgress())
              else if (rows.isEmpty)
                FCard(
                  key: const ValueKey('expenses-empty'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      vm.query.trim().isEmpty
                          ? l10n.expensesEmpty
                          : l10n.expensesNoMatch,
                      textAlign: TextAlign.center,
                      style: _muted(context),
                    ),
                  ),
                )
              else
                _ExpenseList(rows: rows, onOpen: _openDetail),
              if (vm.allRows != null) _ByCategory(viewModel: vm),
            ],
          );
          return SingleChildScrollView(
            key: const ValueKey('expenses-scroll'),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                PageHeader(
                  title: l10n.expensesTitle,
                  subtitle: l10n.expensesSubtitle,
                  action: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (!twoPane && form != null)
                        FButton(
                          key: const ValueKey('expenses-new'),
                          mainAxisSize: .min,
                          onPress: _newDialog,
                          prefix: const Icon(TablerIcons.plus),
                          child: Flexible(child: Text(l10n.expensesNew)),
                        ),
                      exportButton,
                    ],
                  ),
                ),
                if (vm.export.completed && vm.exportPath != null)
                  FAlert(
                    key: const ValueKey('expenses-export-saved'),
                    title: Text(l10n.historyExportSaved(vm.exportPath!)),
                  )
                else if (vm.export.error)
                  FAlert(
                    key: const ValueKey('expenses-export-error'),
                    variant: .destructive,
                    title: Text(l10n.historyExportFailed),
                  ),
                if (twoPane && vm.error == null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      Expanded(flex: 63, child: list),
                      Expanded(
                        flex: 37,
                        child: SectionCard(
                          key: const ValueKey('expenses-form-card'),
                          title: l10n.expenseFormTitle,
                          child: form == null
                              ? const Center(child: FCircularProgress())
                              : ExpenseForm(
                                  viewModel: form,
                                  onSaved: _saved,
                                  onFailed: _list.refresh,
                                ),
                        ),
                      ),
                    ],
                  )
                else
                  list,
              ],
            ),
          );
        },
      );
    },
  );
}

class _Filters extends StatelessWidget {
  const _Filters({required this.viewModel});

  final ExpensesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final search = FTextField(
      key: const ValueKey('expenses-search'),
      hint: l10n.expensesSearch,
      prefixBuilder: (context, style, variants) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 12),
        child: Icon(
          TablerIcons.search,
          size: 16,
          color: context.theme.colors.mutedForeground,
        ),
      ),
      control: .managed(onChange: (v) => vm.setQuery(v.text)),
    );
    final period = FSelect<String>(
      key: const ValueKey('expenses-period'),
      items: {
        for (final p in ExpensePeriod.values)
          expensePeriodLabel(l10n, p): p.name,
      },
      control: .managed(
        initial: vm.period.name,
        onChange: (v) {
          if (v != null) {
            unawaited(vm.setPeriod(ExpensePeriod.values.byName(v)));
          }
        },
      ),
    );
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth < 520
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [search, period],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Expanded(child: search),
                SizedBox(width: 220, child: period),
              ],
            ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList({required this.rows, required this.onOpen});

  final List<ExpenseRow> rows;
  final Future<void> Function(UuidValue id) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return LayoutBuilder(
      builder: (context, c) {
        final cards = c.maxWidth < _cardListWidth;
        final head = theme.typography.body.xs.copyWith(
          color: theme.colors.mutedForeground,
          fontWeight: FontWeight.w600,
        );
        Widget badge(ExpenseRow r) => r.voided
            ? FBadge(variant: .destructive, child: Text(l10n.expenseVoided))
            : FBadge(
                variant: r.hasReceipt ? .primary : .outline,
                child: Text(
                  r.hasReceipt ? l10n.expenseHasReceipt : l10n.expenseNoReceipt,
                ),
              );
        Widget amount(ExpenseRow r) => FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            formatMoney(context, Money(r.expense.amount)),
            maxLines: 1,
            style: theme.typography.body.sm.copyWith(
              fontFeatures: _tabular,
              fontWeight: FontWeight.w600,
              decoration: r.voided ? TextDecoration.lineThrough : null,
              color: r.voided ? theme.colors.mutedForeground : null,
            ),
          ),
        );
        final children = <Widget>[
          if (!cards)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                spacing: 12,
                children: [
                  SizedBox(
                    width: 48,
                    child: Text(l10n.expenseColDate, style: head),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(l10n.expenseColDescription, style: head),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(l10n.expenseColCategory, style: head),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(l10n.expenseColFunding, style: head),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      l10n.expenseColAmount,
                      textAlign: TextAlign.right,
                      style: head,
                    ),
                  ),
                  SizedBox(
                    width: 92,
                    child: Text(l10n.expenseColReceipt, style: head),
                  ),
                ],
              ),
            ),
          for (final r in rows)
            FTappable(
              key: ValueKey('expenses-row-${r.expense.id.uuid}'),
              onPress: () => onOpen(r.expense.id),
              child: DecoratedBox(
                // Tanpa kepala tabel, baris pertama tidak perlu garis atas.
                decoration: BoxDecoration(
                  border: cards && identical(r, rows.first)
                      ? null
                      : Border(top: BorderSide(color: theme.colors.border)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: cards
                      ? Row(
                          spacing: 12,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 2,
                                children: [
                                  Text(
                                    r.expense.description,
                                    style: theme.typography.body.sm.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    [
                                      formatCalendarDayMonth(r.expense.spentOn),
                                      r.categoryName,
                                      expenseFundingText(l10n, r),
                                    ].join(' · '),
                                    style: _muted(context),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 4,
                              children: [amount(r), badge(r)],
                            ),
                          ],
                        )
                      : Row(
                          spacing: 12,
                          children: [
                            SizedBox(
                              width: 48,
                              child: Text(
                                formatCalendarDayMonth(r.expense.spentOn),
                                style: theme.typography.body.sm,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                r.expense.description,
                                style: theme.typography.body.sm.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                r.categoryName,
                                style: theme.typography.body.sm,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                expenseFundingText(l10n, r),
                                style: theme.typography.body.sm,
                              ),
                            ),
                            Expanded(flex: 2, child: amount(r)),
                            SizedBox(
                              width: 92,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: badge(r),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
        ];
        return FCard(
          key: const ValueKey('expenses-table'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        );
      },
    );
  }
}

class _ByCategory extends StatelessWidget {
  const _ByCategory({required this.viewModel});

  final ExpensesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final (total, by) = viewModel.summary;
    final max = by.isEmpty ? 0 : by.first.total.value;
    return SectionCard(
      key: const ValueKey('expenses-by-category'),
      title: l10n.expensesByCategory(
        expensePeriodLabel(l10n, viewModel.period),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            l10n.expensesTotal(formatMoney(context, total)),
            key: const ValueKey('expenses-total'),
            style: _muted(context),
          ),
          if (by.isEmpty)
            Text(l10n.expensesByCategoryEmpty, style: _muted(context)),
          for (final c in by)
            Column(
              key: ValueKey('expenses-category-${c.name}'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Text(c.name, style: theme.typography.body.sm),
                    ),
                    Text(
                      formatMoney(context, c.total),
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: _tabular,
                      ),
                    ),
                  ],
                ),
                ClipRRect(
                  key: ValueKey('expenses-bar-${c.name}'),
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 6,
                    child: ColoredBox(
                      color: theme.colors.muted,
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          widthFactor: _share(c.total.value, max) / 1000,
                          heightFactor: 1,
                          child: ColoredBox(color: theme.colors.primary),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Bagian batang per mil (1..1000) agar `flex` tetap kecil.
int _share(int value, int max) =>
    max <= 0 ? 1000 : (value * 1000 ~/ max).clamp(1, 1000);
