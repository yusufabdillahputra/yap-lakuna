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

/// Cabang yang bisa dipilih perangkat baru saat memakai kode pasang
/// (F2-01, layar gabung).
abstract class PairingOutlet
    implements _is.SerializableModel, _is.ProtocolSerialization {
  PairingOutlet._({
    required this.id,
    required this.code,
    required this.name,
  });

  factory PairingOutlet({
    required _is.UuidValue id,
    required String code,
    required String name,
  }) = _PairingOutletImpl;

  factory PairingOutlet.fromJson(Map<String, dynamic> jsonSerialization) {
    return PairingOutlet(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      code: jsonSerialization['code'] as String,
      name: jsonSerialization['name'] as String,
    );
  }

  _is.UuidValue id;

  String code;

  String name;

  /// Returns a shallow copy of this [PairingOutlet]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PairingOutlet copyWith({
    _is.UuidValue? id,
    String? code,
    String? name,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PairingOutlet',
      'id': id.toJson(),
      'code': code,
      'name': name,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PairingOutlet',
      'id': id.toJson(),
      'code': code,
      'name': name,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _PairingOutletImpl extends PairingOutlet {
  _PairingOutletImpl({
    required _is.UuidValue id,
    required String code,
    required String name,
  }) : super._(
         id: id,
         code: code,
         name: name,
       );

  /// Returns a shallow copy of this [PairingOutlet]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PairingOutlet copyWith({
    _is.UuidValue? id,
    String? code,
    String? name,
  }) {
    return PairingOutlet(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
    );
  }
}
