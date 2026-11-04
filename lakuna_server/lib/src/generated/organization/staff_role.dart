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

/// Role staf yang izinnya diatur di matriks 1.25 (F1-17). Role bawaan baru
/// disimpan saat izinnya diubah pertama kali; role `owner` tidak pernah
/// disimpan. `permissionKeys` = kunci `resource:action` dipisah koma.
abstract class StaffRole
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  StaffRole._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.roleKey,
    required this.name,
    required this.permissionKeys,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _is.Uuid().v7obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory StaffRole({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required String roleKey,
    required String name,
    required String permissionKeys,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _StaffRoleImpl;

  factory StaffRole.fromJson(Map<String, dynamic> jsonSerialization) {
    return StaffRole(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      roleKey: jsonSerialization['roleKey'] as String,
      name: jsonSerialization['name'] as String,
      permissionKeys: jsonSerialization['permissionKeys'] as String,
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

  static final t = StaffRoleTable();

  static const db = StaffRoleRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  String roleKey;

  String name;

  String permissionKeys;

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

  /// Returns a shallow copy of this [StaffRole]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StaffRole copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    String? roleKey,
    String? name,
    String? permissionKeys,
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
      '__className__': 'StaffRole',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'roleKey': roleKey,
      'name': name,
      'permissionKeys': permissionKeys,
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
      '__className__': 'StaffRole',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'roleKey': roleKey,
      'name': name,
      'permissionKeys': permissionKeys,
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

  static StaffRoleInclude include() {
    return StaffRoleInclude._();
  }

  static StaffRoleIncludeList includeList({
    _is.WhereExpressionBuilder<StaffRoleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StaffRoleTable>? orderBy,
    _is.OrderByListBuilder<StaffRoleTable>? orderByList,
    StaffRoleInclude? include,
  }) {
    return StaffRoleIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StaffRole.t),
      orderByList: orderByList?.call(StaffRole.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _StaffRoleImpl extends StaffRole {
  _StaffRoleImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required String roleKey,
    required String name,
    required String permissionKeys,
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
         roleKey: roleKey,
         name: name,
         permissionKeys: permissionKeys,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [StaffRole]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StaffRole copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    String? roleKey,
    String? name,
    String? permissionKeys,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return StaffRole(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      roleKey: roleKey ?? this.roleKey,
      name: name ?? this.name,
      permissionKeys: permissionKeys ?? this.permissionKeys,
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

class StaffRoleUpdateTable extends _is.UpdateTable<StaffRoleTable> {
  StaffRoleUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<String, String> roleKey(String value) => _is.ColumnValue(
    table.roleKey,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> permissionKeys(String value) =>
      _is.ColumnValue(
        table.permissionKeys,
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

class StaffRoleTable extends _is.Table<_is.UuidValue> {
  StaffRoleTable({super.tableRelation}) : super(tableName: 'roles') {
    updateTable = StaffRoleUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    roleKey = _is.ColumnString(
      'role_key',
      this,
      fieldName: 'roleKey',
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    permissionKeys = _is.ColumnString(
      'permission_keys',
      this,
      fieldName: 'permissionKeys',
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

  late final StaffRoleUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnString roleKey;

  late final _is.ColumnString name;

  late final _is.ColumnString permissionKeys;

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
    roleKey,
    name,
    permissionKeys,
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

class StaffRoleInclude extends _is.IncludeObject {
  StaffRoleInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => StaffRole.t;
}

class StaffRoleIncludeList extends _is.IncludeList {
  StaffRoleIncludeList._({
    _is.WhereExpressionBuilder<StaffRoleTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StaffRole.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => StaffRole.t;
}

class StaffRoleRepository {
  const StaffRoleRepository._();

  /// Returns a list of [StaffRole]s matching the given query parameters.
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
  Future<List<StaffRole>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StaffRoleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StaffRoleTable>? orderBy,
    _is.OrderByListBuilder<StaffRoleTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StaffRole>(
      where: where?.call(StaffRole.t),
      orderBy: orderBy?.call(StaffRole.t),
      orderByList: orderByList?.call(StaffRole.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [StaffRole]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `StaffRole.t`.
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
  _ida.Stream<List<StaffRole>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StaffRoleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StaffRoleTable>? orderBy,
    _is.OrderByListBuilder<StaffRoleTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<StaffRole>(
      where: where?.call(StaffRole.t),
      orderBy: orderBy?.call(StaffRole.t),
      orderByList: orderByList?.call(StaffRole.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [StaffRole] matching the given query parameters.
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
  Future<StaffRole?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StaffRoleTable>? where,
    int? offset,
    _is.OrderByBuilder<StaffRoleTable>? orderBy,
    _is.OrderByListBuilder<StaffRoleTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StaffRole>(
      where: where?.call(StaffRole.t),
      orderBy: orderBy?.call(StaffRole.t),
      orderByList: orderByList?.call(StaffRole.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StaffRole] by its [id] or null if no such row exists.
  Future<StaffRole?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StaffRole>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StaffRole]s in the list and returns the inserted rows.
  ///
  /// The returned [StaffRole]s will have their `id` fields set.
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
  Future<List<StaffRole>> insert(
    _is.DatabaseSession session,
    List<StaffRole> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StaffRole>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StaffRole] and returns the inserted row.
  ///
  /// The returned [StaffRole] will have its `id` field set.
  Future<StaffRole> insertRow(
    _is.DatabaseSession session,
    StaffRole row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StaffRole>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StaffRole]s in the list and returns the resulting rows.
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
  /// The returned [StaffRole]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StaffRole>> upsert(
    _is.DatabaseSession session,
    List<StaffRole> rows, {
    required _is.ColumnSelections<StaffRoleTable> conflictColumns,
    _is.ColumnSelections<StaffRoleTable>? updateColumns,
    _is.WhereExpressionBuilder<StaffRoleTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StaffRole>(
      rows,
      conflictColumns: conflictColumns(StaffRole.t),
      updateColumns: updateColumns?.call(StaffRole.t),
      updateWhere: updateWhere?.call(StaffRole.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StaffRole] and returns the resulting row.
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
  /// The returned [StaffRole] will have its `id` field set.
  Future<StaffRole?> upsertRow(
    _is.DatabaseSession session,
    StaffRole row, {
    required _is.ColumnSelections<StaffRoleTable> conflictColumns,
    _is.ColumnSelections<StaffRoleTable>? updateColumns,
    _is.WhereExpressionBuilder<StaffRoleTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StaffRole>(
      row,
      conflictColumns: conflictColumns(StaffRole.t),
      updateColumns: updateColumns?.call(StaffRole.t),
      updateWhere: updateWhere?.call(StaffRole.t),
      transaction: transaction,
    );
  }

  /// Updates all [StaffRole]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StaffRole>> update(
    _is.DatabaseSession session,
    List<StaffRole> rows, {
    _is.ColumnSelections<StaffRoleTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StaffRole>(
      rows,
      columns: columns?.call(StaffRole.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StaffRole]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StaffRole> updateRow(
    _is.DatabaseSession session,
    StaffRole row, {
    _is.ColumnSelections<StaffRoleTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StaffRole>(
      row,
      columns: columns?.call(StaffRole.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StaffRole] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StaffRole?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<StaffRoleUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StaffRole>(
      id,
      columnValues: columnValues(StaffRole.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StaffRole]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StaffRole>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StaffRoleUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StaffRoleTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StaffRoleTable>? orderBy,
    _is.OrderByListBuilder<StaffRoleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StaffRole>(
      columnValues: columnValues(StaffRole.t.updateTable),
      where: where(StaffRole.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StaffRole.t),
      orderByList: orderByList?.call(StaffRole.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StaffRole]s in the list and returns the deleted rows.
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
  Future<List<StaffRole>> delete(
    _is.DatabaseSession session,
    List<StaffRole> rows, {
    _is.OrderByBuilder<StaffRoleTable>? orderBy,
    _is.OrderByListBuilder<StaffRoleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StaffRole>(
      rows,
      orderBy: orderBy?.call(StaffRole.t),
      orderByList: orderByList?.call(StaffRole.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StaffRole].
  Future<StaffRole> deleteRow(
    _is.DatabaseSession session,
    StaffRole row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StaffRole>(
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
  Future<List<StaffRole>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StaffRoleTable> where,
    _is.OrderByBuilder<StaffRoleTable>? orderBy,
    _is.OrderByListBuilder<StaffRoleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StaffRole>(
      where: where(StaffRole.t),
      orderBy: orderBy?.call(StaffRole.t),
      orderByList: orderByList?.call(StaffRole.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StaffRoleTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StaffRole>(
      where: where?.call(StaffRole.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StaffRole] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StaffRoleTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StaffRole>(
      where: where(StaffRole.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
