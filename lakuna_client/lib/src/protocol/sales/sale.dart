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
import '../sales/sale_status.dart' as _i3rqzpgm;

/// Nota penjualan (F1-04/F1-05). Nomor memuat kode cabang dan perangkat
/// (`PST-K01-261103-0001`) agar unik tanpa koordinasi saat sync.
abstract class Sale
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  Sale._({
    _isc.UuidValue? id,
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

  factory Sale({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue deviceId,
    _isc.UuidValue? cashSessionId,
    required _isc.UuidValue staffId,
    required String number,
    required _i3rqzpgm.SaleStatus status,
    required int subtotal,
    required int tierDiscount,
    required int total,
    required int paidAmount,
    required int changeAmount,
    required int itemCount,
    required DateTime soldAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _SaleImpl;

  factory Sale.fromJson(Map<String, dynamic> jsonSerialization) {
    return Sale(
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
      staffId: _isc.UuidValueJsonExtension.fromJson(
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
      soldAt: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['soldAt']),
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

  static final t = SaleTable();

  static const db = SaleRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue outletId;

  _isc.UuidValue deviceId;

  _isc.UuidValue? cashSessionId;

  _isc.UuidValue staffId;

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

  /// Returns a shallow copy of this [Sale]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Sale copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? deviceId,
    _isc.UuidValue? cashSessionId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? staffId,
    String? number,
    _i3rqzpgm.SaleStatus? status,
    int? subtotal,
    int? tierDiscount,
    int? total,
    int? paidAmount,
    int? changeAmount,
    int? itemCount,
    DateTime? soldAt,
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
    _isd.WhereExpressionBuilder<SaleTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleTable>? orderBy,
    _isd.OrderByListBuilder<SaleTable>? orderByList,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _SaleImpl extends Sale {
  _SaleImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue outletId,
    required _isc.UuidValue deviceId,
    _isc.UuidValue? cashSessionId,
    required _isc.UuidValue staffId,
    required String number,
    required _i3rqzpgm.SaleStatus status,
    required int subtotal,
    required int tierDiscount,
    required int total,
    required int paidAmount,
    required int changeAmount,
    required int itemCount,
    required DateTime soldAt,
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
  @_isc.useResult
  @override
  Sale copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId,
    _isc.UuidValue? deviceId,
    _isc.UuidValue? cashSessionId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? staffId,
    String? number,
    _i3rqzpgm.SaleStatus? status,
    int? subtotal,
    int? tierDiscount,
    int? total,
    int? paidAmount,
    int? changeAmount,
    int? itemCount,
    DateTime? soldAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return Sale(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      deviceId: deviceId ?? this.deviceId,
      cashSessionId: cashSessionId is _isc.UndefinedSentinel
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

class SaleUpdateTable extends _isd.UpdateTable<SaleTable> {
  SaleUpdateTable(super.table);

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

  _isd.ColumnValue<_i3rqzpgm.SaleStatus, _i3rqzpgm.SaleStatus> status(
    _i3rqzpgm.SaleStatus value,
  ) => _isd.ColumnValue(
    table.status,
    value,
  );

  _isd.ColumnValue<int, int> subtotal(int value) => _isd.ColumnValue(
    table.subtotal,
    value,
  );

  _isd.ColumnValue<int, int> tierDiscount(int value) => _isd.ColumnValue(
    table.tierDiscount,
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

  _isd.ColumnValue<int, int> changeAmount(int value) => _isd.ColumnValue(
    table.changeAmount,
    value,
  );

  _isd.ColumnValue<int, int> itemCount(int value) => _isd.ColumnValue(
    table.itemCount,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> soldAt(DateTime value) =>
      _isd.ColumnValue(
        table.soldAt,
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

class SaleTable extends _isd.Table<_isc.UuidValue> {
  SaleTable({super.tableRelation}) : super(tableName: 'sales') {
    updateTable = SaleUpdateTable(this);
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
    staffId = _isd.ColumnUuid(
      'staff_id',
      this,
      fieldName: 'staffId',
    );
    number = _isd.ColumnString(
      'number',
      this,
    );
    status = _isd.ColumnEnum(
      'status',
      this,
      _isd.EnumSerialization.byName,
    );
    subtotal = _isd.ColumnInt(
      'subtotal',
      this,
    );
    tierDiscount = _isd.ColumnInt(
      'tier_discount',
      this,
      fieldName: 'tierDiscount',
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
    changeAmount = _isd.ColumnInt(
      'change_amount',
      this,
      fieldName: 'changeAmount',
    );
    itemCount = _isd.ColumnInt(
      'item_count',
      this,
      fieldName: 'itemCount',
    );
    soldAt = _isd.ColumnDateTime(
      'sold_at',
      this,
      fieldName: 'soldAt',
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

  late final SaleUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid outletId;

  late final _isd.ColumnUuid deviceId;

  late final _isd.ColumnUuid cashSessionId;

  late final _isd.ColumnUuid staffId;

  late final _isd.ColumnString number;

  late final _isd.ColumnEnum<_i3rqzpgm.SaleStatus> status;

  /// Σ harga daftar × jumlah (sebelum grosir), rupiah.
  late final _isd.ColumnInt subtotal;

  late final _isd.ColumnInt tierDiscount;

  late final _isd.ColumnInt total;

  late final _isd.ColumnInt paidAmount;

  late final _isd.ColumnInt changeAmount;

  /// Jumlah baris item.
  late final _isd.ColumnInt itemCount;

  late final _isd.ColumnDateTime soldAt;

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

class SaleInclude extends _isd.IncludeObject {
  SaleInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => Sale.t;
}

class SaleIncludeList extends _isd.IncludeList {
  SaleIncludeList._({
    _isd.WhereExpressionBuilder<SaleTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Sale.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => Sale.t;
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleTable>? orderBy,
    _isd.OrderByListBuilder<SaleTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleTable>? orderBy,
    _isd.OrderByListBuilder<SaleTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleTable>? where,
    int? offset,
    _isd.OrderByBuilder<SaleTable>? orderBy,
    _isd.OrderByListBuilder<SaleTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session,
    List<Sale> rows, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    Sale row, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<Sale> rows, {
    required _isd.ColumnSelections<SaleTable> conflictColumns,
    _isd.ColumnSelections<SaleTable>? updateColumns,
    _isd.WhereExpressionBuilder<SaleTable>? updateWhere,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    Sale row, {
    required _isd.ColumnSelections<SaleTable> conflictColumns,
    _isd.ColumnSelections<SaleTable>? updateColumns,
    _isd.WhereExpressionBuilder<SaleTable>? updateWhere,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<Sale> rows, {
    _isd.ColumnSelections<SaleTable>? columns,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    Sale row, {
    _isd.ColumnSelections<SaleTable>? columns,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<SaleUpdateTable> columnValues,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<SaleUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<SaleTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleTable>? orderBy,
    _isd.OrderByListBuilder<SaleTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<Sale> rows, {
    _isd.OrderByBuilder<SaleTable>? orderBy,
    _isd.OrderByListBuilder<SaleTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    Sale row, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<SaleTable> where,
    _isd.OrderByBuilder<SaleTable>? orderBy,
    _isd.OrderByListBuilder<SaleTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<Sale>(
      where: where?.call(Sale.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Sale] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<SaleTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Sale>(
      where: where(Sale.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
