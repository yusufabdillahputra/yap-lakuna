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
import '../web_access/web_access_failure.dart' as _idig8gqm;

/// Login web atau pengaturan verifikasi 2 langkah ditolak. `lockedUntil`
/// diisi bila `failure` = `locked`.
abstract class WebAccessException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  WebAccessException._({
    required this.failure,
    this.lockedUntil,
  });

  factory WebAccessException({
    required _idig8gqm.WebAccessFailure failure,
    DateTime? lockedUntil,
  }) = _WebAccessExceptionImpl;

  factory WebAccessException.fromJson(Map<String, dynamic> jsonSerialization) {
    return WebAccessException(
      failure: _idig8gqm.WebAccessFailure.fromJson(
        (jsonSerialization['failure'] as String),
      ),
      lockedUntil: jsonSerialization['lockedUntil'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lockedUntil'],
            ),
    );
  }

  _idig8gqm.WebAccessFailure failure;

  DateTime? lockedUntil;

  /// Returns a shallow copy of this [WebAccessException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WebAccessException copyWith({
    _idig8gqm.WebAccessFailure? failure,
    DateTime? lockedUntil = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WebAccessException',
      'failure': failure.toJson(),
      if (lockedUntil != null) 'lockedUntil': lockedUntil?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WebAccessException',
      'failure': failure.toJson(),
      if (lockedUntil != null) 'lockedUntil': lockedUntil?.toJson(),
    };
  }

  @override
  String toString() {
    return 'WebAccessException(failure: $failure, lockedUntil: $lockedUntil)';
  }
}

class _WebAccessExceptionImpl extends WebAccessException {
  _WebAccessExceptionImpl({
    required _idig8gqm.WebAccessFailure failure,
    DateTime? lockedUntil,
  }) : super._(
         failure: failure,
         lockedUntil: lockedUntil,
       );

  /// Returns a shallow copy of this [WebAccessException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WebAccessException copyWith({
    _idig8gqm.WebAccessFailure? failure,
    DateTime? lockedUntil = const _is.$UndefinedDateTime(),
  }) {
    return WebAccessException(
      failure: failure ?? this.failure,
      lockedUntil: lockedUntil is _is.UndefinedSentinel
          ? this.lockedUntil
          : lockedUntil,
    );
  }
}
