import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/dashboard_repository.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../routing/routes.dart';
import '../../utils/result.dart';
import '../customers/customer_labels.dart' show formatLongDate;
import '../products/product_widgets.dart';
import '../reports/report_labels.dart';
import 'dashboard_export.dart';
import 'dashboard_view_model.dart';

const _tabular = [FontFeature.tabularFigures()];

/// Sentinel pilihan *Semua cabang* di pemilih cabang.
const _allOutlets = '*';

/// Mulai lebar ini tabel *Per cabang hari ini* tampil sebagai tabel.
const _tableWidth = 720.0;

/// Mulai lebar ini grafik per jam dan *Terlaris* berdampingan.
const _sideBySideWidth = 1000.0;

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

TextStyle _strong(BuildContext context) => context.theme.typography.body.sm
    .copyWith(fontWeight: FontWeight.w600, fontFeatures: _tabular);

/// "3 jam lalu" dari [time] sampai [now]; `null` = belum pernah.
String dashboardAgo(AppLocalizations l10n, DateTime? time, DateTime now) {
  if (time == null) return l10n.dashboardAgoNever;
  final d = now.difference(time);
  if (d.inMinutes < 1) return l10n.dashboardAgoNow;
  if (d.inMinutes < 60) return l10n.dashboardAgoMinutes(d.inMinutes);
  if (d.inHours < 24) return l10n.dashboardAgoHours(d.inHours);
  return l10n.dashboardAgoDays(d.inDays);
}

/// Layar *Dashboard semua cabang* (2.3, F2-02 tahap 3).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.repository,
    this.exporter = const PlatformSpreadsheetExporter(),
    this.permissions = const {},
    this.currentOutletId,
    this.timezone,
  });

  final DashboardRepository repository;
  final SpreadsheetExporter exporter;

  /// Izin staf, untuk tautan ke Stok minimum dan kartu *Versi hosting*.
  final Set<Permission> permissions;

  /// Cabang perangkat/sesi ini: tautan Stok minimum hanya untuk cabang ini.
  final String? currentOutletId;

  /// Zona waktu cabang ini untuk tanggal di subjudul.
  final String? timezone;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final _vm = DashboardViewModel(
    repository: widget.repository,
    exporter: widget.exporter,
    timezone: widget.timezone,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_vm.start());
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    if (_vm.data == null || _vm.exportExcel.running) return;
    final l10n = AppLocalizations.of(context);
    await _vm.exportExcel.execute(
      dashboardXlsx(
        l10n,
        _vm,
        date: l10n.dashboardSubtitle(formatLongDate(l10n, _vm.localNow)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final vm = _vm;
      final data = vm.data;
      final today = vm.localNow;
      final error = vm.load.result;
      return SingleChildScrollView(
        key: const ValueKey('dashboard-screen'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            PageHeader(
              title: l10n.dashboardTitle,
              subtitle: l10n.dashboardSubtitle(formatLongDate(l10n, today)),
              action: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (data != null) _OutletPicker(viewModel: vm),
                  FButton(
                    key: const ValueKey('dashboard-download'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: data == null || vm.exportExcel.running
                        ? null
                        : () => unawaited(_download()),
                    prefix: const Icon(TablerIcons.fileSpreadsheet),
                    child: Flexible(child: Text(l10n.dashboardDownload)),
                  ),
                ],
              ),
            ),
            if (vm.exportExcel.completed && vm.exportPath != null)
              FAlert(
                key: const ValueKey('dashboard-export-saved'),
                title: Text(l10n.historyExportSaved(vm.exportPath!)),
              )
            else if (vm.exportExcel.error)
              FAlert(
                key: const ValueKey('dashboard-export-error'),
                variant: .destructive,
                title: Text(l10n.historyExportFailed),
              ),
            if (data == null && error is Error)
              LoadFailedAlert(
                key: const ValueKey('dashboard-error'),
                message: switch (error.error) {
                  NotPermitted() => l10n.reportsNotPermitted,
                  _ => l10n.dashboardLoadFailed,
                },
                onRetry: vm.load.execute,
              )
            else if (data == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: FCircularProgress()),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final now = DateTime.now().toUtc();
                  final hourly = _Hourly(viewModel: vm);
                  final top = _Top(viewModel: vm);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      _Kpis(viewModel: vm, now: now, width: width),
                      _OutletTable(
                        viewModel: vm,
                        now: now,
                        table: width >= _tableWidth,
                      ),
                      if (width >= _sideBySideWidth)
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: 16,
                            children: [
                              Expanded(flex: 2, child: hourly),
                              Expanded(child: top),
                            ],
                          ),
                        )
                      else ...[
                        hourly,
                        top,
                      ],
                      _Attention(
                        viewModel: vm,
                        now: now,
                        permissions: widget.permissions,
                        currentOutletId: widget.currentOutletId,
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      );
    },
  );
}

class _OutletPicker extends StatelessWidget {
  const _OutletPicker({required this.viewModel});

  final DashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final info = viewModel.data?.outletInfo ?? const {};
    final entries = info.entries.toList()
      ..sort((a, b) => a.value.code.compareTo(b.value.code));
    return SizedBox(
      width: 240,
      child: FSelect<String>(
        key: const ValueKey('dashboard-outlet'),
        items: {
          l10n.dashboardOutletAll(info.length): _allOutlets,
          for (final e in entries) '${e.value.name} (${e.value.code})': e.key,
        },
        control: .managed(
          initial: viewModel.selectedOutlet ?? _allOutlets,
          onChange: (id) {
            if (id == null) return;
            unawaited(viewModel.selectOutlet(id == _allOutlets ? null : id));
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => FCard(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            title,
            style: context.theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          child,
        ],
      ),
    ),
  );
}

// --- Kartu KPI -----------------------------------------------------------------

class _Kpis extends StatelessWidget {
  const _Kpis({
    required this.viewModel,
    required this.now,
    required this.width,
  });

  final DashboardViewModel viewModel;
  final DateTime now;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final unavailable = vm.devicesUnavailable;
    final stale = vm.staleDevices;
    final offline = vm.devicesTotal - vm.devicesOnline;
    final cards = [
      _Kpi(
        id: 'sales',
        label: l10n.dashboardKpiSales,
        value: moneyLabel(l10n, vm.totalSales),
        note: l10n.dashboardKpiSalesNote(vm.transactions, vm.outletCount),
      ),
      _Kpi(
        id: 'average',
        label: l10n.dashboardKpiAverage,
        value: moneyLabel(l10n, vm.average),
        note: l10n.dashboardKpiAverageNote,
      ),
      _Kpi(
        id: 'devices',
        label: l10n.dashboardKpiDevices,
        value: unavailable ? '–' : '${vm.devicesOnline} / ${vm.devicesTotal}',
        note: unavailable
            ? l10n.dashboardDevicesUnavailable
            : vm.devicesTotal == 0
            ? l10n.dashboardDevicesNone
            : stale.length == 1
            ? l10n.dashboardDevicesStaleOne(
                dashboardAgo(l10n, stale.single.lastSeenAt, now),
              )
            : stale.length > 1
            ? l10n.dashboardDevicesStaleMany(stale.length)
            : offline > 0
            ? l10n.dashboardDevicesSomeOffline(offline)
            : l10n.dashboardDevicesAllOnline,
        warning: !unavailable && stale.isNotEmpty,
      ),
      _Kpi(
        id: 'conflicts',
        label: l10n.dashboardKpiConflicts,
        value: unavailable ? '–' : '${vm.conflicts}',
        note: unavailable
            ? l10n.dashboardDevicesUnavailable
            : vm.conflicts > 0
            ? l10n.dashboardConflictsReview
            : l10n.dashboardConflictsNone,
        warning: vm.conflicts > 0,
      ),
    ];
    final columns = width >= 1000 ? 4 : 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        for (var i = 0; i < cards.length; i += columns)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                for (final c in cards.skip(i).take(columns)) Expanded(child: c),
              ],
            ),
          ),
      ],
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.id,
    required this.label,
    required this.value,
    required this.note,
    this.warning = false,
  });

  final String id;
  final String label;
  final String value;
  final String note;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FCard(
      key: ValueKey('dashboard-kpi-$id'),
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
            Text(
              note,
              style: warning
                  ? _muted(
                      context,
                    ).copyWith(color: theme.colors.destructive)
                  : _muted(context),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Per cabang hari ini -------------------------------------------------------

/// Teks kolom *Sync terakhir* dan *Status* satu baris.
({String lastSync, String status, bool offline}) _deviceCells(
  AppLocalizations l10n, {
  required bool unavailable,
  required int devices,
  required int offline,
  required DateTime? lastSync,
  required DateTime now,
}) {
  if (unavailable) return (lastSync: '–', status: '–', offline: false);
  if (devices == 0) {
    return (
      lastSync: '–',
      status: l10n.dashboardStatusNoDevices,
      offline: false,
    );
  }
  return (
    lastSync: dashboardAgo(l10n, lastSync, now),
    status: offline == 0
        ? l10n.dashboardStatusOnline
        : l10n.dashboardDevicesSomeOffline(offline),
    offline: offline > 0,
  );
}

class _OutletTable extends StatelessWidget {
  const _OutletTable({
    required this.viewModel,
    required this.now,
    required this.table,
  });

  final DashboardViewModel viewModel;
  final DateTime now;
  final bool table;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final unavailable = vm.devicesUnavailable;
    final rows = vm.rows;
    final lines = [
      for (final r in rows)
        _Line(
          id: r.outletId,
          name: r.name,
          meta: unavailable
              ? r.code
              : l10n.dashboardOutletMeta(r.code, r.devices),
          sales: moneyLabel(l10n, r.sales),
          transactions: '${r.transactions}',
          cells: _deviceCells(
            l10n,
            unavailable: unavailable,
            devices: r.devices,
            offline: r.offline,
            lastSync: r.lastSync,
            now: now,
          ),
        ),
      _Line(
        id: 'total',
        name: l10n.dashboardTotal,
        meta: null,
        sales: moneyLabel(l10n, vm.totalSales),
        transactions: '${vm.transactions}',
        cells: _deviceCells(
          l10n,
          unavailable: unavailable,
          devices: vm.devicesTotal,
          offline: vm.devicesTotal - vm.devicesOnline,
          lastSync: vm.lastSync,
          now: now,
        ),
        total: true,
      ),
    ];
    return _Section(
      key: const ValueKey('dashboard-table'),
      title: l10n.dashboardTableTitle,
      child: table
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TableRow(
                  header: true,
                  cells: [
                    l10n.dashboardColOutlet,
                    l10n.dashboardColSales,
                    l10n.dashboardColTransactions,
                    l10n.dashboardColLastSync,
                    l10n.dashboardColStatus,
                  ],
                ),
                for (final line in lines) _TableLine(line: line),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [for (final line in lines) _CardLine(line: line)],
            ),
    );
  }
}

class _Line {
  const _Line({
    required this.id,
    required this.name,
    required this.meta,
    required this.sales,
    required this.transactions,
    required this.cells,
    this.total = false,
  });

  final String id;
  final String name;
  final String? meta;
  final String sales;
  final String transactions;
  final ({String lastSync, String status, bool offline}) cells;
  final bool total;
}

const _flex = [3, 2, 1, 2, 2];

class _TableRow extends StatelessWidget {
  const _TableRow({required this.cells, this.header = false});

  final List<String> cells;
  final bool header;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      spacing: 12,
      children: [
        for (var i = 0; i < cells.length; i++)
          Expanded(
            flex: _flex[i],
            child: Text(
              cells[i],
              textAlign: i == 1 || i == 2 ? TextAlign.end : TextAlign.start,
              style: _muted(context),
            ),
          ),
      ],
    ),
  );
}

class _TableLine extends StatelessWidget {
  const _TableLine({required this.line});

  final _Line line;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final body = theme.typography.body.sm.copyWith(fontFeatures: _tabular);
    final strong = line.total ? _strong(context) : body;
    return DecoratedBox(
      key: ValueKey('dashboard-row-${line.id}'),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              flex: _flex[0],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line.name, style: _strong(context)),
                  if (line.meta case final meta?)
                    Text(meta, style: _muted(context)),
                ],
              ),
            ),
            Expanded(
              flex: _flex[1],
              child: Text(
                line.sales,
                textAlign: TextAlign.end,
                style: strong,
              ),
            ),
            Expanded(
              flex: _flex[2],
              child: Text(
                line.transactions,
                textAlign: TextAlign.end,
                style: strong,
              ),
            ),
            Expanded(
              flex: _flex[3],
              child: Text(line.cells.lastSync, style: body),
            ),
            Expanded(
              flex: _flex[4],
              child: _StatusText(line: line),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.line});

  final _Line line;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      line.cells.status,
      style: theme.typography.body.sm.copyWith(
        color: line.cells.offline
            ? theme.colors.destructive
            : theme.colors.foreground,
        fontWeight: line.total ? FontWeight.w600 : null,
      ),
    );
  }
}

/// Baris tabel di ponsel: nama + penjualan, lalu transaksi, sync, status.
class _CardLine extends StatelessWidget {
  const _CardLine({required this.line});

  final _Line line;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return DecoratedBox(
      key: ValueKey('dashboard-row-${line.id}'),
      decoration: BoxDecoration(
        color: line.total ? theme.colors.muted : null,
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            Row(
              spacing: 8,
              children: [
                Expanded(child: Text(line.name, style: _strong(context))),
                Text(line.sales, style: _strong(context)),
              ],
            ),
            if (line.meta case final meta?) Text(meta, style: _muted(context)),
            Text(
              '${l10n.dashboardColTransactions} ${line.transactions} · '
              '${l10n.dashboardColLastSync} ${line.cells.lastSync}',
              style: _muted(context),
            ),
            _StatusText(line: line),
          ],
        ),
      ),
    );
  }
}

// --- Penjualan per jam dan Terlaris ---------------------------------------------

class _Hourly extends StatelessWidget {
  const _Hourly({required this.viewModel});

  final DashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final hourly = vm.hourly;
    final axis = vm.axis;
    final selected = vm.selectedOutlet;
    final scope = selected == null
        ? l10n.dashboardScopeAll
        : (vm.data?.outletInfo[selected]?.name ?? selected);
    var max = 0;
    for (var h = axis.from; h <= axis.to; h++) {
      if (hourly[h].value > max) max = hourly[h].value;
    }
    String two(int h) => h.toString().padLeft(2, '0');
    return _Section(
      key: const ValueKey('dashboard-hourly'),
      title: l10n.dashboardHourlyTitle(scope),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          if (max == 0) Text(l10n.dashboardHourlyEmpty, style: _muted(context)),
          LayoutBuilder(
            builder: (context, constraints) {
              // Ponsel: label jam tiap 2–3 jam agar tidak berdesakan.
              final count = axis.to - axis.from + 1;
              final slot = constraints.maxWidth / count;
              final step = slot >= 28 ? 1 : (slot >= 16 ? 2 : 3);
              return SizedBox(
                height: 160,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 4,
                  children: [
                    for (var h = axis.from; h <= axis.to; h++)
                      Expanded(
                        child: Semantics(
                          label: '${two(h)}.00 ${moneyLabel(l10n, hourly[h])}',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: FractionallySizedBox(
                                    // Jam dengan retur > penjualan bernilai negatif: batang
                                    // kosong, nilainya tetap di label dan Excel.
                                    heightFactor: max == 0
                                        ? 0
                                        : (hourly[h].value / max).clamp(
                                            0.0,
                                            1.0,
                                          ),
                                    widthFactor: 1,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: theme.colors.primary,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(3),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  (h - axis.from) % step == 0 ? two(h) : '',
                                  style: _muted(context),
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
          ),
        ],
      ),
    );
  }
}

class _Top extends StatelessWidget {
  const _Top({required this.viewModel});

  final DashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final top = viewModel.top;
    return _Section(
      key: const ValueKey('dashboard-top'),
      title: l10n.dashboardTopTitle,
      child: top.isEmpty
          ? Text(l10n.dashboardTopEmpty, style: _muted(context))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                for (final (i, t) in top.indexed)
                  Row(
                    spacing: 8,
                    children: [
                      SizedBox(
                        width: 20,
                        child: Text('${i + 1}', style: _muted(context)),
                      ),
                      Expanded(
                        child: Text(
                          t.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.theme.typography.body.sm,
                        ),
                      ),
                      Text(
                        l10n.dashboardTopSold(qtyLabel(l10n, t.sold)),
                        style: _muted(context),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}

// --- Perlu perhatian -------------------------------------------------------------

class _Attention extends StatelessWidget {
  const _Attention({
    required this.viewModel,
    required this.now,
    required this.permissions,
    required this.currentOutletId,
  });

  final DashboardViewModel viewModel;
  final DateTime now;
  final Set<Permission> permissions;
  final String? currentOutletId;

  /// Stok minimum hanya bisa dibuka untuk cabang ini (layar Stok per
  /// cabang).
  bool _linksStock(String outletId) =>
      outletId == currentOutletId &&
      permissions.contains(Permission.stockAdjust);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    if (vm.allClear) {
      return FCard(
        key: const ValueKey('dashboard-all-clear'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 12,
            children: [
              Icon(TablerIcons.circleCheck, color: theme.colors.primary),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      l10n.dashboardAllClear,
                      style: theme.typography.body.md.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(l10n.dashboardAllClearNote, style: _muted(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    final items = vm.attention;
    return _Section(
      key: const ValueKey('dashboard-attention'),
      title: l10n.dashboardAttentionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          for (final item in items)
            switch (item) {
              AttentionConflicts(:final count) => FItem(
                key: const ValueKey('dashboard-attention-conflicts'),
                prefix: const Icon(TablerIcons.arrowsDiff),
                title: Text(l10n.dashboardAttentionConflicts(count)),
                suffix: permissions.contains(Permission.syncManage)
                    ? const Icon(TablerIcons.chevronRight)
                    : null,
                onPress: permissions.contains(Permission.syncManage)
                    ? () => context.go('${Routes.settings}?bagian=hosting')
                    : null,
              ),
              AttentionDevice(:final device, :final outletName) => FItem(
                key: ValueKey('dashboard-attention-device-${device.code}'),
                prefix: const Icon(TablerIcons.deviceMobileOff),
                title: Text(
                  device.lastSeenAt == null
                      ? l10n.dashboardAttentionDeviceNever(
                          device.name,
                          outletName,
                        )
                      : l10n.dashboardAttentionDevice(
                          device.name,
                          outletName,
                          dashboardAgo(l10n, device.lastSeenAt, now),
                        ),
                ),
              ),
              AttentionStock(
                :final outletId,
                :final outletName,
                :final count,
              ) =>
                FItem(
                  key: ValueKey('dashboard-attention-stock-$outletId'),
                  prefix: const Icon(TablerIcons.packageOff),
                  title: Text(l10n.dashboardAttentionStock(count, outletName)),
                  suffix: _linksStock(outletId)
                      ? const Icon(TablerIcons.chevronRight)
                      : null,
                  onPress: _linksStock(outletId)
                      ? () => context.go(Routes.stockTab('minimum'))
                      : null,
                ),
            },
          if (vm.devicesUnavailable)
            Text(l10n.dashboardDevicesUnavailable, style: _muted(context)),
        ],
      ),
    );
  }
}
