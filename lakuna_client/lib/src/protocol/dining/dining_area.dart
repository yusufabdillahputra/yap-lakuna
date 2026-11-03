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
import '../dining/dining_layout_mode.dart' as _iks3qkj2;

/// Area meja per cabang (F1-10), mis. Indoor, Teras.
abstract class DiningArea
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  DiningArea._({
    _isc.UuidValue? id,
    required this.tenantId,
    required this.outletId,
    required this.name,
    int? sortOrder,
    _iks3qkj2.DiningLayoutMode? layoutMode,
    this.floorMediaId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _isc.Uuid().v7obj(),
       sortOrder = sortOrder ?? 0,
       layoutMode = layoutMode ?? _iks3qkj2.DiningLayoutMode.grid,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory DiningArea({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required String name,
    int? sortOrder,
    _iks3qkj2.DiningLayoutMode? layoutMode,
    _isc.UuidValue? floorMediaId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _DiningAreaImpl;

  factory DiningArea.fromJson(Map<String, dynamic> jsonSerialization) {
    return DiningArea(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      name: jsonSerialization['name'] as String,
      sortOrder: jsonSerialization['sortOrder'] as int?,
      layoutMode: jsonSerialization['layoutMode'] == null
          ? null
          : _iks3qkj2.DiningLayoutMode.fromJson(
              (jsonSerialization['layoutMode'] as String),
            ),
      floorMediaId: jsonSerialization['floorMediaId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['floorMediaId'],
            ),
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

  static final t = DiningAreaTable();

  static const db = DiningAreaRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue outletId;

  String name;

  int sortOrder;

  _iks3qkj2.DiningLayoutMode layoutMode;

  _isc.UuidValue? floorMediaId;

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

  /// Returns a shallow copy of this [DiningArea]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DiningArea copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    String? name,
    int? sortOrder,
    _iks3qkj2.DiningLayoutMode? layoutMode,
    _isc.UuidValue? floorMediaId = const _isc.$UndefinedUuidValue(),
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
      '__className__': 'DiningArea',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'name': name,
      'sortOrder': sortOrder,
      'layoutMode': layoutMode.toJson(),
      if (floorMediaId != null) 'floorMediaId': floorMediaId?.toJson(),
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
      '__className__': 'DiningArea',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'name': name,
      'sortOrder': sortOrder,
      'layoutMode': layoutMode.toJson(),
      if (floorMediaId != null) 'floorMediaId': floorMediaId?.toJson(),
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

  static DiningAreaInclude include() {
    return DiningAreaInclude._();
  }

  static DiningAreaIncludeList includeList({
    _isd.WhereExpressionBuilder<DiningAreaTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<DiningAreaTable>? orderBy,
    _isd.OrderByListBuilder<DiningAreaTable>? orderByList,
    DiningAreaInclude? include,
  }) {
    return DiningAreaIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DiningArea.t),
      orderByList: orderByList?.call(DiningArea.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _DiningAreaImpl extends DiningArea {
  _DiningAreaImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required String name,
    int? sortOrder,
    _iks3qkj2.DiningLayoutMode? layoutMode,
    _isc.UuidValue? floorMediaId,
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
         outletId: outletId,
         name: name,
         sortOrder: sortOrder,
         layoutMode: layoutMode,
         floorMediaId: floorMediaId,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [DiningArea]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DiningArea copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    String? name,
    int? sortOrder,
    _iks3qkj2.DiningLayoutMode? layoutMode,
    _isc.UuidValue? floorMediaId = const _isc.$UndefinedUuidValue(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return DiningArea(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      layoutMode: layoutMode ?? this.layoutMode,
      floorMediaId: floorMediaId is _isc.UndefinedSentinel
          ? this.floorMediaId
          : floorMediaId,
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

class DiningAreaUpdateTable extends _isd.UpdateTable<DiningAreaTable> {
  DiningAreaUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> tenantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.tenantId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> outletId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.outletId,
    value,
  );

  _isd.ColumnValue<String, String> name(String value) => _isd.ColumnValue(
    table.name,
    value,
  );

  _isd.ColumnValue<int, int> sortOrder(int value) => _isd.ColumnValue(
    table.sortOrder,
    value,
  );

  _isd.ColumnValue<_iks3qkj2.DiningLayoutMode, _iks3qkj2.DiningLayoutMode>
  layoutMode(_iks3qkj2.DiningLayoutMode value) => _isd.ColumnValue(
    table.layoutMode,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> floorMediaId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.floorMediaId,
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

class DiningAreaTable extends _isd.Table<_isc.UuidValue> {
  DiningAreaTable({super.tableRelation}) : super(tableName: 'dining_areas') {
    updateTable = DiningAreaUpdateTable(this);
    tenantId = _isd.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    outletId = _isd.ColumnUuid(
      'outlet_id',
      this,
      fieldName: 'outletId',
    );
    name = _isd.ColumnString(
      'name',
      this,
    );
    sortOrder = _isd.ColumnInt(
      'sort_order',
      this,
      hasDefault: true,
      fieldName: 'sortOrder',
    );
    layoutMode = _isd.ColumnEnum(
      'layout_mode',
      this,
      _isd.EnumSerialization.byName,
      hasDefault: true,
      fieldName: 'layoutMode',
    );
    floorMediaId = _isd.ColumnUuid(
      'floor_media_id',
      this,
      fieldName: 'floorMediaId',
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

  late final DiningAreaUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid outletId;

  late final _isd.ColumnString name;

  late final _isd.ColumnInt sortOrder;

  late final _isd.ColumnEnum<_iks3qkj2.DiningLayoutMode> layoutMode;

  late final _isd.ColumnUuid floorMediaId;

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
    outletId,
    name,
    sortOrder,
    layoutMode,
    floorMediaId,
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

class DiningAreaInclude extends _isd.IncludeObject {
  DiningAreaInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => DiningArea.t;
}

class DiningAreaIncludeList extends _isd.IncludeList {
  DiningAreaIncludeList._({
    _isd.WhereExpressionBuilder<DiningAreaTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DiningArea.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => DiningArea.t;
}

class DiningAreaRepository {
  const DiningAreaRepository._();

  /// Returns a list of [DiningArea]s matching the given query parameters.
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
  Future<List<DiningArea>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<DiningAreaTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<DiningAreaTable>? orderBy,
    _isd.OrderByListBuilder<DiningAreaTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DiningArea>(
      where: where?.call(DiningArea.t),
      orderBy: orderBy?.call(DiningArea.t),
      orderByList: orderByList?.call(DiningArea.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [DiningArea]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `DiningArea.t`.
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
  _ida.Stream<List<DiningArea>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<DiningAreaTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<DiningAreaTable>? orderBy,
    _isd.OrderByListBuilder<DiningAreaTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<DiningArea>(
      where: where?.call(DiningArea.t),
      orderBy: orderBy?.call(DiningArea.t),
      orderByList: orderByList?.call(DiningArea.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [DiningArea] matching the given query parameters.
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
  Future<DiningArea?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<DiningAreaTable>? where,
    int? offset,
    _isd.OrderByBuilder<DiningAreaTable>? orderBy,
    _isd.OrderByListBuilder<DiningAreaTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DiningArea>(
      where: where?.call(DiningArea.t),
      orderBy: orderBy?.call(DiningArea.t),
      orderByList: orderByList?.call(DiningArea.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DiningArea] by its [id] or null if no such row exists.
  Future<DiningArea?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DiningArea>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DiningArea]s in the list and returns the inserted rows.
  ///
  /// The returned [DiningArea]s will have their `id` fields set.
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
  Future<List<DiningArea>> insert(
    _isd.DatabaseSession session,
    List<DiningArea> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DiningArea>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DiningArea] and returns the inserted row.
  ///
  /// The returned [DiningArea] will have its `id` field set.
  Future<DiningArea> insertRow(
    _isd.DatabaseSession session,
    DiningArea row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<DiningArea>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DiningArea]s in the list and returns the resulting rows.
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
  /// The returned [DiningArea]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningArea>> upsert(
    _isd.DatabaseSession session,
    List<DiningArea> rows, {
    required _isd.ColumnSelections<DiningAreaTable> conflictColumns,
    _isd.ColumnSelections<DiningAreaTable>? updateColumns,
    _isd.WhereExpressionBuilder<DiningAreaTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DiningArea>(
      rows,
      conflictColumns: conflictColumns(DiningArea.t),
      updateColumns: updateColumns?.call(DiningArea.t),
      updateWhere: updateWhere?.call(DiningArea.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DiningArea] and returns the resulting row.
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
  /// The returned [DiningArea] will have its `id` field set.
  Future<DiningArea?> upsertRow(
    _isd.DatabaseSession session,
    DiningArea row, {
    required _isd.ColumnSelections<DiningAreaTable> conflictColumns,
    _isd.ColumnSelections<DiningAreaTable>? updateColumns,
    _isd.WhereExpressionBuilder<DiningAreaTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DiningArea>(
      row,
      conflictColumns: conflictColumns(DiningArea.t),
      updateColumns: updateColumns?.call(DiningArea.t),
      updateWhere: updateWhere?.call(DiningArea.t),
      transaction: transaction,
    );
  }

  /// Updates all [DiningArea]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningArea>> update(
    _isd.DatabaseSession session,
    List<DiningArea> rows, {
    _isd.ColumnSelections<DiningAreaTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DiningArea>(
      rows,
      columns: columns?.call(DiningArea.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DiningArea]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DiningArea> updateRow(
    _isd.DatabaseSession session,
    DiningArea row, {
    _isd.ColumnSelections<DiningAreaTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<DiningArea>(
      row,
      columns: columns?.call(DiningArea.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DiningArea] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DiningArea?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<DiningAreaUpdateTable> columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<DiningArea>(
      id,
      columnValues: columnValues(DiningArea.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DiningArea]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DiningArea>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<DiningAreaUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<DiningAreaTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<DiningAreaTable>? orderBy,
    _isd.OrderByListBuilder<DiningAreaTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DiningArea>(
      columnValues: columnValues(DiningArea.t.updateTable),
      where: where(DiningArea.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DiningArea.t),
      orderByList: orderByList?.call(DiningArea.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DiningArea]s in the list and returns the deleted rows.
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
  Future<List<DiningArea>> delete(
    _isd.DatabaseSession session,
    List<DiningArea> rows, {
    _isd.OrderByBuilder<DiningAreaTable>? orderBy,
    _isd.OrderByListBuilder<DiningAreaTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DiningArea>(
      rows,
      orderBy: orderBy?.call(DiningArea.t),
      orderByList: orderByList?.call(DiningArea.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DiningArea].
  Future<DiningArea> deleteRow(
    _isd.DatabaseSession session,
    DiningArea row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DiningArea>(
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
  Future<List<DiningArea>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<DiningAreaTable> where,
    _isd.OrderByBuilder<DiningAreaTable>? orderBy,
    _isd.OrderByListBuilder<DiningAreaTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DiningArea>(
      where: where(DiningArea.t),
      orderBy: orderBy?.call(DiningArea.t),
      orderByList: orderByList?.call(DiningArea.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<DiningAreaTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<DiningArea>(
      where: where?.call(DiningArea.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DiningArea] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<DiningAreaTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DiningArea>(
      where: where(DiningArea.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
