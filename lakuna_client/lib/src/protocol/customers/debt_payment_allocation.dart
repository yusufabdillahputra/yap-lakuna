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
import '../customers/debt_document_type.dart' as _ip0q7jzd;

/// Bagian pembayaran [debtPaymentId] yang melunasi satu nota atau
/// pembelian. [balanceBefore] = sisa dokumen sebelum alokasi ini.
abstract class DebtPaymentAllocation
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  DebtPaymentAllocation._({
    _isc.UuidValue? id,
    required this.tenantId,
    required this.debtPaymentId,
    required this.documentType,
    this.saleId,
    this.purchaseId,
    required this.amount,
    required this.balanceBefore,
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

  factory DebtPaymentAllocation({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue debtPaymentId,
    required _ip0q7jzd.DebtDocumentType documentType,
    _isc.UuidValue? saleId,
    _isc.UuidValue? purchaseId,
    required int amount,
    required int balanceBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _DebtPaymentAllocationImpl;

  factory DebtPaymentAllocation.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DebtPaymentAllocation(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      debtPaymentId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['debtPaymentId'],
      ),
      documentType: _ip0q7jzd.DebtDocumentType.fromJson(
        (jsonSerialization['documentType'] as String),
      ),
      saleId: jsonSerialization['saleId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['saleId']),
      purchaseId: jsonSerialization['purchaseId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['purchaseId'],
            ),
      amount: jsonSerialization['amount'] as int,
      balanceBefore: jsonSerialization['balanceBefore'] as int,
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

  static final t = DebtPaymentAllocationTable();

  static const db = DebtPaymentAllocationRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue debtPaymentId;

  _ip0q7jzd.DebtDocumentType documentType;

  _isc.UuidValue? saleId;

  _isc.UuidValue? purchaseId;

  int amount;

  int balanceBefore;

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

  /// Returns a shallow copy of this [DebtPaymentAllocation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DebtPaymentAllocation copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? debtPaymentId,
    _ip0q7jzd.DebtDocumentType? documentType,
    _isc.UuidValue? saleId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? purchaseId = const _isc.$UndefinedUuidValue(),
    int? amount,
    int? balanceBefore,
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
      '__className__': 'DebtPaymentAllocation',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'debtPaymentId': debtPaymentId.toJson(),
      'documentType': documentType.toJson(),
      if (saleId != null) 'saleId': saleId?.toJson(),
      if (purchaseId != null) 'purchaseId': purchaseId?.toJson(),
      'amount': amount,
      'balanceBefore': balanceBefore,
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
      '__className__': 'DebtPaymentAllocation',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'debtPaymentId': debtPaymentId.toJson(),
      'documentType': documentType.toJson(),
      if (saleId != null) 'saleId': saleId?.toJson(),
      if (purchaseId != null) 'purchaseId': purchaseId?.toJson(),
      'amount': amount,
      'balanceBefore': balanceBefore,
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

  static DebtPaymentAllocationInclude include() {
    return DebtPaymentAllocationInclude._();
  }

  static DebtPaymentAllocationIncludeList includeList({
    _isd.WhereExpressionBuilder<DebtPaymentAllocationTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<DebtPaymentAllocationTable>? orderBy,
    _isd.OrderByListBuilder<DebtPaymentAllocationTable>? orderByList,
    DebtPaymentAllocationInclude? include,
  }) {
    return DebtPaymentAllocationIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DebtPaymentAllocation.t),
      orderByList: orderByList?.call(DebtPaymentAllocation.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _DebtPaymentAllocationImpl extends DebtPaymentAllocation {
  _DebtPaymentAllocationImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue debtPaymentId,
    required _ip0q7jzd.DebtDocumentType documentType,
    _isc.UuidValue? saleId,
    _isc.UuidValue? purchaseId,
    required int amount,
    required int balanceBefore,
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
         debtPaymentId: debtPaymentId,
         documentType: documentType,
         saleId: saleId,
         purchaseId: purchaseId,
         amount: amount,
         balanceBefore: balanceBefore,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [DebtPaymentAllocation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DebtPaymentAllocation copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? debtPaymentId,
    _ip0q7jzd.DebtDocumentType? documentType,
    _isc.UuidValue? saleId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? purchaseId = const _isc.$UndefinedUuidValue(),
    int? amount,
    int? balanceBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return DebtPaymentAllocation(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      debtPaymentId: debtPaymentId ?? this.debtPaymentId,
      documentType: documentType ?? this.documentType,
      saleId: saleId is _isc.UndefinedSentinel ? this.saleId : saleId,
      purchaseId: purchaseId is _isc.UndefinedSentinel
          ? this.purchaseId
          : purchaseId,
      amount: amount ?? this.amount,
      balanceBefore: balanceBefore ?? this.balanceBefore,
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

class DebtPaymentAllocationUpdateTable
    extends _isd.UpdateTable<DebtPaymentAllocationTable> {
  DebtPaymentAllocationUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> tenantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.tenantId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> debtPaymentId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.debtPaymentId,
    value,
  );

  _isd.ColumnValue<_ip0q7jzd.DebtDocumentType, _ip0q7jzd.DebtDocumentType>
  documentType(_ip0q7jzd.DebtDocumentType value) => _isd.ColumnValue(
    table.documentType,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> saleId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.saleId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> purchaseId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.purchaseId,
    value,
  );

  _isd.ColumnValue<int, int> amount(int value) => _isd.ColumnValue(
    table.amount,
    value,
  );

  _isd.ColumnValue<int, int> balanceBefore(int value) => _isd.ColumnValue(
    table.balanceBefore,
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

class DebtPaymentAllocationTable extends _isd.Table<_isc.UuidValue> {
  DebtPaymentAllocationTable({super.tableRelation})
    : super(tableName: 'debt_payment_allocations') {
    updateTable = DebtPaymentAllocationUpdateTable(this);
    tenantId = _isd.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    debtPaymentId = _isd.ColumnUuid(
      'debt_payment_id',
      this,
      fieldName: 'debtPaymentId',
    );
    documentType = _isd.ColumnEnum(
      'document_type',
      this,
      _isd.EnumSerialization.byName,
      fieldName: 'documentType',
    );
    saleId = _isd.ColumnUuid(
      'sale_id',
      this,
      fieldName: 'saleId',
    );
    purchaseId = _isd.ColumnUuid(
      'purchase_id',
      this,
      fieldName: 'purchaseId',
    );
    amount = _isd.ColumnInt(
      'amount',
      this,
    );
    balanceBefore = _isd.ColumnInt(
      'balance_before',
      this,
      fieldName: 'balanceBefore',
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

  late final DebtPaymentAllocationUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid debtPaymentId;

  late final _isd.ColumnEnum<_ip0q7jzd.DebtDocumentType> documentType;

  late final _isd.ColumnUuid saleId;

  late final _isd.ColumnUuid purchaseId;

  late final _isd.ColumnInt amount;

  late final _isd.ColumnInt balanceBefore;

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
    debtPaymentId,
    documentType,
    saleId,
    purchaseId,
    amount,
    balanceBefore,
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

class DebtPaymentAllocationInclude extends _isd.IncludeObject {
  DebtPaymentAllocationInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => DebtPaymentAllocation.t;
}

class DebtPaymentAllocationIncludeList extends _isd.IncludeList {
  DebtPaymentAllocationIncludeList._({
    _isd.WhereExpressionBuilder<DebtPaymentAllocationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DebtPaymentAllocation.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => DebtPaymentAllocation.t;
}

class DebtPaymentAllocationRepository {
  const DebtPaymentAllocationRepository._();

  /// Returns a list of [DebtPaymentAllocation]s matching the given query parameters.
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
  Future<List<DebtPaymentAllocation>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<DebtPaymentAllocationTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<DebtPaymentAllocationTable>? orderBy,
    _isd.OrderByListBuilder<DebtPaymentAllocationTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<DebtPaymentAllocation>(
      where: where?.call(DebtPaymentAllocation.t),
      orderBy: orderBy?.call(DebtPaymentAllocation.t),
      orderByList: orderByList?.call(DebtPaymentAllocation.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [DebtPaymentAllocation]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `DebtPaymentAllocation.t`.
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
  _ida.Stream<List<DebtPaymentAllocation>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<DebtPaymentAllocationTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<DebtPaymentAllocationTable>? orderBy,
    _isd.OrderByListBuilder<DebtPaymentAllocationTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<DebtPaymentAllocation>(
      where: where?.call(DebtPaymentAllocation.t),
      orderBy: orderBy?.call(DebtPaymentAllocation.t),
      orderByList: orderByList?.call(DebtPaymentAllocation.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [DebtPaymentAllocation] matching the given query parameters.
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
  Future<DebtPaymentAllocation?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<DebtPaymentAllocationTable>? where,
    int? offset,
    _isd.OrderByBuilder<DebtPaymentAllocationTable>? orderBy,
    _isd.OrderByListBuilder<DebtPaymentAllocationTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<DebtPaymentAllocation>(
      where: where?.call(DebtPaymentAllocation.t),
      orderBy: orderBy?.call(DebtPaymentAllocation.t),
      orderByList: orderByList?.call(DebtPaymentAllocation.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [DebtPaymentAllocation] by its [id] or null if no such row exists.
  Future<DebtPaymentAllocation?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<DebtPaymentAllocation>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [DebtPaymentAllocation]s in the list and returns the inserted rows.
  ///
  /// The returned [DebtPaymentAllocation]s will have their `id` fields set.
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
  Future<List<DebtPaymentAllocation>> insert(
    _isd.DatabaseSession session,
    List<DebtPaymentAllocation> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<DebtPaymentAllocation>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [DebtPaymentAllocation] and returns the inserted row.
  ///
  /// The returned [DebtPaymentAllocation] will have its `id` field set.
  Future<DebtPaymentAllocation> insertRow(
    _isd.DatabaseSession session,
    DebtPaymentAllocation row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<DebtPaymentAllocation>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [DebtPaymentAllocation]s in the list and returns the resulting rows.
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
  /// The returned [DebtPaymentAllocation]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DebtPaymentAllocation>> upsert(
    _isd.DatabaseSession session,
    List<DebtPaymentAllocation> rows, {
    required _isd.ColumnSelections<DebtPaymentAllocationTable> conflictColumns,
    _isd.ColumnSelections<DebtPaymentAllocationTable>? updateColumns,
    _isd.WhereExpressionBuilder<DebtPaymentAllocationTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<DebtPaymentAllocation>(
      rows,
      conflictColumns: conflictColumns(DebtPaymentAllocation.t),
      updateColumns: updateColumns?.call(DebtPaymentAllocation.t),
      updateWhere: updateWhere?.call(DebtPaymentAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [DebtPaymentAllocation] and returns the resulting row.
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
  /// The returned [DebtPaymentAllocation] will have its `id` field set.
  Future<DebtPaymentAllocation?> upsertRow(
    _isd.DatabaseSession session,
    DebtPaymentAllocation row, {
    required _isd.ColumnSelections<DebtPaymentAllocationTable> conflictColumns,
    _isd.ColumnSelections<DebtPaymentAllocationTable>? updateColumns,
    _isd.WhereExpressionBuilder<DebtPaymentAllocationTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<DebtPaymentAllocation>(
      row,
      conflictColumns: conflictColumns(DebtPaymentAllocation.t),
      updateColumns: updateColumns?.call(DebtPaymentAllocation.t),
      updateWhere: updateWhere?.call(DebtPaymentAllocation.t),
      transaction: transaction,
    );
  }

  /// Updates all [DebtPaymentAllocation]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DebtPaymentAllocation>> update(
    _isd.DatabaseSession session,
    List<DebtPaymentAllocation> rows, {
    _isd.ColumnSelections<DebtPaymentAllocationTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<DebtPaymentAllocation>(
      rows,
      columns: columns?.call(DebtPaymentAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [DebtPaymentAllocation]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DebtPaymentAllocation> updateRow(
    _isd.DatabaseSession session,
    DebtPaymentAllocation row, {
    _isd.ColumnSelections<DebtPaymentAllocationTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<DebtPaymentAllocation>(
      row,
      columns: columns?.call(DebtPaymentAllocation.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DebtPaymentAllocation] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DebtPaymentAllocation?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<DebtPaymentAllocationUpdateTable>
    columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<DebtPaymentAllocation>(
      id,
      columnValues: columnValues(DebtPaymentAllocation.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DebtPaymentAllocation]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<DebtPaymentAllocation>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<DebtPaymentAllocationUpdateTable>
    columnValues,
    required _isd.WhereExpressionBuilder<DebtPaymentAllocationTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<DebtPaymentAllocationTable>? orderBy,
    _isd.OrderByListBuilder<DebtPaymentAllocationTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<DebtPaymentAllocation>(
      columnValues: columnValues(DebtPaymentAllocation.t.updateTable),
      where: where(DebtPaymentAllocation.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DebtPaymentAllocation.t),
      orderByList: orderByList?.call(DebtPaymentAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [DebtPaymentAllocation]s in the list and returns the deleted rows.
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
  Future<List<DebtPaymentAllocation>> delete(
    _isd.DatabaseSession session,
    List<DebtPaymentAllocation> rows, {
    _isd.OrderByBuilder<DebtPaymentAllocationTable>? orderBy,
    _isd.OrderByListBuilder<DebtPaymentAllocationTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<DebtPaymentAllocation>(
      rows,
      orderBy: orderBy?.call(DebtPaymentAllocation.t),
      orderByList: orderByList?.call(DebtPaymentAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [DebtPaymentAllocation].
  Future<DebtPaymentAllocation> deleteRow(
    _isd.DatabaseSession session,
    DebtPaymentAllocation row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DebtPaymentAllocation>(
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
  Future<List<DebtPaymentAllocation>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<DebtPaymentAllocationTable> where,
    _isd.OrderByBuilder<DebtPaymentAllocationTable>? orderBy,
    _isd.OrderByListBuilder<DebtPaymentAllocationTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<DebtPaymentAllocation>(
      where: where(DebtPaymentAllocation.t),
      orderBy: orderBy?.call(DebtPaymentAllocation.t),
      orderByList: orderByList?.call(DebtPaymentAllocation.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<DebtPaymentAllocationTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<DebtPaymentAllocation>(
      where: where?.call(DebtPaymentAllocation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DebtPaymentAllocation] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<DebtPaymentAllocationTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DebtPaymentAllocation>(
      where: where(DebtPaymentAllocation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
