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

/// Alasan entri push ditolak (F2-01 aturan 1). `finalDocument` = isi
/// dokumen final diubah (aturan 7a).
enum SyncRejectReason implements _is.SerializableModel {
  tenant,
  table,
  device,
  finalDocument,
  unique,
  dependency,
  clock;

  static SyncRejectReason fromJson(String name) {
    switch (name) {
      case 'tenant':
        return SyncRejectReason.tenant;
      case 'table':
        return SyncRejectReason.table;
      case 'device':
        return SyncRejectReason.device;
      case 'finalDocument':
        return SyncRejectReason.finalDocument;
      case 'unique':
        return SyncRejectReason.unique;
      case 'dependency':
        return SyncRejectReason.dependency;
      case 'clock':
        return SyncRejectReason.clock;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "SyncRejectReason"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
