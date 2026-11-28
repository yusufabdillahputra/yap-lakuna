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
import '../sync/sync_op.dart' as _ik9d1u3s;

/// Satu entri outbox yang didorong perangkat ke `sync.push`.
abstract class SyncPushEntry
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SyncPushEntry._({
    required this.tableName,
    required this.rowId,
    required this.op,
    required this.payloadJson,
    required this.hlc,
  });

  factory SyncPushEntry({
    required String tableName,
    required _is.UuidValue rowId,
    required _ik9d1u3s.SyncOp op,
    required String payloadJson,
    required String hlc,
  }) = _SyncPushEntryImpl;

  factory SyncPushEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncPushEntry(
      tableName: jsonSerialization['tableName'] as String,
      rowId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['rowId']),
      op: _ik9d1u3s.SyncOp.fromJson((jsonSerialization['op'] as String)),
      payloadJson: jsonSerialization['payloadJson'] as String,
      hlc: jsonSerialization['hlc'] as String,
    );
  }

  String tableName;

  _is.UuidValue rowId;

  _ik9d1u3s.SyncOp op;

  /// Baris utuh, kunci nama field Dart (`toJson` model).
  String payloadJson;

  String hlc;

  /// Returns a shallow copy of this [SyncPushEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SyncPushEntry copyWith({
    String? tableName,
    _is.UuidValue? rowId,
    _ik9d1u3s.SyncOp? op,
    String? payloadJson,
    String? hlc,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncPushEntry',
      'tableName': tableName,
      'rowId': rowId.toJson(),
      'op': op.toJson(),
      'payloadJson': payloadJson,
      'hlc': hlc,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SyncPushEntry',
      'tableName': tableName,
      'rowId': rowId.toJson(),
      'op': op.toJson(),
      'payloadJson': payloadJson,
      'hlc': hlc,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _SyncPushEntryImpl extends SyncPushEntry {
  _SyncPushEntryImpl({
    required String tableName,
    required _is.UuidValue rowId,
    required _ik9d1u3s.SyncOp op,
    required String payloadJson,
    required String hlc,
  }) : super._(
         tableName: tableName,
         rowId: rowId,
         op: op,
         payloadJson: payloadJson,
         hlc: hlc,
       );

  /// Returns a shallow copy of this [SyncPushEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SyncPushEntry copyWith({
    String? tableName,
    _is.UuidValue? rowId,
    _ik9d1u3s.SyncOp? op,
    String? payloadJson,
    String? hlc,
  }) {
    return SyncPushEntry(
      tableName: tableName ?? this.tableName,
      rowId: rowId ?? this.rowId,
      op: op ?? this.op,
      payloadJson: payloadJson ?? this.payloadJson,
      hlc: hlc ?? this.hlc,
    );
  }
}
