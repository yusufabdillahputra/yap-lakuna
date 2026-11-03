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
import '../catalog/stock_source_type.dart' as _iyl2alwo;

/// Ledger stok: satu baris per pergerakan, tidak pernah diubah. Jumlah dalam
/// mili-satuan dasar, positif = masuk.
abstract class StockMovement
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  StockMovement._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.outletId,
    required this.stockLocationId,
    required this.variantId,
    required this.quantityMilli,
    required this.unitCost,
    required this.sourceType,
    this.sourceId,
    required this.occurredAt,
    this.note,
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

  factory StockMovement({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue stockLocationId,
    required _is.UuidValue variantId,
    required int quantityMilli,
    required int unitCost,
    required _iyl2alwo.StockSourceType sourceType,
    _is.UuidValue? sourceId,
    required DateTime occurredAt,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _StockMovementImpl;

  factory StockMovement.fromJson(Map<String, dynamic> jsonSerialization) {
    return StockMovement(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      stockLocationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['stockLocationId'],
      ),
      variantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['variantId'],
      ),
      quantityMilli: jsonSerialization['quantityMilli'] as int,
      unitCost: jsonSerialization['unitCost'] as int,
      sourceType: _iyl2alwo.StockSourceType.fromJson(
        (jsonSerialization['sourceType'] as String),
      ),
      sourceId: jsonSerialization['sourceId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['sourceId']),
      occurredAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['occurredAt'],
      ),
      note: jsonSerialization['note'] as String?,
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

  static final t = StockMovementTable();

  static const db = StockMovementRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue outletId;

  _is.UuidValue stockLocationId;

  _is.UuidValue variantId;

  int quantityMilli;

  /// Biaya per satuan dasar (rupiah).
  int unitCost;

  _iyl2alwo.StockSourceType sourceType;

  _is.UuidValue? sourceId;

  DateTime occurredAt;

  String? note;

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

  /// Returns a shallow copy of this [StockMovement]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StockMovement copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? stockLocationId,
    _is.UuidValue? variantId,
    int? quantityMilli,
    int? unitCost,
    _iyl2alwo.StockSourceType? sourceType,
    _is.UuidValue? sourceId = const _is.$UndefinedUuidValue(),
    DateTime? occurredAt,
    String? note,
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
      '__className__': 'StockMovement',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'stockLocationId': stockLocationId.toJson(),
      'variantId': variantId.toJson(),
      'quantityMilli': quantityMilli,
      'unitCost': unitCost,
      'sourceType': sourceType.toJson(),
      if (sourceId != null) 'sourceId': sourceId?.toJson(),
      'occurredAt': occurredAt.toJson(),
      if (note != null) 'note': note,
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
      '__className__': 'StockMovement',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'stockLocationId': stockLocationId.toJson(),
      'variantId': variantId.toJson(),
      'quantityMilli': quantityMilli,
      'unitCost': unitCost,
      'sourceType': sourceType.toJson(),
      if (sourceId != null) 'sourceId': sourceId?.toJson(),
      'occurredAt': occurredAt.toJson(),
      if (note != null) 'note': note,
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

  static StockMovementInclude include() {
    return StockMovementInclude._();
  }

  static StockMovementIncludeList includeList({
    _is.WhereExpressionBuilder<StockMovementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockMovementTable>? orderBy,
    _is.OrderByListBuilder<StockMovementTable>? orderByList,
    StockMovementInclude? include,
  }) {
    return StockMovementIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StockMovement.t),
      orderByList: orderByList?.call(StockMovement.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StockMovementImpl extends StockMovement {
  _StockMovementImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue stockLocationId,
    required _is.UuidValue variantId,
    required int quantityMilli,
    required int unitCost,
    required _iyl2alwo.StockSourceType sourceType,
    _is.UuidValue? sourceId,
    required DateTime occurredAt,
    String? note,
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
         stockLocationId: stockLocationId,
         variantId: variantId,
         quantityMilli: quantityMilli,
         unitCost: unitCost,
         sourceType: sourceType,
         sourceId: sourceId,
         occurredAt: occurredAt,
         note: note,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [StockMovement]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StockMovement copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? stockLocationId,
    _is.UuidValue? variantId,
    int? quantityMilli,
    int? unitCost,
    _iyl2alwo.StockSourceType? sourceType,
    _is.UuidValue? sourceId = const _is.$UndefinedUuidValue(),
    DateTime? occurredAt,
    Object? note = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return StockMovement(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      stockLocationId: stockLocationId ?? this.stockLocationId,
      variantId: variantId ?? this.variantId,
      quantityMilli: quantityMilli ?? this.quantityMilli,
      unitCost: unitCost ?? this.unitCost,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId is _is.UndefinedSentinel ? this.sourceId : sourceId,
      occurredAt: occurredAt ?? this.occurredAt,
      note: note is String? ? note : this.note,
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

class StockMovementUpdateTable extends _is.UpdateTable<StockMovementTable> {
  StockMovementUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> stockLocationId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.stockLocationId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> variantId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.variantId,
    value,
  );

  _is.ColumnValue<int, int> quantityMilli(int value) => _is.ColumnValue(
    table.quantityMilli,
    value,
  );

  _is.ColumnValue<int, int> unitCost(int value) => _is.ColumnValue(
    table.unitCost,
    value,
  );

  _is.ColumnValue<_iyl2alwo.StockSourceType, _iyl2alwo.StockSourceType>
  sourceType(_iyl2alwo.StockSourceType value) => _is.ColumnValue(
    table.sourceType,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> sourceId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.sourceId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> occurredAt(DateTime value) =>
      _is.ColumnValue(
        table.occurredAt,
        value,
      );

  _is.ColumnValue<String, String> note(String? value) => _is.ColumnValue(
    table.note,
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

class StockMovementTable extends _is.Table<_is.UuidValue> {
  StockMovementTable({super.tableRelation})
    : super(tableName: 'stock_movements') {
    updateTable = StockMovementUpdateTable(this);
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
    stockLocationId = _is.ColumnUuid(
      'stock_location_id',
      this,
      fieldName: 'stockLocationId',
    );
    variantId = _is.ColumnUuid(
      'variant_id',
      this,
      fieldName: 'variantId',
    );
    quantityMilli = _is.ColumnInt(
      'quantity_milli',
      this,
      fieldName: 'quantityMilli',
    );
    unitCost = _is.ColumnInt(
      'unit_cost',
      this,
      fieldName: 'unitCost',
    );
    sourceType = _is.ColumnEnum(
      'source_type',
      this,
      _is.EnumSerialization.byName,
      fieldName: 'sourceType',
    );
    sourceId = _is.ColumnUuid(
      'source_id',
      this,
      fieldName: 'sourceId',
    );
    occurredAt = _is.ColumnDateTime(
      'occurred_at',
      this,
      fieldName: 'occurredAt',
    );
    note = _is.ColumnString(
      'note',
      this,
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

  late final StockMovementUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid outletId;

  late final _is.ColumnUuid stockLocationId;

  late final _is.ColumnUuid variantId;

  late final _is.ColumnInt quantityMilli;

  /// Biaya per satuan dasar (rupiah).
  late final _is.ColumnInt unitCost;

  late final _is.ColumnEnum<_iyl2alwo.StockSourceType> sourceType;

  late final _is.ColumnUuid sourceId;

  late final _is.ColumnDateTime occurredAt;

  late final _is.ColumnString note;

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
    stockLocationId,
    variantId,
    quantityMilli,
    unitCost,
    sourceType,
    sourceId,
    occurredAt,
    note,
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

class StockMovementInclude extends _is.IncludeObject {
  StockMovementInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => StockMovement.t;
}

class StockMovementIncludeList extends _is.IncludeList {
  StockMovementIncludeList._({
    _is.WhereExpressionBuilder<StockMovementTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(StockMovement.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => StockMovement.t;
}

class StockMovementRepository {
  const StockMovementRepository._();

  /// Returns a list of [StockMovement]s matching the given query parameters.
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
  Future<List<StockMovement>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockMovementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockMovementTable>? orderBy,
    _is.OrderByListBuilder<StockMovementTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<StockMovement>(
      where: where?.call(StockMovement.t),
      orderBy: orderBy?.call(StockMovement.t),
      orderByList: orderByList?.call(StockMovement.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [StockMovement]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `StockMovement.t`.
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
  _ida.Stream<List<StockMovement>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockMovementTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockMovementTable>? orderBy,
    _is.OrderByListBuilder<StockMovementTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<StockMovement>(
      where: where?.call(StockMovement.t),
      orderBy: orderBy?.call(StockMovement.t),
      orderByList: orderByList?.call(StockMovement.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [StockMovement] matching the given query parameters.
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
  Future<StockMovement?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockMovementTable>? where,
    int? offset,
    _is.OrderByBuilder<StockMovementTable>? orderBy,
    _is.OrderByListBuilder<StockMovementTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<StockMovement>(
      where: where?.call(StockMovement.t),
      orderBy: orderBy?.call(StockMovement.t),
      orderByList: orderByList?.call(StockMovement.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [StockMovement] by its [id] or null if no such row exists.
  Future<StockMovement?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<StockMovement>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [StockMovement]s in the list and returns the inserted rows.
  ///
  /// The returned [StockMovement]s will have their `id` fields set.
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
  Future<List<StockMovement>> insert(
    _is.DatabaseSession session,
    List<StockMovement> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<StockMovement>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [StockMovement] and returns the inserted row.
  ///
  /// The returned [StockMovement] will have its `id` field set.
  Future<StockMovement> insertRow(
    _is.DatabaseSession session,
    StockMovement row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<StockMovement>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [StockMovement]s in the list and returns the resulting rows.
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
  /// The returned [StockMovement]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockMovement>> upsert(
    _is.DatabaseSession session,
    List<StockMovement> rows, {
    required _is.ColumnSelections<StockMovementTable> conflictColumns,
    _is.ColumnSelections<StockMovementTable>? updateColumns,
    _is.WhereExpressionBuilder<StockMovementTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<StockMovement>(
      rows,
      conflictColumns: conflictColumns(StockMovement.t),
      updateColumns: updateColumns?.call(StockMovement.t),
      updateWhere: updateWhere?.call(StockMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [StockMovement] and returns the resulting row.
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
  /// The returned [StockMovement] will have its `id` field set.
  Future<StockMovement?> upsertRow(
    _is.DatabaseSession session,
    StockMovement row, {
    required _is.ColumnSelections<StockMovementTable> conflictColumns,
    _is.ColumnSelections<StockMovementTable>? updateColumns,
    _is.WhereExpressionBuilder<StockMovementTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<StockMovement>(
      row,
      conflictColumns: conflictColumns(StockMovement.t),
      updateColumns: updateColumns?.call(StockMovement.t),
      updateWhere: updateWhere?.call(StockMovement.t),
      transaction: transaction,
    );
  }

  /// Updates all [StockMovement]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockMovement>> update(
    _is.DatabaseSession session,
    List<StockMovement> rows, {
    _is.ColumnSelections<StockMovementTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<StockMovement>(
      rows,
      columns: columns?.call(StockMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [StockMovement]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<StockMovement> updateRow(
    _is.DatabaseSession session,
    StockMovement row, {
    _is.ColumnSelections<StockMovementTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<StockMovement>(
      row,
      columns: columns?.call(StockMovement.t),
      transaction: transaction,
    );
  }

  /// Updates a single [StockMovement] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<StockMovement?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<StockMovementUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<StockMovement>(
      id,
      columnValues: columnValues(StockMovement.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [StockMovement]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<StockMovement>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StockMovementUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StockMovementTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StockMovementTable>? orderBy,
    _is.OrderByListBuilder<StockMovementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<StockMovement>(
      columnValues: columnValues(StockMovement.t.updateTable),
      where: where(StockMovement.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(StockMovement.t),
      orderByList: orderByList?.call(StockMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [StockMovement]s in the list and returns the deleted rows.
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
  Future<List<StockMovement>> delete(
    _is.DatabaseSession session,
    List<StockMovement> rows, {
    _is.OrderByBuilder<StockMovementTable>? orderBy,
    _is.OrderByListBuilder<StockMovementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<StockMovement>(
      rows,
      orderBy: orderBy?.call(StockMovement.t),
      orderByList: orderByList?.call(StockMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [StockMovement].
  Future<StockMovement> deleteRow(
    _is.DatabaseSession session,
    StockMovement row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<StockMovement>(
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
  Future<List<StockMovement>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StockMovementTable> where,
    _is.OrderByBuilder<StockMovementTable>? orderBy,
    _is.OrderByListBuilder<StockMovementTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<StockMovement>(
      where: where(StockMovement.t),
      orderBy: orderBy?.call(StockMovement.t),
      orderByList: orderByList?.call(StockMovement.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StockMovementTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<StockMovement>(
      where: where?.call(StockMovement.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [StockMovement] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StockMovementTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<StockMovement>(
      where: where(StockMovement.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
