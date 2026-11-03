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
import '../media/media_kind.dart' as _i2bme9zf;

/// Berkas gambar yang diunggah (stiker QRIS, nanti foto produk). Isi berkas
/// disimpan di `<folder data>/media/<storage_key>`; `storage_key` =
/// `<sha256>.<ext>` sehingga berkas sama tidak disalin dua kali dan aman
/// disinkronkan ke object storage (Fase 2).
abstract class MediaFile
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  MediaFile._({
    _isc.UuidValue? id,
    required this.tenantId,
    this.outletId,
    required this.kind,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.sha256,
    required this.width,
    required this.height,
    required this.storageKey,
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

  factory MediaFile({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    _isc.UuidValue? outletId,
    required _i2bme9zf.MediaKind kind,
    required String fileName,
    required String mimeType,
    required int sizeBytes,
    required String sha256,
    required int width,
    required int height,
    required String storageKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _MediaFileImpl;

  factory MediaFile.fromJson(Map<String, dynamic> jsonSerialization) {
    return MediaFile(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      outletId: jsonSerialization['outletId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['outletId']),
      kind: _i2bme9zf.MediaKind.fromJson((jsonSerialization['kind'] as String)),
      fileName: jsonSerialization['fileName'] as String,
      mimeType: jsonSerialization['mimeType'] as String,
      sizeBytes: jsonSerialization['sizeBytes'] as int,
      sha256: jsonSerialization['sha256'] as String,
      width: jsonSerialization['width'] as int,
      height: jsonSerialization['height'] as int,
      storageKey: jsonSerialization['storageKey'] as String,
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

  static final t = MediaFileTable();

  static const db = MediaFileRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue? outletId;

  _i2bme9zf.MediaKind kind;

  String fileName;

  String mimeType;

  int sizeBytes;

  String sha256;

  int width;

  int height;

  String storageKey;

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

  /// Returns a shallow copy of this [MediaFile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MediaFile copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId = const _isc.$UndefinedUuidValue(),
    _i2bme9zf.MediaKind? kind,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    String? sha256,
    int? width,
    int? height,
    String? storageKey,
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
      '__className__': 'MediaFile',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      if (outletId != null) 'outletId': outletId?.toJson(),
      'kind': kind.toJson(),
      'fileName': fileName,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'sha256': sha256,
      'width': width,
      'height': height,
      'storageKey': storageKey,
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
      '__className__': 'MediaFile',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      if (outletId != null) 'outletId': outletId?.toJson(),
      'kind': kind.toJson(),
      'fileName': fileName,
      'mimeType': mimeType,
      'sizeBytes': sizeBytes,
      'sha256': sha256,
      'width': width,
      'height': height,
      'storageKey': storageKey,
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

  static MediaFileInclude include() {
    return MediaFileInclude._();
  }

  static MediaFileIncludeList includeList({
    _isd.WhereExpressionBuilder<MediaFileTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<MediaFileTable>? orderBy,
    _isd.OrderByListBuilder<MediaFileTable>? orderByList,
    MediaFileInclude? include,
  }) {
    return MediaFileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MediaFile.t),
      orderByList: orderByList?.call(MediaFile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _MediaFileImpl extends MediaFile {
  _MediaFileImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    _isc.UuidValue? outletId,
    required _i2bme9zf.MediaKind kind,
    required String fileName,
    required String mimeType,
    required int sizeBytes,
    required String sha256,
    required int width,
    required int height,
    required String storageKey,
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
         kind: kind,
         fileName: fileName,
         mimeType: mimeType,
         sizeBytes: sizeBytes,
         sha256: sha256,
         width: width,
         height: height,
         storageKey: storageKey,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [MediaFile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MediaFile copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? outletId = const _isc.$UndefinedUuidValue(),
    _i2bme9zf.MediaKind? kind,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    String? sha256,
    int? width,
    int? height,
    String? storageKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return MediaFile(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      outletId: outletId is _isc.UndefinedSentinel ? this.outletId : outletId,
      kind: kind ?? this.kind,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sha256: sha256 ?? this.sha256,
      width: width ?? this.width,
      height: height ?? this.height,
      storageKey: storageKey ?? this.storageKey,
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

class MediaFileUpdateTable extends _isd.UpdateTable<MediaFileTable> {
  MediaFileUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> tenantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.tenantId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> outletId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.outletId,
    value,
  );

  _isd.ColumnValue<_i2bme9zf.MediaKind, _i2bme9zf.MediaKind> kind(
    _i2bme9zf.MediaKind value,
  ) => _isd.ColumnValue(
    table.kind,
    value,
  );

  _isd.ColumnValue<String, String> fileName(String value) => _isd.ColumnValue(
    table.fileName,
    value,
  );

  _isd.ColumnValue<String, String> mimeType(String value) => _isd.ColumnValue(
    table.mimeType,
    value,
  );

  _isd.ColumnValue<int, int> sizeBytes(int value) => _isd.ColumnValue(
    table.sizeBytes,
    value,
  );

  _isd.ColumnValue<String, String> sha256(String value) => _isd.ColumnValue(
    table.sha256,
    value,
  );

  _isd.ColumnValue<int, int> width(int value) => _isd.ColumnValue(
    table.width,
    value,
  );

  _isd.ColumnValue<int, int> height(int value) => _isd.ColumnValue(
    table.height,
    value,
  );

  _isd.ColumnValue<String, String> storageKey(String value) => _isd.ColumnValue(
    table.storageKey,
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

class MediaFileTable extends _isd.Table<_isc.UuidValue> {
  MediaFileTable({super.tableRelation}) : super(tableName: 'media_files') {
    updateTable = MediaFileUpdateTable(this);
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
    kind = _isd.ColumnEnum(
      'kind',
      this,
      _isd.EnumSerialization.byName,
    );
    fileName = _isd.ColumnString(
      'file_name',
      this,
      fieldName: 'fileName',
    );
    mimeType = _isd.ColumnString(
      'mime_type',
      this,
      fieldName: 'mimeType',
    );
    sizeBytes = _isd.ColumnInt(
      'size_bytes',
      this,
      fieldName: 'sizeBytes',
    );
    sha256 = _isd.ColumnString(
      'sha256',
      this,
    );
    width = _isd.ColumnInt(
      'width',
      this,
    );
    height = _isd.ColumnInt(
      'height',
      this,
    );
    storageKey = _isd.ColumnString(
      'storage_key',
      this,
      fieldName: 'storageKey',
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

  late final MediaFileUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid outletId;

  late final _isd.ColumnEnum<_i2bme9zf.MediaKind> kind;

  late final _isd.ColumnString fileName;

  late final _isd.ColumnString mimeType;

  late final _isd.ColumnInt sizeBytes;

  late final _isd.ColumnString sha256;

  late final _isd.ColumnInt width;

  late final _isd.ColumnInt height;

  late final _isd.ColumnString storageKey;

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
    kind,
    fileName,
    mimeType,
    sizeBytes,
    sha256,
    width,
    height,
    storageKey,
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

class MediaFileInclude extends _isd.IncludeObject {
  MediaFileInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => MediaFile.t;
}

class MediaFileIncludeList extends _isd.IncludeList {
  MediaFileIncludeList._({
    _isd.WhereExpressionBuilder<MediaFileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MediaFile.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => MediaFile.t;
}

class MediaFileRepository {
  const MediaFileRepository._();

  /// Returns a list of [MediaFile]s matching the given query parameters.
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
  Future<List<MediaFile>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<MediaFileTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<MediaFileTable>? orderBy,
    _isd.OrderByListBuilder<MediaFileTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MediaFile>(
      where: where?.call(MediaFile.t),
      orderBy: orderBy?.call(MediaFile.t),
      orderByList: orderByList?.call(MediaFile.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [MediaFile]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `MediaFile.t`.
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
  _ida.Stream<List<MediaFile>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<MediaFileTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<MediaFileTable>? orderBy,
    _isd.OrderByListBuilder<MediaFileTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<MediaFile>(
      where: where?.call(MediaFile.t),
      orderBy: orderBy?.call(MediaFile.t),
      orderByList: orderByList?.call(MediaFile.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [MediaFile] matching the given query parameters.
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
  Future<MediaFile?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<MediaFileTable>? where,
    int? offset,
    _isd.OrderByBuilder<MediaFileTable>? orderBy,
    _isd.OrderByListBuilder<MediaFileTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MediaFile>(
      where: where?.call(MediaFile.t),
      orderBy: orderBy?.call(MediaFile.t),
      orderByList: orderByList?.call(MediaFile.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MediaFile] by its [id] or null if no such row exists.
  Future<MediaFile?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MediaFile>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MediaFile]s in the list and returns the inserted rows.
  ///
  /// The returned [MediaFile]s will have their `id` fields set.
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
  Future<List<MediaFile>> insert(
    _isd.DatabaseSession session,
    List<MediaFile> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<MediaFile>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [MediaFile] and returns the inserted row.
  ///
  /// The returned [MediaFile] will have its `id` field set.
  Future<MediaFile> insertRow(
    _isd.DatabaseSession session,
    MediaFile row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<MediaFile>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [MediaFile]s in the list and returns the resulting rows.
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
  /// The returned [MediaFile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MediaFile>> upsert(
    _isd.DatabaseSession session,
    List<MediaFile> rows, {
    required _isd.ColumnSelections<MediaFileTable> conflictColumns,
    _isd.ColumnSelections<MediaFileTable>? updateColumns,
    _isd.WhereExpressionBuilder<MediaFileTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<MediaFile>(
      rows,
      conflictColumns: conflictColumns(MediaFile.t),
      updateColumns: updateColumns?.call(MediaFile.t),
      updateWhere: updateWhere?.call(MediaFile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [MediaFile] and returns the resulting row.
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
  /// The returned [MediaFile] will have its `id` field set.
  Future<MediaFile?> upsertRow(
    _isd.DatabaseSession session,
    MediaFile row, {
    required _isd.ColumnSelections<MediaFileTable> conflictColumns,
    _isd.ColumnSelections<MediaFileTable>? updateColumns,
    _isd.WhereExpressionBuilder<MediaFileTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<MediaFile>(
      row,
      conflictColumns: conflictColumns(MediaFile.t),
      updateColumns: updateColumns?.call(MediaFile.t),
      updateWhere: updateWhere?.call(MediaFile.t),
      transaction: transaction,
    );
  }

  /// Updates all [MediaFile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MediaFile>> update(
    _isd.DatabaseSession session,
    List<MediaFile> rows, {
    _isd.ColumnSelections<MediaFileTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<MediaFile>(
      rows,
      columns: columns?.call(MediaFile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [MediaFile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MediaFile> updateRow(
    _isd.DatabaseSession session,
    MediaFile row, {
    _isd.ColumnSelections<MediaFileTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<MediaFile>(
      row,
      columns: columns?.call(MediaFile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MediaFile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MediaFile?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<MediaFileUpdateTable> columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<MediaFile>(
      id,
      columnValues: columnValues(MediaFile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MediaFile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MediaFile>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<MediaFileUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<MediaFileTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<MediaFileTable>? orderBy,
    _isd.OrderByListBuilder<MediaFileTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<MediaFile>(
      columnValues: columnValues(MediaFile.t.updateTable),
      where: where(MediaFile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MediaFile.t),
      orderByList: orderByList?.call(MediaFile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [MediaFile]s in the list and returns the deleted rows.
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
  Future<List<MediaFile>> delete(
    _isd.DatabaseSession session,
    List<MediaFile> rows, {
    _isd.OrderByBuilder<MediaFileTable>? orderBy,
    _isd.OrderByListBuilder<MediaFileTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<MediaFile>(
      rows,
      orderBy: orderBy?.call(MediaFile.t),
      orderByList: orderByList?.call(MediaFile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [MediaFile].
  Future<MediaFile> deleteRow(
    _isd.DatabaseSession session,
    MediaFile row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MediaFile>(
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
  Future<List<MediaFile>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<MediaFileTable> where,
    _isd.OrderByBuilder<MediaFileTable>? orderBy,
    _isd.OrderByListBuilder<MediaFileTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<MediaFile>(
      where: where(MediaFile.t),
      orderBy: orderBy?.call(MediaFile.t),
      orderByList: orderByList?.call(MediaFile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<MediaFileTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<MediaFile>(
      where: where?.call(MediaFile.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MediaFile] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<MediaFileTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MediaFile>(
      where: where(MediaFile.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
