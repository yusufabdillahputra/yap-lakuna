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

/// Token perangkat tidak valid atau sudah dicabut.
abstract class SyncAuthException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  SyncAuthException._({required this.reason});

  factory SyncAuthException({required String reason}) = _SyncAuthExceptionImpl;

  factory SyncAuthException.fromJson(Map<String, dynamic> jsonSerialization) {
    return SyncAuthException(reason: jsonSerialization['reason'] as String);
  }

  String reason;

  /// Returns a shallow copy of this [SyncAuthException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SyncAuthException copyWith({String? reason});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncAuthException',
      'reason': reason,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SyncAuthException',
      'reason': reason,
    };
  }

  @override
  String toString() {
    return 'SyncAuthException(reason: $reason)';
  }
}

class _SyncAuthExceptionImpl extends SyncAuthException {
  _SyncAuthExceptionImpl({required String reason}) : super._(reason: reason);

  /// Returns a shallow copy of this [SyncAuthException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SyncAuthException copyWith({String? reason}) {
    return SyncAuthException(reason: reason ?? this.reason);
  }
}
