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

/// Hasil aktivasi perangkat pertama atau pasang perangkat berikutnya.
/// `deviceToken` hanya dikirim sekali; server menyimpan hash-nya.
abstract class ActivationResult
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ActivationResult._({
    required this.deviceToken,
    required this.tenantId,
    required this.deviceId,
    required this.deviceCode,
  });

  factory ActivationResult({
    required String deviceToken,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue deviceId,
    required String deviceCode,
  }) = _ActivationResultImpl;

  factory ActivationResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return ActivationResult(
      deviceToken: jsonSerialization['deviceToken'] as String,
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      deviceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['deviceId'],
      ),
      deviceCode: jsonSerialization['deviceCode'] as String,
    );
  }

  String deviceToken;

  _isc.UuidValue tenantId;

  _isc.UuidValue deviceId;

  String deviceCode;

  /// Returns a shallow copy of this [ActivationResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ActivationResult copyWith({
    String? deviceToken,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? deviceId,
    String? deviceCode,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ActivationResult',
      'deviceToken': deviceToken,
      'tenantId': tenantId.toJson(),
      'deviceId': deviceId.toJson(),
      'deviceCode': deviceCode,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ActivationResult',
      'deviceToken': deviceToken,
      'tenantId': tenantId.toJson(),
      'deviceId': deviceId.toJson(),
      'deviceCode': deviceCode,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _ActivationResultImpl extends ActivationResult {
  _ActivationResultImpl({
    required String deviceToken,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue deviceId,
    required String deviceCode,
  }) : super._(
         deviceToken: deviceToken,
         tenantId: tenantId,
         deviceId: deviceId,
         deviceCode: deviceCode,
       );

  /// Returns a shallow copy of this [ActivationResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ActivationResult copyWith({
    String? deviceToken,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? deviceId,
    String? deviceCode,
  }) {
    return ActivationResult(
      deviceToken: deviceToken ?? this.deviceToken,
      tenantId: tenantId ?? this.tenantId,
      deviceId: deviceId ?? this.deviceId,
      deviceCode: deviceCode ?? this.deviceCode,
    );
  }
}
