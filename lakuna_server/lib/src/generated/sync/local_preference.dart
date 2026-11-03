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

/// Preferensi lokal perangkat yang tidak disinkronkan (mis. tema, bahasa
/// sebelum ada login staf).
abstract class LocalPreference
    implements _is.SerializableModel, _is.ProtocolSerialization {
  LocalPreference._({
    this.id,
    required this.key,
    required this.value,
  });

  factory LocalPreference({
    int? id,
    required String key,
    required String value,
  }) = _LocalPreferenceImpl;

  factory LocalPreference.fromJson(Map<String, dynamic> jsonSerialization) {
    return LocalPreference(
      id: jsonSerialization['id'] as int?,
      key: jsonSerialization['key'] as String,
      value: jsonSerialization['value'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String key;

  String value;

  /// Returns a shallow copy of this [LocalPreference]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LocalPreference copyWith({
    int? id,
    String? key,
    String? value,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LocalPreference',
      if (id != null) 'id': id,
      'key': key,
      'value': value,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LocalPreference',
      if (id != null) 'id': id,
      'key': key,
      'value': value,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LocalPreferenceImpl extends LocalPreference {
  _LocalPreferenceImpl({
    int? id,
    required String key,
    required String value,
  }) : super._(
         id: id,
         key: key,
         value: value,
       );

  /// Returns a shallow copy of this [LocalPreference]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LocalPreference copyWith({
    Object? id = _Undefined,
    String? key,
    String? value,
  }) {
    return LocalPreference(
      id: id is int? ? id : this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }
}
