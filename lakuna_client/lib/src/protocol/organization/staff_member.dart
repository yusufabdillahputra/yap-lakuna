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

/// Staf toko. PIN dan kata sandi disimpan sebagai hash Argon2id (string PHC).
abstract class StaffMember
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  StaffMember._({
    _isc.UuidValue? id,
    required this.tenantId,
    required this.name,
    this.email,
    this.pinHash,
    this.passwordHash,
    bool? isOwner,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _isc.Uuid().v7obj(),
       isOwner = isOwner ?? false,
       isActive = isActive ?? true,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory StaffMember({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required String name,
    String? email,
    String? pinHash,
    String? passwordHash,
    bool? isOwner,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _StaffMemberImpl;

  factory StaffMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return StaffMember(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      name: jsonSerialization['name'] as String,
      email: jsonSerialization['email'] as String?,
      pinHash: jsonSerialization['pinHash'] as String?,
      passwordHash: jsonSerialization['passwordHash'] as String?,
      isOwner: jsonSerialization['isOwner'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isOwner']),
      isActive: jsonSerialization['isActive'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      createdBy: jsonSerialization['createdBy'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['createdBy'],
            ),
      updatedBy: jsonSerialization['updatedBy'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['updatedBy'],
            ),
      version: jsonSerialization['version'] as int?,
      hlc: jsonSerialization['hlc'] as String,
      originDeviceId: jsonSerialization['originDeviceId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['originDeviceId'],
            ),
    );
  }

  static final t = StaffMemberTable();

  static const db = StaffMemberRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  String name;

  String? email;

  String? pinHash;

  /// Hash Argon2id kata sandi pemilik (login email, F1-01).
  String? passwordHash;

  bool isOwner;

  bool isActive;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? deletedAt;

  _isc.UuidValue? createdBy;

  _isc.UuidValue? updatedBy;

  int version;

  String hlc;

  _isc.UuidValue? originDeviceId;

  @override
  _isd.Table<_isc.UuidValue> get table => t;

  /// Returns a shallow copy of this [StaffMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  StaffMember copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    String? name,
    String? email,
    String? pinHash,
    String? passwordHash,
    bool? isOwner,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StaffMember',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'name': name,
      if (email != null) 'email': email,
      if (pinHash != null) 'pinHash': pinHash,
      if (passwordHash != null) 'passwordHash': passwordHash,
      'isOwner': isOwner,
      'isActive': isActive,
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
      '__className__': 'StaffMember',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'name': name,
      if (email != null) 'email': email,
      if (pinHash != null) 'pinHash': pinHash,
      if (passwordHash != null) 'passwordHash': passwordHash,
      'isOwner': isOwner,
      'isActive': isActive,
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

  static StaffMemberInclude include() {
    return StaffMemberInclude._();
  }

  static StaffMemberIncludeList includeList({
    _isd.WhereExpressionBuilder<StaffMemberTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StaffMemberTable>? orderBy,
    _isd.OrderByListBuilder<StaffMemberTable>? orderByList,
    StaffMemberInclude? include,
  }) {
    return StaffMemberIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StaffMember.t),
      orderByList: orderByList?.call(StaffMember.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StaffMemberImpl extends StaffMember {
  _StaffMemberImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required String name,
    String? email,
    String? pinHash,
    String? passwordHash,
    bool? isOwner,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) : super._(
         id: id,
         tenantId: tenantId,
         name: name,
         email: email,
         pinHash: pinHash,
         passwordHash: passwordHash,
         isOwner: isOwner,
         isActive: isActive,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [StaffMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  StaffMember copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    String? name,
    Object? email = _Undefined,
    Object? pinHash = _Undefined,
    Object? passwordHash = _Undefined,
    bool? isOwner,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return StaffMember(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      email: email is String? ? email : this.email,
      pinHash: pinHash is String? ? pinHash : this.pinHash,
      passwordHash: passwordHash is String? ? passwordHash : this.passwordHash,
      isOwner: isOwner ?? this.isOwner,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt is _isc.UndefinedSentinel
          ? this.deletedAt
          : deletedAt,
      createdBy: createdBy is _isc.UndefinedSentinel
          ? this.createdBy
          : createdBy,
      updatedBy: updatedBy is _isc.UndefinedSentinel
          ? this.updatedBy
          : updatedBy,
      version: version ?? this.version,
      hlc: hlc ?? this.hlc,
      originDeviceId: originDeviceId is _isc.UndefinedSentinel
          ? this.originDeviceId
          : originDeviceId,
    );
  }
}

class StaffMemberUpdateTable extends _isd.UpdateTable<StaffMemberTable> {
  StaffMemberUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> tenantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.tenantId,
    value,
  );

  _isd.ColumnValue<String, String> name(String value) => _isd.ColumnValue(
    table.name,
    value,
  );

  _isd.ColumnValue<String, String> email(String? value) => _isd.ColumnValue(
    table.email,
    value,
  );

  _isd.ColumnValue<String, String> pinHash(String? value) => _isd.ColumnValue(
    table.pinHash,
    value,
  );

  _isd.ColumnValue<String, String> passwordHash(String? value) =>
      _isd.ColumnValue(
        table.passwordHash,
        value,
      );

  _isd.ColumnValue<bool, bool> isOwner(bool value) => _isd.ColumnValue(
    table.isOwner,
    value,
  );

  _isd.ColumnValue<bool, bool> isActive(bool value) => _isd.ColumnValue(
    table.isActive,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _isd.ColumnValue(
        table.createdAt,
        value,
      );

  _isd.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _isd.ColumnValue(
        table.updatedAt,
        value,
      );

  _isd.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _isd.ColumnValue(
        table.deletedAt,
        value,
      );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> createdBy(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.createdBy,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> updatedBy(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.updatedBy,
    value,
  );

  _isd.ColumnValue<int, int> version(int value) => _isd.ColumnValue(
    table.version,
    value,
  );

  _isd.ColumnValue<String, String> hlc(String value) => _isd.ColumnValue(
    table.hlc,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> originDeviceId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.originDeviceId,
    value,
  );
}

class StaffMemberTable extends _isd.Table<_isc.UuidValue> {
  StaffMemberTable({super.tableRelation}) : super(tableName: 'staff_members') {
    updateTable = StaffMemberUpdateTable(this);
    tenantId = _isd.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    name = _isd.ColumnString(
      'name',
      this,
    );
    email = _isd.ColumnString(
      'email',
      this,
    );
    pinHash = _isd.ColumnString(
      'pin_hash',
      this,
      fieldName: 'pinHash',
    );
    passwordHash = _isd.ColumnString(
      'password_hash',
      this,
      fieldName: 'passwordHash',
    );
    isOwner = _isd.ColumnBool(
      'is_owner',
      this,
      hasDefault: true,
      fieldName: 'isOwner',
    );
    isActive = _isd.ColumnBool(
      'is_active',
      this,
      hasDefault: true,
      fieldName: 'isActive',
    );
    createdAt = _isd.ColumnDateTime(
      'created_at',
      this,
      hasDefault: true,
      fieldName: 'createdAt',
    );
    updatedAt = _isd.ColumnDateTime(
      'updated_at',
      this,
      hasDefault: true,
      fieldName: 'updatedAt',
    );
    deletedAt = _isd.ColumnDateTime(
      'deleted_at',
      this,
      fieldName: 'deletedAt',
    );
    createdBy = _isd.ColumnUuid(
      'created_by',
      this,
      fieldName: 'createdBy',
    );
    updatedBy = _isd.ColumnUuid(
      'updated_by',
      this,
      fieldName: 'updatedBy',
    );
    version = _isd.ColumnInt(
      'version',
      this,
      hasDefault: true,
    );
    hlc = _isd.ColumnString(
      'hlc',
      this,
    );
    originDeviceId = _isd.ColumnUuid(
      'origin_device_id',
      this,
      fieldName: 'originDeviceId',
    );
  }

  late final StaffMemberUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnString name;

  late final _isd.ColumnString email;

  late final _isd.ColumnString pinHash;

  /// Hash Argon2id kata sandi pemilik (login email, F1-01).
  late final _isd.ColumnString passwordHash;

  late final _isd.ColumnBool isOwner;

  late final _isd.ColumnBool isActive;

  late final _isd.ColumnDateTime createdAt;

  late final _isd.ColumnDateTime updatedAt;

  late final _isd.ColumnDateTime deletedAt;

  late final _isd.ColumnUuid createdBy;

  late final _isd.ColumnUuid updatedBy;

  late final _isd.ColumnInt version;

  late final _isd.ColumnString hlc;

  late final _isd.ColumnUuid originDeviceId;

  @override
  List<_isd.Column> get columns => [
    id,
    tenantId,
    name,
    email,
    pinHash,
    passwordHash,
    isOwner,
    isActive,
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

class StaffMemberInclude extends _isd.IncludeObject {
  StaffMemberInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => StaffMember.t;
}

class StaffMemberIncludeList extends _isd.IncludeList {
  StaffMemberIncludeList._({
    _isd.WhereExpressionBuilder<StaffMemberTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StaffMember.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => StaffMember.t;
}

class StaffMemberRepository {
  const StaffMemberRepository._();

  /// Returns a list of [StaffMember]s matching the given query parameters.
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
  Future<List<StaffMember>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StaffMemberTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StaffMemberTable>? orderBy,
    _isd.OrderByListBuilder<StaffMemberTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StaffMember>(
      where: where?.call(StaffMember.t),
      orderBy: orderBy?.call(StaffMember.t),
      orderByList: orderByList?.call(StaffMember.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [StaffMember]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `StaffMember.t`.
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
  _ida.Stream<List<StaffMember>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StaffMemberTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StaffMemberTable>? orderBy,
    _isd.OrderByListBuilder<StaffMemberTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<StaffMember>(
      where: where?.call(StaffMember.t),
      orderBy: orderBy?.call(StaffMember.t),
      orderByList: orderByList?.call(StaffMember.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [StaffMember] matching the given query parameters.
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
  Future<StaffMember?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StaffMemberTable>? where,
    int? offset,
    _isd.OrderByBuilder<StaffMemberTable>? orderBy,
    _isd.OrderByListBuilder<StaffMemberTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StaffMember>(
      where: where?.call(StaffMember.t),
      orderBy: orderBy?.call(StaffMember.t),
      orderByList: orderByList?.call(StaffMember.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StaffMember] by its [id] or null if no such row exists.
  Future<StaffMember?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StaffMember>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StaffMember]s in the list and returns the inserted rows.
  ///
  /// The returned [StaffMember]s will have their `id` fields set.
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
  Future<List<StaffMember>> insert(
    _isd.DatabaseSession session,
    List<StaffMember> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StaffMember>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StaffMember] and returns the inserted row.
  ///
  /// The returned [StaffMember] will have its `id` field set.
  Future<StaffMember> insertRow(
    _isd.DatabaseSession session,
    StaffMember row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<StaffMember>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StaffMember]s in the list and returns the resulting rows.
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
  /// The returned [StaffMember]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StaffMember>> upsert(
    _isd.DatabaseSession session,
    List<StaffMember> rows, {
    required _isd.ColumnSelections<StaffMemberTable> conflictColumns,
    _isd.ColumnSelections<StaffMemberTable>? updateColumns,
    _isd.WhereExpressionBuilder<StaffMemberTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StaffMember>(
      rows,
      conflictColumns: conflictColumns(StaffMember.t),
      updateColumns: updateColumns?.call(StaffMember.t),
      updateWhere: updateWhere?.call(StaffMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StaffMember] and returns the resulting row.
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
  /// The returned [StaffMember] will have its `id` field set.
  Future<StaffMember?> upsertRow(
    _isd.DatabaseSession session,
    StaffMember row, {
    required _isd.ColumnSelections<StaffMemberTable> conflictColumns,
    _isd.ColumnSelections<StaffMemberTable>? updateColumns,
    _isd.WhereExpressionBuilder<StaffMemberTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StaffMember>(
      row,
      conflictColumns: conflictColumns(StaffMember.t),
      updateColumns: updateColumns?.call(StaffMember.t),
      updateWhere: updateWhere?.call(StaffMember.t),
      transaction: transaction,
    );
  }

  /// Updates all [StaffMember]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StaffMember>> update(
    _isd.DatabaseSession session,
    List<StaffMember> rows, {
    _isd.ColumnSelections<StaffMemberTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StaffMember>(
      rows,
      columns: columns?.call(StaffMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StaffMember]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StaffMember> updateRow(
    _isd.DatabaseSession session,
    StaffMember row, {
    _isd.ColumnSelections<StaffMemberTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<StaffMember>(
      row,
      columns: columns?.call(StaffMember.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StaffMember] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StaffMember?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<StaffMemberUpdateTable> columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<StaffMember>(
      id,
      columnValues: columnValues(StaffMember.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StaffMember]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StaffMember>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<StaffMemberUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<StaffMemberTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StaffMemberTable>? orderBy,
    _isd.OrderByListBuilder<StaffMemberTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StaffMember>(
      columnValues: columnValues(StaffMember.t.updateTable),
      where: where(StaffMember.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StaffMember.t),
      orderByList: orderByList?.call(StaffMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StaffMember]s in the list and returns the deleted rows.
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
  Future<List<StaffMember>> delete(
    _isd.DatabaseSession session,
    List<StaffMember> rows, {
    _isd.OrderByBuilder<StaffMemberTable>? orderBy,
    _isd.OrderByListBuilder<StaffMemberTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StaffMember>(
      rows,
      orderBy: orderBy?.call(StaffMember.t),
      orderByList: orderByList?.call(StaffMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StaffMember].
  Future<StaffMember> deleteRow(
    _isd.DatabaseSession session,
    StaffMember row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StaffMember>(
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
  Future<List<StaffMember>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<StaffMemberTable> where,
    _isd.OrderByBuilder<StaffMemberTable>? orderBy,
    _isd.OrderByListBuilder<StaffMemberTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StaffMember>(
      where: where(StaffMember.t),
      orderBy: orderBy?.call(StaffMember.t),
      orderByList: orderByList?.call(StaffMember.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StaffMemberTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<StaffMember>(
      where: where?.call(StaffMember.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StaffMember] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<StaffMemberTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StaffMember>(
      where: where(StaffMember.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
