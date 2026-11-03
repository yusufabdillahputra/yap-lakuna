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

/// Jenis pesanan (F1-10): penjualan kasir retail, dine in (meja), take away.
enum OrderType implements _is.SerializableModel {
  retail,
  dineIn,
  takeAway;

  static OrderType fromJson(String name) {
    switch (name) {
      case 'retail':
        return OrderType.retail;
      case 'dineIn':
        return OrderType.dineIn;
      case 'takeAway':
        return OrderType.takeAway;
      default:
        throw ArgumentError('Value "$name" cannot be converted to "OrderType"');
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
