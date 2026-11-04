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
import '../customers/debt_party.dart' as _i4qktbwe;
import '../purchases/funding_source.dart' as _i56sp7oc;
import '../sales/payment_method.dart' as _inpnx77f;

/// Pembayaran piutang pelanggan (F1-13, nomor `BP-…`) atau hutang supplier
/// (F1-14). Tunai di sesi kasir terbuka menulis `cash_movements` masuk dan
/// mengisi [cashSessionId]. [balanceAfter] = sisa piutang/hutang pihak itu
/// setelah pembayaran, disimpan agar kuitansi cetak ulang tidak berubah.
abstract class DebtPayment
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  DebtPayment._({
    _isc.UuidValue? id,
    required this.tenantId,
    required this.outletId,
    required this.deviceId,
    required this.staffId,
    required this.party,
    this.customerId,
    this.supplierId,
    required this.number,
    required this.amount,
    this.method,
    this.fundingSource,
    required this.paidOn,
    this.cashSessionId,
    required this.balanceAfter,
    this.note,
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

  factory DebtPayment({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue deviceId,
    required _isc.UuidValue staffId,
    required _i4qktbwe.DebtParty party,
    _isc.UuidValue? customerId,
    _isc.UuidValue? supplierId,
    required String number,
    required int amount,
    _inpnx77f.PaymentMethod? method,
    _i56sp7oc.FundingSource? fundingSource,
    required DateTime paidOn,
    _isc.UuidValue? cashSessionId,
    required int balanceAfter,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _DebtPaymentImpl;

  factory DebtPayment.fromJson(Map<String, dynamic> jsonSerialization) {
    return DebtPayment(
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
      party: _i4qktbwe.DebtParty.fromJson(
        (jsonSerialization['party'] as String),
      ),
      customerId: jsonSerialization['customerId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['customerId'],
            ),
      supplierId: jsonSerialization['supplierId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['supplierId'],
            ),
      number: jsonSerialization['number'] as String,
      amount: jsonSerialization['amount'] as int,
      method: jsonSerialization['method'] == null
          ? null
          : _inpnx77f.PaymentMethod.fromJson(
              (jsonSerialization['method'] as String),
            ),
      fundingSource: jsonSerialization['fundingSource'] == null
          ? null
          : _i56sp7oc.FundingSource.fromJson(
              (jsonSerialization['fundingSource'] as String),
            ),
      paidOn: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['paidOn']),
      cashSessionId: jsonSerialization['cashSessionId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['cashSessionId'],
            ),
      balanceAfter: jsonSerialization['balanceAfter'] as int,
      note: jsonSerialization['note'] as String?,
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

  static final t = DebtPaymentTable();

  static const db = DebtPaymentRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue outletId;

  _isc.UuidValue deviceId;

  _isc.UuidValue staffId;

  _i4qktbwe.DebtParty party;

  _isc.UuidValue? customerId;

  _isc.UuidValue? supplierId;

  String number;

  int amount;

  /// Metode terima piutang pelanggan.
  _inpnx77f.PaymentMethod? method;

  /// Sumber dana bayar hutang supplier (F1-14).
  _i56sp7oc.FundingSource? fundingSource;

  /// Tanggal bayar (kalender, UTC tengah malam).
  DateTime paidOn;

  _isc.UuidValue? cashSessionId;

  int balanceAfter;

  String? note;

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

  /// Returns a shallow copy of this [DebtPayment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DebtPayment copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? deviceId,
    _isc.UuidValue? staffId,
    _i4qktbwe.DebtParty? party,
    _isc.UuidValue? customerId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? supplierId = const _isc.$UndefinedUuidValue(),
    String? number,
    int? amount,
    _inpnx77f.PaymentMethod? method,
    _i56sp7oc.FundingSource? fundingSource,
    DateTime? paidOn,
    _isc.UuidValue? cashSessionId = const _isc.$UndefinedUuidValue(),
    int? balanceAfter,
    String? note,
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
      '__className__': 'DebtPayment',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      'staffId': staffId.toJson(),
      'party': party.toJson(),
      if (customerId != null) 'customerId': customerId?.toJson(),
      if (supplierId != null) 'supplierId': supplierId?.toJson(),
      'number': number,
      'amount': amount,
      if (method != null) 'method': method?.toJson(),
      if (fundingSource != null) 'fundingSource': fundingSource?.toJson(),
      'paidOn': paidOn.toJson(),
      if (cashSessionId != null) 'cashSessionId': cashSessionId?.toJson(),
      'balanceAfter': balanceAfter,
      if (note != null) 'note': note,
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
      '__className__': 'DebtPayment',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      'staffId': staffId.toJson(),
      'party': party.toJson(),
      if (customerId != null) 'customerId': customerId?.toJson(),
      if (supplierId != null) 'supplierId': supplierId?.toJson(),
      'number': number,
      'amount': amount,
      if (method != null) 'method': method?.toJson(),
      if (fundingSource != null) 'fundingSource': fundingSource?.toJson(),
      'paidOn': paidOn.toJson(),
      if (cashSessionId != null) 'cashSessionId': cashSessionId?.toJson(),
      'balanceAfter': balanceAfter,
      if (note != null) 'note': note,
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

  static DebtPaymentInclude include() {
    return DebtPaymentInclude._();
  }

  static DebtPaymentIncludeList includeList({
    _isd.WhereExpressionBuilder<DebtPaymentTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<DebtPaymentTable>? orderBy,
    _isd.OrderByListBuilder<DebtPaymentTable>? orderByList,
    DebtPaymentInclude? include,
  }) {
    return DebtPaymentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DebtPayment.t),
      orderByList: orderByList?.call(DebtPayment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DebtPaymentImpl extends DebtPayment {
  _DebtPaymentImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue deviceId,
    required _isc.UuidValue staffId,
    required _i4qktbwe.DebtParty party,
    _isc.UuidValue? customerId,
    _isc.UuidValue? supplierId,
    required String number,
    required int amount,
    _inpnx77f.PaymentMethod? method,
    _i56sp7oc.FundingSource? fundingSource,
    required DateTime paidOn,
    _isc.UuidValue? cashSessionId,
    required int balanceAfter,
    String? note,
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
         party: party,
         customerId: customerId,
         supplierId: supplierId,
         number: number,
         amount: amount,
         method: method,
         fundingSource: fundingSource,
         paidOn: paidOn,
         cashSessionId: cashSessionId,
         balanceAfter: balanceAfter,
         note: note,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [DebtPayment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DebtPayment copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? deviceId,
    _isc.UuidValue? staffId,
    _i4qktbwe.DebtParty? party,
    _isc.UuidValue? customerId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? supplierId = const _isc.$UndefinedUuidValue(),
    String? number,
    int? amount,
    Object? method = _Undefined,
    Object? fundingSource = _Undefined,
    DateTime? paidOn,
    _isc.UuidValue? cashSessionId = const _isc.$UndefinedUuidValue(),
    int? balanceAfter,
    Object? note = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return DebtPayment(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      deviceId: deviceId ?? this.deviceId,
      staffId: staffId ?? this.staffId,
      party: party ?? this.party,
      customerId: customerId is _isc.UndefinedSentinel
          ? this.customerId
          : customerId,
      supplierId: supplierId is _isc.UndefinedSentinel
          ? this.supplierId
          : supplierId,
      number: number ?? this.number,
      amount: amount ?? this.amount,
      method: method is _inpnx77f.PaymentMethod? ? method : this.method,
      fundingSource: fundingSource is _i56sp7oc.FundingSource?
          ? fundingSource
          : this.fundingSource,
      paidOn: paidOn ?? this.paidOn,
      cashSessionId: cashSessionId is _isc.UndefinedSentinel
          ? this.cashSessionId
          : cashSessionId,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      note: note is String? ? note : this.note,
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

class DebtPaymentUpdateTable extends _isd.UpdateTable<DebtPaymentTable> {
  DebtPaymentUpdateTable(super.table);

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

  _isd.ColumnValue<_i4qktbwe.DebtParty, _i4qktbwe.DebtParty> party(
    _i4qktbwe.DebtParty value,
  ) => _isd.ColumnValue(
    table.party,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> customerId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.customerId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> supplierId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.supplierId,
    value,
  );

  _isd.ColumnValue<String, String> number(String value) => _isd.ColumnValue(
    table.number,
    value,
  );

  _isd.ColumnValue<int, int> amount(int value) => _isd.ColumnValue(
    table.amount,
    value,
  );

  _isd.ColumnValue<_inpnx77f.PaymentMethod, _inpnx77f.PaymentMethod> method(
    _inpnx77f.PaymentMethod? value,
  ) => _isd.ColumnValue(
    table.method,
    value,
  );

  _isd.ColumnValue<_i56sp7oc.FundingSource, _i56sp7oc.FundingSource>
  fundingSource(_i56sp7oc.FundingSource? value) => _isd.ColumnValue(
    table.fundingSource,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> paidOn(DateTime value) =>
      _isd.ColumnValue(
        table.paidOn,
        value,
      );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> cashSessionId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.cashSessionId,
    value,
  );

  _isd.ColumnValue<int, int> balanceAfter(int value) => _isd.ColumnValue(
    table.balanceAfter,
    value,
  );

  _isd.ColumnValue<String, String> note(String? value) => _isd.ColumnValue(
    table.note,
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

class DebtPaymentTable extends _isd.Table<_isc.UuidValue> {
  DebtPaymentTable({super.tableRelation}) : super(tableName: 'debt_payments') {
    updateTable = DebtPaymentUpdateTable(this);
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
    party = _isd.ColumnEnum(
      'party',
      this,
      _isd.EnumSerialization.byName,
    );
    customerId = _isd.ColumnUuid(
      'customer_id',
      this,
      fieldName: 'customerId',
    );
    supplierId = _isd.ColumnUuid(
      'supplier_id',
      this,
      fieldName: 'supplierId',
    );
    number = _isd.ColumnString(
      'number',
      this,
    );
    amount = _isd.ColumnInt(
      'amount',
      this,
    );
    method = _isd.ColumnEnum(
      'method',
      this,
      _isd.EnumSerialization.byName,
    );
    fundingSource = _isd.ColumnEnum(
      'funding_source',
      this,
      _isd.EnumSerialization.byName,
      fieldName: 'fundingSource',
    );
    paidOn = _isd.ColumnDateTime(
      'paid_on',
      this,
      fieldName: 'paidOn',
    );
    cashSessionId = _isd.ColumnUuid(
      'cash_session_id',
      this,
      fieldName: 'cashSessionId',
    );
    balanceAfter = _isd.ColumnInt(
      'balance_after',
      this,
      fieldName: 'balanceAfter',
    );
    note = _isd.ColumnString(
      'note',
      this,
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

  late final DebtPaymentUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid outletId;

  late final _isd.ColumnUuid deviceId;

  late final _isd.ColumnUuid staffId;

  late final _isd.ColumnEnum<_i4qktbwe.DebtParty> party;

  late final _isd.ColumnUuid customerId;

  late final _isd.ColumnUuid supplierId;

  late final _isd.ColumnString number;

  late final _isd.ColumnInt amount;

  /// Metode terima piutang pelanggan.
  late final _isd.ColumnEnum<_inpnx77f.PaymentMethod> method;

  /// Sumber dana bayar hutang supplier (F1-14).
  late final _isd.ColumnEnum<_i56sp7oc.FundingSource> fundingSource;

  /// Tanggal bayar (kalender, UTC tengah malam).
  late final _isd.ColumnDateTime paidOn;

  late final _isd.ColumnUuid cashSessionId;

  late final _isd.ColumnInt balanceAfter;

  late final _isd.ColumnString note;

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
    party,
    customerId,
    supplierId,
    number,
    amount,
    method,
    fundingSource,
    paidOn,
    cashSessionId,
    balanceAfter,
    note,
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

class DebtPaymentInclude extends _isd.IncludeObject {
  DebtPaymentInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => DebtPayment.t;
}

class DebtPaymentIncludeList extends _isd.IncludeList {
  DebtPaymentIncludeList._({
    _isd.WhereExpressionBuilder<DebtPaymentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DebtPayment.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => DebtPayment.t;
}

class DebtPaymentRepository {
  const DebtPaymentRepository._();

  /// Returns a list of [DebtPayment]s matching the given query parameters.
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
  Future<List<DebtPayment>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<DebtPaymentTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<DebtPaymentTable>? orderBy,
    _isd.OrderByListBuilder<DebtPaymentTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DebtPayment>(
      where: where?.call(DebtPayment.t),
      orderBy: orderBy?.call(DebtPayment.t),
      orderByList: orderByList?.call(DebtPayment.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [DebtPayment]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `DebtPayment.t`.
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
  _ida.Stream<List<DebtPayment>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<DebtPaymentTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<DebtPaymentTable>? orderBy,
    _isd.OrderByListBuilder<DebtPaymentTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<DebtPayment>(
      where: where?.call(DebtPayment.t),
      orderBy: orderBy?.call(DebtPayment.t),
      orderByList: orderByList?.call(DebtPayment.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [DebtPayment] matching the given query parameters.
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
  Future<DebtPayment?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<DebtPaymentTable>? where,
    int? offset,
    _isd.OrderByBuilder<DebtPaymentTable>? orderBy,
    _isd.OrderByListBuilder<DebtPaymentTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DebtPayment>(
      where: where?.call(DebtPayment.t),
      orderBy: orderBy?.call(DebtPayment.t),
      orderByList: orderByList?.call(DebtPayment.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DebtPayment] by its [id] or null if no such row exists.
  Future<DebtPayment?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DebtPayment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DebtPayment]s in the list and returns the inserted rows.
  ///
  /// The returned [DebtPayment]s will have their `id` fields set.
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
  Future<List<DebtPayment>> insert(
    _isd.DatabaseSession session,
    List<DebtPayment> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DebtPayment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DebtPayment] and returns the inserted row.
  ///
  /// The returned [DebtPayment] will have its `id` field set.
  Future<DebtPayment> insertRow(
    _isd.DatabaseSession session,
    DebtPayment row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<DebtPayment>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DebtPayment]s in the list and returns the resulting rows.
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
  /// The returned [DebtPayment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DebtPayment>> upsert(
    _isd.DatabaseSession session,
    List<DebtPayment> rows, {
    required _isd.ColumnSelections<DebtPaymentTable> conflictColumns,
    _isd.ColumnSelections<DebtPaymentTable>? updateColumns,
    _isd.WhereExpressionBuilder<DebtPaymentTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DebtPayment>(
      rows,
      conflictColumns: conflictColumns(DebtPayment.t),
      updateColumns: updateColumns?.call(DebtPayment.t),
      updateWhere: updateWhere?.call(DebtPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DebtPayment] and returns the resulting row.
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
  /// The returned [DebtPayment] will have its `id` field set.
  Future<DebtPayment?> upsertRow(
    _isd.DatabaseSession session,
    DebtPayment row, {
    required _isd.ColumnSelections<DebtPaymentTable> conflictColumns,
    _isd.ColumnSelections<DebtPaymentTable>? updateColumns,
    _isd.WhereExpressionBuilder<DebtPaymentTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DebtPayment>(
      row,
      conflictColumns: conflictColumns(DebtPayment.t),
      updateColumns: updateColumns?.call(DebtPayment.t),
      updateWhere: updateWhere?.call(DebtPayment.t),
      transaction: transaction,
    );
  }

  /// Updates all [DebtPayment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DebtPayment>> update(
    _isd.DatabaseSession session,
    List<DebtPayment> rows, {
    _isd.ColumnSelections<DebtPaymentTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DebtPayment>(
      rows,
      columns: columns?.call(DebtPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DebtPayment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DebtPayment> updateRow(
    _isd.DatabaseSession session,
    DebtPayment row, {
    _isd.ColumnSelections<DebtPaymentTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<DebtPayment>(
      row,
      columns: columns?.call(DebtPayment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DebtPayment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DebtPayment?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<DebtPaymentUpdateTable> columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<DebtPayment>(
      id,
      columnValues: columnValues(DebtPayment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DebtPayment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DebtPayment>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<DebtPaymentUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<DebtPaymentTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<DebtPaymentTable>? orderBy,
    _isd.OrderByListBuilder<DebtPaymentTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DebtPayment>(
      columnValues: columnValues(DebtPayment.t.updateTable),
      where: where(DebtPayment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DebtPayment.t),
      orderByList: orderByList?.call(DebtPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DebtPayment]s in the list and returns the deleted rows.
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
  Future<List<DebtPayment>> delete(
    _isd.DatabaseSession session,
    List<DebtPayment> rows, {
    _isd.OrderByBuilder<DebtPaymentTable>? orderBy,
    _isd.OrderByListBuilder<DebtPaymentTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DebtPayment>(
      rows,
      orderBy: orderBy?.call(DebtPayment.t),
      orderByList: orderByList?.call(DebtPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DebtPayment].
  Future<DebtPayment> deleteRow(
    _isd.DatabaseSession session,
    DebtPayment row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DebtPayment>(
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
  Future<List<DebtPayment>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<DebtPaymentTable> where,
    _isd.OrderByBuilder<DebtPaymentTable>? orderBy,
    _isd.OrderByListBuilder<DebtPaymentTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DebtPayment>(
      where: where(DebtPayment.t),
      orderBy: orderBy?.call(DebtPayment.t),
      orderByList: orderByList?.call(DebtPayment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<DebtPaymentTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<DebtPayment>(
      where: where?.call(DebtPayment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DebtPayment] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<DebtPaymentTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DebtPayment>(
      where: where(DebtPayment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
