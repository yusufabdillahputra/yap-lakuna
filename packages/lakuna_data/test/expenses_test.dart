import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

import 'helpers.dart';

/// PNG 1×1 terkecil yang sah.
final _png = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

void main() {
  late LakunaStore store;
  late Directory dir;
  late StoreContext ctx;
  late CatalogScope scope;
  late CashScope cashScope;
  late DateTime now;

  UuidValue owner() => ctx.owner.id;

  Future<StaffMember> addStaff(String name, String role) {
    final actor = ctx.owner.id;
    return store.write(actor: actor, (w) async {
      final s = await w.stamp();
      final staff = await w.insert(
        StaffMember(
          tenantId: ctx.tenant.id,
          name: name,
          pinHash: r'$argon2id$x',
          isActive: true,
          createdBy: actor,
          updatedBy: actor,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      await w.insert(
        OutletMember(
          tenantId: ctx.tenant.id,
          outletId: ctx.outlet.id,
          staffMemberId: staff.id,
          roleName: role,
          createdBy: actor,
          updatedBy: actor,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
      return staff;
    });
  }

  setUp(() async {
    // 2026-11-04 03.00 UTC = 10.00 WIB.
    now = DateTime.utc(2026, 11, 4, 3);
    (store, dir) = await openTempStore(clock: () => now);
    ctx = await setupTestStore(store);
    scope = CatalogScope.of(ctx);
    cashScope = CashScope.of(ctx);
    await ensureExpenseCategories(store, scope, staffId: owner());
  });

  tearDown(() async {
    await store.close();
    await dir.delete(recursive: true);
  });

  Future<UuidValue> jenis(String name) async => (await listExpenseCategories(
    store,
    scope,
  )).firstWhere((r) => r.category.name == name).category.id;

  Future<Expense> spend(
    String description,
    int amount, {
    String category = 'Bahan habis pakai',
    FundingSource funding = FundingSource.storeCash,
    DateTime? spentOn,
    ExpenseReceipt? receipt,
    UuidValue? staffId,
  }) async => recordExpense(
    store,
    scope,
    staffId: staffId ?? owner(),
    request: ExpenseRequest(
      description: description,
      categoryId: await jenis(category),
      amount: Money(amount),
      funding: funding,
      spentOn: spentOn ?? DateTime.utc(2026, 11, 4),
      receipt: receipt,
    ),
  );

  final month = DateRange(
    DateTime.utc(2026, 11, 1),
    DateTime.utc(2026, 11, 30),
  );

  group('jenis pengeluaran', () {
    test(
      'bawaan dibuat sekali, unik, ubah, hapus bila belum dipakai',
      () async {
        final rows = await listExpenseCategories(store, scope);
        expect(rows.map((r) => r.category.name).toSet(), {
          ...defaultExpenseCategories,
        });
        // Tidak dibuat ulang walau semua dihapus.
        for (final r in rows) {
          await deleteExpenseCategory(
            store,
            scope,
            staffId: owner(),
            categoryId: r.category.id,
          );
        }
        await ensureExpenseCategories(store, scope, staffId: owner());
        expect(await listExpenseCategories(store, scope), isEmpty);

        final es = await saveExpenseCategory(
          store,
          scope,
          staffId: owner(),
          name: ' Es batu ',
        );
        expect(es.name, 'Es batu');
        await expectLater(
          saveExpenseCategory(store, scope, staffId: owner(), name: 'ES BATU'),
          throwsA(isA<ExpenseCategoryNameTaken>()),
        );
        await expectLater(
          saveExpenseCategory(store, scope, staffId: owner(), name: ' '),
          throwsA(isA<ExpenseCategoryInvalid>()),
        );
        final renamed = await saveExpenseCategory(
          store,
          scope,
          staffId: owner(),
          id: es.id,
          name: 'Es batu & galon',
        );
        expect(renamed.version, es.version + 1);
        await recordExpense(
          store,
          scope,
          staffId: owner(),
          request: ExpenseRequest(
            description: 'Galon',
            categoryId: es.id,
            amount: const Money(20000),
            funding: FundingSource.storeCash,
            spentOn: DateTime.utc(2026, 11, 4),
          ),
        );
        expect((await listExpenseCategories(store, scope)).single.usage, 1);
        await expectLater(
          deleteExpenseCategory(
            store,
            scope,
            staffId: owner(),
            categoryId: es.id,
          ),
          throwsA(isA<ExpenseCategoryInUse>()),
        );
      },
    );
  });

  group('catat', () {
    test(
      'kas toko dan bank: nomor EX, tanggal mundur boleh, validasi',
      () async {
        final a = await spend(
          'Token listrik',
          500000,
          category: 'Listrik & air',
          funding: FundingSource.bank,
        );
        expect(a.number, 'EX-PST-K01-261104-0001');
        expect(a.cashSessionId, isNull);
        final b = await spend(
          'Sewa November',
          2500000,
          category: 'Sewa tempat',
          spentOn: DateTime.utc(2026, 10, 30),
        );
        expect(b.number, 'EX-PST-K01-261104-0002');
        expect(b.spentOn, DateTime.utc(2026, 10, 30));
        await expectLater(
          spend('Besok', 1000, spentOn: DateTime.utc(2026, 11, 5)),
          throwsA(isA<ExpenseDateInvalid>()),
        );
        await expectLater(
          recordExpense(
            store,
            scope,
            staffId: owner(),
            request: ExpenseRequest(
              description: '',
              categoryId: null,
              amount: Money.zero,
              funding: FundingSource.storeCash,
              spentOn: DateTime.utc(2026, 11, 4),
            ),
          ),
          throwsA(
            isA<ExpenseInvalid>().having((e) => e.issues, 'issues', {
              ExpenseIssue.description,
              ExpenseIssue.category,
              ExpenseIssue.amount,
            }),
          ),
        );
      },
    );

    test('kas laci: butuh sesi, hari ini, kas keluar di sesi', () async {
      await expectLater(
        spend('Beli es batu', 20000, funding: FundingSource.drawer),
        throwsA(isA<CashSessionNotOpen>()),
      );
      final session = await openCashSession(
        store,
        cashScope,
        staffId: owner(),
        openingCash: const Money(300000),
      );
      // Tanggal basi dari layar yang terbuka sejak kemarin tetap dicatat
      // hari ini karena uang laci keluar sekarang.
      final e = await spend(
        'Beli es batu',
        20000,
        funding: FundingSource.drawer,
        spentOn: DateTime.utc(2026, 11, 3),
      );
      expect(e.spentOn, DateTime.utc(2026, 11, 4));
      expect(e.cashSessionId, session.id);
      final moves = await listCashMovements(store, cashScope, session.id);
      final out = moves.single;
      expect(out.id, e.cashMovementId);
      expect(out.direction, CashDirection.outflow);
      expect(out.amount, 20000);
      expect(out.source, expenseCashSource);
      expect(out.note, 'Beli es batu');
      final drawer = await cashDrawerFor(store, cashScope, session);
      expect(drawer.expectedCash, const Money(280000));
      expect(await expenseLabelsForSession(store, scope, session.id), {
        out.id: 'Bahan habis pakai',
      });
      final row = await loadExpense(store, scope, e.id);
      expect(row.sessionStaffName, ctx.owner.name);
    });

    test('foto nota tersimpan, bukan gambar ditolak', () async {
      final e = await spend(
        'Plastik kresek',
        120000,
        category: 'Plastik & kemasan',
        receipt: ExpenseReceipt(bytes: _png, fileName: 'nota.png'),
      );
      expect(e.receiptMediaId, isNotNull);
      expect(await loadExpenseReceipt(store, scope, e.id), _png);
      await expectLater(
        spend(
          'Rusak',
          1000,
          receipt: ExpenseReceipt(
            bytes: Uint8List.fromList([1, 2, 3]),
            fileName: 'x.png',
          ),
        ),
        throwsA(isA<ExpenseReceiptInvalid>()),
      );
    });

    test('foto nota besar dikecilkan ke 2.000 px JPEG (F1-15b)', () async {
      final big = _tallPng();
      final e = await spend(
        'Plastik kresek',
        120000,
        category: 'Plastik & kemasan',
        receipt: ExpenseReceipt(bytes: big, fileName: 'nota.png'),
      );
      final media = await MediaFile.db.findById(
        store.session,
        e.receiptMediaId!,
      );
      expect((media!.width, media.height), (1200, 2000));
      expect(media.mimeType, 'image/jpeg');
      final stored = (await loadExpenseReceipt(store, scope, e.id))!;
      expect(readImageHeader(stored)!.width, 1200);
    });

    test('foto nota di atas 20 MB, > 50 MP, atau rusak ditolak', () async {
      final before = await SyncOutboxEntry.db.count(store.session);
      final tooBig = Uint8List(ExpenseLimits.receiptInputMaxBytes + 1)
        ..setAll(0, pngBytes(400, 300));
      final huge = Uint8List.fromList(
        img.encodePng(img.Image(width: 10000, height: 6000)),
      );
      final broken = Uint8List(ExpenseLimits.receiptMaxBytes)
        ..setAll(0, pngBytes(4000, 3000));
      for (final bytes in [tooBig, huge, broken]) {
        await expectLater(
          spend(
            'Rusak',
            1000,
            receipt: ExpenseReceipt(bytes: bytes, fileName: 'x.png'),
          ),
          throwsA(isA<ExpenseReceiptInvalid>()),
        );
      }
      expect(await SyncOutboxEntry.db.count(store.session), before);
    });

    test('foto nota 6 MB dari kamera diterima (batas lama 5 MB)', () async {
      final rnd = Random(3);
      final source = img.Image(width: 1800, height: 1600);
      for (final p in source) {
        p
          ..r = rnd.nextInt(256)
          ..g = rnd.nextInt(256)
          ..b = rnd.nextInt(256);
      }
      final png = Uint8List.fromList(img.encodePng(source, level: 0));
      expect(png.length, greaterThan(ExpenseLimits.receiptMaxBytes));
      final e = await spend(
        'Galon',
        20000,
        receipt: ExpenseReceipt(bytes: png, fileName: 'nota.png'),
      );
      final stored = (await loadExpenseReceipt(store, scope, e.id))!;
      expect(stored.length, lessThanOrEqualTo(ExpenseLimits.receiptMaxBytes));
    });

    test('pengeluaran laci + gerakan kas masuk outbox bersama', () async {
      await openCashSession(
        store,
        cashScope,
        staffId: owner(),
        openingCash: const Money(100000),
      );
      Future<Map<String, int>> counts() async {
        final rows = await SyncOutboxEntry.db.find(store.session);
        return {
          for (final t in const ['expenses', 'cash_movements'])
            t: rows.where((r) => r.entity == t).length,
        };
      }

      final before = await counts();
      await spend('Es batu', 8000, funding: FundingSource.drawer);
      final after = await counts();
      expect(after['expenses'], before['expenses']! + 1);
      expect(after['cash_movements'], before['cash_movements']! + 1);
    });

    test('pengeluaran dan foto nota cabang lain tidak bisa dibuka', () async {
      final e = await spend(
        'Bensin',
        50000,
        receipt: ExpenseReceipt(bytes: _png, fileName: 'nota.png'),
      );
      final other = CatalogScope(
        tenantId: scope.tenantId,
        outletId: UuidValue.fromString(newId()),
        deviceId: scope.deviceId,
      );
      expect(await loadExpenseReceipt(store, other, e.id), isNull);
      expect(await loadExpenseReceipt(store, scope, e.id), isNotNull);
      await expectLater(
        loadExpense(store, other, e.id),
        throwsA(isA<ExpenseNotFound>()),
      );
    });

    test('izin: pengeluaran dan kas laci', () async {
      final gudang = await addStaff('Andi', 'stock_keeper');
      await expectLater(
        spend('Bensin', 50000, staffId: gudang.id),
        throwsA(isA<ExpenseActorNotPermitted>()),
      );
      final kasir = await addStaff('Sari', 'cashier');
      await expectLater(
        spend('Bensin', 50000, staffId: kasir.id),
        throwsA(isA<ExpenseActorNotPermitted>()),
      );
    });
  });

  group('daftar & batal', () {
    test('ringkasan per jenis tanpa yang batal; filter rentang', () async {
      await spend(
        'Sewa November',
        2500000,
        category: 'Sewa tempat',
        spentOn: DateTime.utc(2026, 10, 30),
      );
      final listrik = await spend(
        'Token listrik',
        500000,
        category: 'Listrik & air',
        funding: FundingSource.bank,
      );
      await spend('Es batu', 80000);
      await spend('Es batu lagi', 20000, spentOn: DateTime.utc(2026, 11, 2));
      await voidExpense(
        store,
        scope,
        staffId: owner(),
        expenseId: listrik.id,
        reason: 'Salah catat',
      );
      final rows = await listExpenses(store, scope, month);
      expect(rows.map((r) => r.expense.description), [
        'Es batu',
        'Token listrik',
        'Es batu lagi',
      ]);
      final (total, by) = summarizeExpenses(rows);
      expect(total, const Money(100000));
      expect(by.single.name, 'Bahan habis pakai');
      expect(by.single.total, const Money(100000));
      final voided = rows.firstWhere((r) => r.voided);
      expect(voided.expense.voidReason, 'Salah catat');
      expect(voided.voidedByName, ctx.owner.name);

      final all = await listExpenses(
        store,
        scope,
        DateRange(DateTime.utc(2026, 10, 1), DateTime.utc(2026, 11, 30)),
      );
      expect(all, hasLength(4));
      await expectLater(
        voidExpense(
          store,
          scope,
          staffId: owner(),
          expenseId: listrik.id,
          reason: 'Lagi',
        ),
        throwsA(isA<ExpenseAlreadyVoided>()),
      );
      await expectLater(
        voidExpense(
          store,
          scope,
          staffId: owner(),
          expenseId: listrik.id,
          reason: ' ',
        ),
        throwsA(isA<ExpenseVoidReasonInvalid>()),
      );
    });

    test('batal pengeluaran laci mengembalikan uang di sesi terbuka', () async {
      final first = await openCashSession(
        store,
        cashScope,
        staffId: owner(),
        openingCash: const Money(300000),
      );
      final e = await spend(
        'Beli es batu',
        20000,
        funding: FundingSource.drawer,
      );
      await closeCashSession(
        store,
        cashScope,
        sessionId: first.id,
        staffId: owner(),
        count: const CashCount(coins: Money(280000)),
      );
      await expectLater(
        voidExpense(
          store,
          scope,
          staffId: owner(),
          expenseId: e.id,
          reason: 'Batal',
        ),
        throwsA(isA<CashSessionNotOpen>()),
      );
      final second = await openCashSession(
        store,
        cashScope,
        staffId: owner(),
        openingCash: const Money(280000),
      );
      final v = await voidExpense(
        store,
        scope,
        staffId: owner(),
        expenseId: e.id,
        reason: 'Es batu dikembalikan',
      );
      final back = (await listCashMovements(
        store,
        cashScope,
        second.id,
      )).single;
      expect(back.id, v.voidCashMovementId);
      expect(back.direction, CashDirection.inflow);
      expect(back.amount, 20000);
      expect(back.source, expenseVoidCashSource);
    });
  });
}

/// Foto nota tegak 2400×4000 bergaris (di atas batas sisi).
Uint8List _tallPng() {
  final source = img.Image(width: 2400, height: 4000);
  for (final p in source) {
    p
      ..r = p.x * 255 ~/ 2400
      ..g = p.y * 255 ~/ 4000
      ..b = (p.y ~/ 30).isEven ? 230 : 30;
  }
  return Uint8List.fromList(img.encodePng(source));
}
