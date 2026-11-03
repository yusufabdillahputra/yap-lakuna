/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_database/serverpod_database.dart' as _isd;
import '../sales/kitchen_status.dart' as _i2h1um1f;

/// Baris nota. Nama, satuan, dan harga disalin saat jual agar nota lama
/// tidak berubah bila katalog diubah.
abstract class SaleItem
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  SaleItem._({
    _isc.UuidValue? id,
    required this.tenantId,
    required this.saleId,
    required this.variantId,
    this.productUnitId,
    required this.productName,
    required this.variantName,
    required this.unitName,
    required this.factorMilli,
    required this.quantityMilli,
    required this.listPrice,
    required this.unitPrice,
    required this.lineTotal,
    required this.unitCost,
    required this.tracksStock,
    required this.sortOrder,
    this.kitchenStatus,
    this.kitchenTicketId,
    this.note,
    int? modifierDelta,
    this.modifierKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _isc.Uuid().v7obj(),
       modifierDelta = modifierDelta ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory SaleItem({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue saleId,
    required _isc.UuidValue variantId,
    _isc.UuidValue? productUnitId,
    required String productName,
    required String variantName,
    required String unitName,
    required int factorMilli,
    required int quantityMilli,
    required int listPrice,
    required int unitPrice,
    required int lineTotal,
    required int unitCost,
    required bool tracksStock,
    required int sortOrder,
    _i2h1um1f.KitchenStatus? kitchenStatus,
    _isc.UuidValue? kitchenTicketId,
    String? note,
    int? modifierDelta,
    String? modifierKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _SaleItemImpl;

  factory SaleItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return SaleItem(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      saleId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['saleId']),
      variantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['variantId'],
      ),
      productUnitId: jsonSerialization['productUnitId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['productUnitId'],
            ),
      productName: jsonSerialization['productName'] as String,
      variantName: jsonSerialization['variantName'] as String,
      unitName: jsonSerialization['unitName'] as String,
      factorMilli: jsonSerialization['factorMilli'] as int,
      quantityMilli: jsonSerialization['quantityMilli'] as int,
      listPrice: jsonSerialization['listPrice'] as int,
      unitPrice: jsonSerialization['unitPrice'] as int,
      lineTotal: jsonSerialization['lineTotal'] as int,
      unitCost: jsonSerialization['unitCost'] as int,
      tracksStock: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['tracksStock'],
      ),
      sortOrder: jsonSerialization['sortOrder'] as int,
      kitchenStatus: jsonSerialization['kitchenStatus'] == null
          ? null
          : _i2h1um1f.KitchenStatus.fromJson(
              (jsonSerialization['kitchenStatus'] as String),
            ),
      kitchenTicketId: jsonSerialization['kitchenTicketId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['kitchenTicketId'],
            ),
      note: jsonSerialization['note'] as String?,
      modifierDelta: jsonSerialization['modifierDelta'] as int?,
      modifierKey: jsonSerialization['modifierKey'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      createdBy: jsonSerialization['createdBy'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['createdBy'],
            ),
      updatedBy: jsonSerialization['updatedBy'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['updatedBy'],
            ),
      version: jsonSerialization['version'] as int?,
      hlc: jsonSerialization['hlc'] as String,
      originDeviceId: jsonSerialization['originDeviceId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['originDeviceId'],
            ),
    );
  }

  static final t = SaleItemTable();

  static const db = SaleItemRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue saleId;

  _isc.UuidValue variantId;

  /// Satuan konversi; null = satuan dasar.
  _isc.UuidValue? productUnitId;

  String productName;

  String variantName;

  String unitName;

  /// Isi satu satuan baris dalam mili-satuan dasar (1000 = satuan dasar).
  int factorMilli;

  /// Jumlah dalam satuan baris, mili-satuan.
  int quantityMilli;

  /// Harga per satuan baris tanpa grosir dan yang dipakai.
  int listPrice;

  int unitPrice;

  int lineTotal;

  /// Biaya rata-rata per satuan dasar saat jual (HPP).
  int unitCost;

  bool tracksStock;

  int sortOrder;

  /// F&B (F1-10); `null` = penjualan retail.
  _i2h1um1f.KitchenStatus? kitchenStatus;

  _isc.UuidValue? kitchenTicketId;

  /// Catatan dapur, maks 120 karakter.
  String? note;

  /// Σ tambahan harga modifier per satuan baris (F1-10b); line_total =
  /// (unit_price + modifier_delta) × jumlah.
  int modifierDelta;

  /// Id opsi modifier terurut dipisah koma; kunci gabung baris.
  String? modifierKey;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? deletedAt;

  _isc.UuidValue? createdBy;

  _isc.UuidValue? updatedBy;

  int version;

  String hlc;

  _isc.UuidValue? originDeviceId;

  @override
  _isd.Table<_isc.UuidValue> get table => t;

  /// Returns a shallow copy of this [SaleItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SaleItem copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? saleId,
    _isc.UuidValue? variantId,
    _isc.UuidValue? productUnitId = const _isc.$UndefinedUuidValue(),
    String? productName,
    String? variantName,
    String? unitName,
    int? factorMilli,
    int? quantityMilli,
    int? listPrice,
    int? unitPrice,
    int? lineTotal,
    int? unitCost,
    bool? tracksStock,
    int? sortOrder,
    _i2h1um1f.KitchenStatus? kitchenStatus,
    _isc.UuidValue? kitchenTicketId = const _isc.$UndefinedUuidValue(),
    String? note,
    int? modifierDelta,
    String? modifierKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SaleItem',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'saleId': saleId.toJson(),
      'variantId': variantId.toJson(),
      if (productUnitId != null) 'productUnitId': productUnitId?.toJson(),
      'productName': productName,
      'variantName': variantName,
      'unitName': unitName,
      'factorMilli': factorMilli,
      'quantityMilli': quantityMilli,
      'listPrice': listPrice,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
      'unitCost': unitCost,
      'tracksStock': tracksStock,
      'sortOrder': sortOrder,
      if (kitchenStatus != null) 'kitchenStatus': kitchenStatus?.toJson(),
      if (kitchenTicketId != null) 'kitchenTicketId': kitchenTicketId?.toJson(),
      if (note != null) 'note': note,
      'modifierDelta': modifierDelta,
      if (modifierKey != null) 'modifierKey': modifierKey,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (createdBy != null) 'createdBy': createdBy?.toJson(),
      if (updatedBy != null) 'updatedBy': updatedBy?.toJson(),
      'version': version,
      'hlc': hlc,
      if (originDeviceId != null) 'originDeviceId': originDeviceId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SaleItem',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'saleId': saleId.toJson(),
      'variantId': variantId.toJson(),
      if (productUnitId != null) 'productUnitId': productUnitId?.toJson(),
      'productName': productName,
      'variantName': variantName,
      'unitName': unitName,
      'factorMilli': factorMilli,
      'quantityMilli': quantityMilli,
      'listPrice': listPrice,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
      'unitCost': unitCost,
      'tracksStock': tracksStock,
      'sortOrder': sortOrder,
      if (kitchenStatus != null) 'kitchenStatus': kitchenStatus?.toJson(),
      if (kitchenTicketId != null) 'kitchenTicketId': kitchenTicketId?.toJson(),
      if (note != null) 'note': note,
      'modifierDelta': modifierDelta,
      if (modifierKey != null) 'modifierKey': modifierKey,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (createdBy != null) 'createdBy': createdBy?.toJson(),
      if (updatedBy != null) 'updatedBy': updatedBy?.toJson(),
      'version': version,
      'hlc': hlc,
      if (originDeviceId != null) 'originDeviceId': originDeviceId?.toJson(),
    };
  }

  static SaleItemInclude include() {
    return SaleItemInclude._();
  }

  static SaleItemIncludeList includeList({
    _isd.WhereExpressionBuilder<SaleItemTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleItemTable>? orderBy,
    _isd.OrderByListBuilder<SaleItemTable>? orderByList,
    SaleItemInclude? include,
  }) {
    return SaleItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SaleItem.t),
      orderByList: orderByList?.call(SaleItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SaleItemImpl extends SaleItem {
  _SaleItemImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue saleId,
    required _isc.UuidValue variantId,
    _isc.UuidValue? productUnitId,
    required String productName,
    required String variantName,
    required String unitName,
    required int factorMilli,
    required int quantityMilli,
    required int listPrice,
    required int unitPrice,
    required int lineTotal,
    required int unitCost,
    required bool tracksStock,
    required int sortOrder,
    _i2h1um1f.KitchenStatus? kitchenStatus,
    _isc.UuidValue? kitchenTicketId,
    String? note,
    int? modifierDelta,
    String? modifierKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) : super._(
         id: id,
         tenantId: tenantId,
         saleId: saleId,
         variantId: variantId,
         productUnitId: productUnitId,
         productName: productName,
         variantName: variantName,
         unitName: unitName,
         factorMilli: factorMilli,
         quantityMilli: quantityMilli,
         listPrice: listPrice,
         unitPrice: unitPrice,
         lineTotal: lineTotal,
         unitCost: unitCost,
         tracksStock: tracksStock,
         sortOrder: sortOrder,
         kitchenStatus: kitchenStatus,
         kitchenTicketId: kitchenTicketId,
         note: note,
         modifierDelta: modifierDelta,
         modifierKey: modifierKey,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [SaleItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SaleItem copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? saleId,
    _isc.UuidValue? variantId,
    _isc.UuidValue? productUnitId = const _isc.$UndefinedUuidValue(),
    String? productName,
    String? variantName,
    String? unitName,
    int? factorMilli,
    int? quantityMilli,
    int? listPrice,
    int? unitPrice,
    int? lineTotal,
    int? unitCost,
    bool? tracksStock,
    int? sortOrder,
    Object? kitchenStatus = _Undefined,
    _isc.UuidValue? kitchenTicketId = const _isc.$UndefinedUuidValue(),
    Object? note = _Undefined,
    int? modifierDelta,
    Object? modifierKey = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return SaleItem(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      saleId: saleId ?? this.saleId,
      variantId: variantId ?? this.variantId,
      productUnitId: productUnitId is _isc.UndefinedSentinel
          ? this.productUnitId
          : productUnitId,
      productName: productName ?? this.productName,
      variantName: variantName ?? this.variantName,
      unitName: unitName ?? this.unitName,
      factorMilli: factorMilli ?? this.factorMilli,
      quantityMilli: quantityMilli ?? this.quantityMilli,
      listPrice: listPrice ?? this.listPrice,
      unitPrice: unitPrice ?? this.unitPrice,
      lineTotal: lineTotal ?? this.lineTotal,
      unitCost: unitCost ?? this.unitCost,
      tracksStock: tracksStock ?? this.tracksStock,
      sortOrder: sortOrder ?? this.sortOrder,
      kitchenStatus: kitchenStatus is _i2h1um1f.KitchenStatus?
          ? kitchenStatus
          : this.kitchenStatus,
      kitchenTicketId: kitchenTicketId is _isc.UndefinedSentinel
          ? this.kitchenTicketId
          : kitchenTicketId,
      note: note is String? ? note : this.note,
      modifierDelta: modifierDelta ?? this.modifierDelta,
      modifierKey: modifierKey is String? ? modifierKey : this.modifierKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt is _isc.UndefinedSentinel
          ? this.deletedAt
          : deletedAt,
      createdBy: createdBy is _isc.UndefinedSentinel
          ? this.createdBy
          : createdBy,
      updatedBy: updatedBy is _isc.UndefinedSentinel
          ? this.updatedBy
          : updatedBy,
      version: version ?? this.version,
      hlc: hlc ?? this.hlc,
      originDeviceId: originDeviceId is _isc.UndefinedSentinel
          ? this.originDeviceId
          : originDeviceId,
    );
  }
}

class SaleItemUpdateTable extends _isd.UpdateTable<SaleItemTable> {
  SaleItemUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> tenantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.tenantId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> saleId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.saleId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> variantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.variantId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> productUnitId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.productUnitId,
    value,
  );

  _isd.ColumnValue<String, String> productName(String value) =>
      _isd.ColumnValue(
        table.productName,
        value,
      );

  _isd.ColumnValue<String, String> variantName(String value) =>
      _isd.ColumnValue(
        table.variantName,
        value,
      );

  _isd.ColumnValue<String, String> unitName(String value) => _isd.ColumnValue(
    table.unitName,
    value,
  );

  _isd.ColumnValue<int, int> factorMilli(int value) => _isd.ColumnValue(
    table.factorMilli,
    value,
  );

  _isd.ColumnValue<int, int> quantityMilli(int value) => _isd.ColumnValue(
    table.quantityMilli,
    value,
  );

  _isd.ColumnValue<int, int> listPrice(int value) => _isd.ColumnValue(
    table.listPrice,
    value,
  );

  _isd.ColumnValue<int, int> unitPrice(int value) => _isd.ColumnValue(
    table.unitPrice,
    value,
  );

  _isd.ColumnValue<int, int> lineTotal(int value) => _isd.ColumnValue(
    table.lineTotal,
    value,
  );

  _isd.ColumnValue<int, int> unitCost(int value) => _isd.ColumnValue(
    table.unitCost,
    value,
  );

  _isd.ColumnValue<bool, bool> tracksStock(bool value) => _isd.ColumnValue(
    table.tracksStock,
    value,
  );

  _isd.ColumnValue<int, int> sortOrder(int value) => _isd.ColumnValue(
    table.sortOrder,
    value,
  );

  _isd.ColumnValue<_i2h1um1f.KitchenStatus, _i2h1um1f.KitchenStatus>
  kitchenStatus(_i2h1um1f.KitchenStatus? value) => _isd.ColumnValue(
    table.kitchenStatus,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> kitchenTicketId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.kitchenTicketId,
    value,
  );

  _isd.ColumnValue<String, String> note(String? value) => _isd.ColumnValue(
    table.note,
    value,
  );

  _isd.ColumnValue<int, int> modifierDelta(int value) => _isd.ColumnValue(
    table.modifierDelta,
    value,
  );

  _isd.ColumnValue<String, String> modifierKey(String? value) =>
      _isd.ColumnValue(
        table.modifierKey,
        value,
      );

  _isd.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _isd.ColumnValue(
        table.createdAt,
        value,
      );

  _isd.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _isd.ColumnValue(
        table.updatedAt,
        value,
      );

  _isd.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _isd.ColumnValue(
        table.deletedAt,
        value,
      );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> createdBy(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.createdBy,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> updatedBy(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.updatedBy,
    value,
  );

  _isd.ColumnValue<int, int> version(int value) => _isd.ColumnValue(
    table.version,
    value,
  );

  _isd.ColumnValue<String, String> hlc(String value) => _isd.ColumnValue(
    table.hlc,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> originDeviceId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.originDeviceId,
    value,
  );
}

class SaleItemTable extends _isd.Table<_isc.UuidValue> {
  SaleItemTable({super.tableRelation}) : super(tableName: 'sale_items') {
    updateTable = SaleItemUpdateTable(this);
    tenantId = _isd.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    saleId = _isd.ColumnUuid(
      'sale_id',
      this,
      fieldName: 'saleId',
    );
    variantId = _isd.ColumnUuid(
      'variant_id',
      this,
      fieldName: 'variantId',
    );
    productUnitId = _isd.ColumnUuid(
      'product_unit_id',
      this,
      fieldName: 'productUnitId',
    );
    productName = _isd.ColumnString(
      'product_name',
      this,
      fieldName: 'productName',
    );
    variantName = _isd.ColumnString(
      'variant_name',
      this,
      fieldName: 'variantName',
    );
    unitName = _isd.ColumnString(
      'unit_name',
      this,
      fieldName: 'unitName',
    );
    factorMilli = _isd.ColumnInt(
      'factor_milli',
      this,
      fieldName: 'factorMilli',
    );
    quantityMilli = _isd.ColumnInt(
      'quantity_milli',
      this,
      fieldName: 'quantityMilli',
    );
    listPrice = _isd.ColumnInt(
      'list_price',
      this,
      fieldName: 'listPrice',
    );
    unitPrice = _isd.ColumnInt(
      'unit_price',
      this,
      fieldName: 'unitPrice',
    );
    lineTotal = _isd.ColumnInt(
      'line_total',
      this,
      fieldName: 'lineTotal',
    );
    unitCost = _isd.ColumnInt(
      'unit_cost',
      this,
      fieldName: 'unitCost',
    );
    tracksStock = _isd.ColumnBool(
      'tracks_stock',
      this,
      fieldName: 'tracksStock',
    );
    sortOrder = _isd.ColumnInt(
      'sort_order',
      this,
      fieldName: 'sortOrder',
    );
    kitchenStatus = _isd.ColumnEnum(
      'kitchen_status',
      this,
      _isd.EnumSerialization.byName,
      fieldName: 'kitchenStatus',
    );
    kitchenTicketId = _isd.ColumnUuid(
      'kitchen_ticket_id',
      this,
      fieldName: 'kitchenTicketId',
    );
    note = _isd.ColumnString(
      'note',
      this,
    );
    modifierDelta = _isd.ColumnInt(
      'modifier_delta',
      this,
      hasDefault: true,
      fieldName: 'modifierDelta',
    );
    modifierKey = _isd.ColumnString(
      'modifier_key',
      this,
      fieldName: 'modifierKey',
    );
    createdAt = _isd.ColumnDateTime(
      'created_at',
      this,
      hasDefault: true,
      fieldName: 'createdAt',
    );
    updatedAt = _isd.ColumnDateTime(
      'updated_at',
      this,
      hasDefault: true,
      fieldName: 'updatedAt',
    );
    deletedAt = _isd.ColumnDateTime(
      'deleted_at',
      this,
      fieldName: 'deletedAt',
    );
    createdBy = _isd.ColumnUuid(
      'created_by',
      this,
      fieldName: 'createdBy',
    );
    updatedBy = _isd.ColumnUuid(
      'updated_by',
      this,
      fieldName: 'updatedBy',
    );
    version = _isd.ColumnInt(
      'version',
      this,
      hasDefault: true,
    );
    hlc = _isd.ColumnString(
      'hlc',
      this,
    );
    originDeviceId = _isd.ColumnUuid(
      'origin_device_id',
      this,
      fieldName: 'originDeviceId',
    );
  }

  late final SaleItemUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid saleId;

  late final _isd.ColumnUuid variantId;

  /// Satuan konversi; null = satuan dasar.
  late final _isd.ColumnUuid productUnitId;

  late final _isd.ColumnString productName;

  late final _isd.ColumnString variantName;

  late final _isd.ColumnString unitName;

  /// Isi satu satuan baris dalam mili-satuan dasar (1000 = satuan dasar).
  late final _isd.ColumnInt factorMilli;

  /// Jumlah dalam satuan baris, mili-satuan.
  late final _isd.ColumnInt quantityMilli;

  /// Harga per satuan baris tanpa grosir dan yang dipakai.
  late final _isd.ColumnInt listPrice;

  late final _isd.ColumnInt unitPrice;

  late final _isd.ColumnInt lineTotal;

  /// Biaya rata-rata per satuan dasar saat jual (HPP).
  late final _isd.ColumnInt unitCost;

  late final _isd.ColumnBool tracksStock;

  late final _isd.ColumnInt sortOrder;

  /// F&B (F1-10); `null` = penjualan retail.
  late final _isd.ColumnEnum<_i2h1um1f.KitchenStatus> kitchenStatus;

  late final _isd.ColumnUuid kitchenTicketId;

  /// Catatan dapur, maks 120 karakter.
  late final _isd.ColumnString note;

  /// Σ tambahan harga modifier per satuan baris (F1-10b); line_total =
  /// (unit_price + modifier_delta) × jumlah.
  late final _isd.ColumnInt modifierDelta;

  /// Id opsi modifier terurut dipisah koma; kunci gabung baris.
  late final _isd.ColumnString modifierKey;

  late final _isd.ColumnDateTime createdAt;

  late final _isd.ColumnDateTime updatedAt;

  late final _isd.ColumnDateTime deletedAt;

  late final _isd.ColumnUuid createdBy;

  late final _isd.ColumnUuid updatedBy;

  late final _isd.ColumnInt version;

  late final _isd.ColumnString hlc;

  late final _isd.ColumnUuid originDeviceId;

  @override
  List<_isd.Column> get columns => [
    id,
    tenantId,
    saleId,
    variantId,
    productUnitId,
    productName,
    variantName,
    unitName,
    factorMilli,
    quantityMilli,
    listPrice,
    unitPrice,
    lineTotal,
    unitCost,
    tracksStock,
    sortOrder,
    kitchenStatus,
    kitchenTicketId,
    note,
    modifierDelta,
    modifierKey,
    createdAt,
    updatedAt,
    deletedAt,
    createdBy,
    updatedBy,
    version,
    hlc,
    originDeviceId,
  ];
}

class SaleItemInclude extends _isd.IncludeObject {
  SaleItemInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => SaleItem.t;
}

class SaleItemIncludeList extends _isd.IncludeList {
  SaleItemIncludeList._({
    _isd.WhereExpressionBuilder<SaleItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SaleItem.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => SaleItem.t;
}

class SaleItemRepository {
  const SaleItemRepository._();

  /// Returns a list of [SaleItem]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<SaleItem>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleItemTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleItemTable>? orderBy,
    _isd.OrderByListBuilder<SaleItemTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SaleItem>(
      where: where?.call(SaleItem.t),
      orderBy: orderBy?.call(SaleItem.t),
      orderByList: orderByList?.call(SaleItem.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [SaleItem]s matching the given query parameters every time the
  /// source tables are modified.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// Use [throttle] to specify the minimum interval between queries. It can
  /// also be set to `null`, in which case the stream will only be throttled
  /// when its subscription is paused.
  ///
  /// Source tables are collected from the queried table, [where], [orderBy],
  /// [orderByList], and the [include] graph. [alsoTriggerOnTables] is added
  /// to that set. Pass [Table] instances such as `SaleItem.t`.
  ///
  /// Raw [Expression] SQL is not inspected. Tables referenced only in raw
  /// SQL must be passed via [alsoTriggerOnTables].
  ///
  /// The stream always reads committed state and never joins an ambient
  /// [Transaction]. Emissions for a write fire after that write commits.
  ///
  /// Currently only supported on SQLite. Calling this method on PostgreSQL
  /// throws an [UnsupportedError].
  ///
  /// ```dart
  /// var subscription = Persons.db.watch(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// ).listen((persons) {
  ///   // Handle the latest matching rows.
  /// });
  /// ```
  _ida.Stream<List<SaleItem>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleItemTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleItemTable>? orderBy,
    _isd.OrderByListBuilder<SaleItemTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<SaleItem>(
      where: where?.call(SaleItem.t),
      orderBy: orderBy?.call(SaleItem.t),
      orderByList: orderByList?.call(SaleItem.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [SaleItem] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<SaleItem?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleItemTable>? where,
    int? offset,
    _isd.OrderByBuilder<SaleItemTable>? orderBy,
    _isd.OrderByListBuilder<SaleItemTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SaleItem>(
      where: where?.call(SaleItem.t),
      orderBy: orderBy?.call(SaleItem.t),
      orderByList: orderByList?.call(SaleItem.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SaleItem] by its [id] or null if no such row exists.
  Future<SaleItem?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SaleItem>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SaleItem]s in the list and returns the inserted rows.
  ///
  /// The returned [SaleItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleItem>> insert(
    _isd.DatabaseSession session,
    List<SaleItem> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SaleItem>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SaleItem] and returns the inserted row.
  ///
  /// The returned [SaleItem] will have its `id` field set.
  Future<SaleItem> insertRow(
    _isd.DatabaseSession session,
    SaleItem row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<SaleItem>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SaleItem]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [SaleItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleItem>> upsert(
    _isd.DatabaseSession session,
    List<SaleItem> rows, {
    required _isd.ColumnSelections<SaleItemTable> conflictColumns,
    _isd.ColumnSelections<SaleItemTable>? updateColumns,
    _isd.WhereExpressionBuilder<SaleItemTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SaleItem>(
      rows,
      conflictColumns: conflictColumns(SaleItem.t),
      updateColumns: updateColumns?.call(SaleItem.t),
      updateWhere: updateWhere?.call(SaleItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SaleItem] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [SaleItem] will have its `id` field set.
  Future<SaleItem?> upsertRow(
    _isd.DatabaseSession session,
    SaleItem row, {
    required _isd.ColumnSelections<SaleItemTable> conflictColumns,
    _isd.ColumnSelections<SaleItemTable>? updateColumns,
    _isd.WhereExpressionBuilder<SaleItemTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SaleItem>(
      row,
      conflictColumns: conflictColumns(SaleItem.t),
      updateColumns: updateColumns?.call(SaleItem.t),
      updateWhere: updateWhere?.call(SaleItem.t),
      transaction: transaction,
    );
  }

  /// Updates all [SaleItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleItem>> update(
    _isd.DatabaseSession session,
    List<SaleItem> rows, {
    _isd.ColumnSelections<SaleItemTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SaleItem>(
      rows,
      columns: columns?.call(SaleItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SaleItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SaleItem> updateRow(
    _isd.DatabaseSession session,
    SaleItem row, {
    _isd.ColumnSelections<SaleItemTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<SaleItem>(
      row,
      columns: columns?.call(SaleItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SaleItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SaleItem?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<SaleItemUpdateTable> columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<SaleItem>(
      id,
      columnValues: columnValues(SaleItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SaleItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleItem>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<SaleItemUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<SaleItemTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleItemTable>? orderBy,
    _isd.OrderByListBuilder<SaleItemTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SaleItem>(
      columnValues: columnValues(SaleItem.t.updateTable),
      where: where(SaleItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SaleItem.t),
      orderByList: orderByList?.call(SaleItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SaleItem]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleItem>> delete(
    _isd.DatabaseSession session,
    List<SaleItem> rows, {
    _isd.OrderByBuilder<SaleItemTable>? orderBy,
    _isd.OrderByListBuilder<SaleItemTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SaleItem>(
      rows,
      orderBy: orderBy?.call(SaleItem.t),
      orderByList: orderByList?.call(SaleItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SaleItem].
  Future<SaleItem> deleteRow(
    _isd.DatabaseSession session,
    SaleItem row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SaleItem>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleItem>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<SaleItemTable> where,
    _isd.OrderByBuilder<SaleItemTable>? orderBy,
    _isd.OrderByListBuilder<SaleItemTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SaleItem>(
      where: where(SaleItem.t),
      orderBy: orderBy?.call(SaleItem.t),
      orderByList: orderByList?.call(SaleItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleItemTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<SaleItem>(
      where: where?.call(SaleItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SaleItem] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<SaleItemTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SaleItem>(
      where: where(SaleItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
