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
import '../sales/order_type.dart' as _is7lc49y;
import '../sales/sale_status.dart' as _i3rqzpgm;
import '../sales/split_mode.dart' as _ixxw9kq3;

/// Nota penjualan (F1-04/F1-05). Nomor memuat kode cabang dan perangkat
/// (`PST-K01-261103-0001`) agar unik tanpa koordinasi saat sync.
abstract class Sale
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  Sale._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.outletId,
    required this.deviceId,
    this.cashSessionId,
    required this.staffId,
    required this.number,
    required this.status,
    required this.subtotal,
    required this.tierDiscount,
    required this.total,
    required this.paidAmount,
    required this.changeAmount,
    required this.itemCount,
    required this.soldAt,
    _is7lc49y.OrderType? orderType,
    this.diningTableId,
    this.billNumber,
    this.queueNumber,
    this.customerName,
    this.guestCount,
    this.openedBy,
    this.openedAt,
    this.billRequestedAt,
    int? serviceBp,
    int? taxBp,
    int? serviceAmount,
    int? taxAmount,
    bool? taxInclusive,
    int? roundingAmount,
    this.voidReason,
    this.voidedBy,
    this.voidedAt,
    this.splitMode,
    this.splitGuests,
    this.customerId,
    this.dueOn,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _is.Uuid().v7obj(),
       orderType = orderType ?? _is7lc49y.OrderType.retail,
       serviceBp = serviceBp ?? 0,
       taxBp = taxBp ?? 0,
       serviceAmount = serviceAmount ?? 0,
       taxAmount = taxAmount ?? 0,
       taxInclusive = taxInclusive ?? false,
       roundingAmount = roundingAmount ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory Sale({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    _is.UuidValue? cashSessionId,
    required _is.UuidValue staffId,
    required String number,
    required _i3rqzpgm.SaleStatus status,
    required int subtotal,
    required int tierDiscount,
    required int total,
    required int paidAmount,
    required int changeAmount,
    required int itemCount,
    required DateTime soldAt,
    _is7lc49y.OrderType? orderType,
    _is.UuidValue? diningTableId,
    String? billNumber,
    int? queueNumber,
    String? customerName,
    int? guestCount,
    _is.UuidValue? openedBy,
    DateTime? openedAt,
    DateTime? billRequestedAt,
    int? serviceBp,
    int? taxBp,
    int? serviceAmount,
    int? taxAmount,
    bool? taxInclusive,
    int? roundingAmount,
    String? voidReason,
    _is.UuidValue? voidedBy,
    DateTime? voidedAt,
    _ixxw9kq3.SplitMode? splitMode,
    int? splitGuests,
    _is.UuidValue? customerId,
    DateTime? dueOn,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _SaleImpl;

  factory Sale.fromJson(Map<String, dynamic> jsonSerialization) {
    return Sale(
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
      staffId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['staffId'],
      ),
      number: jsonSerialization['number'] as String,
      status: _i3rqzpgm.SaleStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      subtotal: jsonSerialization['subtotal'] as int,
      tierDiscount: jsonSerialization['tierDiscount'] as int,
      total: jsonSerialization['total'] as int,
      paidAmount: jsonSerialization['paidAmount'] as int,
      changeAmount: jsonSerialization['changeAmount'] as int,
      itemCount: jsonSerialization['itemCount'] as int,
      soldAt: _is.DateTimeJsonExtension.fromJson(jsonSerialization['soldAt']),
      orderType: jsonSerialization['orderType'] == null
          ? null
          : _is7lc49y.OrderType.fromJson(
              (jsonSerialization['orderType'] as String),
            ),
      diningTableId: jsonSerialization['diningTableId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['diningTableId'],
            ),
      billNumber: jsonSerialization['billNumber'] as String?,
      queueNumber: jsonSerialization['queueNumber'] as int?,
      customerName: jsonSerialization['customerName'] as String?,
      guestCount: jsonSerialization['guestCount'] as int?,
      openedBy: jsonSerialization['openedBy'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['openedBy']),
      openedAt: jsonSerialization['openedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['openedAt']),
      billRequestedAt: jsonSerialization['billRequestedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['billRequestedAt'],
            ),
      serviceBp: jsonSerialization['serviceBp'] as int?,
      taxBp: jsonSerialization['taxBp'] as int?,
      serviceAmount: jsonSerialization['serviceAmount'] as int?,
      taxAmount: jsonSerialization['taxAmount'] as int?,
      taxInclusive: jsonSerialization['taxInclusive'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['taxInclusive']),
      roundingAmount: jsonSerialization['roundingAmount'] as int?,
      voidReason: jsonSerialization['voidReason'] as String?,
      voidedBy: jsonSerialization['voidedBy'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['voidedBy']),
      voidedAt: jsonSerialization['voidedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['voidedAt']),
      splitMode: jsonSerialization['splitMode'] == null
          ? null
          : _ixxw9kq3.SplitMode.fromJson(
              (jsonSerialization['splitMode'] as String),
            ),
      splitGuests: jsonSerialization['splitGuests'] as int?,
      customerId: jsonSerialization['customerId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['customerId'],
            ),
      dueOn: jsonSerialization['dueOn'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueOn']),
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

  static final t = SaleTable();

  static const db = SaleRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue outletId;

  _is.UuidValue deviceId;

  _is.UuidValue? cashSessionId;

  _is.UuidValue staffId;

  String number;

  _i3rqzpgm.SaleStatus status;

  /// Σ harga daftar × jumlah (sebelum grosir), rupiah.
  int subtotal;

  int tierDiscount;

  int total;

  int paidAmount;

  int changeAmount;

  /// Jumlah baris item.
  int itemCount;

  DateTime soldAt;

  /// F&B (F1-10). Open bill memakai nomor bill `OB-…` di [number] sampai
  /// lunas; nomor bill tetap di [billNumber].
  _is7lc49y.OrderType orderType;

  _is.UuidValue? diningTableId;

  String? billNumber;

  /// Nomor take away harian per perangkat (`TA-07`).
  int? queueNumber;

  String? customerName;

  int? guestCount;

  _is.UuidValue? openedBy;

  DateTime? openedAt;

  DateTime? billRequestedAt;

  /// Tarif dan nominal service/PB1, dibekukan saat lunas.
  int serviceBp;

  int taxBp;

  int serviceAmount;

  int taxAmount;

  /// PB1 sudah termasuk harga (F1-18): tax_amount dipisahkan, bukan ditambah.
  bool taxInclusive;

  /// Selisih pembulatan total (F1-18), termasuk dalam total; boleh negatif.
  int roundingAmount;

  String? voidReason;

  _is.UuidValue? voidedBy;

  DateTime? voidedAt;

  /// Split bill (F1-10c): mode dan jumlah tamu (2–8, label A–H).
  _ixxw9kq3.SplitMode? splitMode;

  int? splitGuests;

  /// Kredit (F1-13): pelanggan dan jatuh tempo piutang. Sisa piutang =
  /// total − [paidAmount] − alokasi pembayaran − pengurang retur.
  _is.UuidValue? customerId;

  DateTime? dueOn;

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

  /// Returns a shallow copy of this [Sale]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Sale copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _is.UuidValue? cashSessionId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? staffId,
    String? number,
    _i3rqzpgm.SaleStatus? status,
    int? subtotal,
    int? tierDiscount,
    int? total,
    int? paidAmount,
    int? changeAmount,
    int? itemCount,
    DateTime? soldAt,
    _is7lc49y.OrderType? orderType,
    _is.UuidValue? diningTableId = const _is.$UndefinedUuidValue(),
    String? billNumber,
    int? queueNumber,
    String? customerName,
    int? guestCount,
    _is.UuidValue? openedBy = const _is.$UndefinedUuidValue(),
    DateTime? openedAt = const _is.$UndefinedDateTime(),
    DateTime? billRequestedAt = const _is.$UndefinedDateTime(),
    int? serviceBp,
    int? taxBp,
    int? serviceAmount,
    int? taxAmount,
    bool? taxInclusive,
    int? roundingAmount,
    String? voidReason,
    _is.UuidValue? voidedBy = const _is.$UndefinedUuidValue(),
    DateTime? voidedAt = const _is.$UndefinedDateTime(),
    _ixxw9kq3.SplitMode? splitMode,
    int? splitGuests,
    _is.UuidValue? customerId = const _is.$UndefinedUuidValue(),
    DateTime? dueOn = const _is.$UndefinedDateTime(),
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
      '__className__': 'Sale',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      if (cashSessionId != null) 'cashSessionId': cashSessionId?.toJson(),
      'staffId': staffId.toJson(),
      'number': number,
      'status': status.toJson(),
      'subtotal': subtotal,
      'tierDiscount': tierDiscount,
      'total': total,
      'paidAmount': paidAmount,
      'changeAmount': changeAmount,
      'itemCount': itemCount,
      'soldAt': soldAt.toJson(),
      'orderType': orderType.toJson(),
      if (diningTableId != null) 'diningTableId': diningTableId?.toJson(),
      if (billNumber != null) 'billNumber': billNumber,
      if (queueNumber != null) 'queueNumber': queueNumber,
      if (customerName != null) 'customerName': customerName,
      if (guestCount != null) 'guestCount': guestCount,
      if (openedBy != null) 'openedBy': openedBy?.toJson(),
      if (openedAt != null) 'openedAt': openedAt?.toJson(),
      if (billRequestedAt != null) 'billRequestedAt': billRequestedAt?.toJson(),
      'serviceBp': serviceBp,
      'taxBp': taxBp,
      'serviceAmount': serviceAmount,
      'taxAmount': taxAmount,
      'taxInclusive': taxInclusive,
      'roundingAmount': roundingAmount,
      if (voidReason != null) 'voidReason': voidReason,
      if (voidedBy != null) 'voidedBy': voidedBy?.toJson(),
      if (voidedAt != null) 'voidedAt': voidedAt?.toJson(),
      if (splitMode != null) 'splitMode': splitMode?.toJson(),
      if (splitGuests != null) 'splitGuests': splitGuests,
      if (customerId != null) 'customerId': customerId?.toJson(),
      if (dueOn != null) 'dueOn': dueOn?.toJson(),
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
      '__className__': 'Sale',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      if (cashSessionId != null) 'cashSessionId': cashSessionId?.toJson(),
      'staffId': staffId.toJson(),
      'number': number,
      'status': status.toJson(),
      'subtotal': subtotal,
      'tierDiscount': tierDiscount,
      'total': total,
      'paidAmount': paidAmount,
      'changeAmount': changeAmount,
      'itemCount': itemCount,
      'soldAt': soldAt.toJson(),
      'orderType': orderType.toJson(),
      if (diningTableId != null) 'diningTableId': diningTableId?.toJson(),
      if (billNumber != null) 'billNumber': billNumber,
      if (queueNumber != null) 'queueNumber': queueNumber,
      if (customerName != null) 'customerName': customerName,
      if (guestCount != null) 'guestCount': guestCount,
      if (openedBy != null) 'openedBy': openedBy?.toJson(),
      if (openedAt != null) 'openedAt': openedAt?.toJson(),
      if (billRequestedAt != null) 'billRequestedAt': billRequestedAt?.toJson(),
      'serviceBp': serviceBp,
      'taxBp': taxBp,
      'serviceAmount': serviceAmount,
      'taxAmount': taxAmount,
      'taxInclusive': taxInclusive,
      'roundingAmount': roundingAmount,
      if (voidReason != null) 'voidReason': voidReason,
      if (voidedBy != null) 'voidedBy': voidedBy?.toJson(),
      if (voidedAt != null) 'voidedAt': voidedAt?.toJson(),
      if (splitMode != null) 'splitMode': splitMode?.toJson(),
      if (splitGuests != null) 'splitGuests': splitGuests,
      if (customerId != null) 'customerId': customerId?.toJson(),
      if (dueOn != null) 'dueOn': dueOn?.toJson(),
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

  static SaleInclude include() {
    return SaleInclude._();
  }

  static SaleIncludeList includeList({
    _is.WhereExpressionBuilder<SaleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleTable>? orderBy,
    _is.OrderByListBuilder<SaleTable>? orderByList,
    SaleInclude? include,
  }) {
    return SaleIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Sale.t),
      orderByList: orderByList?.call(Sale.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SaleImpl extends Sale {
  _SaleImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    _is.UuidValue? cashSessionId,
    required _is.UuidValue staffId,
    required String number,
    required _i3rqzpgm.SaleStatus status,
    required int subtotal,
    required int tierDiscount,
    required int total,
    required int paidAmount,
    required int changeAmount,
    required int itemCount,
    required DateTime soldAt,
    _is7lc49y.OrderType? orderType,
    _is.UuidValue? diningTableId,
    String? billNumber,
    int? queueNumber,
    String? customerName,
    int? guestCount,
    _is.UuidValue? openedBy,
    DateTime? openedAt,
    DateTime? billRequestedAt,
    int? serviceBp,
    int? taxBp,
    int? serviceAmount,
    int? taxAmount,
    bool? taxInclusive,
    int? roundingAmount,
    String? voidReason,
    _is.UuidValue? voidedBy,
    DateTime? voidedAt,
    _ixxw9kq3.SplitMode? splitMode,
    int? splitGuests,
    _is.UuidValue? customerId,
    DateTime? dueOn,
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
         staffId: staffId,
         number: number,
         status: status,
         subtotal: subtotal,
         tierDiscount: tierDiscount,
         total: total,
         paidAmount: paidAmount,
         changeAmount: changeAmount,
         itemCount: itemCount,
         soldAt: soldAt,
         orderType: orderType,
         diningTableId: diningTableId,
         billNumber: billNumber,
         queueNumber: queueNumber,
         customerName: customerName,
         guestCount: guestCount,
         openedBy: openedBy,
         openedAt: openedAt,
         billRequestedAt: billRequestedAt,
         serviceBp: serviceBp,
         taxBp: taxBp,
         serviceAmount: serviceAmount,
         taxAmount: taxAmount,
         taxInclusive: taxInclusive,
         roundingAmount: roundingAmount,
         voidReason: voidReason,
         voidedBy: voidedBy,
         voidedAt: voidedAt,
         splitMode: splitMode,
         splitGuests: splitGuests,
         customerId: customerId,
         dueOn: dueOn,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [Sale]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Sale copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _is.UuidValue? cashSessionId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? staffId,
    String? number,
    _i3rqzpgm.SaleStatus? status,
    int? subtotal,
    int? tierDiscount,
    int? total,
    int? paidAmount,
    int? changeAmount,
    int? itemCount,
    DateTime? soldAt,
    _is7lc49y.OrderType? orderType,
    _is.UuidValue? diningTableId = const _is.$UndefinedUuidValue(),
    Object? billNumber = _Undefined,
    Object? queueNumber = _Undefined,
    Object? customerName = _Undefined,
    Object? guestCount = _Undefined,
    _is.UuidValue? openedBy = const _is.$UndefinedUuidValue(),
    DateTime? openedAt = const _is.$UndefinedDateTime(),
    DateTime? billRequestedAt = const _is.$UndefinedDateTime(),
    int? serviceBp,
    int? taxBp,
    int? serviceAmount,
    int? taxAmount,
    bool? taxInclusive,
    int? roundingAmount,
    Object? voidReason = _Undefined,
    _is.UuidValue? voidedBy = const _is.$UndefinedUuidValue(),
    DateTime? voidedAt = const _is.$UndefinedDateTime(),
    Object? splitMode = _Undefined,
    Object? splitGuests = _Undefined,
    _is.UuidValue? customerId = const _is.$UndefinedUuidValue(),
    DateTime? dueOn = const _is.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return Sale(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      deviceId: deviceId ?? this.deviceId,
      cashSessionId: cashSessionId is _is.UndefinedSentinel
          ? this.cashSessionId
          : cashSessionId,
      staffId: staffId ?? this.staffId,
      number: number ?? this.number,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      tierDiscount: tierDiscount ?? this.tierDiscount,
      total: total ?? this.total,
      paidAmount: paidAmount ?? this.paidAmount,
      changeAmount: changeAmount ?? this.changeAmount,
      itemCount: itemCount ?? this.itemCount,
      soldAt: soldAt ?? this.soldAt,
      orderType: orderType ?? this.orderType,
      diningTableId: diningTableId is _is.UndefinedSentinel
          ? this.diningTableId
          : diningTableId,
      billNumber: billNumber is String? ? billNumber : this.billNumber,
      queueNumber: queueNumber is int? ? queueNumber : this.queueNumber,
      customerName: customerName is String? ? customerName : this.customerName,
      guestCount: guestCount is int? ? guestCount : this.guestCount,
      openedBy: openedBy is _is.UndefinedSentinel ? this.openedBy : openedBy,
      openedAt: openedAt is _is.UndefinedSentinel ? this.openedAt : openedAt,
      billRequestedAt: billRequestedAt is _is.UndefinedSentinel
          ? this.billRequestedAt
          : billRequestedAt,
      serviceBp: serviceBp ?? this.serviceBp,
      taxBp: taxBp ?? this.taxBp,
      serviceAmount: serviceAmount ?? this.serviceAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      taxInclusive: taxInclusive ?? this.taxInclusive,
      roundingAmount: roundingAmount ?? this.roundingAmount,
      voidReason: voidReason is String? ? voidReason : this.voidReason,
      voidedBy: voidedBy is _is.UndefinedSentinel ? this.voidedBy : voidedBy,
      voidedAt: voidedAt is _is.UndefinedSentinel ? this.voidedAt : voidedAt,
      splitMode: splitMode is _ixxw9kq3.SplitMode? ? splitMode : this.splitMode,
      splitGuests: splitGuests is int? ? splitGuests : this.splitGuests,
      customerId: customerId is _is.UndefinedSentinel
          ? this.customerId
          : customerId,
      dueOn: dueOn is _is.UndefinedSentinel ? this.dueOn : dueOn,
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

class SaleUpdateTable extends _is.UpdateTable<SaleTable> {
  SaleUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> staffId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.staffId,
        value,
      );

  _is.ColumnValue<String, String> number(String value) => _is.ColumnValue(
    table.number,
    value,
  );

  _is.ColumnValue<_i3rqzpgm.SaleStatus, _i3rqzpgm.SaleStatus> status(
    _i3rqzpgm.SaleStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<int, int> subtotal(int value) => _is.ColumnValue(
    table.subtotal,
    value,
  );

  _is.ColumnValue<int, int> tierDiscount(int value) => _is.ColumnValue(
    table.tierDiscount,
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

  _is.ColumnValue<int, int> changeAmount(int value) => _is.ColumnValue(
    table.changeAmount,
    value,
  );

  _is.ColumnValue<int, int> itemCount(int value) => _is.ColumnValue(
    table.itemCount,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> soldAt(DateTime value) => _is.ColumnValue(
    table.soldAt,
    value,
  );

  _is.ColumnValue<_is7lc49y.OrderType, _is7lc49y.OrderType> orderType(
    _is7lc49y.OrderType value,
  ) => _is.ColumnValue(
    table.orderType,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> diningTableId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.diningTableId,
    value,
  );

  _is.ColumnValue<String, String> billNumber(String? value) => _is.ColumnValue(
    table.billNumber,
    value,
  );

  _is.ColumnValue<int, int> queueNumber(int? value) => _is.ColumnValue(
    table.queueNumber,
    value,
  );

  _is.ColumnValue<String, String> customerName(String? value) =>
      _is.ColumnValue(
        table.customerName,
        value,
      );

  _is.ColumnValue<int, int> guestCount(int? value) => _is.ColumnValue(
    table.guestCount,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> openedBy(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.openedBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> openedAt(DateTime? value) =>
      _is.ColumnValue(
        table.openedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> billRequestedAt(DateTime? value) =>
      _is.ColumnValue(
        table.billRequestedAt,
        value,
      );

  _is.ColumnValue<int, int> serviceBp(int value) => _is.ColumnValue(
    table.serviceBp,
    value,
  );

  _is.ColumnValue<int, int> taxBp(int value) => _is.ColumnValue(
    table.taxBp,
    value,
  );

  _is.ColumnValue<int, int> serviceAmount(int value) => _is.ColumnValue(
    table.serviceAmount,
    value,
  );

  _is.ColumnValue<int, int> taxAmount(int value) => _is.ColumnValue(
    table.taxAmount,
    value,
  );

  _is.ColumnValue<bool, bool> taxInclusive(bool value) => _is.ColumnValue(
    table.taxInclusive,
    value,
  );

  _is.ColumnValue<int, int> roundingAmount(int value) => _is.ColumnValue(
    table.roundingAmount,
    value,
  );

  _is.ColumnValue<String, String> voidReason(String? value) => _is.ColumnValue(
    table.voidReason,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> voidedBy(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.voidedBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> voidedAt(DateTime? value) =>
      _is.ColumnValue(
        table.voidedAt,
        value,
      );

  _is.ColumnValue<_ixxw9kq3.SplitMode, _ixxw9kq3.SplitMode> splitMode(
    _ixxw9kq3.SplitMode? value,
  ) => _is.ColumnValue(
    table.splitMode,
    value,
  );

  _is.ColumnValue<int, int> splitGuests(int? value) => _is.ColumnValue(
    table.splitGuests,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> customerId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.customerId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> dueOn(DateTime? value) => _is.ColumnValue(
    table.dueOn,
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

class SaleTable extends _is.Table<_is.UuidValue> {
  SaleTable({super.tableRelation}) : super(tableName: 'sales') {
    updateTable = SaleUpdateTable(this);
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
    staffId = _is.ColumnUuid(
      'staff_id',
      this,
      fieldName: 'staffId',
    );
    number = _is.ColumnString(
      'number',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    subtotal = _is.ColumnInt(
      'subtotal',
      this,
    );
    tierDiscount = _is.ColumnInt(
      'tier_discount',
      this,
      fieldName: 'tierDiscount',
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
    changeAmount = _is.ColumnInt(
      'change_amount',
      this,
      fieldName: 'changeAmount',
    );
    itemCount = _is.ColumnInt(
      'item_count',
      this,
      fieldName: 'itemCount',
    );
    soldAt = _is.ColumnDateTime(
      'sold_at',
      this,
      fieldName: 'soldAt',
    );
    orderType = _is.ColumnEnum(
      'order_type',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
      fieldName: 'orderType',
    );
    diningTableId = _is.ColumnUuid(
      'dining_table_id',
      this,
      fieldName: 'diningTableId',
    );
    billNumber = _is.ColumnString(
      'bill_number',
      this,
      fieldName: 'billNumber',
    );
    queueNumber = _is.ColumnInt(
      'queue_number',
      this,
      fieldName: 'queueNumber',
    );
    customerName = _is.ColumnString(
      'customer_name',
      this,
      fieldName: 'customerName',
    );
    guestCount = _is.ColumnInt(
      'guest_count',
      this,
      fieldName: 'guestCount',
    );
    openedBy = _is.ColumnUuid(
      'opened_by',
      this,
      fieldName: 'openedBy',
    );
    openedAt = _is.ColumnDateTime(
      'opened_at',
      this,
      fieldName: 'openedAt',
    );
    billRequestedAt = _is.ColumnDateTime(
      'bill_requested_at',
      this,
      fieldName: 'billRequestedAt',
    );
    serviceBp = _is.ColumnInt(
      'service_bp',
      this,
      hasDefault: true,
      fieldName: 'serviceBp',
    );
    taxBp = _is.ColumnInt(
      'tax_bp',
      this,
      hasDefault: true,
      fieldName: 'taxBp',
    );
    serviceAmount = _is.ColumnInt(
      'service_amount',
      this,
      hasDefault: true,
      fieldName: 'serviceAmount',
    );
    taxAmount = _is.ColumnInt(
      'tax_amount',
      this,
      hasDefault: true,
      fieldName: 'taxAmount',
    );
    taxInclusive = _is.ColumnBool(
      'tax_inclusive',
      this,
      hasDefault: true,
      fieldName: 'taxInclusive',
    );
    roundingAmount = _is.ColumnInt(
      'rounding_amount',
      this,
      hasDefault: true,
      fieldName: 'roundingAmount',
    );
    voidReason = _is.ColumnString(
      'void_reason',
      this,
      fieldName: 'voidReason',
    );
    voidedBy = _is.ColumnUuid(
      'voided_by',
      this,
      fieldName: 'voidedBy',
    );
    voidedAt = _is.ColumnDateTime(
      'voided_at',
      this,
      fieldName: 'voidedAt',
    );
    splitMode = _is.ColumnEnum(
      'split_mode',
      this,
      _is.EnumSerialization.byName,
      fieldName: 'splitMode',
    );
    splitGuests = _is.ColumnInt(
      'split_guests',
      this,
      fieldName: 'splitGuests',
    );
    customerId = _is.ColumnUuid(
      'customer_id',
      this,
      fieldName: 'customerId',
    );
    dueOn = _is.ColumnDateTime(
      'due_on',
      this,
      fieldName: 'dueOn',
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

  late final SaleUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid outletId;

  late final _is.ColumnUuid deviceId;

  late final _is.ColumnUuid cashSessionId;

  late final _is.ColumnUuid staffId;

  late final _is.ColumnString number;

  late final _is.ColumnEnum<_i3rqzpgm.SaleStatus> status;

  /// Σ harga daftar × jumlah (sebelum grosir), rupiah.
  late final _is.ColumnInt subtotal;

  late final _is.ColumnInt tierDiscount;

  late final _is.ColumnInt total;

  late final _is.ColumnInt paidAmount;

  late final _is.ColumnInt changeAmount;

  /// Jumlah baris item.
  late final _is.ColumnInt itemCount;

  late final _is.ColumnDateTime soldAt;

  /// F&B (F1-10). Open bill memakai nomor bill `OB-…` di [number] sampai
  /// lunas; nomor bill tetap di [billNumber].
  late final _is.ColumnEnum<_is7lc49y.OrderType> orderType;

  late final _is.ColumnUuid diningTableId;

  late final _is.ColumnString billNumber;

  /// Nomor take away harian per perangkat (`TA-07`).
  late final _is.ColumnInt queueNumber;

  late final _is.ColumnString customerName;

  late final _is.ColumnInt guestCount;

  late final _is.ColumnUuid openedBy;

  late final _is.ColumnDateTime openedAt;

  late final _is.ColumnDateTime billRequestedAt;

  /// Tarif dan nominal service/PB1, dibekukan saat lunas.
  late final _is.ColumnInt serviceBp;

  late final _is.ColumnInt taxBp;

  late final _is.ColumnInt serviceAmount;

  late final _is.ColumnInt taxAmount;

  /// PB1 sudah termasuk harga (F1-18): tax_amount dipisahkan, bukan ditambah.
  late final _is.ColumnBool taxInclusive;

  /// Selisih pembulatan total (F1-18), termasuk dalam total; boleh negatif.
  late final _is.ColumnInt roundingAmount;

  late final _is.ColumnString voidReason;

  late final _is.ColumnUuid voidedBy;

  late final _is.ColumnDateTime voidedAt;

  /// Split bill (F1-10c): mode dan jumlah tamu (2–8, label A–H).
  late final _is.ColumnEnum<_ixxw9kq3.SplitMode> splitMode;

  late final _is.ColumnInt splitGuests;

  /// Kredit (F1-13): pelanggan dan jatuh tempo piutang. Sisa piutang =
  /// total − [paidAmount] − alokasi pembayaran − pengurang retur.
  late final _is.ColumnUuid customerId;

  late final _is.ColumnDateTime dueOn;

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
    staffId,
    number,
    status,
    subtotal,
    tierDiscount,
    total,
    paidAmount,
    changeAmount,
    itemCount,
    soldAt,
    orderType,
    diningTableId,
    billNumber,
    queueNumber,
    customerName,
    guestCount,
    openedBy,
    openedAt,
    billRequestedAt,
    serviceBp,
    taxBp,
    serviceAmount,
    taxAmount,
    taxInclusive,
    roundingAmount,
    voidReason,
    voidedBy,
    voidedAt,
    splitMode,
    splitGuests,
    customerId,
    dueOn,
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

class SaleInclude extends _is.IncludeObject {
  SaleInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => Sale.t;
}

class SaleIncludeList extends _is.IncludeList {
  SaleIncludeList._({
    _is.WhereExpressionBuilder<SaleTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Sale.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => Sale.t;
}

class SaleRepository {
  const SaleRepository._();

  /// Returns a list of [Sale]s matching the given query parameters.
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
  Future<List<Sale>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleTable>? orderBy,
    _is.OrderByListBuilder<SaleTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Sale>(
      where: where?.call(Sale.t),
      orderBy: orderBy?.call(Sale.t),
      orderByList: orderByList?.call(Sale.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Sale]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Sale.t`.
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
  _ida.Stream<List<Sale>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleTable>? orderBy,
    _is.OrderByListBuilder<SaleTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Sale>(
      where: where?.call(Sale.t),
      orderBy: orderBy?.call(Sale.t),
      orderByList: orderByList?.call(Sale.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Sale] matching the given query parameters.
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
  Future<Sale?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleTable>? where,
    int? offset,
    _is.OrderByBuilder<SaleTable>? orderBy,
    _is.OrderByListBuilder<SaleTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Sale>(
      where: where?.call(Sale.t),
      orderBy: orderBy?.call(Sale.t),
      orderByList: orderByList?.call(Sale.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Sale] by its [id] or null if no such row exists.
  Future<Sale?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Sale>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Sale]s in the list and returns the inserted rows.
  ///
  /// The returned [Sale]s will have their `id` fields set.
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
  Future<List<Sale>> insert(
    _is.DatabaseSession session,
    List<Sale> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Sale>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Sale] and returns the inserted row.
  ///
  /// The returned [Sale] will have its `id` field set.
  Future<Sale> insertRow(
    _is.DatabaseSession session,
    Sale row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Sale>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Sale]s in the list and returns the resulting rows.
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
  /// The returned [Sale]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Sale>> upsert(
    _is.DatabaseSession session,
    List<Sale> rows, {
    required _is.ColumnSelections<SaleTable> conflictColumns,
    _is.ColumnSelections<SaleTable>? updateColumns,
    _is.WhereExpressionBuilder<SaleTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Sale>(
      rows,
      conflictColumns: conflictColumns(Sale.t),
      updateColumns: updateColumns?.call(Sale.t),
      updateWhere: updateWhere?.call(Sale.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Sale] and returns the resulting row.
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
  /// The returned [Sale] will have its `id` field set.
  Future<Sale?> upsertRow(
    _is.DatabaseSession session,
    Sale row, {
    required _is.ColumnSelections<SaleTable> conflictColumns,
    _is.ColumnSelections<SaleTable>? updateColumns,
    _is.WhereExpressionBuilder<SaleTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Sale>(
      row,
      conflictColumns: conflictColumns(Sale.t),
      updateColumns: updateColumns?.call(Sale.t),
      updateWhere: updateWhere?.call(Sale.t),
      transaction: transaction,
    );
  }

  /// Updates all [Sale]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Sale>> update(
    _is.DatabaseSession session,
    List<Sale> rows, {
    _is.ColumnSelections<SaleTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Sale>(
      rows,
      columns: columns?.call(Sale.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Sale]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Sale> updateRow(
    _is.DatabaseSession session,
    Sale row, {
    _is.ColumnSelections<SaleTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Sale>(
      row,
      columns: columns?.call(Sale.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Sale] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Sale?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<SaleUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Sale>(
      id,
      columnValues: columnValues(Sale.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Sale]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Sale>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SaleUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SaleTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SaleTable>? orderBy,
    _is.OrderByListBuilder<SaleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Sale>(
      columnValues: columnValues(Sale.t.updateTable),
      where: where(Sale.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Sale.t),
      orderByList: orderByList?.call(Sale.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Sale]s in the list and returns the deleted rows.
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
  Future<List<Sale>> delete(
    _is.DatabaseSession session,
    List<Sale> rows, {
    _is.OrderByBuilder<SaleTable>? orderBy,
    _is.OrderByListBuilder<SaleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Sale>(
      rows,
      orderBy: orderBy?.call(Sale.t),
      orderByList: orderByList?.call(Sale.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Sale].
  Future<Sale> deleteRow(
    _is.DatabaseSession session,
    Sale row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Sale>(
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
  Future<List<Sale>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SaleTable> where,
    _is.OrderByBuilder<SaleTable>? orderBy,
    _is.OrderByListBuilder<SaleTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Sale>(
      where: where(Sale.t),
      orderBy: orderBy?.call(Sale.t),
      orderByList: orderByList?.call(Sale.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SaleTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Sale>(
      where: where?.call(Sale.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Sale] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SaleTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Sale>(
      where: where(Sale.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
