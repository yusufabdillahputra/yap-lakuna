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

/// Baris retur penjualan (F1-11): jumlah dan nilai yang dikembalikan dari satu baris nota.
abstract class SaleReturnItem
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  SaleReturnItem._({
    _isc.UuidValue? id,
    required this.tenantId,
    required this.saleReturnId,
    required this.saleItemId,
    required this.quantityMilli,
    required this.amount,
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

  factory SaleReturnItem({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue saleReturnId,
    required _isc.UuidValue saleItemId,
    required int quantityMilli,
    required int amount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _SaleReturnItemImpl;

  factory SaleReturnItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return SaleReturnItem(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      saleReturnId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['saleReturnId'],
      ),
      saleItemId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['saleItemId'],
      ),
      quantityMilli: jsonSerialization['quantityMilli'] as int,
      amount: jsonSerialization['amount'] as int,
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

  static final t = SaleReturnItemTable();

  static const db = SaleReturnItemRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue saleReturnId;

  _isc.UuidValue saleItemId;

  int quantityMilli;

  int amount;

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

  /// Returns a shallow copy of this [SaleReturnItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SaleReturnItem copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? saleReturnId,
    _isc.UuidValue? saleItemId,
    int? quantityMilli,
    int? amount,
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
      '__className__': 'SaleReturnItem',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'saleReturnId': saleReturnId.toJson(),
      'saleItemId': saleItemId.toJson(),
      'quantityMilli': quantityMilli,
      'amount': amount,
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
      '__className__': 'SaleReturnItem',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'saleReturnId': saleReturnId.toJson(),
      'saleItemId': saleItemId.toJson(),
      'quantityMilli': quantityMilli,
      'amount': amount,
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

  static SaleReturnItemInclude include() {
    return SaleReturnItemInclude._();
  }

  static SaleReturnItemIncludeList includeList({
    _isd.WhereExpressionBuilder<SaleReturnItemTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleReturnItemTable>? orderBy,
    _isd.OrderByListBuilder<SaleReturnItemTable>? orderByList,
    SaleReturnItemInclude? include,
  }) {
    return SaleReturnItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SaleReturnItem.t),
      orderByList: orderByList?.call(SaleReturnItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _SaleReturnItemImpl extends SaleReturnItem {
  _SaleReturnItemImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue saleReturnId,
    required _isc.UuidValue saleItemId,
    required int quantityMilli,
    required int amount,
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
         saleReturnId: saleReturnId,
         saleItemId: saleItemId,
         quantityMilli: quantityMilli,
         amount: amount,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [SaleReturnItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SaleReturnItem copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? saleReturnId,
    _isc.UuidValue? saleItemId,
    int? quantityMilli,
    int? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return SaleReturnItem(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      saleReturnId: saleReturnId ?? this.saleReturnId,
      saleItemId: saleItemId ?? this.saleItemId,
      quantityMilli: quantityMilli ?? this.quantityMilli,
      amount: amount ?? this.amount,
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

class SaleReturnItemUpdateTable extends _isd.UpdateTable<SaleReturnItemTable> {
  SaleReturnItemUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> tenantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.tenantId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> saleReturnId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.saleReturnId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> saleItemId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.saleItemId,
    value,
  );

  _isd.ColumnValue<int, int> quantityMilli(int value) => _isd.ColumnValue(
    table.quantityMilli,
    value,
  );

  _isd.ColumnValue<int, int> amount(int value) => _isd.ColumnValue(
    table.amount,
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

class SaleReturnItemTable extends _isd.Table<_isc.UuidValue> {
  SaleReturnItemTable({super.tableRelation})
    : super(tableName: 'sale_return_items') {
    updateTable = SaleReturnItemUpdateTable(this);
    tenantId = _isd.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    saleReturnId = _isd.ColumnUuid(
      'sale_return_id',
      this,
      fieldName: 'saleReturnId',
    );
    saleItemId = _isd.ColumnUuid(
      'sale_item_id',
      this,
      fieldName: 'saleItemId',
    );
    quantityMilli = _isd.ColumnInt(
      'quantity_milli',
      this,
      fieldName: 'quantityMilli',
    );
    amount = _isd.ColumnInt(
      'amount',
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

  late final SaleReturnItemUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid saleReturnId;

  late final _isd.ColumnUuid saleItemId;

  late final _isd.ColumnInt quantityMilli;

  late final _isd.ColumnInt amount;

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
    saleReturnId,
    saleItemId,
    quantityMilli,
    amount,
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

class SaleReturnItemInclude extends _isd.IncludeObject {
  SaleReturnItemInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => SaleReturnItem.t;
}

class SaleReturnItemIncludeList extends _isd.IncludeList {
  SaleReturnItemIncludeList._({
    _isd.WhereExpressionBuilder<SaleReturnItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SaleReturnItem.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => SaleReturnItem.t;
}

class SaleReturnItemRepository {
  const SaleReturnItemRepository._();

  /// Returns a list of [SaleReturnItem]s matching the given query parameters.
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
  Future<List<SaleReturnItem>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleReturnItemTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleReturnItemTable>? orderBy,
    _isd.OrderByListBuilder<SaleReturnItemTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SaleReturnItem>(
      where: where?.call(SaleReturnItem.t),
      orderBy: orderBy?.call(SaleReturnItem.t),
      orderByList: orderByList?.call(SaleReturnItem.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [SaleReturnItem]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `SaleReturnItem.t`.
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
  _ida.Stream<List<SaleReturnItem>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleReturnItemTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleReturnItemTable>? orderBy,
    _isd.OrderByListBuilder<SaleReturnItemTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<SaleReturnItem>(
      where: where?.call(SaleReturnItem.t),
      orderBy: orderBy?.call(SaleReturnItem.t),
      orderByList: orderByList?.call(SaleReturnItem.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [SaleReturnItem] matching the given query parameters.
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
  Future<SaleReturnItem?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleReturnItemTable>? where,
    int? offset,
    _isd.OrderByBuilder<SaleReturnItemTable>? orderBy,
    _isd.OrderByListBuilder<SaleReturnItemTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SaleReturnItem>(
      where: where?.call(SaleReturnItem.t),
      orderBy: orderBy?.call(SaleReturnItem.t),
      orderByList: orderByList?.call(SaleReturnItem.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SaleReturnItem] by its [id] or null if no such row exists.
  Future<SaleReturnItem?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SaleReturnItem>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SaleReturnItem]s in the list and returns the inserted rows.
  ///
  /// The returned [SaleReturnItem]s will have their `id` fields set.
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
  Future<List<SaleReturnItem>> insert(
    _isd.DatabaseSession session,
    List<SaleReturnItem> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SaleReturnItem>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SaleReturnItem] and returns the inserted row.
  ///
  /// The returned [SaleReturnItem] will have its `id` field set.
  Future<SaleReturnItem> insertRow(
    _isd.DatabaseSession session,
    SaleReturnItem row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<SaleReturnItem>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SaleReturnItem]s in the list and returns the resulting rows.
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
  /// The returned [SaleReturnItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleReturnItem>> upsert(
    _isd.DatabaseSession session,
    List<SaleReturnItem> rows, {
    required _isd.ColumnSelections<SaleReturnItemTable> conflictColumns,
    _isd.ColumnSelections<SaleReturnItemTable>? updateColumns,
    _isd.WhereExpressionBuilder<SaleReturnItemTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SaleReturnItem>(
      rows,
      conflictColumns: conflictColumns(SaleReturnItem.t),
      updateColumns: updateColumns?.call(SaleReturnItem.t),
      updateWhere: updateWhere?.call(SaleReturnItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SaleReturnItem] and returns the resulting row.
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
  /// The returned [SaleReturnItem] will have its `id` field set.
  Future<SaleReturnItem?> upsertRow(
    _isd.DatabaseSession session,
    SaleReturnItem row, {
    required _isd.ColumnSelections<SaleReturnItemTable> conflictColumns,
    _isd.ColumnSelections<SaleReturnItemTable>? updateColumns,
    _isd.WhereExpressionBuilder<SaleReturnItemTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SaleReturnItem>(
      row,
      conflictColumns: conflictColumns(SaleReturnItem.t),
      updateColumns: updateColumns?.call(SaleReturnItem.t),
      updateWhere: updateWhere?.call(SaleReturnItem.t),
      transaction: transaction,
    );
  }

  /// Updates all [SaleReturnItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleReturnItem>> update(
    _isd.DatabaseSession session,
    List<SaleReturnItem> rows, {
    _isd.ColumnSelections<SaleReturnItemTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SaleReturnItem>(
      rows,
      columns: columns?.call(SaleReturnItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SaleReturnItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SaleReturnItem> updateRow(
    _isd.DatabaseSession session,
    SaleReturnItem row, {
    _isd.ColumnSelections<SaleReturnItemTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<SaleReturnItem>(
      row,
      columns: columns?.call(SaleReturnItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SaleReturnItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SaleReturnItem?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<SaleReturnItemUpdateTable>
    columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<SaleReturnItem>(
      id,
      columnValues: columnValues(SaleReturnItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SaleReturnItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SaleReturnItem>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<SaleReturnItemUpdateTable>
    columnValues,
    required _isd.WhereExpressionBuilder<SaleReturnItemTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SaleReturnItemTable>? orderBy,
    _isd.OrderByListBuilder<SaleReturnItemTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SaleReturnItem>(
      columnValues: columnValues(SaleReturnItem.t.updateTable),
      where: where(SaleReturnItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SaleReturnItem.t),
      orderByList: orderByList?.call(SaleReturnItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SaleReturnItem]s in the list and returns the deleted rows.
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
  Future<List<SaleReturnItem>> delete(
    _isd.DatabaseSession session,
    List<SaleReturnItem> rows, {
    _isd.OrderByBuilder<SaleReturnItemTable>? orderBy,
    _isd.OrderByListBuilder<SaleReturnItemTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SaleReturnItem>(
      rows,
      orderBy: orderBy?.call(SaleReturnItem.t),
      orderByList: orderByList?.call(SaleReturnItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SaleReturnItem].
  Future<SaleReturnItem> deleteRow(
    _isd.DatabaseSession session,
    SaleReturnItem row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SaleReturnItem>(
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
  Future<List<SaleReturnItem>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<SaleReturnItemTable> where,
    _isd.OrderByBuilder<SaleReturnItemTable>? orderBy,
    _isd.OrderByListBuilder<SaleReturnItemTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SaleReturnItem>(
      where: where(SaleReturnItem.t),
      orderBy: orderBy?.call(SaleReturnItem.t),
      orderByList: orderByList?.call(SaleReturnItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SaleReturnItemTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<SaleReturnItem>(
      where: where?.call(SaleReturnItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SaleReturnItem] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<SaleReturnItemTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SaleReturnItem>(
      where: where(SaleReturnItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
