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

/// Grup pelanggan (F1-13), mis. *Grosir*. Nama unik per tenant tanpa
/// membedakan huruf besar/kecil (dicek di lakuna_data). [termDays] = tempo
/// standar kredit di Kasir.
abstract class CustomerGroup
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  CustomerGroup._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.name,
    int? termDays,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _is.Uuid().v7obj(),
       termDays = termDays ?? 14,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory CustomerGroup({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required String name,
    int? termDays,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _CustomerGroupImpl;

  factory CustomerGroup.fromJson(Map<String, dynamic> jsonSerialization) {
    return CustomerGroup(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      name: jsonSerialization['name'] as String,
      termDays: jsonSerialization['termDays'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      createdBy: jsonSerialization['createdBy'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['createdBy']),
      updatedBy: jsonSerialization['updatedBy'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['updatedBy']),
      version: jsonSerialization['version'] as int?,
      hlc: jsonSerialization['hlc'] as String,
      originDeviceId: jsonSerialization['originDeviceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['originDeviceId'],
            ),
    );
  }

  static final t = CustomerGroupTable();

  static const db = CustomerGroupRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  String name;

  int termDays;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? deletedAt;

  _is.UuidValue? createdBy;

  _is.UuidValue? updatedBy;

  int version;

  String hlc;

  _is.UuidValue? originDeviceId;

  @override
  _is.Table<_is.UuidValue> get table => t;

  /// Returns a shallow copy of this [CustomerGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CustomerGroup copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    String? name,
    int? termDays,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustomerGroup',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'name': name,
      'termDays': termDays,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (createdBy != null) 'createdBy': createdBy?.toJson(),
      if (updatedBy != null) 'updatedBy': updatedBy?.toJson(),
      'version': version,
      'hlc': hlc,
      if (originDeviceId != null) 'originDeviceId': originDeviceId?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CustomerGroup',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'name': name,
      'termDays': termDays,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      if (createdBy != null) 'createdBy': createdBy?.toJson(),
      if (updatedBy != null) 'updatedBy': updatedBy?.toJson(),
      'version': version,
      'hlc': hlc,
      if (originDeviceId != null) 'originDeviceId': originDeviceId?.toJson(),
    };
  }

  static CustomerGroupInclude include() {
    return CustomerGroupInclude._();
  }

  static CustomerGroupIncludeList includeList({
    _is.WhereExpressionBuilder<CustomerGroupTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerGroupTable>? orderBy,
    _is.OrderByListBuilder<CustomerGroupTable>? orderByList,
    CustomerGroupInclude? include,
  }) {
    return CustomerGroupIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomerGroup.t),
      orderByList: orderByList?.call(CustomerGroup.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CustomerGroupImpl extends CustomerGroup {
  _CustomerGroupImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required String name,
    int? termDays,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) : super._(
         id: id,
         tenantId: tenantId,
         name: name,
         termDays: termDays,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [CustomerGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CustomerGroup copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    String? name,
    int? termDays,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return CustomerGroup(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      termDays: termDays ?? this.termDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt is _is.UndefinedSentinel
          ? this.deletedAt
          : deletedAt,
      createdBy: createdBy is _is.UndefinedSentinel
          ? this.createdBy
          : createdBy,
      updatedBy: updatedBy is _is.UndefinedSentinel
          ? this.updatedBy
          : updatedBy,
      version: version ?? this.version,
      hlc: hlc ?? this.hlc,
      originDeviceId: originDeviceId is _is.UndefinedSentinel
          ? this.originDeviceId
          : originDeviceId,
    );
  }
}

class CustomerGroupUpdateTable extends _is.UpdateTable<CustomerGroupTable> {
  CustomerGroupUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<int, int> termDays(int value) => _is.ColumnValue(
    table.termDays,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _is.ColumnValue(
        table.deletedAt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> createdBy(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.createdBy,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> updatedBy(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.updatedBy,
    value,
  );

  _is.ColumnValue<int, int> version(int value) => _is.ColumnValue(
    table.version,
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
}

class CustomerGroupTable extends _is.Table<_is.UuidValue> {
  CustomerGroupTable({super.tableRelation})
    : super(tableName: 'customer_groups') {
    updateTable = CustomerGroupUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    termDays = _is.ColumnInt(
      'term_days',
      this,
      hasDefault: true,
      fieldName: 'termDays',
    );
    createdAt = _is.ColumnDateTime(
      'created_at',
      this,
      hasDefault: true,
      fieldName: 'createdAt',
    );
    updatedAt = _is.ColumnDateTime(
      'updated_at',
      this,
      hasDefault: true,
      fieldName: 'updatedAt',
    );
    deletedAt = _is.ColumnDateTime(
      'deleted_at',
      this,
      fieldName: 'deletedAt',
    );
    createdBy = _is.ColumnUuid(
      'created_by',
      this,
      fieldName: 'createdBy',
    );
    updatedBy = _is.ColumnUuid(
      'updated_by',
      this,
      fieldName: 'updatedBy',
    );
    version = _is.ColumnInt(
      'version',
      this,
      hasDefault: true,
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
  }

  late final CustomerGroupUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnString name;

  late final _is.ColumnInt termDays;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnDateTime deletedAt;

  late final _is.ColumnUuid createdBy;

  late final _is.ColumnUuid updatedBy;

  late final _is.ColumnInt version;

  late final _is.ColumnString hlc;

  late final _is.ColumnUuid originDeviceId;

  @override
  List<_is.Column> get columns => [
    id,
    tenantId,
    name,
    termDays,
    createdAt,
    updatedAt,
    deletedAt,
    createdBy,
    updatedBy,
    version,
    hlc,
    originDeviceId,
  ];
}

class CustomerGroupInclude extends _is.IncludeObject {
  CustomerGroupInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => CustomerGroup.t;
}

class CustomerGroupIncludeList extends _is.IncludeList {
  CustomerGroupIncludeList._({
    _is.WhereExpressionBuilder<CustomerGroupTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CustomerGroup.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => CustomerGroup.t;
}

class CustomerGroupRepository {
  const CustomerGroupRepository._();

  /// Returns a list of [CustomerGroup]s matching the given query parameters.
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
  Future<List<CustomerGroup>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerGroupTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerGroupTable>? orderBy,
    _is.OrderByListBuilder<CustomerGroupTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CustomerGroup>(
      where: where?.call(CustomerGroup.t),
      orderBy: orderBy?.call(CustomerGroup.t),
      orderByList: orderByList?.call(CustomerGroup.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CustomerGroup]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CustomerGroup.t`.
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
  _ida.Stream<List<CustomerGroup>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerGroupTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerGroupTable>? orderBy,
    _is.OrderByListBuilder<CustomerGroupTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CustomerGroup>(
      where: where?.call(CustomerGroup.t),
      orderBy: orderBy?.call(CustomerGroup.t),
      orderByList: orderByList?.call(CustomerGroup.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CustomerGroup] matching the given query parameters.
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
  Future<CustomerGroup?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerGroupTable>? where,
    int? offset,
    _is.OrderByBuilder<CustomerGroupTable>? orderBy,
    _is.OrderByListBuilder<CustomerGroupTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CustomerGroup>(
      where: where?.call(CustomerGroup.t),
      orderBy: orderBy?.call(CustomerGroup.t),
      orderByList: orderByList?.call(CustomerGroup.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CustomerGroup] by its [id] or null if no such row exists.
  Future<CustomerGroup?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CustomerGroup>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CustomerGroup]s in the list and returns the inserted rows.
  ///
  /// The returned [CustomerGroup]s will have their `id` fields set.
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
  Future<List<CustomerGroup>> insert(
    _is.DatabaseSession session,
    List<CustomerGroup> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CustomerGroup>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CustomerGroup] and returns the inserted row.
  ///
  /// The returned [CustomerGroup] will have its `id` field set.
  Future<CustomerGroup> insertRow(
    _is.DatabaseSession session,
    CustomerGroup row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CustomerGroup>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CustomerGroup]s in the list and returns the resulting rows.
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
  /// The returned [CustomerGroup]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerGroup>> upsert(
    _is.DatabaseSession session,
    List<CustomerGroup> rows, {
    required _is.ColumnSelections<CustomerGroupTable> conflictColumns,
    _is.ColumnSelections<CustomerGroupTable>? updateColumns,
    _is.WhereExpressionBuilder<CustomerGroupTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CustomerGroup>(
      rows,
      conflictColumns: conflictColumns(CustomerGroup.t),
      updateColumns: updateColumns?.call(CustomerGroup.t),
      updateWhere: updateWhere?.call(CustomerGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CustomerGroup] and returns the resulting row.
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
  /// The returned [CustomerGroup] will have its `id` field set.
  Future<CustomerGroup?> upsertRow(
    _is.DatabaseSession session,
    CustomerGroup row, {
    required _is.ColumnSelections<CustomerGroupTable> conflictColumns,
    _is.ColumnSelections<CustomerGroupTable>? updateColumns,
    _is.WhereExpressionBuilder<CustomerGroupTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CustomerGroup>(
      row,
      conflictColumns: conflictColumns(CustomerGroup.t),
      updateColumns: updateColumns?.call(CustomerGroup.t),
      updateWhere: updateWhere?.call(CustomerGroup.t),
      transaction: transaction,
    );
  }

  /// Updates all [CustomerGroup]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerGroup>> update(
    _is.DatabaseSession session,
    List<CustomerGroup> rows, {
    _is.ColumnSelections<CustomerGroupTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CustomerGroup>(
      rows,
      columns: columns?.call(CustomerGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CustomerGroup]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CustomerGroup> updateRow(
    _is.DatabaseSession session,
    CustomerGroup row, {
    _is.ColumnSelections<CustomerGroupTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CustomerGroup>(
      row,
      columns: columns?.call(CustomerGroup.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CustomerGroup] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CustomerGroup?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CustomerGroupUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CustomerGroup>(
      id,
      columnValues: columnValues(CustomerGroup.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CustomerGroup]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CustomerGroup>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CustomerGroupUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CustomerGroupTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CustomerGroupTable>? orderBy,
    _is.OrderByListBuilder<CustomerGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CustomerGroup>(
      columnValues: columnValues(CustomerGroup.t.updateTable),
      where: where(CustomerGroup.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CustomerGroup.t),
      orderByList: orderByList?.call(CustomerGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CustomerGroup]s in the list and returns the deleted rows.
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
  Future<List<CustomerGroup>> delete(
    _is.DatabaseSession session,
    List<CustomerGroup> rows, {
    _is.OrderByBuilder<CustomerGroupTable>? orderBy,
    _is.OrderByListBuilder<CustomerGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CustomerGroup>(
      rows,
      orderBy: orderBy?.call(CustomerGroup.t),
      orderByList: orderByList?.call(CustomerGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CustomerGroup].
  Future<CustomerGroup> deleteRow(
    _is.DatabaseSession session,
    CustomerGroup row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CustomerGroup>(
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
  Future<List<CustomerGroup>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CustomerGroupTable> where,
    _is.OrderByBuilder<CustomerGroupTable>? orderBy,
    _is.OrderByListBuilder<CustomerGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CustomerGroup>(
      where: where(CustomerGroup.t),
      orderBy: orderBy?.call(CustomerGroup.t),
      orderByList: orderByList?.call(CustomerGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CustomerGroupTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CustomerGroup>(
      where: where?.call(CustomerGroup.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CustomerGroup] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CustomerGroupTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CustomerGroup>(
      where: where(CustomerGroup.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
