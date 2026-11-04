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
import '../purchases/funding_source.dart' as _i56sp7oc;

/// Pengeluaran operasional (F1-15), nomor `EX-…`. Dari kas laci menulis
/// `cash_movements` keluar di sesi kasir terbuka ([cashSessionId],
/// [cashMovementId]). Koreksi = batal ([voidedAt]) lalu catat baru.
abstract class Expense
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  Expense._({
    _isc.UuidValue? id,
    required this.tenantId,
    required this.outletId,
    required this.deviceId,
    required this.staffId,
    required this.expenseCategoryId,
    required this.number,
    required this.spentOn,
    required this.description,
    required this.amount,
    required this.fundingSource,
    this.cashSessionId,
    this.cashMovementId,
    this.receiptMediaId,
    this.voidedAt,
    this.voidedBy,
    this.voidReason,
    this.voidCashMovementId,
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

  factory Expense({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue deviceId,
    required _isc.UuidValue staffId,
    required _isc.UuidValue expenseCategoryId,
    required String number,
    required DateTime spentOn,
    required String description,
    required int amount,
    required _i56sp7oc.FundingSource fundingSource,
    _isc.UuidValue? cashSessionId,
    _isc.UuidValue? cashMovementId,
    _isc.UuidValue? receiptMediaId,
    DateTime? voidedAt,
    _isc.UuidValue? voidedBy,
    String? voidReason,
    _isc.UuidValue? voidCashMovementId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _ExpenseImpl;

  factory Expense.fromJson(Map<String, dynamic> jsonSerialization) {
    return Expense(
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
      staffId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['staffId'],
      ),
      expenseCategoryId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['expenseCategoryId'],
      ),
      number: jsonSerialization['number'] as String,
      spentOn: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['spentOn'],
      ),
      description: jsonSerialization['description'] as String,
      amount: jsonSerialization['amount'] as int,
      fundingSource: _i56sp7oc.FundingSource.fromJson(
        (jsonSerialization['fundingSource'] as String),
      ),
      cashSessionId: jsonSerialization['cashSessionId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['cashSessionId'],
            ),
      cashMovementId: jsonSerialization['cashMovementId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['cashMovementId'],
            ),
      receiptMediaId: jsonSerialization['receiptMediaId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['receiptMediaId'],
            ),
      voidedAt: jsonSerialization['voidedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['voidedAt']),
      voidedBy: jsonSerialization['voidedBy'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['voidedBy']),
      voidReason: jsonSerialization['voidReason'] as String?,
      voidCashMovementId: jsonSerialization['voidCashMovementId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['voidCashMovementId'],
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

  static final t = ExpenseTable();

  static const db = ExpenseRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue outletId;

  _isc.UuidValue deviceId;

  _isc.UuidValue staffId;

  _isc.UuidValue expenseCategoryId;

  String number;

  /// Tanggal pengeluaran (kalender, UTC tengah malam).
  DateTime spentOn;

  String description;

  int amount;

  _i56sp7oc.FundingSource fundingSource;

  _isc.UuidValue? cashSessionId;

  _isc.UuidValue? cashMovementId;

  /// Foto nota.
  _isc.UuidValue? receiptMediaId;

  DateTime? voidedAt;

  _isc.UuidValue? voidedBy;

  String? voidReason;

  /// Gerakan kas pengembalian ke laci saat batal.
  _isc.UuidValue? voidCashMovementId;

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

  /// Returns a shallow copy of this [Expense]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Expense copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? deviceId,
    _isc.UuidValue? staffId,
    _isc.UuidValue? expenseCategoryId,
    String? number,
    DateTime? spentOn,
    String? description,
    int? amount,
    _i56sp7oc.FundingSource? fundingSource,
    _isc.UuidValue? cashSessionId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? cashMovementId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? receiptMediaId = const _isc.$UndefinedUuidValue(),
    DateTime? voidedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? voidedBy = const _isc.$UndefinedUuidValue(),
    String? voidReason,
    _isc.UuidValue? voidCashMovementId = const _isc.$UndefinedUuidValue(),
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
      '__className__': 'Expense',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      'staffId': staffId.toJson(),
      'expenseCategoryId': expenseCategoryId.toJson(),
      'number': number,
      'spentOn': spentOn.toJson(),
      'description': description,
      'amount': amount,
      'fundingSource': fundingSource.toJson(),
      if (cashSessionId != null) 'cashSessionId': cashSessionId?.toJson(),
      if (cashMovementId != null) 'cashMovementId': cashMovementId?.toJson(),
      if (receiptMediaId != null) 'receiptMediaId': receiptMediaId?.toJson(),
      if (voidedAt != null) 'voidedAt': voidedAt?.toJson(),
      if (voidedBy != null) 'voidedBy': voidedBy?.toJson(),
      if (voidReason != null) 'voidReason': voidReason,
      if (voidCashMovementId != null)
        'voidCashMovementId': voidCashMovementId?.toJson(),
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
      '__className__': 'Expense',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      'staffId': staffId.toJson(),
      'expenseCategoryId': expenseCategoryId.toJson(),
      'number': number,
      'spentOn': spentOn.toJson(),
      'description': description,
      'amount': amount,
      'fundingSource': fundingSource.toJson(),
      if (cashSessionId != null) 'cashSessionId': cashSessionId?.toJson(),
      if (cashMovementId != null) 'cashMovementId': cashMovementId?.toJson(),
      if (receiptMediaId != null) 'receiptMediaId': receiptMediaId?.toJson(),
      if (voidedAt != null) 'voidedAt': voidedAt?.toJson(),
      if (voidedBy != null) 'voidedBy': voidedBy?.toJson(),
      if (voidReason != null) 'voidReason': voidReason,
      if (voidCashMovementId != null)
        'voidCashMovementId': voidCashMovementId?.toJson(),
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

  static ExpenseInclude include() {
    return ExpenseInclude._();
  }

  static ExpenseIncludeList includeList({
    _isd.WhereExpressionBuilder<ExpenseTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ExpenseTable>? orderBy,
    _isd.OrderByListBuilder<ExpenseTable>? orderByList,
    ExpenseInclude? include,
  }) {
    return ExpenseIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Expense.t),
      orderByList: orderByList?.call(Expense.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ExpenseImpl extends Expense {
  _ExpenseImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue deviceId,
    required _isc.UuidValue staffId,
    required _isc.UuidValue expenseCategoryId,
    required String number,
    required DateTime spentOn,
    required String description,
    required int amount,
    required _i56sp7oc.FundingSource fundingSource,
    _isc.UuidValue? cashSessionId,
    _isc.UuidValue? cashMovementId,
    _isc.UuidValue? receiptMediaId,
    DateTime? voidedAt,
    _isc.UuidValue? voidedBy,
    String? voidReason,
    _isc.UuidValue? voidCashMovementId,
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
         staffId: staffId,
         expenseCategoryId: expenseCategoryId,
         number: number,
         spentOn: spentOn,
         description: description,
         amount: amount,
         fundingSource: fundingSource,
         cashSessionId: cashSessionId,
         cashMovementId: cashMovementId,
         receiptMediaId: receiptMediaId,
         voidedAt: voidedAt,
         voidedBy: voidedBy,
         voidReason: voidReason,
         voidCashMovementId: voidCashMovementId,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [Expense]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Expense copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? deviceId,
    _isc.UuidValue? staffId,
    _isc.UuidValue? expenseCategoryId,
    String? number,
    DateTime? spentOn,
    String? description,
    int? amount,
    _i56sp7oc.FundingSource? fundingSource,
    _isc.UuidValue? cashSessionId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? cashMovementId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? receiptMediaId = const _isc.$UndefinedUuidValue(),
    DateTime? voidedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? voidedBy = const _isc.$UndefinedUuidValue(),
    Object? voidReason = _Undefined,
    _isc.UuidValue? voidCashMovementId = const _isc.$UndefinedUuidValue(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return Expense(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      deviceId: deviceId ?? this.deviceId,
      staffId: staffId ?? this.staffId,
      expenseCategoryId: expenseCategoryId ?? this.expenseCategoryId,
      number: number ?? this.number,
      spentOn: spentOn ?? this.spentOn,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      fundingSource: fundingSource ?? this.fundingSource,
      cashSessionId: cashSessionId is _isc.UndefinedSentinel
          ? this.cashSessionId
          : cashSessionId,
      cashMovementId: cashMovementId is _isc.UndefinedSentinel
          ? this.cashMovementId
          : cashMovementId,
      receiptMediaId: receiptMediaId is _isc.UndefinedSentinel
          ? this.receiptMediaId
          : receiptMediaId,
      voidedAt: voidedAt is _isc.UndefinedSentinel ? this.voidedAt : voidedAt,
      voidedBy: voidedBy is _isc.UndefinedSentinel ? this.voidedBy : voidedBy,
      voidReason: voidReason is String? ? voidReason : this.voidReason,
      voidCashMovementId: voidCashMovementId is _isc.UndefinedSentinel
          ? this.voidCashMovementId
          : voidCashMovementId,
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

class ExpenseUpdateTable extends _isd.UpdateTable<ExpenseTable> {
  ExpenseUpdateTable(super.table);

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

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> staffId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.staffId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> expenseCategoryId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.expenseCategoryId,
    value,
  );

  _isd.ColumnValue<String, String> number(String value) => _isd.ColumnValue(
    table.number,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> spentOn(DateTime value) =>
      _isd.ColumnValue(
        table.spentOn,
        value,
      );

  _isd.ColumnValue<String, String> description(String value) =>
      _isd.ColumnValue(
        table.description,
        value,
      );

  _isd.ColumnValue<int, int> amount(int value) => _isd.ColumnValue(
    table.amount,
    value,
  );

  _isd.ColumnValue<_i56sp7oc.FundingSource, _i56sp7oc.FundingSource>
  fundingSource(_i56sp7oc.FundingSource value) => _isd.ColumnValue(
    table.fundingSource,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> cashSessionId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.cashSessionId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> cashMovementId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.cashMovementId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> receiptMediaId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.receiptMediaId,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> voidedAt(DateTime? value) =>
      _isd.ColumnValue(
        table.voidedAt,
        value,
      );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> voidedBy(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.voidedBy,
    value,
  );

  _isd.ColumnValue<String, String> voidReason(String? value) =>
      _isd.ColumnValue(
        table.voidReason,
        value,
      );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> voidCashMovementId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.voidCashMovementId,
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

class ExpenseTable extends _isd.Table<_isc.UuidValue> {
  ExpenseTable({super.tableRelation}) : super(tableName: 'expenses') {
    updateTable = ExpenseUpdateTable(this);
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
    staffId = _isd.ColumnUuid(
      'staff_id',
      this,
      fieldName: 'staffId',
    );
    expenseCategoryId = _isd.ColumnUuid(
      'expense_category_id',
      this,
      fieldName: 'expenseCategoryId',
    );
    number = _isd.ColumnString(
      'number',
      this,
    );
    spentOn = _isd.ColumnDateTime(
      'spent_on',
      this,
      fieldName: 'spentOn',
    );
    description = _isd.ColumnString(
      'description',
      this,
    );
    amount = _isd.ColumnInt(
      'amount',
      this,
    );
    fundingSource = _isd.ColumnEnum(
      'funding_source',
      this,
      _isd.EnumSerialization.byName,
      fieldName: 'fundingSource',
    );
    cashSessionId = _isd.ColumnUuid(
      'cash_session_id',
      this,
      fieldName: 'cashSessionId',
    );
    cashMovementId = _isd.ColumnUuid(
      'cash_movement_id',
      this,
      fieldName: 'cashMovementId',
    );
    receiptMediaId = _isd.ColumnUuid(
      'receipt_media_id',
      this,
      fieldName: 'receiptMediaId',
    );
    voidedAt = _isd.ColumnDateTime(
      'voided_at',
      this,
      fieldName: 'voidedAt',
    );
    voidedBy = _isd.ColumnUuid(
      'voided_by',
      this,
      fieldName: 'voidedBy',
    );
    voidReason = _isd.ColumnString(
      'void_reason',
      this,
      fieldName: 'voidReason',
    );
    voidCashMovementId = _isd.ColumnUuid(
      'void_cash_movement_id',
      this,
      fieldName: 'voidCashMovementId',
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

  late final ExpenseUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid outletId;

  late final _isd.ColumnUuid deviceId;

  late final _isd.ColumnUuid staffId;

  late final _isd.ColumnUuid expenseCategoryId;

  late final _isd.ColumnString number;

  /// Tanggal pengeluaran (kalender, UTC tengah malam).
  late final _isd.ColumnDateTime spentOn;

  late final _isd.ColumnString description;

  late final _isd.ColumnInt amount;

  late final _isd.ColumnEnum<_i56sp7oc.FundingSource> fundingSource;

  late final _isd.ColumnUuid cashSessionId;

  late final _isd.ColumnUuid cashMovementId;

  /// Foto nota.
  late final _isd.ColumnUuid receiptMediaId;

  late final _isd.ColumnDateTime voidedAt;

  late final _isd.ColumnUuid voidedBy;

  late final _isd.ColumnString voidReason;

  /// Gerakan kas pengembalian ke laci saat batal.
  late final _isd.ColumnUuid voidCashMovementId;

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
    staffId,
    expenseCategoryId,
    number,
    spentOn,
    description,
    amount,
    fundingSource,
    cashSessionId,
    cashMovementId,
    receiptMediaId,
    voidedAt,
    voidedBy,
    voidReason,
    voidCashMovementId,
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

class ExpenseInclude extends _isd.IncludeObject {
  ExpenseInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => Expense.t;
}

class ExpenseIncludeList extends _isd.IncludeList {
  ExpenseIncludeList._({
    _isd.WhereExpressionBuilder<ExpenseTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Expense.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => Expense.t;
}

class ExpenseRepository {
  const ExpenseRepository._();

  /// Returns a list of [Expense]s matching the given query parameters.
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
  Future<List<Expense>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ExpenseTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ExpenseTable>? orderBy,
    _isd.OrderByListBuilder<ExpenseTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Expense>(
      where: where?.call(Expense.t),
      orderBy: orderBy?.call(Expense.t),
      orderByList: orderByList?.call(Expense.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Expense]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Expense.t`.
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
  _ida.Stream<List<Expense>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ExpenseTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ExpenseTable>? orderBy,
    _isd.OrderByListBuilder<ExpenseTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Expense>(
      where: where?.call(Expense.t),
      orderBy: orderBy?.call(Expense.t),
      orderByList: orderByList?.call(Expense.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Expense] matching the given query parameters.
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
  Future<Expense?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ExpenseTable>? where,
    int? offset,
    _isd.OrderByBuilder<ExpenseTable>? orderBy,
    _isd.OrderByListBuilder<ExpenseTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Expense>(
      where: where?.call(Expense.t),
      orderBy: orderBy?.call(Expense.t),
      orderByList: orderByList?.call(Expense.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Expense] by its [id] or null if no such row exists.
  Future<Expense?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Expense>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Expense]s in the list and returns the inserted rows.
  ///
  /// The returned [Expense]s will have their `id` fields set.
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
  Future<List<Expense>> insert(
    _isd.DatabaseSession session,
    List<Expense> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Expense>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Expense] and returns the inserted row.
  ///
  /// The returned [Expense] will have its `id` field set.
  Future<Expense> insertRow(
    _isd.DatabaseSession session,
    Expense row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<Expense>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Expense]s in the list and returns the resulting rows.
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
  /// The returned [Expense]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Expense>> upsert(
    _isd.DatabaseSession session,
    List<Expense> rows, {
    required _isd.ColumnSelections<ExpenseTable> conflictColumns,
    _isd.ColumnSelections<ExpenseTable>? updateColumns,
    _isd.WhereExpressionBuilder<ExpenseTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Expense>(
      rows,
      conflictColumns: conflictColumns(Expense.t),
      updateColumns: updateColumns?.call(Expense.t),
      updateWhere: updateWhere?.call(Expense.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Expense] and returns the resulting row.
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
  /// The returned [Expense] will have its `id` field set.
  Future<Expense?> upsertRow(
    _isd.DatabaseSession session,
    Expense row, {
    required _isd.ColumnSelections<ExpenseTable> conflictColumns,
    _isd.ColumnSelections<ExpenseTable>? updateColumns,
    _isd.WhereExpressionBuilder<ExpenseTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Expense>(
      row,
      conflictColumns: conflictColumns(Expense.t),
      updateColumns: updateColumns?.call(Expense.t),
      updateWhere: updateWhere?.call(Expense.t),
      transaction: transaction,
    );
  }

  /// Updates all [Expense]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Expense>> update(
    _isd.DatabaseSession session,
    List<Expense> rows, {
    _isd.ColumnSelections<ExpenseTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Expense>(
      rows,
      columns: columns?.call(Expense.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Expense]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Expense> updateRow(
    _isd.DatabaseSession session,
    Expense row, {
    _isd.ColumnSelections<ExpenseTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<Expense>(
      row,
      columns: columns?.call(Expense.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Expense] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Expense?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<ExpenseUpdateTable> columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<Expense>(
      id,
      columnValues: columnValues(Expense.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Expense]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Expense>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<ExpenseUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<ExpenseTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ExpenseTable>? orderBy,
    _isd.OrderByListBuilder<ExpenseTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Expense>(
      columnValues: columnValues(Expense.t.updateTable),
      where: where(Expense.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Expense.t),
      orderByList: orderByList?.call(Expense.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Expense]s in the list and returns the deleted rows.
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
  Future<List<Expense>> delete(
    _isd.DatabaseSession session,
    List<Expense> rows, {
    _isd.OrderByBuilder<ExpenseTable>? orderBy,
    _isd.OrderByListBuilder<ExpenseTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Expense>(
      rows,
      orderBy: orderBy?.call(Expense.t),
      orderByList: orderByList?.call(Expense.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Expense].
  Future<Expense> deleteRow(
    _isd.DatabaseSession session,
    Expense row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Expense>(
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
  Future<List<Expense>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<ExpenseTable> where,
    _isd.OrderByBuilder<ExpenseTable>? orderBy,
    _isd.OrderByListBuilder<ExpenseTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Expense>(
      where: where(Expense.t),
      orderBy: orderBy?.call(Expense.t),
      orderByList: orderByList?.call(Expense.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ExpenseTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<Expense>(
      where: where?.call(Expense.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Expense] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<ExpenseTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Expense>(
      where: where(Expense.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
