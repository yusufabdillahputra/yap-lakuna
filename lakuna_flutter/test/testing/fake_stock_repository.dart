import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/stock_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

UuidValue fakeId(int n) => UuidValue.fromString(
  '00000000-0000-7000-8000-${n.toString().padLeft(12, '0')}',
);

/// [StockRepository] di memori: penyesuaian mengubah stok baris, kartu stok
/// dibuat dari pergerakan yang dicatat.
class FakeStockRepository extends StockRepository {
  FakeStockRepository({
    List<StockRow>? rows,
    List<StockLocation>? locations,
    this.canAdjust = true,
  }) : rows = rows ?? sampleStockRows(),
       locationList = locations ?? [sampleLocation(1, 'Etalase', true)];

  List<StockRow> rows;
  List<StockLocation> locationList;
  bool canAdjust;
  Exception? nextError;
  final saves =
      <(UuidValue, StockAdjustmentReason, List<AdjustmentLine>, String?)>[];
  final summaries = <StockAdjustmentSummary>[];
  final cards = <UuidValue, List<StockCardEntry>>{};
  var _counter = 0;

  Result<T> _result<T>(T Function() value) {
    final e = nextError;
    nextError = null;
    return e == null ? Result.ok(value()) : Result.error(e);
  }

  @override
  Future<Result<List<StockLocation>>> locations() async =>
      _result(() => List.of(locationList));

  @override
  Future<Result<List<StockRow>>> stock({UuidValue? locationId}) async =>
      _result(() => List.of(rows));

  @override
  Future<Result<List<StockRow>>> belowMinimum({UuidValue? locationId}) async =>
      _result(
        () => [
          for (final r in rows)
            if (r.belowMinimum) r,
        ],
      );

  @override
  Future<Result<StockCard>> card({
    required UuidValue variantId,
    UuidValue? locationId,
  }) async => _result(
    () {
      final row = rows.firstWhere((r) => r.variantId == variantId);
      final entries = cards[variantId] ?? const <StockCardEntry>[];
      // Saldo awal + pergerakan = stok baris, seperti ledger asli.
      final moved = entries.fold(0, (sum, e) => sum + e.quantity.milli);
      return StockCard(
        openingBalance: Qty(row.stock.milli - moved),
        entries: entries,
        minStock: row.minStock,
      );
    },
  );

  String get _next =>
      'SA-PST-K01-261103-${(_counter + 1).toString().padLeft(4, '0')}';

  @override
  Future<Result<String>> nextAdjustmentNumber() async => _result(() => _next);

  @override
  Future<Result<List<StockAdjustmentSummary>>> recentAdjustments() async =>
      _result(() => summaries.reversed.toList());

  @override
  Future<Result<StockAdjustmentResult>> saveAdjustment({
    required UuidValue locationId,
    required StockAdjustmentReason reason,
    required List<AdjustmentLine> lines,
    String? note,
  }) async {
    if (!canAdjust) {
      return const Result.error(NotPermitted(Permission.stockAdjust));
    }
    final e = nextError;
    nextError = null;
    if (e != null) return Result.error(e);
    saves.add((locationId, reason, lines, note));
    final number = _next;
    _counter++;
    var total = Money.zero;
    final now = DateTime.utc(2026, 11, 3, 9, _counter);
    for (final l in lines) {
      final i = rows.indexWhere((r) => r.variantId == l.variantId);
      final r = rows[i];
      final diff = l.physical - r.stock;
      total += adjustmentValue(diff, r.unitCost);
      rows[i] = StockRow(
        variantId: r.variantId,
        productId: r.productId,
        productName: r.productName,
        variantName: r.variantName,
        baseUnit: r.baseUnit,
        stock: l.physical,
        minStock: r.minStock,
        unitCost: r.unitCost,
        sku: r.sku,
        barcode: r.barcode,
      );
      if (diff != Qty.zero) {
        (cards[r.variantId] ??= []).add(
          StockCardEntry(
            occurredAt: now,
            sourceType: StockSourceType.adjustment,
            documentNumber: number,
            staffName: 'Budi',
            reason: reason,
            note: l.note,
            quantity: diff,
            balance: l.physical,
          ),
        );
      }
    }
    summaries.add(
      StockAdjustmentSummary(
        id: fakeId(900 + _counter),
        number: number,
        adjustedAt: now,
        reason: reason,
        staffName: 'Budi',
        locationName: locationList.first.name,
        itemCount: lines.length,
        totalValue: total,
        note: note,
      ),
    );
    return Result.ok(
      StockAdjustmentResult(
        adjustment: StockAdjustment(
          id: fakeId(900 + _counter),
          tenantId: fakeId(1),
          outletId: fakeId(2),
          stockLocationId: locationId,
          number: number,
          reason: reason,
          note: note,
          totalValue: total.value,
          staffId: fakeId(3),
          adjustedAt: now,
          hlc: '',
        ),
        items: const [],
      ),
    );
  }

  @override
  Future<Result<StockLocation>> createLocation(String name) async {
    if (!canAdjust) {
      return const Result.error(NotPermitted(Permission.stockAdjust));
    }
    final error = validateLocationName(
      name,
      existing: locationList.map((l) => l.name),
    );
    if (error != null) return Result.error(StockLocationInvalid(error));
    final l = sampleLocation(locationList.length + 1, name.trim(), false);
    locationList.add(l);
    return Result.ok(l);
  }

  @override
  Future<Result<StockLocation>> renameLocation(
    UuidValue id,
    String name,
  ) async {
    if (!canAdjust) {
      return const Result.error(NotPermitted(Permission.stockAdjust));
    }
    final error = validateLocationName(
      name,
      existing: [
        for (final l in locationList)
          if (l.id != id) l.name,
      ],
    );
    if (error != null) return Result.error(StockLocationInvalid(error));
    final i = locationList.indexWhere((l) => l.id == id);
    locationList[i] = locationList[i].copyWith(name: name.trim());
    return Result.ok(locationList[i]);
  }
}

StockLocation sampleLocation(int n, String name, bool isDefault) =>
    StockLocation(
      id: fakeId(100 + n),
      tenantId: fakeId(1),
      outletId: fakeId(2),
      name: name,
      isDefault: isDefault,
      hlc: '',
    );

StockRow sampleRow(
  int n,
  String name, {
  required String unit,
  required Qty stock,
  Qty minStock = Qty.zero,
  Money cost = const Money(1000),
  String? barcode,
}) => StockRow(
  variantId: fakeId(200 + n),
  productId: fakeId(300 + n),
  productName: name,
  variantName: '',
  baseUnit: unit,
  stock: stock,
  minStock: minStock,
  unitCost: cost,
  barcode: barcode,
);

/// Telur 12,5 kg (min 15), Kopi 2 (min 20), Sabun 15.
List<StockRow> sampleStockRows() => [
  sampleRow(
    1,
    'Kopi Sachet',
    unit: 'sachet',
    stock: Qty.units(2),
    minStock: Qty.units(20),
    cost: const Money(1500),
    barcode: '8990001',
  ),
  sampleRow(
    2,
    'Sabun Cuci 800 g',
    unit: 'pcs',
    stock: Qty.units(15),
    cost: const Money(18000),
  ),
  sampleRow(
    3,
    'Telur Ayam',
    unit: 'kg',
    stock: const Qty(12500),
    minStock: Qty.units(15),
    cost: const Money(25500),
  ),
];
