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

/// Hasil login web: perangkat web baru tenant dan tokennya (dikirim sekali).
abstract class WebAccessResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
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
    required _is.UuidValue tenantId,
    required _is.UuidValue deviceId,
    required String deviceCode,
    required _is.UuidValue outletId,
    required DateTime expiresAt,
  }) = _WebAccessResultImpl;

  factory WebAccessResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return WebAccessResult(
      deviceToken: jsonSerialization['deviceToken'] as String,
      tenantId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      deviceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['deviceId'],
      ),
      deviceCode: jsonSerialization['deviceCode'] as String,
      outletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      expiresAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  String deviceToken;

  _is.UuidValue tenantId;

  _is.UuidValue deviceId;

  String deviceCode;

  _is.UuidValue outletId;

  DateTime expiresAt;

  /// Returns a shallow copy of this [WebAccessResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WebAccessResult copyWith({
    String? deviceToken,
    _is.UuidValue? tenantId,
    _is.UuidValue? deviceId,
    String? deviceCode,
    _is.UuidValue? outletId,
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
    return _is.SerializationManager.encode(this);
  }
}

class _WebAccessResultImpl extends WebAccessResult {
  _WebAccessResultImpl({
    required String deviceToken,
    required _is.UuidValue tenantId,
    required _is.UuidValue deviceId,
    required String deviceCode,
    required _is.UuidValue outletId,
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
  @_is.useResult
  @override
  WebAccessResult copyWith({
    String? deviceToken,
    _is.UuidValue? tenantId,
    _is.UuidValue? deviceId,
    String? deviceCode,
    _is.UuidValue? outletId,
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
