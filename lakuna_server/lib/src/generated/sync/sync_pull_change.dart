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

/// Satu perubahan dari log server untuk `sync.pull`.
abstract class SyncPullChange
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SyncPullChange._({
    required this.seq,
    required this.tableName,
    required this.rowId,
    required this.payloadJson,
    required this.hlc,
  });

  factory SyncPullChange({
    required int seq,
    required String tableName,
    required _is.UuidValue rowId,
    required String payloadJson,
    required String hlc,
  }) = _SyncPullChangeImpl;

  factory SyncPullChange.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncPullChange(
      seq: jsonSerialization['seq'] as int,
      tableName: jsonSerialization['tableName'] as String,
      rowId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['rowId']),
      payloadJson: jsonSerialization['payloadJson'] as String,
      hlc: jsonSerialization['hlc'] as String,
    );
  }

  int seq;

  String tableName;

  _is.UuidValue rowId;

  String payloadJson;

  String hlc;

  /// Returns a shallow copy of this [SyncPullChange]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SyncPullChange copyWith({
    int? seq,
    String? tableName,
    _is.UuidValue? rowId,
    String? payloadJson,
    String? hlc,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncPullChange',
      'seq': seq,
      'tableName': tableName,
      'rowId': rowId.toJson(),
      'payloadJson': payloadJson,
      'hlc': hlc,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SyncPullChange',
      'seq': seq,
      'tableName': tableName,
      'rowId': rowId.toJson(),
      'payloadJson': payloadJson,
      'hlc': hlc,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _SyncPullChangeImpl extends SyncPullChange {
  _SyncPullChangeImpl({
    required int seq,
    required String tableName,
    required _is.UuidValue rowId,
    required String payloadJson,
    required String hlc,
  }) : super._(
         seq: seq,
         tableName: tableName,
         rowId: rowId,
         payloadJson: payloadJson,
         hlc: hlc,
       );

  /// Returns a shallow copy of this [SyncPullChange]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SyncPullChange copyWith({
    int? seq,
    String? tableName,
    _is.UuidValue? rowId,
    String? payloadJson,
    String? hlc,
  }) {
    return SyncPullChange(
      seq: seq ?? this.seq,
      tableName: tableName ?? this.tableName,
      rowId: rowId ?? this.rowId,
      payloadJson: payloadJson ?? this.payloadJson,
      hlc: hlc ?? this.hlc,
    );
  }
}
