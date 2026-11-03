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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// Asal pergerakan stok di ledger `stock_movements`.
enum StockSourceType implements _isc.SerializableModel {
  opening,
  adjustment,
  sale,
  saleReturn,
  purchase,
  purchaseReturn,
  transfer;

  static StockSourceType fromJson(String name) {
    switch (name) {
      case 'opening':
        return StockSourceType.opening;
      case 'adjustment':
        return StockSourceType.adjustment;
      case 'sale':
        return StockSourceType.sale;
      case 'saleReturn':
        return StockSourceType.saleReturn;
      case 'purchase':
        return StockSourceType.purchase;
      case 'purchaseReturn':
        return StockSourceType.purchaseReturn;
      case 'transfer':
        return StockSourceType.transfer;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "StockSourceType"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
