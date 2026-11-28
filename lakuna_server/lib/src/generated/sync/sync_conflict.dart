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

/// Baris yang kalah atau ditolak saat push (F2-01 aturan 6, 7a, 8a), untuk
/// ditinjau di F2-03. Hanya ada di server.
abstract class SyncConflict
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SyncConflict._({
    this.id,
    required this.tenantId,
    required this.entity,
    required this.rowId,
    this.winnerHlc,
    required this.loserHlc,
    this.loserDeviceId,
    required this.loserPayloadJson,
    required this.reason,
    DateTime? createdAt,
    this.resolvedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SyncConflict({
    int? id,
    required _is.UuidValue tenantId,
    required String entity,
    required _is.UuidValue rowId,
    String? winnerHlc,
    required String loserHlc,
    _is.UuidValue? loserDeviceId,
    required String loserPayloadJson,
    required String reason,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) = _SyncConflictImpl;

  factory SyncConflict.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncConflict(
      id: jsonSerialization['id'] as int?,
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      entity: jsonSerialization['entity'] as String,
      rowId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['rowId']),
      winnerHlc: jsonSerialization['winnerHlc'] as String?,
      loserHlc: jsonSerialization['loserHlc'] as String,
      loserDeviceId: jsonSerialization['loserDeviceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['loserDeviceId'],
            ),
      loserPayloadJson: jsonSerialization['loserPayloadJson'] as String,
      reason: jsonSerialization['reason'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['resolvedAt']),
    );
  }

  static final t = SyncConflictTable();

  static const db = SyncConflictRepository._();

  @override
  int? id;

  _is.UuidValue tenantId;

  /// Nama tabel (`tableName` dipakai Serverpod).
  String entity;

  _is.UuidValue rowId;

  /// HLC baris server yang menang; null bila baris server tidak ada.
  String? winnerHlc;

  String loserHlc;

  _is.UuidValue? loserDeviceId;

  String loserPayloadJson;

  /// `lww`, `final`, `unique`, atau `merged`.
  String reason;

  DateTime createdAt;

  DateTime? resolvedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SyncConflict]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SyncConflict copyWith({
    int? id,
    _is.UuidValue? tenantId,
    String? entity,
    _is.UuidValue? rowId,
    String? winnerHlc,
    String? loserHlc,
    _is.UuidValue? loserDeviceId = const _is.$UndefinedUuidValue(),
    String? loserPayloadJson,
    String? reason,
    DateTime? createdAt,
    DateTime? resolvedAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncConflict',
      if (id != null) 'id': id,
      'tenantId': tenantId.toJson(),
      'entity': entity,
      'rowId': rowId.toJson(),
      if (winnerHlc != null) 'winnerHlc': winnerHlc,
      'loserHlc': loserHlc,
      if (loserDeviceId != null) 'loserDeviceId': loserDeviceId?.toJson(),
      'loserPayloadJson': loserPayloadJson,
      'reason': reason,
      'createdAt': createdAt.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static SyncConflictInclude include() {
    return SyncConflictInclude._();
  }

  static SyncConflictIncludeList includeList({
    _is.WhereExpressionBuilder<SyncConflictTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SyncConflictTable>? orderBy,
    _is.OrderByListBuilder<SyncConflictTable>? orderByList,
    SyncConflictInclude? include,
  }) {
    return SyncConflictIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SyncConflict.t),
      orderByList: orderByList?.call(SyncConflict.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SyncConflictImpl extends SyncConflict {
  _SyncConflictImpl({
    int? id,
    required _is.UuidValue tenantId,
    required String entity,
    required _is.UuidValue rowId,
    String? winnerHlc,
    required String loserHlc,
    _is.UuidValue? loserDeviceId,
    required String loserPayloadJson,
    required String reason,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) : super._(
         id: id,
         tenantId: tenantId,
         entity: entity,
         rowId: rowId,
         winnerHlc: winnerHlc,
         loserHlc: loserHlc,
         loserDeviceId: loserDeviceId,
         loserPayloadJson: loserPayloadJson,
         reason: reason,
         createdAt: createdAt,
         resolvedAt: resolvedAt,
       );

  /// Returns a shallow copy of this [SyncConflict]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SyncConflict copyWith({
    Object? id = _Undefined,
    _is.UuidValue? tenantId,
    String? entity,
    _is.UuidValue? rowId,
    Object? winnerHlc = _Undefined,
    String? loserHlc,
    _is.UuidValue? loserDeviceId = const _is.$UndefinedUuidValue(),
    String? loserPayloadJson,
    String? reason,
    DateTime? createdAt,
    DateTime? resolvedAt = const _is.$UndefinedDateTime(),
  }) {
    return SyncConflict(
      id: id is int? ? id : this.id,
      tenantId: tenantId ?? this.tenantId,
      entity: entity ?? this.entity,
      rowId: rowId ?? this.rowId,
      winnerHlc: winnerHlc is String? ? winnerHlc : this.winnerHlc,
      loserHlc: loserHlc ?? this.loserHlc,
      loserDeviceId: loserDeviceId is _is.UndefinedSentinel
          ? this.loserDeviceId
          : loserDeviceId,
      loserPayloadJson: loserPayloadJson ?? this.loserPayloadJson,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt is _is.UndefinedSentinel
          ? this.resolvedAt
          : resolvedAt,
    );
  }
}

class SyncConflictUpdateTable extends _is.UpdateTable<SyncConflictTable> {
  SyncConflictUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<String, String> entity(String value) => _is.ColumnValue(
    table.entity,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> rowId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.rowId,
        value,
      );

  _is.ColumnValue<String, String> winnerHlc(String? value) => _is.ColumnValue(
    table.winnerHlc,
    value,
  );

  _is.ColumnValue<String, String> loserHlc(String value) => _is.ColumnValue(
    table.loserHlc,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> loserDeviceId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.loserDeviceId,
    value,
  );

  _is.ColumnValue<String, String> loserPayloadJson(String value) =>
      _is.ColumnValue(
        table.loserPayloadJson,
        value,
      );

  _is.ColumnValue<String, String> reason(String value) => _is.ColumnValue(
    table.reason,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> resolvedAt(DateTime? value) =>
      _is.ColumnValue(
        table.resolvedAt,
        value,
      );
}

class SyncConflictTable extends _is.Table<int?> {
  SyncConflictTable({super.tableRelation})
    : super(tableName: 'sync_conflicts') {
    updateTable = SyncConflictUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    entity = _is.ColumnString(
      'table_name',
      this,
      fieldName: 'entity',
    );
    rowId = _is.ColumnUuid(
      'row_id',
      this,
      fieldName: 'rowId',
    );
    winnerHlc = _is.ColumnString(
      'winner_hlc',
      this,
      fieldName: 'winnerHlc',
    );
    loserHlc = _is.ColumnString(
      'loser_hlc',
      this,
      fieldName: 'loserHlc',
    );
    loserDeviceId = _is.ColumnUuid(
      'loser_device_id',
      this,
      fieldName: 'loserDeviceId',
    );
    loserPayloadJson = _is.ColumnString(
      'loser_payload_json',
      this,
      fieldName: 'loserPayloadJson',
    );
    reason = _is.ColumnString(
      'reason',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'created_at',
      this,
      hasDefault: true,
      fieldName: 'createdAt',
    );
    resolvedAt = _is.ColumnDateTime(
      'resolved_at',
      this,
      fieldName: 'resolvedAt',
    );
  }

  late final SyncConflictUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  /// Nama tabel (`tableName` dipakai Serverpod).
  late final _is.ColumnString entity;

  late final _is.ColumnUuid rowId;

  /// HLC baris server yang menang; null bila baris server tidak ada.
  late final _is.ColumnString winnerHlc;

  late final _is.ColumnString loserHlc;

  late final _is.ColumnUuid loserDeviceId;

  late final _is.ColumnString loserPayloadJson;

  /// `lww`, `final`, `unique`, atau `merged`.
  late final _is.ColumnString reason;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime resolvedAt;

  @override
  List<_is.Column> get columns => [
    id,
    tenantId,
    entity,
    rowId,
    winnerHlc,
    loserHlc,
    loserDeviceId,
    loserPayloadJson,
    reason,
    createdAt,
    resolvedAt,
  ];
}

class SyncConflictInclude extends _is.IncludeObject {
  SyncConflictInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SyncConflict.t;
}

class SyncConflictIncludeList extends _is.IncludeList {
  SyncConflictIncludeList._({
    _is.WhereExpressionBuilder<SyncConflictTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SyncConflict.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SyncConflict.t;
}

class SyncConflictRepository {
  const SyncConflictRepository._();

  /// Returns a list of [SyncConflict]s matching the given query parameters.
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
  Future<List<SyncConflict>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SyncConflictTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SyncConflictTable>? orderBy,
    _is.OrderByListBuilder<SyncConflictTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SyncConflict>(
      where: where?.call(SyncConflict.t),
      orderBy: orderBy?.call(SyncConflict.t),
      orderByList: orderByList?.call(SyncConflict.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [SyncConflict]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `SyncConflict.t`.
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
  _ida.Stream<List<SyncConflict>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SyncConflictTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SyncConflictTable>? orderBy,
    _is.OrderByListBuilder<SyncConflictTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<SyncConflict>(
      where: where?.call(SyncConflict.t),
      orderBy: orderBy?.call(SyncConflict.t),
      orderByList: orderByList?.call(SyncConflict.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [SyncConflict] matching the given query parameters.
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
  Future<SyncConflict?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SyncConflictTable>? where,
    int? offset,
    _is.OrderByBuilder<SyncConflictTable>? orderBy,
    _is.OrderByListBuilder<SyncConflictTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SyncConflict>(
      where: where?.call(SyncConflict.t),
      orderBy: orderBy?.call(SyncConflict.t),
      orderByList: orderByList?.call(SyncConflict.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SyncConflict] by its [id] or null if no such row exists.
  Future<SyncConflict?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SyncConflict>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SyncConflict]s in the list and returns the inserted rows.
  ///
  /// The returned [SyncConflict]s will have their `id` fields set.
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
  Future<List<SyncConflict>> insert(
    _is.DatabaseSession session,
    List<SyncConflict> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SyncConflict>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SyncConflict] and returns the inserted row.
  ///
  /// The returned [SyncConflict] will have its `id` field set.
  Future<SyncConflict> insertRow(
    _is.DatabaseSession session,
    SyncConflict row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SyncConflict>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SyncConflict]s in the list and returns the resulting rows.
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
  /// The returned [SyncConflict]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SyncConflict>> upsert(
    _is.DatabaseSession session,
    List<SyncConflict> rows, {
    required _is.ColumnSelections<SyncConflictTable> conflictColumns,
    _is.ColumnSelections<SyncConflictTable>? updateColumns,
    _is.WhereExpressionBuilder<SyncConflictTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SyncConflict>(
      rows,
      conflictColumns: conflictColumns(SyncConflict.t),
      updateColumns: updateColumns?.call(SyncConflict.t),
      updateWhere: updateWhere?.call(SyncConflict.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SyncConflict] and returns the resulting row.
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
  /// The returned [SyncConflict] will have its `id` field set.
  Future<SyncConflict?> upsertRow(
    _is.DatabaseSession session,
    SyncConflict row, {
    required _is.ColumnSelections<SyncConflictTable> conflictColumns,
    _is.ColumnSelections<SyncConflictTable>? updateColumns,
    _is.WhereExpressionBuilder<SyncConflictTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SyncConflict>(
      row,
      conflictColumns: conflictColumns(SyncConflict.t),
      updateColumns: updateColumns?.call(SyncConflict.t),
      updateWhere: updateWhere?.call(SyncConflict.t),
      transaction: transaction,
    );
  }

  /// Updates all [SyncConflict]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SyncConflict>> update(
    _is.DatabaseSession session,
    List<SyncConflict> rows, {
    _is.ColumnSelections<SyncConflictTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SyncConflict>(
      rows,
      columns: columns?.call(SyncConflict.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SyncConflict]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SyncConflict> updateRow(
    _is.DatabaseSession session,
    SyncConflict row, {
    _is.ColumnSelections<SyncConflictTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SyncConflict>(
      row,
      columns: columns?.call(SyncConflict.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SyncConflict] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SyncConflict?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SyncConflictUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SyncConflict>(
      id,
      columnValues: columnValues(SyncConflict.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SyncConflict]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SyncConflict>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SyncConflictUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SyncConflictTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SyncConflictTable>? orderBy,
    _is.OrderByListBuilder<SyncConflictTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SyncConflict>(
      columnValues: columnValues(SyncConflict.t.updateTable),
      where: where(SyncConflict.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SyncConflict.t),
      orderByList: orderByList?.call(SyncConflict.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SyncConflict]s in the list and returns the deleted rows.
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
  Future<List<SyncConflict>> delete(
    _is.DatabaseSession session,
    List<SyncConflict> rows, {
    _is.OrderByBuilder<SyncConflictTable>? orderBy,
    _is.OrderByListBuilder<SyncConflictTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SyncConflict>(
      rows,
      orderBy: orderBy?.call(SyncConflict.t),
      orderByList: orderByList?.call(SyncConflict.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SyncConflict].
  Future<SyncConflict> deleteRow(
    _is.DatabaseSession session,
    SyncConflict row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SyncConflict>(
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
  Future<List<SyncConflict>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SyncConflictTable> where,
    _is.OrderByBuilder<SyncConflictTable>? orderBy,
    _is.OrderByListBuilder<SyncConflictTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SyncConflict>(
      where: where(SyncConflict.t),
      orderBy: orderBy?.call(SyncConflict.t),
      orderByList: orderByList?.call(SyncConflict.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SyncConflictTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SyncConflict>(
      where: where?.call(SyncConflict.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SyncConflict] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SyncConflictTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SyncConflict>(
      where: where(SyncConflict.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
