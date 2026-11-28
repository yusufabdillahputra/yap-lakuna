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
import '../organization/device_platform.dart' as _i4nkore5;

/// Satu perangkat kasir tenant untuk kartu *Perangkat* di dashboard
/// (F2-02 tahap 3). `lastSeenAt` = sync terakhir yang dilihat server.
abstract class DeviceStatus
    implements _is.SerializableModel, _is.ProtocolSerialization {
  DeviceStatus._({
    required this.deviceId,
    required this.outletId,
    required this.code,
    required this.name,
    required this.platform,
    this.lastSeenAt,
  });

  factory DeviceStatus({
    required _is.UuidValue deviceId,
    required _is.UuidValue outletId,
    required String code,
    required String name,
    required _i4nkore5.DevicePlatform platform,
    DateTime? lastSeenAt,
  }) = _DeviceStatusImpl;

  factory DeviceStatus.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeviceStatus(
      deviceId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['deviceId'],
      ),
      outletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['outletId'],
      ),
      code: jsonSerialization['code'] as String,
      name: jsonSerialization['name'] as String,
      platform: _i4nkore5.DevicePlatform.fromJson(
        (jsonSerialization['platform'] as String),
      ),
      lastSeenAt: jsonSerialization['lastSeenAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['lastSeenAt']),
    );
  }

  _is.UuidValue deviceId;

  _is.UuidValue outletId;

  String code;

  String name;

  _i4nkore5.DevicePlatform platform;

  DateTime? lastSeenAt;

  /// Returns a shallow copy of this [DeviceStatus]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DeviceStatus copyWith({
    _is.UuidValue? deviceId,
    _is.UuidValue? outletId,
    String? code,
    String? name,
    _i4nkore5.DevicePlatform? platform,
    DateTime? lastSeenAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DeviceStatus',
      'deviceId': deviceId.toJson(),
      'outletId': outletId.toJson(),
      'code': code,
      'name': name,
      'platform': platform.toJson(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DeviceStatus',
      'deviceId': deviceId.toJson(),
      'outletId': outletId.toJson(),
      'code': code,
      'name': name,
      'platform': platform.toJson(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _DeviceStatusImpl extends DeviceStatus {
  _DeviceStatusImpl({
    required _is.UuidValue deviceId,
    required _is.UuidValue outletId,
    required String code,
    required String name,
    required _i4nkore5.DevicePlatform platform,
    DateTime? lastSeenAt,
  }) : super._(
         deviceId: deviceId,
         outletId: outletId,
         code: code,
         name: name,
         platform: platform,
         lastSeenAt: lastSeenAt,
       );

  /// Returns a shallow copy of this [DeviceStatus]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DeviceStatus copyWith({
    _is.UuidValue? deviceId,
    _is.UuidValue? outletId,
    String? code,
    String? name,
    _i4nkore5.DevicePlatform? platform,
    DateTime? lastSeenAt = const _is.$UndefinedDateTime(),
  }) {
    return DeviceStatus(
      deviceId: deviceId ?? this.deviceId,
      outletId: outletId ?? this.outletId,
      code: code ?? this.code,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      lastSeenAt: lastSeenAt is _is.UndefinedSentinel
          ? this.lastSeenAt
          : lastSeenAt,
    );
  }
}
