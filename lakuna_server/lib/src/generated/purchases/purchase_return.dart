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
import '../purchases/funding_source.dart' as _i56sp7oc;

/// Retur pembelian (F1-12), nomor `RB-…`. Nilai mengurangi hutang dulu
/// (`debt_reduction`); kelebihannya uang kembali (`refund_amount`) ke
/// `refund_source`. Laci menulis `cash_movements` masuk di sesi
/// `cash_session_id`.
abstract class PurchaseReturn
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  PurchaseReturn._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.outletId,
    required this.deviceId,
    required this.purchaseId,
    required this.staffId,
    this.cashSessionId,
    required this.number,
    required this.amount,
    required this.debtReduction,
    required this.refundAmount,
    this.refundSource,
    this.note,
    required this.returnedAt,
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

  factory PurchaseReturn({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    required _is.UuidValue purchaseId,
    required _is.UuidValue staffId,
    _is.UuidValue? cashSessionId,
    required String number,
    required int amount,
    required int debtReduction,
    required int refundAmount,
    _i56sp7oc.FundingSource? refundSource,
    String? note,
    required DateTime returnedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _PurchaseReturnImpl;

  factory PurchaseReturn.fromJson(Map<String, dynamic> jsonSerialization) {
    return PurchaseReturn(
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
      purchaseId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['purchaseId'],
      ),
      staffId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['staffId'],
      ),
      cashSessionId: jsonSerialization['cashSessionId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['cashSessionId'],
            ),
      number: jsonSerialization['number'] as String,
      amount: jsonSerialization['amount'] as int,
      debtReduction: jsonSerialization['debtReduction'] as int,
      refundAmount: jsonSerialization['refundAmount'] as int,
      refundSource: jsonSerialization['refundSource'] == null
          ? null
          : _i56sp7oc.FundingSource.fromJson(
              (jsonSerialization['refundSource'] as String),
            ),
      note: jsonSerialization['note'] as String?,
      returnedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['returnedAt'],
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

  static final t = PurchaseReturnTable();

  static const db = PurchaseReturnRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue outletId;

  _is.UuidValue deviceId;

  _is.UuidValue purchaseId;

  _is.UuidValue staffId;

  _is.UuidValue? cashSessionId;

  String number;

  int amount;

  int debtReduction;

  int refundAmount;

  _i56sp7oc.FundingSource? refundSource;

  String? note;

  DateTime returnedAt;

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

  /// Returns a shallow copy of this [PurchaseReturn]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PurchaseReturn copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _is.UuidValue? purchaseId,
    _is.UuidValue? staffId,
    _is.UuidValue? cashSessionId = const _is.$UndefinedUuidValue(),
    String? number,
    int? amount,
    int? debtReduction,
    int? refundAmount,
    _i56sp7oc.FundingSource? refundSource,
    String? note,
    DateTime? returnedAt,
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
      '__className__': 'PurchaseReturn',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      'purchaseId': purchaseId.toJson(),
      'staffId': staffId.toJson(),
      if (cashSessionId != null) 'cashSessionId': cashSessionId?.toJson(),
      'number': number,
      'amount': amount,
      'debtReduction': debtReduction,
      'refundAmount': refundAmount,
      if (refundSource != null) 'refundSource': refundSource?.toJson(),
      if (note != null) 'note': note,
      'returnedAt': returnedAt.toJson(),
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
      '__className__': 'PurchaseReturn',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      'purchaseId': purchaseId.toJson(),
      'staffId': staffId.toJson(),
      if (cashSessionId != null) 'cashSessionId': cashSessionId?.toJson(),
      'number': number,
      'amount': amount,
      'debtReduction': debtReduction,
      'refundAmount': refundAmount,
      if (refundSource != null) 'refundSource': refundSource?.toJson(),
      if (note != null) 'note': note,
      'returnedAt': returnedAt.toJson(),
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

  static PurchaseReturnInclude include() {
    return PurchaseReturnInclude._();
  }

  static PurchaseReturnIncludeList includeList({
    _is.WhereExpressionBuilder<PurchaseReturnTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseReturnTable>? orderBy,
    _is.OrderByListBuilder<PurchaseReturnTable>? orderByList,
    PurchaseReturnInclude? include,
  }) {
    return PurchaseReturnIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PurchaseReturn.t),
      orderByList: orderByList?.call(PurchaseReturn.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PurchaseReturnImpl extends PurchaseReturn {
  _PurchaseReturnImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    required _is.UuidValue purchaseId,
    required _is.UuidValue staffId,
    _is.UuidValue? cashSessionId,
    required String number,
    required int amount,
    required int debtReduction,
    required int refundAmount,
    _i56sp7oc.FundingSource? refundSource,
    String? note,
    required DateTime returnedAt,
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
         purchaseId: purchaseId,
         staffId: staffId,
         cashSessionId: cashSessionId,
         number: number,
         amount: amount,
         debtReduction: debtReduction,
         refundAmount: refundAmount,
         refundSource: refundSource,
         note: note,
         returnedAt: returnedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [PurchaseReturn]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PurchaseReturn copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _is.UuidValue? purchaseId,
    _is.UuidValue? staffId,
    _is.UuidValue? cashSessionId = const _is.$UndefinedUuidValue(),
    String? number,
    int? amount,
    int? debtReduction,
    int? refundAmount,
    Object? refundSource = _Undefined,
    Object? note = _Undefined,
    DateTime? returnedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return PurchaseReturn(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      deviceId: deviceId ?? this.deviceId,
      purchaseId: purchaseId ?? this.purchaseId,
      staffId: staffId ?? this.staffId,
      cashSessionId: cashSessionId is _is.UndefinedSentinel
          ? this.cashSessionId
          : cashSessionId,
      number: number ?? this.number,
      amount: amount ?? this.amount,
      debtReduction: debtReduction ?? this.debtReduction,
      refundAmount: refundAmount ?? this.refundAmount,
      refundSource: refundSource is _i56sp7oc.FundingSource?
          ? refundSource
          : this.refundSource,
      note: note is String? ? note : this.note,
      returnedAt: returnedAt ?? this.returnedAt,
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

class PurchaseReturnUpdateTable extends _is.UpdateTable<PurchaseReturnTable> {
  PurchaseReturnUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> purchaseId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.purchaseId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> staffId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.staffId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> cashSessionId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.cashSessionId,
    value,
  );

  _is.ColumnValue<String, String> number(String value) => _is.ColumnValue(
    table.number,
    value,
  );

  _is.ColumnValue<int, int> amount(int value) => _is.ColumnValue(
    table.amount,
    value,
  );

  _is.ColumnValue<int, int> debtReduction(int value) => _is.ColumnValue(
    table.debtReduction,
    value,
  );

  _is.ColumnValue<int, int> refundAmount(int value) => _is.ColumnValue(
    table.refundAmount,
    value,
  );

  _is.ColumnValue<_i56sp7oc.FundingSource, _i56sp7oc.FundingSource>
  refundSource(_i56sp7oc.FundingSource? value) => _is.ColumnValue(
    table.refundSource,
    value,
  );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> returnedAt(DateTime value) =>
      _is.ColumnValue(
        table.returnedAt,
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

class PurchaseReturnTable extends _is.Table<_is.UuidValue> {
  PurchaseReturnTable({super.tableRelation})
    : super(tableName: 'purchase_returns') {
    updateTable = PurchaseReturnUpdateTable(this);
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
    purchaseId = _is.ColumnUuid(
      'purchase_id',
      this,
      fieldName: 'purchaseId',
    );
    staffId = _is.ColumnUuid(
      'staff_id',
      this,
      fieldName: 'staffId',
    );
    cashSessionId = _is.ColumnUuid(
      'cash_session_id',
      this,
      fieldName: 'cashSessionId',
    );
    number = _is.ColumnString(
      'number',
      this,
    );
    amount = _is.ColumnInt(
      'amount',
      this,
    );
    debtReduction = _is.ColumnInt(
      'debt_reduction',
      this,
      fieldName: 'debtReduction',
    );
    refundAmount = _is.ColumnInt(
      'refund_amount',
      this,
      fieldName: 'refundAmount',
    );
    refundSource = _is.ColumnEnum(
      'refund_source',
      this,
      _is.EnumSerialization.byName,
      fieldName: 'refundSource',
    );
    note = _is.ColumnString(
      'note',
      this,
    );
    returnedAt = _is.ColumnDateTime(
      'returned_at',
      this,
      fieldName: 'returnedAt',
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

  late final PurchaseReturnUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid outletId;

  late final _is.ColumnUuid deviceId;

  late final _is.ColumnUuid purchaseId;

  late final _is.ColumnUuid staffId;

  late final _is.ColumnUuid cashSessionId;

  late final _is.ColumnString number;

  late final _is.ColumnInt amount;

  late final _is.ColumnInt debtReduction;

  late final _is.ColumnInt refundAmount;

  late final _is.ColumnEnum<_i56sp7oc.FundingSource> refundSource;

  late final _is.ColumnString note;

  late final _is.ColumnDateTime returnedAt;

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
    purchaseId,
    staffId,
    cashSessionId,
    number,
    amount,
    debtReduction,
    refundAmount,
    refundSource,
    note,
    returnedAt,
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

class PurchaseReturnInclude extends _is.IncludeObject {
  PurchaseReturnInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => PurchaseReturn.t;
}

class PurchaseReturnIncludeList extends _is.IncludeList {
  PurchaseReturnIncludeList._({
    _is.WhereExpressionBuilder<PurchaseReturnTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PurchaseReturn.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => PurchaseReturn.t;
}

class PurchaseReturnRepository {
  const PurchaseReturnRepository._();

  /// Returns a list of [PurchaseReturn]s matching the given query parameters.
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
  Future<List<PurchaseReturn>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseReturnTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseReturnTable>? orderBy,
    _is.OrderByListBuilder<PurchaseReturnTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<PurchaseReturn>(
      where: where?.call(PurchaseReturn.t),
      orderBy: orderBy?.call(PurchaseReturn.t),
      orderByList: orderByList?.call(PurchaseReturn.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [PurchaseReturn]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `PurchaseReturn.t`.
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
  _ida.Stream<List<PurchaseReturn>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseReturnTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseReturnTable>? orderBy,
    _is.OrderByListBuilder<PurchaseReturnTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<PurchaseReturn>(
      where: where?.call(PurchaseReturn.t),
      orderBy: orderBy?.call(PurchaseReturn.t),
      orderByList: orderByList?.call(PurchaseReturn.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [PurchaseReturn] matching the given query parameters.
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
  Future<PurchaseReturn?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseReturnTable>? where,
    int? offset,
    _is.OrderByBuilder<PurchaseReturnTable>? orderBy,
    _is.OrderByListBuilder<PurchaseReturnTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<PurchaseReturn>(
      where: where?.call(PurchaseReturn.t),
      orderBy: orderBy?.call(PurchaseReturn.t),
      orderByList: orderByList?.call(PurchaseReturn.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [PurchaseReturn] by its [id] or null if no such row exists.
  Future<PurchaseReturn?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<PurchaseReturn>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [PurchaseReturn]s in the list and returns the inserted rows.
  ///
  /// The returned [PurchaseReturn]s will have their `id` fields set.
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
  Future<List<PurchaseReturn>> insert(
    _is.DatabaseSession session,
    List<PurchaseReturn> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<PurchaseReturn>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [PurchaseReturn] and returns the inserted row.
  ///
  /// The returned [PurchaseReturn] will have its `id` field set.
  Future<PurchaseReturn> insertRow(
    _is.DatabaseSession session,
    PurchaseReturn row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<PurchaseReturn>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [PurchaseReturn]s in the list and returns the resulting rows.
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
  /// The returned [PurchaseReturn]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PurchaseReturn>> upsert(
    _is.DatabaseSession session,
    List<PurchaseReturn> rows, {
    required _is.ColumnSelections<PurchaseReturnTable> conflictColumns,
    _is.ColumnSelections<PurchaseReturnTable>? updateColumns,
    _is.WhereExpressionBuilder<PurchaseReturnTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<PurchaseReturn>(
      rows,
      conflictColumns: conflictColumns(PurchaseReturn.t),
      updateColumns: updateColumns?.call(PurchaseReturn.t),
      updateWhere: updateWhere?.call(PurchaseReturn.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [PurchaseReturn] and returns the resulting row.
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
  /// The returned [PurchaseReturn] will have its `id` field set.
  Future<PurchaseReturn?> upsertRow(
    _is.DatabaseSession session,
    PurchaseReturn row, {
    required _is.ColumnSelections<PurchaseReturnTable> conflictColumns,
    _is.ColumnSelections<PurchaseReturnTable>? updateColumns,
    _is.WhereExpressionBuilder<PurchaseReturnTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<PurchaseReturn>(
      row,
      conflictColumns: conflictColumns(PurchaseReturn.t),
      updateColumns: updateColumns?.call(PurchaseReturn.t),
      updateWhere: updateWhere?.call(PurchaseReturn.t),
      transaction: transaction,
    );
  }

  /// Updates all [PurchaseReturn]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PurchaseReturn>> update(
    _is.DatabaseSession session,
    List<PurchaseReturn> rows, {
    _is.ColumnSelections<PurchaseReturnTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<PurchaseReturn>(
      rows,
      columns: columns?.call(PurchaseReturn.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [PurchaseReturn]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PurchaseReturn> updateRow(
    _is.DatabaseSession session,
    PurchaseReturn row, {
    _is.ColumnSelections<PurchaseReturnTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<PurchaseReturn>(
      row,
      columns: columns?.call(PurchaseReturn.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PurchaseReturn] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PurchaseReturn?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<PurchaseReturnUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<PurchaseReturn>(
      id,
      columnValues: columnValues(PurchaseReturn.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PurchaseReturn]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<PurchaseReturn>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PurchaseReturnUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PurchaseReturnTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseReturnTable>? orderBy,
    _is.OrderByListBuilder<PurchaseReturnTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<PurchaseReturn>(
      columnValues: columnValues(PurchaseReturn.t.updateTable),
      where: where(PurchaseReturn.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PurchaseReturn.t),
      orderByList: orderByList?.call(PurchaseReturn.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [PurchaseReturn]s in the list and returns the deleted rows.
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
  Future<List<PurchaseReturn>> delete(
    _is.DatabaseSession session,
    List<PurchaseReturn> rows, {
    _is.OrderByBuilder<PurchaseReturnTable>? orderBy,
    _is.OrderByListBuilder<PurchaseReturnTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<PurchaseReturn>(
      rows,
      orderBy: orderBy?.call(PurchaseReturn.t),
      orderByList: orderByList?.call(PurchaseReturn.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [PurchaseReturn].
  Future<PurchaseReturn> deleteRow(
    _is.DatabaseSession session,
    PurchaseReturn row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PurchaseReturn>(
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
  Future<List<PurchaseReturn>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PurchaseReturnTable> where,
    _is.OrderByBuilder<PurchaseReturnTable>? orderBy,
    _is.OrderByListBuilder<PurchaseReturnTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<PurchaseReturn>(
      where: where(PurchaseReturn.t),
      orderBy: orderBy?.call(PurchaseReturn.t),
      orderByList: orderByList?.call(PurchaseReturn.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseReturnTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<PurchaseReturn>(
      where: where?.call(PurchaseReturn.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [PurchaseReturn] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PurchaseReturnTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<PurchaseReturn>(
      where: where(PurchaseReturn.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
