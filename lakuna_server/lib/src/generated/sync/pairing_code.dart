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

/// Kode pasang perangkat (8 karakter, 15 menit, sekali pakai). Hanya ada
/// di server; yang disimpan hash-nya.
abstract class PairingCode
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  PairingCode._({
    this.id,
    required this.tenantId,
    required this.codeHash,
    required this.createdByDeviceId,
    DateTime? createdAt,
    required this.expiresAt,
    this.usedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PairingCode({
    int? id,
    required _is.UuidValue tenantId,
    required String codeHash,
    required _is.UuidValue createdByDeviceId,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? usedAt,
  }) = _PairingCodeImpl;

  factory PairingCode.fromJson(Map<String, dynamic> jsonSerialization) {
    return PairingCode(
      id: jsonSerialization['id'] as int?,
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      codeHash: jsonSerialization['codeHash'] as String,
      createdByDeviceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['createdByDeviceId'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      usedAt: jsonSerialization['usedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['usedAt']),
    );
  }

  static final t = PairingCodeTable();

  static const db = PairingCodeRepository._();

  @override
  int? id;

  _is.UuidValue tenantId;

  String codeHash;

  _is.UuidValue createdByDeviceId;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime? usedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [PairingCode]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PairingCode copyWith({
    int? id,
    _is.UuidValue? tenantId,
    String? codeHash,
    _is.UuidValue? createdByDeviceId,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? usedAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PairingCode',
      if (id != null) 'id': id,
      'tenantId': tenantId.toJson(),
      'codeHash': codeHash,
      'createdByDeviceId': createdByDeviceId.toJson(),
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PairingCodeInclude include() {
    return PairingCodeInclude._();
  }

  static PairingCodeIncludeList includeList({
    _is.WhereExpressionBuilder<PairingCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PairingCodeTable>? orderBy,
    _is.OrderByListBuilder<PairingCodeTable>? orderByList,
    PairingCodeInclude? include,
  }) {
    return PairingCodeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PairingCode.t),
      orderByList: orderByList?.call(PairingCode.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PairingCodeImpl extends PairingCode {
  _PairingCodeImpl({
    int? id,
    required _is.UuidValue tenantId,
    required String codeHash,
    required _is.UuidValue createdByDeviceId,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? usedAt,
  }) : super._(
         id: id,
         tenantId: tenantId,
         codeHash: codeHash,
         createdByDeviceId: createdByDeviceId,
         createdAt: createdAt,
         expiresAt: expiresAt,
         usedAt: usedAt,
       );

  /// Returns a shallow copy of this [PairingCode]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PairingCode copyWith({
    Object? id = _Undefined,
    _is.UuidValue? tenantId,
    String? codeHash,
    _is.UuidValue? createdByDeviceId,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? usedAt = const _is.$UndefinedDateTime(),
  }) {
    return PairingCode(
      id: id is int? ? id : this.id,
      tenantId: tenantId ?? this.tenantId,
      codeHash: codeHash ?? this.codeHash,
      createdByDeviceId: createdByDeviceId ?? this.createdByDeviceId,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt is _is.UndefinedSentinel ? this.usedAt : usedAt,
    );
  }
}

class PairingCodeUpdateTable extends _is.UpdateTable<PairingCodeTable> {
  PairingCodeUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<String, String> codeHash(String value) => _is.ColumnValue(
    table.codeHash,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> createdByDeviceId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.createdByDeviceId,
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
}

class PairingCodeTable extends _is.Table<int?> {
  PairingCodeTable({super.tableRelation}) : super(tableName: 'pairing_codes') {
    updateTable = PairingCodeUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    codeHash = _is.ColumnString(
      'code_hash',
      this,
      fieldName: 'codeHash',
    );
    createdByDeviceId = _is.ColumnUuid(
      'created_by_device_id',
      this,
      fieldName: 'createdByDeviceId',
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
  }

  late final PairingCodeUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnString codeHash;

  late final _is.ColumnUuid createdByDeviceId;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime expiresAt;

  late final _is.ColumnDateTime usedAt;

  @override
  List<_is.Column> get columns => [
    id,
    tenantId,
    codeHash,
    createdByDeviceId,
    createdAt,
    expiresAt,
    usedAt,
  ];
}

class PairingCodeInclude extends _is.IncludeObject {
  PairingCodeInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => PairingCode.t;
}

class PairingCodeIncludeList extends _is.IncludeList {
  PairingCodeIncludeList._({
    _is.WhereExpressionBuilder<PairingCodeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PairingCode.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => PairingCode.t;
}

class PairingCodeRepository {
  const PairingCodeRepository._();

  /// Returns a list of [PairingCode]s matching the given query parameters.
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
  Future<List<PairingCode>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PairingCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PairingCodeTable>? orderBy,
    _is.OrderByListBuilder<PairingCodeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PairingCode>(
      where: where?.call(PairingCode.t),
      orderBy: orderBy?.call(PairingCode.t),
      orderByList: orderByList?.call(PairingCode.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [PairingCode]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `PairingCode.t`.
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
  _ida.Stream<List<PairingCode>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PairingCodeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PairingCodeTable>? orderBy,
    _is.OrderByListBuilder<PairingCodeTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<PairingCode>(
      where: where?.call(PairingCode.t),
      orderBy: orderBy?.call(PairingCode.t),
      orderByList: orderByList?.call(PairingCode.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [PairingCode] matching the given query parameters.
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
  Future<PairingCode?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PairingCodeTable>? where,
    int? offset,
    _is.OrderByBuilder<PairingCodeTable>? orderBy,
    _is.OrderByListBuilder<PairingCodeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PairingCode>(
      where: where?.call(PairingCode.t),
      orderBy: orderBy?.call(PairingCode.t),
      orderByList: orderByList?.call(PairingCode.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PairingCode] by its [id] or null if no such row exists.
  Future<PairingCode?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PairingCode>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PairingCode]s in the list and returns the inserted rows.
  ///
  /// The returned [PairingCode]s will have their `id` fields set.
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
  Future<List<PairingCode>> insert(
    _is.DatabaseSession session,
    List<PairingCode> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PairingCode>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PairingCode] and returns the inserted row.
  ///
  /// The returned [PairingCode] will have its `id` field set.
  Future<PairingCode> insertRow(
    _is.DatabaseSession session,
    PairingCode row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PairingCode>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PairingCode]s in the list and returns the resulting rows.
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
  /// The returned [PairingCode]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PairingCode>> upsert(
    _is.DatabaseSession session,
    List<PairingCode> rows, {
    required _is.ColumnSelections<PairingCodeTable> conflictColumns,
    _is.ColumnSelections<PairingCodeTable>? updateColumns,
    _is.WhereExpressionBuilder<PairingCodeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PairingCode>(
      rows,
      conflictColumns: conflictColumns(PairingCode.t),
      updateColumns: updateColumns?.call(PairingCode.t),
      updateWhere: updateWhere?.call(PairingCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PairingCode] and returns the resulting row.
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
  /// The returned [PairingCode] will have its `id` field set.
  Future<PairingCode?> upsertRow(
    _is.DatabaseSession session,
    PairingCode row, {
    required _is.ColumnSelections<PairingCodeTable> conflictColumns,
    _is.ColumnSelections<PairingCodeTable>? updateColumns,
    _is.WhereExpressionBuilder<PairingCodeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PairingCode>(
      row,
      conflictColumns: conflictColumns(PairingCode.t),
      updateColumns: updateColumns?.call(PairingCode.t),
      updateWhere: updateWhere?.call(PairingCode.t),
      transaction: transaction,
    );
  }

  /// Updates all [PairingCode]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PairingCode>> update(
    _is.DatabaseSession session,
    List<PairingCode> rows, {
    _is.ColumnSelections<PairingCodeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PairingCode>(
      rows,
      columns: columns?.call(PairingCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PairingCode]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PairingCode> updateRow(
    _is.DatabaseSession session,
    PairingCode row, {
    _is.ColumnSelections<PairingCodeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PairingCode>(
      row,
      columns: columns?.call(PairingCode.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PairingCode] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PairingCode?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<PairingCodeUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PairingCode>(
      id,
      columnValues: columnValues(PairingCode.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PairingCode]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PairingCode>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PairingCodeUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PairingCodeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PairingCodeTable>? orderBy,
    _is.OrderByListBuilder<PairingCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PairingCode>(
      columnValues: columnValues(PairingCode.t.updateTable),
      where: where(PairingCode.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PairingCode.t),
      orderByList: orderByList?.call(PairingCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PairingCode]s in the list and returns the deleted rows.
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
  Future<List<PairingCode>> delete(
    _is.DatabaseSession session,
    List<PairingCode> rows, {
    _is.OrderByBuilder<PairingCodeTable>? orderBy,
    _is.OrderByListBuilder<PairingCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PairingCode>(
      rows,
      orderBy: orderBy?.call(PairingCode.t),
      orderByList: orderByList?.call(PairingCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PairingCode].
  Future<PairingCode> deleteRow(
    _is.DatabaseSession session,
    PairingCode row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PairingCode>(
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
  Future<List<PairingCode>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PairingCodeTable> where,
    _is.OrderByBuilder<PairingCodeTable>? orderBy,
    _is.OrderByListBuilder<PairingCodeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PairingCode>(
      where: where(PairingCode.t),
      orderBy: orderBy?.call(PairingCode.t),
      orderByList: orderByList?.call(PairingCode.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PairingCodeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PairingCode>(
      where: where?.call(PairingCode.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PairingCode] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PairingCodeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PairingCode>(
      where: where(PairingCode.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
