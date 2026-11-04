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
import '../sales/refund_method.dart' as _i950y1oy;
import '../sales/sale_return_reason.dart' as _ia3pakej;

/// Dokumen retur penjualan (F1-11), nomor `RT-<OUTLET>-<PERANGKAT>-<yymmdd>-<nnnn>`.
/// Nilai termasuk bagian service, PB1, dan potongan nota. Retur tunai
/// mengurangi laci sesi `cash_session_id` (tanpa `cash_movements`).
abstract class SaleReturn
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  SaleReturn._({
    _isc.UuidValue? id,
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
    int? debtReduction,
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
  }) : id = id ?? const _isc.Uuid().v7obj(),
       debtReduction = debtReduction ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory SaleReturn({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue deviceId,
    _isc.UuidValue? cashSessionId,
    required _isc.UuidValue saleId,
    required _isc.UuidValue staffId,
    required String number,
    required _ia3pakej.SaleReturnReason reason,
    String? note,
    required _i950y1oy.RefundMethod refundMethod,
    required int amount,
    int? debtReduction,
    required bool restock,
    required DateTime returnedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _SaleReturnImpl;

  factory SaleReturn.fromJson(Map<String, dynamic> jsonSerialization) {
    return SaleReturn(
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
      cashSessionId: jsonSerialization['cashSessionId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['cashSessionId'],
            ),
      saleId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['saleId']),
      staffId: _isc.UuidValueJsonExtension.fromJson(
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
      debtReduction: jsonSerialization['debtReduction'] as int?,
      restock: _isc.BoolJsonExtension.fromJson(jsonSerialization['restock']),
      returnedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['returnedAt'],
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

  static final t = SaleReturnTable();

  static const db = SaleReturnRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue outletId;

  _isc.UuidValue deviceId;

  _isc.UuidValue? cashSessionId;

  _isc.UuidValue saleId;

  _isc.UuidValue staffId;

  String number;

  _ia3pakej.SaleReturnReason reason;

  String? note;

  _i950y1oy.RefundMethod refundMethod;

  int amount;

  /// Bagian [amount] yang memotong piutang nota kredit (F1-13); sisanya
  /// dikembalikan lewat [refundMethod].
  int debtReduction;

  bool restock;

  DateTime returnedAt;

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

  /// Returns a shallow copy of this [SaleReturn]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SaleReturn copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? deviceId,
    _isc.UuidValue? cashSessionId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? saleId,
    _isc.UuidValue? staffId,
    String? number,
    _ia3pakej.SaleReturnReason? reason,
    String? note,
    _i950y1oy.RefundMethod? refundMethod,
    int? amount,
    int? debtReduction,
    bool? restock,
    DateTime? returnedAt,
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
      'debtReduction': debtReduction,
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
      'debtReduction': debtReduction,
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
    _isd.WhereExpressionBuilder<SaleReturnTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleReturnTable>? orderBy,
    _isd.OrderByListBuilder<SaleReturnTable>? orderByList,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SaleReturnImpl extends SaleReturn {
  _SaleReturnImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue deviceId,
    _isc.UuidValue? cashSessionId,
    required _isc.UuidValue saleId,
    required _isc.UuidValue staffId,
    required String number,
    required _ia3pakej.SaleReturnReason reason,
    String? note,
    required _i950y1oy.RefundMethod refundMethod,
    required int amount,
    int? debtReduction,
    required bool restock,
    required DateTime returnedAt,
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
         cashSessionId: cashSessionId,
         saleId: saleId,
         staffId: staffId,
         number: number,
         reason: reason,
         note: note,
         refundMethod: refundMethod,
         amount: amount,
         debtReduction: debtReduction,
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
  @_isc.useResult
  @override
  SaleReturn copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? deviceId,
    _isc.UuidValue? cashSessionId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? saleId,
    _isc.UuidValue? staffId,
    String? number,
    _ia3pakej.SaleReturnReason? reason,
    Object? note = _Undefined,
    _i950y1oy.RefundMethod? refundMethod,
    int? amount,
    int? debtReduction,
    bool? restock,
    DateTime? returnedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return SaleReturn(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      deviceId: deviceId ?? this.deviceId,
      cashSessionId: cashSessionId is _isc.UndefinedSentinel
          ? this.cashSessionId
          : cashSessionId,
      saleId: saleId ?? this.saleId,
      staffId: staffId ?? this.staffId,
      number: number ?? this.number,
      reason: reason ?? this.reason,
      note: note is String? ? note : this.note,
      refundMethod: refundMethod ?? this.refundMethod,
      amount: amount ?? this.amount,
      debtReduction: debtReduction ?? this.debtReduction,
      restock: restock ?? this.restock,
      returnedAt: returnedAt ?? this.returnedAt,
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

class SaleReturnUpdateTable extends _isd.UpdateTable<SaleReturnTable> {
  SaleReturnUpdateTable(super.table);

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

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> cashSessionId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.cashSessionId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> saleId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.saleId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> staffId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.staffId,
    value,
  );

  _isd.ColumnValue<String, String> number(String value) => _isd.ColumnValue(
    table.number,
    value,
  );

  _isd.ColumnValue<_ia3pakej.SaleReturnReason, _ia3pakej.SaleReturnReason>
  reason(_ia3pakej.SaleReturnReason value) => _isd.ColumnValue(
    table.reason,
    value,
  );

  _isd.ColumnValue<String, String> note(String? value) => _isd.ColumnValue(
    table.note,
    value,
  );

  _isd.ColumnValue<_i950y1oy.RefundMethod, _i950y1oy.RefundMethod> refundMethod(
    _i950y1oy.RefundMethod value,
  ) => _isd.ColumnValue(
    table.refundMethod,
    value,
  );

  _isd.ColumnValue<int, int> amount(int value) => _isd.ColumnValue(
    table.amount,
    value,
  );

  _isd.ColumnValue<int, int> debtReduction(int value) => _isd.ColumnValue(
    table.debtReduction,
    value,
  );

  _isd.ColumnValue<bool, bool> restock(bool value) => _isd.ColumnValue(
    table.restock,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> returnedAt(DateTime value) =>
      _isd.ColumnValue(
        table.returnedAt,
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

class SaleReturnTable extends _isd.Table<_isc.UuidValue> {
  SaleReturnTable({super.tableRelation}) : super(tableName: 'sale_returns') {
    updateTable = SaleReturnUpdateTable(this);
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
    cashSessionId = _isd.ColumnUuid(
      'cash_session_id',
      this,
      fieldName: 'cashSessionId',
    );
    saleId = _isd.ColumnUuid(
      'sale_id',
      this,
      fieldName: 'saleId',
    );
    staffId = _isd.ColumnUuid(
      'staff_id',
      this,
      fieldName: 'staffId',
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
    refundMethod = _isd.ColumnEnum(
      'refund_method',
      this,
      _isd.EnumSerialization.byName,
      fieldName: 'refundMethod',
    );
    amount = _isd.ColumnInt(
      'amount',
      this,
    );
    debtReduction = _isd.ColumnInt(
      'debt_reduction',
      this,
      hasDefault: true,
      fieldName: 'debtReduction',
    );
    restock = _isd.ColumnBool(
      'restock',
      this,
    );
    returnedAt = _isd.ColumnDateTime(
      'returned_at',
      this,
      fieldName: 'returnedAt',
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

  late final SaleReturnUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid outletId;

  late final _isd.ColumnUuid deviceId;

  late final _isd.ColumnUuid cashSessionId;

  late final _isd.ColumnUuid saleId;

  late final _isd.ColumnUuid staffId;

  late final _isd.ColumnString number;

  late final _isd.ColumnEnum<_ia3pakej.SaleReturnReason> reason;

  late final _isd.ColumnString note;

  late final _isd.ColumnEnum<_i950y1oy.RefundMethod> refundMethod;

  late final _isd.ColumnInt amount;

  /// Bagian [amount] yang memotong piutang nota kredit (F1-13); sisanya
  /// dikembalikan lewat [refundMethod].
  late final _isd.ColumnInt debtReduction;

  late final _isd.ColumnBool restock;

  late final _isd.ColumnDateTime returnedAt;

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
    cashSessionId,
    saleId,
    staffId,
    number,
    reason,
    note,
    refundMethod,
    amount,
    debtReduction,
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

class SaleReturnInclude extends _isd.IncludeObject {
  SaleReturnInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => SaleReturn.t;
}

class SaleReturnIncludeList extends _isd.IncludeList {
  SaleReturnIncludeList._({
    _isd.WhereExpressionBuilder<SaleReturnTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SaleReturn.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => SaleReturn.t;
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleReturnTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleReturnTable>? orderBy,
    _isd.OrderByListBuilder<SaleReturnTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleReturnTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleReturnTable>? orderBy,
    _isd.OrderByListBuilder<SaleReturnTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleReturnTable>? where,
    int? offset,
    _isd.OrderByBuilder<SaleReturnTable>? orderBy,
    _isd.OrderByListBuilder<SaleReturnTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session,
    List<SaleReturn> rows, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    SaleReturn row, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<SaleReturn> rows, {
    required _isd.ColumnSelections<SaleReturnTable> conflictColumns,
    _isd.ColumnSelections<SaleReturnTable>? updateColumns,
    _isd.WhereExpressionBuilder<SaleReturnTable>? updateWhere,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    SaleReturn row, {
    required _isd.ColumnSelections<SaleReturnTable> conflictColumns,
    _isd.ColumnSelections<SaleReturnTable>? updateColumns,
    _isd.WhereExpressionBuilder<SaleReturnTable>? updateWhere,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<SaleReturn> rows, {
    _isd.ColumnSelections<SaleReturnTable>? columns,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    SaleReturn row, {
    _isd.ColumnSelections<SaleReturnTable>? columns,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<SaleReturnUpdateTable> columnValues,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<SaleReturnUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<SaleReturnTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleReturnTable>? orderBy,
    _isd.OrderByListBuilder<SaleReturnTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<SaleReturn> rows, {
    _isd.OrderByBuilder<SaleReturnTable>? orderBy,
    _isd.OrderByListBuilder<SaleReturnTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    SaleReturn row, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<SaleReturnTable> where,
    _isd.OrderByBuilder<SaleReturnTable>? orderBy,
    _isd.OrderByListBuilder<SaleReturnTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleReturnTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<SaleReturn>(
      where: where?.call(SaleReturn.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SaleReturn] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<SaleReturnTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SaleReturn>(
      where: where(SaleReturn.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
