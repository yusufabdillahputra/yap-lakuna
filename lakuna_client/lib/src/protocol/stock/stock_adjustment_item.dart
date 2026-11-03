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

/// Baris dokumen penyesuaian: stok sistem saat disimpan, stok fisik, dan
/// selisihnya (mili-satuan dasar).
abstract class StockAdjustmentItem
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  StockAdjustmentItem._({
    _isc.UuidValue? id,
    required this.tenantId,
    required this.adjustmentId,
    required this.variantId,
    required this.systemMilli,
    required this.physicalMilli,
    required this.differenceMilli,
    required this.unitCost,
    required this.value,
    this.note,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _isc.Uuid().v7obj(),
       sortOrder = sortOrder ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory StockAdjustmentItem({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue adjustmentId,
    required _isc.UuidValue variantId,
    required int systemMilli,
    required int physicalMilli,
    required int differenceMilli,
    required int unitCost,
    required int value,
    String? note,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _StockAdjustmentItemImpl;

  factory StockAdjustmentItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return StockAdjustmentItem(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      adjustmentId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['adjustmentId'],
      ),
      variantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['variantId'],
      ),
      systemMilli: jsonSerialization['systemMilli'] as int,
      physicalMilli: jsonSerialization['physicalMilli'] as int,
      differenceMilli: jsonSerialization['differenceMilli'] as int,
      unitCost: jsonSerialization['unitCost'] as int,
      value: jsonSerialization['value'] as int,
      note: jsonSerialization['note'] as String?,
      sortOrder: jsonSerialization['sortOrder'] as int?,
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

  static final t = StockAdjustmentItemTable();

  static const db = StockAdjustmentItemRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue adjustmentId;

  _isc.UuidValue variantId;

  int systemMilli;

  int physicalMilli;

  int differenceMilli;

  /// HPP per satuan dasar saat disimpan (rupiah).
  int unitCost;

  /// Nilai selisih (rupiah, bertanda).
  int value;

  String? note;

  int sortOrder;

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

  /// Returns a shallow copy of this [StockAdjustmentItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  StockAdjustmentItem copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? adjustmentId,
    _isc.UuidValue? variantId,
    int? systemMilli,
    int? physicalMilli,
    int? differenceMilli,
    int? unitCost,
    int? value,
    String? note,
    int? sortOrder,
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
      '__className__': 'StockAdjustmentItem',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'adjustmentId': adjustmentId.toJson(),
      'variantId': variantId.toJson(),
      'systemMilli': systemMilli,
      'physicalMilli': physicalMilli,
      'differenceMilli': differenceMilli,
      'unitCost': unitCost,
      'value': value,
      if (note != null) 'note': note,
      'sortOrder': sortOrder,
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
      '__className__': 'StockAdjustmentItem',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'adjustmentId': adjustmentId.toJson(),
      'variantId': variantId.toJson(),
      'systemMilli': systemMilli,
      'physicalMilli': physicalMilli,
      'differenceMilli': differenceMilli,
      'unitCost': unitCost,
      'value': value,
      if (note != null) 'note': note,
      'sortOrder': sortOrder,
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

  static StockAdjustmentItemInclude include() {
    return StockAdjustmentItemInclude._();
  }

  static StockAdjustmentItemIncludeList includeList({
    _isd.WhereExpressionBuilder<StockAdjustmentItemTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StockAdjustmentItemTable>? orderBy,
    _isd.OrderByListBuilder<StockAdjustmentItemTable>? orderByList,
    StockAdjustmentItemInclude? include,
  }) {
    return StockAdjustmentItemIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StockAdjustmentItem.t),
      orderByList: orderByList?.call(StockAdjustmentItem.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StockAdjustmentItemImpl extends StockAdjustmentItem {
  _StockAdjustmentItemImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue adjustmentId,
    required _isc.UuidValue variantId,
    required int systemMilli,
    required int physicalMilli,
    required int differenceMilli,
    required int unitCost,
    required int value,
    String? note,
    int? sortOrder,
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
         adjustmentId: adjustmentId,
         variantId: variantId,
         systemMilli: systemMilli,
         physicalMilli: physicalMilli,
         differenceMilli: differenceMilli,
         unitCost: unitCost,
         value: value,
         note: note,
         sortOrder: sortOrder,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [StockAdjustmentItem]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  StockAdjustmentItem copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? adjustmentId,
    _isc.UuidValue? variantId,
    int? systemMilli,
    int? physicalMilli,
    int? differenceMilli,
    int? unitCost,
    int? value,
    Object? note = _Undefined,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return StockAdjustmentItem(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      adjustmentId: adjustmentId ?? this.adjustmentId,
      variantId: variantId ?? this.variantId,
      systemMilli: systemMilli ?? this.systemMilli,
      physicalMilli: physicalMilli ?? this.physicalMilli,
      differenceMilli: differenceMilli ?? this.differenceMilli,
      unitCost: unitCost ?? this.unitCost,
      value: value ?? this.value,
      note: note is String? ? note : this.note,
      sortOrder: sortOrder ?? this.sortOrder,
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

class StockAdjustmentItemUpdateTable
    extends _isd.UpdateTable<StockAdjustmentItemTable> {
  StockAdjustmentItemUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> tenantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.tenantId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> adjustmentId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.adjustmentId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> variantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.variantId,
    value,
  );

  _isd.ColumnValue<int, int> systemMilli(int value) => _isd.ColumnValue(
    table.systemMilli,
    value,
  );

  _isd.ColumnValue<int, int> physicalMilli(int value) => _isd.ColumnValue(
    table.physicalMilli,
    value,
  );

  _isd.ColumnValue<int, int> differenceMilli(int value) => _isd.ColumnValue(
    table.differenceMilli,
    value,
  );

  _isd.ColumnValue<int, int> unitCost(int value) => _isd.ColumnValue(
    table.unitCost,
    value,
  );

  _isd.ColumnValue<int, int> value(int value) => _isd.ColumnValue(
    table.value,
    value,
  );

  _isd.ColumnValue<String, String> note(String? value) => _isd.ColumnValue(
    table.note,
    value,
  );

  _isd.ColumnValue<int, int> sortOrder(int value) => _isd.ColumnValue(
    table.sortOrder,
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

class StockAdjustmentItemTable extends _isd.Table<_isc.UuidValue> {
  StockAdjustmentItemTable({super.tableRelation})
    : super(tableName: 'stock_adjustment_items') {
    updateTable = StockAdjustmentItemUpdateTable(this);
    tenantId = _isd.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    adjustmentId = _isd.ColumnUuid(
      'adjustment_id',
      this,
      fieldName: 'adjustmentId',
    );
    variantId = _isd.ColumnUuid(
      'variant_id',
      this,
      fieldName: 'variantId',
    );
    systemMilli = _isd.ColumnInt(
      'system_milli',
      this,
      fieldName: 'systemMilli',
    );
    physicalMilli = _isd.ColumnInt(
      'physical_milli',
      this,
      fieldName: 'physicalMilli',
    );
    differenceMilli = _isd.ColumnInt(
      'difference_milli',
      this,
      fieldName: 'differenceMilli',
    );
    unitCost = _isd.ColumnInt(
      'unit_cost',
      this,
      fieldName: 'unitCost',
    );
    value = _isd.ColumnInt(
      'value',
      this,
    );
    note = _isd.ColumnString(
      'note',
      this,
    );
    sortOrder = _isd.ColumnInt(
      'sort_order',
      this,
      hasDefault: true,
      fieldName: 'sortOrder',
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

  late final StockAdjustmentItemUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid adjustmentId;

  late final _isd.ColumnUuid variantId;

  late final _isd.ColumnInt systemMilli;

  late final _isd.ColumnInt physicalMilli;

  late final _isd.ColumnInt differenceMilli;

  /// HPP per satuan dasar saat disimpan (rupiah).
  late final _isd.ColumnInt unitCost;

  /// Nilai selisih (rupiah, bertanda).
  late final _isd.ColumnInt value;

  late final _isd.ColumnString note;

  late final _isd.ColumnInt sortOrder;

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
    adjustmentId,
    variantId,
    systemMilli,
    physicalMilli,
    differenceMilli,
    unitCost,
    value,
    note,
    sortOrder,
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

class StockAdjustmentItemInclude extends _isd.IncludeObject {
  StockAdjustmentItemInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => StockAdjustmentItem.t;
}

class StockAdjustmentItemIncludeList extends _isd.IncludeList {
  StockAdjustmentItemIncludeList._({
    _isd.WhereExpressionBuilder<StockAdjustmentItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StockAdjustmentItem.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => StockAdjustmentItem.t;
}

class StockAdjustmentItemRepository {
  const StockAdjustmentItemRepository._();

  /// Returns a list of [StockAdjustmentItem]s matching the given query parameters.
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
  Future<List<StockAdjustmentItem>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StockAdjustmentItemTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StockAdjustmentItemTable>? orderBy,
    _isd.OrderByListBuilder<StockAdjustmentItemTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StockAdjustmentItem>(
      where: where?.call(StockAdjustmentItem.t),
      orderBy: orderBy?.call(StockAdjustmentItem.t),
      orderByList: orderByList?.call(StockAdjustmentItem.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [StockAdjustmentItem]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `StockAdjustmentItem.t`.
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
  _ida.Stream<List<StockAdjustmentItem>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StockAdjustmentItemTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StockAdjustmentItemTable>? orderBy,
    _isd.OrderByListBuilder<StockAdjustmentItemTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<StockAdjustmentItem>(
      where: where?.call(StockAdjustmentItem.t),
      orderBy: orderBy?.call(StockAdjustmentItem.t),
      orderByList: orderByList?.call(StockAdjustmentItem.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [StockAdjustmentItem] matching the given query parameters.
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
  Future<StockAdjustmentItem?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StockAdjustmentItemTable>? where,
    int? offset,
    _isd.OrderByBuilder<StockAdjustmentItemTable>? orderBy,
    _isd.OrderByListBuilder<StockAdjustmentItemTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StockAdjustmentItem>(
      where: where?.call(StockAdjustmentItem.t),
      orderBy: orderBy?.call(StockAdjustmentItem.t),
      orderByList: orderByList?.call(StockAdjustmentItem.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StockAdjustmentItem] by its [id] or null if no such row exists.
  Future<StockAdjustmentItem?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StockAdjustmentItem>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StockAdjustmentItem]s in the list and returns the inserted rows.
  ///
  /// The returned [StockAdjustmentItem]s will have their `id` fields set.
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
  Future<List<StockAdjustmentItem>> insert(
    _isd.DatabaseSession session,
    List<StockAdjustmentItem> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StockAdjustmentItem>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StockAdjustmentItem] and returns the inserted row.
  ///
  /// The returned [StockAdjustmentItem] will have its `id` field set.
  Future<StockAdjustmentItem> insertRow(
    _isd.DatabaseSession session,
    StockAdjustmentItem row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<StockAdjustmentItem>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StockAdjustmentItem]s in the list and returns the resulting rows.
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
  /// The returned [StockAdjustmentItem]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockAdjustmentItem>> upsert(
    _isd.DatabaseSession session,
    List<StockAdjustmentItem> rows, {
    required _isd.ColumnSelections<StockAdjustmentItemTable> conflictColumns,
    _isd.ColumnSelections<StockAdjustmentItemTable>? updateColumns,
    _isd.WhereExpressionBuilder<StockAdjustmentItemTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StockAdjustmentItem>(
      rows,
      conflictColumns: conflictColumns(StockAdjustmentItem.t),
      updateColumns: updateColumns?.call(StockAdjustmentItem.t),
      updateWhere: updateWhere?.call(StockAdjustmentItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StockAdjustmentItem] and returns the resulting row.
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
  /// The returned [StockAdjustmentItem] will have its `id` field set.
  Future<StockAdjustmentItem?> upsertRow(
    _isd.DatabaseSession session,
    StockAdjustmentItem row, {
    required _isd.ColumnSelections<StockAdjustmentItemTable> conflictColumns,
    _isd.ColumnSelections<StockAdjustmentItemTable>? updateColumns,
    _isd.WhereExpressionBuilder<StockAdjustmentItemTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StockAdjustmentItem>(
      row,
      conflictColumns: conflictColumns(StockAdjustmentItem.t),
      updateColumns: updateColumns?.call(StockAdjustmentItem.t),
      updateWhere: updateWhere?.call(StockAdjustmentItem.t),
      transaction: transaction,
    );
  }

  /// Updates all [StockAdjustmentItem]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockAdjustmentItem>> update(
    _isd.DatabaseSession session,
    List<StockAdjustmentItem> rows, {
    _isd.ColumnSelections<StockAdjustmentItemTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StockAdjustmentItem>(
      rows,
      columns: columns?.call(StockAdjustmentItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StockAdjustmentItem]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StockAdjustmentItem> updateRow(
    _isd.DatabaseSession session,
    StockAdjustmentItem row, {
    _isd.ColumnSelections<StockAdjustmentItemTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<StockAdjustmentItem>(
      row,
      columns: columns?.call(StockAdjustmentItem.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StockAdjustmentItem] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StockAdjustmentItem?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<StockAdjustmentItemUpdateTable>
    columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<StockAdjustmentItem>(
      id,
      columnValues: columnValues(StockAdjustmentItem.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StockAdjustmentItem]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockAdjustmentItem>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<StockAdjustmentItemUpdateTable>
    columnValues,
    required _isd.WhereExpressionBuilder<StockAdjustmentItemTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<StockAdjustmentItemTable>? orderBy,
    _isd.OrderByListBuilder<StockAdjustmentItemTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StockAdjustmentItem>(
      columnValues: columnValues(StockAdjustmentItem.t.updateTable),
      where: where(StockAdjustmentItem.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StockAdjustmentItem.t),
      orderByList: orderByList?.call(StockAdjustmentItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StockAdjustmentItem]s in the list and returns the deleted rows.
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
  Future<List<StockAdjustmentItem>> delete(
    _isd.DatabaseSession session,
    List<StockAdjustmentItem> rows, {
    _isd.OrderByBuilder<StockAdjustmentItemTable>? orderBy,
    _isd.OrderByListBuilder<StockAdjustmentItemTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StockAdjustmentItem>(
      rows,
      orderBy: orderBy?.call(StockAdjustmentItem.t),
      orderByList: orderByList?.call(StockAdjustmentItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StockAdjustmentItem].
  Future<StockAdjustmentItem> deleteRow(
    _isd.DatabaseSession session,
    StockAdjustmentItem row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StockAdjustmentItem>(
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
  Future<List<StockAdjustmentItem>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<StockAdjustmentItemTable> where,
    _isd.OrderByBuilder<StockAdjustmentItemTable>? orderBy,
    _isd.OrderByListBuilder<StockAdjustmentItemTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StockAdjustmentItem>(
      where: where(StockAdjustmentItem.t),
      orderBy: orderBy?.call(StockAdjustmentItem.t),
      orderByList: orderByList?.call(StockAdjustmentItem.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<StockAdjustmentItemTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<StockAdjustmentItem>(
      where: where?.call(StockAdjustmentItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StockAdjustmentItem] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<StockAdjustmentItemTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StockAdjustmentItem>(
      where: where(StockAdjustmentItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
