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
import 'package:lakuna_server/src/generated/protocol.dart' as _in75rlex;
import 'package:serverpod/serverpod.dart' as _is;
import '../sync/sync_pull_change.dart' as _i9i0xnu6;

/// Satu halaman `sync.pull` (maks 1.000 perubahan).
abstract class SyncPullPage
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SyncPullPage._({
    required this.changes,
    required this.nextSeq,
    required this.hasMore,
    required this.serverTime,
  });

  factory SyncPullPage({
    required List<_i9i0xnu6.SyncPullChange> changes,
    required int nextSeq,
    required bool hasMore,
    required DateTime serverTime,
  }) = _SyncPullPageImpl;

  factory SyncPullPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncPullPage(
      changes: _in75rlex.Protocol().deserialize<List<_i9i0xnu6.SyncPullChange>>(
        jsonSerialization['changes'],
      ),
      nextSeq: jsonSerialization['nextSeq'] as int,
      hasMore: _is.BoolJsonExtension.fromJson(jsonSerialization['hasMore']),
      serverTime: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['serverTime'],
      ),
    );
  }

  List<_i9i0xnu6.SyncPullChange> changes;

  /// `seq` terakhir di halaman ini (atau `afterSeq` bila kosong).
  int nextSeq;

  bool hasMore;

  DateTime serverTime;

  /// Returns a shallow copy of this [SyncPullPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SyncPullPage copyWith({
    List<_i9i0xnu6.SyncPullChange>? changes,
    int? nextSeq,
    bool? hasMore,
    DateTime? serverTime,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncPullPage',
      'changes': changes.toJson(valueToJson: (v) => v.toJson()),
      'nextSeq': nextSeq,
      'hasMore': hasMore,
      'serverTime': serverTime.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SyncPullPage',
      'changes': changes.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'nextSeq': nextSeq,
      'hasMore': hasMore,
      'serverTime': serverTime.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _SyncPullPageImpl extends SyncPullPage {
  _SyncPullPageImpl({
    required List<_i9i0xnu6.SyncPullChange> changes,
    required int nextSeq,
    required bool hasMore,
    required DateTime serverTime,
  }) : super._(
         changes: changes,
         nextSeq: nextSeq,
         hasMore: hasMore,
         serverTime: serverTime,
       );

  /// Returns a shallow copy of this [SyncPullPage]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SyncPullPage copyWith({
    List<_i9i0xnu6.SyncPullChange>? changes,
    int? nextSeq,
    bool? hasMore,
    DateTime? serverTime,
  }) {
    return SyncPullPage(
      changes: changes ?? this.changes.map((e0) => e0.copyWith()).toList(),
      nextSeq: nextSeq ?? this.nextSeq,
      hasMore: hasMore ?? this.hasMore,
      serverTime: serverTime ?? this.serverTime,
    );
  }
}
