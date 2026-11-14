import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/reports_repository.dart';
import '../../data/services/report_document.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../routing/routes.dart';
import '../core/format.dart';
import '../customers/customer_labels.dart' show formatLongDate;
import '../history/history_labels.dart' show returnReasonLabel;
import '../products/product_widgets.dart';
import '../purchases/purchase_labels.dart' show formatCalendarDate;
import '../receipt/receipt_content.dart' show receiptDate;
import 'report_labels.dart';
import 'report_range_dialog.dart';
import 'reports_view_model.dart';

part 'reports_extra_view.dart';

const _tabular = [FontFeature.tabularFigures()];

/// Lebar minimum untuk laba rugi + panel samping berdampingan (1.24).
const reportsSidePanelWidth = 960.0;

/// Di bawah lebar ini tabel tampil sebagai kartu.
const _cardListWidth = 600.0;

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

TextStyle _amountStyle(BuildContext context, {bool strong = false}) =>
    context.theme.typography.body.sm.copyWith(
      fontFeatures: _tabular,
      fontWeight: strong ? FontWeight.w600 : FontWeight.w500,
    );

bool _dark(BuildContext context) =>
    context.theme.colors.brightness == Brightness.dark;

/// Latar dan teks sorotan biru langit (kartu Laba bersih).
(Color, Color) _sky(BuildContext context) => _dark(context)
    ? (const Color(0xFF052F4A), const Color(0xFF74D4FF))
    : (const Color(0xFFDFF2FE), const Color(0xFF00598A));

Color _positive(BuildContext context) =>
    _dark(context) ? const Color(0xFF7BF1A8) : const Color(0xFF016630);

String _periodKey(ReportPeriod p) => switch (p.kind) {
  ReportPeriodKind.month => 'm-${p.year}-${p.monthOfYear}',
  ReportPeriodKind.custom => 'c-${p.fileKey(DateTime(0))}',
  _ => p.kind.name,
};

/// Entri *Rentang tanggal…* di pilihan Periode (F1-16b).
const _pickRangeKey = 'pick-range';

/// Layar *Laporan* (1.23 ringkasan, 1.24 laba rugi; F1-16).
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({
    super.key,
    required this.repository,
    this.permissions = const {},
    this.exporter = const PlatformSpreadsheetExporter(),
  });

  final ReportsRepository repository;

  /// Izin staf, untuk menyaring tautan *Laporan lengkap* ke layar lain.
  final Set<Permission> permissions;
  final SpreadsheetExporter exporter;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late final _vm = ReportsViewModel(
    repository: widget.repository,
    exporter: widget.exporter,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_vm.load.execute());
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  /// Naik setiap dialog rentang ditutup agar pilihan Periode kembali ke
  /// periode aktif (Batal) atau menampilkan rentang baru (F1-16b).
  var _periodGeneration = 0;

  Future<void> _pickRange() async {
    final picked = await showReportRangeDialog(
      context,
      initial: _vm.period.range(_vm.today),
      today: _vm.today,
    );
    if (!mounted) return;
    setState(() => _periodGeneration++);
    if (picked != null) await _vm.setPeriod(picked);
  }

  /// Selama berkas dibuat (font PDF dimuat sebelum ekspor berjalan), tombol
  /// unduh mati agar ketukan ganda tidak menyimpan dua berkas.
  var _preparing = false;

  Future<void> _download(ReportFormat format) async {
    final data = _vm.data;
    if (data == null || !_vm.ready || _preparing) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _preparing = true);
    try {
      final table = reportTable(
        l10n,
        data,
        _vm.tab,
        _vm.group,
        stock: _vm.stock,
        cash: _vm.cash,
        debts: _vm.debts,
        returns: _vm.returns,
      );
      final bytes = switch (format) {
        ReportFormat.xlsx => reportXlsx(table),
        ReportFormat.pdf => await reportPdf(
          table,
          money: (v) => moneyLabel(l10n, Money(v)),
        ),
      };
      await _vm.export.execute((bytes, format));
    } finally {
      if (mounted) setState(() => _preparing = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final vm = _vm;
      final data = vm.data;
      final busy = _preparing || vm.export.running;
      Widget download(ReportFormat f) => FButton(
        key: ValueKey('reports-download-${f.name}'),
        variant: .outline,
        mainAxisSize: .min,
        onPress: !vm.ready || busy ? null : () => _download(f),
        prefix: Icon(
          f == ReportFormat.pdf
              ? TablerIcons.fileTypePdf
              : TablerIcons.fileSpreadsheet,
        ),
        child: Flexible(
          child: Text(
            f == ReportFormat.pdf
                ? l10n.reportsDownloadPdf
                : l10n.reportsDownloadExcel,
          ),
        ),
      );
      final periods = vm.periods;
      final period = SizedBox(
        width: 220,
        child: KeyedSubtree(
          key: ValueKey(
            'reports-period-${_periodKey(vm.period)}-$_periodGeneration',
          ),
          child: FSelect<String>(
            key: const ValueKey('reports-period'),
            items: {
              for (final p in periods)
                reportPeriodLabel(l10n, p): _periodKey(p),
              l10n.reportsPeriodCustom: _pickRangeKey,
            },
            control: .managed(
              initial: _periodKey(vm.period),
              onChange: (key) {
                if (key == _pickRangeKey) {
                  unawaited(_pickRange());
                  return;
                }
                final p = periods
                    .where((p) => _periodKey(p) == key)
                    .firstOrNull;
                if (p != null) unawaited(vm.setPeriod(p));
              },
            ),
          ),
        ),
      );
      return SingleChildScrollView(
        key: const ValueKey('reports-scroll'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            PageHeader(
              title: l10n.reportsTitle,
              subtitle: data == null
                  ? reportPeriodLabel(l10n, vm.period)
                  : l10n.reportsSubtitle(
                      reportPeriodLabel(l10n, vm.period),
                      data.outletName,
                    ),
              action: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  period,
                  download(ReportFormat.pdf),
                  download(ReportFormat.xlsx),
                ],
              ),
            ),
            if (vm.export.completed && vm.exportPath != null)
              FAlert(
                key: const ValueKey('reports-export-saved'),
                title: Text(l10n.historyExportSaved(vm.exportPath!)),
              )
            else if (vm.export.error)
              FAlert(
                key: const ValueKey('reports-export-error'),
                variant: .destructive,
                title: Text(l10n.historyExportFailed),
              ),
            if (vm.error case final error?)
              LoadFailedAlert(
                key: const ValueKey('reports-error'),
                message: reportErrorMessage(l10n, error),
                onRetry: vm.load.execute,
              )
            else if (data == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: FCircularProgress()),
              )
            else ...[
              _Tabs(viewModel: vm),
              switch (vm.tab) {
                ReportTab.summary => _Summary(
                  data: data,
                  permissions: widget.permissions,
                  onTab: (tab, [group]) {
                    if (group != null) vm.setGroup(group);
                    vm.setTab(tab);
                  },
                ),
                ReportTab.sales => _Sales(viewModel: vm, data: data),
                ReportTab.top => _Top(data: data),
                ReportTab.profit => _Profit(data: data),
                ReportTab.stock => _Stock(viewModel: vm),
                ReportTab.cash => _Cash(viewModel: vm),
                ReportTab.debts => _Debts(viewModel: vm),
                ReportTab.returns => _Returns(viewModel: vm),
              },
            ],
          ],
        ),
      );
    },
  );
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.viewModel});

  final ReportsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = viewModel.tabs;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FTabs(
        key: ValueKey('reports-tabs-${tabs.length}'),
        scrollable: true,
        control: .lifted(
          index: tabs.indexOf(viewModel.tab),
          onChange: (i) => viewModel.setTab(tabs[i]),
        ),
        children: [
          for (final tab in tabs)
            FTabEntry(
              label: Text(
                reportTabLabel(l10n, tab),
                key: ValueKey('reports-tab-${tab.name}'),
              ),
              child: const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}

// --- Ringkasan (1.23) ---------------------------------------------------------

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.id,
    required this.label,
    required this.value,
    required this.note,
  });

  final String id;
  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FCard(
      key: ValueKey('reports-kpi-$id'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            Text(label, style: _muted(context)),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                maxLines: 1,
                style: theme.typography.display.xl2.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: _tabular,
                ),
              ),
            ),
            Text(note, style: _muted(context)),
          ],
        ),
      ),
    );
  }
}

/// Susunan kotak bersebelahan: [columns] per baris, sisanya turun.
class _Grid extends StatelessWidget {
  const _Grid({
    required this.columns,
    required this.children,
    this.equalHeight = false,
  });

  final int columns;
  final List<Widget> children;

  /// Tinggi kotak sebaris disamakan (tanpa `LayoutBuilder` di dalamnya).
  final bool equalHeight;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final slice = children.skip(i).take(columns).toList();
      final row = Row(
        crossAxisAlignment: equalHeight
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.start,
        spacing: 16,
        children: [
          for (final c in slice) Expanded(child: c),
          for (var k = slice.length; k < columns; k++)
            const Expanded(child: SizedBox.shrink()),
        ],
      );
      rows.add(equalHeight ? IntrinsicHeight(child: row) : row);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: rows,
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.data,
    required this.permissions,
    required this.onTab,
  });

  final ReportData data;
  final Set<Permission> permissions;
  final void Function(ReportTab tab, [SalesGroup? group]) onTab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pl = data.profit;
    final kpis = [
      _Kpi(
        id: 'sales',
        label: l10n.reportsKpiSales,
        value: formatMoney(context, data.netSales),
        note: l10n.reportsKpiSalesNote(data.saleCount),
      ),
      if (pl != null)
        _Kpi(
          id: 'gross-profit',
          label: l10n.reportsKpiGrossProfit,
          value: formatMoney(context, pl.grossProfit),
          note: l10n.reportsKpiGrossProfitNote,
        ),
      _Kpi(
        id: 'average',
        label: l10n.reportsKpiAverage,
        value: formatMoney(context, data.averagePerSale),
        note: l10n.reportsKpiAverageNote,
      ),
      _Kpi(
        id: 'overdue',
        label: l10n.reportsKpiOverdue,
        value: formatMoney(context, data.overdue),
        note: l10n.reportsKpiOverdueNote(data.overdueCustomers),
      ),
    ];
    final links = <(String, String, VoidCallback)>[
      (
        'sales-product',
        l10n.reportsLinkSalesProduct,
        () => onTab(ReportTab.sales, SalesGroup.product),
      ),
      (
        'sales-staff',
        l10n.reportsLinkSalesStaff,
        () => onTab(ReportTab.sales, SalesGroup.staff),
      ),
      (
        'sales-category',
        l10n.reportsLinkSalesCategory,
        () => onTab(ReportTab.sales, SalesGroup.category),
      ),
      if (pl != null)
        ('profit', l10n.reportsLinkProfit, () => onTab(ReportTab.profit)),
      for (final (id, label, path, permission, alt) in [
        (
          'stock',
          l10n.reportsLinkStock,
          Routes.stock,
          Permission.stockAdjust,
          null,
        ),
        (
          'debts',
          l10n.reportsLinkDebts,
          Routes.customers,
          Permission.customersManage,
          Permission.debtsManage,
        ),
        (
          'returns',
          l10n.reportsLinkReturns,
          Routes.history,
          Permission.salesCreate,
          Permission.reportsView,
        ),
        (
          'expenses',
          l10n.reportsLinkExpenses,
          Routes.expenses,
          Permission.expensesManage,
          null,
        ),
        (
          'sessions',
          l10n.reportsLinkSessions,
          Routes.cashSession,
          Permission.cashSessionOpen,
          null,
        ),
      ])
        if (permissions.contains(permission) ||
            (alt != null && permissions.contains(alt)))
          (id, label, () => context.go(path)),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth >= 900
            ? kpis.length
            : c.maxWidth >= 560
            ? 2
            : 1;
        final methods = _Methods(data: data);
        final top = _TopCard(data: data);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            _Grid(columns: columns, equalHeight: true, children: kpis),
            if (c.maxWidth >= 900)
              _Grid(columns: 2, children: [methods, top])
            else ...[
              methods,
              top,
            ],
            SectionCard(
              key: const ValueKey('reports-links'),
              title: l10n.reportsFull,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (id, label, onPress) in links)
                    FButton(
                      key: ValueKey('reports-link-$id'),
                      variant: .outline,
                      size: .sm,
                      mainAxisSize: .min,
                      onPress: onPress,
                      child: Flexible(child: Text(label)),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.permille});

  final int permille;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: ColoredBox(
          color: theme.colors.muted,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: permille.clamp(0, 1000) / 1000,
              heightFactor: 1,
              child: ColoredBox(color: theme.colors.primary),
            ),
          ),
        ),
      ),
    );
  }
}

class _Methods extends StatelessWidget {
  const _Methods({required this.data});

  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final rows = data.payments;
    return SectionCard(
      key: const ValueKey('reports-methods'),
      title: l10n.reportsByMethod,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (rows.isEmpty) Text(l10n.reportsEmpty, style: _muted(context)),
          for (final m in rows)
            Column(
              key: ValueKey('reports-method-${m.method.name}'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Text(
                        reportMethodLabel(l10n, m.method),
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      formatMoney(context, m.amount),
                      style: _amountStyle(context, strong: true),
                    ),
                  ],
                ),
                _Bar(permille: m.shareBp ~/ 10),
                Text(percentLabel(l10n, m.shareBp), style: _muted(context)),
              ],
            ),
          if (rows.isNotEmpty)
            Text(l10n.reportsByMethodNote, style: _muted(context)),
        ],
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  const _TopCard({required this.data});

  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final top = data.top.take(5).toList();
    return SectionCard(
      key: const ValueKey('reports-top-card'),
      title: l10n.reportsTop,
      child: top.isEmpty
          ? Text(l10n.reportsEmpty, style: _muted(context))
          : _RankList(data: data, rows: top),
    );
  }
}

class _RankList extends StatelessWidget {
  const _RankList({required this.data, required this.rows});

  final ReportData data;
  final List<BreakdownRow> rows;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 480;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, t) in rows.indexed)
              DecoratedBox(
                key: ValueKey('reports-top-${t.key}'),
                decoration: BoxDecoration(
                  border: i == 0
                      ? null
                      : Border(top: BorderSide(color: theme.colors.border)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    spacing: 12,
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${i + 1}',
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              t.name,
                              style: theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (narrow)
                              Text(
                                breakdownQty(l10n, data, t),
                                style: _muted(context),
                              ),
                          ],
                        ),
                      ),
                      if (!narrow)
                        Text(
                          breakdownQty(l10n, data, t),
                          style: _muted(context),
                        ),
                      Text(
                        formatMoney(context, t.value),
                        textAlign: TextAlign.right,
                        style: _amountStyle(context, strong: true),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// --- Penjualan ----------------------------------------------------------------

class _Sales extends StatelessWidget {
  const _Sales({required this.viewModel, required this.data});

  final ReportsViewModel viewModel;
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final group = viewModel.group;
    final rows = breakdownRows(data, group);
    final total = Money.sum(rows.map((r) => r.value));
    final head = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
      fontWeight: FontWeight.w600,
    );
    String amountCol(BreakdownRow r) => breakdownCount(l10n, data, group, r);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in SalesGroup.values)
              FButton(
                key: ValueKey('reports-group-${g.name}'),
                variant: g == group ? .primary : .outline,
                size: .sm,
                mainAxisSize: .min,
                onPress: () => viewModel.setGroup(g),
                child: Flexible(child: Text(salesGroupLabel(l10n, g))),
              ),
          ],
        ),
        if (rows.isEmpty)
          FCard(
            key: const ValueKey('reports-sales-empty'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.reportsEmpty,
                textAlign: TextAlign.center,
                style: _muted(context),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, c) {
              final cards = c.maxWidth < _cardListWidth;
              Widget line(
                String name,
                String qty,
                Money value,
                String share, {
                Key? key,
                bool strong = false,
                bool first = false,
              }) {
                final nameStyle = theme.typography.body.sm.copyWith(
                  fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
                );
                return DecoratedBox(
                  key: key,
                  decoration: BoxDecoration(
                    color: strong ? theme.colors.muted : null,
                    border: first
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
                                    Text(name, style: nameStyle),
                                    if (qty.isNotEmpty || share.isNotEmpty)
                                      Text(
                                        [
                                              qty,
                                              share,
                                            ]
                                            .where((s) => s.isNotEmpty)
                                            .join(' · '),
                                        style: _muted(context),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                formatMoney(context, value),
                                style: _amountStyle(context, strong: true),
                              ),
                            ],
                          )
                        : Row(
                            spacing: 12,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(name, style: nameStyle),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  qty,
                                  textAlign: TextAlign.right,
                                  style: theme.typography.body.sm.copyWith(
                                    fontFeatures: _tabular,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  formatMoney(context, value),
                                  textAlign: TextAlign.right,
                                  style: _amountStyle(context, strong: true),
                                ),
                              ),
                              SizedBox(
                                width: 64,
                                child: Text(
                                  share,
                                  textAlign: TextAlign.right,
                                  style: _muted(context),
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              }

              return FCard(
                key: const ValueKey('reports-sales-table'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!cards)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          spacing: 12,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(switch (group) {
                                SalesGroup.product => l10n.reportsColProduct,
                                SalesGroup.staff => l10n.reportsColStaff,
                                SalesGroup.category => l10n.reportsColCategory,
                              }, style: head),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                group == SalesGroup.staff
                                    ? l10n.reportsColReceipts
                                    : l10n.reportsColQty,
                                textAlign: TextAlign.right,
                                style: head,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                group == SalesGroup.staff
                                    ? l10n.reportsColNet
                                    : l10n.reportsColValue,
                                textAlign: TextAlign.right,
                                style: head,
                              ),
                            ),
                            SizedBox(
                              width: 64,
                              child: Text(
                                l10n.reportsColShare,
                                textAlign: TextAlign.right,
                                style: head,
                              ),
                            ),
                          ],
                        ),
                      ),
                    for (final (i, r) in rows.indexed)
                      line(
                        breakdownName(l10n, data, group, r),
                        amountCol(r),
                        r.value,
                        percentLabel(l10n, ratioBp(r.value, total)),
                        key: ValueKey('reports-sales-row-${r.key}'),
                        first: cards && i == 0,
                      ),
                    line(
                      l10n.reportsTotal,
                      group == SalesGroup.staff ? '${data.saleCount}' : '',
                      total,
                      '',
                      key: const ValueKey('reports-sales-total'),
                      strong: true,
                    ),
                  ],
                ),
              );
            },
          ),
        Text(l10n.reportsSalesNote, style: _muted(context)),
      ],
    );
  }
}

// --- Produk terlaris ----------------------------------------------------------

class _Top extends StatelessWidget {
  const _Top({required this.data});

  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionCard(
      key: const ValueKey('reports-top-table'),
      title: l10n.reportsTabTop,
      child: data.top.isEmpty
          ? Text(l10n.reportsEmpty, style: _muted(context))
          : _RankList(data: data, rows: data.top),
    );
  }
}

// --- Laba rugi (1.24) ---------------------------------------------------------

class _Profit extends StatelessWidget {
  const _Profit({required this.data});

  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final pl = data.profit!;
    final period = reportPeriodLabel(l10n, data.period);
    final lines = profitLines(l10n, pl);
    final notes = profitNotes(l10n, pl);
    final (skyBg, skyFg) = _sky(context);

    Widget lineRow(PlLine line) {
      final strong = line.style != PlStyle.item && line.style != PlStyle.detail;
      final total = line.style == PlStyle.total;
      final amount = formatMoney(context, line.amount);
      final text = Text(
        line.negative && line.amount.value != 0 ? '− $amount' : amount,
        textAlign: TextAlign.right,
        style: (total ? theme.typography.display.lg : theme.typography.body.sm)
            .copyWith(
              fontFeatures: _tabular,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              color: total
                  ? (line.negative ? theme.colors.destructive : skyFg)
                  : line.positive
                  ? _positive(context)
                  : null,
            ),
      );
      final label = Text(
        line.label,
        style: (total ? theme.typography.display.lg : theme.typography.body.sm)
            .copyWith(
              fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
              color: total ? skyFg : null,
            ),
      );
      final row = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Expanded(child: label),
          text,
        ],
      );
      return switch (line.style) {
        PlStyle.total => Container(
          key: const ValueKey('reports-pl-net-profit'),
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: skyBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: row,
        ),
        PlStyle.subtotal => DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.muted,
            border: Border(top: BorderSide(color: theme.colors.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: row,
          ),
        ),
        PlStyle.item || PlStyle.detail => DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.colors.border)),
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              line.style == PlStyle.detail ? 24 : 8,
              12,
              8,
              12,
            ),
            child: row,
          ),
        ),
      };
    }

    final statement = FCard(
      key: const ValueKey('reports-pl'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.reportsPlTitle(period),
              style: theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.reportsPlSubtitle(data.outletName),
              style: _muted(context),
            ),
            const SizedBox(height: 12),
            for (final line in lines) lineRow(line),
            if (pl.expenses.isEmpty)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 24, top: 4),
                child: Text(l10n.reportsPlExpensesNone, style: _muted(context)),
              ),
          ],
        ),
      ),
    );

    final previous = data.previousProfit;
    final change = previous == null
        ? null
        : changeBp(pl.netProfit, previous.netProfit);
    final prevLabel = previousPeriodLabel(l10n, data.period, data.today);
    Widget side(
      String id,
      String label,
      String value,
      String? note, {
      bool highlight = false,
    }) => DecoratedBox(
      key: ValueKey('reports-side-$id'),
      decoration: BoxDecoration(
        color: highlight ? skyBg : theme.colors.card,
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              label,
              style: _muted(context).copyWith(
                color: highlight ? skyFg : null,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: theme.typography.display.xl.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: _tabular,
                color: highlight ? skyFg : null,
              ),
            ),
            if (note != null)
              Text(
                note,
                style: _muted(context).copyWith(
                  color: highlight ? skyFg : null,
                ),
              ),
          ],
        ),
      ),
    );
    final panel = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        side(
          'net-profit',
          l10n.reportsPlNetProfit,
          formatMoney(context, pl.netProfit),
          previous == null
              ? null
              : change != null
              ? l10n.reportsVsPrevious(
                  percentLabel(l10n, change, signed: true),
                  prevLabel,
                )
              : l10n.reportsPreviousValue(
                  prevLabel,
                  formatMoney(context, previous.netProfit),
                ),
          highlight: true,
        ),
        side(
          'margin',
          l10n.reportsMargin,
          percentLabel(l10n, pl.grossMarginBp),
          l10n.reportsMarginNote,
        ),
        side(
          'expense-ratio',
          l10n.reportsExpenseRatio,
          percentLabel(l10n, pl.expenseRatioBp),
          null,
        ),
        SectionCard(
          key: const ValueKey('reports-how'),
          title: l10n.reportsHowTitle,
          child: Text(l10n.reportsHowBody, style: _muted(context)),
        ),
      ],
    );
    final alerts = [
      for (final n in notes)
        FAlert(
          key: ValueKey('reports-note-${notes.indexOf(n)}'),
          title: Text(n),
        ),
    ];
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth >= reportsSidePanelWidth
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Expanded(
                  flex: 63,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [statement, ...alerts],
                  ),
                ),
                Expanded(flex: 37, child: panel),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [statement, ...alerts, panel],
            ),
    );
  }
}
