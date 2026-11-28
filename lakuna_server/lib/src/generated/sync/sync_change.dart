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

/// Log perubahan server berurutan (F2-01). `id` = `seq` yang ditarik
/// perangkat lewat `sync.pull`. Hanya ada di server.
abstract class SyncChange
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SyncChange._({
    this.id,
    required this.tenantId,
    this.outletId,
    required this.entity,
    required this.rowId,
    required this.hlc,
    this.originDeviceId,
    required this.payloadJson,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory SyncChange({
    int? id,
    required _is.UuidValue tenantId,
    _is.UuidValue? outletId,
    required String entity,
    required _is.UuidValue rowId,
    required String hlc,
    _is.UuidValue? originDeviceId,
    required String payloadJson,
    DateTime? receivedAt,
  }) = _SyncChangeImpl;

  factory SyncChange.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncChange(
      id: jsonSerialization['id'] as int?,
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: jsonSerialization['outletId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['outletId']),
      entity: jsonSerialization['entity'] as String,
      rowId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['rowId']),
      hlc: jsonSerialization['hlc'] as String,
      originDeviceId: jsonSerialization['originDeviceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['originDeviceId'],
            ),
      payloadJson: jsonSerialization['payloadJson'] as String,
      receivedAt: jsonSerialization['receivedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['receivedAt']),
    );
  }

  static final t = SyncChangeTable();

  static const db = SyncChangeRepository._();

  @override
  int? id;

  _is.UuidValue tenantId;

  /// Outlet baris bila tabelnya per outlet (dari payload); null = se-tenant.
  _is.UuidValue? outletId;

  /// Nama tabel (`tableName` dipakai Serverpod).
  String entity;

  _is.UuidValue rowId;

  String hlc;

  /// Perangkat asal; null untuk baris hasil gabung server (aturan 7b/8b),
  /// yang ditarik semua perangkat termasuk pengirimnya.
  _is.UuidValue? originDeviceId;

  String payloadJson;

  DateTime receivedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SyncChange]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SyncChange copyWith({
    int? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId = const _is.$UndefinedUuidValue(),
    String? entity,
    _is.UuidValue? rowId,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
    String? payloadJson,
    DateTime? receivedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncChange',
      if (id != null) 'id': id,
      'tenantId': tenantId.toJson(),
      if (outletId != null) 'outletId': outletId?.toJson(),
      'entity': entity,
      'rowId': rowId.toJson(),
      'hlc': hlc,
      if (originDeviceId != null) 'originDeviceId': originDeviceId?.toJson(),
      'payloadJson': payloadJson,
      'receivedAt': receivedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static SyncChangeInclude include() {
    return SyncChangeInclude._();
  }

  static SyncChangeIncludeList includeList({
    _is.WhereExpressionBuilder<SyncChangeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SyncChangeTable>? orderBy,
    _is.OrderByListBuilder<SyncChangeTable>? orderByList,
    SyncChangeInclude? include,
  }) {
    return SyncChangeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SyncChange.t),
      orderByList: orderByList?.call(SyncChange.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SyncChangeImpl extends SyncChange {
  _SyncChangeImpl({
    int? id,
    required _is.UuidValue tenantId,
    _is.UuidValue? outletId,
    required String entity,
    required _is.UuidValue rowId,
    required String hlc,
    _is.UuidValue? originDeviceId,
    required String payloadJson,
    DateTime? receivedAt,
  }) : super._(
         id: id,
         tenantId: tenantId,
         outletId: outletId,
         entity: entity,
         rowId: rowId,
         hlc: hlc,
         originDeviceId: originDeviceId,
         payloadJson: payloadJson,
         receivedAt: receivedAt,
       );

  /// Returns a shallow copy of this [SyncChange]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SyncChange copyWith({
    Object? id = _Undefined,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId = const _is.$UndefinedUuidValue(),
    String? entity,
    _is.UuidValue? rowId,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
    String? payloadJson,
    DateTime? receivedAt,
  }) {
    return SyncChange(
      id: id is int? ? id : this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId is _is.UndefinedSentinel ? this.outletId : outletId,
      entity: entity ?? this.entity,
      rowId: rowId ?? this.rowId,
      hlc: hlc ?? this.hlc,
      originDeviceId: originDeviceId is _is.UndefinedSentinel
          ? this.originDeviceId
          : originDeviceId,
      payloadJson: payloadJson ?? this.payloadJson,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}

class SyncChangeUpdateTable extends _is.UpdateTable<SyncChangeTable> {
  SyncChangeUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> outletId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.outletId,
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

  _is.ColumnValue<String, String> payloadJson(String value) => _is.ColumnValue(
    table.payloadJson,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> receivedAt(DateTime value) =>
      _is.ColumnValue(
        table.receivedAt,
        value,
      );
}

class SyncChangeTable extends _is.Table<int?> {
  SyncChangeTable({super.tableRelation}) : super(tableName: 'sync_changes') {
    updateTable = SyncChangeUpdateTable(this);
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
    hlc = _is.ColumnString(
      'hlc',
      this,
    );
    originDeviceId = _is.ColumnUuid(
      'origin_device_id',
      this,
      fieldName: 'originDeviceId',
    );
    payloadJson = _is.ColumnString(
      'payload_json',
      this,
      fieldName: 'payloadJson',
    );
    receivedAt = _is.ColumnDateTime(
      'received_at',
      this,
      hasDefault: true,
      fieldName: 'receivedAt',
    );
  }

  late final SyncChangeUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  /// Outlet baris bila tabelnya per outlet (dari payload); null = se-tenant.
  late final _is.ColumnUuid outletId;

  /// Nama tabel (`tableName` dipakai Serverpod).
  late final _is.ColumnString entity;

  late final _is.ColumnUuid rowId;

  late final _is.ColumnString hlc;

  /// Perangkat asal; null untuk baris hasil gabung server (aturan 7b/8b),
  /// yang ditarik semua perangkat termasuk pengirimnya.
  late final _is.ColumnUuid originDeviceId;

  late final _is.ColumnString payloadJson;

  late final _is.ColumnDateTime receivedAt;

  @override
  List<_is.Column> get columns => [
    id,
    tenantId,
    outletId,
    entity,
    rowId,
    hlc,
    originDeviceId,
    payloadJson,
    receivedAt,
  ];
}

class SyncChangeInclude extends _is.IncludeObject {
  SyncChangeInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SyncChange.t;
}

class SyncChangeIncludeList extends _is.IncludeList {
  SyncChangeIncludeList._({
    _is.WhereExpressionBuilder<SyncChangeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SyncChange.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SyncChange.t;
}

class SyncChangeRepository {
  const SyncChangeRepository._();

  /// Returns a list of [SyncChange]s matching the given query parameters.
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
  Future<List<SyncChange>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SyncChangeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SyncChangeTable>? orderBy,
    _is.OrderByListBuilder<SyncChangeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SyncChange>(
      where: where?.call(SyncChange.t),
      orderBy: orderBy?.call(SyncChange.t),
      orderByList: orderByList?.call(SyncChange.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [SyncChange]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `SyncChange.t`.
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
  _ida.Stream<List<SyncChange>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SyncChangeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SyncChangeTable>? orderBy,
    _is.OrderByListBuilder<SyncChangeTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<SyncChange>(
      where: where?.call(SyncChange.t),
      orderBy: orderBy?.call(SyncChange.t),
      orderByList: orderByList?.call(SyncChange.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [SyncChange] matching the given query parameters.
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
  Future<SyncChange?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SyncChangeTable>? where,
    int? offset,
    _is.OrderByBuilder<SyncChangeTable>? orderBy,
    _is.OrderByListBuilder<SyncChangeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SyncChange>(
      where: where?.call(SyncChange.t),
      orderBy: orderBy?.call(SyncChange.t),
      orderByList: orderByList?.call(SyncChange.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SyncChange] by its [id] or null if no such row exists.
  Future<SyncChange?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SyncChange>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SyncChange]s in the list and returns the inserted rows.
  ///
  /// The returned [SyncChange]s will have their `id` fields set.
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
  Future<List<SyncChange>> insert(
    _is.DatabaseSession session,
    List<SyncChange> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SyncChange>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SyncChange] and returns the inserted row.
  ///
  /// The returned [SyncChange] will have its `id` field set.
  Future<SyncChange> insertRow(
    _is.DatabaseSession session,
    SyncChange row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SyncChange>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SyncChange]s in the list and returns the resulting rows.
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
  /// The returned [SyncChange]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SyncChange>> upsert(
    _is.DatabaseSession session,
    List<SyncChange> rows, {
    required _is.ColumnSelections<SyncChangeTable> conflictColumns,
    _is.ColumnSelections<SyncChangeTable>? updateColumns,
    _is.WhereExpressionBuilder<SyncChangeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SyncChange>(
      rows,
      conflictColumns: conflictColumns(SyncChange.t),
      updateColumns: updateColumns?.call(SyncChange.t),
      updateWhere: updateWhere?.call(SyncChange.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SyncChange] and returns the resulting row.
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
  /// The returned [SyncChange] will have its `id` field set.
  Future<SyncChange?> upsertRow(
    _is.DatabaseSession session,
    SyncChange row, {
    required _is.ColumnSelections<SyncChangeTable> conflictColumns,
    _is.ColumnSelections<SyncChangeTable>? updateColumns,
    _is.WhereExpressionBuilder<SyncChangeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SyncChange>(
      row,
      conflictColumns: conflictColumns(SyncChange.t),
      updateColumns: updateColumns?.call(SyncChange.t),
      updateWhere: updateWhere?.call(SyncChange.t),
      transaction: transaction,
    );
  }

  /// Updates all [SyncChange]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SyncChange>> update(
    _is.DatabaseSession session,
    List<SyncChange> rows, {
    _is.ColumnSelections<SyncChangeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SyncChange>(
      rows,
      columns: columns?.call(SyncChange.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SyncChange]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SyncChange> updateRow(
    _is.DatabaseSession session,
    SyncChange row, {
    _is.ColumnSelections<SyncChangeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SyncChange>(
      row,
      columns: columns?.call(SyncChange.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SyncChange] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SyncChange?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SyncChangeUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SyncChange>(
      id,
      columnValues: columnValues(SyncChange.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SyncChange]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SyncChange>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SyncChangeUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SyncChangeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SyncChangeTable>? orderBy,
    _is.OrderByListBuilder<SyncChangeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SyncChange>(
      columnValues: columnValues(SyncChange.t.updateTable),
      where: where(SyncChange.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SyncChange.t),
      orderByList: orderByList?.call(SyncChange.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SyncChange]s in the list and returns the deleted rows.
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
  Future<List<SyncChange>> delete(
    _is.DatabaseSession session,
    List<SyncChange> rows, {
    _is.OrderByBuilder<SyncChangeTable>? orderBy,
    _is.OrderByListBuilder<SyncChangeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SyncChange>(
      rows,
      orderBy: orderBy?.call(SyncChange.t),
      orderByList: orderByList?.call(SyncChange.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SyncChange].
  Future<SyncChange> deleteRow(
    _is.DatabaseSession session,
    SyncChange row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SyncChange>(
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
  Future<List<SyncChange>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SyncChangeTable> where,
    _is.OrderByBuilder<SyncChangeTable>? orderBy,
    _is.OrderByListBuilder<SyncChangeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SyncChange>(
      where: where(SyncChange.t),
      orderBy: orderBy?.call(SyncChange.t),
      orderByList: orderByList?.call(SyncChange.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SyncChangeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SyncChange>(
      where: where?.call(SyncChange.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SyncChange] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SyncChangeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SyncChange>(
      where: where(SyncChange.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
