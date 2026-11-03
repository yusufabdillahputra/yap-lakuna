import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'dining_admin.dart';
import 'media.dart';
import 'stock.dart';
import 'store.dart';
import 'sync_tx.dart';

/// Denah meja (F1-10 v0.14.0): gambar denah per area dan tata letak meja.
/// Semua tulis lewat [LakunaStore.write] (outbox sync).

enum FloorImageError { format, tooLarge }

/// Gambar denah ditolak (format bukan PNG/JPG/WebP/SVG atau > 5 MB).
class FloorImageInvalid implements Exception {
  const FloorImageInvalid(this.error);

  final FloorImageError error;

  @override
  String toString() => 'FloorImageInvalid(${error.name})';
}

/// Isian meja denah tidak sah ([index] = baris draf).
class FloorTableInvalid implements Exception {
  const FloorTableInvalid(this.error, {this.index = 0});

  final FloorTableError error;
  final int index;

  @override
  String toString() => 'FloorTableInvalid(${error.name}, $index)';
}

/// Gambar denah satu area.
class FloorImage {
  const FloorImage({required this.media, this.bytes});

  final MediaFile media;

  /// `null` bila berkasnya belum ada di perangkat ini.
  final Uint8List? bytes;

  bool get isSvg => media.mimeType == ImageFormat.svg.mimeType;

  /// Ukuran dunia denah (lebar 800).
  ({int width, int height}) get world =>
      floorWorldSize(media.width, media.height);
}

/// Satu meja di draf *Atur denah*. [id] `null` = meja baru.
class FloorTableDraft {
  const FloorTableDraft({
    this.id,
    required this.name,
    this.seats = 4,
    this.shape = TableShape.square,
    this.x,
    this.y,
    this.width = 80,
    this.height = 80,
    this.canMerge = false,
  });

  final UuidValue? id;
  final String name;
  final int seats;
  final TableShape shape;
  final int? x;
  final int? y;
  final int width;
  final int height;
  final bool canMerge;
}

Future<MediaFile?> _floorMedia(
  DatabaseSession session,
  CatalogScope scope,
  UuidValue? id, {
  Transaction? transaction,
}) async {
  if (id == null) return null;
  return MediaFile.db.findFirstRow(
    session,
    where: (m) =>
        m.id.equals(id) &
        m.tenantId.equals(scope.tenantId) &
        m.deletedAt.equals(null),
    transaction: transaction,
  );
}

/// Gambar denah [area], `null` bila belum diunggah.
Future<FloorImage?> loadFloorImage(
  LakunaStore store,
  CatalogScope scope,
  DiningArea area,
) async {
  final media = await _floorMedia(store.session, scope, area.floorMediaId);
  if (media == null) return null;
  return FloorImage(media: media, bytes: await readMediaFile(store, media));
}

/// Gambar denah semua [areas] yang punya gambar.
Future<Map<UuidValue, FloorImage>> floorImages(
  LakunaStore store,
  CatalogScope scope,
  Iterable<DiningArea> areas,
) async => {
  for (final a in areas) a.id: ?await loadFloorImage(store, scope, a),
};

Future<DiningArea> _area(SyncTx w, CatalogScope scope, UuidValue id) async {
  final area = await DiningArea.db.findFirstRow(
    w.session,
    where: (a) =>
        a.id.equals(id) &
        a.tenantId.equals(scope.tenantId) &
        a.outletId.equals(scope.outletId) &
        a.deletedAt.equals(null),
    transaction: w.transaction,
  );
  if (area == null) throw DiningNotFound();
  return area;
}

/// Mengunggah gambar denah area [areaId] (PNG/JPG/WebP/SVG ≤ 5 MB) dan
/// mengubah area ke mode denah. Gagal dengan [FloorImageInvalid] atau
/// [DiningNotFound].
Future<DiningArea> saveFloorImage(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue areaId,
  required Uint8List bytes,
  required String fileName,
}) async {
  if (bytes.length > FloorLimits.imageBytes) {
    throw const FloorImageInvalid(FloorImageError.tooLarge);
  }
  final header = readFloorImageHeader(bytes);
  if (header == null) throw const FloorImageInvalid(FloorImageError.format);
  return store.write(actor: staffId, (w) async {
    final area = await _area(w, scope, areaId);
    final s = await w.stamp();
    final media = await storeMediaFile(
      w,
      store,
      scope,
      bytes: bytes,
      header: header,
      fileName: fileName,
      kind: MediaKind.floorPlan,
      stamp: s,
      outletId: scope.outletId,
    );
    return w.update(
      area.copyWith(
        floorMediaId: media.id,
        layoutMode: DiningLayoutMode.floor,
        version: area.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  });
}

/// *Simpan tata letak* (1.7d) area [areaId] dalam satu transaksi: mode
/// tata letak, meja di [tables] (yang ber-`id` diperbarui dan dipindah ke
/// area ini, yang baru dibuat di akhir urutan), dan meja [deleted]
/// (soft delete). Meja area ini yang tidak disebut tidak berubah.
///
/// Gagal dengan [DiningNameInvalid] / [FloorTableInvalid] (indeks draf),
/// [DiningInUse] (meja dihapus punya bill terbuka), atau [DiningNotFound].
Future<void> saveFloorLayout(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue areaId,
  required DiningLayoutMode mode,
  required List<FloorTableDraft> tables,
  List<UuidValue> deleted = const [],
}) => store.write(actor: staffId, (w) async {
  final area = await _area(w, scope, areaId);
  final all = await diningTables(store, scope, transaction: w.transaction);
  final byId = {for (final t in all) t.id: t};
  final touched = {
    for (final d in tables)
      if (d.id != null) d.id!,
    ...deleted,
  };
  if (touched.any((id) => !byId.containsKey(id))) throw DiningNotFound();

  // Nama unik per cabang: meja yang tidak disentuh + draf sebelumnya.
  final names = [
    for (final t in all)
      if (!touched.contains(t.id)) t.name,
  ];
  for (final (i, d) in tables.indexed) {
    final error = validateDiningName(
      d.name,
      max: FnbLimits.tableName,
      existing: names,
    );
    if (error != null) throw DiningNameInvalid(error, index: i);
    final invalid = validateFloorTable(
      seats: d.seats,
      width: d.width,
      height: d.height,
      x: d.x,
      y: d.y,
    );
    if (invalid != null) throw FloorTableInvalid(invalid, index: i);
    names.add(d.name.trim());
  }

  for (final id in deleted) {
    final open = await Sale.db.count(
      w.session,
      where: (s) =>
          s.tenantId.equals(scope.tenantId) &
          s.diningTableId.equals(id) &
          s.status.equals(SaleStatus.open) &
          s.deletedAt.equals(null),
      transaction: w.transaction,
    );
    if (open > 0) throw const DiningInUse(openBill: true);
  }

  final s = await w.stamp();
  for (final id in deleted) {
    final t = byId[id]!;
    await w.update(
      t.copyWith(
        deletedAt: s.now,
        version: t.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  }
  var order = all.fold(-1, (m, t) => t.sortOrder > m ? t.sortOrder : m);
  for (final d in tables) {
    final current = d.id == null ? null : byId[d.id]!;
    if (current == null) {
      await w.insert(
        DiningTable(
          tenantId: scope.tenantId,
          outletId: scope.outletId,
          diningAreaId: areaId,
          name: d.name.trim(),
          seats: d.seats,
          sortOrder: ++order,
          shape: d.shape,
          posX: d.x,
          posY: d.y,
          width: d.width,
          height: d.height,
          canMerge: d.canMerge,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: staffId,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      continue;
    }
    final next = current.copyWith(
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
    if (_sameLayout(current, next)) continue;
    await w.update(
      next.copyWith(
        version: current.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  }
  if (area.layoutMode != mode) {
    await w.update(
      area.copyWith(
        layoutMode: mode,
        version: area.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  }
});

bool _sameLayout(DiningTable a, DiningTable b) =>
    a.diningAreaId == b.diningAreaId &&
    a.name == b.name &&
    a.seats == b.seats &&
    a.shape == b.shape &&
    a.posX == b.posX &&
    a.posY == b.posY &&
    a.width == b.width &&
    a.height == b.height &&
    a.canMerge == b.canMerge;
