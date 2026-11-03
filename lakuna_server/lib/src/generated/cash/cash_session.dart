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
import '../cash/cash_session_status.dart' as _iazxu1j8;

/// Sesi kasir satu perangkat: saldo awal, lalu hitung uang fisik dan selisih
/// saat tutup (F1-03). Satu sesi terbuka per perangkat.
abstract class CashSession
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  CashSession._({
    _is.UuidValue? id,
    required this.tenantId,
    required this.outletId,
    required this.deviceId,
    required this.status,
    required this.openedBy,
    required this.openedAt,
    required this.openingCash,
    this.openingNote,
    this.closedBy,
    this.closedAt,
    this.expectedCash,
    this.countedCash,
    this.difference,
    this.countedBreakdown,
    this.closingNote,
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

  factory CashSession({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    required _iazxu1j8.CashSessionStatus status,
    required _is.UuidValue openedBy,
    required DateTime openedAt,
    required int openingCash,
    String? openingNote,
    _is.UuidValue? closedBy,
    DateTime? closedAt,
    int? expectedCash,
    int? countedCash,
    int? difference,
    String? countedBreakdown,
    String? closingNote,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _is.UuidValue? createdBy,
    _is.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _is.UuidValue? originDeviceId,
  }) = _CashSessionImpl;

  factory CashSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return CashSession(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      deviceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['deviceId'],
      ),
      status: _iazxu1j8.CashSessionStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      openedBy: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['openedBy'],
      ),
      openedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['openedAt'],
      ),
      openingCash: jsonSerialization['openingCash'] as int,
      openingNote: jsonSerialization['openingNote'] as String?,
      closedBy: jsonSerialization['closedBy'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['closedBy']),
      closedAt: jsonSerialization['closedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['closedAt']),
      expectedCash: jsonSerialization['expectedCash'] as int?,
      countedCash: jsonSerialization['countedCash'] as int?,
      difference: jsonSerialization['difference'] as int?,
      countedBreakdown: jsonSerialization['countedBreakdown'] as String?,
      closingNote: jsonSerialization['closingNote'] as String?,
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

  static final t = CashSessionTable();

  static const db = CashSessionRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue tenantId;

  _is.UuidValue outletId;

  _is.UuidValue deviceId;

  _iazxu1j8.CashSessionStatus status;

  _is.UuidValue openedBy;

  DateTime openedAt;

  /// Saldo awal laci (rupiah).
  int openingCash;

  String? openingNote;

  _is.UuidValue? closedBy;

  DateTime? closedAt;

  /// Seharusnya di laci saat tutup (rupiah).
  int? expectedCash;

  /// Hasil hitung uang fisik (rupiah).
  int? countedCash;

  /// Hitung - seharusnya: positif lebih, negatif kurang.
  int? difference;

  /// Rincian hitung per pecahan (JSON `CashCount`).
  String? countedBreakdown;

  String? closingNote;

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

  /// Returns a shallow copy of this [CashSession]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CashSession copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _iazxu1j8.CashSessionStatus? status,
    _is.UuidValue? openedBy,
    DateTime? openedAt,
    int? openingCash,
    String? openingNote,
    _is.UuidValue? closedBy = const _is.$UndefinedUuidValue(),
    DateTime? closedAt = const _is.$UndefinedDateTime(),
    int? expectedCash,
    int? countedCash,
    int? difference,
    String? countedBreakdown,
    String? closingNote,
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
      '__className__': 'CashSession',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      'status': status.toJson(),
      'openedBy': openedBy.toJson(),
      'openedAt': openedAt.toJson(),
      'openingCash': openingCash,
      if (openingNote != null) 'openingNote': openingNote,
      if (closedBy != null) 'closedBy': closedBy?.toJson(),
      if (closedAt != null) 'closedAt': closedAt?.toJson(),
      if (expectedCash != null) 'expectedCash': expectedCash,
      if (countedCash != null) 'countedCash': countedCash,
      if (difference != null) 'difference': difference,
      if (countedBreakdown != null) 'countedBreakdown': countedBreakdown,
      if (closingNote != null) 'closingNote': closingNote,
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
      '__className__': 'CashSession',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      'outletId': outletId.toJson(),
      'deviceId': deviceId.toJson(),
      'status': status.toJson(),
      'openedBy': openedBy.toJson(),
      'openedAt': openedAt.toJson(),
      'openingCash': openingCash,
      if (openingNote != null) 'openingNote': openingNote,
      if (closedBy != null) 'closedBy': closedBy?.toJson(),
      if (closedAt != null) 'closedAt': closedAt?.toJson(),
      if (expectedCash != null) 'expectedCash': expectedCash,
      if (countedCash != null) 'countedCash': countedCash,
      if (difference != null) 'difference': difference,
      if (countedBreakdown != null) 'countedBreakdown': countedBreakdown,
      if (closingNote != null) 'closingNote': closingNote,
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

  static CashSessionInclude include() {
    return CashSessionInclude._();
  }

  static CashSessionIncludeList includeList({
    _is.WhereExpressionBuilder<CashSessionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CashSessionTable>? orderBy,
    _is.OrderByListBuilder<CashSessionTable>? orderByList,
    CashSessionInclude? include,
  }) {
    return CashSessionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CashSession.t),
      orderByList: orderByList?.call(CashSession.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CashSessionImpl extends CashSession {
  _CashSessionImpl({
    _is.UuidValue? id,
    required _is.UuidValue tenantId,
    required _is.UuidValue outletId,
    required _is.UuidValue deviceId,
    required _iazxu1j8.CashSessionStatus status,
    required _is.UuidValue openedBy,
    required DateTime openedAt,
    required int openingCash,
    String? openingNote,
    _is.UuidValue? closedBy,
    DateTime? closedAt,
    int? expectedCash,
    int? countedCash,
    int? difference,
    String? countedBreakdown,
    String? closingNote,
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
         deviceId: deviceId,
         status: status,
         openedBy: openedBy,
         openedAt: openedAt,
         openingCash: openingCash,
         openingNote: openingNote,
         closedBy: closedBy,
         closedAt: closedAt,
         expectedCash: expectedCash,
         countedCash: countedCash,
         difference: difference,
         countedBreakdown: countedBreakdown,
         closingNote: closingNote,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [CashSession]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CashSession copyWith({
    _is.UuidValue? id,
    _is.UuidValue? tenantId,
    _is.UuidValue? outletId,
    _is.UuidValue? deviceId,
    _iazxu1j8.CashSessionStatus? status,
    _is.UuidValue? openedBy,
    DateTime? openedAt,
    int? openingCash,
    Object? openingNote = _Undefined,
    _is.UuidValue? closedBy = const _is.$UndefinedUuidValue(),
    DateTime? closedAt = const _is.$UndefinedDateTime(),
    Object? expectedCash = _Undefined,
    Object? countedCash = _Undefined,
    Object? difference = _Undefined,
    Object? countedBreakdown = _Undefined,
    Object? closingNote = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _is.$UndefinedDateTime(),
    _is.UuidValue? createdBy = const _is.$UndefinedUuidValue(),
    _is.UuidValue? updatedBy = const _is.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _is.UuidValue? originDeviceId = const _is.$UndefinedUuidValue(),
  }) {
    return CashSession(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId ?? this.outletId,
      deviceId: deviceId ?? this.deviceId,
      status: status ?? this.status,
      openedBy: openedBy ?? this.openedBy,
      openedAt: openedAt ?? this.openedAt,
      openingCash: openingCash ?? this.openingCash,
      openingNote: openingNote is String? ? openingNote : this.openingNote,
      closedBy: closedBy is _is.UndefinedSentinel ? this.closedBy : closedBy,
      closedAt: closedAt is _is.UndefinedSentinel ? this.closedAt : closedAt,
      expectedCash: expectedCash is int? ? expectedCash : this.expectedCash,
      countedCash: countedCash is int? ? countedCash : this.countedCash,
      difference: difference is int? ? difference : this.difference,
      countedBreakdown: countedBreakdown is String?
          ? countedBreakdown
          : this.countedBreakdown,
      closingNote: closingNote is String? ? closingNote : this.closingNote,
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

class CashSessionUpdateTable extends _is.UpdateTable<CashSessionTable> {
  CashSessionUpdateTable(super.table);

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

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> deviceId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.deviceId,
        value,
      );

  _is.ColumnValue<_iazxu1j8.CashSessionStatus, _iazxu1j8.CashSessionStatus>
  status(_iazxu1j8.CashSessionStatus value) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> openedBy(_is.UuidValue value) =>
      _is.ColumnValue(
        table.openedBy,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> openedAt(DateTime value) =>
      _is.ColumnValue(
        table.openedAt,
        value,
      );

  _is.ColumnValue<int, int> openingCash(int value) => _is.ColumnValue(
    table.openingCash,
    value,
  );

  _is.ColumnValue<String, String> openingNote(String? value) => _is.ColumnValue(
    table.openingNote,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> closedBy(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.closedBy,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> closedAt(DateTime? value) =>
      _is.ColumnValue(
        table.closedAt,
        value,
      );

  _is.ColumnValue<int, int> expectedCash(int? value) => _is.ColumnValue(
    table.expectedCash,
    value,
  );

  _is.ColumnValue<int, int> countedCash(int? value) => _is.ColumnValue(
    table.countedCash,
    value,
  );

  _is.ColumnValue<int, int> difference(int? value) => _is.ColumnValue(
    table.difference,
    value,
  );

  _is.ColumnValue<String, String> countedBreakdown(String? value) =>
      _is.ColumnValue(
        table.countedBreakdown,
        value,
      );

  _is.ColumnValue<String, String> closingNote(String? value) => _is.ColumnValue(
    table.closingNote,
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

class CashSessionTable extends _is.Table<_is.UuidValue> {
  CashSessionTable({super.tableRelation}) : super(tableName: 'cash_sessions') {
    updateTable = CashSessionUpdateTable(this);
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
    deviceId = _is.ColumnUuid(
      'device_id',
      this,
      fieldName: 'deviceId',
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    openedBy = _is.ColumnUuid(
      'opened_by',
      this,
      fieldName: 'openedBy',
    );
    openedAt = _is.ColumnDateTime(
      'opened_at',
      this,
      fieldName: 'openedAt',
    );
    openingCash = _is.ColumnInt(
      'opening_cash',
      this,
      fieldName: 'openingCash',
    );
    openingNote = _is.ColumnString(
      'opening_note',
      this,
      fieldName: 'openingNote',
    );
    closedBy = _is.ColumnUuid(
      'closed_by',
      this,
      fieldName: 'closedBy',
    );
    closedAt = _is.ColumnDateTime(
      'closed_at',
      this,
      fieldName: 'closedAt',
    );
    expectedCash = _is.ColumnInt(
      'expected_cash',
      this,
      fieldName: 'expectedCash',
    );
    countedCash = _is.ColumnInt(
      'counted_cash',
      this,
      fieldName: 'countedCash',
    );
    difference = _is.ColumnInt(
      'difference',
      this,
    );
    countedBreakdown = _is.ColumnString(
      'counted_breakdown',
      this,
      fieldName: 'countedBreakdown',
    );
    closingNote = _is.ColumnString(
      'closing_note',
      this,
      fieldName: 'closingNote',
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

  late final CashSessionUpdateTable updateTable;

  late final _is.ColumnUuid tenantId;

  late final _is.ColumnUuid outletId;

  late final _is.ColumnUuid deviceId;

  late final _is.ColumnEnum<_iazxu1j8.CashSessionStatus> status;

  late final _is.ColumnUuid openedBy;

  late final _is.ColumnDateTime openedAt;

  /// Saldo awal laci (rupiah).
  late final _is.ColumnInt openingCash;

  late final _is.ColumnString openingNote;

  late final _is.ColumnUuid closedBy;

  late final _is.ColumnDateTime closedAt;

  /// Seharusnya di laci saat tutup (rupiah).
  late final _is.ColumnInt expectedCash;

  /// Hasil hitung uang fisik (rupiah).
  late final _is.ColumnInt countedCash;

  /// Hitung - seharusnya: positif lebih, negatif kurang.
  late final _is.ColumnInt difference;

  /// Rincian hitung per pecahan (JSON `CashCount`).
  late final _is.ColumnString countedBreakdown;

  late final _is.ColumnString closingNote;

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
    deviceId,
    status,
    openedBy,
    openedAt,
    openingCash,
    openingNote,
    closedBy,
    closedAt,
    expectedCash,
    countedCash,
    difference,
    countedBreakdown,
    closingNote,
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

class CashSessionInclude extends _is.IncludeObject {
  CashSessionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => CashSession.t;
}

class CashSessionIncludeList extends _is.IncludeList {
  CashSessionIncludeList._({
    _is.WhereExpressionBuilder<CashSessionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CashSession.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => CashSession.t;
}

class CashSessionRepository {
  const CashSessionRepository._();

  /// Returns a list of [CashSession]s matching the given query parameters.
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
  Future<List<CashSession>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CashSessionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CashSessionTable>? orderBy,
    _is.OrderByListBuilder<CashSessionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CashSession>(
      where: where?.call(CashSession.t),
      orderBy: orderBy?.call(CashSession.t),
      orderByList: orderByList?.call(CashSession.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [CashSession]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `CashSession.t`.
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
  _ida.Stream<List<CashSession>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CashSessionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CashSessionTable>? orderBy,
    _is.OrderByListBuilder<CashSessionTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<CashSession>(
      where: where?.call(CashSession.t),
      orderBy: orderBy?.call(CashSession.t),
      orderByList: orderByList?.call(CashSession.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [CashSession] matching the given query parameters.
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
  Future<CashSession?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CashSessionTable>? where,
    int? offset,
    _is.OrderByBuilder<CashSessionTable>? orderBy,
    _is.OrderByListBuilder<CashSessionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CashSession>(
      where: where?.call(CashSession.t),
      orderBy: orderBy?.call(CashSession.t),
      orderByList: orderByList?.call(CashSession.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CashSession] by its [id] or null if no such row exists.
  Future<CashSession?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CashSession>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CashSession]s in the list and returns the inserted rows.
  ///
  /// The returned [CashSession]s will have their `id` fields set.
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
  Future<List<CashSession>> insert(
    _is.DatabaseSession session,
    List<CashSession> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CashSession>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CashSession] and returns the inserted row.
  ///
  /// The returned [CashSession] will have its `id` field set.
  Future<CashSession> insertRow(
    _is.DatabaseSession session,
    CashSession row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CashSession>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CashSession]s in the list and returns the resulting rows.
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
  /// The returned [CashSession]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CashSession>> upsert(
    _is.DatabaseSession session,
    List<CashSession> rows, {
    required _is.ColumnSelections<CashSessionTable> conflictColumns,
    _is.ColumnSelections<CashSessionTable>? updateColumns,
    _is.WhereExpressionBuilder<CashSessionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CashSession>(
      rows,
      conflictColumns: conflictColumns(CashSession.t),
      updateColumns: updateColumns?.call(CashSession.t),
      updateWhere: updateWhere?.call(CashSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CashSession] and returns the resulting row.
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
  /// The returned [CashSession] will have its `id` field set.
  Future<CashSession?> upsertRow(
    _is.DatabaseSession session,
    CashSession row, {
    required _is.ColumnSelections<CashSessionTable> conflictColumns,
    _is.ColumnSelections<CashSessionTable>? updateColumns,
    _is.WhereExpressionBuilder<CashSessionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CashSession>(
      row,
      conflictColumns: conflictColumns(CashSession.t),
      updateColumns: updateColumns?.call(CashSession.t),
      updateWhere: updateWhere?.call(CashSession.t),
      transaction: transaction,
    );
  }

  /// Updates all [CashSession]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CashSession>> update(
    _is.DatabaseSession session,
    List<CashSession> rows, {
    _is.ColumnSelections<CashSessionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CashSession>(
      rows,
      columns: columns?.call(CashSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CashSession]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CashSession> updateRow(
    _is.DatabaseSession session,
    CashSession row, {
    _is.ColumnSelections<CashSessionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CashSession>(
      row,
      columns: columns?.call(CashSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CashSession] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CashSession?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<CashSessionUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CashSession>(
      id,
      columnValues: columnValues(CashSession.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CashSession]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CashSession>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CashSessionUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CashSessionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CashSessionTable>? orderBy,
    _is.OrderByListBuilder<CashSessionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CashSession>(
      columnValues: columnValues(CashSession.t.updateTable),
      where: where(CashSession.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CashSession.t),
      orderByList: orderByList?.call(CashSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CashSession]s in the list and returns the deleted rows.
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
  Future<List<CashSession>> delete(
    _is.DatabaseSession session,
    List<CashSession> rows, {
    _is.OrderByBuilder<CashSessionTable>? orderBy,
    _is.OrderByListBuilder<CashSessionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CashSession>(
      rows,
      orderBy: orderBy?.call(CashSession.t),
      orderByList: orderByList?.call(CashSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CashSession].
  Future<CashSession> deleteRow(
    _is.DatabaseSession session,
    CashSession row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CashSession>(
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
  Future<List<CashSession>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CashSessionTable> where,
    _is.OrderByBuilder<CashSessionTable>? orderBy,
    _is.OrderByListBuilder<CashSessionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CashSession>(
      where: where(CashSession.t),
      orderBy: orderBy?.call(CashSession.t),
      orderByList: orderByList?.call(CashSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CashSessionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CashSession>(
      where: where?.call(CashSession.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CashSession] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CashSessionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CashSession>(
      where: where(CashSession.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
