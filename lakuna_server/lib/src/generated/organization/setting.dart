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

/// Pengaturan per tenant; outlet_id diisi bila hanya berlaku untuk satu outlet.
/// scope_key = 'tenant' untuk pengaturan tingkat tenant, atau 'outlet:<id>' untuk
/// pengaturan per outlet (lihat settingScopeTenant / settingScopeOutlet di
/// lakuna_data). Kolom ini tidak boleh NULL agar indeks unik juga menjaga
/// pengaturan tingkat tenant (NULL dianggap berbeda oleh SQLite & Postgres).
abstract class Setting
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  Setting._({
    _is.UuidValue? id,
    required this.tenantId,
    this.outletId,
    required this.scopeKey,
    required this.key,
    String? valueJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _is.Uuid().v7obj(),
       valueJson = valueJson ?? 'null',
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory Setting({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    _is.UuidValue? outletId,
    required String scopeKey,
    required String key,
    String? valueJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _SettingImpl;

  factory Setting.fromJson(Map<String, dynamic> jsonSerialization) {
    return Setting(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: jsonSerialization['outletId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['outletId']),
      scopeKey: jsonSerialization['scopeKey'] as String,
      key: jsonSerialization['key'] as String,
      valueJson: jsonSerialization['valueJson'] as String?,
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

  static final t = SettingTable();

  static const db = SettingRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue? outletId;

  String scopeKey;

  String key;

  String valueJson;

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

  /// Returns a shallow copy of this [Setting]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Setting copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? key,
    String? valueJson,
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
      '__className__': 'Setting',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      if (outletId != null) 'outletId': outletId?.toJson(),
      'scopeKey': scopeKey,
      'key': key,
      'valueJson': valueJson,
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
      '__className__': 'Setting',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      if (outletId != null) 'outletId': outletId?.toJson(),
      'scopeKey': scopeKey,
      'key': key,
      'valueJson': valueJson,
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

  static SettingInclude include() {
    return SettingInclude._();
  }

  static SettingIncludeList includeList({
    _is.WhereExpressionBuilder<SettingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SettingTable>? orderBy,
    _is.OrderByListBuilder<SettingTable>? orderByList,
    SettingInclude? include,
  }) {
    return SettingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Setting.t),
      orderByList: orderByList?.call(Setting.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _SettingImpl extends Setting {
  _SettingImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    _is.UuidValue? outletId,
    required String scopeKey,
    required String key,
    String? valueJson,
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
         scopeKey: scopeKey,
         key: key,
         valueJson: valueJson,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [Setting]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Setting copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId = const _is.$UndefinedUuidValue(),
    String? scopeKey,
    String? key,
    String? valueJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return Setting(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId is _is.UndefinedSentinel ? this.outletId : outletId,
      scopeKey: scopeKey ?? this.scopeKey,
      key: key ?? this.key,
      valueJson: valueJson ?? this.valueJson,
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

class SettingUpdateTable extends _is.UpdateTable<SettingTable> {
  SettingUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> outletId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.outletId,
    value,
  );

  _is.ColumnValue<String, String> scopeKey(String value) => _is.ColumnValue(
    table.scopeKey,
    value,
  );

  _is.ColumnValue<String, String> key(String value) => _is.ColumnValue(
    table.key,
    value,
  );

  _is.ColumnValue<String, String> valueJson(String value) => _is.ColumnValue(
    table.valueJson,
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

class SettingTable extends _is.Table<_is.UuidValue> {
  SettingTable({super.tableRelation}) : super(tableName: 'settings') {
    updateTable = SettingUpdateTable(this);
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
    scopeKey = _is.ColumnString(
      'scope_key',
      this,
      fieldName: 'scopeKey',
    );
    key = _is.ColumnString(
      'key',
      this,
    );
    valueJson = _is.ColumnString(
      'value_json',
      this,
      hasDefault: true,
      fieldName: 'valueJson',
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

  late final SettingUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid outletId;

  late final _is.ColumnString scopeKey;

  late final _is.ColumnString key;

  late final _is.ColumnString valueJson;

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
    scopeKey,
    key,
    valueJson,
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

class SettingInclude extends _is.IncludeObject {
  SettingInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => Setting.t;
}

class SettingIncludeList extends _is.IncludeList {
  SettingIncludeList._({
    _is.WhereExpressionBuilder<SettingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Setting.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => Setting.t;
}

class SettingRepository {
  const SettingRepository._();

  /// Returns a list of [Setting]s matching the given query parameters.
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
  Future<List<Setting>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SettingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SettingTable>? orderBy,
    _is.OrderByListBuilder<SettingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Setting>(
      where: where?.call(Setting.t),
      orderBy: orderBy?.call(Setting.t),
      orderByList: orderByList?.call(Setting.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Setting]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Setting.t`.
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
  _ida.Stream<List<Setting>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SettingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SettingTable>? orderBy,
    _is.OrderByListBuilder<SettingTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Setting>(
      where: where?.call(Setting.t),
      orderBy: orderBy?.call(Setting.t),
      orderByList: orderByList?.call(Setting.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Setting] matching the given query parameters.
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
  Future<Setting?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SettingTable>? where,
    int? offset,
    _is.OrderByBuilder<SettingTable>? orderBy,
    _is.OrderByListBuilder<SettingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Setting>(
      where: where?.call(Setting.t),
      orderBy: orderBy?.call(Setting.t),
      orderByList: orderByList?.call(Setting.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Setting] by its [id] or null if no such row exists.
  Future<Setting?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Setting>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Setting]s in the list and returns the inserted rows.
  ///
  /// The returned [Setting]s will have their `id` fields set.
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
  Future<List<Setting>> insert(
    _is.DatabaseSession session,
    List<Setting> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Setting>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Setting] and returns the inserted row.
  ///
  /// The returned [Setting] will have its `id` field set.
  Future<Setting> insertRow(
    _is.DatabaseSession session,
    Setting row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Setting>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Setting]s in the list and returns the resulting rows.
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
  /// The returned [Setting]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Setting>> upsert(
    _is.DatabaseSession session,
    List<Setting> rows, {
    required _is.ColumnSelections<SettingTable> conflictColumns,
    _is.ColumnSelections<SettingTable>? updateColumns,
    _is.WhereExpressionBuilder<SettingTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Setting>(
      rows,
      conflictColumns: conflictColumns(Setting.t),
      updateColumns: updateColumns?.call(Setting.t),
      updateWhere: updateWhere?.call(Setting.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Setting] and returns the resulting row.
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
  /// The returned [Setting] will have its `id` field set.
  Future<Setting?> upsertRow(
    _is.DatabaseSession session,
    Setting row, {
    required _is.ColumnSelections<SettingTable> conflictColumns,
    _is.ColumnSelections<SettingTable>? updateColumns,
    _is.WhereExpressionBuilder<SettingTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Setting>(
      row,
      conflictColumns: conflictColumns(Setting.t),
      updateColumns: updateColumns?.call(Setting.t),
      updateWhere: updateWhere?.call(Setting.t),
      transaction: transaction,
    );
  }

  /// Updates all [Setting]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Setting>> update(
    _is.DatabaseSession session,
    List<Setting> rows, {
    _is.ColumnSelections<SettingTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Setting>(
      rows,
      columns: columns?.call(Setting.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Setting]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Setting> updateRow(
    _is.DatabaseSession session,
    Setting row, {
    _is.ColumnSelections<SettingTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Setting>(
      row,
      columns: columns?.call(Setting.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Setting] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Setting?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<SettingUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Setting>(
      id,
      columnValues: columnValues(Setting.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Setting]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Setting>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SettingUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SettingTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SettingTable>? orderBy,
    _is.OrderByListBuilder<SettingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Setting>(
      columnValues: columnValues(Setting.t.updateTable),
      where: where(Setting.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Setting.t),
      orderByList: orderByList?.call(Setting.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Setting]s in the list and returns the deleted rows.
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
  Future<List<Setting>> delete(
    _is.DatabaseSession session,
    List<Setting> rows, {
    _is.OrderByBuilder<SettingTable>? orderBy,
    _is.OrderByListBuilder<SettingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Setting>(
      rows,
      orderBy: orderBy?.call(Setting.t),
      orderByList: orderByList?.call(Setting.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Setting].
  Future<Setting> deleteRow(
    _is.DatabaseSession session,
    Setting row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Setting>(
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
  Future<List<Setting>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SettingTable> where,
    _is.OrderByBuilder<SettingTable>? orderBy,
    _is.OrderByListBuilder<SettingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Setting>(
      where: where(Setting.t),
      orderBy: orderBy?.call(Setting.t),
      orderByList: orderByList?.call(Setting.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SettingTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Setting>(
      where: where?.call(Setting.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Setting] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SettingTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Setting>(
      where: where(Setting.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
