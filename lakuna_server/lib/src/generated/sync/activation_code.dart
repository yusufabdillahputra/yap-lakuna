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

/// Kode aktivasi sekali pakai yang dibuat admin server lewat CLI
/// (`lakuna-admin activation-code`). Hanya ada di server; yang disimpan
/// hash-nya.
abstract class ActivationCode
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ActivationCode._({
    this.id,
    required this.codeHash,
    required this.note,
    DateTime? createdAt,
    required this.expiresAt,
    this.usedAt,
    this.tenantId,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ActivationCode({
    int? id,
    required String codeHash,
    required String note,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? usedAt,
    _is.UuidValue? tenantId,
  }) = _ActivationCodeImpl;

  factory ActivationCode.fromJson(Map<String, dynamic> jsonSerialization) {
    return ActivationCode(
      id: jsonSerialization['id'] as int?,
      codeHash: jsonSerialization['codeHash'] as String,
      note: jsonSerialization['note'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      usedAt: jsonSerialization['usedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['usedAt']),
      tenantId: jsonSerialization['tenantId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['tenantId']),
    );
  }

  static final t = ActivationCodeTable();

  static const db = ActivationCodeRepository._();

  @override
  int? id;

  String codeHash;

  /// Catatan admin, mis. nama toko pemesan.
  String note;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime? usedAt;

  _is.UuidValue? tenantId;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ActivationCode]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ActivationCode copyWith({
    int? id,
    String? codeHash,
    String? note,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? usedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? tenantId = const _is.$UndefinedUuidValue(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ActivationCode',
      if (id != null) 'id': id,
      'codeHash': codeHash,
      'note': note,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
      if (tenantId != null) 'tenantId': tenantId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static ActivationCodeInclude include() {
    return ActivationCodeInclude._();
  }

  static ActivationCodeIncludeList includeList({
    _is.WhereExpressionBuilder<ActivationCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ActivationCodeTable>? orderBy,
    _is.OrderByListBuilder<ActivationCodeTable>? orderByList,
    ActivationCodeInclude? include,
  }) {
    return ActivationCodeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ActivationCode.t),
      orderByList: orderByList?.call(ActivationCode.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ActivationCodeImpl extends ActivationCode {
  _ActivationCodeImpl({
    int? id,
    required String codeHash,
    required String note,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? usedAt,
    _is.UuidValue? tenantId,
  }) : super._(
         id: id,
         codeHash: codeHash,
         note: note,
         createdAt: createdAt,
         expiresAt: expiresAt,
         usedAt: usedAt,
         tenantId: tenantId,
       );

  /// Returns a shallow copy of this [ActivationCode]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ActivationCode copyWith({
    Object? id = _Undefined,
    String? codeHash,
    String? note,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? usedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? tenantId = const _is.$UndefinedUuidValue(),
  }) {
    return ActivationCode(
      id: id is int? ? id : this.id,
      codeHash: codeHash ?? this.codeHash,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt is _is.UndefinedSentinel ? this.usedAt : usedAt,
      tenantId: tenantId is _is.UndefinedSentinel ? this.tenantId : tenantId,
    );
  }
}

class ActivationCodeUpdateTable extends _is.UpdateTable<ActivationCodeTable> {
  ActivationCodeUpdateTable(super.table);

  _is.ColumnValue<String, String> codeHash(String value) => _is.ColumnValue(
    table.codeHash,
    value,
  );

  _is.ColumnValue<String, String> note(String value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> expiresAt(DateTime value) =>
      _is.ColumnValue(
        table.expiresAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> usedAt(DateTime? value) =>
      _is.ColumnValue(
        table.usedAt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.tenantId,
    value,
  );
}

class ActivationCodeTable extends _is.Table<int?> {
  ActivationCodeTable({super.tableRelation})
    : super(tableName: 'activation_codes') {
    updateTable = ActivationCodeUpdateTable(this);
    codeHash = _is.ColumnString(
      'code_hash',
      this,
      fieldName: 'codeHash',
    );
    note = _is.ColumnString(
      'note',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'created_at',
      this,
      hasDefault: true,
      fieldName: 'createdAt',
    );
    expiresAt = _is.ColumnDateTime(
      'expires_at',
      this,
      fieldName: 'expiresAt',
    );
    usedAt = _is.ColumnDateTime(
      'used_at',
      this,
      fieldName: 'usedAt',
    );
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
  }

  late final ActivationCodeUpdateTable updateTable;

  late final _is.ColumnString codeHash;

  /// Catatan admin, mis. nama toko pemesan.
  late final _is.ColumnString note;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime usedAt;

  late final _is.ColumnUuid tenantId;

  @override
  List<_is.Column> get columns => [
    id,
    codeHash,
    note,
    createdAt,
    expiresAt,
    usedAt,
    tenantId,
  ];
}

class ActivationCodeInclude extends _is.IncludeObject {
  ActivationCodeInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => ActivationCode.t;
}

class ActivationCodeIncludeList extends _is.IncludeList {
  ActivationCodeIncludeList._({
    _is.WhereExpressionBuilder<ActivationCodeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ActivationCode.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ActivationCode.t;
}

class ActivationCodeRepository {
  const ActivationCodeRepository._();

  /// Returns a list of [ActivationCode]s matching the given query parameters.
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
  Future<List<ActivationCode>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ActivationCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ActivationCodeTable>? orderBy,
    _is.OrderByListBuilder<ActivationCodeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ActivationCode>(
      where: where?.call(ActivationCode.t),
      orderBy: orderBy?.call(ActivationCode.t),
      orderByList: orderByList?.call(ActivationCode.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [ActivationCode]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `ActivationCode.t`.
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
  _ida.Stream<List<ActivationCode>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ActivationCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ActivationCodeTable>? orderBy,
    _is.OrderByListBuilder<ActivationCodeTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<ActivationCode>(
      where: where?.call(ActivationCode.t),
      orderBy: orderBy?.call(ActivationCode.t),
      orderByList: orderByList?.call(ActivationCode.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [ActivationCode] matching the given query parameters.
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
  Future<ActivationCode?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ActivationCodeTable>? where,
    int? offset,
    _is.OrderByBuilder<ActivationCodeTable>? orderBy,
    _is.OrderByListBuilder<ActivationCodeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ActivationCode>(
      where: where?.call(ActivationCode.t),
      orderBy: orderBy?.call(ActivationCode.t),
      orderByList: orderByList?.call(ActivationCode.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ActivationCode] by its [id] or null if no such row exists.
  Future<ActivationCode?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ActivationCode>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ActivationCode]s in the list and returns the inserted rows.
  ///
  /// The returned [ActivationCode]s will have their `id` fields set.
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
  Future<List<ActivationCode>> insert(
    _is.DatabaseSession session,
    List<ActivationCode> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ActivationCode>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ActivationCode] and returns the inserted row.
  ///
  /// The returned [ActivationCode] will have its `id` field set.
  Future<ActivationCode> insertRow(
    _is.DatabaseSession session,
    ActivationCode row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ActivationCode>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ActivationCode]s in the list and returns the resulting rows.
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
  /// The returned [ActivationCode]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ActivationCode>> upsert(
    _is.DatabaseSession session,
    List<ActivationCode> rows, {
    required _is.ColumnSelections<ActivationCodeTable> conflictColumns,
    _is.ColumnSelections<ActivationCodeTable>? updateColumns,
    _is.WhereExpressionBuilder<ActivationCodeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ActivationCode>(
      rows,
      conflictColumns: conflictColumns(ActivationCode.t),
      updateColumns: updateColumns?.call(ActivationCode.t),
      updateWhere: updateWhere?.call(ActivationCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ActivationCode] and returns the resulting row.
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
  /// The returned [ActivationCode] will have its `id` field set.
  Future<ActivationCode?> upsertRow(
    _is.DatabaseSession session,
    ActivationCode row, {
    required _is.ColumnSelections<ActivationCodeTable> conflictColumns,
    _is.ColumnSelections<ActivationCodeTable>? updateColumns,
    _is.WhereExpressionBuilder<ActivationCodeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ActivationCode>(
      row,
      conflictColumns: conflictColumns(ActivationCode.t),
      updateColumns: updateColumns?.call(ActivationCode.t),
      updateWhere: updateWhere?.call(ActivationCode.t),
      transaction: transaction,
    );
  }

  /// Updates all [ActivationCode]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ActivationCode>> update(
    _is.DatabaseSession session,
    List<ActivationCode> rows, {
    _is.ColumnSelections<ActivationCodeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ActivationCode>(
      rows,
      columns: columns?.call(ActivationCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ActivationCode]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ActivationCode> updateRow(
    _is.DatabaseSession session,
    ActivationCode row, {
    _is.ColumnSelections<ActivationCodeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ActivationCode>(
      row,
      columns: columns?.call(ActivationCode.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ActivationCode] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ActivationCode?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ActivationCodeUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ActivationCode>(
      id,
      columnValues: columnValues(ActivationCode.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ActivationCode]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ActivationCode>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ActivationCodeUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ActivationCodeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ActivationCodeTable>? orderBy,
    _is.OrderByListBuilder<ActivationCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ActivationCode>(
      columnValues: columnValues(ActivationCode.t.updateTable),
      where: where(ActivationCode.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ActivationCode.t),
      orderByList: orderByList?.call(ActivationCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ActivationCode]s in the list and returns the deleted rows.
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
  Future<List<ActivationCode>> delete(
    _is.DatabaseSession session,
    List<ActivationCode> rows, {
    _is.OrderByBuilder<ActivationCodeTable>? orderBy,
    _is.OrderByListBuilder<ActivationCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ActivationCode>(
      rows,
      orderBy: orderBy?.call(ActivationCode.t),
      orderByList: orderByList?.call(ActivationCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ActivationCode].
  Future<ActivationCode> deleteRow(
    _is.DatabaseSession session,
    ActivationCode row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ActivationCode>(
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
  Future<List<ActivationCode>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ActivationCodeTable> where,
    _is.OrderByBuilder<ActivationCodeTable>? orderBy,
    _is.OrderByListBuilder<ActivationCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ActivationCode>(
      where: where(ActivationCode.t),
      orderBy: orderBy?.call(ActivationCode.t),
      orderByList: orderByList?.call(ActivationCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ActivationCodeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ActivationCode>(
      where: where?.call(ActivationCode.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ActivationCode] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ActivationCodeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ActivationCode>(
      where: where(ActivationCode.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
