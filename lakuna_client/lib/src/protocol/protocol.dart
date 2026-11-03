/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_database/serverpod_database.dart' as _isd;
import 'cash/cash_direction.dart' as _i728pu70;
import 'cash/cash_movement.dart' as _iepnwe9z;
import 'cash/cash_session.dart' as _iepiq7d7;
import 'cash/cash_session_status.dart' as _itp0bn28;
import 'organization/business_type.dart' as _i6i3gkff;
import 'organization/device.dart' as _iis0lnof;
import 'organization/device_platform.dart' as _ide5u809;
import 'organization/outlet.dart' as _iqoqqr0f;
import 'organization/outlet_member.dart' as _igpgya6r;
import 'organization/setting.dart' as _if597mfg;
import 'organization/staff_member.dart' as _iy6hfkoy;
import 'organization/stock_location.dart' as _iwbn33ao;
import 'organization/tenant.dart' as _icpow00o;
import 'organization/tenant_plan.dart' as _ii59gw8o;
import 'sync/local_preference.dart' as _ierz52ew;
import 'sync/outbox_status.dart' as _imib010r;
import 'sync/sync_op.dart' as _ipjkwoxz;
import 'sync/sync_outbox_entry.dart' as _ikzi06kl;
import 'sync/sync_state_entry.dart' as _iwwr3hpi;
export 'cash/cash_direction.dart';
export 'cash/cash_movement.dart';
export 'cash/cash_session.dart';
export 'cash/cash_session_status.dart';
export 'organization/business_type.dart';
export 'organization/device.dart';
export 'organization/device_platform.dart';
export 'organization/outlet.dart';
export 'organization/outlet_member.dart';
export 'organization/setting.dart';
export 'organization/staff_member.dart';
export 'organization/stock_location.dart';
export 'organization/tenant.dart';
export 'organization/tenant_plan.dart';
export 'sync/local_preference.dart';
export 'sync/outbox_status.dart';
export 'sync/sync_op.dart';
export 'sync/sync_outbox_entry.dart';
export 'sync/sync_state_entry.dart';
export 'client.dart';

class Protocol extends _isd.DatabaseSerializationManager
    implements _isd.DatabaseProtocolDeserializationProvider {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  @override
  _isc.ProtocolDeserialization get deserializationMetadata =>
      _isc.ProtocolDeserialization.cached(
        this,
        types: const [
          _isc.getType<_i728pu70.CashDirection>,
          _isc.getType<_iepnwe9z.CashMovement>,
          _isc.getType<_iepiq7d7.CashSession>,
          _isc.getType<_itp0bn28.CashSessionStatus>,
          _isc.getType<_i6i3gkff.BusinessType>,
          _isc.getType<_iis0lnof.Device>,
          _isc.getType<_ide5u809.DevicePlatform>,
          _isc.getType<_iqoqqr0f.Outlet>,
          _isc.getType<_igpgya6r.OutletMember>,
          _isc.getType<_if597mfg.Setting>,
          _isc.getType<_iy6hfkoy.StaffMember>,
          _isc.getType<_iwbn33ao.StockLocation>,
          _isc.getType<_icpow00o.Tenant>,
          _isc.getType<_ii59gw8o.TenantPlan>,
          _isc.getType<_ierz52ew.LocalPreference>,
          _isc.getType<_imib010r.OutboxStatus>,
          _isc.getType<_ipjkwoxz.SyncOp>,
          _isc.getType<_ikzi06kl.SyncOutboxEntry>,
          _isc.getType<_iwwr3hpi.SyncStateEntry>,
          _isc.getType<_i728pu70.CashDirection?>,
          _isc.getType<_iepnwe9z.CashMovement?>,
          _isc.getType<_iepiq7d7.CashSession?>,
          _isc.getType<_itp0bn28.CashSessionStatus?>,
          _isc.getType<_i6i3gkff.BusinessType?>,
          _isc.getType<_iis0lnof.Device?>,
          _isc.getType<_ide5u809.DevicePlatform?>,
          _isc.getType<_iqoqqr0f.Outlet?>,
          _isc.getType<_igpgya6r.OutletMember?>,
          _isc.getType<_if597mfg.Setting?>,
          _isc.getType<_iy6hfkoy.StaffMember?>,
          _isc.getType<_iwbn33ao.StockLocation?>,
          _isc.getType<_icpow00o.Tenant?>,
          _isc.getType<_ii59gw8o.TenantPlan?>,
          _isc.getType<_ierz52ew.LocalPreference?>,
          _isc.getType<_imib010r.OutboxStatus?>,
          _isc.getType<_ipjkwoxz.SyncOp?>,
          _isc.getType<_ikzi06kl.SyncOutboxEntry?>,
          _isc.getType<_iwwr3hpi.SyncStateEntry?>,
        ],
        modules: const [
          _iaic.Protocol.new,
          _iacc.Protocol.new,
        ],
        classNames: const [
          'CashDirection',
          'CashMovement',
          'CashSession',
          'CashSessionStatus',
          'BusinessType',
          'Device',
          'DevicePlatform',
          'Outlet',
          'OutletMember',
          'Setting',
          'StaffMember',
          'StockLocation',
          'Tenant',
          'TenantPlan',
          'LocalPreference',
          'OutboxStatus',
          'SyncOp',
          'SyncOutboxEntry',
          'SyncStateEntry',
        ],
      );

  static List<_isd.TableDefinition> get targetTableDefinitions => [
    _isd.TableDefinition(
      name: 'cash_movements',
      dartName: 'CashMovement',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isd.ColumnDefinition(
          name: 'id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isd.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'cash_session_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'direction',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CashDirection',
        ),
        _isd.ColumnDefinition(
          name: 'amount',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isd.ColumnDefinition(
          name: 'note',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'source',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'manual\'',
        ),
        _isd.ColumnDefinition(
          name: 'created_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'updated_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isd.ColumnDefinition(
          name: 'created_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'updated_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'version',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isd.ColumnDefinition(
          name: 'hlc',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isd.ForeignKeyDefinition(
          constraintName: 'cash_movements_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isd.ForeignKeyDefinition(
          constraintName: 'cash_movements_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isd.ForeignKeyDefinition(
          constraintName: 'cash_movements_fk_2',
          columns: ['cash_session_id'],
          referenceTable: 'cash_sessions',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isd.IndexDefinition(
          indexName: 'cash_movements_session_idx',
          tableSpace: null,
          elements: [
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'cash_session_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isd.TableDefinition(
      name: 'cash_sessions',
      dartName: 'CashSession',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isd.ColumnDefinition(
          name: 'id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isd.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'device_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'status',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CashSessionStatus',
        ),
        _isd.ColumnDefinition(
          name: 'opened_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'opened_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isd.ColumnDefinition(
          name: 'opening_cash',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isd.ColumnDefinition(
          name: 'opening_note',
          columnType: _isd.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isd.ColumnDefinition(
          name: 'closed_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'closed_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isd.ColumnDefinition(
          name: 'expected_cash',
          columnType: _isd.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isd.ColumnDefinition(
          name: 'counted_cash',
          columnType: _isd.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isd.ColumnDefinition(
          name: 'difference',
          columnType: _isd.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isd.ColumnDefinition(
          name: 'counted_breakdown',
          columnType: _isd.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isd.ColumnDefinition(
          name: 'closing_note',
          columnType: _isd.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isd.ColumnDefinition(
          name: 'created_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'updated_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isd.ColumnDefinition(
          name: 'created_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'updated_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'version',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isd.ColumnDefinition(
          name: 'hlc',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isd.ForeignKeyDefinition(
          constraintName: 'cash_sessions_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isd.ForeignKeyDefinition(
          constraintName: 'cash_sessions_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isd.ForeignKeyDefinition(
          constraintName: 'cash_sessions_fk_2',
          columns: ['device_id'],
          referenceTable: 'devices',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isd.ForeignKeyDefinition(
          constraintName: 'cash_sessions_fk_3',
          columns: ['opened_by'],
          referenceTable: 'staff_members',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isd.ForeignKeyDefinition(
          constraintName: 'cash_sessions_fk_4',
          columns: ['closed_by'],
          referenceTable: 'staff_members',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isd.IndexDefinition(
          indexName: 'cash_sessions_device_status_idx',
          tableSpace: null,
          elements: [
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'device_id',
            ),
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isd.TableDefinition(
      name: 'devices',
      dartName: 'Device',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isd.ColumnDefinition(
          name: 'id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isd.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'code',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'name',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'platform',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:DevicePlatform',
        ),
        _isd.ColumnDefinition(
          name: 'receipt_counter',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isd.ColumnDefinition(
          name: 'receipt_counter_date',
          columnType: _isd.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isd.ColumnDefinition(
          name: 'created_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'updated_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isd.ColumnDefinition(
          name: 'created_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'updated_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'version',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isd.ColumnDefinition(
          name: 'hlc',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isd.ForeignKeyDefinition(
          constraintName: 'devices_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isd.ForeignKeyDefinition(
          constraintName: 'devices_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isd.IndexDefinition(
          indexName: 'devices_outlet_code_idx',
          tableSpace: null,
          elements: [
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'outlet_id',
            ),
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'code',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isd.TableDefinition(
      name: 'local_preferences',
      dartName: 'LocalPreference',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isd.ColumnDefinition(
          name: 'id',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isd.ColumnDefinition(
          name: 'key',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'value',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isd.IndexDefinition(
          indexName: 'local_preferences_key_idx',
          tableSpace: null,
          elements: [
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'key',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isd.TableDefinition(
      name: 'outlet_members',
      dartName: 'OutletMember',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isd.ColumnDefinition(
          name: 'id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isd.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'staff_member_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'role_name',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'created_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'updated_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isd.ColumnDefinition(
          name: 'created_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'updated_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'version',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isd.ColumnDefinition(
          name: 'hlc',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isd.ForeignKeyDefinition(
          constraintName: 'outlet_members_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isd.ForeignKeyDefinition(
          constraintName: 'outlet_members_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isd.ForeignKeyDefinition(
          constraintName: 'outlet_members_fk_2',
          columns: ['staff_member_id'],
          referenceTable: 'staff_members',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isd.IndexDefinition(
          indexName: 'outlet_members_staff_outlet_idx',
          tableSpace: null,
          elements: [
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'staff_member_id',
            ),
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'outlet_id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isd.TableDefinition(
      name: 'outlets',
      dartName: 'Outlet',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isd.ColumnDefinition(
          name: 'id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isd.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'code',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'name',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'address',
          columnType: _isd.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isd.ColumnDefinition(
          name: 'phone',
          columnType: _isd.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isd.ColumnDefinition(
          name: 'timezone',
          columnType: _isd.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isd.ColumnDefinition(
          name: 'created_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'updated_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isd.ColumnDefinition(
          name: 'created_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'updated_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'version',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isd.ColumnDefinition(
          name: 'hlc',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isd.ForeignKeyDefinition(
          constraintName: 'outlets_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isd.IndexDefinition(
          indexName: 'outlets_tenant_code_idx',
          tableSpace: null,
          elements: [
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'tenant_id',
            ),
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'code',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isd.TableDefinition(
      name: 'settings',
      dartName: 'Setting',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isd.ColumnDefinition(
          name: 'id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isd.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'scope_key',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'key',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'value_json',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'null\'',
        ),
        _isd.ColumnDefinition(
          name: 'created_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'updated_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isd.ColumnDefinition(
          name: 'created_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'updated_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'version',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isd.ColumnDefinition(
          name: 'hlc',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isd.ForeignKeyDefinition(
          constraintName: 'settings_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isd.ForeignKeyDefinition(
          constraintName: 'settings_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isd.IndexDefinition(
          indexName: 'settings_tenant_scope_key_idx',
          tableSpace: null,
          elements: [
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'tenant_id',
            ),
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'scope_key',
            ),
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'key',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isd.TableDefinition(
      name: 'staff_members',
      dartName: 'StaffMember',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isd.ColumnDefinition(
          name: 'id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isd.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'name',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'email',
          columnType: _isd.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isd.ColumnDefinition(
          name: 'pin_hash',
          columnType: _isd.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isd.ColumnDefinition(
          name: 'password_hash',
          columnType: _isd.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isd.ColumnDefinition(
          name: 'is_owner',
          columnType: _isd.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isd.ColumnDefinition(
          name: 'is_active',
          columnType: _isd.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isd.ColumnDefinition(
          name: 'created_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'updated_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isd.ColumnDefinition(
          name: 'created_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'updated_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'version',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isd.ColumnDefinition(
          name: 'hlc',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isd.ForeignKeyDefinition(
          constraintName: 'staff_members_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isd.TableDefinition(
      name: 'stock_locations',
      dartName: 'StockLocation',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isd.ColumnDefinition(
          name: 'id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isd.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'name',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'is_default',
          columnType: _isd.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isd.ColumnDefinition(
          name: 'created_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'updated_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isd.ColumnDefinition(
          name: 'created_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'updated_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'version',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isd.ColumnDefinition(
          name: 'hlc',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isd.ForeignKeyDefinition(
          constraintName: 'stock_locations_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isd.ForeignKeyDefinition(
          constraintName: 'stock_locations_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isd.ForeignKeyAction.noAction,
          onDelete: _isd.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isd.TableDefinition(
      name: 'sync_outbox',
      dartName: 'SyncOutboxEntry',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isd.ColumnDefinition(
          name: 'id',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isd.ColumnDefinition(
          name: 'table_name',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'row_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isd.ColumnDefinition(
          name: 'op',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:SyncOp',
        ),
        _isd.ColumnDefinition(
          name: 'payload_json',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'hlc',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'status',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:OutboxStatus',
          columnDefault: '\'pending\'',
        ),
        _isd.ColumnDefinition(
          name: 'attempts',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isd.ColumnDefinition(
          name: 'last_error',
          columnType: _isd.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isd.ColumnDefinition(
          name: 'created_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isd.IndexDefinition(
          indexName: 'sync_outbox_status_idx',
          tableSpace: null,
          elements: [
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'status',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isd.TableDefinition(
      name: 'sync_state',
      dartName: 'SyncStateEntry',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isd.ColumnDefinition(
          name: 'id',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isd.ColumnDefinition(
          name: 'key',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'value',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isd.IndexDefinition(
          indexName: 'sync_state_key_idx',
          tableSpace: null,
          elements: [
            _isd.IndexElementDefinition(
              type: _isd.IndexElementDefinitionType.column,
              definition: 'key',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isd.TableDefinition(
      name: 'tenants',
      dartName: 'Tenant',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isd.ColumnDefinition(
          name: 'id',
          columnType: _isd.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isd.ColumnDefinition(
          name: 'name',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'business_type',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:BusinessType',
          columnDefault: '\'retail\'',
        ),
        _isd.ColumnDefinition(
          name: 'plan',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:TenantPlan',
          columnDefault: '\'free\'',
        ),
        _isd.ColumnDefinition(
          name: 'timezone',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'Asia/Jakarta\'',
        ),
        _isd.ColumnDefinition(
          name: 'created_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'updated_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isd.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isd.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isd.ColumnDefinition(
          name: 'created_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'updated_by',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isd.ColumnDefinition(
          name: 'version',
          columnType: _isd.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isd.ColumnDefinition(
          name: 'hlc',
          columnType: _isd.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isd.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isd.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    ..._iaic.Protocol() is _isd.DatabaseSerializationManager
        ? (_iaic.Protocol() as _isd.DatabaseSerializationManager)
              .getTargetTableDefinitions()
        : [],
    ..._iacc.Protocol() is _isd.DatabaseSerializationManager
        ? (_iacc.Protocol() as _isd.DatabaseSerializationManager)
              .getTargetTableDefinitions()
        : [],
  ];

  static String? getClassNameFromObjectJson(dynamic data) =>
      _isc.ProtocolDeserialization.readClassName(data);

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    final rawDataClassName = _isc.ProtocolDeserialization.readClassName(data);
    final dataClassName = rawDataClassName;
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i728pu70.CashDirection) {
      return _i728pu70.CashDirection.fromJson(data) as T;
    }
    if (t == _iepnwe9z.CashMovement) {
      return _iepnwe9z.CashMovement.fromJson(data) as T;
    }
    if (t == _iepiq7d7.CashSession) {
      return _iepiq7d7.CashSession.fromJson(data) as T;
    }
    if (t == _itp0bn28.CashSessionStatus) {
      return _itp0bn28.CashSessionStatus.fromJson(data) as T;
    }
    if (t == _i6i3gkff.BusinessType) {
      return _i6i3gkff.BusinessType.fromJson(data) as T;
    }
    if (t == _iis0lnof.Device) {
      return _iis0lnof.Device.fromJson(data) as T;
    }
    if (t == _ide5u809.DevicePlatform) {
      return _ide5u809.DevicePlatform.fromJson(data) as T;
    }
    if (t == _iqoqqr0f.Outlet) {
      return _iqoqqr0f.Outlet.fromJson(data) as T;
    }
    if (t == _igpgya6r.OutletMember) {
      return _igpgya6r.OutletMember.fromJson(data) as T;
    }
    if (t == _if597mfg.Setting) {
      return _if597mfg.Setting.fromJson(data) as T;
    }
    if (t == _iy6hfkoy.StaffMember) {
      return _iy6hfkoy.StaffMember.fromJson(data) as T;
    }
    if (t == _iwbn33ao.StockLocation) {
      return _iwbn33ao.StockLocation.fromJson(data) as T;
    }
    if (t == _icpow00o.Tenant) {
      return _icpow00o.Tenant.fromJson(data) as T;
    }
    if (t == _ii59gw8o.TenantPlan) {
      return _ii59gw8o.TenantPlan.fromJson(data) as T;
    }
    if (t == _ierz52ew.LocalPreference) {
      return _ierz52ew.LocalPreference.fromJson(data) as T;
    }
    if (t == _imib010r.OutboxStatus) {
      return _imib010r.OutboxStatus.fromJson(data) as T;
    }
    if (t == _ipjkwoxz.SyncOp) {
      return _ipjkwoxz.SyncOp.fromJson(data) as T;
    }
    if (t == _ikzi06kl.SyncOutboxEntry) {
      return _ikzi06kl.SyncOutboxEntry.fromJson(data) as T;
    }
    if (t == _iwwr3hpi.SyncStateEntry) {
      return _iwwr3hpi.SyncStateEntry.fromJson(data) as T;
    }
    if (t == _isc.getType<_i728pu70.CashDirection?>()) {
      return (data != null ? _i728pu70.CashDirection.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iepnwe9z.CashMovement?>()) {
      return (data != null ? _iepnwe9z.CashMovement.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iepiq7d7.CashSession?>()) {
      return (data != null ? _iepiq7d7.CashSession.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_itp0bn28.CashSessionStatus?>()) {
      return (data != null ? _itp0bn28.CashSessionStatus.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i6i3gkff.BusinessType?>()) {
      return (data != null ? _i6i3gkff.BusinessType.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iis0lnof.Device?>()) {
      return (data != null ? _iis0lnof.Device.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ide5u809.DevicePlatform?>()) {
      return (data != null ? _ide5u809.DevicePlatform.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iqoqqr0f.Outlet?>()) {
      return (data != null ? _iqoqqr0f.Outlet.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_igpgya6r.OutletMember?>()) {
      return (data != null ? _igpgya6r.OutletMember.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_if597mfg.Setting?>()) {
      return (data != null ? _if597mfg.Setting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iy6hfkoy.StaffMember?>()) {
      return (data != null ? _iy6hfkoy.StaffMember.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iwbn33ao.StockLocation?>()) {
      return (data != null ? _iwbn33ao.StockLocation.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_icpow00o.Tenant?>()) {
      return (data != null ? _icpow00o.Tenant.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ii59gw8o.TenantPlan?>()) {
      return (data != null ? _ii59gw8o.TenantPlan.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ierz52ew.LocalPreference?>()) {
      return (data != null ? _ierz52ew.LocalPreference.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_imib010r.OutboxStatus?>()) {
      return (data != null ? _imib010r.OutboxStatus.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ipjkwoxz.SyncOp?>()) {
      return (data != null ? _ipjkwoxz.SyncOp.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_ikzi06kl.SyncOutboxEntry?>()) {
      return (data != null ? _ikzi06kl.SyncOutboxEntry.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_iwwr3hpi.SyncStateEntry?>()) {
      return (data != null ? _iwwr3hpi.SyncStateEntry.fromJson(data) : null)
          as T;
    }
    final modules = deserializationMetadata.modulesForDeserialization(
      t,
      className: rawDataClassName,
    );
    for (final module in modules) {
      try {
        return module.deserialize<T>(data, t);
      } on _isc.DeserializationTypeNotFoundException catch (_) {}
    }

    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i728pu70.CashDirection => 'CashDirection',
      _iepnwe9z.CashMovement => 'CashMovement',
      _iepiq7d7.CashSession => 'CashSession',
      _itp0bn28.CashSessionStatus => 'CashSessionStatus',
      _i6i3gkff.BusinessType => 'BusinessType',
      _iis0lnof.Device => 'Device',
      _ide5u809.DevicePlatform => 'DevicePlatform',
      _iqoqqr0f.Outlet => 'Outlet',
      _igpgya6r.OutletMember => 'OutletMember',
      _if597mfg.Setting => 'Setting',
      _iy6hfkoy.StaffMember => 'StaffMember',
      _iwbn33ao.StockLocation => 'StockLocation',
      _icpow00o.Tenant => 'Tenant',
      _ii59gw8o.TenantPlan => 'TenantPlan',
      _ierz52ew.LocalPreference => 'LocalPreference',
      _imib010r.OutboxStatus => 'OutboxStatus',
      _ipjkwoxz.SyncOp => 'SyncOp',
      _ikzi06kl.SyncOutboxEntry => 'SyncOutboxEntry',
      _iwwr3hpi.SyncStateEntry => 'SyncStateEntry',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('lakuna.', '');
    }

    switch (data) {
      case _i728pu70.CashDirection():
        return 'CashDirection';
      case _iepnwe9z.CashMovement():
        return 'CashMovement';
      case _iepiq7d7.CashSession():
        return 'CashSession';
      case _itp0bn28.CashSessionStatus():
        return 'CashSessionStatus';
      case _i6i3gkff.BusinessType():
        return 'BusinessType';
      case _iis0lnof.Device():
        return 'Device';
      case _ide5u809.DevicePlatform():
        return 'DevicePlatform';
      case _iqoqqr0f.Outlet():
        return 'Outlet';
      case _igpgya6r.OutletMember():
        return 'OutletMember';
      case _if597mfg.Setting():
        return 'Setting';
      case _iy6hfkoy.StaffMember():
        return 'StaffMember';
      case _iwbn33ao.StockLocation():
        return 'StockLocation';
      case _icpow00o.Tenant():
        return 'Tenant';
      case _ii59gw8o.TenantPlan():
        return 'TenantPlan';
      case _ierz52ew.LocalPreference():
        return 'LocalPreference';
      case _imib010r.OutboxStatus():
        return 'OutboxStatus';
      case _ipjkwoxz.SyncOp():
        return 'SyncOp';
      case _ikzi06kl.SyncOutboxEntry():
        return 'SyncOutboxEntry';
      case _iwwr3hpi.SyncStateEntry():
        return 'SyncStateEntry';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'CashDirection') {
      return deserialize<_i728pu70.CashDirection>(data['data']);
    }
    if (dataClassName == 'CashMovement') {
      return deserialize<_iepnwe9z.CashMovement>(data['data']);
    }
    if (dataClassName == 'CashSession') {
      return deserialize<_iepiq7d7.CashSession>(data['data']);
    }
    if (dataClassName == 'CashSessionStatus') {
      return deserialize<_itp0bn28.CashSessionStatus>(data['data']);
    }
    if (dataClassName == 'BusinessType') {
      return deserialize<_i6i3gkff.BusinessType>(data['data']);
    }
    if (dataClassName == 'Device') {
      return deserialize<_iis0lnof.Device>(data['data']);
    }
    if (dataClassName == 'DevicePlatform') {
      return deserialize<_ide5u809.DevicePlatform>(data['data']);
    }
    if (dataClassName == 'Outlet') {
      return deserialize<_iqoqqr0f.Outlet>(data['data']);
    }
    if (dataClassName == 'OutletMember') {
      return deserialize<_igpgya6r.OutletMember>(data['data']);
    }
    if (dataClassName == 'Setting') {
      return deserialize<_if597mfg.Setting>(data['data']);
    }
    if (dataClassName == 'StaffMember') {
      return deserialize<_iy6hfkoy.StaffMember>(data['data']);
    }
    if (dataClassName == 'StockLocation') {
      return deserialize<_iwbn33ao.StockLocation>(data['data']);
    }
    if (dataClassName == 'Tenant') {
      return deserialize<_icpow00o.Tenant>(data['data']);
    }
    if (dataClassName == 'TenantPlan') {
      return deserialize<_ii59gw8o.TenantPlan>(data['data']);
    }
    if (dataClassName == 'LocalPreference') {
      return deserialize<_ierz52ew.LocalPreference>(data['data']);
    }
    if (dataClassName == 'OutboxStatus') {
      return deserialize<_imib010r.OutboxStatus>(data['data']);
    }
    if (dataClassName == 'SyncOp') {
      return deserialize<_ipjkwoxz.SyncOp>(data['data']);
    }
    if (dataClassName == 'SyncOutboxEntry') {
      return deserialize<_ikzi06kl.SyncOutboxEntry>(data['data']);
    }
    if (dataClassName == 'SyncStateEntry') {
      return deserialize<_iwwr3hpi.SyncStateEntry>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      return _iaic.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(19),
      });
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      return _iacc.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(20),
      });
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('lakuna', this);
    _iacc.Protocol().registerHostProtocol('lakuna', this);
  }

  @override
  _isd.Table? getTableForType(Type t) {
    {
      var protocol = _iaic.Protocol();
      var table = protocol is _isd.DatabaseSerializationManager
          ? (protocol as _isd.DatabaseSerializationManager).getTableForType(t)
          : null;
      if (table != null) {
        return table;
      }
    }
    {
      var protocol = _iacc.Protocol();
      var table = protocol is _isd.DatabaseSerializationManager
          ? (protocol as _isd.DatabaseSerializationManager).getTableForType(t)
          : null;
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _iepnwe9z.CashMovement:
        return _iepnwe9z.CashMovement.t;
      case _iepiq7d7.CashSession:
        return _iepiq7d7.CashSession.t;
      case _iis0lnof.Device:
        return _iis0lnof.Device.t;
      case _iqoqqr0f.Outlet:
        return _iqoqqr0f.Outlet.t;
      case _igpgya6r.OutletMember:
        return _igpgya6r.OutletMember.t;
      case _if597mfg.Setting:
        return _if597mfg.Setting.t;
      case _iy6hfkoy.StaffMember:
        return _iy6hfkoy.StaffMember.t;
      case _iwbn33ao.StockLocation:
        return _iwbn33ao.StockLocation.t;
      case _icpow00o.Tenant:
        return _icpow00o.Tenant.t;
      case _ierz52ew.LocalPreference:
        return _ierz52ew.LocalPreference.t;
      case _ikzi06kl.SyncOutboxEntry:
        return _ikzi06kl.SyncOutboxEntry.t;
      case _iwwr3hpi.SyncStateEntry:
        return _iwwr3hpi.SyncStateEntry.t;
    }
    return null;
  }

  @override
  List<_isd.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'lakuna';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
