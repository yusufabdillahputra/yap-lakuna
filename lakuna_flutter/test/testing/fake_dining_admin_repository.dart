import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/dining_admin_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

import 'fake_stock_repository.dart' show fakeId;

/// Area & meja di memori dengan aturan `lakuna_domain` yang sama dengan
/// `dining_admin.dart`: Indoor (M1, M2) dan Teras (T1), tarif 0.
class FakeDiningAdminRepository extends DiningAdminRepository {
  FakeDiningAdminRepository({this.permitted = true}) {
    areas.addAll([_area(1, 'Indoor', 0), _area(2, 'Teras', 1)]);
    tables.addAll([
      _table(1, 'M1', 1, 0),
      _table(2, 'M2', 1, 1),
      _table(3, 'T1', 2, 2),
    ]);
  }

  bool permitted;
  final areas = <DiningArea>[];
  final tables = <DiningTable>[];

  /// Meja dengan bill terbuka (hapus ditolak).
  final busyTables = <UuidValue>{};
  FnbRates savedRates = const FnbRates();

  /// Gambar denah per area.
  final images = <UuidValue, FloorImage>{};

  /// Panggilan *Simpan tata letak* terakhir.
  ({
    UuidValue areaId,
    DiningLayoutMode mode,
    List<FloorTableDraft> tables,
    List<UuidValue> deleted,
  })?
  lastLayout;

  /// Galat berikutnya (sekali pakai).
  Exception? nextError;
  var _next = 900;
  final _tenant = fakeId(1);
  final _outlet = fakeId(2);

  DiningArea _area(int n, String name, int order) => DiningArea(
    id: fakeId(800 + n),
    tenantId: _tenant,
    outletId: _outlet,
    name: name,
    sortOrder: order,
    hlc: '',
  );

  DiningTable _table(int n, String name, int area, int order) => DiningTable(
    id: fakeId(850 + n),
    tenantId: _tenant,
    outletId: _outlet,
    diningAreaId: fakeId(800 + area),
    name: name,
    seats: 4,
    sortOrder: order,
    hlc: '',
  );

  Future<Result<T>> _run<T>(T Function() body) async {
    final e = nextError;
    nextError = null;
    if (e != null) return Result.error(e);
    if (!permitted) {
      return const Result.error(NotPermitted(Permission.settingsManage));
    }
    try {
      return Result.ok(body());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  void _sort() {
    areas.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    tables.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  void _checkName(
    String name,
    int max,
    Iterable<String> existing, [
    int i = 0,
  ]) {
    final e = validateDiningName(name, max: max, existing: existing);
    if (e != null) throw DiningNameInvalid(e, index: i);
  }

  @override
  Future<Result<DiningSetup>> load() => _run(() {
    _sort();
    return DiningSetup(areas: List.of(areas), tables: List.of(tables));
  });

  @override
  Future<Result<DiningArea>> createArea(String name) => _run(() {
    _checkName(name, FnbLimits.areaName, areas.map((a) => a.name));
    final a = DiningArea(
      id: fakeId(_next++),
      tenantId: _tenant,
      outletId: _outlet,
      name: name.trim(),
      sortOrder: areas.length,
      hlc: '',
    );
    areas.add(a);
    return a;
  });

  @override
  Future<Result<DiningArea>> renameArea(UuidValue id, String name) => _run(() {
    final i = areas.indexWhere((a) => a.id == id);
    if (i < 0) throw DiningNotFound();
    _checkName(name, FnbLimits.areaName, [
      for (final a in areas)
        if (a.id != id) a.name,
    ]);
    return areas[i] = areas[i].copyWith(name: name.trim());
  });

  @override
  Future<Result<void>> moveArea(UuidValue id, int delta) => _run(() {
    _sort();
    final moved = moveInOrder(
      areas,
      areas.indexWhere((a) => a.id == id),
      delta,
    );
    areas
      ..clear()
      ..addAll([
        for (final (i, a) in moved.indexed) a.copyWith(sortOrder: i),
      ]);
  });

  @override
  Future<Result<void>> deleteArea(UuidValue id) => _run(() {
    final count = tables.where((t) => t.diningAreaId == id).length;
    if (count > 0) throw DiningInUse(tables: count);
    areas.removeWhere((a) => a.id == id);
  });

  void _checkSeats(int seats) {
    if (seats < 1 || seats > FnbLimits.seatsMax) throw DiningSeatsInvalid();
  }

  @override
  Future<Result<List<DiningTable>>> createTables(
    List<DiningTableDraft> drafts,
  ) => _run(() {
    final names = [for (final t in tables) t.name];
    for (final (i, d) in drafts.indexed) {
      _checkName(d.name, FnbLimits.tableName, names, i);
      _checkSeats(d.seats);
      names.add(d.name.trim());
    }
    final created = [
      for (final (i, d) in drafts.indexed)
        DiningTable(
          id: fakeId(_next++),
          tenantId: _tenant,
          outletId: _outlet,
          diningAreaId: d.areaId,
          name: d.name.trim(),
          seats: d.seats,
          sortOrder: tables.length + i,
          hlc: '',
        ),
    ];
    tables.addAll(created);
    return created;
  });

  @override
  Future<Result<DiningTable>> updateTable(
    UuidValue id,
    DiningTableDraft draft,
  ) => _run(() {
    final i = tables.indexWhere((t) => t.id == id);
    if (i < 0) throw DiningNotFound();
    _checkName(draft.name, FnbLimits.tableName, [
      for (final t in tables)
        if (t.id != id) t.name,
    ]);
    _checkSeats(draft.seats);
    return tables[i] = tables[i].copyWith(
      name: draft.name.trim(),
      diningAreaId: draft.areaId,
      seats: draft.seats,
    );
  });

  @override
  Future<Result<void>> moveTable(UuidValue id, int delta) => _run(() {
    _sort();
    final moved = moveInOrder(
      tables,
      tables.indexWhere((t) => t.id == id),
      delta,
    );
    tables
      ..clear()
      ..addAll([
        for (final (i, t) in moved.indexed) t.copyWith(sortOrder: i),
      ]);
  });

  @override
  Future<Result<void>> deleteTable(UuidValue id) => _run(() {
    if (busyTables.contains(id)) throw const DiningInUse(openBill: true);
    tables.removeWhere((t) => t.id == id);
  });

  @override
  Future<Result<FloorPlanSetup>> loadFloorPlan() => _run(() {
    _sort();
    return FloorPlanSetup(
      areas: List.of(areas),
      tables: List.of(tables),
      images: Map.of(images),
    );
  });

  @override
  Future<Result<DiningArea>> saveFloorImage(
    UuidValue areaId,
    Uint8List bytes,
    String fileName,
  ) => _run(() {
    if (bytes.length > FloorLimits.imageBytes) {
      throw const FloorImageInvalid(FloorImageError.tooLarge);
    }
    final header = readFloorImageHeader(bytes);
    if (header == null) throw const FloorImageInvalid(FloorImageError.format);
    final i = areas.indexWhere((a) => a.id == areaId);
    if (i < 0) throw DiningNotFound();
    final media = MediaFile(
      id: fakeId(_next++),
      tenantId: _tenant,
      outletId: _outlet,
      kind: MediaKind.floorPlan,
      fileName: fileName,
      mimeType: header.mimeType,
      sizeBytes: bytes.length,
      sha256: 'x',
      width: header.width,
      height: header.height,
      storageKey: 'x.${header.extension}',
      hlc: '',
    );
    images[areaId] = FloorImage(media: media, bytes: bytes);
    return areas[i] = areas[i].copyWith(
      floorMediaId: media.id,
      layoutMode: DiningLayoutMode.floor,
    );
  });

  @override
  Future<Result<void>> saveFloorLayout(
    UuidValue areaId, {
    required DiningLayoutMode mode,
    required List<FloorTableDraft> tables,
    List<UuidValue> deleted = const [],
  }) => _run(() {
    final i = areas.indexWhere((a) => a.id == areaId);
    if (i < 0) throw DiningNotFound();
    final touched = {
      for (final d in tables)
        if (d.id != null) d.id!,
      ...deleted,
    };
    final names = [
      for (final t in this.tables)
        if (!touched.contains(t.id)) t.name,
    ];
    for (final (j, d) in tables.indexed) {
      _checkName(d.name, FnbLimits.tableName, names, j);
      final e = validateFloorTable(
        seats: d.seats,
        width: d.width,
        height: d.height,
        x: d.x,
        y: d.y,
      );
      if (e != null) throw FloorTableInvalid(e, index: j);
      names.add(d.name.trim());
    }
    if (deleted.any(busyTables.contains)) {
      throw const DiningInUse(openBill: true);
    }
    lastLayout = (
      areaId: areaId,
      mode: mode,
      tables: tables,
      deleted: deleted,
    );
    this.tables.removeWhere((t) => deleted.contains(t.id));
    for (final d in tables) {
      final j = d.id == null ? -1 : this.tables.indexWhere((t) => t.id == d.id);
      final base = j < 0
          ? DiningTable(
              id: fakeId(_next++),
              tenantId: _tenant,
              outletId: _outlet,
              name: d.name,
              sortOrder: this.tables.length,
              hlc: '',
            )
          : this.tables[j];
      final next = base.copyWith(
        diningAreaId: areaId,
        name: d.name.trim(),
        seats: d.seats,
        shape: d.shape,
        posX: d.x,
        posY: d.y,
        width: d.width,
        height: d.height,
        canMerge: d.canMerge,
      );
      if (j < 0) {
        this.tables.add(next);
      } else {
        this.tables[j] = next;
      }
    }
    areas[i] = areas[i].copyWith(layoutMode: mode);
  });

  @override
  Future<Result<FnbRates>> rates() => _run(() => savedRates);

  @override
  Future<Result<FnbRates>> saveRates(FnbRates rates) => _run(() {
    final serviceOk = validateFnbRate(rates.service, FnbLimits.serviceBp);
    final taxOk = validateFnbRate(rates.tax, FnbLimits.taxBp);
    if (!serviceOk || !taxOk) {
      throw FnbRatesInvalid(service: !serviceOk, tax: !taxOk);
    }
    return savedRates = rates;
  });
}
