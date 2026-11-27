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
import '../organization/staff_access_kind.dart' as _ishvodhy;

/// Log masuk/keluar staf di perangkat kasir (F1-03h). Satu baris per
/// kejadian; tidak pernah diubah.
abstract class StaffAccessLog
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  StaffAccessLog._({
    _isc.UuidValue? id,
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
  }) : id = id ?? const _isc.Uuid().v7obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory StaffAccessLog({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue deviceId,
    required _isc.UuidValue staffId,
    required _ishvodhy.StaffAccessKind kind,
    required DateTime occurredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _StaffAccessLogImpl;

  factory StaffAccessLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return StaffAccessLog(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      deviceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['deviceId'],
      ),
      staffId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['staffId'],
      ),
      kind: _ishvodhy.StaffAccessKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      occurredAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['occurredAt'],
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

  static final t = StaffAccessLogTable();

  static const db = StaffAccessLogRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue outletId;

  _isc.UuidValue deviceId;

  _isc.UuidValue staffId;

  _ishvodhy.StaffAccessKind kind;

  DateTime occurredAt;

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

  /// Returns a shallow copy of this [StaffAccessLog]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  StaffAccessLog copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? deviceId,
    _isc.UuidValue? staffId,
    _ishvodhy.StaffAccessKind? kind,
    DateTime? occurredAt,
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
    _isd.WhereExpressionBuilder<StaffAccessLogTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StaffAccessLogTable>? orderBy,
    _isd.OrderByListBuilder<StaffAccessLogTable>? orderByList,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _StaffAccessLogImpl extends StaffAccessLog {
  _StaffAccessLogImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue deviceId,
    required _isc.UuidValue staffId,
    required _ishvodhy.StaffAccessKind kind,
    required DateTime occurredAt,
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
  @_isc.useResult
  @override
  StaffAccessLog copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? deviceId,
    _isc.UuidValue? staffId,
    _ishvodhy.StaffAccessKind? kind,
    DateTime? occurredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
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

class StaffAccessLogUpdateTable extends _isd.UpdateTable<StaffAccessLogTable> {
  StaffAccessLogUpdateTable(super.table);

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

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> deviceId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.deviceId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> staffId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.staffId,
    value,
  );

  _isd.ColumnValue<_ishvodhy.StaffAccessKind, _ishvodhy.StaffAccessKind> kind(
    _ishvodhy.StaffAccessKind value,
  ) => _isd.ColumnValue(
    table.kind,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> occurredAt(DateTime value) =>
      _isd.ColumnValue(
        table.occurredAt,
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

class StaffAccessLogTable extends _isd.Table<_isc.UuidValue> {
  StaffAccessLogTable({super.tableRelation})
    : super(tableName: 'staff_access_logs') {
    updateTable = StaffAccessLogUpdateTable(this);
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
    deviceId = _isd.ColumnUuid(
      'device_id',
      this,
      fieldName: 'deviceId',
    );
    staffId = _isd.ColumnUuid(
      'staff_id',
      this,
      fieldName: 'staffId',
    );
    kind = _isd.ColumnEnum(
      'kind',
      this,
      _isd.EnumSerialization.byName,
    );
    occurredAt = _isd.ColumnDateTime(
      'occurred_at',
      this,
      fieldName: 'occurredAt',
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

  late final StaffAccessLogUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid outletId;

  late final _isd.ColumnUuid deviceId;

  late final _isd.ColumnUuid staffId;

  late final _isd.ColumnEnum<_ishvodhy.StaffAccessKind> kind;

  late final _isd.ColumnDateTime occurredAt;

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

class StaffAccessLogInclude extends _isd.IncludeObject {
  StaffAccessLogInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => StaffAccessLog.t;
}

class StaffAccessLogIncludeList extends _isd.IncludeList {
  StaffAccessLogIncludeList._({
    _isd.WhereExpressionBuilder<StaffAccessLogTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StaffAccessLog.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => StaffAccessLog.t;
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StaffAccessLogTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StaffAccessLogTable>? orderBy,
    _isd.OrderByListBuilder<StaffAccessLogTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StaffAccessLogTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StaffAccessLogTable>? orderBy,
    _isd.OrderByListBuilder<StaffAccessLogTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StaffAccessLogTable>? where,
    int? offset,
    _isd.OrderByBuilder<StaffAccessLogTable>? orderBy,
    _isd.OrderByListBuilder<StaffAccessLogTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session,
    List<StaffAccessLog> rows, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    StaffAccessLog row, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<StaffAccessLog> rows, {
    required _isd.ColumnSelections<StaffAccessLogTable> conflictColumns,
    _isd.ColumnSelections<StaffAccessLogTable>? updateColumns,
    _isd.WhereExpressionBuilder<StaffAccessLogTable>? updateWhere,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    StaffAccessLog row, {
    required _isd.ColumnSelections<StaffAccessLogTable> conflictColumns,
    _isd.ColumnSelections<StaffAccessLogTable>? updateColumns,
    _isd.WhereExpressionBuilder<StaffAccessLogTable>? updateWhere,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<StaffAccessLog> rows, {
    _isd.ColumnSelections<StaffAccessLogTable>? columns,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    StaffAccessLog row, {
    _isd.ColumnSelections<StaffAccessLogTable>? columns,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<StaffAccessLogUpdateTable>
    columnValues,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<StaffAccessLogUpdateTable>
    columnValues,
    required _isd.WhereExpressionBuilder<StaffAccessLogTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StaffAccessLogTable>? orderBy,
    _isd.OrderByListBuilder<StaffAccessLogTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<StaffAccessLog> rows, {
    _isd.OrderByBuilder<StaffAccessLogTable>? orderBy,
    _isd.OrderByListBuilder<StaffAccessLogTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    StaffAccessLog row, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<StaffAccessLogTable> where,
    _isd.OrderByBuilder<StaffAccessLogTable>? orderBy,
    _isd.OrderByListBuilder<StaffAccessLogTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StaffAccessLogTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<StaffAccessLog>(
      where: where?.call(StaffAccessLog.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StaffAccessLog] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<StaffAccessLogTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StaffAccessLog>(
      where: where(StaffAccessLog.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
