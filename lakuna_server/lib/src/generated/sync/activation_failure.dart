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

/// Alasan aktivasi atau pasang perangkat gagal (F2-01 aturan 9–11).
enum ActivationFailure implements _is.SerializableModel {
  codeInvalid,
  codeUsed,
  codeExpired,
  tenantActive,
  copiedDevice,
  notOwner,
  outletUnknown,
  deviceCodeTaken;

  static ActivationFailure fromJson(String name) {
    switch (name) {
      case 'codeInvalid':
        return ActivationFailure.codeInvalid;
      case 'codeUsed':
        return ActivationFailure.codeUsed;
      case 'codeExpired':
        return ActivationFailure.codeExpired;
      case 'tenantActive':
        return ActivationFailure.tenantActive;
      case 'copiedDevice':
        return ActivationFailure.copiedDevice;
      case 'notOwner':
        return ActivationFailure.notOwner;
      case 'outletUnknown':
        return ActivationFailure.outletUnknown;
      case 'deviceCodeTaken':
        return ActivationFailure.deviceCodeTaken;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "ActivationFailure"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
