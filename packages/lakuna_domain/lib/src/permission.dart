/// Katalog izin `resource:action`. Role menyimpan daftar kunci ini; UI dan
/// lapisan penyimpanan memeriksanya.
enum Permission {
  salesCreate('sales:create'),
  salesVoid('sales:void'),
  salesDiscount('sales:discount'),
  salesReturn('sales:return'),
  paymentsConfirm('payments:confirm'),
  openBillsManage('open_bills:manage'),
  cashSessionOpen('cash_session:open'),
  cashSessionClose('cash_session:close'),
  cashMovementsCreate('cash_movements:create'),
  productsManage('products:manage'),
  customersManage('customers:manage'),
  suppliersManage('suppliers:manage'),
  purchasesManage('purchases:manage'),
  stockAdjust('stock:adjust'),
  debtsManage('debts:manage'),
  expensesManage('expenses:manage'),
  reportsView('reports:view'),
  reportsViewProfit('reports:view_profit'),
  settingsManage('settings:manage'),
  usersManage('users:manage'),
  backupManage('backup:manage'),
  syncManage('sync:manage');

  const Permission(this.key);

  /// Kunci yang disimpan di role.
  final String key;

  static final Map<String, Permission> _byKey = {
    for (final p in values) p.key: p,
  };

  static Permission? fromKey(String key) => _byKey[key];
}

/// Role bawaan yang dibuat saat onboarding. Pemilik boleh mengubahnya atau
/// membuat role sendiri.
enum DefaultRole {
  owner('owner'),
  manager('manager'),
  cashier('cashier'),
  waiter('waiter'),
  stockKeeper('stock_keeper');

  const DefaultRole(this.key);

  final String key;

  Set<Permission> get permissions => switch (this) {
    owner => Permission.values.toSet(),
    manager =>
      Permission.values.toSet()..removeAll(const {
        Permission.usersManage,
        Permission.backupManage,
        Permission.syncManage,
      }),
    cashier => const {
      Permission.salesCreate,
      Permission.salesReturn,
      Permission.paymentsConfirm,
      Permission.openBillsManage,
      Permission.cashSessionOpen,
      Permission.cashSessionClose,
      Permission.cashMovementsCreate,
      Permission.debtsManage,
    },
    waiter => const {Permission.openBillsManage},
    stockKeeper => const {
      Permission.purchasesManage,
      Permission.stockAdjust,
      Permission.suppliersManage,
    },
  };
}
