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

/// Status nota: `completed` lunas tersimpan; `open` (nota tersimpan / open
/// bill) dan `voided` menyusul (F1-04 1.4b, F1-10, F1-11).
enum SaleStatus implements _is.SerializableModel {
  open,
  completed,
  voided;

  static SaleStatus fromJson(String name) {
    switch (name) {
      case 'open':
        return SaleStatus.open;
      case 'completed':
        return SaleStatus.completed;
      case 'voided':
        return SaleStatus.voided;
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
