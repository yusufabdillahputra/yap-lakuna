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
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'cash/cash_direction.dart' as _i728pu70;
import 'cash/cash_movement.dart' as _iepnwe9z;
import 'cash/cash_session.dart' as _iepiq7d7;
import 'cash/cash_session_status.dart' as _itp0bn28;
import 'catalog/category.dart' as _i3vicioi;
import 'catalog/price_tier.dart' as _iwn9aw8c;
import 'catalog/product.dart' as _ixeznjic;
import 'catalog/product_type.dart' as _irudmnqe;
import 'catalog/product_unit.dart' as _i6wsuj4v;
import 'catalog/product_variant.dart' as _iz4qpnk9;
import 'catalog/stock_level.dart' as _i9vlojuz;
import 'catalog/stock_movement.dart' as _i3qehoul;
import 'catalog/stock_source_type.dart' as _ieciauh3;
import 'catalog/unit.dart' as _iqtijg36;
import 'media/media_file.dart' as _iw898kbq;
import 'media/media_kind.dart' as _i8mjpd0r;
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
import 'sales/payment.dart' as _inbmsx46;
import 'sales/payment_method.dart' as _i3u620qk;
import 'sales/payment_status.dart' as _i132i774;
import 'sales/sale.dart' as _ichu53ep;
import 'sales/sale_item.dart' as _i2mbgaee;
import 'sales/sale_status.dart' as _i3d8n48k;
import 'stock/stock_adjustment.dart' as _i7xu84a6;
import 'stock/stock_adjustment_item.dart' as _iuqt5pmc;
import 'stock/stock_adjustment_reason.dart' as _i5me420k;
import 'sync/local_preference.dart' as _ierz52ew;
import 'sync/outbox_status.dart' as _imib010r;
import 'sync/sync_op.dart' as _ipjkwoxz;
import 'sync/sync_outbox_entry.dart' as _ikzi06kl;
import 'sync/sync_state_entry.dart' as _iwwr3hpi;
export 'cash/cash_direction.dart';
export 'cash/cash_movement.dart';
export 'cash/cash_session.dart';
export 'cash/cash_session_status.dart';
export 'catalog/category.dart';
export 'catalog/price_tier.dart';
export 'catalog/product.dart';
export 'catalog/product_type.dart';
export 'catalog/product_unit.dart';
export 'catalog/product_variant.dart';
export 'catalog/stock_level.dart';
export 'catalog/stock_movement.dart';
export 'catalog/stock_source_type.dart';
export 'catalog/unit.dart';
export 'media/media_file.dart';
export 'media/media_kind.dart';
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
export 'sales/payment.dart';
export 'sales/payment_method.dart';
export 'sales/payment_status.dart';
export 'sales/sale.dart';
export 'sales/sale_item.dart';
export 'sales/sale_status.dart';
export 'stock/stock_adjustment.dart';
export 'stock/stock_adjustment_item.dart';
export 'stock/stock_adjustment_reason.dart';
export 'sync/local_preference.dart';
export 'sync/outbox_status.dart';
export 'sync/sync_op.dart';
export 'sync/sync_outbox_entry.dart';
export 'sync/sync_state_entry.dart';

class Protocol extends _is.DatabaseSerializationManager
    implements _is.DatabaseProtocolDeserializationProvider {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  @override
  _is.ProtocolDeserialization get deserializationMetadata =>
      _is.ProtocolDeserialization.cached(
        this,
        types: const [
          _is.getType<_i728pu70.CashDirection>,
          _is.getType<_iepnwe9z.CashMovement>,
          _is.getType<_iepiq7d7.CashSession>,
          _is.getType<_itp0bn28.CashSessionStatus>,
          _is.getType<_i3vicioi.ProductCategory>,
          _is.getType<_iwn9aw8c.ProductPriceTier>,
          _is.getType<_ixeznjic.Product>,
          _is.getType<_irudmnqe.ProductType>,
          _is.getType<_i6wsuj4v.ProductUnit>,
          _is.getType<_iz4qpnk9.ProductVariant>,
          _is.getType<_i9vlojuz.StockLevel>,
          _is.getType<_i3qehoul.StockMovement>,
          _is.getType<_ieciauh3.StockSourceType>,
          _is.getType<_iqtijg36.MeasureUnit>,
          _is.getType<_iw898kbq.MediaFile>,
          _is.getType<_i8mjpd0r.MediaKind>,
          _is.getType<_i6i3gkff.BusinessType>,
          _is.getType<_iis0lnof.Device>,
          _is.getType<_ide5u809.DevicePlatform>,
          _is.getType<_iqoqqr0f.Outlet>,
          _is.getType<_igpgya6r.OutletMember>,
          _is.getType<_if597mfg.Setting>,
          _is.getType<_iy6hfkoy.StaffMember>,
          _is.getType<_iwbn33ao.StockLocation>,
          _is.getType<_icpow00o.Tenant>,
          _is.getType<_ii59gw8o.TenantPlan>,
          _is.getType<_inbmsx46.Payment>,
          _is.getType<_i3u620qk.PaymentMethod>,
          _is.getType<_i132i774.PaymentStatus>,
          _is.getType<_ichu53ep.Sale>,
          _is.getType<_i2mbgaee.SaleItem>,
          _is.getType<_i3d8n48k.SaleStatus>,
          _is.getType<_i7xu84a6.StockAdjustment>,
          _is.getType<_iuqt5pmc.StockAdjustmentItem>,
          _is.getType<_i5me420k.StockAdjustmentReason>,
          _is.getType<_ierz52ew.LocalPreference>,
          _is.getType<_imib010r.OutboxStatus>,
          _is.getType<_ipjkwoxz.SyncOp>,
          _is.getType<_ikzi06kl.SyncOutboxEntry>,
          _is.getType<_iwwr3hpi.SyncStateEntry>,
          _is.getType<_i728pu70.CashDirection?>,
          _is.getType<_iepnwe9z.CashMovement?>,
          _is.getType<_iepiq7d7.CashSession?>,
          _is.getType<_itp0bn28.CashSessionStatus?>,
          _is.getType<_i3vicioi.ProductCategory?>,
          _is.getType<_iwn9aw8c.ProductPriceTier?>,
          _is.getType<_ixeznjic.Product?>,
          _is.getType<_irudmnqe.ProductType?>,
          _is.getType<_i6wsuj4v.ProductUnit?>,
          _is.getType<_iz4qpnk9.ProductVariant?>,
          _is.getType<_i9vlojuz.StockLevel?>,
          _is.getType<_i3qehoul.StockMovement?>,
          _is.getType<_ieciauh3.StockSourceType?>,
          _is.getType<_iqtijg36.MeasureUnit?>,
          _is.getType<_iw898kbq.MediaFile?>,
          _is.getType<_i8mjpd0r.MediaKind?>,
          _is.getType<_i6i3gkff.BusinessType?>,
          _is.getType<_iis0lnof.Device?>,
          _is.getType<_ide5u809.DevicePlatform?>,
          _is.getType<_iqoqqr0f.Outlet?>,
          _is.getType<_igpgya6r.OutletMember?>,
          _is.getType<_if597mfg.Setting?>,
          _is.getType<_iy6hfkoy.StaffMember?>,
          _is.getType<_iwbn33ao.StockLocation?>,
          _is.getType<_icpow00o.Tenant?>,
          _is.getType<_ii59gw8o.TenantPlan?>,
          _is.getType<_inbmsx46.Payment?>,
          _is.getType<_i3u620qk.PaymentMethod?>,
          _is.getType<_i132i774.PaymentStatus?>,
          _is.getType<_ichu53ep.Sale?>,
          _is.getType<_i2mbgaee.SaleItem?>,
          _is.getType<_i3d8n48k.SaleStatus?>,
          _is.getType<_i7xu84a6.StockAdjustment?>,
          _is.getType<_iuqt5pmc.StockAdjustmentItem?>,
          _is.getType<_i5me420k.StockAdjustmentReason?>,
          _is.getType<_ierz52ew.LocalPreference?>,
          _is.getType<_imib010r.OutboxStatus?>,
          _is.getType<_ipjkwoxz.SyncOp?>,
          _is.getType<_ikzi06kl.SyncOutboxEntry?>,
          _is.getType<_iwwr3hpi.SyncStateEntry?>,
        ],
        modules: const [
          _iais.Protocol.new,
          _iacs.Protocol.new,
          _isp.Protocol.new,
        ],
        classNames: const [
          'CashDirection',
          'CashMovement',
          'CashSession',
          'CashSessionStatus',
          'ProductCategory',
          'ProductPriceTier',
          'Product',
          'ProductType',
          'ProductUnit',
          'ProductVariant',
          'StockLevel',
          'StockMovement',
          'StockSourceType',
          'MeasureUnit',
          'MediaFile',
          'MediaKind',
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
          'Payment',
          'PaymentMethod',
          'PaymentStatus',
          'Sale',
          'SaleItem',
          'SaleStatus',
          'StockAdjustment',
          'StockAdjustmentItem',
          'StockAdjustmentReason',
          'LocalPreference',
          'OutboxStatus',
          'SyncOp',
          'SyncOutboxEntry',
          'SyncStateEntry',
        ],
      );

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'cash_movements',
      dartName: 'CashMovement',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'cash_session_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'direction',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CashDirection',
        ),
        _isp.ColumnDefinition(
          name: 'amount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'note',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'source',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'manual\'',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'cash_movements_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'cash_movements_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'cash_movements_fk_2',
          columns: ['cash_session_id'],
          referenceTable: 'cash_sessions',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'cash_movements_session_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
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
    _isp.TableDefinition(
      name: 'cash_sessions',
      dartName: 'CashSession',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:CashSessionStatus',
        ),
        _isp.ColumnDefinition(
          name: 'opened_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'opened_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'opening_cash',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'opening_note',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'closed_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'closed_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'expected_cash',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'counted_cash',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'difference',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'counted_breakdown',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'closing_note',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'cash_sessions_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'cash_sessions_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'cash_sessions_fk_2',
          columns: ['device_id'],
          referenceTable: 'devices',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'cash_sessions_fk_3',
          columns: ['opened_by'],
          referenceTable: 'staff_members',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'cash_sessions_fk_4',
          columns: ['closed_by'],
          referenceTable: 'staff_members',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'cash_sessions_device_status_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'device_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
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
    _isp.TableDefinition(
      name: 'categories',
      dartName: 'ProductCategory',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sort_order',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'categories_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'categories_tenant_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tenant_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'devices',
      dartName: 'Device',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'code',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'platform',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:DevicePlatform',
        ),
        _isp.ColumnDefinition(
          name: 'receipt_counter',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'receipt_counter_date',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'devices_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'devices_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'devices_outlet_code_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'outlet_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
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
    _isp.TableDefinition(
      name: 'media_files',
      dartName: 'MediaFile',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'kind',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:MediaKind',
        ),
        _isp.ColumnDefinition(
          name: 'file_name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'mime_type',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'size_bytes',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'sha256',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'width',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'height',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'storage_key',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'media_files_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'media_files_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'media_files_tenant_sha_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tenant_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sha256',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'outlet_members',
      dartName: 'OutletMember',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'staff_member_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'role_name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'outlet_members_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'outlet_members_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'outlet_members_fk_2',
          columns: ['staff_member_id'],
          referenceTable: 'staff_members',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'outlet_members_staff_outlet_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'staff_member_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
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
    _isp.TableDefinition(
      name: 'outlets',
      dartName: 'Outlet',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'code',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'address',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'phone',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'timezone',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'outlets_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'outlets_tenant_code_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tenant_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
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
    _isp.TableDefinition(
      name: 'payments',
      dartName: 'Payment',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'sale_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'method',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:PaymentMethod',
        ),
        _isp.ColumnDefinition(
          name: 'amount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'change_amount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'reference',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:PaymentStatus',
        ),
        _isp.ColumnDefinition(
          name: 'confirmed_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'confirmed_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'paid_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'payments_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'payments_fk_1',
          columns: ['sale_id'],
          referenceTable: 'sales',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'payments_sale_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sale_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'price_tiers',
      dartName: 'ProductPriceTier',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'variant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'min_qty_milli',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'price',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'price_tiers_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'price_tiers_fk_1',
          columns: ['variant_id'],
          referenceTable: 'product_variants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'price_tiers_variant_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'variant_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'product_units',
      dartName: 'ProductUnit',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'variant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'unit_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'factor_milli',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'barcode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'cost_price',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'sell_price',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'product_units_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'product_units_fk_1',
          columns: ['variant_id'],
          referenceTable: 'product_variants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'product_units_fk_2',
          columns: ['unit_id'],
          referenceTable: 'units',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'product_units_variant_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'variant_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'product_variants',
      dartName: 'ProductVariant',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'product_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'\'',
        ),
        _isp.ColumnDefinition(
          name: 'sku',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'barcode',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'cost_price',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'sell_price',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'min_stock_milli',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'sort_order',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'product_variants_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'product_variants_fk_1',
          columns: ['product_id'],
          referenceTable: 'products',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'product_variants_product_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'product_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'product_variants_tenant_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tenant_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'products',
      dartName: 'Product',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'category_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'base_unit_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'type',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ProductType',
        ),
        _isp.ColumnDefinition(
          name: 'sku',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'brand',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'is_active',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'is_taxable',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'products_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'products_fk_1',
          columns: ['category_id'],
          referenceTable: 'categories',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'products_fk_2',
          columns: ['base_unit_id'],
          referenceTable: 'units',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'products_tenant_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tenant_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'sale_items',
      dartName: 'SaleItem',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'sale_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'variant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'product_unit_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'product_name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'variant_name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'unit_name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'factor_milli',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'quantity_milli',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'list_price',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'unit_price',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'line_total',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'unit_cost',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'tracks_stock',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'sort_order',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'sale_items_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'sale_items_fk_1',
          columns: ['sale_id'],
          referenceTable: 'sales',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'sale_items_fk_2',
          columns: ['variant_id'],
          referenceTable: 'product_variants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'sale_items_fk_3',
          columns: ['product_unit_id'],
          referenceTable: 'product_units',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'sale_items_sale_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sale_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'sales',
      dartName: 'Sale',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'cash_session_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'staff_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'number',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:SaleStatus',
        ),
        _isp.ColumnDefinition(
          name: 'subtotal',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'tier_discount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'total',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'paid_amount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'change_amount',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'item_count',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'sold_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'sales_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'sales_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'sales_fk_2',
          columns: ['device_id'],
          referenceTable: 'devices',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'sales_fk_3',
          columns: ['cash_session_id'],
          referenceTable: 'cash_sessions',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'sales_fk_4',
          columns: ['staff_id'],
          referenceTable: 'staff_members',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'sales_number_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tenant_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'number',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'sales_session_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'cash_session_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'sales_outlet_sold_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'outlet_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sold_at',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'settings',
      dartName: 'Setting',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'scope_key',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'key',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'value_json',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'null\'',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'settings_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'settings_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'settings_tenant_scope_key_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tenant_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'scope_key',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
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
    _isp.TableDefinition(
      name: 'staff_members',
      dartName: 'StaffMember',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'email',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'pin_hash',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'password_hash',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'is_owner',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'is_active',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'true',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'staff_members_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'stock_adjustment_items',
      dartName: 'StockAdjustmentItem',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'adjustment_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'variant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'system_milli',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'physical_milli',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'difference_milli',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'unit_cost',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'value',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'note',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'sort_order',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '0',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'stock_adjustment_items_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'stock_adjustment_items_fk_1',
          columns: ['adjustment_id'],
          referenceTable: 'stock_adjustments',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'stock_adjustment_items_fk_2',
          columns: ['variant_id'],
          referenceTable: 'product_variants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'stock_adjustment_items_adjustment_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'adjustment_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'stock_adjustments',
      dartName: 'StockAdjustment',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'stock_location_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'number',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'reason',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:StockAdjustmentReason',
        ),
        _isp.ColumnDefinition(
          name: 'note',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'total_value',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'staff_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'adjusted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'stock_adjustments_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'stock_adjustments_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'stock_adjustments_fk_2',
          columns: ['stock_location_id'],
          referenceTable: 'stock_locations',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'stock_adjustments_fk_3',
          columns: ['staff_id'],
          referenceTable: 'staff_members',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'stock_adjustments_outlet_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'outlet_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'adjusted_at',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'stock_adjustments_number_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tenant_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'number',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'stock_locations',
      dartName: 'StockLocation',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'is_default',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
          columnDefault: 'false',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'stock_locations_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'stock_locations_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'stock_movements',
      dartName: 'StockMovement',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'outlet_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'stock_location_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'variant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'quantity_milli',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'unit_cost',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'source_type',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:StockSourceType',
        ),
        _isp.ColumnDefinition(
          name: 'source_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'occurred_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'note',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'stock_movements_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'stock_movements_fk_1',
          columns: ['outlet_id'],
          referenceTable: 'outlets',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'stock_movements_fk_2',
          columns: ['stock_location_id'],
          referenceTable: 'stock_locations',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'stock_movements_fk_3',
          columns: ['variant_id'],
          referenceTable: 'product_variants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'stock_movements_variant_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'stock_location_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'variant_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'tenants',
      dartName: 'Tenant',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'business_type',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:BusinessType',
          columnDefault: '\'retail\'',
        ),
        _isp.ColumnDefinition(
          name: 'plan',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:TenantPlan',
          columnDefault: '\'free\'',
        ),
        _isp.ColumnDefinition(
          name: 'timezone',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
          columnDefault: '\'Asia/Jakarta\'',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [],
      indexes: [],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'units',
      dartName: 'MeasureUnit',
      schema: 'public',
      module: 'lakuna',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'tenant_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'updated_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'deleted_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'created_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'updated_by',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
        _isp.ColumnDefinition(
          name: 'version',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
          columnDefault: '1',
        ),
        _isp.ColumnDefinition(
          name: 'hlc',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'origin_device_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'units_fk_0',
          columns: ['tenant_id'],
          referenceTable: 'tenants',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'units_tenant_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'tenant_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) =>
      _is.ProtocolDeserialization.readClassName(data);

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    final rawDataClassName = _is.ProtocolDeserialization.readClassName(data);
    final dataClassName = rawDataClassName;
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
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
    if (t == _i3vicioi.ProductCategory) {
      return _i3vicioi.ProductCategory.fromJson(data) as T;
    }
    if (t == _iwn9aw8c.ProductPriceTier) {
      return _iwn9aw8c.ProductPriceTier.fromJson(data) as T;
    }
    if (t == _ixeznjic.Product) {
      return _ixeznjic.Product.fromJson(data) as T;
    }
    if (t == _irudmnqe.ProductType) {
      return _irudmnqe.ProductType.fromJson(data) as T;
    }
    if (t == _i6wsuj4v.ProductUnit) {
      return _i6wsuj4v.ProductUnit.fromJson(data) as T;
    }
    if (t == _iz4qpnk9.ProductVariant) {
      return _iz4qpnk9.ProductVariant.fromJson(data) as T;
    }
    if (t == _i9vlojuz.StockLevel) {
      return _i9vlojuz.StockLevel.fromJson(data) as T;
    }
    if (t == _i3qehoul.StockMovement) {
      return _i3qehoul.StockMovement.fromJson(data) as T;
    }
    if (t == _ieciauh3.StockSourceType) {
      return _ieciauh3.StockSourceType.fromJson(data) as T;
    }
    if (t == _iqtijg36.MeasureUnit) {
      return _iqtijg36.MeasureUnit.fromJson(data) as T;
    }
    if (t == _iw898kbq.MediaFile) {
      return _iw898kbq.MediaFile.fromJson(data) as T;
    }
    if (t == _i8mjpd0r.MediaKind) {
      return _i8mjpd0r.MediaKind.fromJson(data) as T;
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
    if (t == _inbmsx46.Payment) {
      return _inbmsx46.Payment.fromJson(data) as T;
    }
    if (t == _i3u620qk.PaymentMethod) {
      return _i3u620qk.PaymentMethod.fromJson(data) as T;
    }
    if (t == _i132i774.PaymentStatus) {
      return _i132i774.PaymentStatus.fromJson(data) as T;
    }
    if (t == _ichu53ep.Sale) {
      return _ichu53ep.Sale.fromJson(data) as T;
    }
    if (t == _i2mbgaee.SaleItem) {
      return _i2mbgaee.SaleItem.fromJson(data) as T;
    }
    if (t == _i3d8n48k.SaleStatus) {
      return _i3d8n48k.SaleStatus.fromJson(data) as T;
    }
    if (t == _i7xu84a6.StockAdjustment) {
      return _i7xu84a6.StockAdjustment.fromJson(data) as T;
    }
    if (t == _iuqt5pmc.StockAdjustmentItem) {
      return _iuqt5pmc.StockAdjustmentItem.fromJson(data) as T;
    }
    if (t == _i5me420k.StockAdjustmentReason) {
      return _i5me420k.StockAdjustmentReason.fromJson(data) as T;
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
    if (t == _is.getType<_i728pu70.CashDirection?>()) {
      return (data != null ? _i728pu70.CashDirection.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iepnwe9z.CashMovement?>()) {
      return (data != null ? _iepnwe9z.CashMovement.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iepiq7d7.CashSession?>()) {
      return (data != null ? _iepiq7d7.CashSession.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_itp0bn28.CashSessionStatus?>()) {
      return (data != null ? _itp0bn28.CashSessionStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i3vicioi.ProductCategory?>()) {
      return (data != null ? _i3vicioi.ProductCategory.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iwn9aw8c.ProductPriceTier?>()) {
      return (data != null ? _iwn9aw8c.ProductPriceTier.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ixeznjic.Product?>()) {
      return (data != null ? _ixeznjic.Product.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_irudmnqe.ProductType?>()) {
      return (data != null ? _irudmnqe.ProductType.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i6wsuj4v.ProductUnit?>()) {
      return (data != null ? _i6wsuj4v.ProductUnit.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iz4qpnk9.ProductVariant?>()) {
      return (data != null ? _iz4qpnk9.ProductVariant.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i9vlojuz.StockLevel?>()) {
      return (data != null ? _i9vlojuz.StockLevel.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i3qehoul.StockMovement?>()) {
      return (data != null ? _i3qehoul.StockMovement.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ieciauh3.StockSourceType?>()) {
      return (data != null ? _ieciauh3.StockSourceType.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iqtijg36.MeasureUnit?>()) {
      return (data != null ? _iqtijg36.MeasureUnit.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iw898kbq.MediaFile?>()) {
      return (data != null ? _iw898kbq.MediaFile.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i8mjpd0r.MediaKind?>()) {
      return (data != null ? _i8mjpd0r.MediaKind.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i6i3gkff.BusinessType?>()) {
      return (data != null ? _i6i3gkff.BusinessType.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iis0lnof.Device?>()) {
      return (data != null ? _iis0lnof.Device.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ide5u809.DevicePlatform?>()) {
      return (data != null ? _ide5u809.DevicePlatform.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iqoqqr0f.Outlet?>()) {
      return (data != null ? _iqoqqr0f.Outlet.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_igpgya6r.OutletMember?>()) {
      return (data != null ? _igpgya6r.OutletMember.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_if597mfg.Setting?>()) {
      return (data != null ? _if597mfg.Setting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iy6hfkoy.StaffMember?>()) {
      return (data != null ? _iy6hfkoy.StaffMember.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iwbn33ao.StockLocation?>()) {
      return (data != null ? _iwbn33ao.StockLocation.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_icpow00o.Tenant?>()) {
      return (data != null ? _icpow00o.Tenant.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ii59gw8o.TenantPlan?>()) {
      return (data != null ? _ii59gw8o.TenantPlan.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_inbmsx46.Payment?>()) {
      return (data != null ? _inbmsx46.Payment.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i3u620qk.PaymentMethod?>()) {
      return (data != null ? _i3u620qk.PaymentMethod.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i132i774.PaymentStatus?>()) {
      return (data != null ? _i132i774.PaymentStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ichu53ep.Sale?>()) {
      return (data != null ? _ichu53ep.Sale.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i2mbgaee.SaleItem?>()) {
      return (data != null ? _i2mbgaee.SaleItem.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i3d8n48k.SaleStatus?>()) {
      return (data != null ? _i3d8n48k.SaleStatus.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i7xu84a6.StockAdjustment?>()) {
      return (data != null ? _i7xu84a6.StockAdjustment.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iuqt5pmc.StockAdjustmentItem?>()) {
      return (data != null
              ? _iuqt5pmc.StockAdjustmentItem.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i5me420k.StockAdjustmentReason?>()) {
      return (data != null
              ? _i5me420k.StockAdjustmentReason.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ierz52ew.LocalPreference?>()) {
      return (data != null ? _ierz52ew.LocalPreference.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_imib010r.OutboxStatus?>()) {
      return (data != null ? _imib010r.OutboxStatus.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ipjkwoxz.SyncOp?>()) {
      return (data != null ? _ipjkwoxz.SyncOp.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ikzi06kl.SyncOutboxEntry?>()) {
      return (data != null ? _ikzi06kl.SyncOutboxEntry.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iwwr3hpi.SyncStateEntry?>()) {
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
      } on _is.DeserializationTypeNotFoundException catch (_) {}
    }

    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i728pu70.CashDirection => 'CashDirection',
      _iepnwe9z.CashMovement => 'CashMovement',
      _iepiq7d7.CashSession => 'CashSession',
      _itp0bn28.CashSessionStatus => 'CashSessionStatus',
      _i3vicioi.ProductCategory => 'ProductCategory',
      _iwn9aw8c.ProductPriceTier => 'ProductPriceTier',
      _ixeznjic.Product => 'Product',
      _irudmnqe.ProductType => 'ProductType',
      _i6wsuj4v.ProductUnit => 'ProductUnit',
      _iz4qpnk9.ProductVariant => 'ProductVariant',
      _i9vlojuz.StockLevel => 'StockLevel',
      _i3qehoul.StockMovement => 'StockMovement',
      _ieciauh3.StockSourceType => 'StockSourceType',
      _iqtijg36.MeasureUnit => 'MeasureUnit',
      _iw898kbq.MediaFile => 'MediaFile',
      _i8mjpd0r.MediaKind => 'MediaKind',
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
      _inbmsx46.Payment => 'Payment',
      _i3u620qk.PaymentMethod => 'PaymentMethod',
      _i132i774.PaymentStatus => 'PaymentStatus',
      _ichu53ep.Sale => 'Sale',
      _i2mbgaee.SaleItem => 'SaleItem',
      _i3d8n48k.SaleStatus => 'SaleStatus',
      _i7xu84a6.StockAdjustment => 'StockAdjustment',
      _iuqt5pmc.StockAdjustmentItem => 'StockAdjustmentItem',
      _i5me420k.StockAdjustmentReason => 'StockAdjustmentReason',
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
      case _i3vicioi.ProductCategory():
        return 'ProductCategory';
      case _iwn9aw8c.ProductPriceTier():
        return 'ProductPriceTier';
      case _ixeznjic.Product():
        return 'Product';
      case _irudmnqe.ProductType():
        return 'ProductType';
      case _i6wsuj4v.ProductUnit():
        return 'ProductUnit';
      case _iz4qpnk9.ProductVariant():
        return 'ProductVariant';
      case _i9vlojuz.StockLevel():
        return 'StockLevel';
      case _i3qehoul.StockMovement():
        return 'StockMovement';
      case _ieciauh3.StockSourceType():
        return 'StockSourceType';
      case _iqtijg36.MeasureUnit():
        return 'MeasureUnit';
      case _iw898kbq.MediaFile():
        return 'MediaFile';
      case _i8mjpd0r.MediaKind():
        return 'MediaKind';
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
      case _inbmsx46.Payment():
        return 'Payment';
      case _i3u620qk.PaymentMethod():
        return 'PaymentMethod';
      case _i132i774.PaymentStatus():
        return 'PaymentStatus';
      case _ichu53ep.Sale():
        return 'Sale';
      case _i2mbgaee.SaleItem():
        return 'SaleItem';
      case _i3d8n48k.SaleStatus():
        return 'SaleStatus';
      case _i7xu84a6.StockAdjustment():
        return 'StockAdjustment';
      case _iuqt5pmc.StockAdjustmentItem():
        return 'StockAdjustmentItem';
      case _i5me420k.StockAdjustmentReason():
        return 'StockAdjustmentReason';
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
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
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
    if (dataClassName == 'ProductCategory') {
      return deserialize<_i3vicioi.ProductCategory>(data['data']);
    }
    if (dataClassName == 'ProductPriceTier') {
      return deserialize<_iwn9aw8c.ProductPriceTier>(data['data']);
    }
    if (dataClassName == 'Product') {
      return deserialize<_ixeznjic.Product>(data['data']);
    }
    if (dataClassName == 'ProductType') {
      return deserialize<_irudmnqe.ProductType>(data['data']);
    }
    if (dataClassName == 'ProductUnit') {
      return deserialize<_i6wsuj4v.ProductUnit>(data['data']);
    }
    if (dataClassName == 'ProductVariant') {
      return deserialize<_iz4qpnk9.ProductVariant>(data['data']);
    }
    if (dataClassName == 'StockLevel') {
      return deserialize<_i9vlojuz.StockLevel>(data['data']);
    }
    if (dataClassName == 'StockMovement') {
      return deserialize<_i3qehoul.StockMovement>(data['data']);
    }
    if (dataClassName == 'StockSourceType') {
      return deserialize<_ieciauh3.StockSourceType>(data['data']);
    }
    if (dataClassName == 'MeasureUnit') {
      return deserialize<_iqtijg36.MeasureUnit>(data['data']);
    }
    if (dataClassName == 'MediaFile') {
      return deserialize<_iw898kbq.MediaFile>(data['data']);
    }
    if (dataClassName == 'MediaKind') {
      return deserialize<_i8mjpd0r.MediaKind>(data['data']);
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
    if (dataClassName == 'Payment') {
      return deserialize<_inbmsx46.Payment>(data['data']);
    }
    if (dataClassName == 'PaymentMethod') {
      return deserialize<_i3u620qk.PaymentMethod>(data['data']);
    }
    if (dataClassName == 'PaymentStatus') {
      return deserialize<_i132i774.PaymentStatus>(data['data']);
    }
    if (dataClassName == 'Sale') {
      return deserialize<_ichu53ep.Sale>(data['data']);
    }
    if (dataClassName == 'SaleItem') {
      return deserialize<_i2mbgaee.SaleItem>(data['data']);
    }
    if (dataClassName == 'SaleStatus') {
      return deserialize<_i3d8n48k.SaleStatus>(data['data']);
    }
    if (dataClassName == 'StockAdjustment') {
      return deserialize<_i7xu84a6.StockAdjustment>(data['data']);
    }
    if (dataClassName == 'StockAdjustmentItem') {
      return deserialize<_iuqt5pmc.StockAdjustmentItem>(data['data']);
    }
    if (dataClassName == 'StockAdjustmentReason') {
      return deserialize<_i5me420k.StockAdjustmentReason>(data['data']);
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
      return _iais.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(19),
      });
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      return _iacs.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(20),
      });
    }
    if (dataClassName.startsWith('serverpod.')) {
      return _isp.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(10),
      });
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('lakuna', this);
    _iacs.Protocol().registerHostProtocol('lakuna', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _iepnwe9z.CashMovement:
        return _iepnwe9z.CashMovement.t;
      case _iepiq7d7.CashSession:
        return _iepiq7d7.CashSession.t;
      case _i3vicioi.ProductCategory:
        return _i3vicioi.ProductCategory.t;
      case _iwn9aw8c.ProductPriceTier:
        return _iwn9aw8c.ProductPriceTier.t;
      case _ixeznjic.Product:
        return _ixeznjic.Product.t;
      case _i6wsuj4v.ProductUnit:
        return _i6wsuj4v.ProductUnit.t;
      case _iz4qpnk9.ProductVariant:
        return _iz4qpnk9.ProductVariant.t;
      case _i3qehoul.StockMovement:
        return _i3qehoul.StockMovement.t;
      case _iqtijg36.MeasureUnit:
        return _iqtijg36.MeasureUnit.t;
      case _iw898kbq.MediaFile:
        return _iw898kbq.MediaFile.t;
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
      case _inbmsx46.Payment:
        return _inbmsx46.Payment.t;
      case _ichu53ep.Sale:
        return _ichu53ep.Sale.t;
      case _i2mbgaee.SaleItem:
        return _i2mbgaee.SaleItem.t;
      case _i7xu84a6.StockAdjustment:
        return _i7xu84a6.StockAdjustment.t;
      case _iuqt5pmc.StockAdjustmentItem:
        return _iuqt5pmc.StockAdjustmentItem.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
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
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
