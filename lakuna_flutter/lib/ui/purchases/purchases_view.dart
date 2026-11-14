import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/purchases_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import '../products/product_widgets.dart';
import 'purchase_form_view.dart';
import 'purchase_form_view_model.dart';
import 'purchase_labels.dart';
import 'purchases_view_model.dart';

/// Lebar minimum untuk daftar + form berdampingan (1.19).
const purchasesTwoPaneWidth = 1000.0;

const _tabular = [FontFeature.tabularFigures()];

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

/// Layar *Pembelian* (1.19, F1-12): daftar pembelian dan retur pembelian,
/// dengan form di samping pada layar lebar.
class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({
    super.key,
    required this.repository,
    required this.onOpenPurchase,
    required this.onNewPurchase,
    this.imagePicker = const FileSelectorImagePicker(),
  });

  final PurchasesRepository repository;

  /// Foto faktur di form samping (F1-12b).
  final ImageFilePicker imagePicker;

  /// Membuka halaman `/pembelian/:id` (detail, atau form draf di layar
  /// sempit); selesai saat kembali.
  final Future<void> Function(UuidValue id) onOpenPurchase;

  /// Layar sempit: membuka halaman `/pembelian/baru`; hasilnya pembelian
  /// yang diterima di sana (lalu detailnya dibuka).
  final Future<UuidValue?> Function() onNewPurchase;

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  late final _list = PurchasesViewModel(repository: widget.repository);

  /// Form di samping daftar; dibuat saat layar cukup lebar.
  PurchaseFormViewModel? _formVm;

  PurchaseFormViewModel get _form => _formVm ??= _newForm(null);

  PurchaseFormViewModel _newForm(UuidValue? draftId) => PurchaseFormViewModel(
    repository: widget.repository,
    draftId: draftId,
    picker: widget.imagePicker,
  )..load.execute();

  @override
  void initState() {
    super.initState();
    _list.load.execute();
  }

  @override
  void dispose() {
    _list.dispose();
    _formVm?.dispose();
    super.dispose();
  }

  void _replaceForm(UuidValue? draftId) {
    final old = _formVm;
    setState(() => _formVm = _newForm(draftId));
    old?.dispose();
  }

  Future<void> _open(PurchaseRow row, bool twoPane) async {
    if (row.isDraft && twoPane) {
      _replaceForm(row.purchase.id);
      return;
    }
    await widget.onOpenPurchase(row.purchase.id);
    await _list.refresh();
  }

  Future<void> _new(bool twoPane) async {
    if (twoPane) {
      _replaceForm(null);
      return;
    }
    final received = await widget.onNewPurchase();
    await _list.refresh();
    if (received != null) {
      await widget.onOpenPurchase(received);
      await _list.refresh();
    }
  }

  Future<void> _received(Purchase purchase) async {
    _replaceForm(null);
    unawaited(_list.refresh());
    await widget.onOpenPurchase(purchase.id);
    await _list.refresh();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final l10n = AppLocalizations.of(context);
      final twoPane = constraints.maxWidth >= purchasesTwoPaneWidth;
      final list = _PurchaseList(
        viewModel: _list,
        selectedDraft: twoPane ? _formVm?.draftId : null,
        onOpen: (row) => _open(row, twoPane),
      );
      return SingleChildScrollView(
        key: const ValueKey('purchases-scroll'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            PageHeader(
              title: l10n.purchasesTitle,
              subtitle: l10n.purchasesSubtitle,
              action: FButton(
                key: const ValueKey('purchases-new'),
                mainAxisSize: .min,
                onPress: () => _new(twoPane),
                prefix: const Icon(TablerIcons.plus),
                child: Flexible(child: Text(l10n.purchasesNew)),
              ),
            ),
            if (twoPane)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  Expanded(flex: 35, child: list),
                  Expanded(
                    flex: 65,
                    child: PurchaseFormPanel(
                      key: ObjectKey(_form),
                      viewModel: _form,
                      onSaved: (_) => _list.refresh(),
                      onReceived: _received,
                      onDeleted: () {
                        _replaceForm(null);
                        unawaited(_list.refresh());
                      },
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
}

class _PurchaseList extends StatelessWidget {
  const _PurchaseList({
    required this.viewModel,
    required this.selectedDraft,
    required this.onOpen,
  });

  final PurchasesViewModel viewModel;
  final UuidValue? selectedDraft;
  final void Function(PurchaseRow row) onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => _build(
        context,
        constraints.maxWidth < purchasesListCompactWidth,
      ),
    ),
  );

  Widget _build(BuildContext context, bool compact) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    Widget empty(String key, String text) => FCard(
      key: ValueKey(key),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ),
    );
    final rows = vm.rows;
    final returns = vm.returns;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoicePill(
              key: const ValueKey('purchases-tab-purchases'),
              label: l10n.purchasesTabPurchases,
              selected: vm.tab == PurchaseTab.purchases,
              onTap: () => vm.setTab(PurchaseTab.purchases),
            ),
            ChoicePill(
              key: const ValueKey('purchases-tab-returns'),
              label: l10n.purchasesTabReturns,
              selected: vm.tab == PurchaseTab.returns,
              onTap: () => vm.setTab(PurchaseTab.returns),
            ),
          ],
        ),
        FTextField(
          key: const ValueKey('purchases-search'),
          hint: l10n.purchasesSearch,
          prefixBuilder: (context, style, _) => Padding(
            padding: const EdgeInsetsDirectional.only(start: 12),
            child: Icon(
              TablerIcons.search,
              size: 18,
              color: theme.colors.mutedForeground,
            ),
          ),
          control: .managed(onChange: (v) => vm.setQuery(v.text)),
        ),
        if (vm.error != null)
          LoadFailedAlert(
            key: const ValueKey('purchases-load-error'),
            message: l10n.purchasesLoadFailed,
            onRetry: vm.refresh,
          ),
        if (rows == null || returns == null)
          if (vm.error == null)
            const Center(child: FCircularProgress())
          else
            const SizedBox.shrink()
        else if (vm.tab == PurchaseTab.purchases)
          if (rows.isEmpty)
            empty('purchases-empty', l10n.purchasesEmpty)
          else
            _Table(
              key: const ValueKey('purchases-table'),
              flex: compact ? _compactFlex : _flex,
              columns: [
                l10n.purchasesColNumber,
                if (!compact) l10n.purchasesColSupplier,
                l10n.purchasesColTotal,
                l10n.purchasesColStatus,
              ],
              children: [
                for (final r in rows)
                  _PurchaseRowTile(
                    compact: compact,
                    row: r,
                    selected: r.purchase.id == selectedDraft,
                    onTap: () => onOpen(r),
                  ),
              ],
            )
        else if (returns.isEmpty)
          empty('purchases-returns-empty', l10n.purchasesReturnsEmpty)
        else
          _Table(
            key: const ValueKey('purchases-returns-table'),
            flex: compact ? _compactFlex : _flex,
            columns: [
              l10n.purchasesColNumber,
              if (!compact) l10n.purchasesColSupplier,
              l10n.purchasesColValue,
              l10n.purchasesColSource,
            ],
            children: [
              for (final r in returns)
                _ReturnRowTile(
                  row: r,
                  timezone: vm.timezone,
                  compact: compact,
                ),
            ],
          ),
      ],
    );
  }
}

const _flex = [36, 26, 22, 16];

/// Daftar sempit (panel kiri dua panel): supplier pindah ke baris kedua
/// kolom nomor.
const _compactFlex = [50, 28, 22];

/// Di bawah lebar ini daftar pembelian memakai tiga kolom.
const purchasesListCompactWidth = 460.0;

class _Table extends StatelessWidget {
  const _Table({
    super.key,
    required this.columns,
    required this.children,
    required this.flex,
  });

  final List<String> columns;
  final List<int> flex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final head = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
      fontWeight: FontWeight.w600,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.card,
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.muted,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                spacing: 8,
                children: [
                  for (var i = 0; i < columns.length; i++)
                    Expanded(
                      flex: flex[i],
                      child: Text(
                        columns[i],
                        style: head,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: i == columns.length - 2
                            ? TextAlign.end
                            : TextAlign.start,
                      ),
                    ),
                ],
              ),
            ),
          ),
          for (final c in children)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.colors.border)),
              ),
              child: _CellFlex(flex: flex, child: c),
            ),
        ],
      ),
    );
  }
}

/// Meneruskan rasio kolom tabel ke baris-barisnya.
class _CellFlex extends InheritedWidget {
  const _CellFlex({required this.flex, required super.child});

  final List<int> flex;

  @override
  bool updateShouldNotify(_CellFlex old) => old.flex != flex;
}

class _Cells extends StatelessWidget {
  const _Cells({super.key, required this.cells});

  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    final flex =
        context.dependOnInheritedWidgetOfExactType<_CellFlex>()?.flex ?? _flex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        spacing: 8,
        children: [
          for (var i = 0; i < cells.length; i++)
            Expanded(flex: flex[i], child: cells[i]),
        ],
      ),
    );
  }
}

Widget _numberCell(BuildContext context, String number, String sub) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      number,
      maxLines: 2,
      style: context.theme.typography.body.sm.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    Text(
      sub,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: _muted(context),
    ),
  ],
);

/// Lencana status pembelian: *Draf*, *Lunas*, *Hutang*.
class PurchaseStatusBadge extends StatelessWidget {
  const PurchaseStatusBadge({
    super.key,
    required this.isDraft,
    required this.debt,
  });

  final bool isDraft;
  final Money debt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FBadge(
      variant: isDraft
          ? .outline
          : debt.value > 0
          ? .destructive
          : .secondary,
      child: Text(
        isDraft
            ? l10n.purchasesStatusDraft
            : debt.value > 0
            ? l10n.purchasesStatusDebt
            : l10n.purchasesStatusPaid,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _PurchaseRowTile extends StatelessWidget {
  const _PurchaseRowTile({
    required this.row,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  final PurchaseRow row;
  final bool compact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final p = row.purchase;
    final date = formatCalendarDayMonth(p.purchasedOn);
    final supplier = row.supplierName ?? l10n.purchasesNoSupplier;
    final sub = [
      if (compact) supplier,
      date,
      if (row.isDraft) l10n.purchasesDraftTag,
    ].join(' · ');
    return ColoredBox(
      color: selected
          ? theme.colors.primary.withValues(alpha: 0.08)
          : const Color(0x00000000),
      child: FTappable(
        key: ValueKey('purchases-row-${p.id.uuid}'),
        onPress: onTap,
        child: _Cells(
          cells: [
            _numberCell(context, p.number, sub),
            if (!compact)
              Text(
                supplier,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm,
              ),
            Text(
              formatMoney(context, Money(p.total)),
              textAlign: TextAlign.end,
              style: theme.typography.body.sm.copyWith(fontFeatures: _tabular),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: PurchaseStatusBadge(isDraft: row.isDraft, debt: row.debt),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReturnRowTile extends StatelessWidget {
  const _ReturnRowTile({
    required this.row,
    required this.timezone,
    required this.compact,
  });

  final PurchaseReturnRow row;
  final bool compact;
  final String? timezone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final r = row.purchaseReturn;
    final supplier = row.supplierName ?? l10n.purchasesNoSupplier;
    return _Cells(
      key: ValueKey('purchases-return-${r.id.uuid}'),
      cells: [
        _numberCell(
          context,
          r.number,
          [
            if (compact) supplier,
            formatDayMonth(r.returnedAt, timezone),
            l10n.purchasesReturnTag,
          ].join(' · '),
        ),
        if (!compact)
          Text(
            supplier,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.typography.body.sm,
          ),
        Text(
          '− ${formatMoney(context, Money(r.amount))}',
          textAlign: TextAlign.end,
          style: theme.typography.body.sm.copyWith(fontFeatures: _tabular),
        ),
        Text(
          row.purchaseNumber,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _muted(context),
        ),
      ],
    );
  }
}
