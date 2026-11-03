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
import '../cash/cash_direction.dart' as _ince3wv0;

/// Uang masuk/keluar laci di luar penjualan (mis. beli es batu), selalu di
/// sesi kasir yang terbuka (F1-03). Pengeluaran dan bayar hutang dari laci
/// (F1-14/F1-15) menulis ke sini dengan `source` modulnya.
abstract class CashMovement
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  CashMovement._({
    _is.UuidValue? id,
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
  }) : id = id ?? const _is.Uuid().v7obj(),
       source = source ?? 'manual',
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory CashMovement({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue cashSessionId,
    required _ince3wv0.CashDirection direction,
    required int amount,
    required String note,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _CashMovementImpl;

  factory CashMovement.fromJson(Map<String, dynamic> jsonSerialization) {
    return CashMovement(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      cashSessionId: _is.UuidValueJsonExtension.fromJson(
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

  static final t = CashMovementTable();

  static const db = CashMovementRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue outletId;

  _is.UuidValue cashSessionId;

  _ince3wv0.CashDirection direction;

  /// Jumlah (rupiah, selalu positif).
  int amount;

  String note;

  /// Asal catatan: `manual` dari layar sesi kasir.
  String source;

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

  /// Returns a shallow copy of this [CashMovement]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CashMovement copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? cashSessionId,
    _ince3wv0.CashDirection? direction,
    int? amount,
    String? note,
    String? source,
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
    _is.WhereExpressionBuilder<CashMovementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CashMovementTable>? orderBy,
    _is.OrderByListBuilder<CashMovementTable>? orderByList,
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
    return _is.SerializationManager.encode(this);
  }
}

class _CashMovementImpl extends CashMovement {
  _CashMovementImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue cashSessionId,
    required _ince3wv0.CashDirection direction,
    required int amount,
    required String note,
    String? source,
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
  @_is.useResult
  @override
  CashMovement copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? cashSessionId,
    _ince3wv0.CashDirection? direction,
    int? amount,
    String? note,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
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

class CashMovementUpdateTable extends _is.UpdateTable<CashMovementTable> {
  CashMovementUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> cashSessionId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.cashSessionId,
    value,
  );

  _is.ColumnValue<_ince3wv0.CashDirection, _ince3wv0.CashDirection> direction(
    _ince3wv0.CashDirection value,
  ) => _is.ColumnValue(
    table.direction,
    value,
  );

  _is.ColumnValue<int, int> amount(int value) => _is.ColumnValue(
    table.amount,
    value,
  );

  _is.ColumnValue<String, String> note(String value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<String, String> source(String value) => _is.ColumnValue(
    table.source,
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

class CashMovementTable extends _is.Table<_is.UuidValue> {
  CashMovementTable({super.tableRelation})
    : super(tableName: 'cash_movements') {
    updateTable = CashMovementUpdateTable(this);
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
    cashSessionId = _is.ColumnUuid(
      'cash_session_id',
      this,
      fieldName: 'cashSessionId',
    );
    direction = _is.ColumnEnum(
      'direction',
      this,
      _is.EnumSerialization.byName,
    );
    amount = _is.ColumnInt(
      'amount',
      this,
    );
    note = _is.ColumnString(
      'note',
      this,
    );
    source = _is.ColumnString(
      'source',
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

  late final CashMovementUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid outletId;

  late final _is.ColumnUuid cashSessionId;

  late final _is.ColumnEnum<_ince3wv0.CashDirection> direction;

  /// Jumlah (rupiah, selalu positif).
  late final _is.ColumnInt amount;

  late final _is.ColumnString note;

  /// Asal catatan: `manual` dari layar sesi kasir.
  late final _is.ColumnString source;

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

class CashMovementInclude extends _is.IncludeObject {
  CashMovementInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => CashMovement.t;
}

class CashMovementIncludeList extends _is.IncludeList {
  CashMovementIncludeList._({
    _is.WhereExpressionBuilder<CashMovementTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CashMovement.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => CashMovement.t;
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CashMovementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CashMovementTable>? orderBy,
    _is.OrderByListBuilder<CashMovementTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CashMovementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CashMovementTable>? orderBy,
    _is.OrderByListBuilder<CashMovementTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CashMovementTable>? where,
    int? offset,
    _is.OrderByBuilder<CashMovementTable>? orderBy,
    _is.OrderByListBuilder<CashMovementTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session,
    List<CashMovement> rows, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    CashMovement row, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<CashMovement> rows, {
    required _is.ColumnSelections<CashMovementTable> conflictColumns,
    _is.ColumnSelections<CashMovementTable>? updateColumns,
    _is.WhereExpressionBuilder<CashMovementTable>? updateWhere,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    CashMovement row, {
    required _is.ColumnSelections<CashMovementTable> conflictColumns,
    _is.ColumnSelections<CashMovementTable>? updateColumns,
    _is.WhereExpressionBuilder<CashMovementTable>? updateWhere,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<CashMovement> rows, {
    _is.ColumnSelections<CashMovementTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    CashMovement row, {
    _is.ColumnSelections<CashMovementTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CashMovementUpdateTable> columnValues,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CashMovementUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CashMovementTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CashMovementTable>? orderBy,
    _is.OrderByListBuilder<CashMovementTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<CashMovement> rows, {
    _is.OrderByBuilder<CashMovementTable>? orderBy,
    _is.OrderByListBuilder<CashMovementTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    CashMovement row, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CashMovementTable> where,
    _is.OrderByBuilder<CashMovementTable>? orderBy,
    _is.OrderByListBuilder<CashMovementTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CashMovementTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CashMovement>(
      where: where?.call(CashMovement.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CashMovement] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CashMovementTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CashMovement>(
      where: where(CashMovement.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
