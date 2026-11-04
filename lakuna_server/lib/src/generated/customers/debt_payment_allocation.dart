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
import '../customers/debt_document_type.dart' as _ip0q7jzd;

/// Bagian pembayaran [debtPaymentId] yang melunasi satu nota atau
/// pembelian. [balanceBefore] = sisa dokumen sebelum alokasi ini.
abstract class DebtPaymentAllocation
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  DebtPaymentAllocation._({
    _is.UuidValue? id,
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
  }) : id = id ?? const _is.Uuid().v7obj(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory DebtPaymentAllocation({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue debtPaymentId,
    required _ip0q7jzd.DebtDocumentType documentType,
    _is.UuidValue? saleId,
    _is.UuidValue? purchaseId,
    required int amount,
    required int balanceBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _DebtPaymentAllocationImpl;

  factory DebtPaymentAllocation.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return DebtPaymentAllocation(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      debtPaymentId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['debtPaymentId'],
      ),
      documentType: _ip0q7jzd.DebtDocumentType.fromJson(
        (jsonSerialization['documentType'] as String),
      ),
      saleId: jsonSerialization['saleId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['saleId']),
      purchaseId: jsonSerialization['purchaseId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['purchaseId'],
            ),
      amount: jsonSerialization['amount'] as int,
      balanceBefore: jsonSerialization['balanceBefore'] as int,
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

  static final t = DebtPaymentAllocationTable();

  static const db = DebtPaymentAllocationRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue debtPaymentId;

  _ip0q7jzd.DebtDocumentType documentType;

  _is.UuidValue? saleId;

  _is.UuidValue? purchaseId;

  int amount;

  int balanceBefore;

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

  /// Returns a shallow copy of this [DebtPaymentAllocation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DebtPaymentAllocation copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? debtPaymentId,
    _ip0q7jzd.DebtDocumentType? documentType,
    _is.UuidValue? saleId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? purchaseId = const _is.$UndefinedUuidValue(),
    int? amount,
    int? balanceBefore,
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
    _is.WhereExpressionBuilder<DebtPaymentAllocationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DebtPaymentAllocationTable>? orderBy,
    _is.OrderByListBuilder<DebtPaymentAllocationTable>? orderByList,
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
    return _is.SerializationManager.encode(this);
  }
}

class _DebtPaymentAllocationImpl extends DebtPaymentAllocation {
  _DebtPaymentAllocationImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue debtPaymentId,
    required _ip0q7jzd.DebtDocumentType documentType,
    _is.UuidValue? saleId,
    _is.UuidValue? purchaseId,
    required int amount,
    required int balanceBefore,
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
  @_is.useResult
  @override
  DebtPaymentAllocation copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? debtPaymentId,
    _ip0q7jzd.DebtDocumentType? documentType,
    _is.UuidValue? saleId = const _is.$UndefinedUuidValue(),
    _is.UuidValue? purchaseId = const _is.$UndefinedUuidValue(),
    int? amount,
    int? balanceBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return DebtPaymentAllocation(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      debtPaymentId: debtPaymentId ?? this.debtPaymentId,
      documentType: documentType ?? this.documentType,
      saleId: saleId is _is.UndefinedSentinel ? this.saleId : saleId,
      purchaseId: purchaseId is _is.UndefinedSentinel
          ? this.purchaseId
          : purchaseId,
      amount: amount ?? this.amount,
      balanceBefore: balanceBefore ?? this.balanceBefore,
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

class DebtPaymentAllocationUpdateTable
    extends _is.UpdateTable<DebtPaymentAllocationTable> {
  DebtPaymentAllocationUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> debtPaymentId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.debtPaymentId,
    value,
  );

  _is.ColumnValue<_ip0q7jzd.DebtDocumentType, _ip0q7jzd.DebtDocumentType>
  documentType(_ip0q7jzd.DebtDocumentType value) => _is.ColumnValue(
    table.documentType,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> saleId(_is.UuidValue? value) =>
      _is.ColumnValue(
        table.saleId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> purchaseId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.purchaseId,
    value,
  );

  _is.ColumnValue<int, int> amount(int value) => _is.ColumnValue(
    table.amount,
    value,
  );

  _is.ColumnValue<int, int> balanceBefore(int value) => _is.ColumnValue(
    table.balanceBefore,
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

class DebtPaymentAllocationTable extends _is.Table<_is.UuidValue> {
  DebtPaymentAllocationTable({super.tableRelation})
    : super(tableName: 'debt_payment_allocations') {
    updateTable = DebtPaymentAllocationUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    debtPaymentId = _is.ColumnUuid(
      'debt_payment_id',
      this,
      fieldName: 'debtPaymentId',
    );
    documentType = _is.ColumnEnum(
      'document_type',
      this,
      _is.EnumSerialization.byName,
      fieldName: 'documentType',
    );
    saleId = _is.ColumnUuid(
      'sale_id',
      this,
      fieldName: 'saleId',
    );
    purchaseId = _is.ColumnUuid(
      'purchase_id',
      this,
      fieldName: 'purchaseId',
    );
    amount = _is.ColumnInt(
      'amount',
      this,
    );
    balanceBefore = _is.ColumnInt(
      'balance_before',
      this,
      fieldName: 'balanceBefore',
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

  late final DebtPaymentAllocationUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid debtPaymentId;

  late final _is.ColumnEnum<_ip0q7jzd.DebtDocumentType> documentType;

  late final _is.ColumnUuid saleId;

  late final _is.ColumnUuid purchaseId;

  late final _is.ColumnInt amount;

  late final _is.ColumnInt balanceBefore;

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

class DebtPaymentAllocationInclude extends _is.IncludeObject {
  DebtPaymentAllocationInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => DebtPaymentAllocation.t;
}

class DebtPaymentAllocationIncludeList extends _is.IncludeList {
  DebtPaymentAllocationIncludeList._({
    _is.WhereExpressionBuilder<DebtPaymentAllocationTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DebtPaymentAllocation.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => DebtPaymentAllocation.t;
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DebtPaymentAllocationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DebtPaymentAllocationTable>? orderBy,
    _is.OrderByListBuilder<DebtPaymentAllocationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DebtPaymentAllocationTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DebtPaymentAllocationTable>? orderBy,
    _is.OrderByListBuilder<DebtPaymentAllocationTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DebtPaymentAllocationTable>? where,
    int? offset,
    _is.OrderByBuilder<DebtPaymentAllocationTable>? orderBy,
    _is.OrderByListBuilder<DebtPaymentAllocationTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session,
    List<DebtPaymentAllocation> rows, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    DebtPaymentAllocation row, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<DebtPaymentAllocation> rows, {
    required _is.ColumnSelections<DebtPaymentAllocationTable> conflictColumns,
    _is.ColumnSelections<DebtPaymentAllocationTable>? updateColumns,
    _is.WhereExpressionBuilder<DebtPaymentAllocationTable>? updateWhere,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    DebtPaymentAllocation row, {
    required _is.ColumnSelections<DebtPaymentAllocationTable> conflictColumns,
    _is.ColumnSelections<DebtPaymentAllocationTable>? updateColumns,
    _is.WhereExpressionBuilder<DebtPaymentAllocationTable>? updateWhere,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<DebtPaymentAllocation> rows, {
    _is.ColumnSelections<DebtPaymentAllocationTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    DebtPaymentAllocation row, {
    _is.ColumnSelections<DebtPaymentAllocationTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<DebtPaymentAllocationUpdateTable>
    columnValues,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<DebtPaymentAllocationUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<DebtPaymentAllocationTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<DebtPaymentAllocationTable>? orderBy,
    _is.OrderByListBuilder<DebtPaymentAllocationTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<DebtPaymentAllocation> rows, {
    _is.OrderByBuilder<DebtPaymentAllocationTable>? orderBy,
    _is.OrderByListBuilder<DebtPaymentAllocationTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    DebtPaymentAllocation row, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DebtPaymentAllocationTable> where,
    _is.OrderByBuilder<DebtPaymentAllocationTable>? orderBy,
    _is.OrderByListBuilder<DebtPaymentAllocationTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<DebtPaymentAllocationTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<DebtPaymentAllocation>(
      where: where?.call(DebtPaymentAllocation.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [DebtPaymentAllocation] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<DebtPaymentAllocationTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<DebtPaymentAllocation>(
      where: where(DebtPaymentAllocation.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
