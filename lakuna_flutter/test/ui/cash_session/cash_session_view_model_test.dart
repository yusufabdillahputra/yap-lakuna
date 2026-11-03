import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/cash_drawer_repository.dart';
import 'package:lakuna_flutter/ui/cash_session/cash_session_view_model.dart';

import '../../testing/fake_cash_drawer_repository.dart';

void main() {
  late FakeCashDrawerRepository repo;
  late CashSessionViewModel vm;

  CashSessionViewModel create({Set<Permission>? permissions}) =>
      CashSessionViewModel(
        repository: repo,
        permissions: permissions ?? Permission.values.toSet(),
      );

  setUp(() {
    repo = FakeCashDrawerRepository();
    vm = create();
  });

  tearDown(() => vm.dispose());

  Future<void> openWith(String cash) async {
    vm.setOpeningCash(cash);
    await vm.open.execute();
  }

  test('parseRupiah membaca angka dengan titik ribuan', () {
    expect(parseRupiah('200.000'), const Money(200000));
    expect(parseRupiah(' 1.500 '), const Money(1500));
    expect(parseRupiah('0'), Money.zero);
    expect(parseRupiah(''), isNull);
    expect(parseRupiah('abc'), isNull);
  });

  test('memuat: tanpa sesi → formulir buka', () async {
    await vm.load.execute();
    expect(vm.loaded, isTrue);
    expect(vm.active, isNull);
    expect(vm.stage, CashStage.openForm);
  });

  test('buka sesi: saldo awal wajib diisi', () async {
    await vm.load.execute();
    await vm.open.execute();
    expect(vm.openingCashError, CashError.required);
    expect(repo.session, isNull);
  });

  test('buka sesi lalu kas laci', () async {
    await vm.load.execute();
    vm.setOpeningNote('Laci pagi');
    await openWith('200.000');
    expect(vm.openingCashError, isNull);
    expect(vm.stage, CashStage.drawer);
    expect(vm.active!.drawer.expectedCash, const Money(200000));
    expect(repo.session!.openingNote, 'Laci pagi');
  });

  test('uang keluar: validasi lalu tersimpan dan formulir direset', () async {
    await vm.load.execute();
    await openWith('200000');
    expect(vm.direction, CashDirection.outflow);

    await vm.saveMovement.execute();
    expect(vm.movementAmountError, CashError.required);
    expect(vm.movementNoteError, CashError.required);
    expect(repo.movements, isEmpty);

    final formBefore = vm.movementFormVersion;
    vm
      ..setMovementAmount('15.000')
      ..setMovementNote('Beli es batu');
    await vm.saveMovement.execute();
    expect(vm.movementAmountError, isNull);
    expect(vm.movementNoteError, isNull);
    expect(vm.active!.drawer.expectedCash, const Money(185000));
    expect(vm.movementFormVersion, formBefore + 1);

    // Formulir kosong lagi setelah tersimpan.
    await vm.saveMovement.execute();
    expect(vm.movementAmountError, CashError.required);
  });

  test('uang masuk menambah perkiraan', () async {
    await vm.load.execute();
    await openWith('100000');
    vm
      ..setDirection(CashDirection.inflow)
      ..setMovementAmount('50000')
      ..setMovementNote('Tambah kembalian');
    await vm.saveMovement.execute();
    expect(vm.active!.drawer.expectedCash, const Money(150000));
  });

  test('jumlah nol ditolak', () async {
    await vm.load.execute();
    await openWith('100000');
    vm
      ..setMovementAmount('0')
      ..setMovementNote('x');
    await vm.saveMovement.execute();
    expect(vm.movementAmountError, CashError.notPositive);
  });

  test('hitung uang: subtotal, total, selisih', () async {
    await vm.load.execute();
    await openWith('200000');
    vm.startClosing();
    expect(vm.stage, CashStage.closeForm);
    expect(vm.difference, const Money(-200000));
    vm
      ..setSheets(100000, '1')
      ..setSheets(50000, '1')
      ..setSheets(20000, '2')
      ..setCoins('7.500');
    expect(vm.subtotal(20000), const Money(40000));
    expect(vm.countedTotal, const Money(197500));
    expect(vm.difference, const Money(-2500));
    vm.setSheets(20000, '');
    expect(vm.countedTotal, const Money(157500));
  });

  test('tutup: selisih butuh catatan, lalu hasil', () async {
    await vm.load.execute();
    await openWith('200000');
    vm
      ..startClosing()
      ..setSheets(100000, '1')
      ..setSheets(50000, '1')
      ..setSheets(20000, '2');
    await vm.close.execute();
    expect(vm.closingNoteError, CashError.required);
    expect(vm.stage, CashStage.closeForm);

    vm.setClosingNote('Kurang 10 ribu');
    await vm.close.execute();
    expect(vm.closingNoteError, isNull);
    expect(vm.stage, CashStage.closed);
    expect(vm.closed!.difference, -10000);
    expect(vm.active, isNull);

    vm.startNew();
    expect(vm.stage, CashStage.openForm);
  });

  test('selisih pas tidak butuh catatan', () async {
    await vm.load.execute();
    await openWith('100000');
    vm
      ..startClosing()
      ..setSheets(100000, '1');
    expect(vm.difference, Money.zero);
    await vm.close.execute();
    expect(vm.stage, CashStage.closed);
  });

  test('kembali ke kas laci dari formulir tutup', () async {
    await vm.load.execute();
    await openWith('100000');
    vm
      ..startClosing()
      ..cancelClosing();
    expect(vm.stage, CashStage.drawer);
  });

  test(
    'hitungan dan catatan tidak tersimpan diam-diam saat bolak-balik',
    () async {
      await vm.load.execute();
      await openWith('100000');
      vm
        ..startClosing()
        ..setSheets(100000, '3')
        ..setCoins('500')
        ..setClosingNote('catatan tersembunyi')
        ..cancelClosing()
        ..startClosing();
      expect(vm.countedTotal, Money.zero);
      expect(vm.sheetsOf(100000), 0);
      await vm.close.execute();
      expect(vm.closingNoteError, CashError.required);
      expect(repo.session!.status, CashSessionStatus.opened);
    },
  );

  test('formulir uang laci dikosongkan saat pindah ke tutup sesi', () async {
    await vm.load.execute();
    await openWith('100000');
    final version = vm.movementFormVersion;
    vm
      ..setMovementAmount('15000')
      ..setMovementNote('hantu')
      ..startClosing();
    expect(vm.movementFormVersion, greaterThan(version));
    vm.cancelClosing();
    await vm.saveMovement.execute();
    expect(vm.movementAmountError, CashError.required);
    expect(repo.movements, isEmpty);
  });

  test('masuk ke tutup sesi memuat ulang rekap terbaru', () async {
    await vm.load.execute();
    await openWith('100000');
    // Modul lain menulis uang keluar setelah layar dimuat.
    await repo.recordMovement(
      repo.session!.id,
      direction: CashDirection.outflow,
      amount: const Money(10000),
      note: 'Pengeluaran',
    );
    vm.startClosing();
    await pumpEventQueue();
    expect(vm.active!.drawer.expectedCash, const Money(90000));
  });

  test('catatan buka sesi terlalu panjang ditempel di field-nya', () async {
    await vm.load.execute();
    vm.setOpeningNote('x' * (cashNoteMaxLength + 1));
    await openWith('1000');
    expect(vm.openingNoteError, CashError.tooLong);
    expect(vm.error, isNull);
    expect(repo.session, isNull);
  });

  test('izin mengatur tombol', () {
    final limited = create(permissions: {Permission.cashSessionOpen});
    addTearDown(limited.dispose);
    expect(limited.canOpen, isTrue);
    expect(limited.canClose, isFalse);
    expect(limited.canRecordMovement, isFalse);
    expect(vm.canClose, isTrue);
  });

  test('NotPermitted dari repositori menjadi galat umum', () async {
    await vm.load.execute();
    repo.permissions = const {};
    await openWith('1000');
    expect(vm.error, isA<NotPermitted>());
    expect(vm.stage, CashStage.openForm);
  });

  test('sesi sudah dibuka di layar lain → muat ulang', () async {
    await vm.load.execute();
    await repo.open(openingCash: const Money(50000));
    final loadsBefore = repo.loadCalls;
    await openWith('100000');
    expect(repo.loadCalls, loadsBefore + 1);
    expect(vm.stage, CashStage.drawer);
    expect(vm.active!.drawer.openingCash, const Money(50000));
    expect(vm.error, isA<CashSessionAlreadyOpen>());
  });

  test('sesi sudah ditutup di layar lain → muat ulang', () async {
    await vm.load.execute();
    await openWith('100000');
    await repo.close(
      repo.session!.id,
      count: const CashCount(sheets: {100000: 1}),
    );
    vm
      ..setMovementAmount('1000')
      ..setMovementNote('x');
    await vm.saveMovement.execute();
    expect(vm.stage, CashStage.openForm);
    expect(vm.error, isA<CashSessionNotOpen>());
  });

  test('gagal memuat', () async {
    repo.nextError = Exception('disk');
    await vm.load.execute();
    expect(vm.stage, CashStage.loadFailed);
  });
}
