import 'package:characters/characters.dart';

import 'document_number.dart';
import 'money.dart';

// Pengeluaran operasional (F1-15, layar 1.22). Koreksi = batal lalu catat
// baru; nilai tidak pernah diubah.

/// Batas isian pengeluaran.
abstract final class ExpenseLimits {
  /// Keterangan, dalam karakter.
  static const description = 120;

  /// Nama jenis pengeluaran, dalam karakter.
  static const categoryName = 60;

  /// Alasan batal, dalam karakter.
  static const voidReason = 200;

  /// Jumlah maksimum satu pengeluaran (Rp 1 miliar).
  static const maxAmount = 1000000000;

  /// Batas foto nota.
  static const receiptMaxBytes = 5 * 1024 * 1024;
}

enum ExpenseIssue { description, category, amount }

int _len(String s) => s.trim().characters.length;

/// Galat isian pengeluaran.
Set<ExpenseIssue> validateExpense({
  required String description,
  required bool hasCategory,
  required Money amount,
}) => {
  if (_len(description) == 0 || _len(description) > ExpenseLimits.description)
    ExpenseIssue.description,
  if (!hasCategory) ExpenseIssue.category,
  if (amount.value <= 0 || amount.value > ExpenseLimits.maxAmount)
    ExpenseIssue.amount,
};

/// Nama jenis pengeluaran sah: tidak kosong, ≤ [ExpenseLimits.categoryName].
bool validateExpenseCategoryName(String name) =>
    _len(name) > 0 && _len(name) <= ExpenseLimits.categoryName;

/// Alasan batal sah: tidak kosong, ≤ [ExpenseLimits.voidReason].
bool validateExpenseVoidReason(String reason) =>
    _len(reason) > 0 && _len(reason) <= ExpenseLimits.voidReason;

/// Jenis bawaan, dibuat sekali per tenant.
const defaultExpenseCategories = [
  'Sewa tempat',
  'Listrik & air',
  'Gaji & upah',
  'Transport',
  'Plastik & kemasan',
  'Bahan habis pakai',
  'Lain-lain',
];

/// `EX-PST-K01-261104-0007`.
String expenseNumber(
  String outletCode,
  String deviceCode,
  DateTime localDate,
  int counter,
) => documentNumber('EX', outletCode, deviceCode, localDate, counter);

/// Filter periode layar Pengeluaran.
enum ExpensePeriod { last30Days, thisMonth, lastMonth }

/// Rentang tanggal kalender inklusif (UTC tengah malam).
class DateRange {
  const DateRange(this.from, this.to);

  final DateTime from;
  final DateTime to;

  bool contains(DateTime day) => !day.isBefore(from) && !day.isAfter(to);

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() => 'DateRange($from, $to)';
}

/// Rentang [period] relatif ke [today] (tanggal lokal cabang).
DateRange expensePeriodRange(ExpensePeriod period, DateTime today) {
  final t = DateTime.utc(today.year, today.month, today.day);
  return switch (period) {
    ExpensePeriod.last30Days => DateRange(
      DateTime.utc(t.year, t.month, t.day - 29),
      t,
    ),
    ExpensePeriod.thisMonth => DateRange(
      DateTime.utc(t.year, t.month),
      DateTime.utc(t.year, t.month + 1, 0),
    ),
    ExpensePeriod.lastMonth => DateRange(
      DateTime.utc(t.year, t.month - 1),
      DateTime.utc(t.year, t.month, 0),
    ),
  };
}
