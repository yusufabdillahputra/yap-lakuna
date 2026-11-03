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

/// Varian produk yang dijual dan dilacak stoknya. SKU dan barcode unik per
/// tenant (dicek di lakuna_data tanpa membedakan huruf besar/kecil).
abstract class ProductVariant
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  ProductVariant._({
    _isc.UuidValue? id,
    required this.tenantId,
    required this.productId,
    String? name,
    this.sku,
    this.barcode,
    required this.costPrice,
    required this.sellPrice,
    int? minStockMilli,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _isc.Uuid().v7obj(),
       name = name ?? '',
       minStockMilli = minStockMilli ?? 0,
       sortOrder = sortOrder ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory ProductVariant({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue productId,
    String? name,
    String? sku,
    String? barcode,
    required int costPrice,
    required int sellPrice,
    int? minStockMilli,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _ProductVariantImpl;

  factory ProductVariant.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProductVariant(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      productId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['productId'],
      ),
      name: jsonSerialization['name'] as String?,
      sku: jsonSerialization['sku'] as String?,
      barcode: jsonSerialization['barcode'] as String?,
      costPrice: jsonSerialization['costPrice'] as int,
      sellPrice: jsonSerialization['sellPrice'] as int,
      minStockMilli: jsonSerialization['minStockMilli'] as int?,
      sortOrder: jsonSerialization['sortOrder'] as int?,
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

  static final t = ProductVariantTable();

  static const db = ProductVariantRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue productId;

  /// Nama varian; kosong bila produk hanya punya satu varian.
  String name;

  String? sku;

  String? barcode;

  int costPrice;

  int sellPrice;

  int minStockMilli;

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

  /// Returns a shallow copy of this [ProductVariant]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ProductVariant copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? productId,
    String? name,
    String? sku,
    String? barcode,
    int? costPrice,
    int? sellPrice,
    int? minStockMilli,
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
      '__className__': 'ProductVariant',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'productId': productId.toJson(),
      'name': name,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      'costPrice': costPrice,
      'sellPrice': sellPrice,
      'minStockMilli': minStockMilli,
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
      '__className__': 'ProductVariant',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'productId': productId.toJson(),
      'name': name,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      'costPrice': costPrice,
      'sellPrice': sellPrice,
      'minStockMilli': minStockMilli,
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

  static ProductVariantInclude include() {
    return ProductVariantInclude._();
  }

  static ProductVariantIncludeList includeList({
    _isd.WhereExpressionBuilder<ProductVariantTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ProductVariantTable>? orderBy,
    _isd.OrderByListBuilder<ProductVariantTable>? orderByList,
    ProductVariantInclude? include,
  }) {
    return ProductVariantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductVariant.t),
      orderByList: orderByList?.call(ProductVariant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductVariantImpl extends ProductVariant {
  _ProductVariantImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue productId,
    String? name,
    String? sku,
    String? barcode,
    required int costPrice,
    required int sellPrice,
    int? minStockMilli,
    int? sortOrder,
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
         productId: productId,
         name: name,
         sku: sku,
         barcode: barcode,
         costPrice: costPrice,
         sellPrice: sellPrice,
         minStockMilli: minStockMilli,
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

  /// Returns a shallow copy of this [ProductVariant]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ProductVariant copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? productId,
    String? name,
    Object? sku = _Undefined,
    Object? barcode = _Undefined,
    int? costPrice,
    int? sellPrice,
    int? minStockMilli,
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
    return ProductVariant(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      sku: sku is String? ? sku : this.sku,
      barcode: barcode is String? ? barcode : this.barcode,
      costPrice: costPrice ?? this.costPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      minStockMilli: minStockMilli ?? this.minStockMilli,
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

class ProductVariantUpdateTable extends _isd.UpdateTable<ProductVariantTable> {
  ProductVariantUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> tenantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.tenantId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> productId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.productId,
    value,
  );

  _isd.ColumnValue<String, String> name(String value) => _isd.ColumnValue(
    table.name,
    value,
  );

  _isd.ColumnValue<String, String> sku(String? value) => _isd.ColumnValue(
    table.sku,
    value,
  );

  _isd.ColumnValue<String, String> barcode(String? value) => _isd.ColumnValue(
    table.barcode,
    value,
  );

  _isd.ColumnValue<int, int> costPrice(int value) => _isd.ColumnValue(
    table.costPrice,
    value,
  );

  _isd.ColumnValue<int, int> sellPrice(int value) => _isd.ColumnValue(
    table.sellPrice,
    value,
  );

  _isd.ColumnValue<int, int> minStockMilli(int value) => _isd.ColumnValue(
    table.minStockMilli,
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

class ProductVariantTable extends _isd.Table<_isc.UuidValue> {
  ProductVariantTable({super.tableRelation})
    : super(tableName: 'product_variants') {
    updateTable = ProductVariantUpdateTable(this);
    tenantId = _isd.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    productId = _isd.ColumnUuid(
      'product_id',
      this,
      fieldName: 'productId',
    );
    name = _isd.ColumnString(
      'name',
      this,
      hasDefault: true,
    );
    sku = _isd.ColumnString(
      'sku',
      this,
    );
    barcode = _isd.ColumnString(
      'barcode',
      this,
    );
    costPrice = _isd.ColumnInt(
      'cost_price',
      this,
      fieldName: 'costPrice',
    );
    sellPrice = _isd.ColumnInt(
      'sell_price',
      this,
      fieldName: 'sellPrice',
    );
    minStockMilli = _isd.ColumnInt(
      'min_stock_milli',
      this,
      hasDefault: true,
      fieldName: 'minStockMilli',
    );
    sortOrder = _isd.ColumnInt(
      'sort_order',
      this,
      hasDefault: true,
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

  late final ProductVariantUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid productId;

  /// Nama varian; kosong bila produk hanya punya satu varian.
  late final _isd.ColumnString name;

  late final _isd.ColumnString sku;

  late final _isd.ColumnString barcode;

  late final _isd.ColumnInt costPrice;

  late final _isd.ColumnInt sellPrice;

  late final _isd.ColumnInt minStockMilli;

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
    productId,
    name,
    sku,
    barcode,
    costPrice,
    sellPrice,
    minStockMilli,
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

class ProductVariantInclude extends _isd.IncludeObject {
  ProductVariantInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => ProductVariant.t;
}

class ProductVariantIncludeList extends _isd.IncludeList {
  ProductVariantIncludeList._({
    _isd.WhereExpressionBuilder<ProductVariantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProductVariant.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => ProductVariant.t;
}

class ProductVariantRepository {
  const ProductVariantRepository._();

  /// Returns a list of [ProductVariant]s matching the given query parameters.
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
  Future<List<ProductVariant>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ProductVariantTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ProductVariantTable>? orderBy,
    _isd.OrderByListBuilder<ProductVariantTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProductVariant>(
      where: where?.call(ProductVariant.t),
      orderBy: orderBy?.call(ProductVariant.t),
      orderByList: orderByList?.call(ProductVariant.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [ProductVariant]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `ProductVariant.t`.
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
  _ida.Stream<List<ProductVariant>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ProductVariantTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ProductVariantTable>? orderBy,
    _isd.OrderByListBuilder<ProductVariantTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<ProductVariant>(
      where: where?.call(ProductVariant.t),
      orderBy: orderBy?.call(ProductVariant.t),
      orderByList: orderByList?.call(ProductVariant.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [ProductVariant] matching the given query parameters.
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
  Future<ProductVariant?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ProductVariantTable>? where,
    int? offset,
    _isd.OrderByBuilder<ProductVariantTable>? orderBy,
    _isd.OrderByListBuilder<ProductVariantTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProductVariant>(
      where: where?.call(ProductVariant.t),
      orderBy: orderBy?.call(ProductVariant.t),
      orderByList: orderByList?.call(ProductVariant.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProductVariant] by its [id] or null if no such row exists.
  Future<ProductVariant?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProductVariant>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProductVariant]s in the list and returns the inserted rows.
  ///
  /// The returned [ProductVariant]s will have their `id` fields set.
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
  Future<List<ProductVariant>> insert(
    _isd.DatabaseSession session,
    List<ProductVariant> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ProductVariant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ProductVariant] and returns the inserted row.
  ///
  /// The returned [ProductVariant] will have its `id` field set.
  Future<ProductVariant> insertRow(
    _isd.DatabaseSession session,
    ProductVariant row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProductVariant>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ProductVariant]s in the list and returns the resulting rows.
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
  /// The returned [ProductVariant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductVariant>> upsert(
    _isd.DatabaseSession session,
    List<ProductVariant> rows, {
    required _isd.ColumnSelections<ProductVariantTable> conflictColumns,
    _isd.ColumnSelections<ProductVariantTable>? updateColumns,
    _isd.WhereExpressionBuilder<ProductVariantTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ProductVariant>(
      rows,
      conflictColumns: conflictColumns(ProductVariant.t),
      updateColumns: updateColumns?.call(ProductVariant.t),
      updateWhere: updateWhere?.call(ProductVariant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ProductVariant] and returns the resulting row.
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
  /// The returned [ProductVariant] will have its `id` field set.
  Future<ProductVariant?> upsertRow(
    _isd.DatabaseSession session,
    ProductVariant row, {
    required _isd.ColumnSelections<ProductVariantTable> conflictColumns,
    _isd.ColumnSelections<ProductVariantTable>? updateColumns,
    _isd.WhereExpressionBuilder<ProductVariantTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ProductVariant>(
      row,
      conflictColumns: conflictColumns(ProductVariant.t),
      updateColumns: updateColumns?.call(ProductVariant.t),
      updateWhere: updateWhere?.call(ProductVariant.t),
      transaction: transaction,
    );
  }

  /// Updates all [ProductVariant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductVariant>> update(
    _isd.DatabaseSession session,
    List<ProductVariant> rows, {
    _isd.ColumnSelections<ProductVariantTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ProductVariant>(
      rows,
      columns: columns?.call(ProductVariant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ProductVariant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProductVariant> updateRow(
    _isd.DatabaseSession session,
    ProductVariant row, {
    _isd.ColumnSelections<ProductVariantTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProductVariant>(
      row,
      columns: columns?.call(ProductVariant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProductVariant] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProductVariant?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<ProductVariantUpdateTable>
    columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<ProductVariant>(
      id,
      columnValues: columnValues(ProductVariant.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProductVariant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductVariant>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<ProductVariantUpdateTable>
    columnValues,
    required _isd.WhereExpressionBuilder<ProductVariantTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ProductVariantTable>? orderBy,
    _isd.OrderByListBuilder<ProductVariantTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ProductVariant>(
      columnValues: columnValues(ProductVariant.t.updateTable),
      where: where(ProductVariant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductVariant.t),
      orderByList: orderByList?.call(ProductVariant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ProductVariant]s in the list and returns the deleted rows.
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
  Future<List<ProductVariant>> delete(
    _isd.DatabaseSession session,
    List<ProductVariant> rows, {
    _isd.OrderByBuilder<ProductVariantTable>? orderBy,
    _isd.OrderByListBuilder<ProductVariantTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ProductVariant>(
      rows,
      orderBy: orderBy?.call(ProductVariant.t),
      orderByList: orderByList?.call(ProductVariant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ProductVariant].
  Future<ProductVariant> deleteRow(
    _isd.DatabaseSession session,
    ProductVariant row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProductVariant>(
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
  Future<List<ProductVariant>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<ProductVariantTable> where,
    _isd.OrderByBuilder<ProductVariantTable>? orderBy,
    _isd.OrderByListBuilder<ProductVariantTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ProductVariant>(
      where: where(ProductVariant.t),
      orderBy: orderBy?.call(ProductVariant.t),
      orderByList: orderByList?.call(ProductVariant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ProductVariantTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<ProductVariant>(
      where: where?.call(ProductVariant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProductVariant] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<ProductVariantTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProductVariant>(
      where: where(ProductVariant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
