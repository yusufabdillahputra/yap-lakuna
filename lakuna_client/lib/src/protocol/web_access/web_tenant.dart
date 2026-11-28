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

/// Toko milik akun yang bisa dibuka di web (pilihan toko, aturan 13a).
abstract class WebTenant
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WebTenant._({
    required this.tenantId,
    required this.name,
  });

  factory WebTenant({
    required _isc.UuidValue tenantId,
    required String name,
  }) = _WebTenantImpl;

  factory WebTenant.fromJson(Map<String, dynamic> jsonSerialization) {
    return WebTenant(
      tenantId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['tenantId'],
      ),
      name: jsonSerialization['name'] as String,
    );
  }

  _isc.UuidValue tenantId;

  String name;

  /// Returns a shallow copy of this [WebTenant]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WebTenant copyWith({
    _isc.UuidValue? tenantId,
    String? name,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WebTenant',
      'tenantId': tenantId.toJson(),
      'name': name,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WebTenant',
      'tenantId': tenantId.toJson(),
      'name': name,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _WebTenantImpl extends WebTenant {
  _WebTenantImpl({
    required _isc.UuidValue tenantId,
    required String name,
  }) : super._(
         tenantId: tenantId,
         name: name,
       );

  /// Returns a shallow copy of this [WebTenant]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WebTenant copyWith({
    _isc.UuidValue? tenantId,
    String? name,
  }) {
    return WebTenant(
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
    );
  }
}
