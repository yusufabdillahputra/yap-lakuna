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

/// Alasan umum dokumen penyesuaian stok (F1-08).
enum StockAdjustmentReason implements _isc.SerializableModel {
  routineCheck,
  damaged,
  lost,
  expired,
  other;

  static StockAdjustmentReason fromJson(String name) {
    switch (name) {
      case 'routineCheck':
        return StockAdjustmentReason.routineCheck;
      case 'damaged':
        return StockAdjustmentReason.damaged;
      case 'lost':
        return StockAdjustmentReason.lost;
      case 'expired':
        return StockAdjustmentReason.expired;
      case 'other':
        return StockAdjustmentReason.other;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "StockAdjustmentReason"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
