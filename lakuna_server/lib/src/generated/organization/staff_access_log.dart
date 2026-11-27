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
import '../organization/staff_access_kind.dart' as _ishvodhy;

/// Log masuk/keluar staf di perangkat kasir (F1-03h). Satu baris per
/// kejadian; tidak pernah diubah.
abstract class StaffAccessLog
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  StaffAccessLog._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.outletId,
    required this.deviceId,
    required this.staffId,
    required this.kind,
    required this.occurredAt,
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

  factory StaffAccessLog({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    required _is.UuidValue staffId,
    required _ishvodhy.StaffAccessKind kind,
    required DateTime occurredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _StaffAccessLogImpl;

  factory StaffAccessLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return StaffAccessLog(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      deviceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['deviceId'],
      ),
      staffId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['staffId'],
      ),
      kind: _ishvodhy.StaffAccessKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      occurredAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['occurredAt'],
      ),
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

  static final t = StaffAccessLogTable();

  static const db = StaffAccessLogRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue outletId;

  _is.UuidValue deviceId;

  _is.UuidValue staffId;

  _ishvodhy.StaffAccessKind kind;

  DateTime occurredAt;

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

  /// Returns a shallow copy of this [StaffAccessLog]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StaffAccessLog copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _is.UuidValue? staffId,
    _ishvodhy.StaffAccessKind? kind,
    DateTime? occurredAt,
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
      '__className__': 'StaffAccessLog',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      'staffId': staffId.toJson(),
      'kind': kind.toJson(),
      'occurredAt': occurredAt.toJson(),
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
      '__className__': 'StaffAccessLog',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      'staffId': staffId.toJson(),
      'kind': kind.toJson(),
      'occurredAt': occurredAt.toJson(),
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

  static StaffAccessLogInclude include() {
    return StaffAccessLogInclude._();
  }

  static StaffAccessLogIncludeList includeList({
    _is.WhereExpressionBuilder<StaffAccessLogTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StaffAccessLogTable>? orderBy,
    _is.OrderByListBuilder<StaffAccessLogTable>? orderByList,
    StaffAccessLogInclude? include,
  }) {
    return StaffAccessLogIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StaffAccessLog.t),
      orderByList: orderByList?.call(StaffAccessLog.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _StaffAccessLogImpl extends StaffAccessLog {
  _StaffAccessLogImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    required _is.UuidValue staffId,
    required _ishvodhy.StaffAccessKind kind,
    required DateTime occurredAt,
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
         outletId: outletId,
         deviceId: deviceId,
         staffId: staffId,
         kind: kind,
         occurredAt: occurredAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [StaffAccessLog]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StaffAccessLog copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _is.UuidValue? staffId,
    _ishvodhy.StaffAccessKind? kind,
    DateTime? occurredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return StaffAccessLog(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      deviceId: deviceId ?? this.deviceId,
      staffId: staffId ?? this.staffId,
      kind: kind ?? this.kind,
      occurredAt: occurredAt ?? this.occurredAt,
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

class StaffAccessLogUpdateTable extends _is.UpdateTable<StaffAccessLogTable> {
  StaffAccessLogUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> outletId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.outletId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> deviceId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.deviceId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> staffId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.staffId,
        value,
      );

  _is.ColumnValue<_ishvodhy.StaffAccessKind, _ishvodhy.StaffAccessKind> kind(
    _ishvodhy.StaffAccessKind value,
  ) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> occurredAt(DateTime value) =>
      _is.ColumnValue(
        table.occurredAt,
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

class StaffAccessLogTable extends _is.Table<_is.UuidValue> {
  StaffAccessLogTable({super.tableRelation})
    : super(tableName: 'staff_access_logs') {
    updateTable = StaffAccessLogUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    outletId = _is.ColumnUuid(
      'outlet_id',
      this,
      fieldName: 'outletId',
    );
    deviceId = _is.ColumnUuid(
      'device_id',
      this,
      fieldName: 'deviceId',
    );
    staffId = _is.ColumnUuid(
      'staff_id',
      this,
      fieldName: 'staffId',
    );
    kind = _is.ColumnEnum(
      'kind',
      this,
      _is.EnumSerialization.byName,
    );
    occurredAt = _is.ColumnDateTime(
      'occurred_at',
      this,
      fieldName: 'occurredAt',
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

  late final StaffAccessLogUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid outletId;

  late final _is.ColumnUuid deviceId;

  late final _is.ColumnUuid staffId;

  late final _is.ColumnEnum<_ishvodhy.StaffAccessKind> kind;

  late final _is.ColumnDateTime occurredAt;

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
    outletId,
    deviceId,
    staffId,
    kind,
    occurredAt,
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

class StaffAccessLogInclude extends _is.IncludeObject {
  StaffAccessLogInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => StaffAccessLog.t;
}

class StaffAccessLogIncludeList extends _is.IncludeList {
  StaffAccessLogIncludeList._({
    _is.WhereExpressionBuilder<StaffAccessLogTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StaffAccessLog.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => StaffAccessLog.t;
}

class StaffAccessLogRepository {
  const StaffAccessLogRepository._();

  /// Returns a list of [StaffAccessLog]s matching the given query parameters.
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
  Future<List<StaffAccessLog>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StaffAccessLogTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StaffAccessLogTable>? orderBy,
    _is.OrderByListBuilder<StaffAccessLogTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StaffAccessLog>(
      where: where?.call(StaffAccessLog.t),
      orderBy: orderBy?.call(StaffAccessLog.t),
      orderByList: orderByList?.call(StaffAccessLog.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [StaffAccessLog]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `StaffAccessLog.t`.
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
  _ida.Stream<List<StaffAccessLog>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StaffAccessLogTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StaffAccessLogTable>? orderBy,
    _is.OrderByListBuilder<StaffAccessLogTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<StaffAccessLog>(
      where: where?.call(StaffAccessLog.t),
      orderBy: orderBy?.call(StaffAccessLog.t),
      orderByList: orderByList?.call(StaffAccessLog.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [StaffAccessLog] matching the given query parameters.
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
  Future<StaffAccessLog?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StaffAccessLogTable>? where,
    int? offset,
    _is.OrderByBuilder<StaffAccessLogTable>? orderBy,
    _is.OrderByListBuilder<StaffAccessLogTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StaffAccessLog>(
      where: where?.call(StaffAccessLog.t),
      orderBy: orderBy?.call(StaffAccessLog.t),
      orderByList: orderByList?.call(StaffAccessLog.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StaffAccessLog] by its [id] or null if no such row exists.
  Future<StaffAccessLog?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StaffAccessLog>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StaffAccessLog]s in the list and returns the inserted rows.
  ///
  /// The returned [StaffAccessLog]s will have their `id` fields set.
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
  Future<List<StaffAccessLog>> insert(
    _is.DatabaseSession session,
    List<StaffAccessLog> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StaffAccessLog>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StaffAccessLog] and returns the inserted row.
  ///
  /// The returned [StaffAccessLog] will have its `id` field set.
  Future<StaffAccessLog> insertRow(
    _is.DatabaseSession session,
    StaffAccessLog row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StaffAccessLog>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StaffAccessLog]s in the list and returns the resulting rows.
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
  /// The returned [StaffAccessLog]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StaffAccessLog>> upsert(
    _is.DatabaseSession session,
    List<StaffAccessLog> rows, {
    required _is.ColumnSelections<StaffAccessLogTable> conflictColumns,
    _is.ColumnSelections<StaffAccessLogTable>? updateColumns,
    _is.WhereExpressionBuilder<StaffAccessLogTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StaffAccessLog>(
      rows,
      conflictColumns: conflictColumns(StaffAccessLog.t),
      updateColumns: updateColumns?.call(StaffAccessLog.t),
      updateWhere: updateWhere?.call(StaffAccessLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StaffAccessLog] and returns the resulting row.
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
  /// The returned [StaffAccessLog] will have its `id` field set.
  Future<StaffAccessLog?> upsertRow(
    _is.DatabaseSession session,
    StaffAccessLog row, {
    required _is.ColumnSelections<StaffAccessLogTable> conflictColumns,
    _is.ColumnSelections<StaffAccessLogTable>? updateColumns,
    _is.WhereExpressionBuilder<StaffAccessLogTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StaffAccessLog>(
      row,
      conflictColumns: conflictColumns(StaffAccessLog.t),
      updateColumns: updateColumns?.call(StaffAccessLog.t),
      updateWhere: updateWhere?.call(StaffAccessLog.t),
      transaction: transaction,
    );
  }

  /// Updates all [StaffAccessLog]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StaffAccessLog>> update(
    _is.DatabaseSession session,
    List<StaffAccessLog> rows, {
    _is.ColumnSelections<StaffAccessLogTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StaffAccessLog>(
      rows,
      columns: columns?.call(StaffAccessLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StaffAccessLog]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StaffAccessLog> updateRow(
    _is.DatabaseSession session,
    StaffAccessLog row, {
    _is.ColumnSelections<StaffAccessLogTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StaffAccessLog>(
      row,
      columns: columns?.call(StaffAccessLog.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StaffAccessLog] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StaffAccessLog?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<StaffAccessLogUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StaffAccessLog>(
      id,
      columnValues: columnValues(StaffAccessLog.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StaffAccessLog]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StaffAccessLog>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StaffAccessLogUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StaffAccessLogTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StaffAccessLogTable>? orderBy,
    _is.OrderByListBuilder<StaffAccessLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StaffAccessLog>(
      columnValues: columnValues(StaffAccessLog.t.updateTable),
      where: where(StaffAccessLog.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StaffAccessLog.t),
      orderByList: orderByList?.call(StaffAccessLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StaffAccessLog]s in the list and returns the deleted rows.
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
  Future<List<StaffAccessLog>> delete(
    _is.DatabaseSession session,
    List<StaffAccessLog> rows, {
    _is.OrderByBuilder<StaffAccessLogTable>? orderBy,
    _is.OrderByListBuilder<StaffAccessLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StaffAccessLog>(
      rows,
      orderBy: orderBy?.call(StaffAccessLog.t),
      orderByList: orderByList?.call(StaffAccessLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StaffAccessLog].
  Future<StaffAccessLog> deleteRow(
    _is.DatabaseSession session,
    StaffAccessLog row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StaffAccessLog>(
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
  Future<List<StaffAccessLog>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StaffAccessLogTable> where,
    _is.OrderByBuilder<StaffAccessLogTable>? orderBy,
    _is.OrderByListBuilder<StaffAccessLogTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StaffAccessLog>(
      where: where(StaffAccessLog.t),
      orderBy: orderBy?.call(StaffAccessLog.t),
      orderByList: orderByList?.call(StaffAccessLog.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StaffAccessLogTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StaffAccessLog>(
      where: where?.call(StaffAccessLog.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StaffAccessLog] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StaffAccessLogTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StaffAccessLog>(
      where: where(StaffAccessLog.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
