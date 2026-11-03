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

/// Baris pembelian (F1-12). Qty dan harga dalam satuan baris; isi
/// `factor_milli` dan harga pokok mendarat per satuan dasar disalin agar
/// retur memakai angka saat pembelian. `avg_cost_before/after` diisi saat
/// barang diterima (HPP rata-rata lokasi, satuan dasar).
abstract class PurchaseItem
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  PurchaseItem._({
    _isc.UuidValue? id,
    required this.tenantId,
    required this.purchaseId,
    required this.variantId,
    this.productUnitId,
    required this.productName,
    required this.variantName,
    required this.unitName,
    required this.factorMilli,
    required this.quantityMilli,
    required this.unitPrice,
    required this.lineTotal,
    required this.landedUnitCost,
    this.avgCostBefore,
    this.avgCostAfter,
    this.sellPriceBefore,
    required this.sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _isc.Uuid().v7obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory PurchaseItem({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue purchaseId,
    required _isc.UuidValue variantId,
    _isc.UuidValue? productUnitId,
    required String productName,
    required String variantName,
    required String unitName,
    required int factorMilli,
    required int quantityMilli,
    required int unitPrice,
    required int lineTotal,
    required int landedUnitCost,
    int? avgCostBefore,
    int? avgCostAfter,
    int? sellPriceBefore,
    required int sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _PurchaseItemImpl;

  factory PurchaseItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return PurchaseItem(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      purchaseId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['purchaseId'],
      ),
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
      unitPrice: jsonSerialization['unitPrice'] as int,
      lineTotal: jsonSerialization['lineTotal'] as int,
      landedUnitCost: jsonSerialization['landedUnitCost'] as int,
      avgCostBefore: jsonSerialization['avgCostBefore'] as int?,
      avgCostAfter: jsonSerialization['avgCostAfter'] as int?,
      sellPriceBefore: jsonSerialization['sellPriceBefore'] as int?,
      sortOrder: jsonSerialization['sortOrder'] as int,
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

  static final t = PurchaseItemTable();

  static const db = PurchaseItemRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue purchaseId;

  _isc.UuidValue variantId;

  _isc.UuidValue? productUnitId;

  String productName;

  String variantName;

  String unitName;

  int factorMilli;

  int quantityMilli;

  int unitPrice;

  int lineTotal;

  int landedUnitCost;

  int? avgCostBefore;

  int? avgCostAfter;

  int? sellPriceBefore;

  int sortOrder;

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

  /// Returns a shallow copy of this [PurchaseItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PurchaseItem copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? purchaseId,
    _isc.UuidValue? variantId,
    _isc.UuidValue? productUnitId = const _isc.$UndefinedUuidValue(),
    String? productName,
    String? variantName,
    String? unitName,
    int? factorMilli,
    int? quantityMilli,
    int? unitPrice,
    int? lineTotal,
    int? landedUnitCost,
    int? avgCostBefore,
    int? avgCostAfter,
    int? sellPriceBefore,
    int? sortOrder,
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
      '__className__': 'PurchaseItem',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'purchaseId': purchaseId.toJson(),
      'variantId': variantId.toJson(),
      if (productUnitId != null) 'productUnitId': productUnitId?.toJson(),
      'productName': productName,
      'variantName': variantName,
      'unitName': unitName,
      'factorMilli': factorMilli,
      'quantityMilli': quantityMilli,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
      'landedUnitCost': landedUnitCost,
      if (avgCostBefore != null) 'avgCostBefore': avgCostBefore,
      if (avgCostAfter != null) 'avgCostAfter': avgCostAfter,
      if (sellPriceBefore != null) 'sellPriceBefore': sellPriceBefore,
      'sortOrder': sortOrder,
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
      '__className__': 'PurchaseItem',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'purchaseId': purchaseId.toJson(),
      'variantId': variantId.toJson(),
      if (productUnitId != null) 'productUnitId': productUnitId?.toJson(),
      'productName': productName,
      'variantName': variantName,
      'unitName': unitName,
      'factorMilli': factorMilli,
      'quantityMilli': quantityMilli,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
      'landedUnitCost': landedUnitCost,
      if (avgCostBefore != null) 'avgCostBefore': avgCostBefore,
      if (avgCostAfter != null) 'avgCostAfter': avgCostAfter,
      if (sellPriceBefore != null) 'sellPriceBefore': sellPriceBefore,
      'sortOrder': sortOrder,
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

  static PurchaseItemInclude include() {
    return PurchaseItemInclude._();
  }

  static PurchaseItemIncludeList includeList({
    _isd.WhereExpressionBuilder<PurchaseItemTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<PurchaseItemTable>? orderBy,
    _isd.OrderByListBuilder<PurchaseItemTable>? orderByList,
    PurchaseItemInclude? include,
  }) {
    return PurchaseItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PurchaseItem.t),
      orderByList: orderByList?.call(PurchaseItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PurchaseItemImpl extends PurchaseItem {
  _PurchaseItemImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue purchaseId,
    required _isc.UuidValue variantId,
    _isc.UuidValue? productUnitId,
    required String productName,
    required String variantName,
    required String unitName,
    required int factorMilli,
    required int quantityMilli,
    required int unitPrice,
    required int lineTotal,
    required int landedUnitCost,
    int? avgCostBefore,
    int? avgCostAfter,
    int? sellPriceBefore,
    required int sortOrder,
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
         purchaseId: purchaseId,
         variantId: variantId,
         productUnitId: productUnitId,
         productName: productName,
         variantName: variantName,
         unitName: unitName,
         factorMilli: factorMilli,
         quantityMilli: quantityMilli,
         unitPrice: unitPrice,
         lineTotal: lineTotal,
         landedUnitCost: landedUnitCost,
         avgCostBefore: avgCostBefore,
         avgCostAfter: avgCostAfter,
         sellPriceBefore: sellPriceBefore,
         sortOrder: sortOrder,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [PurchaseItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PurchaseItem copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? purchaseId,
    _isc.UuidValue? variantId,
    _isc.UuidValue? productUnitId = const _isc.$UndefinedUuidValue(),
    String? productName,
    String? variantName,
    String? unitName,
    int? factorMilli,
    int? quantityMilli,
    int? unitPrice,
    int? lineTotal,
    int? landedUnitCost,
    Object? avgCostBefore = _Undefined,
    Object? avgCostAfter = _Undefined,
    Object? sellPriceBefore = _Undefined,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      purchaseId: purchaseId ?? this.purchaseId,
      variantId: variantId ?? this.variantId,
      productUnitId: productUnitId is _isc.UndefinedSentinel
          ? this.productUnitId
          : productUnitId,
      productName: productName ?? this.productName,
      variantName: variantName ?? this.variantName,
      unitName: unitName ?? this.unitName,
      factorMilli: factorMilli ?? this.factorMilli,
      quantityMilli: quantityMilli ?? this.quantityMilli,
      unitPrice: unitPrice ?? this.unitPrice,
      lineTotal: lineTotal ?? this.lineTotal,
      landedUnitCost: landedUnitCost ?? this.landedUnitCost,
      avgCostBefore: avgCostBefore is int? ? avgCostBefore : this.avgCostBefore,
      avgCostAfter: avgCostAfter is int? ? avgCostAfter : this.avgCostAfter,
      sellPriceBefore: sellPriceBefore is int?
          ? sellPriceBefore
          : this.sellPriceBefore,
      sortOrder: sortOrder ?? this.sortOrder,
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

class PurchaseItemUpdateTable extends _isd.UpdateTable<PurchaseItemTable> {
  PurchaseItemUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> tenantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.tenantId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> purchaseId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.purchaseId,
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

  _isd.ColumnValue<int, int> unitPrice(int value) => _isd.ColumnValue(
    table.unitPrice,
    value,
  );

  _isd.ColumnValue<int, int> lineTotal(int value) => _isd.ColumnValue(
    table.lineTotal,
    value,
  );

  _isd.ColumnValue<int, int> landedUnitCost(int value) => _isd.ColumnValue(
    table.landedUnitCost,
    value,
  );

  _isd.ColumnValue<int, int> avgCostBefore(int? value) => _isd.ColumnValue(
    table.avgCostBefore,
    value,
  );

  _isd.ColumnValue<int, int> avgCostAfter(int? value) => _isd.ColumnValue(
    table.avgCostAfter,
    value,
  );

  _isd.ColumnValue<int, int> sellPriceBefore(int? value) => _isd.ColumnValue(
    table.sellPriceBefore,
    value,
  );

  _isd.ColumnValue<int, int> sortOrder(int value) => _isd.ColumnValue(
    table.sortOrder,
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

class PurchaseItemTable extends _isd.Table<_isc.UuidValue> {
  PurchaseItemTable({super.tableRelation})
    : super(tableName: 'purchase_items') {
    updateTable = PurchaseItemUpdateTable(this);
    tenantId = _isd.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    purchaseId = _isd.ColumnUuid(
      'purchase_id',
      this,
      fieldName: 'purchaseId',
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
    landedUnitCost = _isd.ColumnInt(
      'landed_unit_cost',
      this,
      fieldName: 'landedUnitCost',
    );
    avgCostBefore = _isd.ColumnInt(
      'avg_cost_before',
      this,
      fieldName: 'avgCostBefore',
    );
    avgCostAfter = _isd.ColumnInt(
      'avg_cost_after',
      this,
      fieldName: 'avgCostAfter',
    );
    sellPriceBefore = _isd.ColumnInt(
      'sell_price_before',
      this,
      fieldName: 'sellPriceBefore',
    );
    sortOrder = _isd.ColumnInt(
      'sort_order',
      this,
      fieldName: 'sortOrder',
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

  late final PurchaseItemUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid purchaseId;

  late final _isd.ColumnUuid variantId;

  late final _isd.ColumnUuid productUnitId;

  late final _isd.ColumnString productName;

  late final _isd.ColumnString variantName;

  late final _isd.ColumnString unitName;

  late final _isd.ColumnInt factorMilli;

  late final _isd.ColumnInt quantityMilli;

  late final _isd.ColumnInt unitPrice;

  late final _isd.ColumnInt lineTotal;

  late final _isd.ColumnInt landedUnitCost;

  late final _isd.ColumnInt avgCostBefore;

  late final _isd.ColumnInt avgCostAfter;

  late final _isd.ColumnInt sellPriceBefore;

  late final _isd.ColumnInt sortOrder;

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
    purchaseId,
    variantId,
    productUnitId,
    productName,
    variantName,
    unitName,
    factorMilli,
    quantityMilli,
    unitPrice,
    lineTotal,
    landedUnitCost,
    avgCostBefore,
    avgCostAfter,
    sellPriceBefore,
    sortOrder,
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

class PurchaseItemInclude extends _isd.IncludeObject {
  PurchaseItemInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => PurchaseItem.t;
}

class PurchaseItemIncludeList extends _isd.IncludeList {
  PurchaseItemIncludeList._({
    _isd.WhereExpressionBuilder<PurchaseItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PurchaseItem.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => PurchaseItem.t;
}

class PurchaseItemRepository {
  const PurchaseItemRepository._();

  /// Returns a list of [PurchaseItem]s matching the given query parameters.
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
  Future<List<PurchaseItem>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<PurchaseItemTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<PurchaseItemTable>? orderBy,
    _isd.OrderByListBuilder<PurchaseItemTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PurchaseItem>(
      where: where?.call(PurchaseItem.t),
      orderBy: orderBy?.call(PurchaseItem.t),
      orderByList: orderByList?.call(PurchaseItem.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [PurchaseItem]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `PurchaseItem.t`.
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
  _ida.Stream<List<PurchaseItem>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<PurchaseItemTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<PurchaseItemTable>? orderBy,
    _isd.OrderByListBuilder<PurchaseItemTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<PurchaseItem>(
      where: where?.call(PurchaseItem.t),
      orderBy: orderBy?.call(PurchaseItem.t),
      orderByList: orderByList?.call(PurchaseItem.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [PurchaseItem] matching the given query parameters.
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
  Future<PurchaseItem?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<PurchaseItemTable>? where,
    int? offset,
    _isd.OrderByBuilder<PurchaseItemTable>? orderBy,
    _isd.OrderByListBuilder<PurchaseItemTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PurchaseItem>(
      where: where?.call(PurchaseItem.t),
      orderBy: orderBy?.call(PurchaseItem.t),
      orderByList: orderByList?.call(PurchaseItem.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PurchaseItem] by its [id] or null if no such row exists.
  Future<PurchaseItem?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PurchaseItem>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PurchaseItem]s in the list and returns the inserted rows.
  ///
  /// The returned [PurchaseItem]s will have their `id` fields set.
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
  Future<List<PurchaseItem>> insert(
    _isd.DatabaseSession session,
    List<PurchaseItem> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PurchaseItem>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PurchaseItem] and returns the inserted row.
  ///
  /// The returned [PurchaseItem] will have its `id` field set.
  Future<PurchaseItem> insertRow(
    _isd.DatabaseSession session,
    PurchaseItem row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<PurchaseItem>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PurchaseItem]s in the list and returns the resulting rows.
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
  /// The returned [PurchaseItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PurchaseItem>> upsert(
    _isd.DatabaseSession session,
    List<PurchaseItem> rows, {
    required _isd.ColumnSelections<PurchaseItemTable> conflictColumns,
    _isd.ColumnSelections<PurchaseItemTable>? updateColumns,
    _isd.WhereExpressionBuilder<PurchaseItemTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PurchaseItem>(
      rows,
      conflictColumns: conflictColumns(PurchaseItem.t),
      updateColumns: updateColumns?.call(PurchaseItem.t),
      updateWhere: updateWhere?.call(PurchaseItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PurchaseItem] and returns the resulting row.
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
  /// The returned [PurchaseItem] will have its `id` field set.
  Future<PurchaseItem?> upsertRow(
    _isd.DatabaseSession session,
    PurchaseItem row, {
    required _isd.ColumnSelections<PurchaseItemTable> conflictColumns,
    _isd.ColumnSelections<PurchaseItemTable>? updateColumns,
    _isd.WhereExpressionBuilder<PurchaseItemTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PurchaseItem>(
      row,
      conflictColumns: conflictColumns(PurchaseItem.t),
      updateColumns: updateColumns?.call(PurchaseItem.t),
      updateWhere: updateWhere?.call(PurchaseItem.t),
      transaction: transaction,
    );
  }

  /// Updates all [PurchaseItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PurchaseItem>> update(
    _isd.DatabaseSession session,
    List<PurchaseItem> rows, {
    _isd.ColumnSelections<PurchaseItemTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PurchaseItem>(
      rows,
      columns: columns?.call(PurchaseItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PurchaseItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PurchaseItem> updateRow(
    _isd.DatabaseSession session,
    PurchaseItem row, {
    _isd.ColumnSelections<PurchaseItemTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<PurchaseItem>(
      row,
      columns: columns?.call(PurchaseItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PurchaseItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PurchaseItem?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<PurchaseItemUpdateTable> columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<PurchaseItem>(
      id,
      columnValues: columnValues(PurchaseItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PurchaseItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PurchaseItem>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<PurchaseItemUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<PurchaseItemTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<PurchaseItemTable>? orderBy,
    _isd.OrderByListBuilder<PurchaseItemTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PurchaseItem>(
      columnValues: columnValues(PurchaseItem.t.updateTable),
      where: where(PurchaseItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PurchaseItem.t),
      orderByList: orderByList?.call(PurchaseItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PurchaseItem]s in the list and returns the deleted rows.
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
  Future<List<PurchaseItem>> delete(
    _isd.DatabaseSession session,
    List<PurchaseItem> rows, {
    _isd.OrderByBuilder<PurchaseItemTable>? orderBy,
    _isd.OrderByListBuilder<PurchaseItemTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PurchaseItem>(
      rows,
      orderBy: orderBy?.call(PurchaseItem.t),
      orderByList: orderByList?.call(PurchaseItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PurchaseItem].
  Future<PurchaseItem> deleteRow(
    _isd.DatabaseSession session,
    PurchaseItem row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PurchaseItem>(
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
  Future<List<PurchaseItem>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<PurchaseItemTable> where,
    _isd.OrderByBuilder<PurchaseItemTable>? orderBy,
    _isd.OrderByListBuilder<PurchaseItemTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PurchaseItem>(
      where: where(PurchaseItem.t),
      orderBy: orderBy?.call(PurchaseItem.t),
      orderByList: orderByList?.call(PurchaseItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<PurchaseItemTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<PurchaseItem>(
      where: where?.call(PurchaseItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PurchaseItem] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<PurchaseItemTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PurchaseItem>(
      where: where(PurchaseItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
