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
import 'package:serverpod/serverpod.dart' as _is;

/// Cache saldo stok per lokasi dan varian, hanya di perangkat. Diperbarui
/// bersama `stock_movements` dan bisa dibangun ulang dari ledger.
abstract class StockLevel
    implements _is.SerializableModel, _is.ProtocolSerialization {
  StockLevel._({
    this.id,
    required this.stockLocationId,
    required this.variantId,
    required this.quantityMilli,
    required this.avgCost,
  });

  factory StockLevel({
    int? id,
    required _is.UuidValue stockLocationId,
    required _is.UuidValue variantId,
    required int quantityMilli,
    required int avgCost,
  }) = _StockLevelImpl;

  factory StockLevel.fromJson(Map<String, dynamic> jsonSerialization) {
    return StockLevel(
      id: jsonSerialization['id'] as int?,
      stockLocationId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['stockLocationId'],
      ),
      variantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['variantId'],
      ),
      quantityMilli: jsonSerialization['quantityMilli'] as int,
      avgCost: jsonSerialization['avgCost'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _is.UuidValue stockLocationId;

  _is.UuidValue variantId;

  int quantityMilli;

  /// Rata-rata biaya per satuan dasar; hanya berubah oleh barang masuk.
  int avgCost;

  /// Returns a shallow copy of this [StockLevel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  StockLevel copyWith({
    int? id,
    _is.UuidValue? stockLocationId,
    _is.UuidValue? variantId,
    int? quantityMilli,
    int? avgCost,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StockLevel',
      if (id != null) 'id': id,
      'stockLocationId': stockLocationId.toJson(),
      'variantId': variantId.toJson(),
      'quantityMilli': quantityMilli,
      'avgCost': avgCost,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StockLevel',
      if (id != null) 'id': id,
      'stockLocationId': stockLocationId.toJson(),
      'variantId': variantId.toJson(),
      'quantityMilli': quantityMilli,
      'avgCost': avgCost,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StockLevelImpl extends StockLevel {
  _StockLevelImpl({
    int? id,
    required _is.UuidValue stockLocationId,
    required _is.UuidValue variantId,
    required int quantityMilli,
    required int avgCost,
  }) : super._(
         id: id,
         stockLocationId: stockLocationId,
         variantId: variantId,
         quantityMilli: quantityMilli,
         avgCost: avgCost,
       );

  /// Returns a shallow copy of this [StockLevel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  StockLevel copyWith({
    Object? id = _Undefined,
    _is.UuidValue? stockLocationId,
    _is.UuidValue? variantId,
    int? quantityMilli,
    int? avgCost,
  }) {
    return StockLevel(
      id: id is int? ? id : this.id,
      stockLocationId: stockLocationId ?? this.stockLocationId,
      variantId: variantId ?? this.variantId,
      quantityMilli: quantityMilli ?? this.quantityMilli,
      avgCost: avgCost ?? this.avgCost,
    );
  }
}
