import 'dart:async';

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/cashier_repository.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';
import 'package:lakuna_flutter/ui/cashier/cart_draft.dart';
import 'package:lakuna_flutter/ui/cashier/cashier_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/cashier_seed.dart';
import '../../testing/fake_cashier_repository.dart';
import '../../testing/fake_dining_repository.dart';
import '../../testing/qris_seed.dart';
import '../../testing/fake_receipt_printer.dart';
import '../../testing/fake_session_repository.dart';

void main() {
  late FakeCashierRepository repo;
  late CashierViewModel vm;
  late FakeReceiptPrinter printer;

  setUp(() async {
    repo = FakeCashierRepository(seed: cashierProducts());
    printer = FakeReceiptPrinter();
    vm = CashierViewModel(repository: repo, printer: printer);
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

  test('chip kategori mengikuti master: urutan, saklar, induk', () async {
    final cats = repo.catalog.categories;
    final sembako = cats.firstWhere((c) => c.name == 'Sembako');
    final minuman = cats.firstWhere((c) => c.name == 'Minuman');
    // Minuman jadi subkategori "Dapur" yang tampil paling depan; Sembako
    // disembunyikan dari kasir.
    final dapur = ProductCategory(
      tenantId: sembako.tenantId,
      name: 'Dapur',
      sortOrder: -1,
      hlc: '',
    );
    cats
      ..add(dapur)
      ..[cats.indexOf(minuman)] = minuman.copyWith(parentId: dapur.id)
      ..[cats.indexOf(sembako)] = sembako.copyWith(showInCashier: false);
    await vm.load.execute();
    expect(vm.categories.map((c) => c.name), ['Dapur', 'Minuman']);
    // Chip induk memuat produk subkategori.
    vm.setCategory(dapur.id);
    expect(vm.products.single.name, 'Kopi Sachet');
    // Sembako tetap dijual lewat "Semua".
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

  test('pembulatan total cabang: baris Pembulatan dan total bayar', () async {
    repo.salesRules = const SalesRules(rounding: TotalRounding.nearest100);
    await vm.load.execute();
    vm.scan('8991234500024');
    // 0,333 × 36.000 = 11.988 → 12.000.
    vm.setQuantity(0, const Qty(333));
    expect(vm.totals.total, const Money(11988));
    expect(vm.rounding, const Money(12));
    expect(vm.grandTotal, const Money(12000));
    vm.startPayment();
    expect(vm.payTotal, const Money(12000));
    expect(vm.shortBy, const Money(12000));
  });

  group('diskon manual', () {
    test('baris + nota: total, pembulatan, dan permintaan checkout', () async {
      repo.salesRules = const SalesRules(rounding: TotalRounding.nearest500);
      await vm.load.execute();
      expect(vm.discountAccess, DiscountAccess.direct);
      vm.scan('8990001'); // 72.500
      vm.scan('KOP'); // 2.000
      vm.setLineDiscount(0, const ManualDiscount.percent(BasisPoints(1000)));
      expect(vm.lines.first.discountCut, const Money(7250));
      expect(vm.lines.first.netTotal, const Money(65250));
      expect(vm.lineDiscount, const Money(7250));
      vm.setBillDiscount(const ManualDiscount.amount(Money(1000)));
      // 65.250 + 2.000 − 1.000 = 66.250 → 66.500.
      expect(vm.netTotal, const Money(66250));
      expect(vm.rounding, const Money(250));
      expect(vm.grandTotal, const Money(66500));
      vm.startPayment();
      vm.setReceived(const Money(66500));
      await vm.pay.execute();
      final (lines, _) = repo.checkouts.single;
      expect(
        lines.first.discount,
        const ManualDiscount.percent(BasisPoints(1000)),
      );
      expect(lines.last.discount, isNull);
      expect(
        repo.discounts.single,
        (const ManualDiscount.amount(Money(1000)), null),
      );
      expect(vm.result!.sale.discountAmount, 1000);
      expect(vm.billDiscount, isNull);
    });

    test('diskon rupiah dipangkas saat jumlah baris berkurang', () async {
      vm.scan('KOP');
      vm.scan('KOP'); // 2 × 2.000
      vm.setLineDiscount(0, const ManualDiscount.amount(Money(3000)));
      vm.decrement(0);
      expect(vm.lines.single.discountCut, const Money(2000));
      vm.scan('8990001');
      vm.startPayment();
      vm.setReceived(const Money(100000));
      await vm.pay.execute();
      expect(
        repo.checkouts.single.$1.first.discount,
        const ManualDiscount.amount(Money(2000)),
      );
    });

    test('galat diskon: melebihi dasar dan nota jadi nol', () {
      vm.scan('KOP');
      expect(
        vm.lineDiscountIssue(0, const ManualDiscount.amount(Money(2500))),
        DiscountIssue.tooLarge,
      );
      expect(
        vm.billDiscountIssue(const ManualDiscount.percent(BasisPoints.full)),
        DiscountIssue.tooLarge,
      );
      expect(
        vm.billDiscountIssue(const ManualDiscount.percent(BasisPoints(5000))),
        isNull,
      );
    });

    test(
      'kasir tanpa izin: butuh persetujuan, penyetuju ikut checkout',
      () async {
        repo.permissions = {Permission.salesCreate};
        await vm.load.execute();
        expect(vm.discountAccess, DiscountAccess.approval);
        expect(vm.discountNeedsApproval, isTrue);
        final rina = UuidValue.fromString(newId());
        vm.approveDiscounts((id: rina, name: 'Rina'));
        expect(vm.discountNeedsApproval, isFalse);
        vm.scan('8990001');
        vm.setBillDiscount(const ManualDiscount.percent(BasisPoints(500)));
        vm.startPayment();
        vm.setReceived(const Money(100000));
        await vm.pay.execute();
        expect(repo.discounts.single.$2, rina);
        // Keranjang baru butuh persetujuan lagi.
        expect(vm.discountNeedsApproval, isTrue);
      },
    );

    test('sakelar PIN mati: kasir tanpa izin tidak bisa diskon', () async {
      repo
        ..permissions = {Permission.salesCreate}
        ..salesRules = const SalesRules(discountNeedsPin: false);
      await vm.load.execute();
      expect(vm.discountAccess, DiscountAccess.none);
      expect(vm.canOfferDiscount, isFalse);
    });

    test('persetujuan ditolak saat bayar: PIN diminta lagi', () async {
      repo.permissions = {Permission.salesCreate};
      await vm.load.execute();
      vm.approveDiscounts((id: UuidValue.fromString(newId()), name: 'Rina'));
      vm.scan('KOP');
      vm.setBillDiscount(const ManualDiscount.amount(Money(500)));
      repo.nextError = const NotPermitted(Permission.salesDiscount);
      vm.startPayment();
      vm.setReceived(const Money(2000));
      await vm.pay.execute();
      expect(vm.error, isA<NotPermitted>());
      expect(vm.discountApprover, isNull);
      expect(vm.discountNeedsApproval, isTrue);
    });

    test('penyetuju tidak dikirim bila diskon sudah dihapus', () async {
      repo.permissions = {Permission.salesCreate};
      await vm.load.execute();
      vm.approveDiscounts((id: UuidValue.fromString(newId()), name: 'Rina'));
      vm.scan('KOP');
      vm.setBillDiscount(const ManualDiscount.amount(Money(500)));
      vm.setBillDiscount(null);
      vm.startPayment();
      vm.setReceived(const Money(2000));
      await vm.pay.execute();
      expect(repo.discounts.single, (null, null));
    });

    test('diskon yang menghabiskan total menahan bayar', () async {
      vm.scan('KOP');
      vm.scan('KOP'); // 4.000
      vm.setBillDiscount(const ManualDiscount.amount(Money(3000)));
      expect(vm.discountBlocksPay, isFalse);
      // Jumlah turun: dasar 2.000, diskon nota terpangkas → total 0.
      vm.decrement(0);
      expect(vm.grandTotal, Money.zero);
      expect(vm.discountBlocksPay, isTrue);
      vm.startPayment();
      expect(vm.stage, CashierStage.browse);
      vm.setBillDiscount(null);
      expect(vm.discountBlocksPay, isFalse);
    });

    test(
      'diskon baris ditolak bila nota jadi nol (juga setelah bulat)',
      () async {
        repo.salesRules = const SalesRules(rounding: TotalRounding.nearest500);
        await vm.load.execute();
        vm.scan('KOP'); // 2.000
        expect(
          vm.lineDiscountIssue(
            0,
            const ManualDiscount.percent(BasisPoints.full),
          ),
          DiscountIssue.tooLarge,
        );
        // 2.000 − 1.800 = 200 → dibulatkan ke 0.
        expect(
          vm.lineDiscountIssue(0, const ManualDiscount.amount(Money(1800))),
          DiscountIssue.tooLarge,
        );
        expect(
          vm.billDiscountIssue(const ManualDiscount.amount(Money(1800))),
          DiscountIssue.tooLarge,
        );
        expect(
          vm.lineDiscountIssue(0, const ManualDiscount.amount(Money(1000))),
          isNull,
        );
      },
    );

    test('kosongkan keranjang menghapus diskon dan penyetuju', () {
      vm.scan('KOP');
      vm.setBillDiscount(const ManualDiscount.amount(Money(500)));
      vm.approveDiscounts((id: UuidValue.fromString(newId()), name: 'Rina'));
      vm.clearCart();
      expect(vm.billDiscount, isNull);
      expect(vm.discountApprover, isNull);
    });
  });

  group('draf keranjang (F1-04c)', () {
    late CartDraft draft;

    setUp(
      () => draft = CartDraft(FakeSessionRepository(current: sampleStaff())),
    );
    tearDown(() => draft.dispose());

    Future<CashierViewModel> open() async {
      final next = CashierViewModel(
        repository: repo,
        printer: printer,
        draft: draft,
      );
      await next.load.execute();
      return next;
    }

    test('keranjang dan diskon dipulihkan saat kasir dibuka lagi', () async {
      final first = await open();
      first
        ..scan('8991234500024') // Minyak botol
        ..scan('8991234500031') // Minyak dus
        ..setQuantity(0, Qty.units(3))
        ..setLineDiscount(0, const ManualDiscount.amount(Money(1000)))
        ..setBillDiscount(const ManualDiscount.percent(BasisPoints(500)))
        ..startPayment()
        ..dispose();
      expect(draft.isEmpty, isFalse);

      final second = await open();
      expect(second.stage, CashierStage.browse);
      expect(second.lines.map((l) => l.unitName), ['botol', 'Dus']);
      expect(second.lines.first.quantity, Qty.units(3));
      expect(
        second.lines.first.discount,
        const ManualDiscount.amount(Money(1000)),
      );
      expect(
        second.billDiscount,
        const ManualDiscount.percent(BasisPoints(500)),
      );
      // Draf sudah diambil; view model lain tidak memulihkannya dua kali.
      expect(draft.isEmpty, isTrue);
      second.dispose();
    });

    test('penyetuju diskon ikut dipulihkan', () async {
      repo.permissions = {Permission.salesCreate};
      final first = await open();
      final rina = UuidValue.fromString(newId());
      first
        ..approveDiscounts((id: rina, name: 'Rina'))
        ..scan('8990001')
        ..dispose();
      final second = await open();
      expect(second.discountApprover?.id, rina);
      second.dispose();
    });

    test('baris yang produknya hilang dibuang', () async {
      final first = await open();
      first
        ..scan('8991234500024')
        ..scan('kop')
        ..dispose();
      repo.catalog.products.removeWhere((p) => p.name == 'Kopi Sachet');
      final second = await open();
      expect(second.lines.map((l) => l.title), ['Minyak Goreng 2 L']);
      second.dispose();
    });

    test('setelah bayar draf kosong', () async {
      final first = await open();
      first
        ..scan('8990001')
        ..startPayment()
        ..setReceived(const Money(100000));
      await first.pay.execute();
      first.dispose();
      expect(draft.isEmpty, isTrue);
    });

    test('keranjang kosong menutup draf yang sudah diambil', () async {
      final first = await open();
      first.dispose();
      expect(draft.isEmpty, isTrue);
    });

    test('layar ditutup sebelum katalog termuat: draf tetap', () async {
      final first = await open();
      first
        ..scan('kop')
        ..dispose();
      repo.nextError = Exception('lambat');
      final failed = await open();
      expect(failed.loaded, isFalse);
      failed.dispose();
      final again = await open();
      expect(again.lines.single.title, 'Kopi Sachet');
      again.dispose();
    });

    test('ditutup saat menyimpan: nota tidak kembali ke draf', () async {
      final first = await open();
      first
        ..scan('8990001')
        ..startPayment()
        ..setReceived(const Money(100000));
      final gate = repo.checkoutGate = Completer<void>();
      final paying = first.pay.execute();
      first.dispose();
      gate.complete();
      await paying;
      expect(repo.checkouts, hasLength(1));
      expect(draft.isEmpty, isTrue);
    });

    test('ditutup saat menyimpan lalu gagal: keranjang ke draf', () async {
      final first = await open();
      first
        ..scan('8990001')
        ..startPayment()
        ..setReceived(const Money(100000));
      final gate = repo.checkoutGate = Completer<void>();
      repo.nextError = Exception('disk penuh');
      final paying = first.pay.execute();
      first.dispose();
      gate.complete();
      await paying;
      expect(draft.lines, hasLength(1));
    });

    test('satuan konversi yang dihapus dibuang saat dipulihkan', () async {
      final first = await open();
      first
        ..scan('8991234500024') // botol
        ..scan('8991234500031') // Dus
        ..dispose();
      for (final v
          in repo.catalog.products
              .firstWhere((p) => p.name == 'Minyak Goreng')
              .variants) {
        v.units.clear();
      }
      final second = await open();
      expect(second.lines.map((l) => l.unitName), ['botol']);
      second.dispose();
    });
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
      // Bagian split QRIS tidak bisa dikonfirmasi, jadi tidak ditawarkan.
      expect(vm.splitMethods, isNot(contains(PaymentMethod.qrisStatic)));
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
      expect(vm.draftMethod, PaymentMethod.card); // tunai masih ada
      vm.removePart(0);
      expect(vm.draftMethod, PaymentMethod.cash);
      expect(vm.parts, isEmpty);
      expect(vm.draftAmount, const Money(6000));
    });

    test('hapus bagian menghapus galat bayar sebelumnya', () async {
      vm.addPart();
      repo.nextError = Exception('gagal');
      await vm.pay.execute();
      expect(vm.error, isNotNull);
      vm.removePart(0);
      expect(vm.error, isNull);
    });

    test('masuk lagi ke tahap bayar mengosongkan bagian', () {
      vm.addPart();
      vm.backToCart();
      vm.startPayment();
      expect(vm.parts, isEmpty);
      expect(vm.mode, PayMode.cash);
    });
  });

  group('struk', () {
    const lines = [ReceiptLine('TOKO')];
    const rpp = PrinterSelection(
      kind: PrinterKind.bluetooth,
      name: 'RPP02N',
      address: '66:22:B1:00:00:01',
    );

    Future<void> sell() async {
      vm.scan('KOP');
      vm.startPayment();
      vm.setMode(PayMode.card);
      await vm.pay.execute();
      expect(vm.stage, CashierStage.done);
    }

    test('tanpa printer: cetak lewat dialog sistem', () async {
      await sell();
      expect(vm.printer, isNull);
      expect(vm.shouldAutoPrint, isFalse);
      await vm.printReceipt.execute(lines);
      final (target, printed, paper) = printer.prints.single;
      expect(target.kind, PrinterKind.system);
      expect(printed, lines);
      expect(paper, ReceiptPaper.mm58);
      expect(vm.printed, isFalse); // dialog: tidak dianggap terkirim
    });

    test('cetak otomatis sekali per nota ke printer langsung', () async {
      repo
        ..printer = rpp
        ..receipt = const ReceiptConfig(
          settings: ReceiptSettings(
            paper: ReceiptPaper.mm80,
            autoPrint: true,
          ),
        );
      await vm.load.execute();
      await sell();
      expect(vm.shouldAutoPrint, isTrue);
      await vm.autoPrint(lines);
      await vm.autoPrint(lines);
      expect(printer.prints, hasLength(1));
      expect(printer.prints.single.$1, rpp);
      expect(printer.prints.single.$3, ReceiptPaper.mm80);
      expect(vm.printed, isTrue);
      expect(vm.shouldAutoPrint, isFalse);
    });

    test('galat cetak/PDF tidak terbawa ke nota berikutnya', () async {
      repo.printer = rpp;
      await vm.load.execute();
      await sell();
      printer.nextFailure = const PrinterFailure(
        PrinterFailureReason.connect,
      );
      await vm.printReceipt.execute(lines);
      printer.nextFailure = const PrinterFailure(PrinterFailureReason.write);
      await vm.shareReceipt.execute(lines);
      expect(vm.printReceipt.error || vm.shareReceipt.error, isTrue);
      vm.newTransaction();
      await vm.load.execute();
      await sell();
      expect(vm.printReceipt.error, isFalse);
      expect(vm.shareReceipt.error, isFalse);
      expect(vm.printFailure, isNull);
    });

    test('selama mencetak, transaksi baru ditahan; hasil cetak nota lama '
        'tidak menempel ke nota baru', () async {
      repo.printer = rpp;
      await vm.load.execute();
      await sell();
      final hold = printer.hold = Completer<void>();
      final job = vm.printReceipt.execute(lines);
      expect(vm.printing, isTrue);
      expect(vm.canStartNewTransaction, isFalse);
      vm.newTransaction(); // diabaikan selama mencetak
      expect(vm.stage, CashierStage.done);
      hold.complete();
      await job;
      expect(vm.printed, isTrue);
      expect(vm.canStartNewTransaction, isTrue);
      vm.newTransaction();
      expect(vm.stage, CashierStage.browse);
      expect(vm.printed, isFalse);
    });

    test('gagal cetak: alasan tersimpan, coba lagi berhasil', () async {
      repo.printer = rpp;
      await vm.load.execute();
      await sell();
      printer.nextFailure = const PrinterFailure(
        PrinterFailureReason.bluetoothOff,
      );
      await vm.printReceipt.execute(lines);
      expect(vm.printFailure, PrinterFailureReason.bluetoothOff);
      expect(vm.stage, CashierStage.done);
      await vm.printReceipt.execute(lines);
      expect(vm.printFailure, isNull);
      expect(vm.printed, isTrue);
    });

    test('bagikan PDF: nama berkas = nomor nota, lokasi desktop', () async {
      await sell();
      await vm.shareReceipt.execute(lines);
      final (_, _, fileName) = printer.shares.single;
      expect(fileName, '${vm.result!.sale.number}.pdf');
      expect(vm.sharedPath, printer.sharePath);
      vm.newTransaction();
      expect(vm.sharedPath, isNull);
    });
  });

  group('bagian split bill', () {
    late FakeDiningRepository dining;
    late OpenBill bill;
    var left = 0;

    Future<T> ok<T>(Future<Result<T>> f) async => switch (await f) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };

    setUp(() async {
      dining = FakeDiningRepository();
      repo
        ..dining = dining
        ..qris = sampleQris();
      left = 0;
      final kopi = dining.catalog.products
          .firstWhere((p) => p.name == 'Kopi Susu Aren')
          .variants
          .single
          .id;
      bill = await ok(dining.openTable(dining.tables.first.id, 2));
      bill = await ok(
        dining.addItem(
          bill.id,
          SaleLineRequest(variantId: kopi, quantity: Qty.units(2)),
        ),
      );
      bill = await ok(dining.setSplit(bill.id, SplitMode.equal, 2));
      vm = CashierViewModel(repository: repo, printer: printer)
        ..onLeaveBill = (() => left++);
      await vm.load.execute();
    });

    test('tagihan = bagian tamu; lunas sebagian kembali ke split', () async {
      vm.setPart(const BillPart(guest: 'A'));
      await vm.openBill.execute(bill.id);
      expect(vm.partMode, isTrue);
      expect(vm.partLabel, 'A');
      // 2 × 24.000 + service 5% + PB1 10% = 55.440, dibagi 2.
      expect(vm.payTotal, const Money(27720));
      vm.setMode(PayMode.card);
      await vm.pay.execute();
      expect(left, 1);
      expect(vm.stage, CashierStage.pay);
      expect(repo.paidParts.single.$2, 'A');

      // Tautan lama ke tamu yang sudah bayar ditolak.
      final again = CashierViewModel(repository: repo, printer: printer)
        ..setPart(const BillPart(guest: 'A'));
      await again.load.execute();
      await again.openBill.execute(bill.id);
      expect(again.openBill.result, isA<Error<OpenBill>>());
      expect(again.billMode, isFalse);
    });

    test('QRIS tunggu konfirmasi lalu tamu terakhir lunas → struk', () async {
      vm.setPart(const BillPart(guest: 'A'));
      await vm.openBill.execute(bill.id);
      vm.setMode(PayMode.qris);
      expect(vm.canWaitQris, isTrue);
      await vm.waitQris();
      expect(left, 1);
      expect(repo.paidParts.single.$5, isTrue);
      expect(
        dining.bill(bill.id).split!.part('A').status,
        SplitPartStatus.pending,
      );

      // Tamu B lunas tapi QRIS A masih menunggu: belum ada struk.
      final b = CashierViewModel(repository: repo, printer: printer)
        ..onLeaveBill = (() => left++)
        ..setPart(const BillPart(guest: 'B'));
      await b.load.execute();
      await b.openBill.execute(bill.id);
      b.setMode(PayMode.card);
      await b.pay.execute();
      expect(left, 2);
      expect(b.result, isNull);
    });

    test('nominal bebas memakai nominal tautan', () async {
      await ok(dining.setSplit(bill.id, SplitMode.amount, 2));
      vm.setPart(const BillPart(amount: Money(55440)));
      await vm.openBill.execute(bill.id);
      expect(vm.payTotal, const Money(55440));
      expect(vm.partLabel, 'A');
      vm.setMode(PayMode.card);
      await vm.pay.execute();
      expect(vm.stage, CashierStage.done);
      expect(vm.result!.payments.single.guestLabel, 'A');
      expect(repo.paidParts.single.$3, const Money(55440));
    });
  });

  group('kredit open bill F&B (F1-13b)', () {
    late FakeDiningRepository dining;
    late OpenBill bill;
    late CustomerRow ani;

    Future<T> ok<T>(Future<Result<T>> f) async => switch (await f) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };

    setUp(() async {
      dining = FakeDiningRepository();
      ani = CustomerRow(
        customer: Customer(
          id: UuidValue.fromString(newId()),
          tenantId: UuidValue.fromString(newId()),
          name: 'Toko Bu Ani',
          creditLimit: 1000000,
          createdAt: DateTime.utc(2026, 11, 1),
          hlc: '',
        ),
        groupName: null,
        termDays: 14,
        outstanding: Money.zero,
        openCount: 0,
        overdueCount: 0,
      );
      repo
        ..dining = dining
        ..creditRows = [ani];
      final kopi = dining.catalog.products
          .firstWhere((p) => p.name == 'Kopi Susu Aren')
          .variants
          .single
          .id;
      bill = await ok(dining.openTable(dining.tables.first.id, 2));
      bill = await ok(
        dining.addItem(
          bill.id,
          SaleLineRequest(variantId: kopi, quantity: Qty.units(2)),
        ),
      );
      vm = CashierViewModel(repository: repo, printer: printer);
      await vm.load.execute();
    });

    test('tutup & bayar bill sebagai kredit dengan DP', () async {
      await vm.openBill.execute(bill.id);
      expect(vm.canSellOnCredit, isTrue);
      vm.setMode(PayMode.credit);
      await Future<void>.delayed(Duration.zero);
      vm
        ..selectCreditCustomer(ani.customer.id)
        ..setCreditDown(const Money(5440));
      // Total bill 55.440 (service & PB1) → piutang 50.000.
      expect(vm.creditDebt, const Money(50000));
      expect(vm.canPay, isTrue);
      await vm.pay.execute();
      expect(vm.stage, CashierStage.done);
      expect(repo.credits.single.customerId, ani.customer.id);
      expect(repo.credits.single.downPayment, const Money(5440));
      expect(vm.result!.sale.customerName, 'Toko Bu Ani');
      expect(vm.result!.sale.paidAmount, 5440);
    });

    test('bagian split bill: kredit tidak tersedia', () async {
      bill = await ok(dining.setSplit(bill.id, SplitMode.equal, 2));
      vm.setPart(const BillPart(guest: 'A'));
      await vm.openBill.execute(bill.id);
      expect(vm.canSellOnCredit, isFalse);
    });
  });

  group('kredit / piutang (1.5b)', () {
    CustomerRow row(
      String name, {
      int limit = 0,
      int debt = 0,
      int term = 14,
    }) => CustomerRow(
      customer: Customer(
        id: UuidValue.fromString(newId()),
        tenantId: UuidValue.fromString(newId()),
        name: name,
        creditLimit: limit,
        createdAt: DateTime.utc(2026, 11, 1),
        hlc: '',
      ),
      groupName: null,
      termDays: term,
      outstanding: Money(debt),
      openCount: debt > 0 ? 1 : 0,
      overdueCount: 0,
    );

    late CustomerRow ani;
    late CustomerRow darto;

    setUp(() {
      ani = row('Toko Bu Ani', limit: 200000, debt: 100000);
      darto = row('Pak Darto');
      repo.creditRows = [darto, ani];
    });

    test('pilih pelanggan → jatuh tempo + DP → nota piutang', () async {
      vm.scan('8990001'); // 72.500
      vm.startPayment();
      expect(vm.canSellOnCredit, isTrue);
      vm.setMode(PayMode.credit);
      await Future<void>.delayed(Duration.zero);
      expect(vm.creditCandidates.first.customer.name, 'Toko Bu Ani');
      expect(vm.canPay, isFalse);
      vm.selectCreditCustomer(ani.customer.id);
      expect(vm.creditDue, DateTime.utc(2026, 11, 17));
      vm.setCreditDown(const Money(10000));
      expect(vm.creditDebt, const Money(62500));
      expect(vm.creditRemainingAfter, const Money(37500));
      expect(vm.canPay, isTrue);
      await vm.pay.execute();
      expect(vm.stage, CashierStage.done);
      expect(repo.credits.single.customerId, ani.customer.id);
      expect(repo.credits.single.downPayment, const Money(10000));
      // DP tercatat sebagai tunai, sisanya piutang.
      expect(repo.checkouts.single.$2.single.amount, const Money(10000));
    });

    test('limit 0 atau melebihi limit tidak bisa disimpan', () async {
      vm.scan('8990001');
      vm.scan('8990001'); // 145.000 > sisa limit 100.000
      vm.startPayment();
      vm.setMode(PayMode.credit);
      await Future<void>.delayed(Duration.zero);
      vm.selectCreditCustomer(darto.customer.id);
      expect(vm.creditIssueNow, CreditIssue.noLimit);
      expect(vm.canPay, isFalse);
      vm.selectCreditCustomer(ani.customer.id);
      expect(vm.creditIssueNow, CreditIssue.overLimit);
      expect(vm.canPay, isFalse);
      vm.setCreditDown(const Money(50000));
      expect(vm.creditIssueNow, isNull);
      expect(vm.canPay, isTrue);
    });

    test('tanpa debts:manage tombol kredit tidak ada', () async {
      final r = FakeCashierRepository(
        seed: cashierProducts(),
        permissions: {Permission.salesCreate},
      );
      final v = CashierViewModel(repository: r, printer: printer);
      await v.load.execute();
      expect(v.canSellOnCredit, isFalse);
      v.setMode(PayMode.credit);
      expect(v.mode, isNot(PayMode.credit));
    });
  });

  group('pelanggan & nota tersimpan (F1-04d)', () {
    CustomerRow row(String name, {int limit = 0}) => CustomerRow(
      customer: Customer(
        id: UuidValue.fromString(newId()),
        tenantId: UuidValue.fromString(newId()),
        name: name,
        phone: '081322221010',
        creditLimit: limit,
        createdAt: DateTime.utc(2026, 11, 1),
        hlc: '',
      ),
      groupName: 'Grosir',
      termDays: 14,
      outstanding: Money.zero,
      openCount: 0,
      overdueCount: 0,
    );

    late CustomerRow budi;

    setUp(() {
      budi = row('Pak Budi', limit: 500000);
      repo.creditRows = [budi, row('Ani Lestari')];
    });

    test('pilih pelanggan: tampil di kepala dan ikut checkout tunai', () async {
      await vm.customers.execute();
      expect(vm.customerCandidates, hasLength(2));
      vm.setCustomerQuery('ani');
      expect(vm.customerCandidates.single.customer.name, 'Ani Lestari');
      vm.setCustomerQuery('0813');
      expect(vm.customerCandidates, hasLength(2));
      vm.selectCustomer(budi);
      expect(vm.customer?.name, 'Pak Budi');
      vm
        ..scan('8990001')
        ..startPayment()
        ..setReceived(const Money(100000));
      await vm.pay.execute();
      expect(repo.checkoutCustomers.single, budi.customer.id);
      expect(vm.result!.sale.customerName, 'Pak Budi');
      // Nota berikutnya kembali ke pelanggan umum.
      vm.newTransaction();
      expect(vm.customer, isNull);
    });

    test('pelanggan baru dari pemilih langsung terpasang (F1-04f)', () async {
      expect(vm.canAddCustomer, isTrue);
      await vm.customers.execute();
      vm.setCustomerQuery('Siti');
      final siti = row('Siti Aminah');
      repo.creditRows = [...repo.creditRows, siti];
      await vm.useNewCustomer(siti.customer);
      expect(vm.customer?.id, siti.customer.id);
      expect(vm.customer?.name, 'Siti Aminah');
      expect(vm.customerQuery, isEmpty);
      // Daftar dimuat ulang agar pelanggan baru ikut tampil.
      expect(vm.customerList!.rows, hasLength(3));
    });

    test(
      'pelanggan baru dari panel kredit langsung terpilih (F1-04f)',
      () async {
        vm
          ..scan('8990001')
          ..startPayment()
          ..setMode(PayMode.credit);
        await Future<void>.delayed(Duration.zero);
        final siti = row('Siti Aminah', limit: 300000);
        repo.creditRows = [...repo.creditRows, siti];
        await vm.useNewCreditCustomer(siti.customer);
        expect(vm.creditCustomer?.customer.id, siti.customer.id);
        expect(vm.customer?.name, 'Siti Aminah');
        // Jatuh tempo dari tempo grup (14 hari).
        expect(vm.creditDue, vm.creditToday.add(const Duration(days: 14)));
      },
    );

    test('muat ulang kredit gagal: nota tidak berubah, galat tampil', () async {
      vm
        ..selectCustomer(budi)
        ..scan('8990001')
        ..startPayment()
        ..setMode(PayMode.credit);
      await Future<void>.delayed(Duration.zero);
      final siti = row('Siti Aminah', limit: 300000);
      repo.nextError = Exception('disk');
      await vm.useNewCreditCustomer(siti.customer);
      expect(vm.customer?.id, budi.customer.id);
      expect(vm.creditCustomers, isNull);
      expect(vm.loadCredit.error, isTrue);
    });

    test('tanpa customers:manage tombol pelanggan baru tidak ada', () async {
      repo.permissions = {Permission.salesCreate, Permission.debtsManage};
      await vm.load.execute();
      expect(vm.canAddCustomer, isFalse);
    });

    test('mode kredit memakai pelanggan terpilih', () async {
      vm
        ..selectCustomer(budi)
        ..scan('8990001')
        ..startPayment()
        ..setMode(PayMode.credit);
      await Future<void>.delayed(Duration.zero);
      expect(vm.creditCustomer?.customer.id, budi.customer.id);
      // Memilih pelanggan kredit lain mengganti pelanggan nota.
      final ani = repo.creditRows.last;
      vm.selectCreditCustomer(ani.customer.id);
      expect(vm.customer?.id, ani.customer.id);
    });

    test('kosongkan keranjang kembali ke pelanggan umum', () {
      vm
        ..selectCustomer(budi)
        ..scan('8990001')
        ..clearCart();
      expect(vm.customer, isNull);
    });

    test('simpan nota → keranjang kosong, daftar bertambah', () async {
      await vm.parked.execute();
      expect(vm.parkedRows, isEmpty);
      vm
        ..selectCustomer(budi)
        ..scan('8990001')
        ..scan('kop')
        ..setBillDiscount(const ManualDiscount.amount(Money(500)));
      expect(vm.canPark, isTrue);
      await vm.park.execute(null);
      expect(vm.park.error, isFalse);
      expect(vm.cartIsEmpty, isTrue);
      expect(vm.customer, isNull);
      expect(vm.billDiscount, isNull);
      expect(vm.parkedRows.single.title, 'Pak Budi');
      expect(
        repo.parked.single.discount,
        const ManualDiscount.amount(Money(500)),
      );
      expect(repo.parked.single.lines, hasLength(2));
    });

    test('lanjutkan nota → keranjang terisi, checkout menghapusnya', () async {
      vm
        ..selectCustomer(budi)
        ..scan('8991234500031') // Dus
        ..setQuantity(0, Qty.units(2));
      await vm.park.execute('Meja depan');
      final id = vm.parkedRows.single.id;
      expect(vm.canResume, isTrue);
      await vm.resumeParked.execute(id);
      expect(vm.resumeParked.error, isFalse);
      expect(vm.lines.single.unitName, 'Dus');
      expect(vm.lines.single.quantity, Qty.units(2));
      expect(vm.customer?.name, 'Pak Budi');
      expect(vm.parkedId, id);
      // Keranjang tidak kosong: nota lain tidak bisa dilanjutkan.
      expect(vm.canResume, isFalse);

      vm
        ..startPayment()
        ..setReceived(const Money(500000));
      await vm.pay.execute();
      expect(repo.checkoutParked.single, id);
      expect(repo.parked, isEmpty);
      expect(vm.parkedRows, isEmpty);
      expect(vm.parkedId, isNull);
    });

    test('simpan ulang nota yang dilanjutkan menggantikannya', () async {
      vm.scan('8990001');
      await vm.park.execute('A');
      await vm.resumeParked.execute(vm.parkedRows.single.id);
      expect(vm.parkedNote, 'A');
      vm.scan('kop');
      await vm.park.execute('A');
      expect(repo.parked, hasLength(1));
      expect(repo.parked.single.lines, hasLength(2));
      expect(vm.parkedNote, isNull);
    });

    test('baris yang produknya hilang dibuang saat dilanjutkan', () async {
      vm
        ..scan('8990001')
        ..scan('kop');
      await vm.park.execute(null);
      repo.catalog.products.removeWhere((p) => p.name == 'Kopi Sachet');
      await vm.load.execute();
      await vm.resumeParked.execute(vm.parkedRows.single.id);
      expect(vm.lines.single.title, startsWith('Beras Premium'));
      expect(vm.resumeDropped, 1);
      // Pesan hilang setelah keranjang dikosongkan.
      vm.clearCart();
      expect(vm.resumeDropped, 0);
    });

    test('hapus nota tersimpan', () async {
      vm.scan('8990001');
      await vm.park.execute(null);
      await vm.deleteParked.execute(vm.parkedRows.single.id);
      expect(vm.parkedRows, isEmpty);
      expect(repo.parked, isEmpty);
    });

    test('baris terakhir dihapus: nota asal dan pelanggannya lepas', () async {
      vm
        ..selectCustomer(budi)
        ..scan('8990001');
      await vm.park.execute(null);
      final id = vm.parkedRows.single.id;
      await vm.resumeParked.execute(id);
      expect(vm.parkedId, id);
      vm.remove(0);
      expect(vm.parkedId, isNull);
      expect(vm.customer, isNull);
      // Penjualan berikutnya tidak menghapus nota Budi.
      vm
        ..scan('kop')
        ..startPayment()
        ..setReceived(const Money(100000));
      await vm.pay.execute();
      expect(repo.checkoutParked.single, isNull);
      expect(repo.checkoutCustomers.single, isNull);
      expect(repo.parked, hasLength(1));
    });

    test('pelanggan dipilih lalu baris dihapus: pelanggan tetap', () {
      vm
        ..selectCustomer(budi)
        ..scan('8990001')
        ..remove(0);
      expect(vm.customer?.id, budi.customer.id);
    });

    test(
      'nota asal hilang saat bayar: pesan khusus, bayar ulang biasa',
      () async {
        vm.scan('8990001');
        await vm.park.execute(null);
        await vm.resumeParked.execute(vm.parkedRows.single.id);
        repo.parked.clear();
        vm
          ..startPayment()
          ..setReceived(const Money(100000));
        await vm.pay.execute();
        expect(vm.error, isA<ParkedSaleNotFound>());
        expect(vm.parkedId, isNull);
        await vm.pay.execute();
        expect(vm.stage, CashierStage.done);
        expect(repo.checkoutParked.last, isNull);
      },
    );

    test('diskon nota tersimpan: kasir tanpa izin diminta PIN', () async {
      vm
        ..scan('8990001')
        ..setBillDiscount(const ManualDiscount.percent(BasisPoints(500)));
      await vm.park.execute(null);
      repo.permissions = {Permission.salesCreate};
      await vm.load.execute();
      await vm.resumeParked.execute(vm.parkedRows.single.id);
      expect(vm.billDiscount, isNotNull);
      expect(vm.discountAwaitsApproval, isTrue);
      vm.approveDiscounts((id: UuidValue.fromString(newId()), name: 'Rina'));
      expect(vm.discountAwaitsApproval, isFalse);
    });

    test(
      'diskon nota tersimpan dilepas bila staf tidak boleh diskon',
      () async {
        vm.scan('8990001');
        vm
          ..setLineDiscount(0, const ManualDiscount.amount(Money(1000)))
          ..setBillDiscount(const ManualDiscount.percent(BasisPoints(500)));
        await vm.park.execute(null);
        repo
          ..permissions = {Permission.salesCreate}
          ..salesRules = const SalesRules(discountNeedsPin: false);
        await vm.load.execute();
        await vm.resumeParked.execute(vm.parkedRows.single.id);
        expect(vm.hasDiscount, isFalse);
        expect(vm.resumeDiscountDropped, isTrue);
        expect(vm.discountAwaitsApproval, isFalse);
        vm.clearCart();
        expect(vm.resumeDiscountDropped, isFalse);
      },
    );

    test('keranjang kosong tidak bisa disimpan', () {
      expect(vm.canPark, isFalse); // keranjang kosong
    });

    test('draf keranjang membawa pelanggan dan nota asal', () async {
      final draft = CartDraft(FakeSessionRepository(current: sampleStaff()));
      final first = CashierViewModel(
        repository: repo,
        printer: printer,
        draft: draft,
      );
      await first.load.execute();
      first.scan('8990001');
      await first.park.execute(null);
      await first.resumeParked.execute(first.parkedRows.single.id);
      first
        ..selectCustomer(budi)
        ..dispose();
      final second = CashierViewModel(
        repository: repo,
        printer: printer,
        draft: draft,
      );
      await second.load.execute();
      expect(second.customer?.id, budi.customer.id);
      expect(second.parkedId, repo.parked.single.id);
      second.dispose();
      draft.dispose();
    });

    group('harga grosir grup pelanggan (F1-07c)', () {
      late UuidValue reseller;
      late CustomerRow ani;

      setUp(() async {
        reseller = UuidValue.fromString(newId());
        repo = FakeCashierRepository(
          seed: cashierProducts(resellerGroupId: reseller.uuid),
        );
        ani = row('Toko Ani');
        ani = CustomerRow(
          customer: ani.customer.copyWith(customerGroupId: reseller),
          groupName: 'Reseller',
          termDays: 14,
          outstanding: Money.zero,
          openCount: 0,
          overdueCount: 0,
        );
        repo.creditRows = [budi, ani];
        vm = CashierViewModel(repository: repo, printer: printer);
        await vm.load.execute();
      });

      test('harga berubah saat pelanggan grup dipilih dan dihapus', () async {
        vm
          ..scan('8991234500024')
          ..setQuantity(0, Qty.units(2));
        expect(vm.totals.total, const Money(72000));
        vm.selectCustomer(ani);
        expect(vm.customer?.groupId, reseller);
        expect(vm.lines.single.priced.unitPrice, const Money(35500));
        expect(vm.totals.total, const Money(71000));
        // Tingkat umum lebih murah tetap menang.
        vm.setQuantity(0, Qty.units(6));
        expect(vm.lines.single.priced.unitPrice, const Money(35000));
        vm.setQuantity(0, Qty.units(2));
        vm.selectCustomer(budi);
        expect(vm.totals.total, const Money(72000));
        vm.selectCustomer(ani);
        vm.clearCustomer();
        expect(vm.totals.total, const Money(72000));
      });

      test('checkout dan nota tersimpan memakai harga grup', () async {
        vm
          ..selectCustomer(ani)
          ..scan('8991234500024');
        await vm.park.execute(null);
        expect(repo.parked.single.customerGroupId, reseller);
        await vm.resumeParked.execute(vm.parkedRows.single.id);
        expect(vm.customer?.groupId, reseller);
        expect(vm.totals.total, const Money(35500));
        vm
          ..startPayment()
          ..setReceived(const Money(50000));
        await vm.pay.execute();
        expect(vm.result!.sale.total, 35500);
      });

      test('draf memakai grup pelanggan terbaru saat dipulihkan', () async {
        final draft = CartDraft(FakeSessionRepository(current: sampleStaff()));
        final first = CashierViewModel(
          repository: repo,
          printer: printer,
          draft: draft,
        );
        await first.load.execute();
        first
          ..selectCustomer(ani)
          ..scan('8991234500024');
        expect(first.totals.total, const Money(35500));
        first.dispose();
        // Ani dikeluarkan dari grup Reseller di menu Pelanggan.
        repo.creditRows = [
          budi,
          CustomerRow(
            customer: ani.customer.copyWith(customerGroupId: null),
            groupName: null,
            termDays: 0,
            outstanding: Money.zero,
            openCount: 0,
            overdueCount: 0,
          ),
        ];
        final second = CashierViewModel(
          repository: repo,
          printer: printer,
          draft: draft,
        );
        await second.load.execute();
        expect(second.customer?.id, ani.customer.id);
        expect(second.customer?.groupId, isNull);
        expect(second.totals.total, const Money(36000));
        second.dispose();
        draft.dispose();
      });

      test('pelanggan baru dan pelanggan kredit membawa grupnya', () async {
        vm.scan('8991234500024');
        await vm.useNewCustomer(ani.customer);
        expect(vm.totals.total, const Money(35500));
        vm.clearCustomer();
        await vm.loadCredit.execute();
        vm.selectCreditCustomer(ani.customer.id);
        expect(vm.customer?.groupId, reseller);
        expect(vm.totals.total, const Money(35500));
      });
    });
  });
}
