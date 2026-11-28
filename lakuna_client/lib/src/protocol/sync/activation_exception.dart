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
import '../sync/activation_failure.dart' as _ie7r1e0d;

/// Aktivasi atau pasang perangkat ditolak.
abstract class ActivationException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  ActivationException._({required this.reason});

  factory ActivationException({required _ie7r1e0d.ActivationFailure reason}) =
      _ActivationExceptionImpl;

  factory ActivationException.fromJson(Map<String, dynamic> jsonSerialization) {
    return ActivationException(
      reason: _ie7r1e0d.ActivationFailure.fromJson(
        (jsonSerialization['reason'] as String),
      ),
    );
  }

  _ie7r1e0d.ActivationFailure reason;

  /// Returns a shallow copy of this [ActivationException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ActivationException copyWith({_ie7r1e0d.ActivationFailure? reason});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ActivationException',
      'reason': reason.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ActivationException',
      'reason': reason.toJson(),
    };
  }

  @override
  String toString() {
    return 'ActivationException(reason: $reason)';
  }
}

class _ActivationExceptionImpl extends ActivationException {
  _ActivationExceptionImpl({required _ie7r1e0d.ActivationFailure reason})
    : super._(reason: reason);

  /// Returns a shallow copy of this [ActivationException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ActivationException copyWith({_ie7r1e0d.ActivationFailure? reason}) {
    return ActivationException(reason: reason ?? this.reason);
  }
}
