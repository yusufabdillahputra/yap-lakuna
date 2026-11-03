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

/// Baris pembelian (F1-12). Qty dan harga dalam satuan baris; isi
/// `factor_milli` dan harga pokok mendarat per satuan dasar disalin agar
/// retur memakai angka saat pembelian. `avg_cost_before/after` diisi saat
/// barang diterima (HPP rata-rata lokasi, satuan dasar).
abstract class PurchaseItem
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  PurchaseItem._({
    _is.UuidValue? id,
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
    required this.sortOrder,
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

  factory PurchaseItem({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue purchaseId,
    required _is.UuidValue variantId,
    _is.UuidValue? productUnitId,
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
    required int sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _PurchaseItemImpl;

  factory PurchaseItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return PurchaseItem(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      purchaseId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['purchaseId'],
      ),
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
      unitPrice: jsonSerialization['unitPrice'] as int,
      lineTotal: jsonSerialization['lineTotal'] as int,
      landedUnitCost: jsonSerialization['landedUnitCost'] as int,
      avgCostBefore: jsonSerialization['avgCostBefore'] as int?,
      avgCostAfter: jsonSerialization['avgCostAfter'] as int?,
      sortOrder: jsonSerialization['sortOrder'] as int,
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

  static final t = PurchaseItemTable();

  static const db = PurchaseItemRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue purchaseId;

  _is.UuidValue variantId;

  _is.UuidValue? productUnitId;

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

  int sortOrder;

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

  /// Returns a shallow copy of this [PurchaseItem]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PurchaseItem copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? purchaseId,
    _is.UuidValue? variantId,
    _is.UuidValue? productUnitId = const _is.$UndefinedUuidValue(),
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
    int? sortOrder,
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
    _is.WhereExpressionBuilder<PurchaseItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseItemTable>? orderBy,
    _is.OrderByListBuilder<PurchaseItemTable>? orderByList,
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
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PurchaseItemImpl extends PurchaseItem {
  _PurchaseItemImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue purchaseId,
    required _is.UuidValue variantId,
    _is.UuidValue? productUnitId,
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
    required int sortOrder,
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
  @_is.useResult
  @override
  PurchaseItem copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? purchaseId,
    _is.UuidValue? variantId,
    _is.UuidValue? productUnitId = const _is.$UndefinedUuidValue(),
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
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      purchaseId: purchaseId ?? this.purchaseId,
      variantId: variantId ?? this.variantId,
      productUnitId: productUnitId is _is.UndefinedSentinel
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
      sortOrder: sortOrder ?? this.sortOrder,
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

class PurchaseItemUpdateTable extends _is.UpdateTable<PurchaseItemTable> {
  PurchaseItemUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> purchaseId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.purchaseId,
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

  _is.ColumnValue<int, int> unitPrice(int value) => _is.ColumnValue(
    table.unitPrice,
    value,
  );

  _is.ColumnValue<int, int> lineTotal(int value) => _is.ColumnValue(
    table.lineTotal,
    value,
  );

  _is.ColumnValue<int, int> landedUnitCost(int value) => _is.ColumnValue(
    table.landedUnitCost,
    value,
  );

  _is.ColumnValue<int, int> avgCostBefore(int? value) => _is.ColumnValue(
    table.avgCostBefore,
    value,
  );

  _is.ColumnValue<int, int> avgCostAfter(int? value) => _is.ColumnValue(
    table.avgCostAfter,
    value,
  );

  _is.ColumnValue<int, int> sortOrder(int value) => _is.ColumnValue(
    table.sortOrder,
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

class PurchaseItemTable extends _is.Table<_is.UuidValue> {
  PurchaseItemTable({super.tableRelation})
    : super(tableName: 'purchase_items') {
    updateTable = PurchaseItemUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    purchaseId = _is.ColumnUuid(
      'purchase_id',
      this,
      fieldName: 'purchaseId',
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
    landedUnitCost = _is.ColumnInt(
      'landed_unit_cost',
      this,
      fieldName: 'landedUnitCost',
    );
    avgCostBefore = _is.ColumnInt(
      'avg_cost_before',
      this,
      fieldName: 'avgCostBefore',
    );
    avgCostAfter = _is.ColumnInt(
      'avg_cost_after',
      this,
      fieldName: 'avgCostAfter',
    );
    sortOrder = _is.ColumnInt(
      'sort_order',
      this,
      fieldName: 'sortOrder',
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

  late final PurchaseItemUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid purchaseId;

  late final _is.ColumnUuid variantId;

  late final _is.ColumnUuid productUnitId;

  late final _is.ColumnString productName;

  late final _is.ColumnString variantName;

  late final _is.ColumnString unitName;

  late final _is.ColumnInt factorMilli;

  late final _is.ColumnInt quantityMilli;

  late final _is.ColumnInt unitPrice;

  late final _is.ColumnInt lineTotal;

  late final _is.ColumnInt landedUnitCost;

  late final _is.ColumnInt avgCostBefore;

  late final _is.ColumnInt avgCostAfter;

  late final _is.ColumnInt sortOrder;

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

class PurchaseItemInclude extends _is.IncludeObject {
  PurchaseItemInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => PurchaseItem.t;
}

class PurchaseItemIncludeList extends _is.IncludeList {
  PurchaseItemIncludeList._({
    _is.WhereExpressionBuilder<PurchaseItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PurchaseItem.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => PurchaseItem.t;
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseItemTable>? orderBy,
    _is.OrderByListBuilder<PurchaseItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseItemTable>? orderBy,
    _is.OrderByListBuilder<PurchaseItemTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseItemTable>? where,
    int? offset,
    _is.OrderByBuilder<PurchaseItemTable>? orderBy,
    _is.OrderByListBuilder<PurchaseItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session,
    List<PurchaseItem> rows, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    PurchaseItem row, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<PurchaseItem> rows, {
    required _is.ColumnSelections<PurchaseItemTable> conflictColumns,
    _is.ColumnSelections<PurchaseItemTable>? updateColumns,
    _is.WhereExpressionBuilder<PurchaseItemTable>? updateWhere,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    PurchaseItem row, {
    required _is.ColumnSelections<PurchaseItemTable> conflictColumns,
    _is.ColumnSelections<PurchaseItemTable>? updateColumns,
    _is.WhereExpressionBuilder<PurchaseItemTable>? updateWhere,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<PurchaseItem> rows, {
    _is.ColumnSelections<PurchaseItemTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    PurchaseItem row, {
    _is.ColumnSelections<PurchaseItemTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<PurchaseItemUpdateTable> columnValues,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PurchaseItemUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PurchaseItemTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseItemTable>? orderBy,
    _is.OrderByListBuilder<PurchaseItemTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<PurchaseItem> rows, {
    _is.OrderByBuilder<PurchaseItemTable>? orderBy,
    _is.OrderByListBuilder<PurchaseItemTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    PurchaseItem row, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PurchaseItemTable> where,
    _is.OrderByBuilder<PurchaseItemTable>? orderBy,
    _is.OrderByListBuilder<PurchaseItemTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseItemTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PurchaseItem>(
      where: where?.call(PurchaseItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PurchaseItem] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PurchaseItemTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PurchaseItem>(
      where: where(PurchaseItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
