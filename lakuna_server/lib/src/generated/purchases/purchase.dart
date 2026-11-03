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
import '../purchases/purchase_status.dart' as _i7pslxk7;

/// Pembelian dari supplier (F1-12), nomor `PB-<OUTLET>-<PERANGKAT>-<yymmdd>-<nnnn>`.
/// `purchased_on` = tanggal lokal (UTC tengah malam). Hutang = total −
/// `paid_amount` − pengurang hutang retur (`purchase_returns.debt_reduction`).
abstract class Purchase
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  Purchase._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.outletId,
    required this.deviceId,
    required this.stockLocationId,
    this.supplierId,
    required this.staffId,
    this.cashSessionId,
    required this.number,
    this.invoiceNo,
    required this.status,
    required this.purchasedOn,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.total,
    required this.paidAmount,
    this.fundingSource,
    this.dueOn,
    this.note,
    this.receivedAt,
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

  factory Purchase({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    required _is.UuidValue stockLocationId,
    _is.UuidValue? supplierId,
    required _is.UuidValue staffId,
    _is.UuidValue? cashSessionId,
    required String number,
    String? invoiceNo,
    required _i7pslxk7.PurchaseStatus status,
    required DateTime purchasedOn,
    required int subtotal,
    required int discount,
    required int shipping,
    required int total,
    required int paidAmount,
    _i56sp7oc.FundingSource? fundingSource,
    DateTime? dueOn,
    String? note,
    DateTime? receivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _PurchaseImpl;

  factory Purchase.fromJson(Map<String, dynamic> jsonSerialization) {
    return Purchase(
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
      stockLocationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['stockLocationId'],
      ),
      supplierId: jsonSerialization['supplierId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['supplierId'],
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
      invoiceNo: jsonSerialization['invoiceNo'] as String?,
      status: _i7pslxk7.PurchaseStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      purchasedOn: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['purchasedOn'],
      ),
      subtotal: jsonSerialization['subtotal'] as int,
      discount: jsonSerialization['discount'] as int,
      shipping: jsonSerialization['shipping'] as int,
      total: jsonSerialization['total'] as int,
      paidAmount: jsonSerialization['paidAmount'] as int,
      fundingSource: jsonSerialization['fundingSource'] == null
          ? null
          : _i56sp7oc.FundingSource.fromJson(
              (jsonSerialization['fundingSource'] as String),
            ),
      dueOn: jsonSerialization['dueOn'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueOn']),
      note: jsonSerialization['note'] as String?,
      receivedAt: jsonSerialization['receivedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['receivedAt']),
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

  static final t = PurchaseTable();

  static const db = PurchaseRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue outletId;

  _is.UuidValue deviceId;

  _is.UuidValue stockLocationId;

  _is.UuidValue? supplierId;

  _is.UuidValue staffId;

  _is.UuidValue? cashSessionId;

  String number;

  String? invoiceNo;

  _i7pslxk7.PurchaseStatus status;

  DateTime purchasedOn;

  int subtotal;

  int discount;

  int shipping;

  int total;

  int paidAmount;

  _i56sp7oc.FundingSource? fundingSource;

  DateTime? dueOn;

  String? note;

  DateTime? receivedAt;

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

  /// Returns a shallow copy of this [Purchase]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Purchase copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _is.UuidValue? stockLocationId,
    _is.UuidValue? supplierId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? staffId,
    _is.UuidValue? cashSessionId = const _is.$UndefinedUuidValue(),
    String? number,
    String? invoiceNo,
    _i7pslxk7.PurchaseStatus? status,
    DateTime? purchasedOn,
    int? subtotal,
    int? discount,
    int? shipping,
    int? total,
    int? paidAmount,
    _i56sp7oc.FundingSource? fundingSource,
    DateTime? dueOn = const _is.$UndefinedDateTime(),
    String? note,
    DateTime? receivedAt = const _is.$UndefinedDateTime(),
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
      '__className__': 'Purchase',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      'stockLocationId': stockLocationId.toJson(),
      if (supplierId != null) 'supplierId': supplierId?.toJson(),
      'staffId': staffId.toJson(),
      if (cashSessionId != null) 'cashSessionId': cashSessionId?.toJson(),
      'number': number,
      if (invoiceNo != null) 'invoiceNo': invoiceNo,
      'status': status.toJson(),
      'purchasedOn': purchasedOn.toJson(),
      'subtotal': subtotal,
      'discount': discount,
      'shipping': shipping,
      'total': total,
      'paidAmount': paidAmount,
      if (fundingSource != null) 'fundingSource': fundingSource?.toJson(),
      if (dueOn != null) 'dueOn': dueOn?.toJson(),
      if (note != null) 'note': note,
      if (receivedAt != null) 'receivedAt': receivedAt?.toJson(),
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
      '__className__': 'Purchase',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      'stockLocationId': stockLocationId.toJson(),
      if (supplierId != null) 'supplierId': supplierId?.toJson(),
      'staffId': staffId.toJson(),
      if (cashSessionId != null) 'cashSessionId': cashSessionId?.toJson(),
      'number': number,
      if (invoiceNo != null) 'invoiceNo': invoiceNo,
      'status': status.toJson(),
      'purchasedOn': purchasedOn.toJson(),
      'subtotal': subtotal,
      'discount': discount,
      'shipping': shipping,
      'total': total,
      'paidAmount': paidAmount,
      if (fundingSource != null) 'fundingSource': fundingSource?.toJson(),
      if (dueOn != null) 'dueOn': dueOn?.toJson(),
      if (note != null) 'note': note,
      if (receivedAt != null) 'receivedAt': receivedAt?.toJson(),
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

  static PurchaseInclude include() {
    return PurchaseInclude._();
  }

  static PurchaseIncludeList includeList({
    _is.WhereExpressionBuilder<PurchaseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseTable>? orderBy,
    _is.OrderByListBuilder<PurchaseTable>? orderByList,
    PurchaseInclude? include,
  }) {
    return PurchaseIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Purchase.t),
      orderByList: orderByList?.call(Purchase.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PurchaseImpl extends Purchase {
  _PurchaseImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    required _is.UuidValue stockLocationId,
    _is.UuidValue? supplierId,
    required _is.UuidValue staffId,
    _is.UuidValue? cashSessionId,
    required String number,
    String? invoiceNo,
    required _i7pslxk7.PurchaseStatus status,
    required DateTime purchasedOn,
    required int subtotal,
    required int discount,
    required int shipping,
    required int total,
    required int paidAmount,
    _i56sp7oc.FundingSource? fundingSource,
    DateTime? dueOn,
    String? note,
    DateTime? receivedAt,
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
         stockLocationId: stockLocationId,
         supplierId: supplierId,
         staffId: staffId,
         cashSessionId: cashSessionId,
         number: number,
         invoiceNo: invoiceNo,
         status: status,
         purchasedOn: purchasedOn,
         subtotal: subtotal,
         discount: discount,
         shipping: shipping,
         total: total,
         paidAmount: paidAmount,
         fundingSource: fundingSource,
         dueOn: dueOn,
         note: note,
         receivedAt: receivedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [Purchase]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Purchase copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _is.UuidValue? stockLocationId,
    _is.UuidValue? supplierId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? staffId,
    _is.UuidValue? cashSessionId = const _is.$UndefinedUuidValue(),
    String? number,
    Object? invoiceNo = _Undefined,
    _i7pslxk7.PurchaseStatus? status,
    DateTime? purchasedOn,
    int? subtotal,
    int? discount,
    int? shipping,
    int? total,
    int? paidAmount,
    Object? fundingSource = _Undefined,
    DateTime? dueOn = const _is.$UndefinedDateTime(),
    Object? note = _Undefined,
    DateTime? receivedAt = const _is.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return Purchase(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      deviceId: deviceId ?? this.deviceId,
      stockLocationId: stockLocationId ?? this.stockLocationId,
      supplierId: supplierId is _is.UndefinedSentinel
          ? this.supplierId
          : supplierId,
      staffId: staffId ?? this.staffId,
      cashSessionId: cashSessionId is _is.UndefinedSentinel
          ? this.cashSessionId
          : cashSessionId,
      number: number ?? this.number,
      invoiceNo: invoiceNo is String? ? invoiceNo : this.invoiceNo,
      status: status ?? this.status,
      purchasedOn: purchasedOn ?? this.purchasedOn,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shipping: shipping ?? this.shipping,
      total: total ?? this.total,
      paidAmount: paidAmount ?? this.paidAmount,
      fundingSource: fundingSource is _i56sp7oc.FundingSource?
          ? fundingSource
          : this.fundingSource,
      dueOn: dueOn is _is.UndefinedSentinel ? this.dueOn : dueOn,
      note: note is String? ? note : this.note,
      receivedAt: receivedAt is _is.UndefinedSentinel
          ? this.receivedAt
          : receivedAt,
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

class PurchaseUpdateTable extends _is.UpdateTable<PurchaseTable> {
  PurchaseUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> stockLocationId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.stockLocationId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> supplierId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.supplierId,
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

  _is.ColumnValue<String, String> invoiceNo(String? value) => _is.ColumnValue(
    table.invoiceNo,
    value,
  );

  _is.ColumnValue<_i7pslxk7.PurchaseStatus, _i7pslxk7.PurchaseStatus> status(
    _i7pslxk7.PurchaseStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> purchasedOn(DateTime value) =>
      _is.ColumnValue(
        table.purchasedOn,
        value,
      );

  _is.ColumnValue<int, int> subtotal(int value) => _is.ColumnValue(
    table.subtotal,
    value,
  );

  _is.ColumnValue<int, int> discount(int value) => _is.ColumnValue(
    table.discount,
    value,
  );

  _is.ColumnValue<int, int> shipping(int value) => _is.ColumnValue(
    table.shipping,
    value,
  );

  _is.ColumnValue<int, int> total(int value) => _is.ColumnValue(
    table.total,
    value,
  );

  _is.ColumnValue<int, int> paidAmount(int value) => _is.ColumnValue(
    table.paidAmount,
    value,
  );

  _is.ColumnValue<_i56sp7oc.FundingSource, _i56sp7oc.FundingSource>
  fundingSource(_i56sp7oc.FundingSource? value) => _is.ColumnValue(
    table.fundingSource,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> dueOn(DateTime? value) => _is.ColumnValue(
    table.dueOn,
    value,
  );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> receivedAt(DateTime? value) =>
      _is.ColumnValue(
        table.receivedAt,
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

class PurchaseTable extends _is.Table<_is.UuidValue> {
  PurchaseTable({super.tableRelation}) : super(tableName: 'purchases') {
    updateTable = PurchaseUpdateTable(this);
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
    stockLocationId = _is.ColumnUuid(
      'stock_location_id',
      this,
      fieldName: 'stockLocationId',
    );
    supplierId = _is.ColumnUuid(
      'supplier_id',
      this,
      fieldName: 'supplierId',
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
    invoiceNo = _is.ColumnString(
      'invoice_no',
      this,
      fieldName: 'invoiceNo',
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    purchasedOn = _is.ColumnDateTime(
      'purchased_on',
      this,
      fieldName: 'purchasedOn',
    );
    subtotal = _is.ColumnInt(
      'subtotal',
      this,
    );
    discount = _is.ColumnInt(
      'discount',
      this,
    );
    shipping = _is.ColumnInt(
      'shipping',
      this,
    );
    total = _is.ColumnInt(
      'total',
      this,
    );
    paidAmount = _is.ColumnInt(
      'paid_amount',
      this,
      fieldName: 'paidAmount',
    );
    fundingSource = _is.ColumnEnum(
      'funding_source',
      this,
      _is.EnumSerialization.byName,
      fieldName: 'fundingSource',
    );
    dueOn = _is.ColumnDateTime(
      'due_on',
      this,
      fieldName: 'dueOn',
    );
    note = _is.ColumnString(
      'note',
      this,
    );
    receivedAt = _is.ColumnDateTime(
      'received_at',
      this,
      fieldName: 'receivedAt',
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

  late final PurchaseUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid outletId;

  late final _is.ColumnUuid deviceId;

  late final _is.ColumnUuid stockLocationId;

  late final _is.ColumnUuid supplierId;

  late final _is.ColumnUuid staffId;

  late final _is.ColumnUuid cashSessionId;

  late final _is.ColumnString number;

  late final _is.ColumnString invoiceNo;

  late final _is.ColumnEnum<_i7pslxk7.PurchaseStatus> status;

  late final _is.ColumnDateTime purchasedOn;

  late final _is.ColumnInt subtotal;

  late final _is.ColumnInt discount;

  late final _is.ColumnInt shipping;

  late final _is.ColumnInt total;

  late final _is.ColumnInt paidAmount;

  late final _is.ColumnEnum<_i56sp7oc.FundingSource> fundingSource;

  late final _is.ColumnDateTime dueOn;

  late final _is.ColumnString note;

  late final _is.ColumnDateTime receivedAt;

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
    stockLocationId,
    supplierId,
    staffId,
    cashSessionId,
    number,
    invoiceNo,
    status,
    purchasedOn,
    subtotal,
    discount,
    shipping,
    total,
    paidAmount,
    fundingSource,
    dueOn,
    note,
    receivedAt,
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

class PurchaseInclude extends _is.IncludeObject {
  PurchaseInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => Purchase.t;
}

class PurchaseIncludeList extends _is.IncludeList {
  PurchaseIncludeList._({
    _is.WhereExpressionBuilder<PurchaseTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Purchase.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => Purchase.t;
}

class PurchaseRepository {
  const PurchaseRepository._();

  /// Returns a list of [Purchase]s matching the given query parameters.
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
  Future<List<Purchase>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseTable>? orderBy,
    _is.OrderByListBuilder<PurchaseTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Purchase>(
      where: where?.call(Purchase.t),
      orderBy: orderBy?.call(Purchase.t),
      orderByList: orderByList?.call(Purchase.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Purchase]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Purchase.t`.
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
  _ida.Stream<List<Purchase>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseTable>? orderBy,
    _is.OrderByListBuilder<PurchaseTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Purchase>(
      where: where?.call(Purchase.t),
      orderBy: orderBy?.call(Purchase.t),
      orderByList: orderByList?.call(Purchase.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Purchase] matching the given query parameters.
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
  Future<Purchase?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseTable>? where,
    int? offset,
    _is.OrderByBuilder<PurchaseTable>? orderBy,
    _is.OrderByListBuilder<PurchaseTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Purchase>(
      where: where?.call(Purchase.t),
      orderBy: orderBy?.call(Purchase.t),
      orderByList: orderByList?.call(Purchase.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Purchase] by its [id] or null if no such row exists.
  Future<Purchase?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Purchase>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Purchase]s in the list and returns the inserted rows.
  ///
  /// The returned [Purchase]s will have their `id` fields set.
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
  Future<List<Purchase>> insert(
    _is.DatabaseSession session,
    List<Purchase> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Purchase>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Purchase] and returns the inserted row.
  ///
  /// The returned [Purchase] will have its `id` field set.
  Future<Purchase> insertRow(
    _is.DatabaseSession session,
    Purchase row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Purchase>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Purchase]s in the list and returns the resulting rows.
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
  /// The returned [Purchase]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Purchase>> upsert(
    _is.DatabaseSession session,
    List<Purchase> rows, {
    required _is.ColumnSelections<PurchaseTable> conflictColumns,
    _is.ColumnSelections<PurchaseTable>? updateColumns,
    _is.WhereExpressionBuilder<PurchaseTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Purchase>(
      rows,
      conflictColumns: conflictColumns(Purchase.t),
      updateColumns: updateColumns?.call(Purchase.t),
      updateWhere: updateWhere?.call(Purchase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Purchase] and returns the resulting row.
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
  /// The returned [Purchase] will have its `id` field set.
  Future<Purchase?> upsertRow(
    _is.DatabaseSession session,
    Purchase row, {
    required _is.ColumnSelections<PurchaseTable> conflictColumns,
    _is.ColumnSelections<PurchaseTable>? updateColumns,
    _is.WhereExpressionBuilder<PurchaseTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Purchase>(
      row,
      conflictColumns: conflictColumns(Purchase.t),
      updateColumns: updateColumns?.call(Purchase.t),
      updateWhere: updateWhere?.call(Purchase.t),
      transaction: transaction,
    );
  }

  /// Updates all [Purchase]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Purchase>> update(
    _is.DatabaseSession session,
    List<Purchase> rows, {
    _is.ColumnSelections<PurchaseTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Purchase>(
      rows,
      columns: columns?.call(Purchase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Purchase]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Purchase> updateRow(
    _is.DatabaseSession session,
    Purchase row, {
    _is.ColumnSelections<PurchaseTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Purchase>(
      row,
      columns: columns?.call(Purchase.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Purchase] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Purchase?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<PurchaseUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Purchase>(
      id,
      columnValues: columnValues(Purchase.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Purchase]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Purchase>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PurchaseUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PurchaseTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PurchaseTable>? orderBy,
    _is.OrderByListBuilder<PurchaseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Purchase>(
      columnValues: columnValues(Purchase.t.updateTable),
      where: where(Purchase.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Purchase.t),
      orderByList: orderByList?.call(Purchase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Purchase]s in the list and returns the deleted rows.
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
  Future<List<Purchase>> delete(
    _is.DatabaseSession session,
    List<Purchase> rows, {
    _is.OrderByBuilder<PurchaseTable>? orderBy,
    _is.OrderByListBuilder<PurchaseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Purchase>(
      rows,
      orderBy: orderBy?.call(Purchase.t),
      orderByList: orderByList?.call(Purchase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Purchase].
  Future<Purchase> deleteRow(
    _is.DatabaseSession session,
    Purchase row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Purchase>(
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
  Future<List<Purchase>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PurchaseTable> where,
    _is.OrderByBuilder<PurchaseTable>? orderBy,
    _is.OrderByListBuilder<PurchaseTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Purchase>(
      where: where(Purchase.t),
      orderBy: orderBy?.call(Purchase.t),
      orderByList: orderByList?.call(Purchase.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PurchaseTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Purchase>(
      where: where?.call(Purchase.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Purchase] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PurchaseTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Purchase>(
      where: where(Purchase.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
