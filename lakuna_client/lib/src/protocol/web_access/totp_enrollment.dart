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

/// Rahasia TOTP baru yang belum dikonfirmasi, untuk QR dan teks salin.
abstract class TotpEnrollment
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TotpEnrollment._({
    required this.secretBase32,
    required this.otpauthUri,
  });

  factory TotpEnrollment({
    required String secretBase32,
    required String otpauthUri,
  }) = _TotpEnrollmentImpl;

  factory TotpEnrollment.fromJson(Map<String, dynamic> jsonSerialization) {
    return TotpEnrollment(
      secretBase32: jsonSerialization['secretBase32'] as String,
      otpauthUri: jsonSerialization['otpauthUri'] as String,
    );
  }

  String secretBase32;

  String otpauthUri;

  /// Returns a shallow copy of this [TotpEnrollment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TotpEnrollment copyWith({
    String? secretBase32,
    String? otpauthUri,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TotpEnrollment',
      'secretBase32': secretBase32,
      'otpauthUri': otpauthUri,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TotpEnrollment',
      'secretBase32': secretBase32,
      'otpauthUri': otpauthUri,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _TotpEnrollmentImpl extends TotpEnrollment {
  _TotpEnrollmentImpl({
    required String secretBase32,
    required String otpauthUri,
  }) : super._(
         secretBase32: secretBase32,
         otpauthUri: otpauthUri,
       );

  /// Returns a shallow copy of this [TotpEnrollment]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TotpEnrollment copyWith({
    String? secretBase32,
    String? otpauthUri,
  }) {
    return TotpEnrollment(
      secretBase32: secretBase32 ?? this.secretBase32,
      otpauthUri: otpauthUri ?? this.otpauthUri,
    );
  }
}
