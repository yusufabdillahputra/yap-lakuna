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

/// Akun pemilik (Serverpod auth) yang mengaktifkan tenant. Hanya ada di
/// server.
abstract class TenantOwner
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  TenantOwner._({
    this.id,
    required this.tenantId,
    required this.authUserId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory TenantOwner({
    int? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue authUserId,
    DateTime? createdAt,
  }) = _TenantOwnerImpl;

  factory TenantOwner.fromJson(Map<String, dynamic> jsonSerialization) {
    return TenantOwner(
      id: jsonSerialization['id'] as int?,
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = TenantOwnerTable();

  static const db = TenantOwnerRepository._();

  @override
  int? id;

  _is.UuidValue tenantId;

  _is.UuidValue authUserId;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [TenantOwner]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TenantOwner copyWith({
    int? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? authUserId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TenantOwner',
      if (id != null) 'id': id,
      'tenantId': tenantId.toJson(),
      'authUserId': authUserId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static TenantOwnerInclude include() {
    return TenantOwnerInclude._();
  }

  static TenantOwnerIncludeList includeList({
    _is.WhereExpressionBuilder<TenantOwnerTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TenantOwnerTable>? orderBy,
    _is.OrderByListBuilder<TenantOwnerTable>? orderByList,
    TenantOwnerInclude? include,
  }) {
    return TenantOwnerIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TenantOwner.t),
      orderByList: orderByList?.call(TenantOwner.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TenantOwnerImpl extends TenantOwner {
  _TenantOwnerImpl({
    int? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue authUserId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         tenantId: tenantId,
         authUserId: authUserId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [TenantOwner]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TenantOwner copyWith({
    Object? id = _Undefined,
    _is.UuidValue? tenantId,
    _is.UuidValue? authUserId,
    DateTime? createdAt,
  }) {
    return TenantOwner(
      id: id is int? ? id : this.id,
      tenantId: tenantId ?? this.tenantId,
      authUserId: authUserId ?? this.authUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class TenantOwnerUpdateTable extends _is.UpdateTable<TenantOwnerTable> {
  TenantOwnerUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class TenantOwnerTable extends _is.Table<int?> {
  TenantOwnerTable({super.tableRelation}) : super(tableName: 'tenant_owners') {
    updateTable = TenantOwnerUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    authUserId = _is.ColumnUuid(
      'auth_user_id',
      this,
      fieldName: 'authUserId',
    );
    createdAt = _is.ColumnDateTime(
      'created_at',
      this,
      hasDefault: true,
      fieldName: 'createdAt',
    );
  }

  late final TenantOwnerUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid authUserId;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    tenantId,
    authUserId,
    createdAt,
  ];
}

class TenantOwnerInclude extends _is.IncludeObject {
  TenantOwnerInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => TenantOwner.t;
}

class TenantOwnerIncludeList extends _is.IncludeList {
  TenantOwnerIncludeList._({
    _is.WhereExpressionBuilder<TenantOwnerTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(TenantOwner.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => TenantOwner.t;
}

class TenantOwnerRepository {
  const TenantOwnerRepository._();

  /// Returns a list of [TenantOwner]s matching the given query parameters.
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
  Future<List<TenantOwner>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TenantOwnerTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TenantOwnerTable>? orderBy,
    _is.OrderByListBuilder<TenantOwnerTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<TenantOwner>(
      where: where?.call(TenantOwner.t),
      orderBy: orderBy?.call(TenantOwner.t),
      orderByList: orderByList?.call(TenantOwner.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [TenantOwner]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `TenantOwner.t`.
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
  _ida.Stream<List<TenantOwner>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TenantOwnerTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TenantOwnerTable>? orderBy,
    _is.OrderByListBuilder<TenantOwnerTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<TenantOwner>(
      where: where?.call(TenantOwner.t),
      orderBy: orderBy?.call(TenantOwner.t),
      orderByList: orderByList?.call(TenantOwner.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [TenantOwner] matching the given query parameters.
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
  Future<TenantOwner?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TenantOwnerTable>? where,
    int? offset,
    _is.OrderByBuilder<TenantOwnerTable>? orderBy,
    _is.OrderByListBuilder<TenantOwnerTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<TenantOwner>(
      where: where?.call(TenantOwner.t),
      orderBy: orderBy?.call(TenantOwner.t),
      orderByList: orderByList?.call(TenantOwner.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [TenantOwner] by its [id] or null if no such row exists.
  Future<TenantOwner?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<TenantOwner>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [TenantOwner]s in the list and returns the inserted rows.
  ///
  /// The returned [TenantOwner]s will have their `id` fields set.
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
  Future<List<TenantOwner>> insert(
    _is.DatabaseSession session,
    List<TenantOwner> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<TenantOwner>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [TenantOwner] and returns the inserted row.
  ///
  /// The returned [TenantOwner] will have its `id` field set.
  Future<TenantOwner> insertRow(
    _is.DatabaseSession session,
    TenantOwner row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<TenantOwner>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [TenantOwner]s in the list and returns the resulting rows.
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
  /// The returned [TenantOwner]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TenantOwner>> upsert(
    _is.DatabaseSession session,
    List<TenantOwner> rows, {
    required _is.ColumnSelections<TenantOwnerTable> conflictColumns,
    _is.ColumnSelections<TenantOwnerTable>? updateColumns,
    _is.WhereExpressionBuilder<TenantOwnerTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<TenantOwner>(
      rows,
      conflictColumns: conflictColumns(TenantOwner.t),
      updateColumns: updateColumns?.call(TenantOwner.t),
      updateWhere: updateWhere?.call(TenantOwner.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [TenantOwner] and returns the resulting row.
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
  /// The returned [TenantOwner] will have its `id` field set.
  Future<TenantOwner?> upsertRow(
    _is.DatabaseSession session,
    TenantOwner row, {
    required _is.ColumnSelections<TenantOwnerTable> conflictColumns,
    _is.ColumnSelections<TenantOwnerTable>? updateColumns,
    _is.WhereExpressionBuilder<TenantOwnerTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<TenantOwner>(
      row,
      conflictColumns: conflictColumns(TenantOwner.t),
      updateColumns: updateColumns?.call(TenantOwner.t),
      updateWhere: updateWhere?.call(TenantOwner.t),
      transaction: transaction,
    );
  }

  /// Updates all [TenantOwner]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TenantOwner>> update(
    _is.DatabaseSession session,
    List<TenantOwner> rows, {
    _is.ColumnSelections<TenantOwnerTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<TenantOwner>(
      rows,
      columns: columns?.call(TenantOwner.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [TenantOwner]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<TenantOwner> updateRow(
    _is.DatabaseSession session,
    TenantOwner row, {
    _is.ColumnSelections<TenantOwnerTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<TenantOwner>(
      row,
      columns: columns?.call(TenantOwner.t),
      transaction: transaction,
    );
  }

  /// Updates a single [TenantOwner] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<TenantOwner?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<TenantOwnerUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<TenantOwner>(
      id,
      columnValues: columnValues(TenantOwner.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [TenantOwner]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<TenantOwner>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TenantOwnerUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TenantOwnerTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TenantOwnerTable>? orderBy,
    _is.OrderByListBuilder<TenantOwnerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<TenantOwner>(
      columnValues: columnValues(TenantOwner.t.updateTable),
      where: where(TenantOwner.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(TenantOwner.t),
      orderByList: orderByList?.call(TenantOwner.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [TenantOwner]s in the list and returns the deleted rows.
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
  Future<List<TenantOwner>> delete(
    _is.DatabaseSession session,
    List<TenantOwner> rows, {
    _is.OrderByBuilder<TenantOwnerTable>? orderBy,
    _is.OrderByListBuilder<TenantOwnerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<TenantOwner>(
      rows,
      orderBy: orderBy?.call(TenantOwner.t),
      orderByList: orderByList?.call(TenantOwner.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [TenantOwner].
  Future<TenantOwner> deleteRow(
    _is.DatabaseSession session,
    TenantOwner row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<TenantOwner>(
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
  Future<List<TenantOwner>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TenantOwnerTable> where,
    _is.OrderByBuilder<TenantOwnerTable>? orderBy,
    _is.OrderByListBuilder<TenantOwnerTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<TenantOwner>(
      where: where(TenantOwner.t),
      orderBy: orderBy?.call(TenantOwner.t),
      orderByList: orderByList?.call(TenantOwner.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TenantOwnerTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<TenantOwner>(
      where: where?.call(TenantOwner.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [TenantOwner] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TenantOwnerTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<TenantOwner>(
      where: where(TenantOwner.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
