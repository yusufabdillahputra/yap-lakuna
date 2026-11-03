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

/// Tiket dapur (F1-10): satu kiriman item Baru dari satu bill. Nomor
/// `K-0012` urut per hari per perangkat.
abstract class KitchenTicket
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  KitchenTicket._({
    _isc.UuidValue? id,
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
  }) : id = id ?? const _isc.Uuid().v7obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory KitchenTicket({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue deviceId,
    required _isc.UuidValue saleId,
    required int number,
    required _isc.UuidValue staffId,
    required DateTime sentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _KitchenTicketImpl;

  factory KitchenTicket.fromJson(Map<String, dynamic> jsonSerialization) {
    return KitchenTicket(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      deviceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['deviceId'],
      ),
      saleId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['saleId']),
      number: jsonSerialization['number'] as int,
      staffId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['staffId'],
      ),
      sentAt: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['sentAt']),
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

  static final t = KitchenTicketTable();

  static const db = KitchenTicketRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue outletId;

  _isc.UuidValue deviceId;

  _isc.UuidValue saleId;

  int number;

  _isc.UuidValue staffId;

  DateTime sentAt;

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

  /// Returns a shallow copy of this [KitchenTicket]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  KitchenTicket copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? deviceId,
    _isc.UuidValue? saleId,
    int? number,
    _isc.UuidValue? staffId,
    DateTime? sentAt,
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
    _isd.WhereExpressionBuilder<KitchenTicketTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<KitchenTicketTable>? orderBy,
    _isd.OrderByListBuilder<KitchenTicketTable>? orderByList,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _KitchenTicketImpl extends KitchenTicket {
  _KitchenTicketImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue deviceId,
    required _isc.UuidValue saleId,
    required int number,
    required _isc.UuidValue staffId,
    required DateTime sentAt,
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
  @_isc.useResult
  @override
  KitchenTicket copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? deviceId,
    _isc.UuidValue? saleId,
    int? number,
    _isc.UuidValue? staffId,
    DateTime? sentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
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

class KitchenTicketUpdateTable extends _isd.UpdateTable<KitchenTicketTable> {
  KitchenTicketUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> tenantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.tenantId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> outletId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.outletId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> deviceId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.deviceId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> saleId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.saleId,
    value,
  );

  _isd.ColumnValue<int, int> number(int value) => _isd.ColumnValue(
    table.number,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> staffId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.staffId,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> sentAt(DateTime value) =>
      _isd.ColumnValue(
        table.sentAt,
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

class KitchenTicketTable extends _isd.Table<_isc.UuidValue> {
  KitchenTicketTable({super.tableRelation})
    : super(tableName: 'kitchen_tickets') {
    updateTable = KitchenTicketUpdateTable(this);
    tenantId = _isd.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    outletId = _isd.ColumnUuid(
      'outlet_id',
      this,
      fieldName: 'outletId',
    );
    deviceId = _isd.ColumnUuid(
      'device_id',
      this,
      fieldName: 'deviceId',
    );
    saleId = _isd.ColumnUuid(
      'sale_id',
      this,
      fieldName: 'saleId',
    );
    number = _isd.ColumnInt(
      'number',
      this,
    );
    staffId = _isd.ColumnUuid(
      'staff_id',
      this,
      fieldName: 'staffId',
    );
    sentAt = _isd.ColumnDateTime(
      'sent_at',
      this,
      fieldName: 'sentAt',
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

  late final KitchenTicketUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid outletId;

  late final _isd.ColumnUuid deviceId;

  late final _isd.ColumnUuid saleId;

  late final _isd.ColumnInt number;

  late final _isd.ColumnUuid staffId;

  late final _isd.ColumnDateTime sentAt;

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

class KitchenTicketInclude extends _isd.IncludeObject {
  KitchenTicketInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => KitchenTicket.t;
}

class KitchenTicketIncludeList extends _isd.IncludeList {
  KitchenTicketIncludeList._({
    _isd.WhereExpressionBuilder<KitchenTicketTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(KitchenTicket.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => KitchenTicket.t;
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<KitchenTicketTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<KitchenTicketTable>? orderBy,
    _isd.OrderByListBuilder<KitchenTicketTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<KitchenTicketTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<KitchenTicketTable>? orderBy,
    _isd.OrderByListBuilder<KitchenTicketTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<KitchenTicketTable>? where,
    int? offset,
    _isd.OrderByBuilder<KitchenTicketTable>? orderBy,
    _isd.OrderByListBuilder<KitchenTicketTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session,
    List<KitchenTicket> rows, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    KitchenTicket row, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<KitchenTicket> rows, {
    required _isd.ColumnSelections<KitchenTicketTable> conflictColumns,
    _isd.ColumnSelections<KitchenTicketTable>? updateColumns,
    _isd.WhereExpressionBuilder<KitchenTicketTable>? updateWhere,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    KitchenTicket row, {
    required _isd.ColumnSelections<KitchenTicketTable> conflictColumns,
    _isd.ColumnSelections<KitchenTicketTable>? updateColumns,
    _isd.WhereExpressionBuilder<KitchenTicketTable>? updateWhere,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<KitchenTicket> rows, {
    _isd.ColumnSelections<KitchenTicketTable>? columns,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    KitchenTicket row, {
    _isd.ColumnSelections<KitchenTicketTable>? columns,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<KitchenTicketUpdateTable> columnValues,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<KitchenTicketUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<KitchenTicketTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<KitchenTicketTable>? orderBy,
    _isd.OrderByListBuilder<KitchenTicketTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<KitchenTicket> rows, {
    _isd.OrderByBuilder<KitchenTicketTable>? orderBy,
    _isd.OrderByListBuilder<KitchenTicketTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    KitchenTicket row, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<KitchenTicketTable> where,
    _isd.OrderByBuilder<KitchenTicketTable>? orderBy,
    _isd.OrderByListBuilder<KitchenTicketTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<KitchenTicketTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<KitchenTicket>(
      where: where?.call(KitchenTicket.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [KitchenTicket] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<KitchenTicketTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<KitchenTicket>(
      where: where(KitchenTicket.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
