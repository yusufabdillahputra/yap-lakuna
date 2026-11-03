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

/// Baris dokumen penyesuaian: stok sistem saat disimpan, stok fisik, dan
/// selisihnya (mili-satuan dasar).
abstract class StockAdjustmentItem
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  StockAdjustmentItem._({
    _is.UuidValue? id,
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
  }) : id = id ?? const _is.Uuid().v7obj(),
       sortOrder = sortOrder ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory StockAdjustmentItem({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue adjustmentId,
    required _is.UuidValue variantId,
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
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _StockAdjustmentItemImpl;

  factory StockAdjustmentItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return StockAdjustmentItem(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      adjustmentId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['adjustmentId'],
      ),
      variantId: _is.UuidValueJsonExtension.fromJson(
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

  static final t = StockAdjustmentItemTable();

  static const db = StockAdjustmentItemRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue adjustmentId;

  _is.UuidValue variantId;

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

  _is.UuidValue? createdBy;

  _is.UuidValue? updatedBy;

  int version;

  String hlc;

  _is.UuidValue? originDeviceId;

  @override
  _is.Table<_is.UuidValue> get table => t;

  /// Returns a shallow copy of this [StockAdjustmentItem]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StockAdjustmentItem copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? adjustmentId,
    _is.UuidValue? variantId,
    int? systemMilli,
    int? physicalMilli,
    int? differenceMilli,
    int? unitCost,
    int? value,
    String? note,
    int? sortOrder,
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
    _is.WhereExpressionBuilder<StockAdjustmentItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockAdjustmentItemTable>? orderBy,
    _is.OrderByListBuilder<StockAdjustmentItemTable>? orderByList,
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
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StockAdjustmentItemImpl extends StockAdjustmentItem {
  _StockAdjustmentItemImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue adjustmentId,
    required _is.UuidValue variantId,
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
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
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
  @_is.useResult
  @override
  StockAdjustmentItem copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? adjustmentId,
    _is.UuidValue? variantId,
    int? systemMilli,
    int? physicalMilli,
    int? differenceMilli,
    int? unitCost,
    int? value,
    Object? note = _Undefined,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
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

class StockAdjustmentItemUpdateTable
    extends _is.UpdateTable<StockAdjustmentItemTable> {
  StockAdjustmentItemUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> adjustmentId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.adjustmentId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> variantId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.variantId,
    value,
  );

  _is.ColumnValue<int, int> systemMilli(int value) => _is.ColumnValue(
    table.systemMilli,
    value,
  );

  _is.ColumnValue<int, int> physicalMilli(int value) => _is.ColumnValue(
    table.physicalMilli,
    value,
  );

  _is.ColumnValue<int, int> differenceMilli(int value) => _is.ColumnValue(
    table.differenceMilli,
    value,
  );

  _is.ColumnValue<int, int> unitCost(int value) => _is.ColumnValue(
    table.unitCost,
    value,
  );

  _is.ColumnValue<int, int> value(int value) => _is.ColumnValue(
    table.value,
    value,
  );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
    value,
  );

  _is.ColumnValue<int, int> sortOrder(int value) => _is.ColumnValue(
    table.sortOrder,
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

class StockAdjustmentItemTable extends _is.Table<_is.UuidValue> {
  StockAdjustmentItemTable({super.tableRelation})
    : super(tableName: 'stock_adjustment_items') {
    updateTable = StockAdjustmentItemUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    adjustmentId = _is.ColumnUuid(
      'adjustment_id',
      this,
      fieldName: 'adjustmentId',
    );
    variantId = _is.ColumnUuid(
      'variant_id',
      this,
      fieldName: 'variantId',
    );
    systemMilli = _is.ColumnInt(
      'system_milli',
      this,
      fieldName: 'systemMilli',
    );
    physicalMilli = _is.ColumnInt(
      'physical_milli',
      this,
      fieldName: 'physicalMilli',
    );
    differenceMilli = _is.ColumnInt(
      'difference_milli',
      this,
      fieldName: 'differenceMilli',
    );
    unitCost = _is.ColumnInt(
      'unit_cost',
      this,
      fieldName: 'unitCost',
    );
    value = _is.ColumnInt(
      'value',
      this,
    );
    note = _is.ColumnString(
      'note',
      this,
    );
    sortOrder = _is.ColumnInt(
      'sort_order',
      this,
      hasDefault: true,
      fieldName: 'sortOrder',
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

  late final StockAdjustmentItemUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid adjustmentId;

  late final _is.ColumnUuid variantId;

  late final _is.ColumnInt systemMilli;

  late final _is.ColumnInt physicalMilli;

  late final _is.ColumnInt differenceMilli;

  /// HPP per satuan dasar saat disimpan (rupiah).
  late final _is.ColumnInt unitCost;

  /// Nilai selisih (rupiah, bertanda).
  late final _is.ColumnInt value;

  late final _is.ColumnString note;

  late final _is.ColumnInt sortOrder;

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

class StockAdjustmentItemInclude extends _is.IncludeObject {
  StockAdjustmentItemInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => StockAdjustmentItem.t;
}

class StockAdjustmentItemIncludeList extends _is.IncludeList {
  StockAdjustmentItemIncludeList._({
    _is.WhereExpressionBuilder<StockAdjustmentItemTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StockAdjustmentItem.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => StockAdjustmentItem.t;
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockAdjustmentItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockAdjustmentItemTable>? orderBy,
    _is.OrderByListBuilder<StockAdjustmentItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockAdjustmentItemTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockAdjustmentItemTable>? orderBy,
    _is.OrderByListBuilder<StockAdjustmentItemTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockAdjustmentItemTable>? where,
    int? offset,
    _is.OrderByBuilder<StockAdjustmentItemTable>? orderBy,
    _is.OrderByListBuilder<StockAdjustmentItemTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
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
    _is.DatabaseSession session,
    List<StockAdjustmentItem> rows, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    StockAdjustmentItem row, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<StockAdjustmentItem> rows, {
    required _is.ColumnSelections<StockAdjustmentItemTable> conflictColumns,
    _is.ColumnSelections<StockAdjustmentItemTable>? updateColumns,
    _is.WhereExpressionBuilder<StockAdjustmentItemTable>? updateWhere,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    StockAdjustmentItem row, {
    required _is.ColumnSelections<StockAdjustmentItemTable> conflictColumns,
    _is.ColumnSelections<StockAdjustmentItemTable>? updateColumns,
    _is.WhereExpressionBuilder<StockAdjustmentItemTable>? updateWhere,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<StockAdjustmentItem> rows, {
    _is.ColumnSelections<StockAdjustmentItemTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    StockAdjustmentItem row, {
    _is.ColumnSelections<StockAdjustmentItemTable>? columns,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<StockAdjustmentItemUpdateTable>
    columnValues,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StockAdjustmentItemUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<StockAdjustmentItemTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockAdjustmentItemTable>? orderBy,
    _is.OrderByListBuilder<StockAdjustmentItemTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    List<StockAdjustmentItem> rows, {
    _is.OrderByBuilder<StockAdjustmentItemTable>? orderBy,
    _is.OrderByListBuilder<StockAdjustmentItemTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session,
    StockAdjustmentItem row, {
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StockAdjustmentItemTable> where,
    _is.OrderByBuilder<StockAdjustmentItemTable>? orderBy,
    _is.OrderByListBuilder<StockAdjustmentItemTable>? orderByList,
    _is.Transaction? transaction,
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
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockAdjustmentItemTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StockAdjustmentItem>(
      where: where?.call(StockAdjustmentItem.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StockAdjustmentItem] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StockAdjustmentItemTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StockAdjustmentItem>(
      where: where(StockAdjustmentItem.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
