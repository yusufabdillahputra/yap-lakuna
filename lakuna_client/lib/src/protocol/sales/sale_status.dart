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

/// Status nota: `completed` lunas; `open` open bill (F1-10); `voided` dan
/// retur sebagian/penuh (F1-11).
enum SaleStatus implements _isc.SerializableModel {
  open,
  completed,
  voided,
  partiallyReturned,
  returned;

  static SaleStatus fromJson(String name) {
    switch (name) {
      case 'open':
        return SaleStatus.open;
      case 'completed':
        return SaleStatus.completed;
      case 'voided':
        return SaleStatus.voided;
      case 'partiallyReturned':
        return SaleStatus.partiallyReturned;
      case 'returned':
        return SaleStatus.returned;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "SaleStatus"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
