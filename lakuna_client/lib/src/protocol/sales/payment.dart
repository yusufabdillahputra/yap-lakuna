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
import '../sales/payment_method.dart' as _inpnx77f;
import '../sales/payment_status.dart' as _il8zccpy;

/// Pembayaran nota (F1-05). Tunai: `amount` = uang diterima,
/// `change_amount` = kembalian. Non-tunai: `amount` = jumlah dibayar.
abstract class Payment
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  Payment._({
    _isc.UuidValue? id,
    required this.tenantId,
    required this.saleId,
    required this.method,
    required this.amount,
    required this.changeAmount,
    this.reference,
    required this.status,
    this.confirmedBy,
    this.confirmedAt,
    required this.paidAt,
    this.guestLabel,
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

  factory Payment({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue saleId,
    required _inpnx77f.PaymentMethod method,
    required int amount,
    required int changeAmount,
    String? reference,
    required _il8zccpy.PaymentStatus status,
    _isc.UuidValue? confirmedBy,
    DateTime? confirmedAt,
    required DateTime paidAt,
    String? guestLabel,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _PaymentImpl;

  factory Payment.fromJson(Map<String, dynamic> jsonSerialization) {
    return Payment(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      saleId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['saleId']),
      method: _inpnx77f.PaymentMethod.fromJson(
        (jsonSerialization['method'] as String),
      ),
      amount: jsonSerialization['amount'] as int,
      changeAmount: jsonSerialization['changeAmount'] as int,
      reference: jsonSerialization['reference'] as String?,
      status: _il8zccpy.PaymentStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      confirmedBy: jsonSerialization['confirmedBy'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['confirmedBy'],
            ),
      confirmedAt: jsonSerialization['confirmedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['confirmedAt'],
            ),
      paidAt: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['paidAt']),
      guestLabel: jsonSerialization['guestLabel'] as String?,
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

  static final t = PaymentTable();

  static const db = PaymentRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue saleId;

  _inpnx77f.PaymentMethod method;

  int amount;

  int changeAmount;

  /// No. approval kartu atau referensi transfer.
  String? reference;

  _il8zccpy.PaymentStatus status;

  _isc.UuidValue? confirmedBy;

  DateTime? confirmedAt;

  DateTime paidAt;

  /// Bagian tamu split bill (`A`–`H`); `null` = pembayaran biasa.
  String? guestLabel;

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

  /// Returns a shallow copy of this [Payment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Payment copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? saleId,
    _inpnx77f.PaymentMethod? method,
    int? amount,
    int? changeAmount,
    String? reference,
    _il8zccpy.PaymentStatus? status,
    _isc.UuidValue? confirmedBy = const _isc.$UndefinedUuidValue(),
    DateTime? confirmedAt = const _isc.$UndefinedDateTime(),
    DateTime? paidAt,
    String? guestLabel,
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
      '__className__': 'Payment',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'saleId': saleId.toJson(),
      'method': method.toJson(),
      'amount': amount,
      'changeAmount': changeAmount,
      if (reference != null) 'reference': reference,
      'status': status.toJson(),
      if (confirmedBy != null) 'confirmedBy': confirmedBy?.toJson(),
      if (confirmedAt != null) 'confirmedAt': confirmedAt?.toJson(),
      'paidAt': paidAt.toJson(),
      if (guestLabel != null) 'guestLabel': guestLabel,
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
      '__className__': 'Payment',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'saleId': saleId.toJson(),
      'method': method.toJson(),
      'amount': amount,
      'changeAmount': changeAmount,
      if (reference != null) 'reference': reference,
      'status': status.toJson(),
      if (confirmedBy != null) 'confirmedBy': confirmedBy?.toJson(),
      if (confirmedAt != null) 'confirmedAt': confirmedAt?.toJson(),
      'paidAt': paidAt.toJson(),
      if (guestLabel != null) 'guestLabel': guestLabel,
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

  static PaymentInclude include() {
    return PaymentInclude._();
  }

  static PaymentIncludeList includeList({
    _isd.WhereExpressionBuilder<PaymentTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<PaymentTable>? orderBy,
    _isd.OrderByListBuilder<PaymentTable>? orderByList,
    PaymentInclude? include,
  }) {
    return PaymentIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Payment.t),
      orderByList: orderByList?.call(Payment.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentImpl extends Payment {
  _PaymentImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue saleId,
    required _inpnx77f.PaymentMethod method,
    required int amount,
    required int changeAmount,
    String? reference,
    required _il8zccpy.PaymentStatus status,
    _isc.UuidValue? confirmedBy,
    DateTime? confirmedAt,
    required DateTime paidAt,
    String? guestLabel,
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
         saleId: saleId,
         method: method,
         amount: amount,
         changeAmount: changeAmount,
         reference: reference,
         status: status,
         confirmedBy: confirmedBy,
         confirmedAt: confirmedAt,
         paidAt: paidAt,
         guestLabel: guestLabel,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [Payment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Payment copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? saleId,
    _inpnx77f.PaymentMethod? method,
    int? amount,
    int? changeAmount,
    Object? reference = _Undefined,
    _il8zccpy.PaymentStatus? status,
    _isc.UuidValue? confirmedBy = const _isc.$UndefinedUuidValue(),
    DateTime? confirmedAt = const _isc.$UndefinedDateTime(),
    DateTime? paidAt,
    Object? guestLabel = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return Payment(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      saleId: saleId ?? this.saleId,
      method: method ?? this.method,
      amount: amount ?? this.amount,
      changeAmount: changeAmount ?? this.changeAmount,
      reference: reference is String? ? reference : this.reference,
      status: status ?? this.status,
      confirmedBy: confirmedBy is _isc.UndefinedSentinel
          ? this.confirmedBy
          : confirmedBy,
      confirmedAt: confirmedAt is _isc.UndefinedSentinel
          ? this.confirmedAt
          : confirmedAt,
      paidAt: paidAt ?? this.paidAt,
      guestLabel: guestLabel is String? ? guestLabel : this.guestLabel,
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

class PaymentUpdateTable extends _isd.UpdateTable<PaymentTable> {
  PaymentUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> tenantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.tenantId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> saleId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.saleId,
    value,
  );

  _isd.ColumnValue<_inpnx77f.PaymentMethod, _inpnx77f.PaymentMethod> method(
    _inpnx77f.PaymentMethod value,
  ) => _isd.ColumnValue(
    table.method,
    value,
  );

  _isd.ColumnValue<int, int> amount(int value) => _isd.ColumnValue(
    table.amount,
    value,
  );

  _isd.ColumnValue<int, int> changeAmount(int value) => _isd.ColumnValue(
    table.changeAmount,
    value,
  );

  _isd.ColumnValue<String, String> reference(String? value) => _isd.ColumnValue(
    table.reference,
    value,
  );

  _isd.ColumnValue<_il8zccpy.PaymentStatus, _il8zccpy.PaymentStatus> status(
    _il8zccpy.PaymentStatus value,
  ) => _isd.ColumnValue(
    table.status,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> confirmedBy(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.confirmedBy,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> confirmedAt(DateTime? value) =>
      _isd.ColumnValue(
        table.confirmedAt,
        value,
      );

  _isd.ColumnValue<DateTime, DateTime> paidAt(DateTime value) =>
      _isd.ColumnValue(
        table.paidAt,
        value,
      );

  _isd.ColumnValue<String, String> guestLabel(String? value) =>
      _isd.ColumnValue(
        table.guestLabel,
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

class PaymentTable extends _isd.Table<_isc.UuidValue> {
  PaymentTable({super.tableRelation}) : super(tableName: 'payments') {
    updateTable = PaymentUpdateTable(this);
    tenantId = _isd.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    saleId = _isd.ColumnUuid(
      'sale_id',
      this,
      fieldName: 'saleId',
    );
    method = _isd.ColumnEnum(
      'method',
      this,
      _isd.EnumSerialization.byName,
    );
    amount = _isd.ColumnInt(
      'amount',
      this,
    );
    changeAmount = _isd.ColumnInt(
      'change_amount',
      this,
      fieldName: 'changeAmount',
    );
    reference = _isd.ColumnString(
      'reference',
      this,
    );
    status = _isd.ColumnEnum(
      'status',
      this,
      _isd.EnumSerialization.byName,
    );
    confirmedBy = _isd.ColumnUuid(
      'confirmed_by',
      this,
      fieldName: 'confirmedBy',
    );
    confirmedAt = _isd.ColumnDateTime(
      'confirmed_at',
      this,
      fieldName: 'confirmedAt',
    );
    paidAt = _isd.ColumnDateTime(
      'paid_at',
      this,
      fieldName: 'paidAt',
    );
    guestLabel = _isd.ColumnString(
      'guest_label',
      this,
      fieldName: 'guestLabel',
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

  late final PaymentUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid saleId;

  late final _isd.ColumnEnum<_inpnx77f.PaymentMethod> method;

  late final _isd.ColumnInt amount;

  late final _isd.ColumnInt changeAmount;

  /// No. approval kartu atau referensi transfer.
  late final _isd.ColumnString reference;

  late final _isd.ColumnEnum<_il8zccpy.PaymentStatus> status;

  late final _isd.ColumnUuid confirmedBy;

  late final _isd.ColumnDateTime confirmedAt;

  late final _isd.ColumnDateTime paidAt;

  /// Bagian tamu split bill (`A`–`H`); `null` = pembayaran biasa.
  late final _isd.ColumnString guestLabel;

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
    saleId,
    method,
    amount,
    changeAmount,
    reference,
    status,
    confirmedBy,
    confirmedAt,
    paidAt,
    guestLabel,
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

class PaymentInclude extends _isd.IncludeObject {
  PaymentInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => Payment.t;
}

class PaymentIncludeList extends _isd.IncludeList {
  PaymentIncludeList._({
    _isd.WhereExpressionBuilder<PaymentTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Payment.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => Payment.t;
}

class PaymentRepository {
  const PaymentRepository._();

  /// Returns a list of [Payment]s matching the given query parameters.
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
  Future<List<Payment>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<PaymentTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<PaymentTable>? orderBy,
    _isd.OrderByListBuilder<PaymentTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Payment>(
      where: where?.call(Payment.t),
      orderBy: orderBy?.call(Payment.t),
      orderByList: orderByList?.call(Payment.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Payment]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Payment.t`.
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
  _ida.Stream<List<Payment>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<PaymentTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<PaymentTable>? orderBy,
    _isd.OrderByListBuilder<PaymentTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Payment>(
      where: where?.call(Payment.t),
      orderBy: orderBy?.call(Payment.t),
      orderByList: orderByList?.call(Payment.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Payment] matching the given query parameters.
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
  Future<Payment?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<PaymentTable>? where,
    int? offset,
    _isd.OrderByBuilder<PaymentTable>? orderBy,
    _isd.OrderByListBuilder<PaymentTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Payment>(
      where: where?.call(Payment.t),
      orderBy: orderBy?.call(Payment.t),
      orderByList: orderByList?.call(Payment.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Payment] by its [id] or null if no such row exists.
  Future<Payment?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Payment>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Payment]s in the list and returns the inserted rows.
  ///
  /// The returned [Payment]s will have their `id` fields set.
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
  Future<List<Payment>> insert(
    _isd.DatabaseSession session,
    List<Payment> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Payment>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Payment] and returns the inserted row.
  ///
  /// The returned [Payment] will have its `id` field set.
  Future<Payment> insertRow(
    _isd.DatabaseSession session,
    Payment row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<Payment>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Payment]s in the list and returns the resulting rows.
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
  /// The returned [Payment]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Payment>> upsert(
    _isd.DatabaseSession session,
    List<Payment> rows, {
    required _isd.ColumnSelections<PaymentTable> conflictColumns,
    _isd.ColumnSelections<PaymentTable>? updateColumns,
    _isd.WhereExpressionBuilder<PaymentTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Payment>(
      rows,
      conflictColumns: conflictColumns(Payment.t),
      updateColumns: updateColumns?.call(Payment.t),
      updateWhere: updateWhere?.call(Payment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Payment] and returns the resulting row.
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
  /// The returned [Payment] will have its `id` field set.
  Future<Payment?> upsertRow(
    _isd.DatabaseSession session,
    Payment row, {
    required _isd.ColumnSelections<PaymentTable> conflictColumns,
    _isd.ColumnSelections<PaymentTable>? updateColumns,
    _isd.WhereExpressionBuilder<PaymentTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Payment>(
      row,
      conflictColumns: conflictColumns(Payment.t),
      updateColumns: updateColumns?.call(Payment.t),
      updateWhere: updateWhere?.call(Payment.t),
      transaction: transaction,
    );
  }

  /// Updates all [Payment]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Payment>> update(
    _isd.DatabaseSession session,
    List<Payment> rows, {
    _isd.ColumnSelections<PaymentTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Payment>(
      rows,
      columns: columns?.call(Payment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Payment]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Payment> updateRow(
    _isd.DatabaseSession session,
    Payment row, {
    _isd.ColumnSelections<PaymentTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<Payment>(
      row,
      columns: columns?.call(Payment.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Payment] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Payment?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<PaymentUpdateTable> columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<Payment>(
      id,
      columnValues: columnValues(Payment.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Payment]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Payment>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<PaymentUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<PaymentTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<PaymentTable>? orderBy,
    _isd.OrderByListBuilder<PaymentTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Payment>(
      columnValues: columnValues(Payment.t.updateTable),
      where: where(Payment.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Payment.t),
      orderByList: orderByList?.call(Payment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Payment]s in the list and returns the deleted rows.
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
  Future<List<Payment>> delete(
    _isd.DatabaseSession session,
    List<Payment> rows, {
    _isd.OrderByBuilder<PaymentTable>? orderBy,
    _isd.OrderByListBuilder<PaymentTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Payment>(
      rows,
      orderBy: orderBy?.call(Payment.t),
      orderByList: orderByList?.call(Payment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Payment].
  Future<Payment> deleteRow(
    _isd.DatabaseSession session,
    Payment row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Payment>(
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
  Future<List<Payment>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<PaymentTable> where,
    _isd.OrderByBuilder<PaymentTable>? orderBy,
    _isd.OrderByListBuilder<PaymentTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Payment>(
      where: where(Payment.t),
      orderBy: orderBy?.call(Payment.t),
      orderByList: orderByList?.call(Payment.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<PaymentTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<Payment>(
      where: where?.call(Payment.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Payment] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<PaymentTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Payment>(
      where: where(Payment.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
