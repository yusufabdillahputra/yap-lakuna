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

/// Akses staf ke outlet beserta role-nya (kunci role, mis. `cashier`).
abstract class OutletMember
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  OutletMember._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.outletId,
    required this.staffMemberId,
    required this.roleName,
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

  factory OutletMember({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue staffMemberId,
    required String roleName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _OutletMemberImpl;

  factory OutletMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return OutletMember(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      staffMemberId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['staffMemberId'],
      ),
      roleName: jsonSerialization['roleName'] as String,
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

  static final t = OutletMemberTable();

  static const db = OutletMemberRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue outletId;

  _is.UuidValue staffMemberId;

  String roleName;

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

  /// Returns a shallow copy of this [OutletMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  OutletMember copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? staffMemberId,
    String? roleName,
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
      '__className__': 'OutletMember',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'staffMemberId': staffMemberId.toJson(),
      'roleName': roleName,
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
      '__className__': 'OutletMember',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'staffMemberId': staffMemberId.toJson(),
      'roleName': roleName,
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

  static OutletMemberInclude include() {
    return OutletMemberInclude._();
  }

  static OutletMemberIncludeList includeList({
    _is.WhereExpressionBuilder<OutletMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OutletMemberTable>? orderBy,
    _is.OrderByListBuilder<OutletMemberTable>? orderByList,
    OutletMemberInclude? include,
  }) {
    return OutletMemberIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OutletMember.t),
      orderByList: orderByList?.call(OutletMember.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _OutletMemberImpl extends OutletMember {
  _OutletMemberImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue staffMemberId,
    required String roleName,
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
         outletId: outletId,
         staffMemberId: staffMemberId,
         roleName: roleName,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [OutletMember]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  OutletMember copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? staffMemberId,
    String? roleName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return OutletMember(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      staffMemberId: staffMemberId ?? this.staffMemberId,
      roleName: roleName ?? this.roleName,
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

class OutletMemberUpdateTable extends _is.UpdateTable<OutletMemberTable> {
  OutletMemberUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> outletId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.outletId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> staffMemberId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.staffMemberId,
    value,
  );

  _is.ColumnValue<String, String> roleName(String value) => _is.ColumnValue(
    table.roleName,
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

class OutletMemberTable extends _is.Table<_is.UuidValue> {
  OutletMemberTable({super.tableRelation})
    : super(tableName: 'outlet_members') {
    updateTable = OutletMemberUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    outletId = _is.ColumnUuid(
      'outlet_id',
      this,
      fieldName: 'outletId',
    );
    staffMemberId = _is.ColumnUuid(
      'staff_member_id',
      this,
      fieldName: 'staffMemberId',
    );
    roleName = _is.ColumnString(
      'role_name',
      this,
      fieldName: 'roleName',
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

  late final OutletMemberUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid outletId;

  late final _is.ColumnUuid staffMemberId;

  late final _is.ColumnString roleName;

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
    outletId,
    staffMemberId,
    roleName,
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

class OutletMemberInclude extends _is.IncludeObject {
  OutletMemberInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => OutletMember.t;
}

class OutletMemberIncludeList extends _is.IncludeList {
  OutletMemberIncludeList._({
    _is.WhereExpressionBuilder<OutletMemberTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OutletMember.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => OutletMember.t;
}

class OutletMemberRepository {
  const OutletMemberRepository._();

  /// Returns a list of [OutletMember]s matching the given query parameters.
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
  Future<List<OutletMember>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OutletMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OutletMemberTable>? orderBy,
    _is.OrderByListBuilder<OutletMemberTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<OutletMember>(
      where: where?.call(OutletMember.t),
      orderBy: orderBy?.call(OutletMember.t),
      orderByList: orderByList?.call(OutletMember.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [OutletMember]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `OutletMember.t`.
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
  _ida.Stream<List<OutletMember>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OutletMemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OutletMemberTable>? orderBy,
    _is.OrderByListBuilder<OutletMemberTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<OutletMember>(
      where: where?.call(OutletMember.t),
      orderBy: orderBy?.call(OutletMember.t),
      orderByList: orderByList?.call(OutletMember.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [OutletMember] matching the given query parameters.
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
  Future<OutletMember?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OutletMemberTable>? where,
    int? offset,
    _is.OrderByBuilder<OutletMemberTable>? orderBy,
    _is.OrderByListBuilder<OutletMemberTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<OutletMember>(
      where: where?.call(OutletMember.t),
      orderBy: orderBy?.call(OutletMember.t),
      orderByList: orderByList?.call(OutletMember.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [OutletMember] by its [id] or null if no such row exists.
  Future<OutletMember?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<OutletMember>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [OutletMember]s in the list and returns the inserted rows.
  ///
  /// The returned [OutletMember]s will have their `id` fields set.
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
  Future<List<OutletMember>> insert(
    _is.DatabaseSession session,
    List<OutletMember> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<OutletMember>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [OutletMember] and returns the inserted row.
  ///
  /// The returned [OutletMember] will have its `id` field set.
  Future<OutletMember> insertRow(
    _is.DatabaseSession session,
    OutletMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<OutletMember>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [OutletMember]s in the list and returns the resulting rows.
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
  /// The returned [OutletMember]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OutletMember>> upsert(
    _is.DatabaseSession session,
    List<OutletMember> rows, {
    required _is.ColumnSelections<OutletMemberTable> conflictColumns,
    _is.ColumnSelections<OutletMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<OutletMemberTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<OutletMember>(
      rows,
      conflictColumns: conflictColumns(OutletMember.t),
      updateColumns: updateColumns?.call(OutletMember.t),
      updateWhere: updateWhere?.call(OutletMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [OutletMember] and returns the resulting row.
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
  /// The returned [OutletMember] will have its `id` field set.
  Future<OutletMember?> upsertRow(
    _is.DatabaseSession session,
    OutletMember row, {
    required _is.ColumnSelections<OutletMemberTable> conflictColumns,
    _is.ColumnSelections<OutletMemberTable>? updateColumns,
    _is.WhereExpressionBuilder<OutletMemberTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<OutletMember>(
      row,
      conflictColumns: conflictColumns(OutletMember.t),
      updateColumns: updateColumns?.call(OutletMember.t),
      updateWhere: updateWhere?.call(OutletMember.t),
      transaction: transaction,
    );
  }

  /// Updates all [OutletMember]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OutletMember>> update(
    _is.DatabaseSession session,
    List<OutletMember> rows, {
    _is.ColumnSelections<OutletMemberTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<OutletMember>(
      rows,
      columns: columns?.call(OutletMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [OutletMember]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OutletMember> updateRow(
    _is.DatabaseSession session,
    OutletMember row, {
    _is.ColumnSelections<OutletMemberTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<OutletMember>(
      row,
      columns: columns?.call(OutletMember.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OutletMember] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<OutletMember?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<OutletMemberUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<OutletMember>(
      id,
      columnValues: columnValues(OutletMember.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [OutletMember]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<OutletMember>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<OutletMemberUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<OutletMemberTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OutletMemberTable>? orderBy,
    _is.OrderByListBuilder<OutletMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<OutletMember>(
      columnValues: columnValues(OutletMember.t.updateTable),
      where: where(OutletMember.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OutletMember.t),
      orderByList: orderByList?.call(OutletMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [OutletMember]s in the list and returns the deleted rows.
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
  Future<List<OutletMember>> delete(
    _is.DatabaseSession session,
    List<OutletMember> rows, {
    _is.OrderByBuilder<OutletMemberTable>? orderBy,
    _is.OrderByListBuilder<OutletMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<OutletMember>(
      rows,
      orderBy: orderBy?.call(OutletMember.t),
      orderByList: orderByList?.call(OutletMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [OutletMember].
  Future<OutletMember> deleteRow(
    _is.DatabaseSession session,
    OutletMember row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OutletMember>(
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
  Future<List<OutletMember>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OutletMemberTable> where,
    _is.OrderByBuilder<OutletMemberTable>? orderBy,
    _is.OrderByListBuilder<OutletMemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<OutletMember>(
      where: where(OutletMember.t),
      orderBy: orderBy?.call(OutletMember.t),
      orderByList: orderByList?.call(OutletMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OutletMemberTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<OutletMember>(
      where: where?.call(OutletMember.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [OutletMember] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OutletMemberTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<OutletMember>(
      where: where(OutletMember.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
