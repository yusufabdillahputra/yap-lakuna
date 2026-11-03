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

/// Cabang/outlet. `code` dipakai di nomor nota.
abstract class Outlet
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  Outlet._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.code,
    required this.name,
    this.address,
    this.phone,
    this.timezone,
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

  factory Outlet({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required String code,
    required String name,
    String? address,
    String? phone,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _OutletImpl;

  factory Outlet.fromJson(Map<String, dynamic> jsonSerialization) {
    return Outlet(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      code: jsonSerialization['code'] as String,
      name: jsonSerialization['name'] as String,
      address: jsonSerialization['address'] as String?,
      phone: jsonSerialization['phone'] as String?,
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

  static final t = OutletTable();

  static const db = OutletRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  String code;

  String name;

  String? address;

  String? phone;

  String? timezone;

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

  /// Returns a shallow copy of this [Outlet]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Outlet copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    String? code,
    String? name,
    String? address,
    String? phone,
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
      '__className__': 'Outlet',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'code': code,
      'name': name,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (timezone != null) 'timezone': timezone,
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
      '__className__': 'Outlet',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'code': code,
      'name': name,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (timezone != null) 'timezone': timezone,
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

  static OutletInclude include() {
    return OutletInclude._();
  }

  static OutletIncludeList includeList({
    _is.WhereExpressionBuilder<OutletTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OutletTable>? orderBy,
    _is.OrderByListBuilder<OutletTable>? orderByList,
    OutletInclude? include,
  }) {
    return OutletIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Outlet.t),
      orderByList: orderByList?.call(Outlet.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OutletImpl extends Outlet {
  _OutletImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required String code,
    required String name,
    String? address,
    String? phone,
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
         tenantId: tenantId,
         code: code,
         name: name,
         address: address,
         phone: phone,
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

  /// Returns a shallow copy of this [Outlet]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Outlet copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    String? code,
    String? name,
    Object? address = _Undefined,
    Object? phone = _Undefined,
    Object? timezone = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return Outlet(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      code: code ?? this.code,
      name: name ?? this.name,
      address: address is String? ? address : this.address,
      phone: phone is String? ? phone : this.phone,
      timezone: timezone is String? ? timezone : this.timezone,
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

class OutletUpdateTable extends _is.UpdateTable<OutletTable> {
  OutletUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<String, String> code(String value) => _is.ColumnValue(
    table.code,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> address(String? value) => _is.ColumnValue(
    table.address,
    value,
  );

  _is.ColumnValue<String, String> phone(String? value) => _is.ColumnValue(
    table.phone,
    value,
  );

  _is.ColumnValue<String, String> timezone(String? value) => _is.ColumnValue(
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

class OutletTable extends _is.Table<_is.UuidValue> {
  OutletTable({super.tableRelation}) : super(tableName: 'outlets') {
    updateTable = OutletUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    code = _is.ColumnString(
      'code',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    address = _is.ColumnString(
      'address',
      this,
    );
    phone = _is.ColumnString(
      'phone',
      this,
    );
    timezone = _is.ColumnString(
      'timezone',
      this,
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

  late final OutletUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnString code;

  late final _is.ColumnString name;

  late final _is.ColumnString address;

  late final _is.ColumnString phone;

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
    tenantId,
    code,
    name,
    address,
    phone,
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

class OutletInclude extends _is.IncludeObject {
  OutletInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => Outlet.t;
}

class OutletIncludeList extends _is.IncludeList {
  OutletIncludeList._({
    _is.WhereExpressionBuilder<OutletTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Outlet.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => Outlet.t;
}

class OutletRepository {
  const OutletRepository._();

  /// Returns a list of [Outlet]s matching the given query parameters.
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
  Future<List<Outlet>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OutletTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OutletTable>? orderBy,
    _is.OrderByListBuilder<OutletTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Outlet>(
      where: where?.call(Outlet.t),
      orderBy: orderBy?.call(Outlet.t),
      orderByList: orderByList?.call(Outlet.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Outlet]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Outlet.t`.
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
  _ida.Stream<List<Outlet>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OutletTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OutletTable>? orderBy,
    _is.OrderByListBuilder<OutletTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Outlet>(
      where: where?.call(Outlet.t),
      orderBy: orderBy?.call(Outlet.t),
      orderByList: orderByList?.call(Outlet.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Outlet] matching the given query parameters.
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
  Future<Outlet?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OutletTable>? where,
    int? offset,
    _is.OrderByBuilder<OutletTable>? orderBy,
    _is.OrderByListBuilder<OutletTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Outlet>(
      where: where?.call(Outlet.t),
      orderBy: orderBy?.call(Outlet.t),
      orderByList: orderByList?.call(Outlet.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Outlet] by its [id] or null if no such row exists.
  Future<Outlet?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Outlet>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Outlet]s in the list and returns the inserted rows.
  ///
  /// The returned [Outlet]s will have their `id` fields set.
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
  Future<List<Outlet>> insert(
    _is.DatabaseSession session,
    List<Outlet> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Outlet>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Outlet] and returns the inserted row.
  ///
  /// The returned [Outlet] will have its `id` field set.
  Future<Outlet> insertRow(
    _is.DatabaseSession session,
    Outlet row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Outlet>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Outlet]s in the list and returns the resulting rows.
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
  /// The returned [Outlet]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Outlet>> upsert(
    _is.DatabaseSession session,
    List<Outlet> rows, {
    required _is.ColumnSelections<OutletTable> conflictColumns,
    _is.ColumnSelections<OutletTable>? updateColumns,
    _is.WhereExpressionBuilder<OutletTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Outlet>(
      rows,
      conflictColumns: conflictColumns(Outlet.t),
      updateColumns: updateColumns?.call(Outlet.t),
      updateWhere: updateWhere?.call(Outlet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Outlet] and returns the resulting row.
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
  /// The returned [Outlet] will have its `id` field set.
  Future<Outlet?> upsertRow(
    _is.DatabaseSession session,
    Outlet row, {
    required _is.ColumnSelections<OutletTable> conflictColumns,
    _is.ColumnSelections<OutletTable>? updateColumns,
    _is.WhereExpressionBuilder<OutletTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Outlet>(
      row,
      conflictColumns: conflictColumns(Outlet.t),
      updateColumns: updateColumns?.call(Outlet.t),
      updateWhere: updateWhere?.call(Outlet.t),
      transaction: transaction,
    );
  }

  /// Updates all [Outlet]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Outlet>> update(
    _is.DatabaseSession session,
    List<Outlet> rows, {
    _is.ColumnSelections<OutletTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Outlet>(
      rows,
      columns: columns?.call(Outlet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Outlet]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Outlet> updateRow(
    _is.DatabaseSession session,
    Outlet row, {
    _is.ColumnSelections<OutletTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Outlet>(
      row,
      columns: columns?.call(Outlet.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Outlet] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Outlet?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<OutletUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Outlet>(
      id,
      columnValues: columnValues(Outlet.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Outlet]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Outlet>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<OutletUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<OutletTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<OutletTable>? orderBy,
    _is.OrderByListBuilder<OutletTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Outlet>(
      columnValues: columnValues(Outlet.t.updateTable),
      where: where(Outlet.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Outlet.t),
      orderByList: orderByList?.call(Outlet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Outlet]s in the list and returns the deleted rows.
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
  Future<List<Outlet>> delete(
    _is.DatabaseSession session,
    List<Outlet> rows, {
    _is.OrderByBuilder<OutletTable>? orderBy,
    _is.OrderByListBuilder<OutletTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Outlet>(
      rows,
      orderBy: orderBy?.call(Outlet.t),
      orderByList: orderByList?.call(Outlet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Outlet].
  Future<Outlet> deleteRow(
    _is.DatabaseSession session,
    Outlet row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Outlet>(
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
  Future<List<Outlet>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OutletTable> where,
    _is.OrderByBuilder<OutletTable>? orderBy,
    _is.OrderByListBuilder<OutletTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Outlet>(
      where: where(Outlet.t),
      orderBy: orderBy?.call(Outlet.t),
      orderByList: orderByList?.call(Outlet.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<OutletTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Outlet>(
      where: where?.call(Outlet.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Outlet] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<OutletTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Outlet>(
      where: where(Outlet.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
