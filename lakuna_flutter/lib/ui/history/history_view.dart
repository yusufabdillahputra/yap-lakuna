import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/history_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/services/receipt_printer.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../l10n/gen/app_localizations.dart';
import '../cashier/payment_view.dart' show paymentMethodLabel;
import '../core/format.dart';
import '../products/product_widgets.dart';
import 'history_detail.dart';
import 'history_labels.dart';
import 'history_view_model.dart';

/// Lebar panel rincian di samping daftar.
const _panelWidth = 380.0;

/// Lebar minimum untuk daftar + panel rincian berdampingan.
const historyTwoPaneWidth = 900.0;

/// Layar *Riwayat transaksi, void & retur* (1.14, F1-11). Dengan
/// [initialSale], layar sempit langsung menampilkan halaman rincian.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.repository,
    required this.session,
    required this.printer,
    this.exporter = const PlatformSpreadsheetExporter(),
    this.initialSale,
    this.onOpenSale,
    this.onBack,
  });

  final HistoryRepository repository;
  final SessionRepository session;
  final ReceiptPrinter printer;
  final SpreadsheetExporter exporter;
  final UuidValue? initialSale;

  /// Layar sempit: membuka halaman rincian nota; selesai saat kembali.
  final Future<void> Function(UuidValue saleId)? onOpenSale;

  /// Halaman rincian di layar sempit: kembali ke daftar.
  final VoidCallback? onBack;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final _viewModel = HistoryViewModel(
    repository: widget.repository,
    printer: widget.printer,
    exporter: widget.exporter,
    initialSale: widget.initialSale,
  );

  @override
  void initState() {
    super.initState();
    _viewModel.load.execute();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => HistoryView(
    viewModel: _viewModel,
    session: widget.session,
    onOpenSale: widget.onOpenSale,
    onBack: widget.onBack,
    detailPage: widget.initialSale != null,
  );
}

class HistoryView extends StatelessWidget {
  const HistoryView({
    super.key,
    required this.viewModel,
    required this.session,
    this.onOpenSale,
    this.onBack,
    this.detailPage = false,
  });

  final HistoryViewModel viewModel;
  final SessionRepository session;
  final Future<void> Function(UuidValue saleId)? onOpenSale;
  final VoidCallback? onBack;

  /// Dibuka lewat `/riwayat/:id`.
  final bool detailPage;

  Future<void> _open(UuidValue id, bool twoPane) async {
    final open = onOpenSale;
    if (twoPane || open == null) {
      viewModel.select(id);
      return;
    }
    await open(id);
    await viewModel.refresh();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        final l10n = AppLocalizations.of(context);
        final vm = viewModel;
        if (vm.data == null) {
          if (vm.error != null) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: LoadFailedAlert(
                key: const ValueKey('history-load-error'),
                message: l10n.historyLoadFailed,
                onRetry: vm.load.execute,
              ),
            );
          }
          return const Center(child: FCircularProgress());
        }
        final width = constraints.maxWidth;
        final twoPane = width >= historyTwoPaneWidth;
        if (!twoPane && detailPage) {
          return SingleChildScrollView(
            key: const ValueKey('history-detail-page'),
            padding: const EdgeInsets.all(16),
            child: HistoryDetailPanel(
              viewModel: vm,
              session: session,
              onBack: onBack,
            ),
          );
        }
        final list = SingleChildScrollView(
          key: const ValueKey('history-list-scroll'),
          padding: const EdgeInsets.all(16),
          child: _HistoryList(
            viewModel: vm,
            narrow: (twoPane ? width - _panelWidth : width) < 520,
            onOpen: (id) => _open(id, twoPane),
          ),
        );
        if (!twoPane) return list;
        final theme = context.theme;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: list),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: theme.colors.border)),
              ),
              child: SizedBox(
                width: _panelWidth,
                child: vm.selectedId == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.historyPickSale,
                            key: const ValueKey('history-pick'),
                            textAlign: TextAlign.center,
                            style: _muted(context),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        key: const ValueKey('history-detail-scroll'),
                        padding: const EdgeInsets.all(16),
                        child: HistoryDetailPanel(
                          viewModel: vm,
                          session: session,
                          onBack: () => vm.select(null),
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

const _tabular = [FontFeature.tabularFigures()];

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.viewModel,
    required this.narrow,
    required this.onOpen,
  });

  final HistoryViewModel viewModel;
  final bool narrow;
  final void Function(UuidValue id) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final page = vm.page;
    final summary = page == null
        ? null
        : l10n.historySummary(
            historyRangeLabel(l10n, vm.filter.range),
            page.count,
            formatMoney(context, page.total),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        PageHeader(
          title: l10n.historyTitle,
          subtitle: summary,
          action: FButton(
            key: const ValueKey('history-export'),
            variant: .outline,
            mainAxisSize: .min,
            onPress:
                page == null ||
                    page.rows.isEmpty ||
                    vm.listing ||
                    vm.export.running
                ? null
                : () => vm.export.execute(
                    historyWorkbook(l10n, page, timezone: vm.data?.timezone),
                  ),
            prefix: vm.export.running
                ? const SizedBox.square(
                    dimension: 16,
                    child: FCircularProgress(),
                  )
                : const Icon(TablerIcons.fileSpreadsheet),
            child: Flexible(child: Text(l10n.historyExport)),
          ),
        ),
        if (vm.export.completed && vm.exportPath != null)
          FAlert(
            key: const ValueKey('history-export-saved'),
            title: Text(l10n.historyExportSaved(vm.exportPath!)),
          )
        else if (vm.export.error)
          FAlert(
            key: const ValueKey('history-export-error'),
            variant: .destructive,
            title: Text(l10n.historyExportFailed),
          ),
        _Filters(viewModel: vm, narrow: narrow),
        if (vm.error != null)
          LoadFailedAlert(
            key: const ValueKey('history-list-error'),
            message: l10n.historyLoadFailed,
            onRetry: vm.refresh,
          ),
        if (page == null)
          const Center(child: FCircularProgress())
        else if (page.rows.isEmpty)
          FCard(
            key: const ValueKey('history-empty'),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                l10n.historyEmpty,
                textAlign: TextAlign.center,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          )
        else if (narrow)
          for (final r in page.rows)
            _SaleCard(
              row: r,
              timezone: vm.data?.timezone,
              withDate: vm.filter.range != HistoryRange.today,
              selected: r.sale.id == vm.selectedId,
              onTap: () => onOpen(r.sale.id),
            )
        else
          _SaleTable(
            rows: page.rows,
            timezone: vm.data?.timezone,
            withDate: vm.filter.range != HistoryRange.today,
            selectedId: vm.selectedId,
            onOpen: onOpen,
          ),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.viewModel, required this.narrow});

  final HistoryViewModel viewModel;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final f = vm.filter;
    final staff = vm.data?.staff ?? const [];
    Widget box(Widget child) =>
        SizedBox(width: narrow ? double.infinity : 180, child: child);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final range in HistoryRange.values)
              ChoicePill(
                key: ValueKey('history-range-${range.name}'),
                label: historyRangeLabel(l10n, range),
                selected: f.range == range,
                onTap: () => vm.setFilter(f.copyWith(range: range)),
              ),
          ],
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            box(
              FSelect<String>(
                key: const ValueKey('history-filter-staff'),
                label: Text(l10n.historyFilterStaff),
                items: _staffItems(l10n.historyFilterAllStaff, staff),
                control: .managed(
                  initial: f.staffId?.uuid ?? '',
                  onChange: (v) => vm.setFilter(
                    f.copyWith(
                      staffId: () => v == null || v.isEmpty
                          ? null
                          : UuidValue.fromString(v),
                    ),
                  ),
                ),
              ),
            ),
            box(
              FSelect<String>(
                key: const ValueKey('history-filter-method'),
                label: Text(l10n.historyFilterMethod),
                items: {
                  l10n.historyFilterAllMethods: '',
                  for (final m in PaymentMethod.values)
                    paymentMethodLabel(l10n, m): m.name,
                },
                control: .managed(
                  initial: f.method?.name ?? '',
                  onChange: (v) => vm.setFilter(
                    f.copyWith(
                      method: () => PaymentMethod.values
                          .where((m) => m.name == v)
                          .firstOrNull,
                    ),
                  ),
                ),
              ),
            ),
            box(
              FSelect<String>(
                key: const ValueKey('history-filter-status'),
                label: Text(l10n.historyFilterStatus),
                items: {
                  for (final s in HistoryStatus.values)
                    historyStatusFilterLabel(l10n, s): s.name,
                },
                control: .managed(
                  initial: f.status.name,
                  onChange: (v) => vm.setFilter(
                    f.copyWith(
                      status: HistoryStatus.values
                          .where((s) => s.name == v)
                          .firstOrNull,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Pilihan filter kasir; nama kembar diberi nomor agar kunci unik.
Map<String, String> _staffItems(String all, List<HistoryStaff> staff) {
  final items = <String, String>{all: ''};
  for (final s in staff) {
    var label = s.name;
    for (var n = 2; items.containsKey(label); n++) {
      label = '${s.name} ($n)';
    }
    items[label] = s.id.uuid;
  }
  return items;
}

/// Lencana status nota.
class SaleStatusBadge extends StatelessWidget {
  const SaleStatusBadge({super.key, required this.status});

  final SaleStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FBadge(
      variant: switch (status) {
        SaleStatus.voided => .destructive,
        SaleStatus.partiallyReturned || SaleStatus.returned => .outline,
        _ => .secondary,
      },
      child: Text(saleStatusLabel(l10n, status)),
    );
  }
}

class _SaleTable extends StatelessWidget {
  const _SaleTable({
    required this.rows,
    required this.timezone,
    required this.withDate,
    required this.selectedId,
    required this.onOpen,
  });

  final List<HistoryRow> rows;
  final String? timezone;

  /// Rentang lebih dari hari ini: kolom waktu memuat tanggal.
  final bool withDate;
  final UuidValue? selectedId;
  final void Function(UuidValue id) onOpen;

  static const _cols = [32, 9, 14, 15, 15, 19];
  static const _colsWithDate = [30, 13, 13, 14, 14, 19];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final head = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
      fontWeight: FontWeight.w600,
    );
    final body = theme.typography.body.sm.copyWith(fontFeatures: _tabular);
    final cols = withDate ? _colsWithDate : _cols;
    Widget cell(int i, Widget child) => Expanded(flex: cols[i], child: child);
    final selectedColor = theme.colors.primary.withValues(alpha: 0.08);
    final labels = [
      l10n.historyColNumber,
      l10n.historyColTime,
      l10n.historyColStaff,
      l10n.historyColMethod,
      l10n.historyColTotal,
      l10n.historyColStatus,
    ];
    return DecoratedBox(
      key: const ValueKey('history-table'),
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
                spacing: 12,
                children: [
                  for (var i = 0; i < labels.length; i++)
                    cell(
                      i,
                      Text(
                        labels[i],
                        style: head,
                        textAlign: i == 4 ? TextAlign.end : TextAlign.start,
                      ),
                    ),
                ],
              ),
            ),
          ),
          for (final r in rows)
            DecoratedBox(
              decoration: BoxDecoration(
                color: r.sale.id == selectedId ? selectedColor : null,
                border: Border(top: BorderSide(color: theme.colors.border)),
              ),
              child: FTappable(
                key: ValueKey('history-row-${r.sale.id.uuid}'),
                onPress: () => onOpen(r.sale.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      cell(
                        0,
                        Text(
                          r.sale.number,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: body.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      cell(
                        1,
                        Text(
                          withDate
                              ? formatDayClock(r.sale.soldAt, timezone)
                              : formatClock(r.sale.soldAt, timezone),
                          maxLines: 1,
                          style: body,
                        ),
                      ),
                      cell(
                        2,
                        Text(
                          r.staffName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: body,
                        ),
                      ),
                      cell(
                        3,
                        Text(
                          historyMethods(l10n, r.methods),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: body,
                        ),
                      ),
                      cell(
                        4,
                        Text(
                          formatMoney(context, r.net),
                          textAlign: TextAlign.end,
                          style: body.copyWith(
                            fontWeight: FontWeight.w700,
                            decoration: r.sale.status == SaleStatus.voided
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      cell(
                        5,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SaleStatusBadge(status: r.sale.status),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({
    required this.row,
    required this.timezone,
    required this.withDate,
    required this.selected,
    required this.onTap,
  });

  final HistoryRow row;
  final String? timezone;
  final bool withDate;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final r = row;
    return FTappable(
      key: ValueKey('history-row-${r.sale.id.uuid}'),
      onPress: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? theme.colors.primary.withValues(alpha: 0.08)
              : theme.colors.card,
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      r.sale.number,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      [
                        withDate
                            ? formatDayClock(r.sale.soldAt, timezone)
                            : formatClock(r.sale.soldAt, timezone),
                        r.staffName,
                        historyMethods(l10n, r.methods),
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _muted(context),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 4,
                children: [
                  Text(
                    formatMoney(context, r.net),
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: _tabular,
                    ),
                  ),
                  SaleStatusBadge(status: r.sale.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
