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
import '../sync/outbox_status.dart' as _i2hbu5uw;
import '../sync/sync_op.dart' as _ik9d1u3s;

/// Satu perubahan baris yang menunggu dikirim ke server. Ditulis dalam
/// transaksi yang sama dengan perubahan datanya. Hanya ada di perangkat.
abstract class SyncOutboxEntry
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SyncOutboxEntry._({
    this.id,
    required this.entity,
    required this.rowId,
    required this.op,
    required this.payloadJson,
    required this.hlc,
    _i2hbu5uw.OutboxStatus? status,
    int? attempts,
    this.lastError,
    DateTime? createdAt,
  }) : status = status ?? _i2hbu5uw.OutboxStatus.pending,
       attempts = attempts ?? 0,
       createdAt = createdAt ?? DateTime.now();

  factory SyncOutboxEntry({
    int? id,
    required String entity,
    required _is.UuidValue rowId,
    required _ik9d1u3s.SyncOp op,
    required String payloadJson,
    required String hlc,
    _i2hbu5uw.OutboxStatus? status,
    int? attempts,
    String? lastError,
    DateTime? createdAt,
  }) = _SyncOutboxEntryImpl;

  factory SyncOutboxEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncOutboxEntry(
      id: jsonSerialization['id'] as int?,
      entity: jsonSerialization['entity'] as String,
      rowId: _is.UuidValueJsonExtension.fromJson(jsonSerialization['rowId']),
      op: _ik9d1u3s.SyncOp.fromJson((jsonSerialization['op'] as String)),
      payloadJson: jsonSerialization['payloadJson'] as String,
      hlc: jsonSerialization['hlc'] as String,
      status: jsonSerialization['status'] == null
          ? null
          : _i2hbu5uw.OutboxStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      attempts: jsonSerialization['attempts'] as int?,
      lastError: jsonSerialization['lastError'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Nama tabel yang berubah.
  String entity;

  _is.UuidValue rowId;

  _ik9d1u3s.SyncOp op;

  String payloadJson;

  String hlc;

  _i2hbu5uw.OutboxStatus status;

  int attempts;

  String? lastError;

  DateTime createdAt;

  /// Returns a shallow copy of this [SyncOutboxEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SyncOutboxEntry copyWith({
    int? id,
    String? entity,
    _is.UuidValue? rowId,
    _ik9d1u3s.SyncOp? op,
    String? payloadJson,
    String? hlc,
    _i2hbu5uw.OutboxStatus? status,
    int? attempts,
    String? lastError,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncOutboxEntry',
      if (id != null) 'id': id,
      'entity': entity,
      'rowId': rowId.toJson(),
      'op': op.toJson(),
      'payloadJson': payloadJson,
      'hlc': hlc,
      'status': status.toJson(),
      'attempts': attempts,
      if (lastError != null) 'lastError': lastError,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SyncOutboxEntry',
      if (id != null) 'id': id,
      'entity': entity,
      'rowId': rowId.toJson(),
      'op': op.toJson(),
      'payloadJson': payloadJson,
      'hlc': hlc,
      'status': status.toJson(),
      'attempts': attempts,
      if (lastError != null) 'lastError': lastError,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SyncOutboxEntryImpl extends SyncOutboxEntry {
  _SyncOutboxEntryImpl({
    int? id,
    required String entity,
    required _is.UuidValue rowId,
    required _ik9d1u3s.SyncOp op,
    required String payloadJson,
    required String hlc,
    _i2hbu5uw.OutboxStatus? status,
    int? attempts,
    String? lastError,
    DateTime? createdAt,
  }) : super._(
         id: id,
         entity: entity,
         rowId: rowId,
         op: op,
         payloadJson: payloadJson,
         hlc: hlc,
         status: status,
         attempts: attempts,
         lastError: lastError,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SyncOutboxEntry]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SyncOutboxEntry copyWith({
    Object? id = _Undefined,
    String? entity,
    _is.UuidValue? rowId,
    _ik9d1u3s.SyncOp? op,
    String? payloadJson,
    String? hlc,
    _i2hbu5uw.OutboxStatus? status,
    int? attempts,
    Object? lastError = _Undefined,
    DateTime? createdAt,
  }) {
    return SyncOutboxEntry(
      id: id is int? ? id : this.id,
      entity: entity ?? this.entity,
      rowId: rowId ?? this.rowId,
      op: op ?? this.op,
      payloadJson: payloadJson ?? this.payloadJson,
      hlc: hlc ?? this.hlc,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastError: lastError is String? ? lastError : this.lastError,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
