import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/customers_repository.dart'
    show NotPermitted;
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:lakuna_flutter/ui/customers/customer_form_view_model.dart';
import 'package:lakuna_flutter/ui/customers/customer_panel_view_model.dart';
import 'package:lakuna_flutter/ui/customers/customers_view_model.dart';
import 'package:lakuna_flutter/ui/customers/kuitansi_content.dart';
import 'package:lakuna_flutter/ui/customers/kuitansi_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_customers_repository.dart';
import '../../testing/fake_receipt_printer.dart';

void main() {
  late FakeCustomersRepository repo;
  final id = lookupAppLocalizations(const Locale('id'));

  setUp(() => repo = FakeCustomersRepository());

  UuidValue idOf(String name) =>
      repo.customers.firstWhere((c) => c.name == name).id;

  group('CustomersViewModel', () {
    test('memuat, menyaring nama/HP, dan memilih', () async {
      final vm = CustomersViewModel(repository: repo);
      await vm.load.execute();
      expect(vm.rows, hasLength(4));
      expect(vm.canManage, isTrue);
      vm.setQuery('0857');
      expect(vm.rows.single.customer.name, 'Kantin SD 2');
      vm.setQuery('sri');
      expect(vm.rows.single.customer.name, 'Warung Mbak Sri');
      vm.select(idOf('Warung Mbak Sri'));
      expect(vm.selected, idOf('Warung Mbak Sri'));
    });

    test('tanpa izin → galat NotPermitted', () async {
      repo
        ..canManage = false
        ..canReceive = false;
      final vm = CustomersViewModel(repository: repo);
      await vm.load.execute();
      expect(vm.error, isA<NotPermitted>());
    });
  });

  group('CustomerPanelViewModel', () {
    late CustomerPanelViewModel vm;

    setUp(() async {
      vm = CustomerPanelViewModel(
        repository: repo,
        customerId: idOf('Toko Bu Ani'),
      );
      await vm.load.execute();
    });

    test('alokasi otomatis nota terlama dulu, sisa setelah bayar', () {
      final open = vm.detail!.open;
      expect(open, hasLength(3));
      vm.setAmount(const Money(650000));
      expect(vm.allocations, {
        open[0].sale.id: const Money(500000),
        open[1].sale.id: const Money(150000),
      });
      expect(vm.balanceAfter, const Money(500000));
      expect(vm.canSubmit, isTrue);
    });

    test('lebih dari piutang → galat, tidak bisa disimpan', () {
      vm.setAmount(const Money(2000000));
      expect(vm.issue, DebtPaymentIssue.overOutstanding);
      expect(vm.canSubmit, isFalse);
    });

    test(
      'simpan benar-benar memanggil repositori lalu mengosongkan isian',
      () async {
        vm.payAll();
        expect(vm.amount, const Money(1150000));
        final gen = vm.generation;
        await vm.receive.execute();
        expect(vm.receive.result, isA<Ok<DebtPayment>>());
        expect(repo.requests.single.amount, const Money(1150000));
        expect(vm.amount, Money.zero);
        expect(vm.generation, greaterThan(gen));
        expect(vm.detail!.open, isEmpty);
        expect(vm.detail!.payments, hasLength(1));
      },
    );

    test('manual: total alokasi harus sama dengan jumlah', () async {
      final open = vm.detail!.open;
      vm
        ..setAmount(const Money(300000))
        ..setManual(true);
      // Diisi awal dengan alokasi otomatis.
      expect(vm.allocations, {open[0].sale.id: const Money(300000)});
      vm
        ..setAllocation(open[0].sale.id, const Money(100000))
        ..setAllocation(open[2].sale.id, const Money(100000));
      expect(vm.canSubmit, isFalse);
      await vm.receive.execute();
      expect(vm.receive.result, isA<Error<DebtPayment>>());
      expect(repo.requests, isEmpty);
      vm.setAllocation(open[2].sale.id, const Money(200000));
      await vm.receive.execute();
      expect(repo.requests.single.allocations, {
        open[0].sale.id: const Money(100000),
        open[2].sale.id: const Money(200000),
      });
    });

    test('tanpa debts:manage tidak bisa menerima pembayaran', () async {
      repo.canReceive = false;
      final ro = CustomerPanelViewModel(
        repository: repo,
        customerId: idOf('Toko Bu Ani'),
      );
      await ro.load.execute();
      ro.setAmount(const Money(100000));
      expect(ro.canReceive, isFalse);
      expect(ro.canSubmit, isFalse);
    });

    test('hapus pelanggan berpiutang ditolak', () async {
      await vm.delete.execute();
      expect(vm.delete.result, isA<Error<void>>());
      expect(
        (vm.delete.result! as Error<void>).error,
        isA<CustomerHasDebt>(),
      );
    });
  });

  group('CustomerFormViewModel', () {
    test('nama wajib; grup baru wajib diberi nama', () async {
      final vm = CustomerFormViewModel(repository: repo);
      await vm.load.execute();
      expect(vm.groups, hasLength(2));
      await vm.save.execute();
      expect(vm.issues, contains(CustomerIssue.name));
      vm
        ..setName('Bu Wati')
        ..setGroup(customerNewGroupKey);
      await vm.save.execute();
      expect(vm.issues, contains(CustomerIssue.group));
      vm
        ..setNewGroup('Langganan')
        ..setPhone('0813-1111-2222')
        ..setCreditLimit(const Money(500000));
      await vm.save.execute();
      final saved = (vm.save.result! as Ok<Customer>).value;
      expect(saved.phone, '081311112222');
      expect(saved.creditLimit, 500000);
      expect(repo.groupList.map((g) => g.name), contains('Langganan'));
    });

    test('ubah: isian awal dari pelanggan, HP ganda ditolak', () async {
      final ani = repo.customers.firstWhere((c) => c.name == 'Toko Bu Ani');
      final vm = CustomerFormViewModel(repository: repo, customer: ani);
      await vm.load.execute();
      expect(vm.isEdit, isTrue);
      expect(vm.name, 'Toko Bu Ani');
      vm.setPhone('085711112020'); // milik Kantin SD 2
      await vm.save.execute();
      expect(
        (vm.save.result! as Error<Customer>).error,
        isA<CustomerPhoneTaken>(),
      );
    });
  });

  group('Kuitansi', () {
    late DebtPayment payment;

    setUp(() async {
      final r = await repo.receivePayment(
        DebtPaymentRequest(
          customerId: idOf('Toko Bu Ani'),
          amount: const Money(650000),
          method: PaymentMethod.cash,
          paidOn: DateTime.utc(2026, 11, 3),
        ),
      );
      payment = (r as Ok<DebtPayment>).value;
    });

    test('isi A5: terbilang, rincian nota, kota & tanggal, salinan', () async {
      final vm = KuitansiViewModel(
        repository: repo,
        printer: FakeReceiptPrinter(),
        paymentId: payment.id,
        copy: true,
      );
      await vm.load.execute();
      vm.setCity('Bandung');
      final doc = kuitansiDocument(
        id,
        receipt: vm.receipt!,
        setup: vm.setup!,
        copy: vm.copy,
        showDetails: vm.showDetails,
        showBalance: vm.showBalance,
        city: vm.city,
      );
      expect(doc.number, payment.number);
      expect(doc.banner, isNotNull);
      expect(
        doc.fields.map((f) => f.value),
        contains('Enam ratus lima puluh ribu rupiah'),
      );
      expect(doc.tableRows, hasLength(2));
      expect(doc.placeDate, startsWith('Bandung, '));
      expect(doc.footnote, isNotNull);

      vm
        ..setShowDetails(false)
        ..setShowBalance(false);
      final short = kuitansiDocument(
        id,
        receipt: vm.receipt!,
        setup: vm.setup!,
        copy: false,
        showDetails: vm.showDetails,
        showBalance: vm.showBalance,
        city: '',
      );
      expect(short.tableRows, isEmpty);
      expect(short.footnote, isNull);
      expect(short.banner, isNull);
    });

    test('isi thermal: nomor BP di baris meta', () async {
      final printer = FakeReceiptPrinter();
      final vm = KuitansiViewModel(
        repository: repo,
        printer: printer,
        paymentId: payment.id,
      );
      await vm.load.execute();
      vm.setFormat(KuitansiFormat.thermal);
      final content = kuitansiReceiptContent(
        id,
        receipt: vm.receipt!,
        setup: vm.setup!,
        copy: false,
        showDetails: true,
        showBalance: true,
      );
      expect(content.meta.first.value, payment.number);
    });

    test('pembayaran tidak ada → galat', () async {
      final vm = KuitansiViewModel(
        repository: repo,
        printer: FakeReceiptPrinter(),
        paymentId: UuidValue.fromString(newId()),
      );
      await vm.load.execute();
      expect(vm.error, isA<DebtPaymentNotFound>());
    });
  });
}
