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

/// Grup modifier menu F&B per tenant (F1-10b, 1.17b), mis. Ukuran, Topping.
/// Wajib dipilih = min_select ≥ 1; maks 1 = pilihan tunggal.
abstract class ModifierGroup
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  ModifierGroup._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.name,
    int? minSelect,
    int? maxSelect,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _is.Uuid().v7obj(),
       minSelect = minSelect ?? 0,
       maxSelect = maxSelect ?? 1,
       sortOrder = sortOrder ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory ModifierGroup({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required String name,
    int? minSelect,
    int? maxSelect,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _ModifierGroupImpl;

  factory ModifierGroup.fromJson(Map<String, dynamic> jsonSerialization) {
    return ModifierGroup(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      name: jsonSerialization['name'] as String,
      minSelect: jsonSerialization['minSelect'] as int?,
      maxSelect: jsonSerialization['maxSelect'] as int?,
      sortOrder: jsonSerialization['sortOrder'] as int?,
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

  static final t = ModifierGroupTable();

  static const db = ModifierGroupRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  String name;

  int minSelect;

  int maxSelect;

  int sortOrder;

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

  /// Returns a shallow copy of this [ModifierGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ModifierGroup copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    String? name,
    int? minSelect,
    int? maxSelect,
    int? sortOrder,
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
      '__className__': 'ModifierGroup',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'name': name,
      'minSelect': minSelect,
      'maxSelect': maxSelect,
      'sortOrder': sortOrder,
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
      '__className__': 'ModifierGroup',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'name': name,
      'minSelect': minSelect,
      'maxSelect': maxSelect,
      'sortOrder': sortOrder,
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

  static ModifierGroupInclude include() {
    return ModifierGroupInclude._();
  }

  static ModifierGroupIncludeList includeList({
    _is.WhereExpressionBuilder<ModifierGroupTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ModifierGroupTable>? orderBy,
    _is.OrderByListBuilder<ModifierGroupTable>? orderByList,
    ModifierGroupInclude? include,
  }) {
    return ModifierGroupIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ModifierGroup.t),
      orderByList: orderByList?.call(ModifierGroup.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _ModifierGroupImpl extends ModifierGroup {
  _ModifierGroupImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required String name,
    int? minSelect,
    int? maxSelect,
    int? sortOrder,
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
         minSelect: minSelect,
         maxSelect: maxSelect,
         sortOrder: sortOrder,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [ModifierGroup]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ModifierGroup copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    String? name,
    int? minSelect,
    int? maxSelect,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return ModifierGroup(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      minSelect: minSelect ?? this.minSelect,
      maxSelect: maxSelect ?? this.maxSelect,
      sortOrder: sortOrder ?? this.sortOrder,
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

class ModifierGroupUpdateTable extends _is.UpdateTable<ModifierGroupTable> {
  ModifierGroupUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<int, int> minSelect(int value) => _is.ColumnValue(
    table.minSelect,
    value,
  );

  _is.ColumnValue<int, int> maxSelect(int value) => _is.ColumnValue(
    table.maxSelect,
    value,
  );

  _is.ColumnValue<int, int> sortOrder(int value) => _is.ColumnValue(
    table.sortOrder,
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

class ModifierGroupTable extends _is.Table<_is.UuidValue> {
  ModifierGroupTable({super.tableRelation})
    : super(tableName: 'modifier_groups') {
    updateTable = ModifierGroupUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    minSelect = _is.ColumnInt(
      'min_select',
      this,
      hasDefault: true,
      fieldName: 'minSelect',
    );
    maxSelect = _is.ColumnInt(
      'max_select',
      this,
      hasDefault: true,
      fieldName: 'maxSelect',
    );
    sortOrder = _is.ColumnInt(
      'sort_order',
      this,
      hasDefault: true,
      fieldName: 'sortOrder',
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

  late final ModifierGroupUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnString name;

  late final _is.ColumnInt minSelect;

  late final _is.ColumnInt maxSelect;

  late final _is.ColumnInt sortOrder;

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
    minSelect,
    maxSelect,
    sortOrder,
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

class ModifierGroupInclude extends _is.IncludeObject {
  ModifierGroupInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => ModifierGroup.t;
}

class ModifierGroupIncludeList extends _is.IncludeList {
  ModifierGroupIncludeList._({
    _is.WhereExpressionBuilder<ModifierGroupTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ModifierGroup.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => ModifierGroup.t;
}

class ModifierGroupRepository {
  const ModifierGroupRepository._();

  /// Returns a list of [ModifierGroup]s matching the given query parameters.
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
  Future<List<ModifierGroup>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ModifierGroupTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ModifierGroupTable>? orderBy,
    _is.OrderByListBuilder<ModifierGroupTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ModifierGroup>(
      where: where?.call(ModifierGroup.t),
      orderBy: orderBy?.call(ModifierGroup.t),
      orderByList: orderByList?.call(ModifierGroup.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [ModifierGroup]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `ModifierGroup.t`.
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
  _ida.Stream<List<ModifierGroup>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ModifierGroupTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ModifierGroupTable>? orderBy,
    _is.OrderByListBuilder<ModifierGroupTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<ModifierGroup>(
      where: where?.call(ModifierGroup.t),
      orderBy: orderBy?.call(ModifierGroup.t),
      orderByList: orderByList?.call(ModifierGroup.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [ModifierGroup] matching the given query parameters.
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
  Future<ModifierGroup?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ModifierGroupTable>? where,
    int? offset,
    _is.OrderByBuilder<ModifierGroupTable>? orderBy,
    _is.OrderByListBuilder<ModifierGroupTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ModifierGroup>(
      where: where?.call(ModifierGroup.t),
      orderBy: orderBy?.call(ModifierGroup.t),
      orderByList: orderByList?.call(ModifierGroup.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ModifierGroup] by its [id] or null if no such row exists.
  Future<ModifierGroup?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ModifierGroup>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ModifierGroup]s in the list and returns the inserted rows.
  ///
  /// The returned [ModifierGroup]s will have their `id` fields set.
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
  Future<List<ModifierGroup>> insert(
    _is.DatabaseSession session,
    List<ModifierGroup> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ModifierGroup>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ModifierGroup] and returns the inserted row.
  ///
  /// The returned [ModifierGroup] will have its `id` field set.
  Future<ModifierGroup> insertRow(
    _is.DatabaseSession session,
    ModifierGroup row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ModifierGroup>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ModifierGroup]s in the list and returns the resulting rows.
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
  /// The returned [ModifierGroup]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ModifierGroup>> upsert(
    _is.DatabaseSession session,
    List<ModifierGroup> rows, {
    required _is.ColumnSelections<ModifierGroupTable> conflictColumns,
    _is.ColumnSelections<ModifierGroupTable>? updateColumns,
    _is.WhereExpressionBuilder<ModifierGroupTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ModifierGroup>(
      rows,
      conflictColumns: conflictColumns(ModifierGroup.t),
      updateColumns: updateColumns?.call(ModifierGroup.t),
      updateWhere: updateWhere?.call(ModifierGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ModifierGroup] and returns the resulting row.
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
  /// The returned [ModifierGroup] will have its `id` field set.
  Future<ModifierGroup?> upsertRow(
    _is.DatabaseSession session,
    ModifierGroup row, {
    required _is.ColumnSelections<ModifierGroupTable> conflictColumns,
    _is.ColumnSelections<ModifierGroupTable>? updateColumns,
    _is.WhereExpressionBuilder<ModifierGroupTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ModifierGroup>(
      row,
      conflictColumns: conflictColumns(ModifierGroup.t),
      updateColumns: updateColumns?.call(ModifierGroup.t),
      updateWhere: updateWhere?.call(ModifierGroup.t),
      transaction: transaction,
    );
  }

  /// Updates all [ModifierGroup]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ModifierGroup>> update(
    _is.DatabaseSession session,
    List<ModifierGroup> rows, {
    _is.ColumnSelections<ModifierGroupTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ModifierGroup>(
      rows,
      columns: columns?.call(ModifierGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ModifierGroup]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ModifierGroup> updateRow(
    _is.DatabaseSession session,
    ModifierGroup row, {
    _is.ColumnSelections<ModifierGroupTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ModifierGroup>(
      row,
      columns: columns?.call(ModifierGroup.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ModifierGroup] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ModifierGroup?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<ModifierGroupUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ModifierGroup>(
      id,
      columnValues: columnValues(ModifierGroup.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ModifierGroup]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ModifierGroup>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ModifierGroupUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ModifierGroupTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ModifierGroupTable>? orderBy,
    _is.OrderByListBuilder<ModifierGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ModifierGroup>(
      columnValues: columnValues(ModifierGroup.t.updateTable),
      where: where(ModifierGroup.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ModifierGroup.t),
      orderByList: orderByList?.call(ModifierGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ModifierGroup]s in the list and returns the deleted rows.
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
  Future<List<ModifierGroup>> delete(
    _is.DatabaseSession session,
    List<ModifierGroup> rows, {
    _is.OrderByBuilder<ModifierGroupTable>? orderBy,
    _is.OrderByListBuilder<ModifierGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ModifierGroup>(
      rows,
      orderBy: orderBy?.call(ModifierGroup.t),
      orderByList: orderByList?.call(ModifierGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ModifierGroup].
  Future<ModifierGroup> deleteRow(
    _is.DatabaseSession session,
    ModifierGroup row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ModifierGroup>(
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
  Future<List<ModifierGroup>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ModifierGroupTable> where,
    _is.OrderByBuilder<ModifierGroupTable>? orderBy,
    _is.OrderByListBuilder<ModifierGroupTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ModifierGroup>(
      where: where(ModifierGroup.t),
      orderBy: orderBy?.call(ModifierGroup.t),
      orderByList: orderByList?.call(ModifierGroup.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ModifierGroupTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ModifierGroup>(
      where: where?.call(ModifierGroup.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ModifierGroup] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ModifierGroupTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ModifierGroup>(
      where: where(ModifierGroup.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
