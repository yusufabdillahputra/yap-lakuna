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

/// Token perangkat versi hosting (F2-01 aturan 11). Server hanya menyimpan
/// hash SHA-256 token. Hanya ada di server.
abstract class DeviceCredential
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  DeviceCredential._({
    this.id,
    required this.tenantId,
    required this.deviceId,
    required this.tokenHash,
    DateTime? createdAt,
    this.lastSeenAt,
    this.revokedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DeviceCredential({
    int? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue deviceId,
    required String tokenHash,
    DateTime? createdAt,
    DateTime? lastSeenAt,
    DateTime? revokedAt,
  }) = _DeviceCredentialImpl;

  factory DeviceCredential.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeviceCredential(
      id: jsonSerialization['id'] as int?,
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      deviceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['deviceId'],
      ),
      tokenHash: jsonSerialization['tokenHash'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      lastSeenAt: jsonSerialization['lastSeenAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['lastSeenAt']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
    );
  }

  static final t = DeviceCredentialTable();

  static const db = DeviceCredentialRepository._();

  @override
  int? id;

  _is.UuidValue tenantId;

  _is.UuidValue deviceId;

  String tokenHash;

  DateTime createdAt;

  DateTime? lastSeenAt;

  DateTime? revokedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [DeviceCredential]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DeviceCredential copyWith({
    int? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? deviceId,
    String? tokenHash,
    DateTime? createdAt,
    DateTime? lastSeenAt = const _is.$UndefinedDateTime(),
    DateTime? revokedAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeviceCredential',
      if (id != null) 'id': id,
      'tenantId': tenantId.toJson(),
      'deviceId': deviceId.toJson(),
      'tokenHash': tokenHash,
      'createdAt': createdAt.toJson(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static DeviceCredentialInclude include() {
    return DeviceCredentialInclude._();
  }

  static DeviceCredentialIncludeList includeList({
    _is.WhereExpressionBuilder<DeviceCredentialTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DeviceCredentialTable>? orderBy,
    _is.OrderByListBuilder<DeviceCredentialTable>? orderByList,
    DeviceCredentialInclude? include,
  }) {
    return DeviceCredentialIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DeviceCredential.t),
      orderByList: orderByList?.call(DeviceCredential.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeviceCredentialImpl extends DeviceCredential {
  _DeviceCredentialImpl({
    int? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue deviceId,
    required String tokenHash,
    DateTime? createdAt,
    DateTime? lastSeenAt,
    DateTime? revokedAt,
  }) : super._(
         id: id,
         tenantId: tenantId,
         deviceId: deviceId,
         tokenHash: tokenHash,
         createdAt: createdAt,
         lastSeenAt: lastSeenAt,
         revokedAt: revokedAt,
       );

  /// Returns a shallow copy of this [DeviceCredential]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DeviceCredential copyWith({
    Object? id = _Undefined,
    _is.UuidValue? tenantId,
    _is.UuidValue? deviceId,
    String? tokenHash,
    DateTime? createdAt,
    DateTime? lastSeenAt = const _is.$UndefinedDateTime(),
    DateTime? revokedAt = const _is.$UndefinedDateTime(),
  }) {
    return DeviceCredential(
      id: id is int? ? id : this.id,
      tenantId: tenantId ?? this.tenantId,
      deviceId: deviceId ?? this.deviceId,
      tokenHash: tokenHash ?? this.tokenHash,
      createdAt: createdAt ?? this.createdAt,
      lastSeenAt: lastSeenAt is _is.UndefinedSentinel
          ? this.lastSeenAt
          : lastSeenAt,
      revokedAt: revokedAt is _is.UndefinedSentinel
          ? this.revokedAt
          : revokedAt,
    );
  }
}

class DeviceCredentialUpdateTable
    extends _is.UpdateTable<DeviceCredentialTable> {
  DeviceCredentialUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> deviceId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.deviceId,
        value,
      );

  _is.ColumnValue<String, String> tokenHash(String value) => _is.ColumnValue(
    table.tokenHash,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> lastSeenAt(DateTime? value) =>
      _is.ColumnValue(
        table.lastSeenAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> revokedAt(DateTime? value) =>
      _is.ColumnValue(
        table.revokedAt,
        value,
      );
}

class DeviceCredentialTable extends _is.Table<int?> {
  DeviceCredentialTable({super.tableRelation})
    : super(tableName: 'device_credentials') {
    updateTable = DeviceCredentialUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    deviceId = _is.ColumnUuid(
      'device_id',
      this,
      fieldName: 'deviceId',
    );
    tokenHash = _is.ColumnString(
      'token_hash',
      this,
      fieldName: 'tokenHash',
    );
    createdAt = _is.ColumnDateTime(
      'created_at',
      this,
      hasDefault: true,
      fieldName: 'createdAt',
    );
    lastSeenAt = _is.ColumnDateTime(
      'last_seen_at',
      this,
      fieldName: 'lastSeenAt',
    );
    revokedAt = _is.ColumnDateTime(
      'revoked_at',
      this,
      fieldName: 'revokedAt',
    );
  }

  late final DeviceCredentialUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid deviceId;

  late final _is.ColumnString tokenHash;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime lastSeenAt;

  late final _is.ColumnDateTime revokedAt;

  @override
  List<_is.Column> get columns => [
    id,
    tenantId,
    deviceId,
    tokenHash,
    createdAt,
    lastSeenAt,
    revokedAt,
  ];
}

class DeviceCredentialInclude extends _is.IncludeObject {
  DeviceCredentialInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => DeviceCredential.t;
}

class DeviceCredentialIncludeList extends _is.IncludeList {
  DeviceCredentialIncludeList._({
    _is.WhereExpressionBuilder<DeviceCredentialTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DeviceCredential.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => DeviceCredential.t;
}

class DeviceCredentialRepository {
  const DeviceCredentialRepository._();

  /// Returns a list of [DeviceCredential]s matching the given query parameters.
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
  Future<List<DeviceCredential>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DeviceCredentialTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DeviceCredentialTable>? orderBy,
    _is.OrderByListBuilder<DeviceCredentialTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DeviceCredential>(
      where: where?.call(DeviceCredential.t),
      orderBy: orderBy?.call(DeviceCredential.t),
      orderByList: orderByList?.call(DeviceCredential.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [DeviceCredential]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `DeviceCredential.t`.
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
  _ida.Stream<List<DeviceCredential>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DeviceCredentialTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DeviceCredentialTable>? orderBy,
    _is.OrderByListBuilder<DeviceCredentialTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<DeviceCredential>(
      where: where?.call(DeviceCredential.t),
      orderBy: orderBy?.call(DeviceCredential.t),
      orderByList: orderByList?.call(DeviceCredential.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [DeviceCredential] matching the given query parameters.
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
  Future<DeviceCredential?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DeviceCredentialTable>? where,
    int? offset,
    _is.OrderByBuilder<DeviceCredentialTable>? orderBy,
    _is.OrderByListBuilder<DeviceCredentialTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DeviceCredential>(
      where: where?.call(DeviceCredential.t),
      orderBy: orderBy?.call(DeviceCredential.t),
      orderByList: orderByList?.call(DeviceCredential.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DeviceCredential] by its [id] or null if no such row exists.
  Future<DeviceCredential?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DeviceCredential>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DeviceCredential]s in the list and returns the inserted rows.
  ///
  /// The returned [DeviceCredential]s will have their `id` fields set.
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
  Future<List<DeviceCredential>> insert(
    _is.DatabaseSession session,
    List<DeviceCredential> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DeviceCredential>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DeviceCredential] and returns the inserted row.
  ///
  /// The returned [DeviceCredential] will have its `id` field set.
  Future<DeviceCredential> insertRow(
    _is.DatabaseSession session,
    DeviceCredential row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<DeviceCredential>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DeviceCredential]s in the list and returns the resulting rows.
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
  /// The returned [DeviceCredential]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DeviceCredential>> upsert(
    _is.DatabaseSession session,
    List<DeviceCredential> rows, {
    required _is.ColumnSelections<DeviceCredentialTable> conflictColumns,
    _is.ColumnSelections<DeviceCredentialTable>? updateColumns,
    _is.WhereExpressionBuilder<DeviceCredentialTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DeviceCredential>(
      rows,
      conflictColumns: conflictColumns(DeviceCredential.t),
      updateColumns: updateColumns?.call(DeviceCredential.t),
      updateWhere: updateWhere?.call(DeviceCredential.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DeviceCredential] and returns the resulting row.
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
  /// The returned [DeviceCredential] will have its `id` field set.
  Future<DeviceCredential?> upsertRow(
    _is.DatabaseSession session,
    DeviceCredential row, {
    required _is.ColumnSelections<DeviceCredentialTable> conflictColumns,
    _is.ColumnSelections<DeviceCredentialTable>? updateColumns,
    _is.WhereExpressionBuilder<DeviceCredentialTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DeviceCredential>(
      row,
      conflictColumns: conflictColumns(DeviceCredential.t),
      updateColumns: updateColumns?.call(DeviceCredential.t),
      updateWhere: updateWhere?.call(DeviceCredential.t),
      transaction: transaction,
    );
  }

  /// Updates all [DeviceCredential]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DeviceCredential>> update(
    _is.DatabaseSession session,
    List<DeviceCredential> rows, {
    _is.ColumnSelections<DeviceCredentialTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DeviceCredential>(
      rows,
      columns: columns?.call(DeviceCredential.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DeviceCredential]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DeviceCredential> updateRow(
    _is.DatabaseSession session,
    DeviceCredential row, {
    _is.ColumnSelections<DeviceCredentialTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<DeviceCredential>(
      row,
      columns: columns?.call(DeviceCredential.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DeviceCredential] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DeviceCredential?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<DeviceCredentialUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<DeviceCredential>(
      id,
      columnValues: columnValues(DeviceCredential.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DeviceCredential]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DeviceCredential>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DeviceCredentialUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<DeviceCredentialTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DeviceCredentialTable>? orderBy,
    _is.OrderByListBuilder<DeviceCredentialTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DeviceCredential>(
      columnValues: columnValues(DeviceCredential.t.updateTable),
      where: where(DeviceCredential.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DeviceCredential.t),
      orderByList: orderByList?.call(DeviceCredential.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DeviceCredential]s in the list and returns the deleted rows.
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
  Future<List<DeviceCredential>> delete(
    _is.DatabaseSession session,
    List<DeviceCredential> rows, {
    _is.OrderByBuilder<DeviceCredentialTable>? orderBy,
    _is.OrderByListBuilder<DeviceCredentialTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DeviceCredential>(
      rows,
      orderBy: orderBy?.call(DeviceCredential.t),
      orderByList: orderByList?.call(DeviceCredential.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DeviceCredential].
  Future<DeviceCredential> deleteRow(
    _is.DatabaseSession session,
    DeviceCredential row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DeviceCredential>(
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
  Future<List<DeviceCredential>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DeviceCredentialTable> where,
    _is.OrderByBuilder<DeviceCredentialTable>? orderBy,
    _is.OrderByListBuilder<DeviceCredentialTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DeviceCredential>(
      where: where(DeviceCredential.t),
      orderBy: orderBy?.call(DeviceCredential.t),
      orderByList: orderByList?.call(DeviceCredential.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DeviceCredentialTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DeviceCredential>(
      where: where?.call(DeviceCredential.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DeviceCredential] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DeviceCredentialTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DeviceCredential>(
      where: where(DeviceCredential.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
