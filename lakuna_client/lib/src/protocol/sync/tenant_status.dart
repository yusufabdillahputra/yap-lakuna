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
import 'package:lakuna_client/src/protocol/protocol.dart' as _ikdnsc2z;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import '../sync/device_status.dart' as _izc92xz3;

/// Balasan `sync.tenantStatus`: perangkat kasir tenant token dan jumlah
/// konflik sync yang belum diselesaikan (dashboard 2.3, F2-02 tahap 3).
abstract class TenantStatus
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TenantStatus._({
    required this.devices,
    required this.openConflicts,
    required this.serverTime,
  });

  factory TenantStatus({
    required List<_izc92xz3.DeviceStatus> devices,
    required int openConflicts,
    required DateTime serverTime,
  }) = _TenantStatusImpl;

  factory TenantStatus.fromJson(Map<String, dynamic> jsonSerialization) {
    return TenantStatus(
      devices: _ikdnsc2z.Protocol().deserialize<List<_izc92xz3.DeviceStatus>>(
        jsonSerialization['devices'],
      ),
      openConflicts: jsonSerialization['openConflicts'] as int,
      serverTime: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['serverTime'],
      ),
    );
  }

  List<_izc92xz3.DeviceStatus> devices;

  int openConflicts;

  DateTime serverTime;

  /// Returns a shallow copy of this [TenantStatus]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TenantStatus copyWith({
    List<_izc92xz3.DeviceStatus>? devices,
    int? openConflicts,
    DateTime? serverTime,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TenantStatus',
      'devices': devices.toJson(valueToJson: (v) => v.toJson()),
      'openConflicts': openConflicts,
      'serverTime': serverTime.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TenantStatus',
      'devices': devices.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'openConflicts': openConflicts,
      'serverTime': serverTime.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _TenantStatusImpl extends TenantStatus {
  _TenantStatusImpl({
    required List<_izc92xz3.DeviceStatus> devices,
    required int openConflicts,
    required DateTime serverTime,
  }) : super._(
         devices: devices,
         openConflicts: openConflicts,
         serverTime: serverTime,
       );

  /// Returns a shallow copy of this [TenantStatus]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TenantStatus copyWith({
    List<_izc92xz3.DeviceStatus>? devices,
    int? openConflicts,
    DateTime? serverTime,
  }) {
    return TenantStatus(
      devices: devices ?? this.devices.map((e0) => e0.copyWith()).toList(),
      openConflicts: openConflicts ?? this.openConflicts,
      serverTime: serverTime ?? this.serverTime,
    );
  }
}
