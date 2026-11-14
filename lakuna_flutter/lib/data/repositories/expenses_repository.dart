import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../utils/result.dart';

export 'repository_errors.dart';

/// Data awal layar Pengeluaran.
@immutable
class ExpensesSetup {
  const ExpensesSetup({
    required this.today,
    this.categories = const [],
    this.canUseDrawer = false,
    this.hasOpenSession = false,
    this.drawerCash,
  });

  /// Tanggal lokal cabang hari ini (UTC tengah malam).
  final DateTime today;

  /// Jenis pengeluaran aktif, urut nama.
  final List<ExpenseCategory> categories;

  /// Staf punya `cash_movements:create` (pengeluaran dari kas laci).
  final bool canUseDrawer;

  /// Perangkat ini punya sesi kasir terbuka.
  final bool hasOpenSession;

  /// Perkiraan uang di laci sesi terbuka (*Kas seharusnya*), `null` tanpa
  /// sesi. Untuk peringatan uang laci tidak cukup (F1-03c).
  final Money? drawerCash;
}

/// Pengeluaran operasional dan jenisnya (F1-15). Semua aksi butuh
/// `expenses:manage` (+ `cash_movements:create` untuk kas laci), dicek di
/// sini juga.
abstract class ExpensesRepository {
  /// Membuat jenis bawaan bila belum pernah ada.
  Future<Result<ExpensesSetup>> load();

  /// Pengeluaran cabang ini dalam [range], terbaru dulu.
  Future<Result<List<ExpenseRow>>> list(DateRange range);

  /// Gagal dengan `ExpenseInvalid`, `ExpenseDateInvalid`,
  /// `ExpenseReceiptInvalid`, atau `CashSessionNotOpen`. Pengeluaran kas
  /// laci selalu bertanggal hari ini menurut cabang.
  Future<Result<Expense>> record(ExpenseRequest request);

  /// Gagal dengan `ExpenseNotFound`.
  Future<Result<ExpenseRow>> detail(UuidValue id);

  /// Gagal dengan `ExpenseVoidReasonInvalid`, `ExpenseAlreadyVoided`, atau
  /// `CashSessionNotOpen` (pengeluaran laci).
  Future<Result<Expense>> cancel(UuidValue id, String reason);

  /// Foto nota; `null` bila tidak ada.
  Future<Result<Uint8List?>> receipt(UuidValue id);

  /// Jenis pengeluaran dengan jumlah pemakaian.
  Future<Result<List<ExpenseCategoryRow>>> categories();

  /// Gagal dengan `ExpenseCategoryInvalid` atau `ExpenseCategoryNameTaken`.
  Future<Result<ExpenseCategory>> saveCategory({
    UuidValue? id,
    required String name,
  });

  /// Gagal dengan `ExpenseCategoryInUse`.
  Future<Result<void>> deleteCategory(UuidValue id);
}
