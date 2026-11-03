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
import '../organization/business_type.dart' as _i5c3mqpw;
import '../organization/tenant_plan.dart' as _iru4za6a;

/// Usaha (tenant). Semua data bisnis dibatasi tenant_id.
abstract class Tenant
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  Tenant._({
    _is.UuidValue? id,
    required this.name,
    _i5c3mqpw.BusinessType? businessType,
    _iru4za6a.TenantPlan? plan,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _is.Uuid().v7obj(),
       businessType = businessType ?? _i5c3mqpw.BusinessType.retail,
       plan = plan ?? _iru4za6a.TenantPlan.free,
       timezone = timezone ?? 'Asia/Jakarta',
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory Tenant({
    _is.UuidValue? id,
    required String name,
    _i5c3mqpw.BusinessType? businessType,
    _iru4za6a.TenantPlan? plan,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _TenantImpl;

  factory Tenant.fromJson(Map<String, dynamic> jsonSerialization) {
    return Tenant(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      businessType: jsonSerialization['businessType'] == null
          ? null
          : _i5c3mqpw.BusinessType.fromJson(
              (jsonSerialization['businessType'] as String),
            ),
      plan: jsonSerialization['plan'] == null
          ? null
          : _iru4za6a.TenantPlan.fromJson(
              (jsonSerialization['plan'] as String),
            ),
      timezone: jsonSerialization['timezone'] as String?,
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

  static final t = TenantTable();

  static const db = TenantRepository._();

  @override
  _is.UuidValue id;

  String name;

  _i5c3mqpw.BusinessType businessType;

  _iru4za6a.TenantPlan plan;

  String timezone;

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

  /// Returns a shallow copy of this [Tenant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Tenant copyWith({
    _is.UuidValue? id,
    String? name,
    _i5c3mqpw.BusinessType? businessType,
    _iru4za6a.TenantPlan? plan,
    String? timezone,
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
      '__className__': 'Tenant',
      'id': id.toJson(),
      'name': name,
      'businessType': businessType.toJson(),
      'plan': plan.toJson(),
      'timezone': timezone,
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
      '__className__': 'Tenant',
      'id': id.toJson(),
      'name': name,
      'businessType': businessType.toJson(),
      'plan': plan.toJson(),
      'timezone': timezone,
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

  static TenantInclude include() {
    return TenantInclude._();
  }

  static TenantIncludeList includeList({
    _is.WhereExpressionBuilder<TenantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TenantTable>? orderBy,
    _is.OrderByListBuilder<TenantTable>? orderByList,
    TenantInclude? include,
  }) {
    return TenantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Tenant.t),
      orderByList: orderByList?.call(Tenant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TenantImpl extends Tenant {
  _TenantImpl({
    _is.UuidValue? id,
    required String name,
    _i5c3mqpw.BusinessType? businessType,
    _iru4za6a.TenantPlan? plan,
    String? timezone,
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
         name: name,
         businessType: businessType,
         plan: plan,
         timezone: timezone,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [Tenant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Tenant copyWith({
    _is.UuidValue? id,
    String? name,
    _i5c3mqpw.BusinessType? businessType,
    _iru4za6a.TenantPlan? plan,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      businessType: businessType ?? this.businessType,
      plan: plan ?? this.plan,
      timezone: timezone ?? this.timezone,
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

class TenantUpdateTable extends _is.UpdateTable<TenantTable> {
  TenantUpdateTable(super.table);

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<_i5c3mqpw.BusinessType, _i5c3mqpw.BusinessType> businessType(
    _i5c3mqpw.BusinessType value,
  ) => _is.ColumnValue(
    table.businessType,
    value,
  );

  _is.ColumnValue<_iru4za6a.TenantPlan, _iru4za6a.TenantPlan> plan(
    _iru4za6a.TenantPlan value,
  ) => _is.ColumnValue(
    table.plan,
    value,
  );

  _is.ColumnValue<String, String> timezone(String value) => _is.ColumnValue(
    table.timezone,
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

class TenantTable extends _is.Table<_is.UuidValue> {
  TenantTable({super.tableRelation}) : super(tableName: 'tenants') {
    updateTable = TenantUpdateTable(this);
    name = _is.ColumnString(
      'name',
      this,
    );
    businessType = _is.ColumnEnum(
      'business_type',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
      fieldName: 'businessType',
    );
    plan = _is.ColumnEnum(
      'plan',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    timezone = _is.ColumnString(
      'timezone',
      this,
      hasDefault: true,
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

  late final TenantUpdateTable updateTable;

  late final _is.ColumnString name;

  late final _is.ColumnEnum<_i5c3mqpw.BusinessType> businessType;

  late final _is.ColumnEnum<_iru4za6a.TenantPlan> plan;

  late final _is.ColumnString timezone;

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
    name,
    businessType,
    plan,
    timezone,
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

class TenantInclude extends _is.IncludeObject {
  TenantInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => Tenant.t;
}

class TenantIncludeList extends _is.IncludeList {
  TenantIncludeList._({
    _is.WhereExpressionBuilder<TenantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Tenant.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => Tenant.t;
}

class TenantRepository {
  const TenantRepository._();

  /// Returns a list of [Tenant]s matching the given query parameters.
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
  Future<List<Tenant>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TenantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TenantTable>? orderBy,
    _is.OrderByListBuilder<TenantTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Tenant>(
      where: where?.call(Tenant.t),
      orderBy: orderBy?.call(Tenant.t),
      orderByList: orderByList?.call(Tenant.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Tenant]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Tenant.t`.
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
  _ida.Stream<List<Tenant>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TenantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TenantTable>? orderBy,
    _is.OrderByListBuilder<TenantTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Tenant>(
      where: where?.call(Tenant.t),
      orderBy: orderBy?.call(Tenant.t),
      orderByList: orderByList?.call(Tenant.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Tenant] matching the given query parameters.
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
  Future<Tenant?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TenantTable>? where,
    int? offset,
    _is.OrderByBuilder<TenantTable>? orderBy,
    _is.OrderByListBuilder<TenantTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Tenant>(
      where: where?.call(Tenant.t),
      orderBy: orderBy?.call(Tenant.t),
      orderByList: orderByList?.call(Tenant.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Tenant] by its [id] or null if no such row exists.
  Future<Tenant?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Tenant>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Tenant]s in the list and returns the inserted rows.
  ///
  /// The returned [Tenant]s will have their `id` fields set.
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
  Future<List<Tenant>> insert(
    _is.DatabaseSession session,
    List<Tenant> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Tenant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Tenant] and returns the inserted row.
  ///
  /// The returned [Tenant] will have its `id` field set.
  Future<Tenant> insertRow(
    _is.DatabaseSession session,
    Tenant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Tenant>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Tenant]s in the list and returns the resulting rows.
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
  /// The returned [Tenant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Tenant>> upsert(
    _is.DatabaseSession session,
    List<Tenant> rows, {
    required _is.ColumnSelections<TenantTable> conflictColumns,
    _is.ColumnSelections<TenantTable>? updateColumns,
    _is.WhereExpressionBuilder<TenantTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Tenant>(
      rows,
      conflictColumns: conflictColumns(Tenant.t),
      updateColumns: updateColumns?.call(Tenant.t),
      updateWhere: updateWhere?.call(Tenant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Tenant] and returns the resulting row.
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
  /// The returned [Tenant] will have its `id` field set.
  Future<Tenant?> upsertRow(
    _is.DatabaseSession session,
    Tenant row, {
    required _is.ColumnSelections<TenantTable> conflictColumns,
    _is.ColumnSelections<TenantTable>? updateColumns,
    _is.WhereExpressionBuilder<TenantTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Tenant>(
      row,
      conflictColumns: conflictColumns(Tenant.t),
      updateColumns: updateColumns?.call(Tenant.t),
      updateWhere: updateWhere?.call(Tenant.t),
      transaction: transaction,
    );
  }

  /// Updates all [Tenant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Tenant>> update(
    _is.DatabaseSession session,
    List<Tenant> rows, {
    _is.ColumnSelections<TenantTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Tenant>(
      rows,
      columns: columns?.call(Tenant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Tenant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Tenant> updateRow(
    _is.DatabaseSession session,
    Tenant row, {
    _is.ColumnSelections<TenantTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Tenant>(
      row,
      columns: columns?.call(Tenant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Tenant] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Tenant?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<TenantUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Tenant>(
      id,
      columnValues: columnValues(Tenant.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Tenant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Tenant>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<TenantUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<TenantTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<TenantTable>? orderBy,
    _is.OrderByListBuilder<TenantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Tenant>(
      columnValues: columnValues(Tenant.t.updateTable),
      where: where(Tenant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Tenant.t),
      orderByList: orderByList?.call(Tenant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Tenant]s in the list and returns the deleted rows.
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
  Future<List<Tenant>> delete(
    _is.DatabaseSession session,
    List<Tenant> rows, {
    _is.OrderByBuilder<TenantTable>? orderBy,
    _is.OrderByListBuilder<TenantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Tenant>(
      rows,
      orderBy: orderBy?.call(Tenant.t),
      orderByList: orderByList?.call(Tenant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Tenant].
  Future<Tenant> deleteRow(
    _is.DatabaseSession session,
    Tenant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Tenant>(
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
  Future<List<Tenant>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TenantTable> where,
    _is.OrderByBuilder<TenantTable>? orderBy,
    _is.OrderByListBuilder<TenantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Tenant>(
      where: where(Tenant.t),
      orderBy: orderBy?.call(Tenant.t),
      orderByList: orderByList?.call(Tenant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<TenantTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Tenant>(
      where: where?.call(Tenant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Tenant] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<TenantTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Tenant>(
      where: where(Tenant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
