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

/// Preferensi lokal perangkat yang tidak disinkronkan (mis. tema, bahasa
/// sebelum ada login staf).
abstract class LocalPreference
    implements _isd.TableRow<int?>, _isc.ProtocolSerialization {
  LocalPreference._({
    this.id,
    required this.key,
    required this.value,
  });

  factory LocalPreference({
    int? id,
    required String key,
    required String value,
  }) = _LocalPreferenceImpl;

  factory LocalPreference.fromJson(Map<String, dynamic> jsonSerialization) {
    return LocalPreference(
      id: jsonSerialization['id'] as int?,
      key: jsonSerialization['key'] as String,
      value: jsonSerialization['value'] as String,
    );
  }

  static final t = LocalPreferenceTable();

  static const db = LocalPreferenceRepository._();

  @override
  int? id;

  String key;

  String value;

  @override
  _isd.Table<int?> get table => t;

  /// Returns a shallow copy of this [LocalPreference]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  LocalPreference copyWith({
    int? id,
    String? key,
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LocalPreference',
      if (id != null) 'id': id,
      'key': key,
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LocalPreference',
      if (id != null) 'id': id,
      'key': key,
      'value': value,
    };
  }

  static LocalPreferenceInclude include() {
    return LocalPreferenceInclude._();
  }

  static LocalPreferenceIncludeList includeList({
    _isd.WhereExpressionBuilder<LocalPreferenceTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<LocalPreferenceTable>? orderBy,
    _isd.OrderByListBuilder<LocalPreferenceTable>? orderByList,
    LocalPreferenceInclude? include,
  }) {
    return LocalPreferenceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LocalPreference.t),
      orderByList: orderByList?.call(LocalPreference.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LocalPreferenceImpl extends LocalPreference {
  _LocalPreferenceImpl({
    int? id,
    required String key,
    required String value,
  }) : super._(
         id: id,
         key: key,
         value: value,
       );

  /// Returns a shallow copy of this [LocalPreference]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  LocalPreference copyWith({
    Object? id = _Undefined,
    String? key,
    String? value,
  }) {
    return LocalPreference(
      id: id is int? ? id : this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }
}

class LocalPreferenceUpdateTable
    extends _isd.UpdateTable<LocalPreferenceTable> {
  LocalPreferenceUpdateTable(super.table);

  _isd.ColumnValue<String, String> key(String value) => _isd.ColumnValue(
    table.key,
    value,
  );

  _isd.ColumnValue<String, String> value(String value) => _isd.ColumnValue(
    table.value,
    value,
  );
}

class LocalPreferenceTable extends _isd.Table<int?> {
  LocalPreferenceTable({super.tableRelation})
    : super(tableName: 'local_preferences') {
    updateTable = LocalPreferenceUpdateTable(this);
    key = _isd.ColumnString(
      'key',
      this,
    );
    value = _isd.ColumnString(
      'value',
      this,
    );
  }

  late final LocalPreferenceUpdateTable updateTable;

  late final _isd.ColumnString key;

  late final _isd.ColumnString value;

  @override
  List<_isd.Column> get columns => [
    id,
    key,
    value,
  ];
}

class LocalPreferenceInclude extends _isd.IncludeObject {
  LocalPreferenceInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<int?> get table => LocalPreference.t;
}

class LocalPreferenceIncludeList extends _isd.IncludeList {
  LocalPreferenceIncludeList._({
    _isd.WhereExpressionBuilder<LocalPreferenceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(LocalPreference.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<int?> get table => LocalPreference.t;
}

class LocalPreferenceRepository {
  const LocalPreferenceRepository._();

  /// Returns a list of [LocalPreference]s matching the given query parameters.
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
  Future<List<LocalPreference>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<LocalPreferenceTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<LocalPreferenceTable>? orderBy,
    _isd.OrderByListBuilder<LocalPreferenceTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<LocalPreference>(
      where: where?.call(LocalPreference.t),
      orderBy: orderBy?.call(LocalPreference.t),
      orderByList: orderByList?.call(LocalPreference.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [LocalPreference]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `LocalPreference.t`.
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
  _ida.Stream<List<LocalPreference>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<LocalPreferenceTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<LocalPreferenceTable>? orderBy,
    _isd.OrderByListBuilder<LocalPreferenceTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<LocalPreference>(
      where: where?.call(LocalPreference.t),
      orderBy: orderBy?.call(LocalPreference.t),
      orderByList: orderByList?.call(LocalPreference.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [LocalPreference] matching the given query parameters.
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
  Future<LocalPreference?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<LocalPreferenceTable>? where,
    int? offset,
    _isd.OrderByBuilder<LocalPreferenceTable>? orderBy,
    _isd.OrderByListBuilder<LocalPreferenceTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<LocalPreference>(
      where: where?.call(LocalPreference.t),
      orderBy: orderBy?.call(LocalPreference.t),
      orderByList: orderByList?.call(LocalPreference.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [LocalPreference] by its [id] or null if no such row exists.
  Future<LocalPreference?> findById(
    _isd.DatabaseSession session,
    int id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<LocalPreference>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [LocalPreference]s in the list and returns the inserted rows.
  ///
  /// The returned [LocalPreference]s will have their `id` fields set.
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
  Future<List<LocalPreference>> insert(
    _isd.DatabaseSession session,
    List<LocalPreference> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<LocalPreference>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [LocalPreference] and returns the inserted row.
  ///
  /// The returned [LocalPreference] will have its `id` field set.
  Future<LocalPreference> insertRow(
    _isd.DatabaseSession session,
    LocalPreference row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<LocalPreference>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [LocalPreference]s in the list and returns the resulting rows.
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
  /// The returned [LocalPreference]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LocalPreference>> upsert(
    _isd.DatabaseSession session,
    List<LocalPreference> rows, {
    required _isd.ColumnSelections<LocalPreferenceTable> conflictColumns,
    _isd.ColumnSelections<LocalPreferenceTable>? updateColumns,
    _isd.WhereExpressionBuilder<LocalPreferenceTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<LocalPreference>(
      rows,
      conflictColumns: conflictColumns(LocalPreference.t),
      updateColumns: updateColumns?.call(LocalPreference.t),
      updateWhere: updateWhere?.call(LocalPreference.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [LocalPreference] and returns the resulting row.
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
  /// The returned [LocalPreference] will have its `id` field set.
  Future<LocalPreference?> upsertRow(
    _isd.DatabaseSession session,
    LocalPreference row, {
    required _isd.ColumnSelections<LocalPreferenceTable> conflictColumns,
    _isd.ColumnSelections<LocalPreferenceTable>? updateColumns,
    _isd.WhereExpressionBuilder<LocalPreferenceTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<LocalPreference>(
      row,
      conflictColumns: conflictColumns(LocalPreference.t),
      updateColumns: updateColumns?.call(LocalPreference.t),
      updateWhere: updateWhere?.call(LocalPreference.t),
      transaction: transaction,
    );
  }

  /// Updates all [LocalPreference]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LocalPreference>> update(
    _isd.DatabaseSession session,
    List<LocalPreference> rows, {
    _isd.ColumnSelections<LocalPreferenceTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<LocalPreference>(
      rows,
      columns: columns?.call(LocalPreference.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [LocalPreference]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<LocalPreference> updateRow(
    _isd.DatabaseSession session,
    LocalPreference row, {
    _isd.ColumnSelections<LocalPreferenceTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<LocalPreference>(
      row,
      columns: columns?.call(LocalPreference.t),
      transaction: transaction,
    );
  }

  /// Updates a single [LocalPreference] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<LocalPreference?> updateById(
    _isd.DatabaseSession session,
    int id, {
    required _isd.ColumnValueListBuilder<LocalPreferenceUpdateTable>
    columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<LocalPreference>(
      id,
      columnValues: columnValues(LocalPreference.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [LocalPreference]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<LocalPreference>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<LocalPreferenceUpdateTable>
    columnValues,
    required _isd.WhereExpressionBuilder<LocalPreferenceTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<LocalPreferenceTable>? orderBy,
    _isd.OrderByListBuilder<LocalPreferenceTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<LocalPreference>(
      columnValues: columnValues(LocalPreference.t.updateTable),
      where: where(LocalPreference.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(LocalPreference.t),
      orderByList: orderByList?.call(LocalPreference.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [LocalPreference]s in the list and returns the deleted rows.
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
  Future<List<LocalPreference>> delete(
    _isd.DatabaseSession session,
    List<LocalPreference> rows, {
    _isd.OrderByBuilder<LocalPreferenceTable>? orderBy,
    _isd.OrderByListBuilder<LocalPreferenceTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<LocalPreference>(
      rows,
      orderBy: orderBy?.call(LocalPreference.t),
      orderByList: orderByList?.call(LocalPreference.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [LocalPreference].
  Future<LocalPreference> deleteRow(
    _isd.DatabaseSession session,
    LocalPreference row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<LocalPreference>(
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
  Future<List<LocalPreference>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<LocalPreferenceTable> where,
    _isd.OrderByBuilder<LocalPreferenceTable>? orderBy,
    _isd.OrderByListBuilder<LocalPreferenceTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<LocalPreference>(
      where: where(LocalPreference.t),
      orderBy: orderBy?.call(LocalPreference.t),
      orderByList: orderByList?.call(LocalPreference.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<LocalPreferenceTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<LocalPreference>(
      where: where?.call(LocalPreference.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [LocalPreference] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<LocalPreferenceTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<LocalPreference>(
      where: where(LocalPreference.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
