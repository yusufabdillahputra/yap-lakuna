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

/// Opsi di grup modifier. Tambahan harga boleh negatif (potongan); opsi
/// habis ditandai is_available = false, tidak dihapus.
abstract class ModifierOption
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  ModifierOption._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.modifierGroupId,
    required this.name,
    int? priceDelta,
    bool? isDefault,
    bool? isAvailable,
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
       priceDelta = priceDelta ?? 0,
       isDefault = isDefault ?? false,
       isAvailable = isAvailable ?? true,
       sortOrder = sortOrder ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory ModifierOption({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue modifierGroupId,
    required String name,
    int? priceDelta,
    bool? isDefault,
    bool? isAvailable,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _ModifierOptionImpl;

  factory ModifierOption.fromJson(Map<String, dynamic> jsonSerialization) {
    return ModifierOption(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      modifierGroupId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['modifierGroupId'],
      ),
      name: jsonSerialization['name'] as String,
      priceDelta: jsonSerialization['priceDelta'] as int?,
      isDefault: jsonSerialization['isDefault'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isDefault']),
      isAvailable: jsonSerialization['isAvailable'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isAvailable']),
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

  static final t = ModifierOptionTable();

  static const db = ModifierOptionRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue modifierGroupId;

  String name;

  /// Tambahan harga per satuan baris, rupiah (boleh negatif).
  int priceDelta;

  /// Terpilih otomatis di sheet 1.8.
  bool isDefault;

  bool isAvailable;

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

  /// Returns a shallow copy of this [ModifierOption]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ModifierOption copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? modifierGroupId,
    String? name,
    int? priceDelta,
    bool? isDefault,
    bool? isAvailable,
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
      '__className__': 'ModifierOption',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'modifierGroupId': modifierGroupId.toJson(),
      'name': name,
      'priceDelta': priceDelta,
      'isDefault': isDefault,
      'isAvailable': isAvailable,
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
      '__className__': 'ModifierOption',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'modifierGroupId': modifierGroupId.toJson(),
      'name': name,
      'priceDelta': priceDelta,
      'isDefault': isDefault,
      'isAvailable': isAvailable,
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

  static ModifierOptionInclude include() {
    return ModifierOptionInclude._();
  }

  static ModifierOptionIncludeList includeList({
    _is.WhereExpressionBuilder<ModifierOptionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ModifierOptionTable>? orderBy,
    _is.OrderByListBuilder<ModifierOptionTable>? orderByList,
    ModifierOptionInclude? include,
  }) {
    return ModifierOptionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ModifierOption.t),
      orderByList: orderByList?.call(ModifierOption.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _ModifierOptionImpl extends ModifierOption {
  _ModifierOptionImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue modifierGroupId,
    required String name,
    int? priceDelta,
    bool? isDefault,
    bool? isAvailable,
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
         modifierGroupId: modifierGroupId,
         name: name,
         priceDelta: priceDelta,
         isDefault: isDefault,
         isAvailable: isAvailable,
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

  /// Returns a shallow copy of this [ModifierOption]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ModifierOption copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? modifierGroupId,
    String? name,
    int? priceDelta,
    bool? isDefault,
    bool? isAvailable,
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
    return ModifierOption(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      modifierGroupId: modifierGroupId ?? this.modifierGroupId,
      name: name ?? this.name,
      priceDelta: priceDelta ?? this.priceDelta,
      isDefault: isDefault ?? this.isDefault,
      isAvailable: isAvailable ?? this.isAvailable,
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

class ModifierOptionUpdateTable extends _is.UpdateTable<ModifierOptionTable> {
  ModifierOptionUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> modifierGroupId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.modifierGroupId,
    value,
  );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<int, int> priceDelta(int value) => _is.ColumnValue(
    table.priceDelta,
    value,
  );

  _is.ColumnValue<bool, bool> isDefault(bool value) => _is.ColumnValue(
    table.isDefault,
    value,
  );

  _is.ColumnValue<bool, bool> isAvailable(bool value) => _is.ColumnValue(
    table.isAvailable,
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

class ModifierOptionTable extends _is.Table<_is.UuidValue> {
  ModifierOptionTable({super.tableRelation}) : super(tableName: 'modifiers') {
    updateTable = ModifierOptionUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    modifierGroupId = _is.ColumnUuid(
      'modifier_group_id',
      this,
      fieldName: 'modifierGroupId',
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    priceDelta = _is.ColumnInt(
      'price_delta',
      this,
      hasDefault: true,
      fieldName: 'priceDelta',
    );
    isDefault = _is.ColumnBool(
      'is_default',
      this,
      hasDefault: true,
      fieldName: 'isDefault',
    );
    isAvailable = _is.ColumnBool(
      'is_available',
      this,
      hasDefault: true,
      fieldName: 'isAvailable',
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

  late final ModifierOptionUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid modifierGroupId;

  late final _is.ColumnString name;

  /// Tambahan harga per satuan baris, rupiah (boleh negatif).
  late final _is.ColumnInt priceDelta;

  /// Terpilih otomatis di sheet 1.8.
  late final _is.ColumnBool isDefault;

  late final _is.ColumnBool isAvailable;

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
    modifierGroupId,
    name,
    priceDelta,
    isDefault,
    isAvailable,
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

class ModifierOptionInclude extends _is.IncludeObject {
  ModifierOptionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => ModifierOption.t;
}

class ModifierOptionIncludeList extends _is.IncludeList {
  ModifierOptionIncludeList._({
    _is.WhereExpressionBuilder<ModifierOptionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ModifierOption.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => ModifierOption.t;
}

class ModifierOptionRepository {
  const ModifierOptionRepository._();

  /// Returns a list of [ModifierOption]s matching the given query parameters.
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
  Future<List<ModifierOption>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ModifierOptionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ModifierOptionTable>? orderBy,
    _is.OrderByListBuilder<ModifierOptionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ModifierOption>(
      where: where?.call(ModifierOption.t),
      orderBy: orderBy?.call(ModifierOption.t),
      orderByList: orderByList?.call(ModifierOption.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [ModifierOption]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `ModifierOption.t`.
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
  _ida.Stream<List<ModifierOption>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ModifierOptionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ModifierOptionTable>? orderBy,
    _is.OrderByListBuilder<ModifierOptionTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<ModifierOption>(
      where: where?.call(ModifierOption.t),
      orderBy: orderBy?.call(ModifierOption.t),
      orderByList: orderByList?.call(ModifierOption.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [ModifierOption] matching the given query parameters.
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
  Future<ModifierOption?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ModifierOptionTable>? where,
    int? offset,
    _is.OrderByBuilder<ModifierOptionTable>? orderBy,
    _is.OrderByListBuilder<ModifierOptionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ModifierOption>(
      where: where?.call(ModifierOption.t),
      orderBy: orderBy?.call(ModifierOption.t),
      orderByList: orderByList?.call(ModifierOption.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ModifierOption] by its [id] or null if no such row exists.
  Future<ModifierOption?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ModifierOption>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ModifierOption]s in the list and returns the inserted rows.
  ///
  /// The returned [ModifierOption]s will have their `id` fields set.
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
  Future<List<ModifierOption>> insert(
    _is.DatabaseSession session,
    List<ModifierOption> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ModifierOption>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ModifierOption] and returns the inserted row.
  ///
  /// The returned [ModifierOption] will have its `id` field set.
  Future<ModifierOption> insertRow(
    _is.DatabaseSession session,
    ModifierOption row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ModifierOption>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ModifierOption]s in the list and returns the resulting rows.
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
  /// The returned [ModifierOption]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ModifierOption>> upsert(
    _is.DatabaseSession session,
    List<ModifierOption> rows, {
    required _is.ColumnSelections<ModifierOptionTable> conflictColumns,
    _is.ColumnSelections<ModifierOptionTable>? updateColumns,
    _is.WhereExpressionBuilder<ModifierOptionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ModifierOption>(
      rows,
      conflictColumns: conflictColumns(ModifierOption.t),
      updateColumns: updateColumns?.call(ModifierOption.t),
      updateWhere: updateWhere?.call(ModifierOption.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ModifierOption] and returns the resulting row.
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
  /// The returned [ModifierOption] will have its `id` field set.
  Future<ModifierOption?> upsertRow(
    _is.DatabaseSession session,
    ModifierOption row, {
    required _is.ColumnSelections<ModifierOptionTable> conflictColumns,
    _is.ColumnSelections<ModifierOptionTable>? updateColumns,
    _is.WhereExpressionBuilder<ModifierOptionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ModifierOption>(
      row,
      conflictColumns: conflictColumns(ModifierOption.t),
      updateColumns: updateColumns?.call(ModifierOption.t),
      updateWhere: updateWhere?.call(ModifierOption.t),
      transaction: transaction,
    );
  }

  /// Updates all [ModifierOption]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ModifierOption>> update(
    _is.DatabaseSession session,
    List<ModifierOption> rows, {
    _is.ColumnSelections<ModifierOptionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ModifierOption>(
      rows,
      columns: columns?.call(ModifierOption.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ModifierOption]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ModifierOption> updateRow(
    _is.DatabaseSession session,
    ModifierOption row, {
    _is.ColumnSelections<ModifierOptionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ModifierOption>(
      row,
      columns: columns?.call(ModifierOption.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ModifierOption] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ModifierOption?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<ModifierOptionUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ModifierOption>(
      id,
      columnValues: columnValues(ModifierOption.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ModifierOption]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ModifierOption>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ModifierOptionUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ModifierOptionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ModifierOptionTable>? orderBy,
    _is.OrderByListBuilder<ModifierOptionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ModifierOption>(
      columnValues: columnValues(ModifierOption.t.updateTable),
      where: where(ModifierOption.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ModifierOption.t),
      orderByList: orderByList?.call(ModifierOption.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ModifierOption]s in the list and returns the deleted rows.
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
  Future<List<ModifierOption>> delete(
    _is.DatabaseSession session,
    List<ModifierOption> rows, {
    _is.OrderByBuilder<ModifierOptionTable>? orderBy,
    _is.OrderByListBuilder<ModifierOptionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ModifierOption>(
      rows,
      orderBy: orderBy?.call(ModifierOption.t),
      orderByList: orderByList?.call(ModifierOption.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ModifierOption].
  Future<ModifierOption> deleteRow(
    _is.DatabaseSession session,
    ModifierOption row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ModifierOption>(
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
  Future<List<ModifierOption>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ModifierOptionTable> where,
    _is.OrderByBuilder<ModifierOptionTable>? orderBy,
    _is.OrderByListBuilder<ModifierOptionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ModifierOption>(
      where: where(ModifierOption.t),
      orderBy: orderBy?.call(ModifierOption.t),
      orderByList: orderByList?.call(ModifierOption.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ModifierOptionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ModifierOption>(
      where: where?.call(ModifierOption.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ModifierOption] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ModifierOptionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ModifierOption>(
      where: where(ModifierOption.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
