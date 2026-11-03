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

/// Sumber dana bayar pembelian atau uang kembali retur beli (F1-12).
/// `drawer` menulis `cash_movements` di sesi kasir perangkat.
enum FundingSource implements _is.SerializableModel {
  storeCash,
  drawer,
  bank;

  static FundingSource fromJson(String name) {
    switch (name) {
      case 'storeCash':
        return FundingSource.storeCash;
      case 'drawer':
        return FundingSource.drawer;
      case 'bank':
        return FundingSource.bank;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "FundingSource"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
