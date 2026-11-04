import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('validateSupplier', () {
    test('isian lengkap sah', () {
      expect(
        validateSupplier(
          name: 'CV Sumber Pangan',
          phone: '021-555-0101',
          contactName: 'Pak Hendra',
          category: 'Sembako',
          address: 'Jl. Raya 1',
          note: 'Kirim Selasa',
          termDays: 14,
        ),
        isEmpty,
      );
    });

    test('nama wajib dan dibatasi', () {
      expect(validateSupplier(name: '  ', termDays: 14), {SupplierIssue.name});
      expect(
        validateSupplier(name: 'x' * (SupplierLimits.name + 1), termDays: 14),
        {SupplierIssue.name},
      );
    });

    test('telepon boleh kosong, bila diisi 8–15 digit', () {
      expect(validateSupplier(name: 'A', phone: '', termDays: 0), isEmpty);
      expect(validateSupplier(name: 'A', phone: '12345', termDays: 0), {
        SupplierIssue.phone,
      });
    });

    test('tempo 0–365 hari', () {
      expect(validateSupplier(name: 'A', termDays: -1), {
        SupplierIssue.termDays,
      });
      expect(validateSupplier(name: 'A', termDays: 366), {
        SupplierIssue.termDays,
      });
      expect(validateSupplier(name: 'A', termDays: 365), isEmpty);
    });

    test('teks lain dibatasi', () {
      expect(
        validateSupplier(
          name: 'A',
          termDays: 1,
          contactName: 'x' * (SupplierLimits.contactName + 1),
          category: 'x' * (SupplierLimits.category + 1),
          address: 'x' * (SupplierLimits.address + 1),
          note: 'x' * (SupplierLimits.note + 1),
        ),
        {
          SupplierIssue.contactName,
          SupplierIssue.category,
          SupplierIssue.address,
          SupplierIssue.note,
        },
      );
    });
  });

  test('hutang pembelian dikurangi alokasi pembayaran', () {
    expect(
      purchaseDebt(
        total: const Money(3300000),
        paid: const Money(1000000),
        allocated: const Money(1000000),
        debtReduction: const Money(300000),
      ),
      const Money(1000000),
    );
    expect(
      purchaseDebt(
        total: const Money(100),
        paid: Money.zero,
        allocated: const Money(150),
      ),
      Money.zero,
    );
  });

  test('urutan bayar hutang: jatuh tempo terdekat, tanpa tempo terakhir', () {
    final a = PayableOrder(
      dueOn: DateTime.utc(2026, 11, 16),
      purchasedOn: DateTime.utc(2026, 11, 2),
      number: 'PB-2',
    );
    final b = PayableOrder(
      dueOn: DateTime.utc(2026, 11, 4),
      purchasedOn: DateTime.utc(2026, 10, 28),
      number: 'PB-1',
    );
    final c = PayableOrder(
      dueOn: null,
      purchasedOn: DateTime.utc(2026, 10, 1),
      number: 'PB-0',
    );
    final d = PayableOrder(
      dueOn: DateTime.utc(2026, 11, 16),
      purchasedOn: DateTime.utc(2026, 11, 1),
      number: 'PB-3',
    );
    final sorted = [a, c, b, d]..sort();
    expect(sorted, [b, d, a, c]);
  });

  test('nomor bayar hutang BH-', () {
    expect(
      supplierPaymentNumber('PST', 'K01', DateTime(2026, 11, 4), 7),
      'BH-PST-K01-261104-0007',
    );
  });
}
