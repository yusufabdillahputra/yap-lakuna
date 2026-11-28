import 'dart:async';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart'
    show DashboardData, SyncOfflineException;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/dashboard_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

const pusatId = '01900000-0000-7000-8000-000000000010';
const timurId = '01900000-0000-7000-8000-000000000011';

List<Money> hoursOf(Map<int, int> at) => [
  for (var h = 0; h < 24; h++) Money(at[h] ?? 0),
];

/// Dua cabang: Pusat (2 nota, 30.000) dan Timur (1 nota, 6.000).
DashboardData sampleDashboard({String? only}) {
  final outlets = [
    OutletDay(
      outletId: pusatId,
      sales: const Money(30000),
      transactions: 2,
      hourly: hoursOf({9: 10000, 14: 20000}),
    ),
    OutletDay(
      outletId: timurId,
      sales: const Money(6000),
      transactions: 1,
      hourly: hoursOf({14: 6000}),
    ),
  ];
  return DashboardData(
    outlets: [
      for (final o in outlets)
        if (only == null || o.outletId == only) o,
    ],
    outletInfo: {
      pusatId: (name: 'Pusat', code: 'PST'),
      timurId: (name: 'Timur', code: 'TMR'),
    },
    top: [
      if (only != timurId)
        (productId: 'kopi', name: 'Kopi Bubuk', sold: const Qty(3000)),
      if (only != pusatId)
        (productId: 'pulsa', name: 'Isi Pulsa', sold: const Qty(1000)),
    ],
    belowMinimum: {
      if (only != timurId) pusatId: 0,
      if (only != pusatId) timurId: 0,
    },
  );
}

DeviceStatus device(String code, String outlet, DateTime? lastSeen) =>
    DeviceStatus(
      deviceId: UuidValue.fromString(
        '01900000-0000-7000-8000-0000000000${code.substring(1)}',
      ),
      outletId: UuidValue.fromString(outlet),
      code: code,
      name: 'Kasir $code',
      platform: DevicePlatform.android,
      lastSeenAt: lastSeen,
    );

class FakeDashboardRepository implements DashboardRepository {
  FakeDashboardRepository({required this.now});

  DateTime now;
  final loads = <UuidValue?>[];
  var statusCalls = 0;

  /// `null` = offline.
  TenantStatus? status;

  /// Bila diisi, [load] memakai ini, bukan [sampleDashboard].
  DashboardData Function(String? outletId)? data;

  /// Bila diisi, [load] / [tenantStatus] menunggu ini (server lambat).
  Completer<void>? loadGate;
  Completer<void>? statusGate;

  @override
  Future<Result<DashboardData>> load({UuidValue? outletId}) async {
    loads.add(outletId);
    await loadGate?.future;
    final only = outletId?.uuid;
    return Result.ok((data ?? (id) => sampleDashboard(only: id))(only));
  }

  @override
  Future<Result<TenantStatus>> tenantStatus() async {
    statusCalls++;
    await statusGate?.future;
    final s = status;
    return s == null
        ? const Result.error(SyncOfflineException())
        : Result.ok(s);
  }
}
