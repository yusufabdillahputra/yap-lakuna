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

/// Kategori produk per tenant (F1-07; master di F1-09: induk satu tingkat,
/// warna palet, urutan, tampil di kasir, aktif).
abstract class ProductCategory
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  ProductCategory._({
    _is.UuidValue? id,
    required this.tenantId,
    this.parentId,
    required this.name,
    this.color,
    bool? showInCashier,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _is.Uuid().v7obj(),
       showInCashier = showInCashier ?? true,
       isActive = isActive ?? true,
       sortOrder = sortOrder ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory ProductCategory({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    _is.UuidValue? parentId,
    required String name,
    String? color,
    bool? showInCashier,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _ProductCategoryImpl;

  factory ProductCategory.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProductCategory(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      parentId: jsonSerialization['parentId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['parentId']),
      name: jsonSerialization['name'] as String,
      color: jsonSerialization['color'] as String?,
      showInCashier: jsonSerialization['showInCashier'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['showInCashier']),
      isActive: jsonSerialization['isActive'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      sortOrder: jsonSerialization['sortOrder'] as int?,
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

  static final t = ProductCategoryTable();

  static const db = ProductCategoryRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  /// Induk (satu tingkat); null = kategori utama.
  _is.UuidValue? parentId;

  String name;

  /// Hex `#RRGGBB` dari palet `categoryColors`, atau null.
  String? color;

  bool showInCashier;

  bool isActive;

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

  /// Returns a shallow copy of this [ProductCategory]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ProductCategory copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? parentId = const _is.$UndefinedUuidValue(),
    String? name,
    String? color,
    bool? showInCashier,
    bool? isActive,
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
      '__className__': 'ProductCategory',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      if (parentId != null) 'parentId': parentId?.toJson(),
      'name': name,
      if (color != null) 'color': color,
      'showInCashier': showInCashier,
      'isActive': isActive,
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
      '__className__': 'ProductCategory',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      if (parentId != null) 'parentId': parentId?.toJson(),
      'name': name,
      if (color != null) 'color': color,
      'showInCashier': showInCashier,
      'isActive': isActive,
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

  static ProductCategoryInclude include() {
    return ProductCategoryInclude._();
  }

  static ProductCategoryIncludeList includeList({
    _is.WhereExpressionBuilder<ProductCategoryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProductCategoryTable>? orderBy,
    _is.OrderByListBuilder<ProductCategoryTable>? orderByList,
    ProductCategoryInclude? include,
  }) {
    return ProductCategoryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductCategory.t),
      orderByList: orderByList?.call(ProductCategory.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductCategoryImpl extends ProductCategory {
  _ProductCategoryImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    _is.UuidValue? parentId,
    required String name,
    String? color,
    bool? showInCashier,
    bool? isActive,
    int? sortOrder,
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
         parentId: parentId,
         name: name,
         color: color,
         showInCashier: showInCashier,
         isActive: isActive,
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

  /// Returns a shallow copy of this [ProductCategory]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ProductCategory copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? parentId = const _is.$UndefinedUuidValue(),
    String? name,
    Object? color = _Undefined,
    bool? showInCashier,
    bool? isActive,
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
    return ProductCategory(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      parentId: parentId is _is.UndefinedSentinel ? this.parentId : parentId,
      name: name ?? this.name,
      color: color is String? ? color : this.color,
      showInCashier: showInCashier ?? this.showInCashier,
      isActive: isActive ?? this.isActive,
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

class ProductCategoryUpdateTable extends _is.UpdateTable<ProductCategoryTable> {
  ProductCategoryUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> parentId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.parentId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> color(String? value) => _is.ColumnValue(
    table.color,
    value,
  );

  _is.ColumnValue<bool, bool> showInCashier(bool value) => _is.ColumnValue(
    table.showInCashier,
    value,
  );

  _is.ColumnValue<bool, bool> isActive(bool value) => _is.ColumnValue(
    table.isActive,
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

class ProductCategoryTable extends _is.Table<_is.UuidValue> {
  ProductCategoryTable({super.tableRelation}) : super(tableName: 'categories') {
    updateTable = ProductCategoryUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    parentId = _is.ColumnUuid(
      'parent_id',
      this,
      fieldName: 'parentId',
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    color = _is.ColumnString(
      'color',
      this,
    );
    showInCashier = _is.ColumnBool(
      'show_in_cashier',
      this,
      hasDefault: true,
      fieldName: 'showInCashier',
    );
    isActive = _is.ColumnBool(
      'is_active',
      this,
      hasDefault: true,
      fieldName: 'isActive',
    );
    sortOrder = _is.ColumnInt(
      'sort_order',
      this,
      hasDefault: true,
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

  late final ProductCategoryUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  /// Induk (satu tingkat); null = kategori utama.
  late final _is.ColumnUuid parentId;

  late final _is.ColumnString name;

  /// Hex `#RRGGBB` dari palet `categoryColors`, atau null.
  late final _is.ColumnString color;

  late final _is.ColumnBool showInCashier;

  late final _is.ColumnBool isActive;

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
    parentId,
    name,
    color,
    showInCashier,
    isActive,
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

class ProductCategoryInclude extends _is.IncludeObject {
  ProductCategoryInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => ProductCategory.t;
}

class ProductCategoryIncludeList extends _is.IncludeList {
  ProductCategoryIncludeList._({
    _is.WhereExpressionBuilder<ProductCategoryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProductCategory.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => ProductCategory.t;
}

class ProductCategoryRepository {
  const ProductCategoryRepository._();

  /// Returns a list of [ProductCategory]s matching the given query parameters.
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
  Future<List<ProductCategory>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProductCategoryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProductCategoryTable>? orderBy,
    _is.OrderByListBuilder<ProductCategoryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProductCategory>(
      where: where?.call(ProductCategory.t),
      orderBy: orderBy?.call(ProductCategory.t),
      orderByList: orderByList?.call(ProductCategory.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [ProductCategory]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `ProductCategory.t`.
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
  _ida.Stream<List<ProductCategory>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProductCategoryTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProductCategoryTable>? orderBy,
    _is.OrderByListBuilder<ProductCategoryTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<ProductCategory>(
      where: where?.call(ProductCategory.t),
      orderBy: orderBy?.call(ProductCategory.t),
      orderByList: orderByList?.call(ProductCategory.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [ProductCategory] matching the given query parameters.
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
  Future<ProductCategory?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProductCategoryTable>? where,
    int? offset,
    _is.OrderByBuilder<ProductCategoryTable>? orderBy,
    _is.OrderByListBuilder<ProductCategoryTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProductCategory>(
      where: where?.call(ProductCategory.t),
      orderBy: orderBy?.call(ProductCategory.t),
      orderByList: orderByList?.call(ProductCategory.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProductCategory] by its [id] or null if no such row exists.
  Future<ProductCategory?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProductCategory>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProductCategory]s in the list and returns the inserted rows.
  ///
  /// The returned [ProductCategory]s will have their `id` fields set.
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
  Future<List<ProductCategory>> insert(
    _is.DatabaseSession session,
    List<ProductCategory> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ProductCategory>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ProductCategory] and returns the inserted row.
  ///
  /// The returned [ProductCategory] will have its `id` field set.
  Future<ProductCategory> insertRow(
    _is.DatabaseSession session,
    ProductCategory row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProductCategory>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ProductCategory]s in the list and returns the resulting rows.
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
  /// The returned [ProductCategory]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductCategory>> upsert(
    _is.DatabaseSession session,
    List<ProductCategory> rows, {
    required _is.ColumnSelections<ProductCategoryTable> conflictColumns,
    _is.ColumnSelections<ProductCategoryTable>? updateColumns,
    _is.WhereExpressionBuilder<ProductCategoryTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ProductCategory>(
      rows,
      conflictColumns: conflictColumns(ProductCategory.t),
      updateColumns: updateColumns?.call(ProductCategory.t),
      updateWhere: updateWhere?.call(ProductCategory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ProductCategory] and returns the resulting row.
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
  /// The returned [ProductCategory] will have its `id` field set.
  Future<ProductCategory?> upsertRow(
    _is.DatabaseSession session,
    ProductCategory row, {
    required _is.ColumnSelections<ProductCategoryTable> conflictColumns,
    _is.ColumnSelections<ProductCategoryTable>? updateColumns,
    _is.WhereExpressionBuilder<ProductCategoryTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ProductCategory>(
      row,
      conflictColumns: conflictColumns(ProductCategory.t),
      updateColumns: updateColumns?.call(ProductCategory.t),
      updateWhere: updateWhere?.call(ProductCategory.t),
      transaction: transaction,
    );
  }

  /// Updates all [ProductCategory]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductCategory>> update(
    _is.DatabaseSession session,
    List<ProductCategory> rows, {
    _is.ColumnSelections<ProductCategoryTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ProductCategory>(
      rows,
      columns: columns?.call(ProductCategory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ProductCategory]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProductCategory> updateRow(
    _is.DatabaseSession session,
    ProductCategory row, {
    _is.ColumnSelections<ProductCategoryTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProductCategory>(
      row,
      columns: columns?.call(ProductCategory.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProductCategory] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProductCategory?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<ProductCategoryUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ProductCategory>(
      id,
      columnValues: columnValues(ProductCategory.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProductCategory]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProductCategory>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ProductCategoryUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<ProductCategoryTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProductCategoryTable>? orderBy,
    _is.OrderByListBuilder<ProductCategoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ProductCategory>(
      columnValues: columnValues(ProductCategory.t.updateTable),
      where: where(ProductCategory.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProductCategory.t),
      orderByList: orderByList?.call(ProductCategory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ProductCategory]s in the list and returns the deleted rows.
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
  Future<List<ProductCategory>> delete(
    _is.DatabaseSession session,
    List<ProductCategory> rows, {
    _is.OrderByBuilder<ProductCategoryTable>? orderBy,
    _is.OrderByListBuilder<ProductCategoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ProductCategory>(
      rows,
      orderBy: orderBy?.call(ProductCategory.t),
      orderByList: orderByList?.call(ProductCategory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ProductCategory].
  Future<ProductCategory> deleteRow(
    _is.DatabaseSession session,
    ProductCategory row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProductCategory>(
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
  Future<List<ProductCategory>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ProductCategoryTable> where,
    _is.OrderByBuilder<ProductCategoryTable>? orderBy,
    _is.OrderByListBuilder<ProductCategoryTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ProductCategory>(
      where: where(ProductCategory.t),
      orderBy: orderBy?.call(ProductCategory.t),
      orderByList: orderByList?.call(ProductCategory.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProductCategoryTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ProductCategory>(
      where: where?.call(ProductCategory.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProductCategory] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ProductCategoryTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProductCategory>(
      where: where(ProductCategory.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
