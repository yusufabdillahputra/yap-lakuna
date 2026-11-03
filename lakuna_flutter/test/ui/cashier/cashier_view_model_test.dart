import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/cashier_repository.dart';
import 'package:lakuna_flutter/ui/cashier/cashier_view_model.dart';

import '../../testing/cashier_seed.dart';
import '../../testing/fake_cashier_repository.dart';

void main() {
  late FakeCashierRepository repo;
  late CashierViewModel vm;

  setUp(() async {
    repo = FakeCashierRepository(seed: cashierProducts());
    vm = CashierViewModel(repository: repo);
    await vm.load.execute();
  });

  CatalogProduct product(String name) =>
      vm.products.firstWhere((p) => p.name == name);

  test('memuat produk aktif dan kategori', () {
    expect(vm.loaded, isTrue);
    expect(vm.hasSession, isTrue);
    expect(vm.products.map((p) => p.name), [
      'Beras Premium',
      'Kopi Sachet',
      'Minyak Goreng',
    ]);
    expect(vm.categories.map((c) => c.name), ['Sembako', 'Minuman']);
    expect(vm.cartIsEmpty, isTrue);
  });

  test('cari dan filter kategori', () {
    vm.setQuery('kopi');
    expect(vm.products.single.name, 'Kopi Sachet');
    vm.setQuery('8990002');
    expect(vm.products.single.name, 'Beras Premium');
    vm
      ..setQuery('')
      ..setCategory(
        vm.categories.firstWhere((c) => c.name == 'Minuman').id,
      );
    expect(vm.products.single.name, 'Kopi Sachet');
    vm.setCategory(null);
    expect(vm.products, hasLength(3));
  });

  test('ketuk produk: langsung masuk bila hanya satu pilihan', () {
    expect(vm.tapProduct(product('Kopi Sachet')), isTrue);
    expect(vm.lines.single.title, 'Kopi Sachet');
    expect(vm.tapProduct(product('Kopi Sachet')), isTrue);
    expect(vm.lines.single.quantity, Qty.units(2));

    // Varian atau satuan lain → pilih dulu.
    expect(vm.tapProduct(product('Beras Premium')), isFalse);
    final beras = vm.optionsFor(product('Beras Premium'));
    expect(beras.map((o) => o.label), ['5 kg', '10 kg']);
    final minyak = vm.optionsFor(product('Minyak Goreng'));
    expect(minyak.map((o) => o.label), ['2 L · botol', '2 L · Dus (6)']);
    expect(minyak.last.price, const Money(210000));
    vm.addOption(minyak.last);
    expect(vm.lines.last.title, 'Minyak Goreng 2 L');
    expect(vm.lines.last.unitName, 'Dus');
  });

  test('scan barcode varian dan satuan, Enter dengan teks tak dikenal', () {
    expect(vm.scan(' 8991234500024 '), ScanOutcome.added);
    expect(vm.scan('8991234500031'), ScanOutcome.added);
    expect(vm.scan('kop'), ScanOutcome.added); // SKU, tidak peka huruf
    expect(vm.lines.map((l) => l.unitName), ['botol', 'Dus', 'sachet']);
    expect(vm.scan('0000'), ScanOutcome.unknown);
    expect(vm.unknownCode, '0000');
    vm.setQuery('k');
    expect(vm.unknownCode, isNull);
    expect(vm.scan('  '), ScanOutcome.empty);
    expect(vm.lines, hasLength(3));
  });

  test('jumlah, grosir, total, dan diskon grosir', () {
    vm.scan('8991234500024');
    vm.setQuantity(0, Qty.units(6));
    final line = vm.lines.single;
    expect(line.priced.unitPrice, const Money(35000));
    expect(line.priced.tier?.minQty, Qty.units(6));
    expect(vm.totals.subtotal, const Money(216000));
    expect(vm.totals.tierDiscount, const Money(6000));
    expect(vm.totals.total, const Money(210000));

    vm.decrement(0);
    expect(vm.lines.single.quantity, Qty.units(5));
    expect(vm.totals.tierDiscount, Money.zero);
    vm.increment(0);
    expect(vm.lines.single.quantity, Qty.units(6));

    vm.setQuantity(0, const Qty(500));
    expect(vm.lines.single.quantity, const Qty(500));
    expect(vm.totals.total, const Money(18000));
    vm.decrement(0); // di bawah 1 → hapus baris
    expect(vm.cartIsEmpty, isTrue);
  });

  test('jumlah produk dan item untuk bilah bawah ponsel', () {
    vm.scan('KOP');
    vm.scan('KOP');
    vm.scan('8990001');
    expect(vm.lineCount, 2);
    expect(vm.itemQuantity, Qty.units(3));
    vm.clearCart();
    expect(vm.cartIsEmpty, isTrue);
  });

  test('bayar tunai: keypad, nominal cepat, kembalian, selesai', () async {
    vm.scan('8990001'); // 72.500
    vm.startPayment();
    expect(vm.stage, CashierStage.pay);
    expect(vm.method, PaymentMethod.cash);
    expect(vm.received, Money.zero);
    expect(vm.canPay, isFalse);
    expect(vm.shortBy, const Money(72500));
    expect(vm.quickAmounts, const [
      Money(72500),
      Money(80000),
      Money(100000),
    ]);

    for (final k in ['1', '0', '000', '0']) {
      vm.keypad(k);
    }
    expect(vm.received, const Money(100000));
    vm.keypad(CashierViewModel.backspace);
    expect(vm.received, const Money(10000));
    vm.setReceived(const Money(100000));
    expect(vm.change, const Money(27500));
    expect(vm.canPay, isTrue);

    await vm.pay.execute();
    expect(vm.stage, CashierStage.done);
    expect(vm.result!.sale.number, 'PST-K01-261103-0001');
    expect(vm.result!.payments.single.changeAmount, 27500);
    expect(vm.cartIsEmpty, isTrue);
    final (lines, payments) = repo.checkouts.single;
    expect(lines.single.quantity, Qty.one);
    expect(payments.single.amount, const Money(100000));

    vm.newTransaction();
    expect(vm.stage, CashierStage.browse);
    expect(vm.result, isNull);
  });

  test('keypad dibatasi 15 digit', () {
    vm.scan('KOP');
    vm.startPayment();
    for (var i = 0; i < 20; i++) {
      vm.keypad('9');
    }
    expect(vm.received.value.toString().length, 15);
  });

  test('kartu: jumlah = total, no. approval ikut', () async {
    vm.scan('KOP');
    vm.startPayment();
    vm.setMode(PayMode.card);
    expect(vm.canPay, isTrue);
    vm.setReference('004512');
    await vm.pay.execute();
    final (_, payments) = repo.checkouts.single;
    expect(payments.single.method, PaymentMethod.card);
    expect(payments.single.reference, '004512');
    expect(payments.single.amount, isNull);
    expect(vm.result!.payments.single.changeAmount, 0);
  });

  test('referensi terlalu panjang mematikan tombol bayar', () {
    vm.scan('KOP');
    vm.startPayment();
    vm.setMode(PayMode.transfer);
    vm.setReference('x' * 41);
    expect(vm.referenceTooLong, isTrue);
    expect(vm.canPay, isFalse);
  });

  test('kembali dari layar bayar mempertahankan keranjang', () {
    vm.scan('KOP');
    vm.startPayment();
    vm.backToCart();
    expect(vm.stage, CashierStage.browse);
    expect(vm.lines, hasLength(1));
  });

  test('stok jadi minus dilaporkan di hasil', () async {
    vm.scan('KOP');
    vm.scan('KOP');
    vm.startPayment();
    vm.setMode(PayMode.card);
    await vm.pay.execute();
    expect(vm.result!.negativeStock.single.name, 'Kopi Sachet');
  });

  test('galat simpan ditampilkan dan keranjang utuh', () async {
    vm.scan('KOP');
    vm.startPayment();
    vm.setMode(PayMode.card);
    repo.sessionOpen = false;
    await vm.pay.execute();
    expect(vm.stage, CashierStage.pay);
    expect(vm.error, isA<CashSessionNotOpen>());
    expect(vm.lines, hasLength(1));
  });

  test('tanpa sesi kasir', () async {
    repo.sessionOpen = false;
    await vm.load.execute();
    expect(vm.hasSession, isFalse);
  });

  test('setelah transaksi, katalog dimuat ulang untuk stok terbaru', () async {
    vm.scan('KOP');
    vm.startPayment();
    vm.setMode(PayMode.card);
    final before = repo.loadCalls;
    await vm.pay.execute();
    vm.newTransaction();
    await Future<void>.delayed(Duration.zero);
    expect(repo.loadCalls, before + 1);
  });

  test('id varian dan satuan dikirim ke checkout', () async {
    vm.scan('8991234500031');
    vm.startPayment();
    vm.setMode(PayMode.card);
    await vm.pay.execute();
    final (lines, _) = repo.checkouts.single;
    final minyak = product('Minyak Goreng').variants.single;
    expect(lines.single.variantId, minyak.id);
    expect(lines.single.productUnitId, minyak.units.single.id);
    expect(lines.single.quantity, Qty.one);
  });

  test('UuidValue tidak dipakai sebagai kunci tampilan', () {
    vm.scan('KOP');
    expect(vm.lines.single.key, isA<int>());
    expect(vm.lines.single.variant.id, isA<UuidValue>());
  });

  group('QRIS statis', () {
    final sticker = CashierQris(
      image: Uint8List.fromList(const [1, 2, 3]),
      merchantName: 'WARUNG CONTOH',
    );

    test('tanpa QRIS aktif: mode QRIS tidak bisa dipilih', () {
      vm.scan('KOP');
      vm.startPayment();
      vm.setMode(PayMode.qris);
      expect(vm.mode, PayMode.cash);
      expect(vm.splitMethods, isNot(contains(PaymentMethod.qrisStatic)));
    });

    test('Sudah Terbayar menyimpan QRIS terkonfirmasi', () async {
      repo.qris = sticker;
      await vm.load.execute();
      vm.scan('KOP');
      vm.startPayment();
      vm.setMode(PayMode.qris);
      expect(vm.mode, PayMode.qris);
      expect(vm.canPay, isFalse); // bukan tombol Selesaikan
      expect(vm.canConfirmQris, isTrue);
      await vm.pay.execute();
      expect(vm.stage, CashierStage.done);
      final payment = repo.checkouts.single.$2.single;
      expect(payment.method, PaymentMethod.qrisStatic);
      expect(payment.confirmed, isTrue);
    });

    test('Belum masuk kembali ke tunai tanpa menyimpan', () {
      repo.qris = sticker;
      vm.load.execute();
      vm.scan('KOP');
      vm.startPayment();
      vm.setMode(PayMode.qris);
      vm.qrisNotReceived();
      expect(vm.mode, PayMode.cash);
      expect(repo.checkouts, isEmpty);
    });

    test('tanpa payments:confirm tombol Sudah Terbayar mati', () async {
      repo
        ..qris = sticker
        ..permissions = {Permission.salesCreate};
      await vm.load.execute();
      vm.scan('KOP');
      vm.startPayment();
      vm.setMode(PayMode.qris);
      expect(vm.canConfirmPayments, isFalse);
      expect(vm.canConfirmQris, isFalse);
    });
  });

  group('split', () {
    setUp(() async {
      repo.qris = CashierQris(image: Uint8List.fromList(const [1]));
      await vm.load.execute();
      // 3 × Kopi Sachet = Rp 6.000.
      for (var i = 0; i < 3; i++) {
        vm.scan('KOP');
      }
      vm.startPayment();
      vm.setMode(PayMode.split);
    });

    test(
      'tambah tunai lalu QRIS sisa; QRIS menunggu sampai dikonfirmasi',
      () async {
        expect(vm.totals.total, const Money(6000));
        expect(vm.draftAmount, const Money(6000));
        expect(vm.canPay, isFalse);

        vm.setDraftAmount(const Money(2000));
        vm.addPart();
        expect(vm.parts.single.isCash, isTrue);
        expect(vm.splitSettlement.remaining, const Money(4000));
        expect(vm.draftAmount, const Money(4000));
        expect(vm.draftMethod, PaymentMethod.card); // tunai sudah ada

        vm.setDraftMethod(PaymentMethod.cash);
        expect(vm.draftError, SplitDraftError.cashExists);

        vm.setDraftMethod(PaymentMethod.qrisStatic);
        vm.setDraftAmount(const Money(5000));
        expect(vm.draftError, SplitDraftError.overRemaining);
        vm.setDraftAmount(const Money(4000));
        vm.addPart();
        expect(vm.parts.last.isPending, isTrue);
        expect(vm.splitSettlement.isSettled, isTrue);
        expect(vm.draftError, SplitDraftError.settled);
        expect(vm.hasPendingQris, isTrue);
        expect(vm.canPay, isFalse);

        vm.confirmPart(1);
        expect(vm.canPay, isTrue);
        await vm.pay.execute();
        final payments = repo.checkouts.single.$2;
        expect(payments.map((p) => p.method), [
          PaymentMethod.cash,
          PaymentMethod.qrisStatic,
        ]);
        expect(payments.map((p) => p.amount), const [Money(2000), Money(4000)]);
        expect(payments.last.confirmed, isTrue);
        expect(vm.result!.payments, hasLength(2));
      },
    );

    test('tunai lebih memberi kembalian; hapus bagian mengembalikan sisa', () {
      vm.setDraftMethod(PaymentMethod.card);
      vm.setDraftAmount(const Money(1000));
      vm.addPart();
      vm.setDraftMethod(PaymentMethod.cash);
      vm.setDraftAmount(const Money(10000));
      vm.addPart();
      expect(vm.splitSettlement.change, const Money(5000));
      expect(vm.canPay, isTrue);

      vm.removePart(0);
      expect(vm.splitSettlement.remaining, Money.zero);
      expect(vm.splitSettlement.change, const Money(4000));
      vm.removePart(0);
      expect(vm.parts, isEmpty);
      expect(vm.draftAmount, const Money(6000));
    });

    test('masuk lagi ke tahap bayar mengosongkan bagian', () {
      vm.addPart();
      vm.backToCart();
      vm.startPayment();
      expect(vm.parts, isEmpty);
      expect(vm.mode, PayMode.cash);
    });
  });
}
