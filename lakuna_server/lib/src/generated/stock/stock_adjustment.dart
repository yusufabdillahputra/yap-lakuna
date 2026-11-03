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
import '../stock/stock_adjustment_reason.dart' as _il9w5f0k;

/// Dokumen penyesuaian stok (F1-08), nomor `SA-<OUTLET>-<PERANGKAT>-<yymmdd>-<nnnn>`.
/// Setiap baris berselisih membuat satu pergerakan `adjustment` di ledger.
abstract class StockAdjustment
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  StockAdjustment._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.outletId,
    required this.stockLocationId,
    required this.number,
    required this.reason,
    this.note,
    required this.totalValue,
    required this.staffId,
    required this.adjustedAt,
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

  factory StockAdjustment({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue stockLocationId,
    required String number,
    required _il9w5f0k.StockAdjustmentReason reason,
    String? note,
    required int totalValue,
    required _is.UuidValue staffId,
    required DateTime adjustedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _StockAdjustmentImpl;

  factory StockAdjustment.fromJson(Map<String, dynamic> jsonSerialization) {
    return StockAdjustment(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      stockLocationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['stockLocationId'],
      ),
      number: jsonSerialization['number'] as String,
      reason: _il9w5f0k.StockAdjustmentReason.fromJson(
        (jsonSerialization['reason'] as String),
      ),
      note: jsonSerialization['note'] as String?,
      totalValue: jsonSerialization['totalValue'] as int,
      staffId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['staffId'],
      ),
      adjustedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['adjustedAt'],
      ),
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

  static final t = StockAdjustmentTable();

  static const db = StockAdjustmentRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue outletId;

  _is.UuidValue stockLocationId;

  String number;

  _il9w5f0k.StockAdjustmentReason reason;

  String? note;

  /// Jumlah nilai selisih (rupiah, bertanda; negatif = rugi).
  int totalValue;

  _is.UuidValue staffId;

  DateTime adjustedAt;

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

  /// Returns a shallow copy of this [StockAdjustment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StockAdjustment copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? stockLocationId,
    String? number,
    _il9w5f0k.StockAdjustmentReason? reason,
    String? note,
    int? totalValue,
    _is.UuidValue? staffId,
    DateTime? adjustedAt,
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
      '__className__': 'StockAdjustment',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'stockLocationId': stockLocationId.toJson(),
      'number': number,
      'reason': reason.toJson(),
      if (note != null) 'note': note,
      'totalValue': totalValue,
      'staffId': staffId.toJson(),
      'adjustedAt': adjustedAt.toJson(),
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
      '__className__': 'StockAdjustment',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'stockLocationId': stockLocationId.toJson(),
      'number': number,
      'reason': reason.toJson(),
      if (note != null) 'note': note,
      'totalValue': totalValue,
      'staffId': staffId.toJson(),
      'adjustedAt': adjustedAt.toJson(),
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

  static StockAdjustmentInclude include() {
    return StockAdjustmentInclude._();
  }

  static StockAdjustmentIncludeList includeList({
    _is.WhereExpressionBuilder<StockAdjustmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockAdjustmentTable>? orderBy,
    _is.OrderByListBuilder<StockAdjustmentTable>? orderByList,
    StockAdjustmentInclude? include,
  }) {
    return StockAdjustmentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StockAdjustment.t),
      orderByList: orderByList?.call(StockAdjustment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StockAdjustmentImpl extends StockAdjustment {
  _StockAdjustmentImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue stockLocationId,
    required String number,
    required _il9w5f0k.StockAdjustmentReason reason,
    String? note,
    required int totalValue,
    required _is.UuidValue staffId,
    required DateTime adjustedAt,
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
         stockLocationId: stockLocationId,
         number: number,
         reason: reason,
         note: note,
         totalValue: totalValue,
         staffId: staffId,
         adjustedAt: adjustedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [StockAdjustment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StockAdjustment copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? stockLocationId,
    String? number,
    _il9w5f0k.StockAdjustmentReason? reason,
    Object? note = _Undefined,
    int? totalValue,
    _is.UuidValue? staffId,
    DateTime? adjustedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return StockAdjustment(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      stockLocationId: stockLocationId ?? this.stockLocationId,
      number: number ?? this.number,
      reason: reason ?? this.reason,
      note: note is String? ? note : this.note,
      totalValue: totalValue ?? this.totalValue,
      staffId: staffId ?? this.staffId,
      adjustedAt: adjustedAt ?? this.adjustedAt,
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

class StockAdjustmentUpdateTable extends _is.UpdateTable<StockAdjustmentTable> {
  StockAdjustmentUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> stockLocationId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.stockLocationId,
    value,
  );

  _is.ColumnValue<String, String> number(String value) => _is.ColumnValue(
    table.number,
    value,
  );

  _is.ColumnValue<
    _il9w5f0k.StockAdjustmentReason,
    _il9w5f0k.StockAdjustmentReason
  >
  reason(_il9w5f0k.StockAdjustmentReason value) => _is.ColumnValue(
    table.reason,
    value,
  );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<int, int> totalValue(int value) => _is.ColumnValue(
    table.totalValue,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> staffId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.staffId,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> adjustedAt(DateTime value) =>
      _is.ColumnValue(
        table.adjustedAt,
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

class StockAdjustmentTable extends _is.Table<_is.UuidValue> {
  StockAdjustmentTable({super.tableRelation})
    : super(tableName: 'stock_adjustments') {
    updateTable = StockAdjustmentUpdateTable(this);
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
    stockLocationId = _is.ColumnUuid(
      'stock_location_id',
      this,
      fieldName: 'stockLocationId',
    );
    number = _is.ColumnString(
      'number',
      this,
    );
    reason = _is.ColumnEnum(
      'reason',
      this,
      _is.EnumSerialization.byName,
    );
    note = _is.ColumnString(
      'note',
      this,
    );
    totalValue = _is.ColumnInt(
      'total_value',
      this,
      fieldName: 'totalValue',
    );
    staffId = _is.ColumnUuid(
      'staff_id',
      this,
      fieldName: 'staffId',
    );
    adjustedAt = _is.ColumnDateTime(
      'adjusted_at',
      this,
      fieldName: 'adjustedAt',
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

  late final StockAdjustmentUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid outletId;

  late final _is.ColumnUuid stockLocationId;

  late final _is.ColumnString number;

  late final _is.ColumnEnum<_il9w5f0k.StockAdjustmentReason> reason;

  late final _is.ColumnString note;

  /// Jumlah nilai selisih (rupiah, bertanda; negatif = rugi).
  late final _is.ColumnInt totalValue;

  late final _is.ColumnUuid staffId;

  late final _is.ColumnDateTime adjustedAt;

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
    stockLocationId,
    number,
    reason,
    note,
    totalValue,
    staffId,
    adjustedAt,
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

class StockAdjustmentInclude extends _is.IncludeObject {
  StockAdjustmentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => StockAdjustment.t;
}

class StockAdjustmentIncludeList extends _is.IncludeList {
  StockAdjustmentIncludeList._({
    _is.WhereExpressionBuilder<StockAdjustmentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StockAdjustment.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => StockAdjustment.t;
}

class StockAdjustmentRepository {
  const StockAdjustmentRepository._();

  /// Returns a list of [StockAdjustment]s matching the given query parameters.
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
  Future<List<StockAdjustment>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockAdjustmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockAdjustmentTable>? orderBy,
    _is.OrderByListBuilder<StockAdjustmentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StockAdjustment>(
      where: where?.call(StockAdjustment.t),
      orderBy: orderBy?.call(StockAdjustment.t),
      orderByList: orderByList?.call(StockAdjustment.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [StockAdjustment]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `StockAdjustment.t`.
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
  _ida.Stream<List<StockAdjustment>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockAdjustmentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockAdjustmentTable>? orderBy,
    _is.OrderByListBuilder<StockAdjustmentTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<StockAdjustment>(
      where: where?.call(StockAdjustment.t),
      orderBy: orderBy?.call(StockAdjustment.t),
      orderByList: orderByList?.call(StockAdjustment.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [StockAdjustment] matching the given query parameters.
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
  Future<StockAdjustment?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockAdjustmentTable>? where,
    int? offset,
    _is.OrderByBuilder<StockAdjustmentTable>? orderBy,
    _is.OrderByListBuilder<StockAdjustmentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StockAdjustment>(
      where: where?.call(StockAdjustment.t),
      orderBy: orderBy?.call(StockAdjustment.t),
      orderByList: orderByList?.call(StockAdjustment.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StockAdjustment] by its [id] or null if no such row exists.
  Future<StockAdjustment?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StockAdjustment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StockAdjustment]s in the list and returns the inserted rows.
  ///
  /// The returned [StockAdjustment]s will have their `id` fields set.
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
  Future<List<StockAdjustment>> insert(
    _is.DatabaseSession session,
    List<StockAdjustment> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StockAdjustment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StockAdjustment] and returns the inserted row.
  ///
  /// The returned [StockAdjustment] will have its `id` field set.
  Future<StockAdjustment> insertRow(
    _is.DatabaseSession session,
    StockAdjustment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StockAdjustment>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StockAdjustment]s in the list and returns the resulting rows.
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
  /// The returned [StockAdjustment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockAdjustment>> upsert(
    _is.DatabaseSession session,
    List<StockAdjustment> rows, {
    required _is.ColumnSelections<StockAdjustmentTable> conflictColumns,
    _is.ColumnSelections<StockAdjustmentTable>? updateColumns,
    _is.WhereExpressionBuilder<StockAdjustmentTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StockAdjustment>(
      rows,
      conflictColumns: conflictColumns(StockAdjustment.t),
      updateColumns: updateColumns?.call(StockAdjustment.t),
      updateWhere: updateWhere?.call(StockAdjustment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StockAdjustment] and returns the resulting row.
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
  /// The returned [StockAdjustment] will have its `id` field set.
  Future<StockAdjustment?> upsertRow(
    _is.DatabaseSession session,
    StockAdjustment row, {
    required _is.ColumnSelections<StockAdjustmentTable> conflictColumns,
    _is.ColumnSelections<StockAdjustmentTable>? updateColumns,
    _is.WhereExpressionBuilder<StockAdjustmentTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StockAdjustment>(
      row,
      conflictColumns: conflictColumns(StockAdjustment.t),
      updateColumns: updateColumns?.call(StockAdjustment.t),
      updateWhere: updateWhere?.call(StockAdjustment.t),
      transaction: transaction,
    );
  }

  /// Updates all [StockAdjustment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockAdjustment>> update(
    _is.DatabaseSession session,
    List<StockAdjustment> rows, {
    _is.ColumnSelections<StockAdjustmentTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StockAdjustment>(
      rows,
      columns: columns?.call(StockAdjustment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StockAdjustment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StockAdjustment> updateRow(
    _is.DatabaseSession session,
    StockAdjustment row, {
    _is.ColumnSelections<StockAdjustmentTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StockAdjustment>(
      row,
      columns: columns?.call(StockAdjustment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StockAdjustment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StockAdjustment?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<StockAdjustmentUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StockAdjustment>(
      id,
      columnValues: columnValues(StockAdjustment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StockAdjustment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockAdjustment>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StockAdjustmentUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<StockAdjustmentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockAdjustmentTable>? orderBy,
    _is.OrderByListBuilder<StockAdjustmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StockAdjustment>(
      columnValues: columnValues(StockAdjustment.t.updateTable),
      where: where(StockAdjustment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StockAdjustment.t),
      orderByList: orderByList?.call(StockAdjustment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StockAdjustment]s in the list and returns the deleted rows.
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
  Future<List<StockAdjustment>> delete(
    _is.DatabaseSession session,
    List<StockAdjustment> rows, {
    _is.OrderByBuilder<StockAdjustmentTable>? orderBy,
    _is.OrderByListBuilder<StockAdjustmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StockAdjustment>(
      rows,
      orderBy: orderBy?.call(StockAdjustment.t),
      orderByList: orderByList?.call(StockAdjustment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StockAdjustment].
  Future<StockAdjustment> deleteRow(
    _is.DatabaseSession session,
    StockAdjustment row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StockAdjustment>(
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
  Future<List<StockAdjustment>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StockAdjustmentTable> where,
    _is.OrderByBuilder<StockAdjustmentTable>? orderBy,
    _is.OrderByListBuilder<StockAdjustmentTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StockAdjustment>(
      where: where(StockAdjustment.t),
      orderBy: orderBy?.call(StockAdjustment.t),
      orderByList: orderByList?.call(StockAdjustment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockAdjustmentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StockAdjustment>(
      where: where?.call(StockAdjustment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StockAdjustment] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StockAdjustmentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StockAdjustment>(
      where: where(StockAdjustment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
