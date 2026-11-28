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

/// Balasan `sync.status`: versi server, versi protokol sync, dan apakah
/// tenant token sudah dikenal.
abstract class SyncServerStatus
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SyncServerStatus._({
    required this.serverVersion,
    required this.protocolVersion,
    this.minAppVersion,
    required this.serverTime,
    required this.tenantKnown,
  });

  factory SyncServerStatus({
    required String serverVersion,
    required int protocolVersion,
    String? minAppVersion,
    required DateTime serverTime,
    required bool tenantKnown,
  }) = _SyncServerStatusImpl;

  factory SyncServerStatus.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncServerStatus(
      serverVersion: jsonSerialization['serverVersion'] as String,
      protocolVersion: jsonSerialization['protocolVersion'] as int,
      minAppVersion: jsonSerialization['minAppVersion'] as String?,
      serverTime: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['serverTime'],
      ),
      tenantKnown: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['tenantKnown'],
      ),
    );
  }

  String serverVersion;

  int protocolVersion;

  String? minAppVersion;

  DateTime serverTime;

  bool tenantKnown;

  /// Returns a shallow copy of this [SyncServerStatus]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SyncServerStatus copyWith({
    String? serverVersion,
    int? protocolVersion,
    String? minAppVersion,
    DateTime? serverTime,
    bool? tenantKnown,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncServerStatus',
      'serverVersion': serverVersion,
      'protocolVersion': protocolVersion,
      if (minAppVersion != null) 'minAppVersion': minAppVersion,
      'serverTime': serverTime.toJson(),
      'tenantKnown': tenantKnown,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SyncServerStatus',
      'serverVersion': serverVersion,
      'protocolVersion': protocolVersion,
      if (minAppVersion != null) 'minAppVersion': minAppVersion,
      'serverTime': serverTime.toJson(),
      'tenantKnown': tenantKnown,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SyncServerStatusImpl extends SyncServerStatus {
  _SyncServerStatusImpl({
    required String serverVersion,
    required int protocolVersion,
    String? minAppVersion,
    required DateTime serverTime,
    required bool tenantKnown,
  }) : super._(
         serverVersion: serverVersion,
         protocolVersion: protocolVersion,
         minAppVersion: minAppVersion,
         serverTime: serverTime,
         tenantKnown: tenantKnown,
       );

  /// Returns a shallow copy of this [SyncServerStatus]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SyncServerStatus copyWith({
    String? serverVersion,
    int? protocolVersion,
    Object? minAppVersion = _Undefined,
    DateTime? serverTime,
    bool? tenantKnown,
  }) {
    return SyncServerStatus(
      serverVersion: serverVersion ?? this.serverVersion,
      protocolVersion: protocolVersion ?? this.protocolVersion,
      minAppVersion: minAppVersion is String?
          ? minAppVersion
          : this.minAppVersion,
      serverTime: serverTime ?? this.serverTime,
      tenantKnown: tenantKnown ?? this.tenantKnown,
    );
  }
}
