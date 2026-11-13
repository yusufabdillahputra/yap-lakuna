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
import '../catalog/product_type.dart' as _irwhsd0r;

/// Produk (F1-07). Stok, harga grosir, dan isi konversi selalu dalam
/// satuan dasar [baseUnitId].
abstract class Product
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  Product._({
    _isc.UuidValue? id,
    required this.tenantId,
    this.categoryId,
    required this.baseUnitId,
    required this.name,
    required this.type,
    this.sku,
    this.brand,
    bool? isActive,
    bool? isTaxable,
    bool? sendToKitchen,
    bool? allowNote,
    this.photoMediaId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    int? version,
    required this.hlc,
    this.originDeviceId,
  }) : id = id ?? const _isc.Uuid().v7obj(),
       isActive = isActive ?? true,
       isTaxable = isTaxable ?? false,
       sendToKitchen = sendToKitchen ?? true,
       allowNote = allowNote ?? true,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       version = version ?? 1;

  factory Product({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    _isc.UuidValue? categoryId,
    required _isc.UuidValue baseUnitId,
    required String name,
    required _irwhsd0r.ProductType type,
    String? sku,
    String? brand,
    bool? isActive,
    bool? isTaxable,
    bool? sendToKitchen,
    bool? allowNote,
    _isc.UuidValue? photoMediaId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    _isc.UuidValue? createdBy,
    _isc.UuidValue? updatedBy,
    int? version,
    required String hlc,
    _isc.UuidValue? originDeviceId,
  }) = _ProductImpl;

  factory Product.fromJson(Map<String, dynamic> jsonSerialization) {
    return Product(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      categoryId: jsonSerialization['categoryId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['categoryId'],
            ),
      baseUnitId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['baseUnitId'],
      ),
      name: jsonSerialization['name'] as String,
      type: _irwhsd0r.ProductType.fromJson(
        (jsonSerialization['type'] as String),
      ),
      sku: jsonSerialization['sku'] as String?,
      brand: jsonSerialization['brand'] as String?,
      isActive: jsonSerialization['isActive'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
      isTaxable: jsonSerialization['isTaxable'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isTaxable']),
      sendToKitchen: jsonSerialization['sendToKitchen'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['sendToKitchen']),
      allowNote: jsonSerialization['allowNote'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['allowNote']),
      photoMediaId: jsonSerialization['photoMediaId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['photoMediaId'],
            ),
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

  static final t = ProductTable();

  static const db = ProductRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue tenantId;

  _isc.UuidValue? categoryId;

  _isc.UuidValue baseUnitId;

  String name;

  _irwhsd0r.ProductType type;

  /// SKU induk (opsional, tidak wajib unik).
  String? sku;

  String? brand;

  /// Sakelar *Dijual di kasir*.
  bool isActive;

  bool isTaxable;

  /// Sakelar *Kirim ke tiket dapur* (F1-10g): mati = item langsung
  /// disajikan tanpa tiket dapur.
  bool sendToKitchen;

  /// Sakelar *Bisa catatan bebas* (F1-10g): mati = catatan item diabaikan.
  bool allowNote;

  /// Foto produk (F1-07f), berkas di folder media.
  _isc.UuidValue? photoMediaId;

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

  /// Returns a shallow copy of this [Product]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Product copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? categoryId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? baseUnitId,
    String? name,
    _irwhsd0r.ProductType? type,
    String? sku,
    String? brand,
    bool? isActive,
    bool? isTaxable,
    bool? sendToKitchen,
    bool? allowNote,
    _isc.UuidValue? photoMediaId = const _isc.$UndefinedUuidValue(),
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
      '__className__': 'Product',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      if (categoryId != null) 'categoryId': categoryId?.toJson(),
      'baseUnitId': baseUnitId.toJson(),
      'name': name,
      'type': type.toJson(),
      if (sku != null) 'sku': sku,
      if (brand != null) 'brand': brand,
      'isActive': isActive,
      'isTaxable': isTaxable,
      'sendToKitchen': sendToKitchen,
      'allowNote': allowNote,
      if (photoMediaId != null) 'photoMediaId': photoMediaId?.toJson(),
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
      '__className__': 'Product',
      'id': id.toJson(),
      'tenantId': tenantId.toJson(),
      if (categoryId != null) 'categoryId': categoryId?.toJson(),
      'baseUnitId': baseUnitId.toJson(),
      'name': name,
      'type': type.toJson(),
      if (sku != null) 'sku': sku,
      if (brand != null) 'brand': brand,
      'isActive': isActive,
      'isTaxable': isTaxable,
      'sendToKitchen': sendToKitchen,
      'allowNote': allowNote,
      if (photoMediaId != null) 'photoMediaId': photoMediaId?.toJson(),
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

  static ProductInclude include() {
    return ProductInclude._();
  }

  static ProductIncludeList includeList({
    _isd.WhereExpressionBuilder<ProductTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ProductTable>? orderBy,
    _isd.OrderByListBuilder<ProductTable>? orderByList,
    ProductInclude? include,
  }) {
    return ProductIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Product.t),
      orderByList: orderByList?.call(Product.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductImpl extends Product {
  _ProductImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue tenantId,
    _isc.UuidValue? categoryId,
    required _isc.UuidValue baseUnitId,
    required String name,
    required _irwhsd0r.ProductType type,
    String? sku,
    String? brand,
    bool? isActive,
    bool? isTaxable,
    bool? sendToKitchen,
    bool? allowNote,
    _isc.UuidValue? photoMediaId,
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
         categoryId: categoryId,
         baseUnitId: baseUnitId,
         name: name,
         type: type,
         sku: sku,
         brand: brand,
         isActive: isActive,
         isTaxable: isTaxable,
         sendToKitchen: sendToKitchen,
         allowNote: allowNote,
         photoMediaId: photoMediaId,
         createdAt: createdAt,
         updatedAt: updatedAt,
         deletedAt: deletedAt,
         createdBy: createdBy,
         updatedBy: updatedBy,
         version: version,
         hlc: hlc,
         originDeviceId: originDeviceId,
       );

  /// Returns a shallow copy of this [Product]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Product copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? categoryId = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? baseUnitId,
    String? name,
    _irwhsd0r.ProductType? type,
    Object? sku = _Undefined,
    Object? brand = _Undefined,
    bool? isActive,
    bool? isTaxable,
    bool? sendToKitchen,
    bool? allowNote,
    _isc.UuidValue? photoMediaId = const _isc.$UndefinedUuidValue(),
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt = const _isc.$UndefinedDateTime(),
    _isc.UuidValue? createdBy = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? updatedBy = const _isc.$UndefinedUuidValue(),
    int? version,
    String? hlc,
    _isc.UuidValue? originDeviceId = const _isc.$UndefinedUuidValue(),
  }) {
    return Product(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      categoryId: categoryId is _isc.UndefinedSentinel
          ? this.categoryId
          : categoryId,
      baseUnitId: baseUnitId ?? this.baseUnitId,
      name: name ?? this.name,
      type: type ?? this.type,
      sku: sku is String? ? sku : this.sku,
      brand: brand is String? ? brand : this.brand,
      isActive: isActive ?? this.isActive,
      isTaxable: isTaxable ?? this.isTaxable,
      sendToKitchen: sendToKitchen ?? this.sendToKitchen,
      allowNote: allowNote ?? this.allowNote,
      photoMediaId: photoMediaId is _isc.UndefinedSentinel
          ? this.photoMediaId
          : photoMediaId,
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

class ProductUpdateTable extends _isd.UpdateTable<ProductTable> {
  ProductUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> tenantId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.tenantId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> categoryId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.categoryId,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> baseUnitId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.baseUnitId,
    value,
  );

  _isd.ColumnValue<String, String> name(String value) => _isd.ColumnValue(
    table.name,
    value,
  );

  _isd.ColumnValue<_irwhsd0r.ProductType, _irwhsd0r.ProductType> type(
    _irwhsd0r.ProductType value,
  ) => _isd.ColumnValue(
    table.type,
    value,
  );

  _isd.ColumnValue<String, String> sku(String? value) => _isd.ColumnValue(
    table.sku,
    value,
  );

  _isd.ColumnValue<String, String> brand(String? value) => _isd.ColumnValue(
    table.brand,
    value,
  );

  _isd.ColumnValue<bool, bool> isActive(bool value) => _isd.ColumnValue(
    table.isActive,
    value,
  );

  _isd.ColumnValue<bool, bool> isTaxable(bool value) => _isd.ColumnValue(
    table.isTaxable,
    value,
  );

  _isd.ColumnValue<bool, bool> sendToKitchen(bool value) => _isd.ColumnValue(
    table.sendToKitchen,
    value,
  );

  _isd.ColumnValue<bool, bool> allowNote(bool value) => _isd.ColumnValue(
    table.allowNote,
    value,
  );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> photoMediaId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.photoMediaId,
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

class ProductTable extends _isd.Table<_isc.UuidValue> {
  ProductTable({super.tableRelation}) : super(tableName: 'products') {
    updateTable = ProductUpdateTable(this);
    tenantId = _isd.ColumnUuid(
      'tenant_id',
      this,
      fieldName: 'tenantId',
    );
    categoryId = _isd.ColumnUuid(
      'category_id',
      this,
      fieldName: 'categoryId',
    );
    baseUnitId = _isd.ColumnUuid(
      'base_unit_id',
      this,
      fieldName: 'baseUnitId',
    );
    name = _isd.ColumnString(
      'name',
      this,
    );
    type = _isd.ColumnEnum(
      'type',
      this,
      _isd.EnumSerialization.byName,
    );
    sku = _isd.ColumnString(
      'sku',
      this,
    );
    brand = _isd.ColumnString(
      'brand',
      this,
    );
    isActive = _isd.ColumnBool(
      'is_active',
      this,
      hasDefault: true,
      fieldName: 'isActive',
    );
    isTaxable = _isd.ColumnBool(
      'is_taxable',
      this,
      hasDefault: true,
      fieldName: 'isTaxable',
    );
    sendToKitchen = _isd.ColumnBool(
      'send_to_kitchen',
      this,
      hasDefault: true,
      fieldName: 'sendToKitchen',
    );
    allowNote = _isd.ColumnBool(
      'allow_note',
      this,
      hasDefault: true,
      fieldName: 'allowNote',
    );
    photoMediaId = _isd.ColumnUuid(
      'photo_media_id',
      this,
      fieldName: 'photoMediaId',
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

  late final ProductUpdateTable updateTable;

  late final _isd.ColumnUuid tenantId;

  late final _isd.ColumnUuid categoryId;

  late final _isd.ColumnUuid baseUnitId;

  late final _isd.ColumnString name;

  late final _isd.ColumnEnum<_irwhsd0r.ProductType> type;

  /// SKU induk (opsional, tidak wajib unik).
  late final _isd.ColumnString sku;

  late final _isd.ColumnString brand;

  /// Sakelar *Dijual di kasir*.
  late final _isd.ColumnBool isActive;

  late final _isd.ColumnBool isTaxable;

  /// Sakelar *Kirim ke tiket dapur* (F1-10g): mati = item langsung
  /// disajikan tanpa tiket dapur.
  late final _isd.ColumnBool sendToKitchen;

  /// Sakelar *Bisa catatan bebas* (F1-10g): mati = catatan item diabaikan.
  late final _isd.ColumnBool allowNote;

  /// Foto produk (F1-07f), berkas di folder media.
  late final _isd.ColumnUuid photoMediaId;

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
    categoryId,
    baseUnitId,
    name,
    type,
    sku,
    brand,
    isActive,
    isTaxable,
    sendToKitchen,
    allowNote,
    photoMediaId,
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

class ProductInclude extends _isd.IncludeObject {
  ProductInclude._();

  @override
  Map<String, _isd.Include?> get includes => {};

  @override
  _isd.Table<_isc.UuidValue> get table => Product.t;
}

class ProductIncludeList extends _isd.IncludeList {
  ProductIncludeList._({
    _isd.WhereExpressionBuilder<ProductTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Product.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => Product.t;
}

class ProductRepository {
  const ProductRepository._();

  /// Returns a list of [Product]s matching the given query parameters.
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
  Future<List<Product>> find(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ProductTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ProductTable>? orderBy,
    _isd.OrderByListBuilder<ProductTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Product>(
      where: where?.call(Product.t),
      orderBy: orderBy?.call(Product.t),
      orderByList: orderByList?.call(Product.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [Product]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `Product.t`.
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
  _ida.Stream<List<Product>> watch(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ProductTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ProductTable>? orderBy,
    _isd.OrderByListBuilder<ProductTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_isd.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<Product>(
      where: where?.call(Product.t),
      orderBy: orderBy?.call(Product.t),
      orderByList: orderByList?.call(Product.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [Product] matching the given query parameters.
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
  Future<Product?> findFirstRow(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ProductTable>? where,
    int? offset,
    _isd.OrderByBuilder<ProductTable>? orderBy,
    _isd.OrderByListBuilder<ProductTable>? orderByList,
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Product>(
      where: where?.call(Product.t),
      orderBy: orderBy?.call(Product.t),
      orderByList: orderByList?.call(Product.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Product] by its [id] or null if no such row exists.
  Future<Product?> findById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Product>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Product]s in the list and returns the inserted rows.
  ///
  /// The returned [Product]s will have their `id` fields set.
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
  Future<List<Product>> insert(
    _isd.DatabaseSession session,
    List<Product> rows, {
    _isd.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Product>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Product] and returns the inserted row.
  ///
  /// The returned [Product] will have its `id` field set.
  Future<Product> insertRow(
    _isd.DatabaseSession session,
    Product row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.insertRow<Product>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Product]s in the list and returns the resulting rows.
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
  /// The returned [Product]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Product>> upsert(
    _isd.DatabaseSession session,
    List<Product> rows, {
    required _isd.ColumnSelections<ProductTable> conflictColumns,
    _isd.ColumnSelections<ProductTable>? updateColumns,
    _isd.WhereExpressionBuilder<ProductTable>? updateWhere,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Product>(
      rows,
      conflictColumns: conflictColumns(Product.t),
      updateColumns: updateColumns?.call(Product.t),
      updateWhere: updateWhere?.call(Product.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Product] and returns the resulting row.
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
  /// The returned [Product] will have its `id` field set.
  Future<Product?> upsertRow(
    _isd.DatabaseSession session,
    Product row, {
    required _isd.ColumnSelections<ProductTable> conflictColumns,
    _isd.ColumnSelections<ProductTable>? updateColumns,
    _isd.WhereExpressionBuilder<ProductTable>? updateWhere,
    _isd.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Product>(
      row,
      conflictColumns: conflictColumns(Product.t),
      updateColumns: updateColumns?.call(Product.t),
      updateWhere: updateWhere?.call(Product.t),
      transaction: transaction,
    );
  }

  /// Updates all [Product]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Product>> update(
    _isd.DatabaseSession session,
    List<Product> rows, {
    _isd.ColumnSelections<ProductTable>? columns,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Product>(
      rows,
      columns: columns?.call(Product.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Product]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Product> updateRow(
    _isd.DatabaseSession session,
    Product row, {
    _isd.ColumnSelections<ProductTable>? columns,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateRow<Product>(
      row,
      columns: columns?.call(Product.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Product] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Product?> updateById(
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<ProductUpdateTable> columnValues,
    _isd.Transaction? transaction,
  }) async {
    return session.db.updateById<Product>(
      id,
      columnValues: columnValues(Product.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Product]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Product>> updateWhere(
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<ProductUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<ProductTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<ProductTable>? orderBy,
    _isd.OrderByListBuilder<ProductTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Product>(
      columnValues: columnValues(Product.t.updateTable),
      where: where(Product.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Product.t),
      orderByList: orderByList?.call(Product.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Product]s in the list and returns the deleted rows.
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
  Future<List<Product>> delete(
    _isd.DatabaseSession session,
    List<Product> rows, {
    _isd.OrderByBuilder<ProductTable>? orderBy,
    _isd.OrderByListBuilder<ProductTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Product>(
      rows,
      orderBy: orderBy?.call(Product.t),
      orderByList: orderByList?.call(Product.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Product].
  Future<Product> deleteRow(
    _isd.DatabaseSession session,
    Product row, {
    _isd.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Product>(
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
  Future<List<Product>> deleteWhere(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<ProductTable> where,
    _isd.OrderByBuilder<ProductTable>? orderBy,
    _isd.OrderByListBuilder<ProductTable>? orderByList,
    _isd.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Product>(
      where: where(Product.t),
      orderBy: orderBy?.call(Product.t),
      orderByList: orderByList?.call(Product.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<ProductTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<Product>(
      where: where?.call(Product.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Product] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<ProductTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Product>(
      where: where(Product.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
