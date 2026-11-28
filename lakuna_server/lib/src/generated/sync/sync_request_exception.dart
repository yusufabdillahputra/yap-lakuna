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

/// Permintaan sync tidak sah, mis. batch push lebih dari 500 entri
/// (`batchTooLarge`).
abstract class SyncRequestException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  SyncRequestException._({required this.reason});

  factory SyncRequestException({required String reason}) =
      _SyncRequestExceptionImpl;

  factory SyncRequestException.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SyncRequestException(reason: jsonSerialization['reason'] as String);
  }

  String reason;

  /// Returns a shallow copy of this [SyncRequestException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SyncRequestException copyWith({String? reason});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SyncRequestException',
      'reason': reason,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SyncRequestException',
      'reason': reason,
    };
  }

  @override
  String toString() {
    return 'SyncRequestException(reason: $reason)';
  }
}

class _SyncRequestExceptionImpl extends SyncRequestException {
  _SyncRequestExceptionImpl({required String reason}) : super._(reason: reason);

  /// Returns a shallow copy of this [SyncRequestException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SyncRequestException copyWith({String? reason}) {
    return SyncRequestException(reason: reason ?? this.reason);
  }
}
