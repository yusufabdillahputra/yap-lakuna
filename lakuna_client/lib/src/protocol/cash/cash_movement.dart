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
import '../cash/cash_direction.dart' as _ince3wv0;

/// Uang masuk/keluar laci di luar penjualan (mis. beli es batu), selalu di
/// sesi kasir yang terbuka (F1-03). Pengeluaran dan bayar hutang dari laci
/// (F1-14/F1-15) menulis ke sini dengan `source` modulnya.
abstract class CashMovement
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  CashMovement._({
    _isc.UuidValue? id,
    required this.tenantId,
    required this.outletId,
    required this.cashSessionId,
    required this.direction,
    required this.amount,
    required this.note,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _isc.Uuid().v7obj(),
       source = source ?? 'manual',
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory CashMovement({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue cashSessionId,
    required _ince3wv0.CashDirection direction,
    required int amount,
    required String note,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _CashMovementImpl;

  factory CashMovement.fromJson(Map<String, dynamic> jsonSerialization) {
    return CashMovement(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      cashSessionId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['cashSessionId'],
      ),
      direction: _ince3wv0.CashDirection.fromJson(
        (jsonSerialization['direction'] as String),
      ),
      amount: jsonSerialization['amount'] as int,
      note: jsonSerialization['note'] as String,
      source: jsonSerialization['source'] as String?,
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

  static final t = CashMovementTable();

  static const db = CashMovementRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue outletId;

  _isc.UuidValue cashSessionId;

  _ince3wv0.CashDirection direction;

  /// Jumlah (rupiah, selalu positif).
  int amount;

  String note;

  /// Asal catatan: `manual` dari layar sesi kasir.
  String source;

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

  /// Returns a shallow copy of this [CashMovement]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CashMovement copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? cashSessionId,
    _ince3wv0.CashDirection? direction,
    int? amount,
    String? note,
    String? source,
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
      '__className__': 'CashMovement',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'cashSessionId': cashSessionId.toJson(),
      'direction': direction.toJson(),
      'amount': amount,
      'note': note,
      'source': source,
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
      '__className__': 'CashMovement',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'cashSessionId': cashSessionId.toJson(),
      'direction': direction.toJson(),
      'amount': amount,
      'note': note,
      'source': source,
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

  static CashMovementInclude include() {
    return CashMovementInclude._();
  }

  static CashMovementIncludeList includeList({
    _isd.WhereExpressionBuilder<CashMovementTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<CashMovementTable>? orderBy,
    _isd.OrderByListBuilder<CashMovementTable>? orderByList,
    CashMovementInclude? include,
  }) {
    return CashMovementIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CashMovement.t),
      orderByList: orderByList?.call(CashMovement.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _CashMovementImpl extends CashMovement {
  _CashMovementImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue cashSessionId,
    required _ince3wv0.CashDirection direction,
    required int amount,
    required String note,
    String? source,
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
         cashSessionId: cashSessionId,
         direction: direction,
         amount: amount,
         note: note,
         source: source,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [CashMovement]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CashMovement copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? cashSessionId,
    _ince3wv0.CashDirection? direction,
    int? amount,
    String? note,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return CashMovement(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      cashSessionId: cashSessionId ?? this.cashSessionId,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      source: source ?? this.source,
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

class CashMovementUpdateTable extends _isd.UpdateTable<CashMovementTable> {
  CashMovementUpdateTable(super.table);

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

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> cashSessionId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.cashSessionId,
    value,
  );

  _isd.ColumnValue<_ince3wv0.CashDirection, _ince3wv0.CashDirection> direction(
    _ince3wv0.CashDirection value,
  ) => _isd.ColumnValue(
    table.direction,
    value,
  );

  _isd.ColumnValue<int, int> amount(int value) => _isd.ColumnValue(
    table.amount,
    value,
  );

  _isd.ColumnValue<String, String> note(String value) => _isd.ColumnValue(
    table.note,
    value,
  );

  _isd.ColumnValue<String, String> source(String value) => _isd.ColumnValue(
    table.source,
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

class CashMovementTable extends _isd.Table<_isc.UuidValue> {
  CashMovementTable({super.tableRelation})
    : super(tableName: 'cash_movements') {
    updateTable = CashMovementUpdateTable(this);
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
    cashSessionId = _isd.ColumnUuid(
      'cash_session_id',
      this,
      fieldName: 'cashSessionId',
    );
    direction = _isd.ColumnEnum(
      'direction',
      this,
      _isd.EnumSerialization.byName,
    );
    amount = _isd.ColumnInt(
      'amount',
      this,
    );
    note = _isd.ColumnString(
      'note',
      this,
    );
    source = _isd.ColumnString(
      'source',
      this,
      hasDefault: true,
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

  late final CashMovementUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid outletId;

  late final _isd.ColumnUuid cashSessionId;

  late final _isd.ColumnEnum<_ince3wv0.CashDirection> direction;

  /// Jumlah (rupiah, selalu positif).
  late final _isd.ColumnInt amount;

  late final _isd.ColumnString note;

  /// Asal catatan: `manual` dari layar sesi kasir.
  late final _isd.ColumnString source;

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
    cashSessionId,
    direction,
    amount,
    note,
    source,
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

class CashMovementInclude extends _isd.IncludeObject {
  CashMovementInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => CashMovement.t;
}

class CashMovementIncludeList extends _isd.IncludeList {
  CashMovementIncludeList._({
    _isd.WhereExpressionBuilder<CashMovementTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CashMovement.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => CashMovement.t;
}

class CashMovementRepository {
  const CashMovementRepository._();

  /// Returns a list of [CashMovement]s matching the given query parameters.
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
  Future<List<CashMovement>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<CashMovementTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<CashMovementTable>? orderBy,
    _isd.OrderByListBuilder<CashMovementTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CashMovement>(
      where: where?.call(CashMovement.t),
      orderBy: orderBy?.call(CashMovement.t),
      orderByList: orderByList?.call(CashMovement.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CashMovement]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CashMovement.t`.
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
  _ida.Stream<List<CashMovement>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<CashMovementTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<CashMovementTable>? orderBy,
    _isd.OrderByListBuilder<CashMovementTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CashMovement>(
      where: where?.call(CashMovement.t),
      orderBy: orderBy?.call(CashMovement.t),
      orderByList: orderByList?.call(CashMovement.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CashMovement] matching the given query parameters.
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
  Future<CashMovement?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<CashMovementTable>? where,
    int? offset,
    _isd.OrderByBuilder<CashMovementTable>? orderBy,
    _isd.OrderByListBuilder<CashMovementTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CashMovement>(
      where: where?.call(CashMovement.t),
      orderBy: orderBy?.call(CashMovement.t),
      orderByList: orderByList?.call(CashMovement.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CashMovement] by its [id] or null if no such row exists.
  Future<CashMovement?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CashMovement>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CashMovement]s in the list and returns the inserted rows.
  ///
  /// The returned [CashMovement]s will have their `id` fields set.
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
  Future<List<CashMovement>> insert(
    _isd.DatabaseSession session,
    List<CashMovement> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CashMovement>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CashMovement] and returns the inserted row.
  ///
  /// The returned [CashMovement] will have its `id` field set.
  Future<CashMovement> insertRow(
    _isd.DatabaseSession session,
    CashMovement row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<CashMovement>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CashMovement]s in the list and returns the resulting rows.
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
  /// The returned [CashMovement]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CashMovement>> upsert(
    _isd.DatabaseSession session,
    List<CashMovement> rows, {
    required _isd.ColumnSelections<CashMovementTable> conflictColumns,
    _isd.ColumnSelections<CashMovementTable>? updateColumns,
    _isd.WhereExpressionBuilder<CashMovementTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CashMovement>(
      rows,
      conflictColumns: conflictColumns(CashMovement.t),
      updateColumns: updateColumns?.call(CashMovement.t),
      updateWhere: updateWhere?.call(CashMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CashMovement] and returns the resulting row.
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
  /// The returned [CashMovement] will have its `id` field set.
  Future<CashMovement?> upsertRow(
    _isd.DatabaseSession session,
    CashMovement row, {
    required _isd.ColumnSelections<CashMovementTable> conflictColumns,
    _isd.ColumnSelections<CashMovementTable>? updateColumns,
    _isd.WhereExpressionBuilder<CashMovementTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CashMovement>(
      row,
      conflictColumns: conflictColumns(CashMovement.t),
      updateColumns: updateColumns?.call(CashMovement.t),
      updateWhere: updateWhere?.call(CashMovement.t),
      transaction: transaction,
    );
  }

  /// Updates all [CashMovement]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CashMovement>> update(
    _isd.DatabaseSession session,
    List<CashMovement> rows, {
    _isd.ColumnSelections<CashMovementTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CashMovement>(
      rows,
      columns: columns?.call(CashMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CashMovement]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CashMovement> updateRow(
    _isd.DatabaseSession session,
    CashMovement row, {
    _isd.ColumnSelections<CashMovementTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<CashMovement>(
      row,
      columns: columns?.call(CashMovement.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CashMovement] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CashMovement?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<CashMovementUpdateTable> columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<CashMovement>(
      id,
      columnValues: columnValues(CashMovement.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CashMovement]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CashMovement>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<CashMovementUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<CashMovementTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<CashMovementTable>? orderBy,
    _isd.OrderByListBuilder<CashMovementTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CashMovement>(
      columnValues: columnValues(CashMovement.t.updateTable),
      where: where(CashMovement.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CashMovement.t),
      orderByList: orderByList?.call(CashMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CashMovement]s in the list and returns the deleted rows.
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
  Future<List<CashMovement>> delete(
    _isd.DatabaseSession session,
    List<CashMovement> rows, {
    _isd.OrderByBuilder<CashMovementTable>? orderBy,
    _isd.OrderByListBuilder<CashMovementTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CashMovement>(
      rows,
      orderBy: orderBy?.call(CashMovement.t),
      orderByList: orderByList?.call(CashMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CashMovement].
  Future<CashMovement> deleteRow(
    _isd.DatabaseSession session,
    CashMovement row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CashMovement>(
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
  Future<List<CashMovement>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<CashMovementTable> where,
    _isd.OrderByBuilder<CashMovementTable>? orderBy,
    _isd.OrderByListBuilder<CashMovementTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CashMovement>(
      where: where(CashMovement.t),
      orderBy: orderBy?.call(CashMovement.t),
      orderByList: orderByList?.call(CashMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<CashMovementTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<CashMovement>(
      where: where?.call(CashMovement.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CashMovement] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<CashMovementTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CashMovement>(
      where: where(CashMovement.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
