import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart' hide Protocol;

/// Akses generik ke satu tabel sync di database perangkat, lewat model
/// Serverpod [T] (baca, ubah JSON payload ↔ model, tulis tanpa outbox).
class SyncRowType<T extends TableRow<UuidValue?>> {
  const SyncRowType();

  Table<UuidValue?> get table =>
      Protocol().getTableForType(T)! as Table<UuidValue?>;

  String get tableName => table.tableName;

  /// Baris dengan ID > [after] (semua bila `null`), urut ID, maks [limit].
  Future<List<T>> after(
    DatabaseSession session,
    Transaction transaction, {
    UuidValue? after,
    int? limit,
  }) => session.db.find<T>(
    where: after == null ? null : table.id > after,
    orderBy: table.id,
    limit: limit,
    transaction: transaction,
  );

  Future<T?> byId(
    DatabaseSession session,
    Transaction transaction,
    UuidValue id,
  ) => session.db.findById<T>(id, transaction: transaction);

  T fromJson(Map<String, dynamic> json) => Protocol().deserialize<T>(json);

  /// Menyisipkan atau memperbarui [row] apa adanya, tanpa outbox (baris dari
  /// server atau stempel ulang pemadatan).
  Future<T> put(
    DatabaseSession session,
    Transaction transaction,
    T row, {
    required bool exists,
  }) => exists
      ? session.db.updateRow<T>(row, transaction: transaction)
      : session.db.insertRow<T>(row, transaction: transaction);

  Future<void> delete(
    DatabaseSession session,
    Transaction transaction,
    T row,
  ) => session.db.deleteRow<T>(row, transaction: transaction);
}

/// Semua tabel `syncTables` beserta modelnya di perangkat.
const List<SyncRowType> _types = [
  SyncRowType<Tenant>(),
  SyncRowType<Outlet>(),
  SyncRowType<Device>(),
  SyncRowType<StaffMember>(),
  SyncRowType<StaffRole>(),
  SyncRowType<OutletMember>(),
  SyncRowType<StockLocation>(),
  SyncRowType<Setting>(),
  SyncRowType<StaffAccessLog>(),
  SyncRowType<MediaFile>(),
  SyncRowType<MeasureUnit>(),
  SyncRowType<ProductCategory>(),
  SyncRowType<CustomerGroup>(),
  SyncRowType<Customer>(),
  SyncRowType<Supplier>(),
  SyncRowType<ExpenseCategory>(),
  SyncRowType<ModifierGroup>(),
  SyncRowType<ModifierOption>(),
  SyncRowType<Product>(),
  SyncRowType<ProductVariant>(),
  SyncRowType<ProductUnit>(),
  SyncRowType<ProductPriceTier>(),
  SyncRowType<ProductModifierGroup>(),
  SyncRowType<Shift>(),
  SyncRowType<CashSession>(),
  SyncRowType<CashMovement>(),
  SyncRowType<DiningArea>(),
  SyncRowType<DiningTable>(),
  SyncRowType<Sale>(),
  SyncRowType<KitchenTicket>(),
  SyncRowType<SaleItem>(),
  SyncRowType<SaleItemModifier>(),
  SyncRowType<Payment>(),
  SyncRowType<SaleReturn>(),
  SyncRowType<SaleReturnItem>(),
  SyncRowType<Purchase>(),
  SyncRowType<PurchaseItem>(),
  SyncRowType<PurchaseInvoicePage>(),
  SyncRowType<PurchaseReturn>(),
  SyncRowType<PurchaseReturnItem>(),
  SyncRowType<DebtPayment>(),
  SyncRowType<DebtPaymentAllocation>(),
  SyncRowType<Expense>(),
  SyncRowType<StockAdjustment>(),
  SyncRowType<StockAdjustmentItem>(),
  SyncRowType<StockMovement>(),
];

final Map<String, SyncRowType> _byName = {
  for (final t in _types) t.tableName: t,
};

/// Model perangkat untuk tabel sync [name], atau `null` bila bukan tabel
/// sync.
SyncRowType? syncRowType(String name) =>
    syncTableByName(name) == null ? null : _byName[name];
