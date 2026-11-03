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
import 'package:serverpod/serverpod.dart' as _is;
import '../sales/kitchen_status.dart' as _i2h1um1f;

/// Baris nota. Nama, satuan, dan harga disalin saat jual agar nota lama
/// tidak berubah bila katalog diubah.
abstract class SaleItem
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  SaleItem._({
    _is.UuidValue? id,
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
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _is.Uuid().v7obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory SaleItem({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue saleId,
    required _is.UuidValue variantId,
    _is.UuidValue? productUnitId,
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
    _is.UuidValue? kitchenTicketId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _SaleItemImpl;

  factory SaleItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return SaleItem(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      saleId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['saleId']),
      variantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['variantId'],
      ),
      productUnitId: jsonSerialization['productUnitId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
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
      tracksStock: _is.BoolJsonExtension.fromJson(
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
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['kitchenTicketId'],
            ),
      note: jsonSerialization['note'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      createdBy: jsonSerialization['createdBy'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['createdBy']),
      updatedBy: jsonSerialization['updatedBy'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['updatedBy']),
      version: jsonSerialization['version'] as int?,
      hlc: jsonSerialization['hlc'] as String,
      originDeviceId: jsonSerialization['originDeviceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['originDeviceId'],
            ),
    );
  }

  static final t = SaleItemTable();

  static const db = SaleItemRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue saleId;

  _is.UuidValue variantId;

  /// Satuan konversi; null = satuan dasar.
  _is.UuidValue? productUnitId;

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

  _is.UuidValue? kitchenTicketId;

  /// Catatan dapur, maks 120 karakter.
  String? note;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? deletedAt;

  _is.UuidValue? createdBy;

  _is.UuidValue? updatedBy;

  int version;

  String hlc;

  _is.UuidValue? originDeviceId;

  @override
  _is.Table<_is.UuidValue> get table => t;

  /// Returns a shallow copy of this [SaleItem]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SaleItem copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? saleId,
    _is.UuidValue? variantId,
    _is.UuidValue? productUnitId = const _is.$UndefinedUuidValue(),
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
    _is.UuidValue? kitchenTicketId = const _is.$UndefinedUuidValue(),
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
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
    _is.WhereExpressionBuilder<SaleItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleItemTable>? orderBy,
    _is.OrderByListBuilder<SaleItemTable>? orderByList,
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
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SaleItemImpl extends SaleItem {
  _SaleItemImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue saleId,
    required _is.UuidValue variantId,
    _is.UuidValue? productUnitId,
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
    _is.UuidValue? kitchenTicketId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
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
  @_is.useResult
  @override
  SaleItem copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? saleId,
    _is.UuidValue? variantId,
    _is.UuidValue? productUnitId = const _is.$UndefinedUuidValue(),
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
    _is.UuidValue? kitchenTicketId = const _is.$UndefinedUuidValue(),
    Object? note = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return SaleItem(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      saleId: saleId ?? this.saleId,
      variantId: variantId ?? this.variantId,
      productUnitId: productUnitId is _is.UndefinedSentinel
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
      kitchenTicketId: kitchenTicketId is _is.UndefinedSentinel
          ? this.kitchenTicketId
          : kitchenTicketId,
      note: note is String? ? note : this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt is _is.UndefinedSentinel
          ? this.deletedAt
          : deletedAt,
      createdBy: createdBy is _is.UndefinedSentinel
          ? this.createdBy
          : createdBy,
      updatedBy: updatedBy is _is.UndefinedSentinel
          ? this.updatedBy
          : updatedBy,
      version: version ?? this.version,
      hlc: hlc ?? this.hlc,
      originDeviceId: originDeviceId is _is.UndefinedSentinel
          ? this.originDeviceId
          : originDeviceId,
    );
  }
}

class SaleItemUpdateTable extends _is.UpdateTable<SaleItemTable> {
  SaleItemUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> saleId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.saleId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> variantId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.variantId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> productUnitId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.productUnitId,
    value,
  );

  _is.ColumnValue<String, String> productName(String value) => _is.ColumnValue(
    table.productName,
    value,
  );

  _is.ColumnValue<String, String> variantName(String value) => _is.ColumnValue(
    table.variantName,
    value,
  );

  _is.ColumnValue<String, String> unitName(String value) => _is.ColumnValue(
    table.unitName,
    value,
  );

  _is.ColumnValue<int, int> factorMilli(int value) => _is.ColumnValue(
    table.factorMilli,
    value,
  );

  _is.ColumnValue<int, int> quantityMilli(int value) => _is.ColumnValue(
    table.quantityMilli,
    value,
  );

  _is.ColumnValue<int, int> listPrice(int value) => _is.ColumnValue(
    table.listPrice,
    value,
  );

  _is.ColumnValue<int, int> unitPrice(int value) => _is.ColumnValue(
    table.unitPrice,
    value,
  );

  _is.ColumnValue<int, int> lineTotal(int value) => _is.ColumnValue(
    table.lineTotal,
    value,
  );

  _is.ColumnValue<int, int> unitCost(int value) => _is.ColumnValue(
    table.unitCost,
    value,
  );

  _is.ColumnValue<bool, bool> tracksStock(bool value) => _is.ColumnValue(
    table.tracksStock,
    value,
  );

  _is.ColumnValue<int, int> sortOrder(int value) => _is.ColumnValue(
    table.sortOrder,
    value,
  );

  _is.ColumnValue<_i2h1um1f.KitchenStatus, _i2h1um1f.KitchenStatus>
  kitchenStatus(_i2h1um1f.KitchenStatus? value) => _is.ColumnValue(
    table.kitchenStatus,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> kitchenTicketId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.kitchenTicketId,
    value,
  );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _is.ColumnValue(
        table.deletedAt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> createdBy(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.createdBy,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> updatedBy(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.updatedBy,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
    value,
  );

  _is.ColumnValue<String, String> hlc(String value) => _is.ColumnValue(
    table.hlc,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> originDeviceId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.originDeviceId,
    value,
  );
}

class SaleItemTable extends _is.Table<_is.UuidValue> {
  SaleItemTable({super.tableRelation}) : super(tableName: 'sale_items') {
    updateTable = SaleItemUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    saleId = _is.ColumnUuid(
      'sale_id',
      this,
      fieldName: 'saleId',
    );
    variantId = _is.ColumnUuid(
      'variant_id',
      this,
      fieldName: 'variantId',
    );
    productUnitId = _is.ColumnUuid(
      'product_unit_id',
      this,
      fieldName: 'productUnitId',
    );
    productName = _is.ColumnString(
      'product_name',
      this,
      fieldName: 'productName',
    );
    variantName = _is.ColumnString(
      'variant_name',
      this,
      fieldName: 'variantName',
    );
    unitName = _is.ColumnString(
      'unit_name',
      this,
      fieldName: 'unitName',
    );
    factorMilli = _is.ColumnInt(
      'factor_milli',
      this,
      fieldName: 'factorMilli',
    );
    quantityMilli = _is.ColumnInt(
      'quantity_milli',
      this,
      fieldName: 'quantityMilli',
    );
    listPrice = _is.ColumnInt(
      'list_price',
      this,
      fieldName: 'listPrice',
    );
    unitPrice = _is.ColumnInt(
      'unit_price',
      this,
      fieldName: 'unitPrice',
    );
    lineTotal = _is.ColumnInt(
      'line_total',
      this,
      fieldName: 'lineTotal',
    );
    unitCost = _is.ColumnInt(
      'unit_cost',
      this,
      fieldName: 'unitCost',
    );
    tracksStock = _is.ColumnBool(
      'tracks_stock',
      this,
      fieldName: 'tracksStock',
    );
    sortOrder = _is.ColumnInt(
      'sort_order',
      this,
      fieldName: 'sortOrder',
    );
    kitchenStatus = _is.ColumnEnum(
      'kitchen_status',
      this,
      _is.EnumSerialization.byName,
      fieldName: 'kitchenStatus',
    );
    kitchenTicketId = _is.ColumnUuid(
      'kitchen_ticket_id',
      this,
      fieldName: 'kitchenTicketId',
    );
    note = _is.ColumnString(
      'note',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'created_at',
      this,
      hasDefault: true,
      fieldName: 'createdAt',
    );
    updatedAt = _is.ColumnDateTime(
      'updated_at',
      this,
      hasDefault: true,
      fieldName: 'updatedAt',
    );
    deletedAt = _is.ColumnDateTime(
      'deleted_at',
      this,
      fieldName: 'deletedAt',
    );
    createdBy = _is.ColumnUuid(
      'created_by',
      this,
      fieldName: 'createdBy',
    );
    updatedBy = _is.ColumnUuid(
      'updated_by',
      this,
      fieldName: 'updatedBy',
    );
    version = _is.ColumnInt(
      'version',
      this,
      hasDefault: true,
    );
    hlc = _is.ColumnString(
      'hlc',
      this,
    );
    originDeviceId = _is.ColumnUuid(
      'origin_device_id',
      this,
      fieldName: 'originDeviceId',
    );
  }

  late final SaleItemUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid saleId;

  late final _is.ColumnUuid variantId;

  /// Satuan konversi; null = satuan dasar.
  late final _is.ColumnUuid productUnitId;

  late final _is.ColumnString productName;

  late final _is.ColumnString variantName;

  late final _is.ColumnString unitName;

  /// Isi satu satuan baris dalam mili-satuan dasar (1000 = satuan dasar).
  late final _is.ColumnInt factorMilli;

  /// Jumlah dalam satuan baris, mili-satuan.
  late final _is.ColumnInt quantityMilli;

  /// Harga per satuan baris tanpa grosir dan yang dipakai.
  late final _is.ColumnInt listPrice;

  late final _is.ColumnInt unitPrice;

  late final _is.ColumnInt lineTotal;

  /// Biaya rata-rata per satuan dasar saat jual (HPP).
  late final _is.ColumnInt unitCost;

  late final _is.ColumnBool tracksStock;

  late final _is.ColumnInt sortOrder;

  /// F&B (F1-10); `null` = penjualan retail.
  late final _is.ColumnEnum<_i2h1um1f.KitchenStatus> kitchenStatus;

  late final _is.ColumnUuid kitchenTicketId;

  /// Catatan dapur, maks 120 karakter.
  late final _is.ColumnString note;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnDateTime deletedAt;

  late final _is.ColumnUuid createdBy;

  late final _is.ColumnUuid updatedBy;

  late final _is.ColumnInt version;

  late final _is.ColumnString hlc;

  late final _is.ColumnUuid originDeviceId;

  @override
  List<_is.Column> get columns => [
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

class SaleItemInclude extends _is.IncludeObject {
  SaleItemInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => SaleItem.t;
}

class SaleItemIncludeList extends _is.IncludeList {
  SaleItemIncludeList._({
    _is.WhereExpressionBuilder<SaleItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SaleItem.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => SaleItem.t;
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleItemTable>? orderBy,
    _is.OrderByListBuilder<SaleItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleItemTable>? orderBy,
    _is.OrderByListBuilder<SaleItemTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleItemTable>? where,
    int? offset,
    _is.OrderByBuilder<SaleItemTable>? orderBy,
    _is.OrderByListBuilder<SaleItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session,
    List<SaleItem> rows, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    SaleItem row, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<SaleItem> rows, {
    required _is.ColumnSelections<SaleItemTable> conflictColumns,
    _is.ColumnSelections<SaleItemTable>? updateColumns,
    _is.WhereExpressionBuilder<SaleItemTable>? updateWhere,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    SaleItem row, {
    required _is.ColumnSelections<SaleItemTable> conflictColumns,
    _is.ColumnSelections<SaleItemTable>? updateColumns,
    _is.WhereExpressionBuilder<SaleItemTable>? updateWhere,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<SaleItem> rows, {
    _is.ColumnSelections<SaleItemTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    SaleItem row, {
    _is.ColumnSelections<SaleItemTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<SaleItemUpdateTable> columnValues,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SaleItemUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SaleItemTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleItemTable>? orderBy,
    _is.OrderByListBuilder<SaleItemTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<SaleItem> rows, {
    _is.OrderByBuilder<SaleItemTable>? orderBy,
    _is.OrderByListBuilder<SaleItemTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    SaleItem row, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SaleItemTable> where,
    _is.OrderByBuilder<SaleItemTable>? orderBy,
    _is.OrderByListBuilder<SaleItemTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleItemTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SaleItem>(
      where: where?.call(SaleItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SaleItem] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SaleItemTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SaleItem>(
      where: where(SaleItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
