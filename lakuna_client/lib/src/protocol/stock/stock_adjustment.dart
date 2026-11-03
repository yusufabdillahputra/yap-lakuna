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
import '../stock/stock_adjustment_reason.dart' as _il9w5f0k;

/// Dokumen penyesuaian stok (F1-08), nomor `SA-<OUTLET>-<PERANGKAT>-<yymmdd>-<nnnn>`.
/// Setiap baris berselisih membuat satu pergerakan `adjustment` di ledger.
abstract class StockAdjustment
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  StockAdjustment._({
    _isc.UuidValue? id,
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
  }) : id = id ?? const _isc.Uuid().v7obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory StockAdjustment({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue stockLocationId,
    required String number,
    required _il9w5f0k.StockAdjustmentReason reason,
    String? note,
    required int totalValue,
    required _isc.UuidValue staffId,
    required DateTime adjustedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _StockAdjustmentImpl;

  factory StockAdjustment.fromJson(Map<String, dynamic> jsonSerialization) {
    return StockAdjustment(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      stockLocationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['stockLocationId'],
      ),
      number: jsonSerialization['number'] as String,
      reason: _il9w5f0k.StockAdjustmentReason.fromJson(
        (jsonSerialization['reason'] as String),
      ),
      note: jsonSerialization['note'] as String?,
      totalValue: jsonSerialization['totalValue'] as int,
      staffId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['staffId'],
      ),
      adjustedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['adjustedAt'],
      ),
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

  static final t = StockAdjustmentTable();

  static const db = StockAdjustmentRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue outletId;

  _isc.UuidValue stockLocationId;

  String number;

  _il9w5f0k.StockAdjustmentReason reason;

  String? note;

  /// Jumlah nilai selisih (rupiah, bertanda; negatif = rugi).
  int totalValue;

  _isc.UuidValue staffId;

  DateTime adjustedAt;

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

  /// Returns a shallow copy of this [StockAdjustment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  StockAdjustment copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? stockLocationId,
    String? number,
    _il9w5f0k.StockAdjustmentReason? reason,
    String? note,
    int? totalValue,
    _isc.UuidValue? staffId,
    DateTime? adjustedAt,
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
    _isd.WhereExpressionBuilder<StockAdjustmentTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StockAdjustmentTable>? orderBy,
    _isd.OrderByListBuilder<StockAdjustmentTable>? orderByList,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StockAdjustmentImpl extends StockAdjustment {
  _StockAdjustmentImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue stockLocationId,
    required String number,
    required _il9w5f0k.StockAdjustmentReason reason,
    String? note,
    required int totalValue,
    required _isc.UuidValue staffId,
    required DateTime adjustedAt,
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
  @_isc.useResult
  @override
  StockAdjustment copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? stockLocationId,
    String? number,
    _il9w5f0k.StockAdjustmentReason? reason,
    Object? note = _Undefined,
    int? totalValue,
    _isc.UuidValue? staffId,
    DateTime? adjustedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
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

class StockAdjustmentUpdateTable
    extends _isd.UpdateTable<StockAdjustmentTable> {
  StockAdjustmentUpdateTable(super.table);

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

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> stockLocationId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.stockLocationId,
    value,
  );

  _isd.ColumnValue<String, String> number(String value) => _isd.ColumnValue(
    table.number,
    value,
  );

  _isd.ColumnValue<
    _il9w5f0k.StockAdjustmentReason,
    _il9w5f0k.StockAdjustmentReason
  >
  reason(_il9w5f0k.StockAdjustmentReason value) => _isd.ColumnValue(
    table.reason,
    value,
  );

  _isd.ColumnValue<String, String> note(String? value) => _isd.ColumnValue(
    table.note,
    value,
  );

  _isd.ColumnValue<int, int> totalValue(int value) => _isd.ColumnValue(
    table.totalValue,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> staffId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.staffId,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> adjustedAt(DateTime value) =>
      _isd.ColumnValue(
        table.adjustedAt,
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

class StockAdjustmentTable extends _isd.Table<_isc.UuidValue> {
  StockAdjustmentTable({super.tableRelation})
    : super(tableName: 'stock_adjustments') {
    updateTable = StockAdjustmentUpdateTable(this);
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
    stockLocationId = _isd.ColumnUuid(
      'stock_location_id',
      this,
      fieldName: 'stockLocationId',
    );
    number = _isd.ColumnString(
      'number',
      this,
    );
    reason = _isd.ColumnEnum(
      'reason',
      this,
      _isd.EnumSerialization.byName,
    );
    note = _isd.ColumnString(
      'note',
      this,
    );
    totalValue = _isd.ColumnInt(
      'total_value',
      this,
      fieldName: 'totalValue',
    );
    staffId = _isd.ColumnUuid(
      'staff_id',
      this,
      fieldName: 'staffId',
    );
    adjustedAt = _isd.ColumnDateTime(
      'adjusted_at',
      this,
      fieldName: 'adjustedAt',
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

  late final StockAdjustmentUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid outletId;

  late final _isd.ColumnUuid stockLocationId;

  late final _isd.ColumnString number;

  late final _isd.ColumnEnum<_il9w5f0k.StockAdjustmentReason> reason;

  late final _isd.ColumnString note;

  /// Jumlah nilai selisih (rupiah, bertanda; negatif = rugi).
  late final _isd.ColumnInt totalValue;

  late final _isd.ColumnUuid staffId;

  late final _isd.ColumnDateTime adjustedAt;

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

class StockAdjustmentInclude extends _isd.IncludeObject {
  StockAdjustmentInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => StockAdjustment.t;
}

class StockAdjustmentIncludeList extends _isd.IncludeList {
  StockAdjustmentIncludeList._({
    _isd.WhereExpressionBuilder<StockAdjustmentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StockAdjustment.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => StockAdjustment.t;
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StockAdjustmentTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StockAdjustmentTable>? orderBy,
    _isd.OrderByListBuilder<StockAdjustmentTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StockAdjustmentTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StockAdjustmentTable>? orderBy,
    _isd.OrderByListBuilder<StockAdjustmentTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StockAdjustmentTable>? where,
    int? offset,
    _isd.OrderByBuilder<StockAdjustmentTable>? orderBy,
    _isd.OrderByListBuilder<StockAdjustmentTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session,
    List<StockAdjustment> rows, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    StockAdjustment row, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<StockAdjustment> rows, {
    required _isd.ColumnSelections<StockAdjustmentTable> conflictColumns,
    _isd.ColumnSelections<StockAdjustmentTable>? updateColumns,
    _isd.WhereExpressionBuilder<StockAdjustmentTable>? updateWhere,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    StockAdjustment row, {
    required _isd.ColumnSelections<StockAdjustmentTable> conflictColumns,
    _isd.ColumnSelections<StockAdjustmentTable>? updateColumns,
    _isd.WhereExpressionBuilder<StockAdjustmentTable>? updateWhere,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<StockAdjustment> rows, {
    _isd.ColumnSelections<StockAdjustmentTable>? columns,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    StockAdjustment row, {
    _isd.ColumnSelections<StockAdjustmentTable>? columns,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<StockAdjustmentUpdateTable>
    columnValues,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<StockAdjustmentUpdateTable>
    columnValues,
    required _isd.WhereExpressionBuilder<StockAdjustmentTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StockAdjustmentTable>? orderBy,
    _isd.OrderByListBuilder<StockAdjustmentTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<StockAdjustment> rows, {
    _isd.OrderByBuilder<StockAdjustmentTable>? orderBy,
    _isd.OrderByListBuilder<StockAdjustmentTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    StockAdjustment row, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<StockAdjustmentTable> where,
    _isd.OrderByBuilder<StockAdjustmentTable>? orderBy,
    _isd.OrderByListBuilder<StockAdjustmentTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StockAdjustmentTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<StockAdjustment>(
      where: where?.call(StockAdjustment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StockAdjustment] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<StockAdjustmentTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StockAdjustment>(
      where: where(StockAdjustment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
