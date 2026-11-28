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
import '../sync/sync_push_result.dart' as _iui0xpmj;

/// Balasan `sync.push`: hasil per entri, urut sama dengan permintaan.
abstract class SyncPushReply
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SyncPushReply._({
    required this.results,
    required this.serverTime,
  });

  factory SyncPushReply({
    required List<_iui0xpmj.SyncPushResult> results,
    required DateTime serverTime,
  }) = _SyncPushReplyImpl;

  factory SyncPushReply.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncPushReply(
      results: _ikdnsc2z.Protocol().deserialize<List<_iui0xpmj.SyncPushResult>>(
        jsonSerialization['results'],
      ),
      serverTime: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['serverTime'],
      ),
    );
  }

  List<_iui0xpmj.SyncPushResult> results;

  DateTime serverTime;

  /// Returns a shallow copy of this [SyncPushReply]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SyncPushReply copyWith({
    List<_iui0xpmj.SyncPushResult>? results,
    DateTime? serverTime,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncPushReply',
      'results': results.toJson(valueToJson: (v) => v.toJson()),
      'serverTime': serverTime.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SyncPushReply',
      'results': results.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'serverTime': serverTime.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _SyncPushReplyImpl extends SyncPushReply {
  _SyncPushReplyImpl({
    required List<_iui0xpmj.SyncPushResult> results,
    required DateTime serverTime,
  }) : super._(
         results: results,
         serverTime: serverTime,
       );

  /// Returns a shallow copy of this [SyncPushReply]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SyncPushReply copyWith({
    List<_iui0xpmj.SyncPushResult>? results,
    DateTime? serverTime,
  }) {
    return SyncPushReply(
      results: results ?? this.results.map((e0) => e0.copyWith()).toList(),
      serverTime: serverTime ?? this.serverTime,
    );
  }
}
