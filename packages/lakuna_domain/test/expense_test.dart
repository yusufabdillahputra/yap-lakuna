import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('validateExpense', () {
    test('wajib keterangan, jenis, jumlah positif', () {
      expect(
        validateExpense(
          description: ' ',
          hasCategory: false,
          amount: Money.zero,
        ),
        {ExpenseIssue.description, ExpenseIssue.category, ExpenseIssue.amount},
      );
      expect(
        validateExpense(
          description: 'Beli es batu',
          hasCategory: true,
          amount: const Money(20000),
        ),
        isEmpty,
      );
    });

    test('batas panjang dan jumlah maksimum', () {
      expect(
        validateExpense(
          description: 'x' * (ExpenseLimits.description + 1),
          hasCategory: true,
          amount: const Money(ExpenseLimits.maxAmount + 1),
        ),
        {ExpenseIssue.description, ExpenseIssue.amount},
      );
    });
  });

  test('nama jenis pengeluaran', () {
    expect(validateExpenseCategoryName(''), isFalse);
    expect(validateExpenseCategoryName('x' * 61), isFalse);
    expect(validateExpenseCategoryName(' Sewa tempat '), isTrue);
    expect(defaultExpenseCategories, contains('Lain-lain'));
  });

  test('alasan batal wajib dan dibatasi', () {
    expect(validateExpenseVoidReason(' '), isFalse);
    expect(validateExpenseVoidReason('x' * 201), isFalse);
    expect(validateExpenseVoidReason('Salah jumlah'), isTrue);
  });

  test('nomor EX', () {
    expect(
      expenseNumber('pst', 'k01', DateTime(2026, 11, 4), 7),
      'EX-PST-K01-261104-0007',
    );
  });

  group('expensePeriodRange', () {
    final today = DateTime.utc(2026, 11, 4);

    test('30 hari terakhir termasuk hari ini', () {
      final r = expensePeriodRange(ExpensePeriod.last30Days, today);
      expect(r.from, DateTime.utc(2026, 10, 6));
      expect(r.to, today);
    });

    test('bulan ini dan bulan lalu', () {
      final now = expensePeriodRange(ExpensePeriod.thisMonth, today);
      expect(now.from, DateTime.utc(2026, 11, 1));
      expect(now.to, DateTime.utc(2026, 11, 30));
      final last = expensePeriodRange(ExpensePeriod.lastMonth, today);
      expect(last.from, DateTime.utc(2026, 10, 1));
      expect(last.to, DateTime.utc(2026, 10, 31));
      final jan = expensePeriodRange(
        ExpensePeriod.lastMonth,
        DateTime.utc(2027, 1, 15),
      );
      expect(jan.from, DateTime.utc(2026, 12, 1));
      expect(jan.to, DateTime.utc(2026, 12, 31));
    });

    test('contains memeriksa tanggal kalender inklusif', () {
      final r = expensePeriodRange(ExpensePeriod.thisMonth, today);
      expect(r.contains(DateTime.utc(2026, 11, 30)), isTrue);
      expect(r.contains(DateTime.utc(2026, 12, 1)), isFalse);
    });
  });
}
