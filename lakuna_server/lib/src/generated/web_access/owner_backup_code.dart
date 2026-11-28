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

/// Kode cadangan sekali pakai verifikasi 2 langkah (F2-02 aturan 14).
/// Server hanya menyimpan hash. Hanya ada di server.
abstract class OwnerBackupCode
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  OwnerBackupCode._({
    this.id,
    required this.authUserId,
    required this.codeHash,
    this.usedAt,
  });

  factory OwnerBackupCode({
    int? id,
    required _is.UuidValue authUserId,
    required String codeHash,
    DateTime? usedAt,
  }) = _OwnerBackupCodeImpl;

  factory OwnerBackupCode.fromJson(Map<String, dynamic> jsonSerialization) {
    return OwnerBackupCode(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      codeHash: jsonSerialization['codeHash'] as String,
      usedAt: jsonSerialization['usedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['usedAt']),
    );
  }

  static final t = OwnerBackupCodeTable();

  static const db = OwnerBackupCodeRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  String codeHash;

  DateTime? usedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [OwnerBackupCode]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  OwnerBackupCode copyWith({
    int? id,
    _is.UuidValue? authUserId,
    String? codeHash,
    DateTime? usedAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'OwnerBackupCode',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      'codeHash': codeHash,
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static OwnerBackupCodeInclude include() {
    return OwnerBackupCodeInclude._();
  }

  static OwnerBackupCodeIncludeList includeList({
    _is.WhereExpressionBuilder<OwnerBackupCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OwnerBackupCodeTable>? orderBy,
    _is.OrderByListBuilder<OwnerBackupCodeTable>? orderByList,
    OwnerBackupCodeInclude? include,
  }) {
    return OwnerBackupCodeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OwnerBackupCode.t),
      orderByList: orderByList?.call(OwnerBackupCode.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OwnerBackupCodeImpl extends OwnerBackupCode {
  _OwnerBackupCodeImpl({
    int? id,
    required _is.UuidValue authUserId,
    required String codeHash,
    DateTime? usedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         codeHash: codeHash,
         usedAt: usedAt,
       );

  /// Returns a shallow copy of this [OwnerBackupCode]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  OwnerBackupCode copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    String? codeHash,
    DateTime? usedAt = const _is.$UndefinedDateTime(),
  }) {
    return OwnerBackupCode(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      codeHash: codeHash ?? this.codeHash,
      usedAt: usedAt is _is.UndefinedSentinel ? this.usedAt : usedAt,
    );
  }
}

class OwnerBackupCodeUpdateTable extends _is.UpdateTable<OwnerBackupCodeTable> {
  OwnerBackupCodeUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> codeHash(String value) => _is.ColumnValue(
    table.codeHash,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> usedAt(DateTime? value) =>
      _is.ColumnValue(
        table.usedAt,
        value,
      );
}

class OwnerBackupCodeTable extends _is.Table<int?> {
  OwnerBackupCodeTable({super.tableRelation})
    : super(tableName: 'owner_backup_codes') {
    updateTable = OwnerBackupCodeUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'auth_user_id',
      this,
      fieldName: 'authUserId',
    );
    codeHash = _is.ColumnString(
      'code_hash',
      this,
      fieldName: 'codeHash',
    );
    usedAt = _is.ColumnDateTime(
      'used_at',
      this,
      fieldName: 'usedAt',
    );
  }

  late final OwnerBackupCodeUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  late final _is.ColumnString codeHash;

  late final _is.ColumnDateTime usedAt;

  @override
  List<_is.Column> get columns => [
    id,
    authUserId,
    codeHash,
    usedAt,
  ];
}

class OwnerBackupCodeInclude extends _is.IncludeObject {
  OwnerBackupCodeInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => OwnerBackupCode.t;
}

class OwnerBackupCodeIncludeList extends _is.IncludeList {
  OwnerBackupCodeIncludeList._({
    _is.WhereExpressionBuilder<OwnerBackupCodeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OwnerBackupCode.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => OwnerBackupCode.t;
}

class OwnerBackupCodeRepository {
  const OwnerBackupCodeRepository._();

  /// Returns a list of [OwnerBackupCode]s matching the given query parameters.
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
  Future<List<OwnerBackupCode>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OwnerBackupCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OwnerBackupCodeTable>? orderBy,
    _is.OrderByListBuilder<OwnerBackupCodeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<OwnerBackupCode>(
      where: where?.call(OwnerBackupCode.t),
      orderBy: orderBy?.call(OwnerBackupCode.t),
      orderByList: orderByList?.call(OwnerBackupCode.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [OwnerBackupCode]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `OwnerBackupCode.t`.
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
  _ida.Stream<List<OwnerBackupCode>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OwnerBackupCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OwnerBackupCodeTable>? orderBy,
    _is.OrderByListBuilder<OwnerBackupCodeTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<OwnerBackupCode>(
      where: where?.call(OwnerBackupCode.t),
      orderBy: orderBy?.call(OwnerBackupCode.t),
      orderByList: orderByList?.call(OwnerBackupCode.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [OwnerBackupCode] matching the given query parameters.
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
  Future<OwnerBackupCode?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OwnerBackupCodeTable>? where,
    int? offset,
    _is.OrderByBuilder<OwnerBackupCodeTable>? orderBy,
    _is.OrderByListBuilder<OwnerBackupCodeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<OwnerBackupCode>(
      where: where?.call(OwnerBackupCode.t),
      orderBy: orderBy?.call(OwnerBackupCode.t),
      orderByList: orderByList?.call(OwnerBackupCode.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [OwnerBackupCode] by its [id] or null if no such row exists.
  Future<OwnerBackupCode?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<OwnerBackupCode>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [OwnerBackupCode]s in the list and returns the inserted rows.
  ///
  /// The returned [OwnerBackupCode]s will have their `id` fields set.
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
  Future<List<OwnerBackupCode>> insert(
    _is.DatabaseSession session,
    List<OwnerBackupCode> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<OwnerBackupCode>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [OwnerBackupCode] and returns the inserted row.
  ///
  /// The returned [OwnerBackupCode] will have its `id` field set.
  Future<OwnerBackupCode> insertRow(
    _is.DatabaseSession session,
    OwnerBackupCode row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<OwnerBackupCode>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [OwnerBackupCode]s in the list and returns the resulting rows.
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
  /// The returned [OwnerBackupCode]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OwnerBackupCode>> upsert(
    _is.DatabaseSession session,
    List<OwnerBackupCode> rows, {
    required _is.ColumnSelections<OwnerBackupCodeTable> conflictColumns,
    _is.ColumnSelections<OwnerBackupCodeTable>? updateColumns,
    _is.WhereExpressionBuilder<OwnerBackupCodeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<OwnerBackupCode>(
      rows,
      conflictColumns: conflictColumns(OwnerBackupCode.t),
      updateColumns: updateColumns?.call(OwnerBackupCode.t),
      updateWhere: updateWhere?.call(OwnerBackupCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [OwnerBackupCode] and returns the resulting row.
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
  /// The returned [OwnerBackupCode] will have its `id` field set.
  Future<OwnerBackupCode?> upsertRow(
    _is.DatabaseSession session,
    OwnerBackupCode row, {
    required _is.ColumnSelections<OwnerBackupCodeTable> conflictColumns,
    _is.ColumnSelections<OwnerBackupCodeTable>? updateColumns,
    _is.WhereExpressionBuilder<OwnerBackupCodeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<OwnerBackupCode>(
      row,
      conflictColumns: conflictColumns(OwnerBackupCode.t),
      updateColumns: updateColumns?.call(OwnerBackupCode.t),
      updateWhere: updateWhere?.call(OwnerBackupCode.t),
      transaction: transaction,
    );
  }

  /// Updates all [OwnerBackupCode]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OwnerBackupCode>> update(
    _is.DatabaseSession session,
    List<OwnerBackupCode> rows, {
    _is.ColumnSelections<OwnerBackupCodeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<OwnerBackupCode>(
      rows,
      columns: columns?.call(OwnerBackupCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [OwnerBackupCode]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OwnerBackupCode> updateRow(
    _is.DatabaseSession session,
    OwnerBackupCode row, {
    _is.ColumnSelections<OwnerBackupCodeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<OwnerBackupCode>(
      row,
      columns: columns?.call(OwnerBackupCode.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OwnerBackupCode] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<OwnerBackupCode?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<OwnerBackupCodeUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<OwnerBackupCode>(
      id,
      columnValues: columnValues(OwnerBackupCode.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [OwnerBackupCode]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OwnerBackupCode>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<OwnerBackupCodeUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<OwnerBackupCodeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OwnerBackupCodeTable>? orderBy,
    _is.OrderByListBuilder<OwnerBackupCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<OwnerBackupCode>(
      columnValues: columnValues(OwnerBackupCode.t.updateTable),
      where: where(OwnerBackupCode.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OwnerBackupCode.t),
      orderByList: orderByList?.call(OwnerBackupCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [OwnerBackupCode]s in the list and returns the deleted rows.
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
  Future<List<OwnerBackupCode>> delete(
    _is.DatabaseSession session,
    List<OwnerBackupCode> rows, {
    _is.OrderByBuilder<OwnerBackupCodeTable>? orderBy,
    _is.OrderByListBuilder<OwnerBackupCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<OwnerBackupCode>(
      rows,
      orderBy: orderBy?.call(OwnerBackupCode.t),
      orderByList: orderByList?.call(OwnerBackupCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [OwnerBackupCode].
  Future<OwnerBackupCode> deleteRow(
    _is.DatabaseSession session,
    OwnerBackupCode row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OwnerBackupCode>(
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
  Future<List<OwnerBackupCode>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OwnerBackupCodeTable> where,
    _is.OrderByBuilder<OwnerBackupCodeTable>? orderBy,
    _is.OrderByListBuilder<OwnerBackupCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<OwnerBackupCode>(
      where: where(OwnerBackupCode.t),
      orderBy: orderBy?.call(OwnerBackupCode.t),
      orderByList: orderByList?.call(OwnerBackupCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OwnerBackupCodeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<OwnerBackupCode>(
      where: where?.call(OwnerBackupCode.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [OwnerBackupCode] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OwnerBackupCodeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<OwnerBackupCode>(
      where: where(OwnerBackupCode.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
