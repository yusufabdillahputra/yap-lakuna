import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/expenses_repository.dart';
import 'package:lakuna_flutter/data/services/image_file_picker.dart';
import 'package:lakuna_flutter/ui/expenses/expense_categories_view_model.dart';
import 'package:lakuna_flutter/ui/expenses/expense_detail_view_model.dart';
import 'package:lakuna_flutter/ui/expenses/expense_form_view_model.dart';
import 'package:lakuna_flutter/ui/expenses/expenses_view_model.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/fake_expenses_repository.dart';
import '../../testing/fake_payment_settings_repository.dart'
    show FakeImagePicker;
import '../../testing/fake_spreadsheet_exporter.dart';
import '../../testing/qris_seed.dart';

void main() {
  late FakeExpensesRepository repo;

  setUp(() => repo = FakeExpensesRepository());

  Future<ExpensesSetup> setup() async =>
      ((await repo.load()) as Ok<ExpensesSetup>).value;

  group('ExpensesViewModel', () {
    test('memuat 30 hari terakhir, ringkasan per jenis, dan cari', () async {
      final vm = ExpensesViewModel(repository: repo);
      await vm.load.execute();
      expect(vm.rows, hasLength(5));
      // Terbaru dulu.
      expect(vm.rows!.first.expense.description, 'Beli es batu');
      final (total, by) = vm.summary;
      expect(total, const Money(3250000));
      expect(by.first.name, 'Sewa tempat');
      vm.setQuery('LISTRIK');
      expect(vm.rows!.single.expense.description, 'Token listrik');
      vm.setQuery('kemasan');
      expect(vm.rows!.single.categoryName, 'Plastik & kemasan');
      vm.setQuery('EX-PST-K01-261030');
      expect(vm.rows!.single.expense.description, 'Sewa tempat November');
      // Ringkasan tetap untuk seluruh periode.
      expect(vm.summary.$1, const Money(3250000));
    });

    test('periode bulan ini dan bulan lalu', () async {
      final vm = ExpensesViewModel(repository: repo);
      await vm.load.execute();
      await vm.setPeriod(ExpensePeriod.thisMonth);
      expect(vm.rows, hasLength(3));
      await vm.setPeriod(ExpensePeriod.lastMonth);
      expect(vm.rows!.map((r) => r.expense.description), [
        'Plastik kresek & cup',
        'Sewa tempat November',
      ]);
      expect(vm.exportFileName(), 'pengeluaran-bulan-lalu-261104.xlsx');
    });

    test('pengeluaran batal tidak dihitung', () async {
      final e = repo.byDescription('Token listrik');
      await repo.cancel(e.id, 'Salah catat');
      final vm = ExpensesViewModel(repository: repo);
      await vm.load.execute();
      expect(vm.rows, hasLength(5));
      expect(vm.summary.$1, const Money(2750000));
    });

    test('galat muat tampil', () async {
      repo.canManage = false;
      final vm = ExpensesViewModel(repository: repo);
      await vm.load.execute();
      expect(vm.error, isA<NotPermitted>());
      expect(vm.rows, isNull);
    });

    test('ekspor menyimpan berkas', () async {
      final exporter = FakeSpreadsheetExporter();
      final vm = ExpensesViewModel(repository: repo, exporter: exporter);
      await vm.load.execute();
      await vm.export.execute(Uint8List.fromList([1, 2]));
      expect(exporter.saved.single.$1, 'pengeluaran-30-hari-261104.xlsx');
      expect(vm.exportPath, exporter.path);
    });
  });

  group('ExpenseFormViewModel', () {
    test('bawaan kas laci bila sesi terbuka, kas toko bila tidak', () async {
      final vm = ExpenseFormViewModel(repository: repo, setup: await setup());
      expect(vm.funding, FundingSource.drawer);
      expect(vm.drawerIssue, isNull);
      repo.hasOpenSession = false;
      final closed = ExpenseFormViewModel(
        repository: repo,
        setup: await setup(),
      );
      expect(closed.funding, FundingSource.storeCash);
      closed.setFunding(FundingSource.drawer);
      expect(closed.drawerIssue, ExpenseDrawerIssue.noSession);
      repo.canUseDrawer = false;
      closed.updateSetup(await setup());
      expect(closed.drawerIssue, ExpenseDrawerIssue.notPermitted);
    });

    test('galat isian baru tampil setelah mencoba menyimpan', () async {
      final vm = ExpenseFormViewModel(repository: repo, setup: await setup());
      expect(vm.issues, isEmpty);
      expect(vm.canSubmit, isFalse);
      await vm.save.execute();
      expect(vm.save.result, isA<Error<Expense>>());
      expect(vm.issues, {
        ExpenseIssue.description,
        ExpenseIssue.category,
        ExpenseIssue.amount,
      });
      expect(repo.requests, isEmpty);
    });

    test('tanggal masa depan dan laci mundur ditolak', () async {
      final vm = ExpenseFormViewModel(repository: repo, setup: await setup())
        ..setSpentOn(DateTime(2026, 11, 5));
      expect(vm.dateInFuture, isTrue);
      vm.setSpentOn(DateTime(2026, 11, 3));
      expect(vm.dateInFuture, isFalse);
      expect(vm.drawerIssue, ExpenseDrawerIssue.notToday);
      vm.setFunding(FundingSource.bank);
      expect(vm.drawerIssue, isNull);
    });

    test('simpan dengan foto, lalu isian dikosongkan', () async {
      final picker = FakeImagePicker()
        ..next = PickedImage(
          name: 'nota.png',
          size: tinyPortraitPng.length,
          bytes: tinyPortraitPng,
        );
      final vm =
          ExpenseFormViewModel(
              repository: repo,
              setup: await setup(),
              picker: picker,
            )
            ..setDescription('  Galon air  ')
            ..setCategory(repo.categoryByName('Bahan habis pakai').id)
            ..setAmount(const Money(25000));
      await vm.pickReceipt.execute(false);
      expect(vm.receipt?.fileName, 'nota.png');
      expect(vm.canSubmit, isTrue);
      final gen = vm.generation;
      await vm.save.execute();
      expect(vm.save.result, isA<Ok<Expense>>());
      final saved = repo.expenses.last;
      expect(saved.description, 'Galon air');
      expect(saved.fundingSource, FundingSource.drawer);
      expect(saved.spentOn, DateTime.utc(2026, 11, 4));
      expect(repo.receipts[saved.id], tinyPortraitPng);
      expect(vm.description, isEmpty);
      expect(vm.amount, Money.zero);
      expect(vm.receipt, isNull);
      expect(vm.generation, gen + 1);
      // Jenis dipertahankan untuk catatan berikutnya.
      expect(vm.categoryId, repo.categoryByName('Bahan habis pakai').id);
    });

    test('foto nota 12 MB diterima (dikecilkan saat disimpan)', () async {
      final big = Uint8List(12 * 1024 * 1024)..setAll(0, tinyPortraitPng);
      final picker = FakeImagePicker()
        ..next = PickedImage(name: 'nota.jpg', size: big.length, bytes: big);
      final vm = ExpenseFormViewModel(
        repository: repo,
        setup: await setup(),
        picker: picker,
      );
      await vm.pickReceipt.execute(false);
      expect(vm.receiptRejected, isFalse);
      expect(vm.receipt!.bytes.length, big.length);
    });

    test('foto bukan gambar ditolak', () async {
      final picker = FakeImagePicker()
        ..next = PickedImage(
          name: 'nota.txt',
          size: 3,
          bytes: Uint8List.fromList([1, 2, 3]),
        );
      final vm = ExpenseFormViewModel(
        repository: repo,
        setup: await setup(),
        picker: picker,
      );
      await vm.pickReceipt.execute(false);
      expect(vm.receiptRejected, isTrue);
      expect(vm.receipt, isNull);
    });

    test('jenis yang hilang dari setup dikosongkan', () async {
      final vm = ExpenseFormViewModel(repository: repo, setup: await setup())
        ..setCategory(repo.categoryByName('Transport').id);
      repo.categoryList.removeWhere((c) => c.name == 'Transport');
      vm.updateSetup(await setup());
      expect(vm.categoryId, isNull);
    });
  });

  group('ExpenseDetailViewModel', () {
    test('memuat rincian + foto lalu membatalkan dengan alasan', () async {
      final e = repo.byDescription('Token listrik');
      repo.receipts[e.id] = tinyPortraitPng;
      final vm = ExpenseDetailViewModel(repository: repo, expenseId: e.id);
      await vm.load.execute();
      expect(vm.row?.categoryName, 'Listrik & air');
      expect(vm.receipt, tinyPortraitPng);
      expect(vm.canCancel, isTrue);
      vm.startCancel();
      expect(vm.confirming, isTrue);
      await vm.cancel.execute();
      expect(vm.reasonInvalid, isTrue);
      expect(repo.byDescription('Token listrik').voidedAt, isNull);
      vm.setReason('Dobel input');
      await vm.cancel.execute();
      expect(vm.cancel.result, isA<Ok<Expense>>());
      expect(vm.confirming, isFalse);
      expect(vm.row!.voided, isTrue);
      expect(vm.row!.expense.voidReason, 'Dobel input');
      expect(vm.canCancel, isFalse);
    });

    test('pengeluaran laci tidak bisa dibatalkan tanpa izin laci', () async {
      final drawer = repo.byDescription('Beli es batu');
      final vm = ExpenseDetailViewModel(
        repository: repo,
        expenseId: drawer.id,
        canUseDrawer: false,
      );
      await vm.load.execute();
      expect(vm.canCancel, isFalse);
      final bank = ExpenseDetailViewModel(
        repository: repo,
        expenseId: repo.byDescription('Token listrik').id,
        canUseDrawer: false,
      );
      await bank.load.execute();
      expect(bank.canCancel, isTrue);
    });

    test('batal laci tanpa sesi terbuka gagal', () async {
      repo.hasOpenSession = false;
      final e = repo.byDescription('Beli es batu');
      final vm = ExpenseDetailViewModel(repository: repo, expenseId: e.id);
      await vm.load.execute();
      vm
        ..startCancel()
        ..setReason('Salah');
      await vm.cancel.execute();
      expect(
        (vm.cancel.result! as Error<Expense>).error,
        isA<CashSessionNotOpen>(),
      );
      expect(vm.confirming, isTrue);
    });
  });

  group('ExpenseCategoriesViewModel', () {
    test('tambah, ubah nama, hapus, dan tolak hapus bila dipakai', () async {
      final vm = ExpenseCategoriesViewModel(repository: repo);
      await vm.load.execute();
      expect(vm.rows, hasLength(7));
      expect(
        vm.rows.firstWhere((r) => r.category.name == 'Sewa tempat').usage,
        1,
      );
      await vm.save.execute((id: null, name: 'Iuran keamanan'));
      expect(vm.rows, hasLength(8));
      await vm.save.execute((id: null, name: 'iuran KEAMANAN'));
      expect(
        (vm.save.result! as Error).error,
        isA<ExpenseCategoryNameTaken>(),
      );
      final iuran = repo.categoryByName('Iuran keamanan').id;
      await vm.save.execute((id: iuran, name: 'Iuran RT'));
      expect(vm.rows.map((r) => r.category.name), contains('Iuran RT'));
      await vm.delete.execute(iuran);
      expect(vm.rows, hasLength(7));
      final sewa = repo.categoryByName('Sewa tempat').id;
      await vm.delete.execute(sewa);
      expect(vm.deleteFailedId, sewa);
      expect(vm.rows, hasLength(7));
    });
  });
}
