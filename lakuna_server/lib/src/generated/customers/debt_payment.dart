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
import '../customers/debt_party.dart' as _i4qktbwe;
import '../purchases/funding_source.dart' as _i56sp7oc;
import '../sales/payment_method.dart' as _inpnx77f;

/// Pembayaran piutang pelanggan (F1-13, nomor `BP-…`) atau hutang supplier
/// (F1-14). Tunai di sesi kasir terbuka menulis `cash_movements` masuk dan
/// mengisi [cashSessionId]. [balanceAfter] = sisa piutang/hutang pihak itu
/// setelah pembayaran, disimpan agar kuitansi cetak ulang tidak berubah.
abstract class DebtPayment
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  DebtPayment._({
    _is.UuidValue? id,
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
    this.reference,
    this.proofMediaId,
    this.note,
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

  factory DebtPayment({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    required _is.UuidValue staffId,
    required _i4qktbwe.DebtParty party,
    _is.UuidValue? customerId,
    _is.UuidValue? supplierId,
    required String number,
    required int amount,
    _inpnx77f.PaymentMethod? method,
    _i56sp7oc.FundingSource? fundingSource,
    required DateTime paidOn,
    _is.UuidValue? cashSessionId,
    required int balanceAfter,
    String? reference,
    _is.UuidValue? proofMediaId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _DebtPaymentImpl;

  factory DebtPayment.fromJson(Map<String, dynamic> jsonSerialization) {
    return DebtPayment(
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
      staffId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['staffId'],
      ),
      party: _i4qktbwe.DebtParty.fromJson(
        (jsonSerialization['party'] as String),
      ),
      customerId: jsonSerialization['customerId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['customerId'],
            ),
      supplierId: jsonSerialization['supplierId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
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
      paidOn: _is.DateTimeJsonExtension.fromJson(jsonSerialization['paidOn']),
      cashSessionId: jsonSerialization['cashSessionId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['cashSessionId'],
            ),
      balanceAfter: jsonSerialization['balanceAfter'] as int,
      reference: jsonSerialization['reference'] as String?,
      proofMediaId: jsonSerialization['proofMediaId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['proofMediaId'],
            ),
      note: jsonSerialization['note'] as String?,
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

  static final t = DebtPaymentTable();

  static const db = DebtPaymentRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue outletId;

  _is.UuidValue deviceId;

  _is.UuidValue staffId;

  _i4qktbwe.DebtParty party;

  _is.UuidValue? customerId;

  _is.UuidValue? supplierId;

  String number;

  int amount;

  /// Metode terima piutang pelanggan.
  _inpnx77f.PaymentMethod? method;

  /// Sumber dana bayar hutang supplier (F1-14).
  _i56sp7oc.FundingSource? fundingSource;

  /// Tanggal bayar (kalender, UTC tengah malam).
  DateTime paidOn;

  _is.UuidValue? cashSessionId;

  int balanceAfter;

  /// No. bukti transfer bayar hutang (F1-14).
  String? reference;

  /// Foto bukti bayar hutang (F1-14).
  _is.UuidValue? proofMediaId;

  String? note;

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

  /// Returns a shallow copy of this [DebtPayment]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DebtPayment copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _is.UuidValue? staffId,
    _i4qktbwe.DebtParty? party,
    _is.UuidValue? customerId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? supplierId = const _is.$UndefinedUuidValue(),
    String? number,
    int? amount,
    _inpnx77f.PaymentMethod? method,
    _i56sp7oc.FundingSource? fundingSource,
    DateTime? paidOn,
    _is.UuidValue? cashSessionId = const _is.$UndefinedUuidValue(),
    int? balanceAfter,
    String? reference,
    _is.UuidValue? proofMediaId = const _is.$UndefinedUuidValue(),
    String? note,
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
      if (reference != null) 'reference': reference,
      if (proofMediaId != null) 'proofMediaId': proofMediaId?.toJson(),
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
      if (reference != null) 'reference': reference,
      if (proofMediaId != null) 'proofMediaId': proofMediaId?.toJson(),
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
    _is.WhereExpressionBuilder<DebtPaymentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DebtPaymentTable>? orderBy,
    _is.OrderByListBuilder<DebtPaymentTable>? orderByList,
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
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DebtPaymentImpl extends DebtPayment {
  _DebtPaymentImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    required _is.UuidValue staffId,
    required _i4qktbwe.DebtParty party,
    _is.UuidValue? customerId,
    _is.UuidValue? supplierId,
    required String number,
    required int amount,
    _inpnx77f.PaymentMethod? method,
    _i56sp7oc.FundingSource? fundingSource,
    required DateTime paidOn,
    _is.UuidValue? cashSessionId,
    required int balanceAfter,
    String? reference,
    _is.UuidValue? proofMediaId,
    String? note,
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
         reference: reference,
         proofMediaId: proofMediaId,
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
  @_is.useResult
  @override
  DebtPayment copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _is.UuidValue? staffId,
    _i4qktbwe.DebtParty? party,
    _is.UuidValue? customerId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? supplierId = const _is.$UndefinedUuidValue(),
    String? number,
    int? amount,
    Object? method = _Undefined,
    Object? fundingSource = _Undefined,
    DateTime? paidOn,
    _is.UuidValue? cashSessionId = const _is.$UndefinedUuidValue(),
    int? balanceAfter,
    Object? reference = _Undefined,
    _is.UuidValue? proofMediaId = const _is.$UndefinedUuidValue(),
    Object? note = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return DebtPayment(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      deviceId: deviceId ?? this.deviceId,
      staffId: staffId ?? this.staffId,
      party: party ?? this.party,
      customerId: customerId is _is.UndefinedSentinel
          ? this.customerId
          : customerId,
      supplierId: supplierId is _is.UndefinedSentinel
          ? this.supplierId
          : supplierId,
      number: number ?? this.number,
      amount: amount ?? this.amount,
      method: method is _inpnx77f.PaymentMethod? ? method : this.method,
      fundingSource: fundingSource is _i56sp7oc.FundingSource?
          ? fundingSource
          : this.fundingSource,
      paidOn: paidOn ?? this.paidOn,
      cashSessionId: cashSessionId is _is.UndefinedSentinel
          ? this.cashSessionId
          : cashSessionId,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      reference: reference is String? ? reference : this.reference,
      proofMediaId: proofMediaId is _is.UndefinedSentinel
          ? this.proofMediaId
          : proofMediaId,
      note: note is String? ? note : this.note,
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

class DebtPaymentUpdateTable extends _is.UpdateTable<DebtPaymentTable> {
  DebtPaymentUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> staffId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.staffId,
        value,
      );

  _is.ColumnValue<_i4qktbwe.DebtParty, _i4qktbwe.DebtParty> party(
    _i4qktbwe.DebtParty value,
  ) => _is.ColumnValue(
    table.party,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> customerId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.customerId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> supplierId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.supplierId,
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

  _is.ColumnValue<_inpnx77f.PaymentMethod, _inpnx77f.PaymentMethod> method(
    _inpnx77f.PaymentMethod? value,
  ) => _is.ColumnValue(
    table.method,
    value,
  );

  _is.ColumnValue<_i56sp7oc.FundingSource, _i56sp7oc.FundingSource>
  fundingSource(_i56sp7oc.FundingSource? value) => _is.ColumnValue(
    table.fundingSource,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> paidOn(DateTime value) => _is.ColumnValue(
    table.paidOn,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> cashSessionId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.cashSessionId,
    value,
  );

  _is.ColumnValue<int, int> balanceAfter(int value) => _is.ColumnValue(
    table.balanceAfter,
    value,
  );

  _is.ColumnValue<String, String> reference(String? value) => _is.ColumnValue(
    table.reference,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> proofMediaId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.proofMediaId,
    value,
  );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
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

class DebtPaymentTable extends _is.Table<_is.UuidValue> {
  DebtPaymentTable({super.tableRelation}) : super(tableName: 'debt_payments') {
    updateTable = DebtPaymentUpdateTable(this);
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
    staffId = _is.ColumnUuid(
      'staff_id',
      this,
      fieldName: 'staffId',
    );
    party = _is.ColumnEnum(
      'party',
      this,
      _is.EnumSerialization.byName,
    );
    customerId = _is.ColumnUuid(
      'customer_id',
      this,
      fieldName: 'customerId',
    );
    supplierId = _is.ColumnUuid(
      'supplier_id',
      this,
      fieldName: 'supplierId',
    );
    number = _is.ColumnString(
      'number',
      this,
    );
    amount = _is.ColumnInt(
      'amount',
      this,
    );
    method = _is.ColumnEnum(
      'method',
      this,
      _is.EnumSerialization.byName,
    );
    fundingSource = _is.ColumnEnum(
      'funding_source',
      this,
      _is.EnumSerialization.byName,
      fieldName: 'fundingSource',
    );
    paidOn = _is.ColumnDateTime(
      'paid_on',
      this,
      fieldName: 'paidOn',
    );
    cashSessionId = _is.ColumnUuid(
      'cash_session_id',
      this,
      fieldName: 'cashSessionId',
    );
    balanceAfter = _is.ColumnInt(
      'balance_after',
      this,
      fieldName: 'balanceAfter',
    );
    reference = _is.ColumnString(
      'reference',
      this,
    );
    proofMediaId = _is.ColumnUuid(
      'proof_media_id',
      this,
      fieldName: 'proofMediaId',
    );
    note = _is.ColumnString(
      'note',
      this,
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

  late final DebtPaymentUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid outletId;

  late final _is.ColumnUuid deviceId;

  late final _is.ColumnUuid staffId;

  late final _is.ColumnEnum<_i4qktbwe.DebtParty> party;

  late final _is.ColumnUuid customerId;

  late final _is.ColumnUuid supplierId;

  late final _is.ColumnString number;

  late final _is.ColumnInt amount;

  /// Metode terima piutang pelanggan.
  late final _is.ColumnEnum<_inpnx77f.PaymentMethod> method;

  /// Sumber dana bayar hutang supplier (F1-14).
  late final _is.ColumnEnum<_i56sp7oc.FundingSource> fundingSource;

  /// Tanggal bayar (kalender, UTC tengah malam).
  late final _is.ColumnDateTime paidOn;

  late final _is.ColumnUuid cashSessionId;

  late final _is.ColumnInt balanceAfter;

  /// No. bukti transfer bayar hutang (F1-14).
  late final _is.ColumnString reference;

  /// Foto bukti bayar hutang (F1-14).
  late final _is.ColumnUuid proofMediaId;

  late final _is.ColumnString note;

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
    reference,
    proofMediaId,
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

class DebtPaymentInclude extends _is.IncludeObject {
  DebtPaymentInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => DebtPayment.t;
}

class DebtPaymentIncludeList extends _is.IncludeList {
  DebtPaymentIncludeList._({
    _is.WhereExpressionBuilder<DebtPaymentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DebtPayment.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => DebtPayment.t;
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DebtPaymentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DebtPaymentTable>? orderBy,
    _is.OrderByListBuilder<DebtPaymentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DebtPaymentTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DebtPaymentTable>? orderBy,
    _is.OrderByListBuilder<DebtPaymentTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DebtPaymentTable>? where,
    int? offset,
    _is.OrderByBuilder<DebtPaymentTable>? orderBy,
    _is.OrderByListBuilder<DebtPaymentTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session,
    List<DebtPayment> rows, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    DebtPayment row, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<DebtPayment> rows, {
    required _is.ColumnSelections<DebtPaymentTable> conflictColumns,
    _is.ColumnSelections<DebtPaymentTable>? updateColumns,
    _is.WhereExpressionBuilder<DebtPaymentTable>? updateWhere,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    DebtPayment row, {
    required _is.ColumnSelections<DebtPaymentTable> conflictColumns,
    _is.ColumnSelections<DebtPaymentTable>? updateColumns,
    _is.WhereExpressionBuilder<DebtPaymentTable>? updateWhere,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<DebtPayment> rows, {
    _is.ColumnSelections<DebtPaymentTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    DebtPayment row, {
    _is.ColumnSelections<DebtPaymentTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<DebtPaymentUpdateTable> columnValues,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DebtPaymentUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<DebtPaymentTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DebtPaymentTable>? orderBy,
    _is.OrderByListBuilder<DebtPaymentTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<DebtPayment> rows, {
    _is.OrderByBuilder<DebtPaymentTable>? orderBy,
    _is.OrderByListBuilder<DebtPaymentTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    DebtPayment row, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DebtPaymentTable> where,
    _is.OrderByBuilder<DebtPaymentTable>? orderBy,
    _is.OrderByListBuilder<DebtPaymentTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DebtPaymentTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DebtPayment>(
      where: where?.call(DebtPayment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DebtPayment] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DebtPaymentTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DebtPayment>(
      where: where(DebtPayment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
