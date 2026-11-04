import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/store_settings_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

const sampleStoreProfile = StoreProfile(
  businessName: 'Warung Contoh',
  businessType: BusinessType.retail,
  timezone: 'Asia/Jakarta',
  outletName: 'Cabang Pusat',
  address: 'Jl. Melati 1',
  phone: '0812-3456',
  outletCode: 'PST',
  deviceCode: 'K01',
);

class FakeStoreSettingsRepository implements StoreSettingsRepository {
  FakeStoreSettingsRepository({
    this.stored = sampleStoreProfile,
    this.rules = const SalesRules(),
    this.failSave = false,
  });

  StoreProfile stored;
  SalesRules rules;
  bool failSave;
  final calls = <String>[];

  @override
  Future<Result<StoreProfile>> profile() async => Result.ok(stored);

  @override
  Future<Result<SalesRules>> salesRules() async => Result.ok(rules);

  @override
  Future<Result<StoreProfile>> saveBusinessName(String name) async {
    calls.add('business:$name');
    if (failSave) return Result.error(Exception('disk penuh'));
    stored = StoreProfile(
      businessName: name.trim(),
      businessType: stored.businessType,
      timezone: stored.timezone,
      outletName: stored.outletName,
      address: stored.address,
      phone: stored.phone,
      outletCode: stored.outletCode,
      deviceCode: stored.deviceCode,
    );
    return Result.ok(stored);
  }

  @override
  Future<Result<StoreProfile>> saveOutlet({
    required String name,
    required String address,
    required String phone,
  }) async {
    calls.add('outlet:$name:$address:$phone');
    if (failSave) return Result.error(Exception('disk penuh'));
    stored = StoreProfile(
      businessName: stored.businessName,
      businessType: stored.businessType,
      timezone: stored.timezone,
      outletName: name.trim(),
      address: address.trim(),
      phone: phone.trim(),
      outletCode: stored.outletCode,
      deviceCode: stored.deviceCode,
    );
    return Result.ok(stored);
  }

  @override
  Future<Result<SalesRules>> saveSalesRules(SalesRules rules) async {
    calls.add('rules:${rules.allowNegativeStock}:${rules.rounding.name}');
    if (failSave) return Result.error(Exception('disk penuh'));
    this.rules = rules;
    return Result.ok(rules);
  }
}
