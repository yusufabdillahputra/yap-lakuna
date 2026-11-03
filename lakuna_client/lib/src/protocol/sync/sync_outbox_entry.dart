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
import '../sync/outbox_status.dart' as _i2hbu5uw;
import '../sync/sync_op.dart' as _ik9d1u3s;

/// Satu perubahan baris yang menunggu dikirim ke server. Ditulis dalam
/// transaksi yang sama dengan perubahan datanya. Hanya ada di perangkat.
abstract class SyncOutboxEntry
    implements _isd.TableRow<int?>, _isc.ProtocolSerialization {
  SyncOutboxEntry._({
    this.id,
    required this.entity,
    required this.rowId,
    required this.op,
    required this.payloadJson,
    required this.hlc,
    _i2hbu5uw.OutboxStatus? status,
    int? attempts,
    this.lastError,
    DateTime? createdAt,
  }) : status = status ?? _i2hbu5uw.OutboxStatus.pending,
       attempts = attempts ?? 0,
       createdAt = createdAt ?? DateTime.now();

  factory SyncOutboxEntry({
    int? id,
    required String entity,
    required _isc.UuidValue rowId,
    required _ik9d1u3s.SyncOp op,
    required String payloadJson,
    required String hlc,
    _i2hbu5uw.OutboxStatus? status,
    int? attempts,
    String? lastError,
    DateTime? createdAt,
  }) = _SyncOutboxEntryImpl;

  factory SyncOutboxEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncOutboxEntry(
      id: jsonSerialization['id'] as int?,
      entity: jsonSerialization['entity'] as String,
      rowId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['rowId']),
      op: _ik9d1u3s.SyncOp.fromJson((jsonSerialization['op'] as String)),
      payloadJson: jsonSerialization['payloadJson'] as String,
      hlc: jsonSerialization['hlc'] as String,
      status: jsonSerialization['status'] == null
          ? null
          : _i2hbu5uw.OutboxStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      attempts: jsonSerialization['attempts'] as int?,
      lastError: jsonSerialization['lastError'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = SyncOutboxEntryTable();

  static const db = SyncOutboxEntryRepository._();

  @override
  int? id;

  /// Nama tabel yang berubah.
  String entity;

  _isc.UuidValue rowId;

  _ik9d1u3s.SyncOp op;

  String payloadJson;

  String hlc;

  _i2hbu5uw.OutboxStatus status;

  int attempts;

  String? lastError;

  DateTime createdAt;

  @override
  _isd.Table<int?> get table => t;

  /// Returns a shallow copy of this [SyncOutboxEntry]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SyncOutboxEntry copyWith({
    int? id,
    String? entity,
    _isc.UuidValue? rowId,
    _ik9d1u3s.SyncOp? op,
    String? payloadJson,
    String? hlc,
    _i2hbu5uw.OutboxStatus? status,
    int? attempts,
    String? lastError,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncOutboxEntry',
      if (id != null) 'id': id,
      'entity': entity,
      'rowId': rowId.toJson(),
      'op': op.toJson(),
      'payloadJson': payloadJson,
      'hlc': hlc,
      'status': status.toJson(),
      'attempts': attempts,
      if (lastError != null) 'lastError': lastError,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SyncOutboxEntry',
      if (id != null) 'id': id,
      'entity': entity,
      'rowId': rowId.toJson(),
      'op': op.toJson(),
      'payloadJson': payloadJson,
      'hlc': hlc,
      'status': status.toJson(),
      'attempts': attempts,
      if (lastError != null) 'lastError': lastError,
      'createdAt': createdAt.toJson(),
    };
  }

  static SyncOutboxEntryInclude include() {
    return SyncOutboxEntryInclude._();
  }

  static SyncOutboxEntryIncludeList includeList({
    _isd.WhereExpressionBuilder<SyncOutboxEntryTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SyncOutboxEntryTable>? orderBy,
    _isd.OrderByListBuilder<SyncOutboxEntryTable>? orderByList,
    SyncOutboxEntryInclude? include,
  }) {
    return SyncOutboxEntryIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SyncOutboxEntry.t),
      orderByList: orderByList?.call(SyncOutboxEntry.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SyncOutboxEntryImpl extends SyncOutboxEntry {
  _SyncOutboxEntryImpl({
    int? id,
    required String entity,
    required _isc.UuidValue rowId,
    required _ik9d1u3s.SyncOp op,
    required String payloadJson,
    required String hlc,
    _i2hbu5uw.OutboxStatus? status,
    int? attempts,
    String? lastError,
    DateTime? createdAt,
  }) : super._(
         id: id,
         entity: entity,
         rowId: rowId,
         op: op,
         payloadJson: payloadJson,
         hlc: hlc,
         status: status,
         attempts: attempts,
         lastError: lastError,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SyncOutboxEntry]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SyncOutboxEntry copyWith({
    Object? id = _Undefined,
    String? entity,
    _isc.UuidValue? rowId,
    _ik9d1u3s.SyncOp? op,
    String? payloadJson,
    String? hlc,
    _i2hbu5uw.OutboxStatus? status,
    int? attempts,
    Object? lastError = _Undefined,
    DateTime? createdAt,
  }) {
    return SyncOutboxEntry(
      id: id is int? ? id : this.id,
      entity: entity ?? this.entity,
      rowId: rowId ?? this.rowId,
      op: op ?? this.op,
      payloadJson: payloadJson ?? this.payloadJson,
      hlc: hlc ?? this.hlc,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastError: lastError is String? ? lastError : this.lastError,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SyncOutboxEntryUpdateTable
    extends _isd.UpdateTable<SyncOutboxEntryTable> {
  SyncOutboxEntryUpdateTable(super.table);

  _isd.ColumnValue<String, String> entity(String value) => _isd.ColumnValue(
    table.entity,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> rowId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.rowId,
    value,
  );

  _isd.ColumnValue<_ik9d1u3s.SyncOp, _ik9d1u3s.SyncOp> op(
    _ik9d1u3s.SyncOp value,
  ) => _isd.ColumnValue(
    table.op,
    value,
  );

  _isd.ColumnValue<String, String> payloadJson(String value) =>
      _isd.ColumnValue(
        table.payloadJson,
        value,
      );

  _isd.ColumnValue<String, String> hlc(String value) => _isd.ColumnValue(
    table.hlc,
    value,
  );

  _isd.ColumnValue<_i2hbu5uw.OutboxStatus, _i2hbu5uw.OutboxStatus> status(
    _i2hbu5uw.OutboxStatus value,
  ) => _isd.ColumnValue(
    table.status,
    value,
  );

  _isd.ColumnValue<int, int> attempts(int value) => _isd.ColumnValue(
    table.attempts,
    value,
  );

  _isd.ColumnValue<String, String> lastError(String? value) => _isd.ColumnValue(
    table.lastError,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _isd.ColumnValue(
        table.createdAt,
        value,
      );
}

class SyncOutboxEntryTable extends _isd.Table<int?> {
  SyncOutboxEntryTable({super.tableRelation})
    : super(tableName: 'sync_outbox') {
    updateTable = SyncOutboxEntryUpdateTable(this);
    entity = _isd.ColumnString(
      'table_name',
      this,
      fieldName: 'entity',
    );
    rowId = _isd.ColumnUuid(
      'row_id',
      this,
      fieldName: 'rowId',
    );
    op = _isd.ColumnEnum(
      'op',
      this,
      _isd.EnumSerialization.byName,
    );
    payloadJson = _isd.ColumnString(
      'payload_json',
      this,
      fieldName: 'payloadJson',
    );
    hlc = _isd.ColumnString(
      'hlc',
      this,
    );
    status = _isd.ColumnEnum(
      'status',
      this,
      _isd.EnumSerialization.byName,
      hasDefault: true,
    );
    attempts = _isd.ColumnInt(
      'attempts',
      this,
      hasDefault: true,
    );
    lastError = _isd.ColumnString(
      'last_error',
      this,
      fieldName: 'lastError',
    );
    createdAt = _isd.ColumnDateTime(
      'created_at',
      this,
      hasDefault: true,
      fieldName: 'createdAt',
    );
  }

  late final SyncOutboxEntryUpdateTable updateTable;

  /// Nama tabel yang berubah.
  late final _isd.ColumnString entity;

  late final _isd.ColumnUuid rowId;

  late final _isd.ColumnEnum<_ik9d1u3s.SyncOp> op;

  late final _isd.ColumnString payloadJson;

  late final _isd.ColumnString hlc;

  late final _isd.ColumnEnum<_i2hbu5uw.OutboxStatus> status;

  late final _isd.ColumnInt attempts;

  late final _isd.ColumnString lastError;

  late final _isd.ColumnDateTime createdAt;

  @override
  List<_isd.Column> get columns => [
    id,
    entity,
    rowId,
    op,
    payloadJson,
    hlc,
    status,
    attempts,
    lastError,
    createdAt,
  ];
}

class SyncOutboxEntryInclude extends _isd.IncludeObject {
  SyncOutboxEntryInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<int?> get table => SyncOutboxEntry.t;
}

class SyncOutboxEntryIncludeList extends _isd.IncludeList {
  SyncOutboxEntryIncludeList._({
    _isd.WhereExpressionBuilder<SyncOutboxEntryTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SyncOutboxEntry.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<int?> get table => SyncOutboxEntry.t;
}

class SyncOutboxEntryRepository {
  const SyncOutboxEntryRepository._();

  /// Returns a list of [SyncOutboxEntry]s matching the given query parameters.
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
  Future<List<SyncOutboxEntry>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SyncOutboxEntryTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SyncOutboxEntryTable>? orderBy,
    _isd.OrderByListBuilder<SyncOutboxEntryTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SyncOutboxEntry>(
      where: where?.call(SyncOutboxEntry.t),
      orderBy: orderBy?.call(SyncOutboxEntry.t),
      orderByList: orderByList?.call(SyncOutboxEntry.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [SyncOutboxEntry]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `SyncOutboxEntry.t`.
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
  _ida.Stream<List<SyncOutboxEntry>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SyncOutboxEntryTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SyncOutboxEntryTable>? orderBy,
    _isd.OrderByListBuilder<SyncOutboxEntryTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<SyncOutboxEntry>(
      where: where?.call(SyncOutboxEntry.t),
      orderBy: orderBy?.call(SyncOutboxEntry.t),
      orderByList: orderByList?.call(SyncOutboxEntry.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [SyncOutboxEntry] matching the given query parameters.
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
  Future<SyncOutboxEntry?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SyncOutboxEntryTable>? where,
    int? offset,
    _isd.OrderByBuilder<SyncOutboxEntryTable>? orderBy,
    _isd.OrderByListBuilder<SyncOutboxEntryTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SyncOutboxEntry>(
      where: where?.call(SyncOutboxEntry.t),
      orderBy: orderBy?.call(SyncOutboxEntry.t),
      orderByList: orderByList?.call(SyncOutboxEntry.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SyncOutboxEntry] by its [id] or null if no such row exists.
  Future<SyncOutboxEntry?> findById(
    _isd.DatabaseSession session,
    int id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SyncOutboxEntry>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SyncOutboxEntry]s in the list and returns the inserted rows.
  ///
  /// The returned [SyncOutboxEntry]s will have their `id` fields set.
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
  Future<List<SyncOutboxEntry>> insert(
    _isd.DatabaseSession session,
    List<SyncOutboxEntry> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SyncOutboxEntry>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SyncOutboxEntry] and returns the inserted row.
  ///
  /// The returned [SyncOutboxEntry] will have its `id` field set.
  Future<SyncOutboxEntry> insertRow(
    _isd.DatabaseSession session,
    SyncOutboxEntry row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<SyncOutboxEntry>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SyncOutboxEntry]s in the list and returns the resulting rows.
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
  /// The returned [SyncOutboxEntry]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SyncOutboxEntry>> upsert(
    _isd.DatabaseSession session,
    List<SyncOutboxEntry> rows, {
    required _isd.ColumnSelections<SyncOutboxEntryTable> conflictColumns,
    _isd.ColumnSelections<SyncOutboxEntryTable>? updateColumns,
    _isd.WhereExpressionBuilder<SyncOutboxEntryTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SyncOutboxEntry>(
      rows,
      conflictColumns: conflictColumns(SyncOutboxEntry.t),
      updateColumns: updateColumns?.call(SyncOutboxEntry.t),
      updateWhere: updateWhere?.call(SyncOutboxEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SyncOutboxEntry] and returns the resulting row.
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
  /// The returned [SyncOutboxEntry] will have its `id` field set.
  Future<SyncOutboxEntry?> upsertRow(
    _isd.DatabaseSession session,
    SyncOutboxEntry row, {
    required _isd.ColumnSelections<SyncOutboxEntryTable> conflictColumns,
    _isd.ColumnSelections<SyncOutboxEntryTable>? updateColumns,
    _isd.WhereExpressionBuilder<SyncOutboxEntryTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SyncOutboxEntry>(
      row,
      conflictColumns: conflictColumns(SyncOutboxEntry.t),
      updateColumns: updateColumns?.call(SyncOutboxEntry.t),
      updateWhere: updateWhere?.call(SyncOutboxEntry.t),
      transaction: transaction,
    );
  }

  /// Updates all [SyncOutboxEntry]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SyncOutboxEntry>> update(
    _isd.DatabaseSession session,
    List<SyncOutboxEntry> rows, {
    _isd.ColumnSelections<SyncOutboxEntryTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SyncOutboxEntry>(
      rows,
      columns: columns?.call(SyncOutboxEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SyncOutboxEntry]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SyncOutboxEntry> updateRow(
    _isd.DatabaseSession session,
    SyncOutboxEntry row, {
    _isd.ColumnSelections<SyncOutboxEntryTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<SyncOutboxEntry>(
      row,
      columns: columns?.call(SyncOutboxEntry.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SyncOutboxEntry] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SyncOutboxEntry?> updateById(
    _isd.DatabaseSession session,
    int id, {
    required _isd.ColumnValueListBuilder<SyncOutboxEntryUpdateTable>
    columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<SyncOutboxEntry>(
      id,
      columnValues: columnValues(SyncOutboxEntry.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SyncOutboxEntry]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SyncOutboxEntry>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<SyncOutboxEntryUpdateTable>
    columnValues,
    required _isd.WhereExpressionBuilder<SyncOutboxEntryTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SyncOutboxEntryTable>? orderBy,
    _isd.OrderByListBuilder<SyncOutboxEntryTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SyncOutboxEntry>(
      columnValues: columnValues(SyncOutboxEntry.t.updateTable),
      where: where(SyncOutboxEntry.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SyncOutboxEntry.t),
      orderByList: orderByList?.call(SyncOutboxEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SyncOutboxEntry]s in the list and returns the deleted rows.
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
  Future<List<SyncOutboxEntry>> delete(
    _isd.DatabaseSession session,
    List<SyncOutboxEntry> rows, {
    _isd.OrderByBuilder<SyncOutboxEntryTable>? orderBy,
    _isd.OrderByListBuilder<SyncOutboxEntryTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SyncOutboxEntry>(
      rows,
      orderBy: orderBy?.call(SyncOutboxEntry.t),
      orderByList: orderByList?.call(SyncOutboxEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SyncOutboxEntry].
  Future<SyncOutboxEntry> deleteRow(
    _isd.DatabaseSession session,
    SyncOutboxEntry row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SyncOutboxEntry>(
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
  Future<List<SyncOutboxEntry>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<SyncOutboxEntryTable> where,
    _isd.OrderByBuilder<SyncOutboxEntryTable>? orderBy,
    _isd.OrderByListBuilder<SyncOutboxEntryTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SyncOutboxEntry>(
      where: where(SyncOutboxEntry.t),
      orderBy: orderBy?.call(SyncOutboxEntry.t),
      orderByList: orderByList?.call(SyncOutboxEntry.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SyncOutboxEntryTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<SyncOutboxEntry>(
      where: where?.call(SyncOutboxEntry.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SyncOutboxEntry] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<SyncOutboxEntryTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SyncOutboxEntry>(
      where: where(SyncOutboxEntry.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
