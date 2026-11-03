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

/// Modifier terpilih di baris nota. Nama dan harga disalin agar nota lama
/// tidak berubah bila master diubah (F1-10b).
abstract class SaleItemModifier
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  SaleItemModifier._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.saleItemId,
    required this.modifierId,
    required this.groupName,
    required this.name,
    required this.priceDelta,
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
       sortOrder = sortOrder ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory SaleItemModifier({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue saleItemId,
    required _is.UuidValue modifierId,
    required String groupName,
    required String name,
    required int priceDelta,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _SaleItemModifierImpl;

  factory SaleItemModifier.fromJson(Map<String, dynamic> jsonSerialization) {
    return SaleItemModifier(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      saleItemId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['saleItemId'],
      ),
      modifierId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['modifierId'],
      ),
      groupName: jsonSerialization['groupName'] as String,
      name: jsonSerialization['name'] as String,
      priceDelta: jsonSerialization['priceDelta'] as int,
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

  static final t = SaleItemModifierTable();

  static const db = SaleItemModifierRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue saleItemId;

  _is.UuidValue modifierId;

  String groupName;

  String name;

  int priceDelta;

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

  /// Returns a shallow copy of this [SaleItemModifier]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SaleItemModifier copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? saleItemId,
    _is.UuidValue? modifierId,
    String? groupName,
    String? name,
    int? priceDelta,
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
      '__className__': 'SaleItemModifier',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'saleItemId': saleItemId.toJson(),
      'modifierId': modifierId.toJson(),
      'groupName': groupName,
      'name': name,
      'priceDelta': priceDelta,
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
      '__className__': 'SaleItemModifier',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'saleItemId': saleItemId.toJson(),
      'modifierId': modifierId.toJson(),
      'groupName': groupName,
      'name': name,
      'priceDelta': priceDelta,
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

  static SaleItemModifierInclude include() {
    return SaleItemModifierInclude._();
  }

  static SaleItemModifierIncludeList includeList({
    _is.WhereExpressionBuilder<SaleItemModifierTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleItemModifierTable>? orderBy,
    _is.OrderByListBuilder<SaleItemModifierTable>? orderByList,
    SaleItemModifierInclude? include,
  }) {
    return SaleItemModifierIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SaleItemModifier.t),
      orderByList: orderByList?.call(SaleItemModifier.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _SaleItemModifierImpl extends SaleItemModifier {
  _SaleItemModifierImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue saleItemId,
    required _is.UuidValue modifierId,
    required String groupName,
    required String name,
    required int priceDelta,
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
         saleItemId: saleItemId,
         modifierId: modifierId,
         groupName: groupName,
         name: name,
         priceDelta: priceDelta,
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

  /// Returns a shallow copy of this [SaleItemModifier]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SaleItemModifier copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? saleItemId,
    _is.UuidValue? modifierId,
    String? groupName,
    String? name,
    int? priceDelta,
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
    return SaleItemModifier(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      saleItemId: saleItemId ?? this.saleItemId,
      modifierId: modifierId ?? this.modifierId,
      groupName: groupName ?? this.groupName,
      name: name ?? this.name,
      priceDelta: priceDelta ?? this.priceDelta,
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

class SaleItemModifierUpdateTable
    extends _is.UpdateTable<SaleItemModifierTable> {
  SaleItemModifierUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> saleItemId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.saleItemId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> modifierId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.modifierId,
    value,
  );

  _is.ColumnValue<String, String> groupName(String value) => _is.ColumnValue(
    table.groupName,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<int, int> priceDelta(int value) => _is.ColumnValue(
    table.priceDelta,
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

class SaleItemModifierTable extends _is.Table<_is.UuidValue> {
  SaleItemModifierTable({super.tableRelation})
    : super(tableName: 'sale_item_modifiers') {
    updateTable = SaleItemModifierUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    saleItemId = _is.ColumnUuid(
      'sale_item_id',
      this,
      fieldName: 'saleItemId',
    );
    modifierId = _is.ColumnUuid(
      'modifier_id',
      this,
      fieldName: 'modifierId',
    );
    groupName = _is.ColumnString(
      'group_name',
      this,
      fieldName: 'groupName',
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    priceDelta = _is.ColumnInt(
      'price_delta',
      this,
      fieldName: 'priceDelta',
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

  late final SaleItemModifierUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid saleItemId;

  late final _is.ColumnUuid modifierId;

  late final _is.ColumnString groupName;

  late final _is.ColumnString name;

  late final _is.ColumnInt priceDelta;

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
    saleItemId,
    modifierId,
    groupName,
    name,
    priceDelta,
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

class SaleItemModifierInclude extends _is.IncludeObject {
  SaleItemModifierInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => SaleItemModifier.t;
}

class SaleItemModifierIncludeList extends _is.IncludeList {
  SaleItemModifierIncludeList._({
    _is.WhereExpressionBuilder<SaleItemModifierTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SaleItemModifier.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => SaleItemModifier.t;
}

class SaleItemModifierRepository {
  const SaleItemModifierRepository._();

  /// Returns a list of [SaleItemModifier]s matching the given query parameters.
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
  Future<List<SaleItemModifier>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleItemModifierTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleItemModifierTable>? orderBy,
    _is.OrderByListBuilder<SaleItemModifierTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SaleItemModifier>(
      where: where?.call(SaleItemModifier.t),
      orderBy: orderBy?.call(SaleItemModifier.t),
      orderByList: orderByList?.call(SaleItemModifier.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [SaleItemModifier]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `SaleItemModifier.t`.
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
  _ida.Stream<List<SaleItemModifier>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleItemModifierTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleItemModifierTable>? orderBy,
    _is.OrderByListBuilder<SaleItemModifierTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<SaleItemModifier>(
      where: where?.call(SaleItemModifier.t),
      orderBy: orderBy?.call(SaleItemModifier.t),
      orderByList: orderByList?.call(SaleItemModifier.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [SaleItemModifier] matching the given query parameters.
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
  Future<SaleItemModifier?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleItemModifierTable>? where,
    int? offset,
    _is.OrderByBuilder<SaleItemModifierTable>? orderBy,
    _is.OrderByListBuilder<SaleItemModifierTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SaleItemModifier>(
      where: where?.call(SaleItemModifier.t),
      orderBy: orderBy?.call(SaleItemModifier.t),
      orderByList: orderByList?.call(SaleItemModifier.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SaleItemModifier] by its [id] or null if no such row exists.
  Future<SaleItemModifier?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SaleItemModifier>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SaleItemModifier]s in the list and returns the inserted rows.
  ///
  /// The returned [SaleItemModifier]s will have their `id` fields set.
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
  Future<List<SaleItemModifier>> insert(
    _is.DatabaseSession session,
    List<SaleItemModifier> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SaleItemModifier>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SaleItemModifier] and returns the inserted row.
  ///
  /// The returned [SaleItemModifier] will have its `id` field set.
  Future<SaleItemModifier> insertRow(
    _is.DatabaseSession session,
    SaleItemModifier row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SaleItemModifier>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SaleItemModifier]s in the list and returns the resulting rows.
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
  /// The returned [SaleItemModifier]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleItemModifier>> upsert(
    _is.DatabaseSession session,
    List<SaleItemModifier> rows, {
    required _is.ColumnSelections<SaleItemModifierTable> conflictColumns,
    _is.ColumnSelections<SaleItemModifierTable>? updateColumns,
    _is.WhereExpressionBuilder<SaleItemModifierTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SaleItemModifier>(
      rows,
      conflictColumns: conflictColumns(SaleItemModifier.t),
      updateColumns: updateColumns?.call(SaleItemModifier.t),
      updateWhere: updateWhere?.call(SaleItemModifier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SaleItemModifier] and returns the resulting row.
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
  /// The returned [SaleItemModifier] will have its `id` field set.
  Future<SaleItemModifier?> upsertRow(
    _is.DatabaseSession session,
    SaleItemModifier row, {
    required _is.ColumnSelections<SaleItemModifierTable> conflictColumns,
    _is.ColumnSelections<SaleItemModifierTable>? updateColumns,
    _is.WhereExpressionBuilder<SaleItemModifierTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SaleItemModifier>(
      row,
      conflictColumns: conflictColumns(SaleItemModifier.t),
      updateColumns: updateColumns?.call(SaleItemModifier.t),
      updateWhere: updateWhere?.call(SaleItemModifier.t),
      transaction: transaction,
    );
  }

  /// Updates all [SaleItemModifier]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleItemModifier>> update(
    _is.DatabaseSession session,
    List<SaleItemModifier> rows, {
    _is.ColumnSelections<SaleItemModifierTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SaleItemModifier>(
      rows,
      columns: columns?.call(SaleItemModifier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SaleItemModifier]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SaleItemModifier> updateRow(
    _is.DatabaseSession session,
    SaleItemModifier row, {
    _is.ColumnSelections<SaleItemModifierTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SaleItemModifier>(
      row,
      columns: columns?.call(SaleItemModifier.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SaleItemModifier] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SaleItemModifier?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<SaleItemModifierUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SaleItemModifier>(
      id,
      columnValues: columnValues(SaleItemModifier.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SaleItemModifier]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleItemModifier>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SaleItemModifierUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<SaleItemModifierTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleItemModifierTable>? orderBy,
    _is.OrderByListBuilder<SaleItemModifierTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SaleItemModifier>(
      columnValues: columnValues(SaleItemModifier.t.updateTable),
      where: where(SaleItemModifier.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SaleItemModifier.t),
      orderByList: orderByList?.call(SaleItemModifier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SaleItemModifier]s in the list and returns the deleted rows.
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
  Future<List<SaleItemModifier>> delete(
    _is.DatabaseSession session,
    List<SaleItemModifier> rows, {
    _is.OrderByBuilder<SaleItemModifierTable>? orderBy,
    _is.OrderByListBuilder<SaleItemModifierTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SaleItemModifier>(
      rows,
      orderBy: orderBy?.call(SaleItemModifier.t),
      orderByList: orderByList?.call(SaleItemModifier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SaleItemModifier].
  Future<SaleItemModifier> deleteRow(
    _is.DatabaseSession session,
    SaleItemModifier row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SaleItemModifier>(
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
  Future<List<SaleItemModifier>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SaleItemModifierTable> where,
    _is.OrderByBuilder<SaleItemModifierTable>? orderBy,
    _is.OrderByListBuilder<SaleItemModifierTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SaleItemModifier>(
      where: where(SaleItemModifier.t),
      orderBy: orderBy?.call(SaleItemModifier.t),
      orderByList: orderByList?.call(SaleItemModifier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleItemModifierTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SaleItemModifier>(
      where: where?.call(SaleItemModifier.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SaleItemModifier] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SaleItemModifierTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SaleItemModifier>(
      where: where(SaleItemModifier.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
