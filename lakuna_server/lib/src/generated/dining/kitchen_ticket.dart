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

/// Tiket dapur (F1-10): satu kiriman item Baru dari satu bill. Nomor
/// `K-0012` urut per hari per perangkat.
abstract class KitchenTicket
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  KitchenTicket._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.outletId,
    required this.deviceId,
    required this.saleId,
    required this.number,
    required this.staffId,
    required this.sentAt,
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

  factory KitchenTicket({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    required _is.UuidValue saleId,
    required int number,
    required _is.UuidValue staffId,
    required DateTime sentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _KitchenTicketImpl;

  factory KitchenTicket.fromJson(Map<String, dynamic> jsonSerialization) {
    return KitchenTicket(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      deviceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['deviceId'],
      ),
      saleId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['saleId']),
      number: jsonSerialization['number'] as int,
      staffId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['staffId'],
      ),
      sentAt: _is.DateTimeJsonExtension.fromJson(jsonSerialization['sentAt']),
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

  static final t = KitchenTicketTable();

  static const db = KitchenTicketRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue outletId;

  _is.UuidValue deviceId;

  _is.UuidValue saleId;

  int number;

  _is.UuidValue staffId;

  DateTime sentAt;

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

  /// Returns a shallow copy of this [KitchenTicket]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  KitchenTicket copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _is.UuidValue? saleId,
    int? number,
    _is.UuidValue? staffId,
    DateTime? sentAt,
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
      '__className__': 'KitchenTicket',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      'saleId': saleId.toJson(),
      'number': number,
      'staffId': staffId.toJson(),
      'sentAt': sentAt.toJson(),
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
      '__className__': 'KitchenTicket',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      'saleId': saleId.toJson(),
      'number': number,
      'staffId': staffId.toJson(),
      'sentAt': sentAt.toJson(),
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

  static KitchenTicketInclude include() {
    return KitchenTicketInclude._();
  }

  static KitchenTicketIncludeList includeList({
    _is.WhereExpressionBuilder<KitchenTicketTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<KitchenTicketTable>? orderBy,
    _is.OrderByListBuilder<KitchenTicketTable>? orderByList,
    KitchenTicketInclude? include,
  }) {
    return KitchenTicketIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(KitchenTicket.t),
      orderByList: orderByList?.call(KitchenTicket.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _KitchenTicketImpl extends KitchenTicket {
  _KitchenTicketImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    required _is.UuidValue saleId,
    required int number,
    required _is.UuidValue staffId,
    required DateTime sentAt,
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
         deviceId: deviceId,
         saleId: saleId,
         number: number,
         staffId: staffId,
         sentAt: sentAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [KitchenTicket]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  KitchenTicket copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _is.UuidValue? saleId,
    int? number,
    _is.UuidValue? staffId,
    DateTime? sentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return KitchenTicket(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      deviceId: deviceId ?? this.deviceId,
      saleId: saleId ?? this.saleId,
      number: number ?? this.number,
      staffId: staffId ?? this.staffId,
      sentAt: sentAt ?? this.sentAt,
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

class KitchenTicketUpdateTable extends _is.UpdateTable<KitchenTicketTable> {
  KitchenTicketUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> deviceId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.deviceId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> saleId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.saleId,
        value,
      );

  _is.ColumnValue<int, int> number(int value) => _is.ColumnValue(
    table.number,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> staffId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.staffId,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> sentAt(DateTime value) => _is.ColumnValue(
    table.sentAt,
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

class KitchenTicketTable extends _is.Table<_is.UuidValue> {
  KitchenTicketTable({super.tableRelation})
    : super(tableName: 'kitchen_tickets') {
    updateTable = KitchenTicketUpdateTable(this);
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
    deviceId = _is.ColumnUuid(
      'device_id',
      this,
      fieldName: 'deviceId',
    );
    saleId = _is.ColumnUuid(
      'sale_id',
      this,
      fieldName: 'saleId',
    );
    number = _is.ColumnInt(
      'number',
      this,
    );
    staffId = _is.ColumnUuid(
      'staff_id',
      this,
      fieldName: 'staffId',
    );
    sentAt = _is.ColumnDateTime(
      'sent_at',
      this,
      fieldName: 'sentAt',
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

  late final KitchenTicketUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid outletId;

  late final _is.ColumnUuid deviceId;

  late final _is.ColumnUuid saleId;

  late final _is.ColumnInt number;

  late final _is.ColumnUuid staffId;

  late final _is.ColumnDateTime sentAt;

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
    deviceId,
    saleId,
    number,
    staffId,
    sentAt,
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

class KitchenTicketInclude extends _is.IncludeObject {
  KitchenTicketInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => KitchenTicket.t;
}

class KitchenTicketIncludeList extends _is.IncludeList {
  KitchenTicketIncludeList._({
    _is.WhereExpressionBuilder<KitchenTicketTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(KitchenTicket.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => KitchenTicket.t;
}

class KitchenTicketRepository {
  const KitchenTicketRepository._();

  /// Returns a list of [KitchenTicket]s matching the given query parameters.
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
  Future<List<KitchenTicket>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<KitchenTicketTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<KitchenTicketTable>? orderBy,
    _is.OrderByListBuilder<KitchenTicketTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<KitchenTicket>(
      where: where?.call(KitchenTicket.t),
      orderBy: orderBy?.call(KitchenTicket.t),
      orderByList: orderByList?.call(KitchenTicket.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [KitchenTicket]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `KitchenTicket.t`.
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
  _ida.Stream<List<KitchenTicket>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<KitchenTicketTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<KitchenTicketTable>? orderBy,
    _is.OrderByListBuilder<KitchenTicketTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<KitchenTicket>(
      where: where?.call(KitchenTicket.t),
      orderBy: orderBy?.call(KitchenTicket.t),
      orderByList: orderByList?.call(KitchenTicket.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [KitchenTicket] matching the given query parameters.
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
  Future<KitchenTicket?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<KitchenTicketTable>? where,
    int? offset,
    _is.OrderByBuilder<KitchenTicketTable>? orderBy,
    _is.OrderByListBuilder<KitchenTicketTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<KitchenTicket>(
      where: where?.call(KitchenTicket.t),
      orderBy: orderBy?.call(KitchenTicket.t),
      orderByList: orderByList?.call(KitchenTicket.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [KitchenTicket] by its [id] or null if no such row exists.
  Future<KitchenTicket?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<KitchenTicket>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [KitchenTicket]s in the list and returns the inserted rows.
  ///
  /// The returned [KitchenTicket]s will have their `id` fields set.
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
  Future<List<KitchenTicket>> insert(
    _is.DatabaseSession session,
    List<KitchenTicket> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<KitchenTicket>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [KitchenTicket] and returns the inserted row.
  ///
  /// The returned [KitchenTicket] will have its `id` field set.
  Future<KitchenTicket> insertRow(
    _is.DatabaseSession session,
    KitchenTicket row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<KitchenTicket>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [KitchenTicket]s in the list and returns the resulting rows.
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
  /// The returned [KitchenTicket]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<KitchenTicket>> upsert(
    _is.DatabaseSession session,
    List<KitchenTicket> rows, {
    required _is.ColumnSelections<KitchenTicketTable> conflictColumns,
    _is.ColumnSelections<KitchenTicketTable>? updateColumns,
    _is.WhereExpressionBuilder<KitchenTicketTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<KitchenTicket>(
      rows,
      conflictColumns: conflictColumns(KitchenTicket.t),
      updateColumns: updateColumns?.call(KitchenTicket.t),
      updateWhere: updateWhere?.call(KitchenTicket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [KitchenTicket] and returns the resulting row.
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
  /// The returned [KitchenTicket] will have its `id` field set.
  Future<KitchenTicket?> upsertRow(
    _is.DatabaseSession session,
    KitchenTicket row, {
    required _is.ColumnSelections<KitchenTicketTable> conflictColumns,
    _is.ColumnSelections<KitchenTicketTable>? updateColumns,
    _is.WhereExpressionBuilder<KitchenTicketTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<KitchenTicket>(
      row,
      conflictColumns: conflictColumns(KitchenTicket.t),
      updateColumns: updateColumns?.call(KitchenTicket.t),
      updateWhere: updateWhere?.call(KitchenTicket.t),
      transaction: transaction,
    );
  }

  /// Updates all [KitchenTicket]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<KitchenTicket>> update(
    _is.DatabaseSession session,
    List<KitchenTicket> rows, {
    _is.ColumnSelections<KitchenTicketTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<KitchenTicket>(
      rows,
      columns: columns?.call(KitchenTicket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [KitchenTicket]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<KitchenTicket> updateRow(
    _is.DatabaseSession session,
    KitchenTicket row, {
    _is.ColumnSelections<KitchenTicketTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<KitchenTicket>(
      row,
      columns: columns?.call(KitchenTicket.t),
      transaction: transaction,
    );
  }

  /// Updates a single [KitchenTicket] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<KitchenTicket?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<KitchenTicketUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<KitchenTicket>(
      id,
      columnValues: columnValues(KitchenTicket.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [KitchenTicket]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<KitchenTicket>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<KitchenTicketUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<KitchenTicketTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<KitchenTicketTable>? orderBy,
    _is.OrderByListBuilder<KitchenTicketTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<KitchenTicket>(
      columnValues: columnValues(KitchenTicket.t.updateTable),
      where: where(KitchenTicket.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(KitchenTicket.t),
      orderByList: orderByList?.call(KitchenTicket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [KitchenTicket]s in the list and returns the deleted rows.
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
  Future<List<KitchenTicket>> delete(
    _is.DatabaseSession session,
    List<KitchenTicket> rows, {
    _is.OrderByBuilder<KitchenTicketTable>? orderBy,
    _is.OrderByListBuilder<KitchenTicketTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<KitchenTicket>(
      rows,
      orderBy: orderBy?.call(KitchenTicket.t),
      orderByList: orderByList?.call(KitchenTicket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [KitchenTicket].
  Future<KitchenTicket> deleteRow(
    _is.DatabaseSession session,
    KitchenTicket row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<KitchenTicket>(
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
  Future<List<KitchenTicket>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<KitchenTicketTable> where,
    _is.OrderByBuilder<KitchenTicketTable>? orderBy,
    _is.OrderByListBuilder<KitchenTicketTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<KitchenTicket>(
      where: where(KitchenTicket.t),
      orderBy: orderBy?.call(KitchenTicket.t),
      orderByList: orderByList?.call(KitchenTicket.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<KitchenTicketTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<KitchenTicket>(
      where: where?.call(KitchenTicket.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [KitchenTicket] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<KitchenTicketTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<KitchenTicket>(
      where: where(KitchenTicket.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
