import 'dart:typed_data';

import '../../data/services/spreadsheet_exporter.dart';
import '../../l10n/gen/app_localizations.dart';
import '../reports/report_labels.dart' show qtyLabel;
import 'dashboard_view.dart' show dashboardAgo;
import 'dashboard_view_model.dart';

/// Excel ringkasan dashboard untuk pilihan cabang saat ini (F2-02 aturan
/// 23): KPI, per cabang, per jam, terlaris.
Uint8List dashboardXlsx(
  AppLocalizations l10n,
  DashboardViewModel vm, {
  required String date,
  DateTime? now,
}) {
  final at = (now ?? DateTime.now()).toUtc();
  final selected = vm.selectedOutlet;
  final scope = selected == null
      ? l10n.dashboardScopeAll
      : (vm.data?.outletInfo[selected]?.name ?? selected);
  final unavailable = vm.devicesUnavailable;
  final axis = vm.axis;
  final hourly = vm.hourly;
  String two(int h) => h.toString().padLeft(2, '0');
  return buildXlsx(
    l10n.dashboardTitle,
    [
      [l10n.dashboardTitle, scope],
      [date],
      [l10n.dashboardKpiSales, XlsxNumber(vm.totalSales.value)],
      [l10n.dashboardColTransactions, XlsxNumber(vm.transactions)],
      [l10n.dashboardKpiAverage, XlsxNumber(vm.average.value)],
      [
        l10n.dashboardKpiDevices,
        unavailable
            ? l10n.dashboardDevicesUnavailable
            : '${vm.devicesOnline} / ${vm.devicesTotal}',
      ],
      [
        l10n.dashboardKpiConflicts,
        unavailable
            ? l10n.dashboardDevicesUnavailable
            : XlsxNumber(vm.conflicts),
      ],
      const [],
      [
        l10n.dashboardColOutlet,
        l10n.dashboardColSales,
        l10n.dashboardColTransactions,
        l10n.dashboardColLastSync,
        l10n.dashboardColStatus,
      ],
      for (final r in vm.rows)
        [
          '${r.name} (${r.code})',
          XlsxNumber(r.sales.value),
          XlsxNumber(r.transactions),
          if (unavailable || r.devices == 0) ...[
            '',
            unavailable ? '' : l10n.dashboardStatusNoDevices,
          ] else ...[
            dashboardAgo(l10n, r.lastSync, at),
            r.offline == 0
                ? l10n.dashboardStatusOnline
                : l10n.dashboardDevicesSomeOffline(r.offline),
          ],
        ],
      [
        l10n.dashboardTotal,
        XlsxNumber(vm.totalSales.value),
        XlsxNumber(vm.transactions),
      ],
      const [],
      [l10n.dashboardExportHour, l10n.dashboardColSales],
      for (var h = axis.from; h <= axis.to; h++)
        ['${two(h)}.00', XlsxNumber(hourly[h].value)],
      const [],
      [l10n.dashboardTopTitle],
      [l10n.dashboardExportProduct, l10n.dashboardExportSold],
      for (final t in vm.top) [t.name, qtyLabel(l10n, t.sold)],
    ],
    widths: const [32, 16, 12, 16, 20],
  );
}
