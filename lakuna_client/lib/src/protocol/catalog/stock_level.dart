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

/// Cache saldo stok per lokasi dan varian, hanya di perangkat. Diperbarui
/// bersama `stock_movements` dan bisa dibangun ulang dari ledger.
abstract class StockLevel
    implements _isd.TableRow<int?>, _isc.ProtocolSerialization {
  StockLevel._({
    this.id,
    required this.stockLocationId,
    required this.variantId,
    required this.quantityMilli,
    required this.avgCost,
  });

  factory StockLevel({
    int? id,
    required _isc.UuidValue stockLocationId,
    required _isc.UuidValue variantId,
    required int quantityMilli,
    required int avgCost,
  }) = _StockLevelImpl;

  factory StockLevel.fromJson(Map<String, dynamic> jsonSerialization) {
    return StockLevel(
      id: jsonSerialization['id'] as int?,
      stockLocationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['stockLocationId'],
      ),
      variantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['variantId'],
      ),
      quantityMilli: jsonSerialization['quantityMilli'] as int,
      avgCost: jsonSerialization['avgCost'] as int,
    );
  }

  static final t = StockLevelTable();

  static const db = StockLevelRepository._();

  @override
  int? id;

  _isc.UuidValue stockLocationId;

  _isc.UuidValue variantId;

  int quantityMilli;

  /// Rata-rata biaya per satuan dasar; hanya berubah oleh barang masuk.
  int avgCost;

  @override
  _isd.Table<int?> get table => t;

  /// Returns a shallow copy of this [StockLevel]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  StockLevel copyWith({
    int? id,
    _isc.UuidValue? stockLocationId,
    _isc.UuidValue? variantId,
    int? quantityMilli,
    int? avgCost,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StockLevel',
      if (id != null) 'id': id,
      'stockLocationId': stockLocationId.toJson(),
      'variantId': variantId.toJson(),
      'quantityMilli': quantityMilli,
      'avgCost': avgCost,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StockLevel',
      if (id != null) 'id': id,
      'stockLocationId': stockLocationId.toJson(),
      'variantId': variantId.toJson(),
      'quantityMilli': quantityMilli,
      'avgCost': avgCost,
    };
  }

  static StockLevelInclude include() {
    return StockLevelInclude._();
  }

  static StockLevelIncludeList includeList({
    _isd.WhereExpressionBuilder<StockLevelTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StockLevelTable>? orderBy,
    _isd.OrderByListBuilder<StockLevelTable>? orderByList,
    StockLevelInclude? include,
  }) {
    return StockLevelIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StockLevel.t),
      orderByList: orderByList?.call(StockLevel.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StockLevelImpl extends StockLevel {
  _StockLevelImpl({
    int? id,
    required _isc.UuidValue stockLocationId,
    required _isc.UuidValue variantId,
    required int quantityMilli,
    required int avgCost,
  }) : super._(
         id: id,
         stockLocationId: stockLocationId,
         variantId: variantId,
         quantityMilli: quantityMilli,
         avgCost: avgCost,
       );

  /// Returns a shallow copy of this [StockLevel]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  StockLevel copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? stockLocationId,
    _isc.UuidValue? variantId,
    int? quantityMilli,
    int? avgCost,
  }) {
    return StockLevel(
      id: id is int? ? id : this.id,
      stockLocationId: stockLocationId ?? this.stockLocationId,
      variantId: variantId ?? this.variantId,
      quantityMilli: quantityMilli ?? this.quantityMilli,
      avgCost: avgCost ?? this.avgCost,
    );
  }
}

class StockLevelUpdateTable extends _isd.UpdateTable<StockLevelTable> {
  StockLevelUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> stockLocationId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.stockLocationId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> variantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.variantId,
    value,
  );

  _isd.ColumnValue<int, int> quantityMilli(int value) => _isd.ColumnValue(
    table.quantityMilli,
    value,
  );

  _isd.ColumnValue<int, int> avgCost(int value) => _isd.ColumnValue(
    table.avgCost,
    value,
  );
}

class StockLevelTable extends _isd.Table<int?> {
  StockLevelTable({super.tableRelation}) : super(tableName: 'stock_levels') {
    updateTable = StockLevelUpdateTable(this);
    stockLocationId = _isd.ColumnUuid(
      'stock_location_id',
      this,
      fieldName: 'stockLocationId',
    );
    variantId = _isd.ColumnUuid(
      'variant_id',
      this,
      fieldName: 'variantId',
    );
    quantityMilli = _isd.ColumnInt(
      'quantity_milli',
      this,
      fieldName: 'quantityMilli',
    );
    avgCost = _isd.ColumnInt(
      'avg_cost',
      this,
      fieldName: 'avgCost',
    );
  }

  late final StockLevelUpdateTable updateTable;

  late final _isd.ColumnUuid stockLocationId;

  late final _isd.ColumnUuid variantId;

  late final _isd.ColumnInt quantityMilli;

  /// Rata-rata biaya per satuan dasar; hanya berubah oleh barang masuk.
  late final _isd.ColumnInt avgCost;

  @override
  List<_isd.Column> get columns => [
    id,
    stockLocationId,
    variantId,
    quantityMilli,
    avgCost,
  ];
}

class StockLevelInclude extends _isd.IncludeObject {
  StockLevelInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<int?> get table => StockLevel.t;
}

class StockLevelIncludeList extends _isd.IncludeList {
  StockLevelIncludeList._({
    _isd.WhereExpressionBuilder<StockLevelTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StockLevel.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<int?> get table => StockLevel.t;
}

class StockLevelRepository {
  const StockLevelRepository._();

  /// Returns a list of [StockLevel]s matching the given query parameters.
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
  Future<List<StockLevel>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StockLevelTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StockLevelTable>? orderBy,
    _isd.OrderByListBuilder<StockLevelTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StockLevel>(
      where: where?.call(StockLevel.t),
      orderBy: orderBy?.call(StockLevel.t),
      orderByList: orderByList?.call(StockLevel.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [StockLevel]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `StockLevel.t`.
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
  _ida.Stream<List<StockLevel>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StockLevelTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StockLevelTable>? orderBy,
    _isd.OrderByListBuilder<StockLevelTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<StockLevel>(
      where: where?.call(StockLevel.t),
      orderBy: orderBy?.call(StockLevel.t),
      orderByList: orderByList?.call(StockLevel.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [StockLevel] matching the given query parameters.
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
  Future<StockLevel?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StockLevelTable>? where,
    int? offset,
    _isd.OrderByBuilder<StockLevelTable>? orderBy,
    _isd.OrderByListBuilder<StockLevelTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StockLevel>(
      where: where?.call(StockLevel.t),
      orderBy: orderBy?.call(StockLevel.t),
      orderByList: orderByList?.call(StockLevel.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StockLevel] by its [id] or null if no such row exists.
  Future<StockLevel?> findById(
    _isd.DatabaseSession session,
    int id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StockLevel>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StockLevel]s in the list and returns the inserted rows.
  ///
  /// The returned [StockLevel]s will have their `id` fields set.
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
  Future<List<StockLevel>> insert(
    _isd.DatabaseSession session,
    List<StockLevel> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StockLevel>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StockLevel] and returns the inserted row.
  ///
  /// The returned [StockLevel] will have its `id` field set.
  Future<StockLevel> insertRow(
    _isd.DatabaseSession session,
    StockLevel row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<StockLevel>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StockLevel]s in the list and returns the resulting rows.
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
  /// The returned [StockLevel]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockLevel>> upsert(
    _isd.DatabaseSession session,
    List<StockLevel> rows, {
    required _isd.ColumnSelections<StockLevelTable> conflictColumns,
    _isd.ColumnSelections<StockLevelTable>? updateColumns,
    _isd.WhereExpressionBuilder<StockLevelTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StockLevel>(
      rows,
      conflictColumns: conflictColumns(StockLevel.t),
      updateColumns: updateColumns?.call(StockLevel.t),
      updateWhere: updateWhere?.call(StockLevel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StockLevel] and returns the resulting row.
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
  /// The returned [StockLevel] will have its `id` field set.
  Future<StockLevel?> upsertRow(
    _isd.DatabaseSession session,
    StockLevel row, {
    required _isd.ColumnSelections<StockLevelTable> conflictColumns,
    _isd.ColumnSelections<StockLevelTable>? updateColumns,
    _isd.WhereExpressionBuilder<StockLevelTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StockLevel>(
      row,
      conflictColumns: conflictColumns(StockLevel.t),
      updateColumns: updateColumns?.call(StockLevel.t),
      updateWhere: updateWhere?.call(StockLevel.t),
      transaction: transaction,
    );
  }

  /// Updates all [StockLevel]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockLevel>> update(
    _isd.DatabaseSession session,
    List<StockLevel> rows, {
    _isd.ColumnSelections<StockLevelTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StockLevel>(
      rows,
      columns: columns?.call(StockLevel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StockLevel]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StockLevel> updateRow(
    _isd.DatabaseSession session,
    StockLevel row, {
    _isd.ColumnSelections<StockLevelTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<StockLevel>(
      row,
      columns: columns?.call(StockLevel.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StockLevel] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StockLevel?> updateById(
    _isd.DatabaseSession session,
    int id, {
    required _isd.ColumnValueListBuilder<StockLevelUpdateTable> columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<StockLevel>(
      id,
      columnValues: columnValues(StockLevel.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StockLevel]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockLevel>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<StockLevelUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<StockLevelTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StockLevelTable>? orderBy,
    _isd.OrderByListBuilder<StockLevelTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StockLevel>(
      columnValues: columnValues(StockLevel.t.updateTable),
      where: where(StockLevel.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StockLevel.t),
      orderByList: orderByList?.call(StockLevel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StockLevel]s in the list and returns the deleted rows.
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
  Future<List<StockLevel>> delete(
    _isd.DatabaseSession session,
    List<StockLevel> rows, {
    _isd.OrderByBuilder<StockLevelTable>? orderBy,
    _isd.OrderByListBuilder<StockLevelTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StockLevel>(
      rows,
      orderBy: orderBy?.call(StockLevel.t),
      orderByList: orderByList?.call(StockLevel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StockLevel].
  Future<StockLevel> deleteRow(
    _isd.DatabaseSession session,
    StockLevel row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StockLevel>(
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
  Future<List<StockLevel>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<StockLevelTable> where,
    _isd.OrderByBuilder<StockLevelTable>? orderBy,
    _isd.OrderByListBuilder<StockLevelTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StockLevel>(
      where: where(StockLevel.t),
      orderBy: orderBy?.call(StockLevel.t),
      orderByList: orderByList?.call(StockLevel.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StockLevelTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<StockLevel>(
      where: where?.call(StockLevel.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StockLevel] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<StockLevelTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StockLevel>(
      where: where(StockLevel.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
