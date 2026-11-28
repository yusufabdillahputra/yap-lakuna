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
import '../sync/sync_reject_reason.dart' as _itzdnn6c;
import '../sync/sync_result_kind.dart' as _i3valc6h;

/// Hasil satu entri push. `serverPayloadJson` berisi baris server untuk
/// `stale` dan `merged`.
abstract class SyncPushResult
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SyncPushResult._({
    required this.rowId,
    required this.hlc,
    required this.kind,
    this.reason,
    this.serverPayloadJson,
  });

  factory SyncPushResult({
    required _isc.UuidValue rowId,
    required String hlc,
    required _i3valc6h.SyncResultKind kind,
    _itzdnn6c.SyncRejectReason? reason,
    String? serverPayloadJson,
  }) = _SyncPushResultImpl;

  factory SyncPushResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncPushResult(
      rowId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['rowId']),
      hlc: jsonSerialization['hlc'] as String,
      kind: _i3valc6h.SyncResultKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      reason: jsonSerialization['reason'] == null
          ? null
          : _itzdnn6c.SyncRejectReason.fromJson(
              (jsonSerialization['reason'] as String),
            ),
      serverPayloadJson: jsonSerialization['serverPayloadJson'] as String?,
    );
  }

  _isc.UuidValue rowId;

  String hlc;

  _i3valc6h.SyncResultKind kind;

  _itzdnn6c.SyncRejectReason? reason;

  String? serverPayloadJson;

  /// Returns a shallow copy of this [SyncPushResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SyncPushResult copyWith({
    _isc.UuidValue? rowId,
    String? hlc,
    _i3valc6h.SyncResultKind? kind,
    _itzdnn6c.SyncRejectReason? reason,
    String? serverPayloadJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncPushResult',
      'rowId': rowId.toJson(),
      'hlc': hlc,
      'kind': kind.toJson(),
      if (reason != null) 'reason': reason?.toJson(),
      if (serverPayloadJson != null) 'serverPayloadJson': serverPayloadJson,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SyncPushResult',
      'rowId': rowId.toJson(),
      'hlc': hlc,
      'kind': kind.toJson(),
      if (reason != null) 'reason': reason?.toJson(),
      if (serverPayloadJson != null) 'serverPayloadJson': serverPayloadJson,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SyncPushResultImpl extends SyncPushResult {
  _SyncPushResultImpl({
    required _isc.UuidValue rowId,
    required String hlc,
    required _i3valc6h.SyncResultKind kind,
    _itzdnn6c.SyncRejectReason? reason,
    String? serverPayloadJson,
  }) : super._(
         rowId: rowId,
         hlc: hlc,
         kind: kind,
         reason: reason,
         serverPayloadJson: serverPayloadJson,
       );

  /// Returns a shallow copy of this [SyncPushResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SyncPushResult copyWith({
    _isc.UuidValue? rowId,
    String? hlc,
    _i3valc6h.SyncResultKind? kind,
    Object? reason = _Undefined,
    Object? serverPayloadJson = _Undefined,
  }) {
    return SyncPushResult(
      rowId: rowId ?? this.rowId,
      hlc: hlc ?? this.hlc,
      kind: kind ?? this.kind,
      reason: reason is _itzdnn6c.SyncRejectReason? ? reason : this.reason,
      serverPayloadJson: serverPayloadJson is String?
          ? serverPayloadJson
          : this.serverPayloadJson,
    );
  }
}
