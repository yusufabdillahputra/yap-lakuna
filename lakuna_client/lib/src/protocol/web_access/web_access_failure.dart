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

/// Alasan login web atau pengaturan verifikasi 2 langkah ditolak
/// (F2-02 aturan 11–14).
enum WebAccessFailure implements _isc.SerializableModel {
  noTenant,
  totpNotEnabled,
  totpInvalid,
  locked,
  sessionExpired,
  totpKeyMissing,
  totpAlreadyEnabled,
  notOwner;

  static WebAccessFailure fromJson(String name) {
    switch (name) {
      case 'noTenant':
        return WebAccessFailure.noTenant;
      case 'totpNotEnabled':
        return WebAccessFailure.totpNotEnabled;
      case 'totpInvalid':
        return WebAccessFailure.totpInvalid;
      case 'locked':
        return WebAccessFailure.locked;
      case 'sessionExpired':
        return WebAccessFailure.sessionExpired;
      case 'totpKeyMissing':
        return WebAccessFailure.totpKeyMissing;
      case 'totpAlreadyEnabled':
        return WebAccessFailure.totpAlreadyEnabled;
      case 'notOwner':
        return WebAccessFailure.notOwner;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "WebAccessFailure"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
