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

/// Hasil login web: perangkat web baru tenant dan tokennya (dikirim sekali).
abstract class WebAccessResult
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WebAccessResult._({
    required this.deviceToken,
    required this.tenantId,
    required this.deviceId,
    required this.deviceCode,
    required this.outletId,
    required this.expiresAt,
  });

  factory WebAccessResult({
    required String deviceToken,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue deviceId,
    required String deviceCode,
    required _isc.UuidValue outletId,
    required DateTime expiresAt,
  }) = _WebAccessResultImpl;

  factory WebAccessResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return WebAccessResult(
      deviceToken: jsonSerialization['deviceToken'] as String,
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      deviceId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['deviceId'],
      ),
      deviceCode: jsonSerialization['deviceCode'] as String,
      outletId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      expiresAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  String deviceToken;

  _isc.UuidValue tenantId;

  _isc.UuidValue deviceId;

  String deviceCode;

  _isc.UuidValue outletId;

  DateTime expiresAt;

  /// Returns a shallow copy of this [WebAccessResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WebAccessResult copyWith({
    String? deviceToken,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? deviceId,
    String? deviceCode,
    _isc.UuidValue? outletId,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WebAccessResult',
      'deviceToken': deviceToken,
      'tenantId': tenantId.toJson(),
      'deviceId': deviceId.toJson(),
      'deviceCode': deviceCode,
      'outletId': outletId.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WebAccessResult',
      'deviceToken': deviceToken,
      'tenantId': tenantId.toJson(),
      'deviceId': deviceId.toJson(),
      'deviceCode': deviceCode,
      'outletId': outletId.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _WebAccessResultImpl extends WebAccessResult {
  _WebAccessResultImpl({
    required String deviceToken,
    required _isc.UuidValue tenantId,
    required _isc.UuidValue deviceId,
    required String deviceCode,
    required _isc.UuidValue outletId,
    required DateTime expiresAt,
  }) : super._(
         deviceToken: deviceToken,
         tenantId: tenantId,
         deviceId: deviceId,
         deviceCode: deviceCode,
         outletId: outletId,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [WebAccessResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WebAccessResult copyWith({
    String? deviceToken,
    _isc.UuidValue? tenantId,
    _isc.UuidValue? deviceId,
    String? deviceCode,
    _isc.UuidValue? outletId,
    DateTime? expiresAt,
  }) {
    return WebAccessResult(
      deviceToken: deviceToken ?? this.deviceToken,
      tenantId: tenantId ?? this.tenantId,
      deviceId: deviceId ?? this.deviceId,
      deviceCode: deviceCode ?? this.deviceCode,
      outletId: outletId ?? this.outletId,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
