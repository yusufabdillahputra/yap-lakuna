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
import '../purchases/purchase_status.dart' as _i7pslxk7;

/// Pembelian dari supplier (F1-12), nomor `PB-<OUTLET>-<PERANGKAT>-<yymmdd>-<nnnn>`.
/// `purchased_on` = tanggal lokal (UTC tengah malam). Hutang = total −
/// `paid_amount` − pengurang hutang retur (`purchase_returns.debt_reduction`).
/// Foto faktur supplier di `invoice_media_id` (F1-12b).
abstract class Purchase
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  Purchase._({
    _isc.UuidValue? id,
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
    this.invoiceMediaId,
    this.receivedAt,
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

  factory Purchase({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue deviceId,
    required _isc.UuidValue stockLocationId,
    _isc.UuidValue? supplierId,
    required _isc.UuidValue staffId,
    _isc.UuidValue? cashSessionId,
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
    _isc.UuidValue? invoiceMediaId,
    DateTime? receivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _PurchaseImpl;

  factory Purchase.fromJson(Map<String, dynamic> jsonSerialization) {
    return Purchase(
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
      stockLocationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['stockLocationId'],
      ),
      supplierId: jsonSerialization['supplierId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['supplierId'],
            ),
      staffId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['staffId'],
      ),
      cashSessionId: jsonSerialization['cashSessionId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['cashSessionId'],
            ),
      number: jsonSerialization['number'] as String,
      invoiceNo: jsonSerialization['invoiceNo'] as String?,
      status: _i7pslxk7.PurchaseStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      purchasedOn: _isc.DateTimeJsonExtension.fromJson(
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
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['dueOn']),
      note: jsonSerialization['note'] as String?,
      invoiceMediaId: jsonSerialization['invoiceMediaId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['invoiceMediaId'],
            ),
      receivedAt: jsonSerialization['receivedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['receivedAt'],
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

  static final t = PurchaseTable();

  static const db = PurchaseRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue outletId;

  _isc.UuidValue deviceId;

  _isc.UuidValue stockLocationId;

  _isc.UuidValue? supplierId;

  _isc.UuidValue staffId;

  _isc.UuidValue? cashSessionId;

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

  _isc.UuidValue? invoiceMediaId;

  DateTime? receivedAt;

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

  /// Returns a shallow copy of this [Purchase]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Purchase copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? deviceId,
    _isc.UuidValue? stockLocationId,
    _isc.UuidValue? supplierId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? staffId,
    _isc.UuidValue? cashSessionId = const _isc.$UndefinedUuidValue(),
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
    DateTime? dueOn = const _isc.$UndefinedDateTime(),
    String? note,
    _isc.UuidValue? invoiceMediaId = const _isc.$UndefinedUuidValue(),
    DateTime? receivedAt = const _isc.$UndefinedDateTime(),
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
      if (invoiceMediaId != null) 'invoiceMediaId': invoiceMediaId?.toJson(),
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
      if (invoiceMediaId != null) 'invoiceMediaId': invoiceMediaId?.toJson(),
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
    _isd.WhereExpressionBuilder<PurchaseTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<PurchaseTable>? orderBy,
    _isd.OrderByListBuilder<PurchaseTable>? orderByList,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PurchaseImpl extends Purchase {
  _PurchaseImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue deviceId,
    required _isc.UuidValue stockLocationId,
    _isc.UuidValue? supplierId,
    required _isc.UuidValue staffId,
    _isc.UuidValue? cashSessionId,
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
    _isc.UuidValue? invoiceMediaId,
    DateTime? receivedAt,
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
         invoiceMediaId: invoiceMediaId,
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
  @_isc.useResult
  @override
  Purchase copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? deviceId,
    _isc.UuidValue? stockLocationId,
    _isc.UuidValue? supplierId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? staffId,
    _isc.UuidValue? cashSessionId = const _isc.$UndefinedUuidValue(),
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
    DateTime? dueOn = const _isc.$UndefinedDateTime(),
    Object? note = _Undefined,
    _isc.UuidValue? invoiceMediaId = const _isc.$UndefinedUuidValue(),
    DateTime? receivedAt = const _isc.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return Purchase(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      deviceId: deviceId ?? this.deviceId,
      stockLocationId: stockLocationId ?? this.stockLocationId,
      supplierId: supplierId is _isc.UndefinedSentinel
          ? this.supplierId
          : supplierId,
      staffId: staffId ?? this.staffId,
      cashSessionId: cashSessionId is _isc.UndefinedSentinel
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
      dueOn: dueOn is _isc.UndefinedSentinel ? this.dueOn : dueOn,
      note: note is String? ? note : this.note,
      invoiceMediaId: invoiceMediaId is _isc.UndefinedSentinel
          ? this.invoiceMediaId
          : invoiceMediaId,
      receivedAt: receivedAt is _isc.UndefinedSentinel
          ? this.receivedAt
          : receivedAt,
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

class PurchaseUpdateTable extends _isd.UpdateTable<PurchaseTable> {
  PurchaseUpdateTable(super.table);

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

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> stockLocationId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.stockLocationId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> supplierId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.supplierId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> staffId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.staffId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> cashSessionId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.cashSessionId,
    value,
  );

  _isd.ColumnValue<String, String> number(String value) => _isd.ColumnValue(
    table.number,
    value,
  );

  _isd.ColumnValue<String, String> invoiceNo(String? value) => _isd.ColumnValue(
    table.invoiceNo,
    value,
  );

  _isd.ColumnValue<_i7pslxk7.PurchaseStatus, _i7pslxk7.PurchaseStatus> status(
    _i7pslxk7.PurchaseStatus value,
  ) => _isd.ColumnValue(
    table.status,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> purchasedOn(DateTime value) =>
      _isd.ColumnValue(
        table.purchasedOn,
        value,
      );

  _isd.ColumnValue<int, int> subtotal(int value) => _isd.ColumnValue(
    table.subtotal,
    value,
  );

  _isd.ColumnValue<int, int> discount(int value) => _isd.ColumnValue(
    table.discount,
    value,
  );

  _isd.ColumnValue<int, int> shipping(int value) => _isd.ColumnValue(
    table.shipping,
    value,
  );

  _isd.ColumnValue<int, int> total(int value) => _isd.ColumnValue(
    table.total,
    value,
  );

  _isd.ColumnValue<int, int> paidAmount(int value) => _isd.ColumnValue(
    table.paidAmount,
    value,
  );

  _isd.ColumnValue<_i56sp7oc.FundingSource, _i56sp7oc.FundingSource>
  fundingSource(_i56sp7oc.FundingSource? value) => _isd.ColumnValue(
    table.fundingSource,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> dueOn(DateTime? value) =>
      _isd.ColumnValue(
        table.dueOn,
        value,
      );

  _isd.ColumnValue<String, String> note(String? value) => _isd.ColumnValue(
    table.note,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> invoiceMediaId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.invoiceMediaId,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> receivedAt(DateTime? value) =>
      _isd.ColumnValue(
        table.receivedAt,
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

class PurchaseTable extends _isd.Table<_isc.UuidValue> {
  PurchaseTable({super.tableRelation}) : super(tableName: 'purchases') {
    updateTable = PurchaseUpdateTable(this);
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
    stockLocationId = _isd.ColumnUuid(
      'stock_location_id',
      this,
      fieldName: 'stockLocationId',
    );
    supplierId = _isd.ColumnUuid(
      'supplier_id',
      this,
      fieldName: 'supplierId',
    );
    staffId = _isd.ColumnUuid(
      'staff_id',
      this,
      fieldName: 'staffId',
    );
    cashSessionId = _isd.ColumnUuid(
      'cash_session_id',
      this,
      fieldName: 'cashSessionId',
    );
    number = _isd.ColumnString(
      'number',
      this,
    );
    invoiceNo = _isd.ColumnString(
      'invoice_no',
      this,
      fieldName: 'invoiceNo',
    );
    status = _isd.ColumnEnum(
      'status',
      this,
      _isd.EnumSerialization.byName,
    );
    purchasedOn = _isd.ColumnDateTime(
      'purchased_on',
      this,
      fieldName: 'purchasedOn',
    );
    subtotal = _isd.ColumnInt(
      'subtotal',
      this,
    );
    discount = _isd.ColumnInt(
      'discount',
      this,
    );
    shipping = _isd.ColumnInt(
      'shipping',
      this,
    );
    total = _isd.ColumnInt(
      'total',
      this,
    );
    paidAmount = _isd.ColumnInt(
      'paid_amount',
      this,
      fieldName: 'paidAmount',
    );
    fundingSource = _isd.ColumnEnum(
      'funding_source',
      this,
      _isd.EnumSerialization.byName,
      fieldName: 'fundingSource',
    );
    dueOn = _isd.ColumnDateTime(
      'due_on',
      this,
      fieldName: 'dueOn',
    );
    note = _isd.ColumnString(
      'note',
      this,
    );
    invoiceMediaId = _isd.ColumnUuid(
      'invoice_media_id',
      this,
      fieldName: 'invoiceMediaId',
    );
    receivedAt = _isd.ColumnDateTime(
      'received_at',
      this,
      fieldName: 'receivedAt',
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

  late final PurchaseUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid outletId;

  late final _isd.ColumnUuid deviceId;

  late final _isd.ColumnUuid stockLocationId;

  late final _isd.ColumnUuid supplierId;

  late final _isd.ColumnUuid staffId;

  late final _isd.ColumnUuid cashSessionId;

  late final _isd.ColumnString number;

  late final _isd.ColumnString invoiceNo;

  late final _isd.ColumnEnum<_i7pslxk7.PurchaseStatus> status;

  late final _isd.ColumnDateTime purchasedOn;

  late final _isd.ColumnInt subtotal;

  late final _isd.ColumnInt discount;

  late final _isd.ColumnInt shipping;

  late final _isd.ColumnInt total;

  late final _isd.ColumnInt paidAmount;

  late final _isd.ColumnEnum<_i56sp7oc.FundingSource> fundingSource;

  late final _isd.ColumnDateTime dueOn;

  late final _isd.ColumnString note;

  late final _isd.ColumnUuid invoiceMediaId;

  late final _isd.ColumnDateTime receivedAt;

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
    invoiceMediaId,
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

class PurchaseInclude extends _isd.IncludeObject {
  PurchaseInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => Purchase.t;
}

class PurchaseIncludeList extends _isd.IncludeList {
  PurchaseIncludeList._({
    _isd.WhereExpressionBuilder<PurchaseTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Purchase.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => Purchase.t;
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<PurchaseTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<PurchaseTable>? orderBy,
    _isd.OrderByListBuilder<PurchaseTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<PurchaseTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<PurchaseTable>? orderBy,
    _isd.OrderByListBuilder<PurchaseTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<PurchaseTable>? where,
    int? offset,
    _isd.OrderByBuilder<PurchaseTable>? orderBy,
    _isd.OrderByListBuilder<PurchaseTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session,
    List<Purchase> rows, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    Purchase row, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<Purchase> rows, {
    required _isd.ColumnSelections<PurchaseTable> conflictColumns,
    _isd.ColumnSelections<PurchaseTable>? updateColumns,
    _isd.WhereExpressionBuilder<PurchaseTable>? updateWhere,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    Purchase row, {
    required _isd.ColumnSelections<PurchaseTable> conflictColumns,
    _isd.ColumnSelections<PurchaseTable>? updateColumns,
    _isd.WhereExpressionBuilder<PurchaseTable>? updateWhere,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<Purchase> rows, {
    _isd.ColumnSelections<PurchaseTable>? columns,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    Purchase row, {
    _isd.ColumnSelections<PurchaseTable>? columns,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<PurchaseUpdateTable> columnValues,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<PurchaseUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<PurchaseTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<PurchaseTable>? orderBy,
    _isd.OrderByListBuilder<PurchaseTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<Purchase> rows, {
    _isd.OrderByBuilder<PurchaseTable>? orderBy,
    _isd.OrderByListBuilder<PurchaseTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    Purchase row, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<PurchaseTable> where,
    _isd.OrderByBuilder<PurchaseTable>? orderBy,
    _isd.OrderByListBuilder<PurchaseTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<PurchaseTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<Purchase>(
      where: where?.call(Purchase.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Purchase] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<PurchaseTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Purchase>(
      where: where(Purchase.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
