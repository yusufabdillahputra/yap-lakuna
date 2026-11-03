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

/// Arah uang laci di luar penjualan: masuk atau keluar.
enum CashDirection implements _isc.SerializableModel {
  inflow,
  outflow;

  static CashDirection fromJson(String name) {
    switch (name) {
      case 'inflow':
        return CashDirection.inflow;
      case 'outflow':
        return CashDirection.outflow;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "CashDirection"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
