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
import '../sales/refund_method.dart' as _i950y1oy;
import '../sales/sale_return_reason.dart' as _ia3pakej;

/// Dokumen retur penjualan (F1-11), nomor `RT-<OUTLET>-<PERANGKAT>-<yymmdd>-<nnnn>`.
/// Nilai termasuk bagian service, PB1, dan potongan nota. Retur tunai
/// mengurangi laci sesi `cash_session_id` (tanpa `cash_movements`).
abstract class SaleReturn
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  SaleReturn._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.outletId,
    required this.deviceId,
    this.cashSessionId,
    required this.saleId,
    required this.staffId,
    required this.number,
    required this.reason,
    this.note,
    required this.refundMethod,
    required this.amount,
    required this.restock,
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

  factory SaleReturn({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    _is.UuidValue? cashSessionId,
    required _is.UuidValue saleId,
    required _is.UuidValue staffId,
    required String number,
    required _ia3pakej.SaleReturnReason reason,
    String? note,
    required _i950y1oy.RefundMethod refundMethod,
    required int amount,
    required bool restock,
    required DateTime returnedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _SaleReturnImpl;

  factory SaleReturn.fromJson(Map<String, dynamic> jsonSerialization) {
    return SaleReturn(
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
      cashSessionId: jsonSerialization['cashSessionId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['cashSessionId'],
            ),
      saleId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['saleId']),
      staffId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['staffId'],
      ),
      number: jsonSerialization['number'] as String,
      reason: _ia3pakej.SaleReturnReason.fromJson(
        (jsonSerialization['reason'] as String),
      ),
      note: jsonSerialization['note'] as String?,
      refundMethod: _i950y1oy.RefundMethod.fromJson(
        (jsonSerialization['refundMethod'] as String),
      ),
      amount: jsonSerialization['amount'] as int,
      restock: _is.BoolJsonExtension.fromJson(jsonSerialization['restock']),
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

  static final t = SaleReturnTable();

  static const db = SaleReturnRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue outletId;

  _is.UuidValue deviceId;

  _is.UuidValue? cashSessionId;

  _is.UuidValue saleId;

  _is.UuidValue staffId;

  String number;

  _ia3pakej.SaleReturnReason reason;

  String? note;

  _i950y1oy.RefundMethod refundMethod;

  int amount;

  bool restock;

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

  /// Returns a shallow copy of this [SaleReturn]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SaleReturn copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _is.UuidValue? cashSessionId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? saleId,
    _is.UuidValue? staffId,
    String? number,
    _ia3pakej.SaleReturnReason? reason,
    String? note,
    _i950y1oy.RefundMethod? refundMethod,
    int? amount,
    bool? restock,
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
      '__className__': 'SaleReturn',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      if (cashSessionId != null) 'cashSessionId': cashSessionId?.toJson(),
      'saleId': saleId.toJson(),
      'staffId': staffId.toJson(),
      'number': number,
      'reason': reason.toJson(),
      if (note != null) 'note': note,
      'refundMethod': refundMethod.toJson(),
      'amount': amount,
      'restock': restock,
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
      '__className__': 'SaleReturn',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      if (cashSessionId != null) 'cashSessionId': cashSessionId?.toJson(),
      'saleId': saleId.toJson(),
      'staffId': staffId.toJson(),
      'number': number,
      'reason': reason.toJson(),
      if (note != null) 'note': note,
      'refundMethod': refundMethod.toJson(),
      'amount': amount,
      'restock': restock,
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

  static SaleReturnInclude include() {
    return SaleReturnInclude._();
  }

  static SaleReturnIncludeList includeList({
    _is.WhereExpressionBuilder<SaleReturnTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleReturnTable>? orderBy,
    _is.OrderByListBuilder<SaleReturnTable>? orderByList,
    SaleReturnInclude? include,
  }) {
    return SaleReturnIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SaleReturn.t),
      orderByList: orderByList?.call(SaleReturn.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SaleReturnImpl extends SaleReturn {
  _SaleReturnImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    _is.UuidValue? cashSessionId,
    required _is.UuidValue saleId,
    required _is.UuidValue staffId,
    required String number,
    required _ia3pakej.SaleReturnReason reason,
    String? note,
    required _i950y1oy.RefundMethod refundMethod,
    required int amount,
    required bool restock,
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
         cashSessionId: cashSessionId,
         saleId: saleId,
         staffId: staffId,
         number: number,
         reason: reason,
         note: note,
         refundMethod: refundMethod,
         amount: amount,
         restock: restock,
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

  /// Returns a shallow copy of this [SaleReturn]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SaleReturn copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _is.UuidValue? cashSessionId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? saleId,
    _is.UuidValue? staffId,
    String? number,
    _ia3pakej.SaleReturnReason? reason,
    Object? note = _Undefined,
    _i950y1oy.RefundMethod? refundMethod,
    int? amount,
    bool? restock,
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
    return SaleReturn(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      deviceId: deviceId ?? this.deviceId,
      cashSessionId: cashSessionId is _is.UndefinedSentinel
          ? this.cashSessionId
          : cashSessionId,
      saleId: saleId ?? this.saleId,
      staffId: staffId ?? this.staffId,
      number: number ?? this.number,
      reason: reason ?? this.reason,
      note: note is String? ? note : this.note,
      refundMethod: refundMethod ?? this.refundMethod,
      amount: amount ?? this.amount,
      restock: restock ?? this.restock,
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

class SaleReturnUpdateTable extends _is.UpdateTable<SaleReturnTable> {
  SaleReturnUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> cashSessionId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.cashSessionId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> saleId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.saleId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> staffId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.staffId,
        value,
      );

  _is.ColumnValue<String, String> number(String value) => _is.ColumnValue(
    table.number,
    value,
  );

  _is.ColumnValue<_ia3pakej.SaleReturnReason, _ia3pakej.SaleReturnReason>
  reason(_ia3pakej.SaleReturnReason value) => _is.ColumnValue(
    table.reason,
    value,
  );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<_i950y1oy.RefundMethod, _i950y1oy.RefundMethod> refundMethod(
    _i950y1oy.RefundMethod value,
  ) => _is.ColumnValue(
    table.refundMethod,
    value,
  );

  _is.ColumnValue<int, int> amount(int value) => _is.ColumnValue(
    table.amount,
    value,
  );

  _is.ColumnValue<bool, bool> restock(bool value) => _is.ColumnValue(
    table.restock,
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

class SaleReturnTable extends _is.Table<_is.UuidValue> {
  SaleReturnTable({super.tableRelation}) : super(tableName: 'sale_returns') {
    updateTable = SaleReturnUpdateTable(this);
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
    cashSessionId = _is.ColumnUuid(
      'cash_session_id',
      this,
      fieldName: 'cashSessionId',
    );
    saleId = _is.ColumnUuid(
      'sale_id',
      this,
      fieldName: 'saleId',
    );
    staffId = _is.ColumnUuid(
      'staff_id',
      this,
      fieldName: 'staffId',
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
    refundMethod = _is.ColumnEnum(
      'refund_method',
      this,
      _is.EnumSerialization.byName,
      fieldName: 'refundMethod',
    );
    amount = _is.ColumnInt(
      'amount',
      this,
    );
    restock = _is.ColumnBool(
      'restock',
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

  late final SaleReturnUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid outletId;

  late final _is.ColumnUuid deviceId;

  late final _is.ColumnUuid cashSessionId;

  late final _is.ColumnUuid saleId;

  late final _is.ColumnUuid staffId;

  late final _is.ColumnString number;

  late final _is.ColumnEnum<_ia3pakej.SaleReturnReason> reason;

  late final _is.ColumnString note;

  late final _is.ColumnEnum<_i950y1oy.RefundMethod> refundMethod;

  late final _is.ColumnInt amount;

  late final _is.ColumnBool restock;

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
    cashSessionId,
    saleId,
    staffId,
    number,
    reason,
    note,
    refundMethod,
    amount,
    restock,
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

class SaleReturnInclude extends _is.IncludeObject {
  SaleReturnInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => SaleReturn.t;
}

class SaleReturnIncludeList extends _is.IncludeList {
  SaleReturnIncludeList._({
    _is.WhereExpressionBuilder<SaleReturnTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SaleReturn.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => SaleReturn.t;
}

class SaleReturnRepository {
  const SaleReturnRepository._();

  /// Returns a list of [SaleReturn]s matching the given query parameters.
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
  Future<List<SaleReturn>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleReturnTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleReturnTable>? orderBy,
    _is.OrderByListBuilder<SaleReturnTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SaleReturn>(
      where: where?.call(SaleReturn.t),
      orderBy: orderBy?.call(SaleReturn.t),
      orderByList: orderByList?.call(SaleReturn.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [SaleReturn]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `SaleReturn.t`.
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
  _ida.Stream<List<SaleReturn>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleReturnTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleReturnTable>? orderBy,
    _is.OrderByListBuilder<SaleReturnTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<SaleReturn>(
      where: where?.call(SaleReturn.t),
      orderBy: orderBy?.call(SaleReturn.t),
      orderByList: orderByList?.call(SaleReturn.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [SaleReturn] matching the given query parameters.
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
  Future<SaleReturn?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleReturnTable>? where,
    int? offset,
    _is.OrderByBuilder<SaleReturnTable>? orderBy,
    _is.OrderByListBuilder<SaleReturnTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SaleReturn>(
      where: where?.call(SaleReturn.t),
      orderBy: orderBy?.call(SaleReturn.t),
      orderByList: orderByList?.call(SaleReturn.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SaleReturn] by its [id] or null if no such row exists.
  Future<SaleReturn?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SaleReturn>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SaleReturn]s in the list and returns the inserted rows.
  ///
  /// The returned [SaleReturn]s will have their `id` fields set.
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
  Future<List<SaleReturn>> insert(
    _is.DatabaseSession session,
    List<SaleReturn> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SaleReturn>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SaleReturn] and returns the inserted row.
  ///
  /// The returned [SaleReturn] will have its `id` field set.
  Future<SaleReturn> insertRow(
    _is.DatabaseSession session,
    SaleReturn row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SaleReturn>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SaleReturn]s in the list and returns the resulting rows.
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
  /// The returned [SaleReturn]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleReturn>> upsert(
    _is.DatabaseSession session,
    List<SaleReturn> rows, {
    required _is.ColumnSelections<SaleReturnTable> conflictColumns,
    _is.ColumnSelections<SaleReturnTable>? updateColumns,
    _is.WhereExpressionBuilder<SaleReturnTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SaleReturn>(
      rows,
      conflictColumns: conflictColumns(SaleReturn.t),
      updateColumns: updateColumns?.call(SaleReturn.t),
      updateWhere: updateWhere?.call(SaleReturn.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SaleReturn] and returns the resulting row.
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
  /// The returned [SaleReturn] will have its `id` field set.
  Future<SaleReturn?> upsertRow(
    _is.DatabaseSession session,
    SaleReturn row, {
    required _is.ColumnSelections<SaleReturnTable> conflictColumns,
    _is.ColumnSelections<SaleReturnTable>? updateColumns,
    _is.WhereExpressionBuilder<SaleReturnTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SaleReturn>(
      row,
      conflictColumns: conflictColumns(SaleReturn.t),
      updateColumns: updateColumns?.call(SaleReturn.t),
      updateWhere: updateWhere?.call(SaleReturn.t),
      transaction: transaction,
    );
  }

  /// Updates all [SaleReturn]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleReturn>> update(
    _is.DatabaseSession session,
    List<SaleReturn> rows, {
    _is.ColumnSelections<SaleReturnTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SaleReturn>(
      rows,
      columns: columns?.call(SaleReturn.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SaleReturn]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SaleReturn> updateRow(
    _is.DatabaseSession session,
    SaleReturn row, {
    _is.ColumnSelections<SaleReturnTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SaleReturn>(
      row,
      columns: columns?.call(SaleReturn.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SaleReturn] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SaleReturn?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<SaleReturnUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SaleReturn>(
      id,
      columnValues: columnValues(SaleReturn.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SaleReturn]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleReturn>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SaleReturnUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SaleReturnTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleReturnTable>? orderBy,
    _is.OrderByListBuilder<SaleReturnTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SaleReturn>(
      columnValues: columnValues(SaleReturn.t.updateTable),
      where: where(SaleReturn.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SaleReturn.t),
      orderByList: orderByList?.call(SaleReturn.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SaleReturn]s in the list and returns the deleted rows.
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
  Future<List<SaleReturn>> delete(
    _is.DatabaseSession session,
    List<SaleReturn> rows, {
    _is.OrderByBuilder<SaleReturnTable>? orderBy,
    _is.OrderByListBuilder<SaleReturnTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SaleReturn>(
      rows,
      orderBy: orderBy?.call(SaleReturn.t),
      orderByList: orderByList?.call(SaleReturn.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SaleReturn].
  Future<SaleReturn> deleteRow(
    _is.DatabaseSession session,
    SaleReturn row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SaleReturn>(
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
  Future<List<SaleReturn>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SaleReturnTable> where,
    _is.OrderByBuilder<SaleReturnTable>? orderBy,
    _is.OrderByListBuilder<SaleReturnTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SaleReturn>(
      where: where(SaleReturn.t),
      orderBy: orderBy?.call(SaleReturn.t),
      orderByList: orderByList?.call(SaleReturn.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleReturnTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SaleReturn>(
      where: where?.call(SaleReturn.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SaleReturn] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SaleReturnTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SaleReturn>(
      where: where(SaleReturn.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
