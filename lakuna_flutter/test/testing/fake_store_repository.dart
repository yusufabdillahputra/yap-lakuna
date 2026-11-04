import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/store_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

/// Konteks toko contoh untuk tes.
StoreContext sampleStoreContext({
  String businessName = 'Warung Contoh',
  String outletName = 'Cabang Pusat',
  String outletCode = 'PST',
  String deviceCode = 'K01',
  String? timezone,
  BusinessType businessType = BusinessType.retail,
}) {
  final tenantId = UuidValue.fromString(newId());
  final outletId = UuidValue.fromString(newId());
  return StoreContext(
    tenant: Tenant(
      id: tenantId,
      name: businessName,
      businessType: businessType,
      hlc: 'h',
    ),
    outlet: Outlet(
      id: outletId,
      tenantId: tenantId,
      code: outletCode,
      name: outletName,
      timezone: timezone,
      hlc: 'h',
    ),
    device: Device(
      id: UuidValue.fromString(newId()),
      tenantId: tenantId,
      outletId: outletId,
      code: deviceCode,
      name: 'Perangkat $deviceCode',
      platform: DevicePlatform.linux,
      hlc: 'h',
    ),
    owner: StaffMember(
      tenantId: tenantId,
      name: 'Yusuf',
      isOwner: true,
      hlc: 'h',
    ),
  );
}

class FakeStoreRepository extends StoreRepository {
  FakeStoreRepository({this._current, this.failSetup = false});

  StoreContext? _current;
  bool failSetup;
  final setupCalls = <SetupInput>[];

  @override
  StoreContext? get current => _current;

  @override
  Future<Result<StoreContext?>> load() async => Result.ok(_current);

  @override
  Future<Result<StoreContext>> setup(SetupInput input) async {
    setupCalls.add(input);
    if (failSetup) return Result.error(Exception('disk penuh'));
    if (_current != null) return Result.error(SetupAlreadyDone());
    final ctx = sampleStoreContext(
      businessName: input.businessName,
      outletName: input.outletName,
      outletCode: input.outletCode,
      deviceCode: input.deviceCode,
    );
    _current = ctx;
    notifyListeners();
    return Result.ok(ctx);
  }
}
