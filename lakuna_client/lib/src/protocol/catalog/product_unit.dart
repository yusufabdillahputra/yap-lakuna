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

/// Satuan konversi varian, mis. dus berisi 6 botol (factor_milli 6000).
abstract class ProductUnit
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  ProductUnit._({
    _isc.UuidValue? id,
    required this.tenantId,
    required this.variantId,
    required this.unitId,
    required this.factorMilli,
    this.barcode,
    this.costPrice,
    this.sellPrice,
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

  factory ProductUnit({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue variantId,
    required _isc.UuidValue unitId,
    required int factorMilli,
    String? barcode,
    int? costPrice,
    int? sellPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _ProductUnitImpl;

  factory ProductUnit.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProductUnit(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      variantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['variantId'],
      ),
      unitId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['unitId']),
      factorMilli: jsonSerialization['factorMilli'] as int,
      barcode: jsonSerialization['barcode'] as String?,
      costPrice: jsonSerialization['costPrice'] as int?,
      sellPrice: jsonSerialization['sellPrice'] as int?,
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

  static final t = ProductUnitTable();

  static const db = ProductUnitRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue variantId;

  _isc.UuidValue unitId;

  /// Isi satu satuan ini dalam mili-satuan dasar.
  int factorMilli;

  String? barcode;

  /// Harga yang diisi sendiri; null = harga varian × isi.
  int? costPrice;

  int? sellPrice;

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

  /// Returns a shallow copy of this [ProductUnit]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ProductUnit copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? variantId,
    _isc.UuidValue? unitId,
    int? factorMilli,
    String? barcode,
    int? costPrice,
    int? sellPrice,
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
      '__className__': 'ProductUnit',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'variantId': variantId.toJson(),
      'unitId': unitId.toJson(),
      'factorMilli': factorMilli,
      if (barcode != null) 'barcode': barcode,
      if (costPrice != null) 'costPrice': costPrice,
      if (sellPrice != null) 'sellPrice': sellPrice,
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
      '__className__': 'ProductUnit',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'variantId': variantId.toJson(),
      'unitId': unitId.toJson(),
      'factorMilli': factorMilli,
      if (barcode != null) 'barcode': barcode,
      if (costPrice != null) 'costPrice': costPrice,
      if (sellPrice != null) 'sellPrice': sellPrice,
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

  static ProductUnitInclude include() {
    return ProductUnitInclude._();
  }

  static ProductUnitIncludeList includeList({
    _isd.WhereExpressionBuilder<ProductUnitTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ProductUnitTable>? orderBy,
    _isd.OrderByListBuilder<ProductUnitTable>? orderByList,
    ProductUnitInclude? include,
  }) {
    return ProductUnitIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductUnit.t),
      orderByList: orderByList?.call(ProductUnit.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductUnitImpl extends ProductUnit {
  _ProductUnitImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue variantId,
    required _isc.UuidValue unitId,
    required int factorMilli,
    String? barcode,
    int? costPrice,
    int? sellPrice,
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
         variantId: variantId,
         unitId: unitId,
         factorMilli: factorMilli,
         barcode: barcode,
         costPrice: costPrice,
         sellPrice: sellPrice,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [ProductUnit]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ProductUnit copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? variantId,
    _isc.UuidValue? unitId,
    int? factorMilli,
    Object? barcode = _Undefined,
    Object? costPrice = _Undefined,
    Object? sellPrice = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return ProductUnit(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      variantId: variantId ?? this.variantId,
      unitId: unitId ?? this.unitId,
      factorMilli: factorMilli ?? this.factorMilli,
      barcode: barcode is String? ? barcode : this.barcode,
      costPrice: costPrice is int? ? costPrice : this.costPrice,
      sellPrice: sellPrice is int? ? sellPrice : this.sellPrice,
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

class ProductUnitUpdateTable extends _isd.UpdateTable<ProductUnitTable> {
  ProductUnitUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> tenantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.tenantId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> variantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.variantId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> unitId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.unitId,
    value,
  );

  _isd.ColumnValue<int, int> factorMilli(int value) => _isd.ColumnValue(
    table.factorMilli,
    value,
  );

  _isd.ColumnValue<String, String> barcode(String? value) => _isd.ColumnValue(
    table.barcode,
    value,
  );

  _isd.ColumnValue<int, int> costPrice(int? value) => _isd.ColumnValue(
    table.costPrice,
    value,
  );

  _isd.ColumnValue<int, int> sellPrice(int? value) => _isd.ColumnValue(
    table.sellPrice,
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

class ProductUnitTable extends _isd.Table<_isc.UuidValue> {
  ProductUnitTable({super.tableRelation}) : super(tableName: 'product_units') {
    updateTable = ProductUnitUpdateTable(this);
    tenantId = _isd.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    variantId = _isd.ColumnUuid(
      'variant_id',
      this,
      fieldName: 'variantId',
    );
    unitId = _isd.ColumnUuid(
      'unit_id',
      this,
      fieldName: 'unitId',
    );
    factorMilli = _isd.ColumnInt(
      'factor_milli',
      this,
      fieldName: 'factorMilli',
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

  late final ProductUnitUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid variantId;

  late final _isd.ColumnUuid unitId;

  /// Isi satu satuan ini dalam mili-satuan dasar.
  late final _isd.ColumnInt factorMilli;

  late final _isd.ColumnString barcode;

  /// Harga yang diisi sendiri; null = harga varian × isi.
  late final _isd.ColumnInt costPrice;

  late final _isd.ColumnInt sellPrice;

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
    variantId,
    unitId,
    factorMilli,
    barcode,
    costPrice,
    sellPrice,
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

class ProductUnitInclude extends _isd.IncludeObject {
  ProductUnitInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => ProductUnit.t;
}

class ProductUnitIncludeList extends _isd.IncludeList {
  ProductUnitIncludeList._({
    _isd.WhereExpressionBuilder<ProductUnitTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProductUnit.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => ProductUnit.t;
}

class ProductUnitRepository {
  const ProductUnitRepository._();

  /// Returns a list of [ProductUnit]s matching the given query parameters.
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
  Future<List<ProductUnit>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ProductUnitTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ProductUnitTable>? orderBy,
    _isd.OrderByListBuilder<ProductUnitTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProductUnit>(
      where: where?.call(ProductUnit.t),
      orderBy: orderBy?.call(ProductUnit.t),
      orderByList: orderByList?.call(ProductUnit.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [ProductUnit]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `ProductUnit.t`.
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
  _ida.Stream<List<ProductUnit>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ProductUnitTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ProductUnitTable>? orderBy,
    _isd.OrderByListBuilder<ProductUnitTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<ProductUnit>(
      where: where?.call(ProductUnit.t),
      orderBy: orderBy?.call(ProductUnit.t),
      orderByList: orderByList?.call(ProductUnit.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [ProductUnit] matching the given query parameters.
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
  Future<ProductUnit?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ProductUnitTable>? where,
    int? offset,
    _isd.OrderByBuilder<ProductUnitTable>? orderBy,
    _isd.OrderByListBuilder<ProductUnitTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProductUnit>(
      where: where?.call(ProductUnit.t),
      orderBy: orderBy?.call(ProductUnit.t),
      orderByList: orderByList?.call(ProductUnit.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProductUnit] by its [id] or null if no such row exists.
  Future<ProductUnit?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProductUnit>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProductUnit]s in the list and returns the inserted rows.
  ///
  /// The returned [ProductUnit]s will have their `id` fields set.
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
  Future<List<ProductUnit>> insert(
    _isd.DatabaseSession session,
    List<ProductUnit> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ProductUnit>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ProductUnit] and returns the inserted row.
  ///
  /// The returned [ProductUnit] will have its `id` field set.
  Future<ProductUnit> insertRow(
    _isd.DatabaseSession session,
    ProductUnit row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProductUnit>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ProductUnit]s in the list and returns the resulting rows.
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
  /// The returned [ProductUnit]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductUnit>> upsert(
    _isd.DatabaseSession session,
    List<ProductUnit> rows, {
    required _isd.ColumnSelections<ProductUnitTable> conflictColumns,
    _isd.ColumnSelections<ProductUnitTable>? updateColumns,
    _isd.WhereExpressionBuilder<ProductUnitTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ProductUnit>(
      rows,
      conflictColumns: conflictColumns(ProductUnit.t),
      updateColumns: updateColumns?.call(ProductUnit.t),
      updateWhere: updateWhere?.call(ProductUnit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ProductUnit] and returns the resulting row.
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
  /// The returned [ProductUnit] will have its `id` field set.
  Future<ProductUnit?> upsertRow(
    _isd.DatabaseSession session,
    ProductUnit row, {
    required _isd.ColumnSelections<ProductUnitTable> conflictColumns,
    _isd.ColumnSelections<ProductUnitTable>? updateColumns,
    _isd.WhereExpressionBuilder<ProductUnitTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ProductUnit>(
      row,
      conflictColumns: conflictColumns(ProductUnit.t),
      updateColumns: updateColumns?.call(ProductUnit.t),
      updateWhere: updateWhere?.call(ProductUnit.t),
      transaction: transaction,
    );
  }

  /// Updates all [ProductUnit]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductUnit>> update(
    _isd.DatabaseSession session,
    List<ProductUnit> rows, {
    _isd.ColumnSelections<ProductUnitTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ProductUnit>(
      rows,
      columns: columns?.call(ProductUnit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ProductUnit]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProductUnit> updateRow(
    _isd.DatabaseSession session,
    ProductUnit row, {
    _isd.ColumnSelections<ProductUnitTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProductUnit>(
      row,
      columns: columns?.call(ProductUnit.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProductUnit] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProductUnit?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<ProductUnitUpdateTable> columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<ProductUnit>(
      id,
      columnValues: columnValues(ProductUnit.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProductUnit]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductUnit>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<ProductUnitUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<ProductUnitTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ProductUnitTable>? orderBy,
    _isd.OrderByListBuilder<ProductUnitTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ProductUnit>(
      columnValues: columnValues(ProductUnit.t.updateTable),
      where: where(ProductUnit.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductUnit.t),
      orderByList: orderByList?.call(ProductUnit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ProductUnit]s in the list and returns the deleted rows.
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
  Future<List<ProductUnit>> delete(
    _isd.DatabaseSession session,
    List<ProductUnit> rows, {
    _isd.OrderByBuilder<ProductUnitTable>? orderBy,
    _isd.OrderByListBuilder<ProductUnitTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ProductUnit>(
      rows,
      orderBy: orderBy?.call(ProductUnit.t),
      orderByList: orderByList?.call(ProductUnit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ProductUnit].
  Future<ProductUnit> deleteRow(
    _isd.DatabaseSession session,
    ProductUnit row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProductUnit>(
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
  Future<List<ProductUnit>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<ProductUnitTable> where,
    _isd.OrderByBuilder<ProductUnitTable>? orderBy,
    _isd.OrderByListBuilder<ProductUnitTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ProductUnit>(
      where: where(ProductUnit.t),
      orderBy: orderBy?.call(ProductUnit.t),
      orderByList: orderByList?.call(ProductUnit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ProductUnitTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<ProductUnit>(
      where: where?.call(ProductUnit.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProductUnit] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<ProductUnitTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProductUnit>(
      where: where(ProductUnit.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
