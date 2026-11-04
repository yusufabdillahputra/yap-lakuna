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

/// Supplier (F1-12, master lengkap F1-14). Nama unik per tenant tanpa
/// membedakan huruf besar/kecil (dicek di lakuna_data). [termDays] = tempo
/// standar yang mengisi jatuh tempo bawaan di Pembelian.
abstract class Supplier
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  Supplier._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.name,
    this.phone,
    this.contactName,
    this.category,
    this.address,
    int? termDays,
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
       termDays = termDays ?? 14,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory Supplier({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required String name,
    String? phone,
    String? contactName,
    String? category,
    String? address,
    int? termDays,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _SupplierImpl;

  factory Supplier.fromJson(Map<String, dynamic> jsonSerialization) {
    return Supplier(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      name: jsonSerialization['name'] as String,
      phone: jsonSerialization['phone'] as String?,
      contactName: jsonSerialization['contactName'] as String?,
      category: jsonSerialization['category'] as String?,
      address: jsonSerialization['address'] as String?,
      termDays: jsonSerialization['termDays'] as int?,
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

  static final t = SupplierTable();

  static const db = SupplierRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  String name;

  String? phone;

  String? contactName;

  String? category;

  String? address;

  int termDays;

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

  /// Returns a shallow copy of this [Supplier]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Supplier copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    String? name,
    String? phone,
    String? contactName,
    String? category,
    String? address,
    int? termDays,
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
      '__className__': 'Supplier',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'name': name,
      if (phone != null) 'phone': phone,
      if (contactName != null) 'contactName': contactName,
      if (category != null) 'category': category,
      if (address != null) 'address': address,
      'termDays': termDays,
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
      '__className__': 'Supplier',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'name': name,
      if (phone != null) 'phone': phone,
      if (contactName != null) 'contactName': contactName,
      if (category != null) 'category': category,
      if (address != null) 'address': address,
      'termDays': termDays,
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

  static SupplierInclude include() {
    return SupplierInclude._();
  }

  static SupplierIncludeList includeList({
    _is.WhereExpressionBuilder<SupplierTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupplierTable>? orderBy,
    _is.OrderByListBuilder<SupplierTable>? orderByList,
    SupplierInclude? include,
  }) {
    return SupplierIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Supplier.t),
      orderByList: orderByList?.call(Supplier.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SupplierImpl extends Supplier {
  _SupplierImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required String name,
    String? phone,
    String? contactName,
    String? category,
    String? address,
    int? termDays,
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
         name: name,
         phone: phone,
         contactName: contactName,
         category: category,
         address: address,
         termDays: termDays,
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

  /// Returns a shallow copy of this [Supplier]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Supplier copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    String? name,
    Object? phone = _Undefined,
    Object? contactName = _Undefined,
    Object? category = _Undefined,
    Object? address = _Undefined,
    int? termDays,
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
    return Supplier(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      phone: phone is String? ? phone : this.phone,
      contactName: contactName is String? ? contactName : this.contactName,
      category: category is String? ? category : this.category,
      address: address is String? ? address : this.address,
      termDays: termDays ?? this.termDays,
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

class SupplierUpdateTable extends _is.UpdateTable<SupplierTable> {
  SupplierUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> tenantId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.tenantId,
        value,
      );

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> phone(String? value) => _is.ColumnValue(
    table.phone,
    value,
  );

  _is.ColumnValue<String, String> contactName(String? value) => _is.ColumnValue(
    table.contactName,
    value,
  );

  _is.ColumnValue<String, String> category(String? value) => _is.ColumnValue(
    table.category,
    value,
  );

  _is.ColumnValue<String, String> address(String? value) => _is.ColumnValue(
    table.address,
    value,
  );

  _is.ColumnValue<int, int> termDays(int value) => _is.ColumnValue(
    table.termDays,
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

class SupplierTable extends _is.Table<_is.UuidValue> {
  SupplierTable({super.tableRelation}) : super(tableName: 'suppliers') {
    updateTable = SupplierUpdateTable(this);
    tenantId = _is.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    phone = _is.ColumnString(
      'phone',
      this,
    );
    contactName = _is.ColumnString(
      'contact_name',
      this,
      fieldName: 'contactName',
    );
    category = _is.ColumnString(
      'category',
      this,
    );
    address = _is.ColumnString(
      'address',
      this,
    );
    termDays = _is.ColumnInt(
      'term_days',
      this,
      hasDefault: true,
      fieldName: 'termDays',
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

  late final SupplierUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnString name;

  late final _is.ColumnString phone;

  late final _is.ColumnString contactName;

  late final _is.ColumnString category;

  late final _is.ColumnString address;

  late final _is.ColumnInt termDays;

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
    name,
    phone,
    contactName,
    category,
    address,
    termDays,
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

class SupplierInclude extends _is.IncludeObject {
  SupplierInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => Supplier.t;
}

class SupplierIncludeList extends _is.IncludeList {
  SupplierIncludeList._({
    _is.WhereExpressionBuilder<SupplierTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Supplier.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => Supplier.t;
}

class SupplierRepository {
  const SupplierRepository._();

  /// Returns a list of [Supplier]s matching the given query parameters.
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
  Future<List<Supplier>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupplierTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupplierTable>? orderBy,
    _is.OrderByListBuilder<SupplierTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Supplier>(
      where: where?.call(Supplier.t),
      orderBy: orderBy?.call(Supplier.t),
      orderByList: orderByList?.call(Supplier.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Supplier]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Supplier.t`.
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
  _ida.Stream<List<Supplier>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupplierTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupplierTable>? orderBy,
    _is.OrderByListBuilder<SupplierTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Supplier>(
      where: where?.call(Supplier.t),
      orderBy: orderBy?.call(Supplier.t),
      orderByList: orderByList?.call(Supplier.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Supplier] matching the given query parameters.
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
  Future<Supplier?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupplierTable>? where,
    int? offset,
    _is.OrderByBuilder<SupplierTable>? orderBy,
    _is.OrderByListBuilder<SupplierTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Supplier>(
      where: where?.call(Supplier.t),
      orderBy: orderBy?.call(Supplier.t),
      orderByList: orderByList?.call(Supplier.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Supplier] by its [id] or null if no such row exists.
  Future<Supplier?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Supplier>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Supplier]s in the list and returns the inserted rows.
  ///
  /// The returned [Supplier]s will have their `id` fields set.
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
  Future<List<Supplier>> insert(
    _is.DatabaseSession session,
    List<Supplier> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Supplier>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Supplier] and returns the inserted row.
  ///
  /// The returned [Supplier] will have its `id` field set.
  Future<Supplier> insertRow(
    _is.DatabaseSession session,
    Supplier row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Supplier>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Supplier]s in the list and returns the resulting rows.
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
  /// The returned [Supplier]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Supplier>> upsert(
    _is.DatabaseSession session,
    List<Supplier> rows, {
    required _is.ColumnSelections<SupplierTable> conflictColumns,
    _is.ColumnSelections<SupplierTable>? updateColumns,
    _is.WhereExpressionBuilder<SupplierTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Supplier>(
      rows,
      conflictColumns: conflictColumns(Supplier.t),
      updateColumns: updateColumns?.call(Supplier.t),
      updateWhere: updateWhere?.call(Supplier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Supplier] and returns the resulting row.
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
  /// The returned [Supplier] will have its `id` field set.
  Future<Supplier?> upsertRow(
    _is.DatabaseSession session,
    Supplier row, {
    required _is.ColumnSelections<SupplierTable> conflictColumns,
    _is.ColumnSelections<SupplierTable>? updateColumns,
    _is.WhereExpressionBuilder<SupplierTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Supplier>(
      row,
      conflictColumns: conflictColumns(Supplier.t),
      updateColumns: updateColumns?.call(Supplier.t),
      updateWhere: updateWhere?.call(Supplier.t),
      transaction: transaction,
    );
  }

  /// Updates all [Supplier]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Supplier>> update(
    _is.DatabaseSession session,
    List<Supplier> rows, {
    _is.ColumnSelections<SupplierTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Supplier>(
      rows,
      columns: columns?.call(Supplier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Supplier]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Supplier> updateRow(
    _is.DatabaseSession session,
    Supplier row, {
    _is.ColumnSelections<SupplierTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Supplier>(
      row,
      columns: columns?.call(Supplier.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Supplier] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Supplier?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<SupplierUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Supplier>(
      id,
      columnValues: columnValues(Supplier.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Supplier]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Supplier>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SupplierUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SupplierTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SupplierTable>? orderBy,
    _is.OrderByListBuilder<SupplierTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Supplier>(
      columnValues: columnValues(Supplier.t.updateTable),
      where: where(Supplier.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Supplier.t),
      orderByList: orderByList?.call(Supplier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Supplier]s in the list and returns the deleted rows.
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
  Future<List<Supplier>> delete(
    _is.DatabaseSession session,
    List<Supplier> rows, {
    _is.OrderByBuilder<SupplierTable>? orderBy,
    _is.OrderByListBuilder<SupplierTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Supplier>(
      rows,
      orderBy: orderBy?.call(Supplier.t),
      orderByList: orderByList?.call(Supplier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Supplier].
  Future<Supplier> deleteRow(
    _is.DatabaseSession session,
    Supplier row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Supplier>(
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
  Future<List<Supplier>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SupplierTable> where,
    _is.OrderByBuilder<SupplierTable>? orderBy,
    _is.OrderByListBuilder<SupplierTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Supplier>(
      where: where(Supplier.t),
      orderBy: orderBy?.call(Supplier.t),
      orderByList: orderByList?.call(Supplier.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SupplierTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Supplier>(
      where: where?.call(Supplier.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Supplier] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SupplierTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Supplier>(
      where: where(Supplier.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
