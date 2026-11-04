import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'config/app_environment.dart';
import 'data/repositories/app_settings_repository.dart';
import 'data/repositories/cash_drawer_repository.dart';
import 'data/repositories/cashier_repository.dart';
import 'data/repositories/dining_admin_repository.dart';
import 'data/repositories/dining_repository.dart';
import 'data/repositories/local_app_settings_repository.dart';
import 'data/repositories/local_cash_drawer_repository.dart';
import 'data/repositories/local_cashier_repository.dart';
import 'data/repositories/local_dining_admin_repository.dart';
import 'data/repositories/customers_repository.dart';
import 'data/repositories/expenses_repository.dart';
import 'data/repositories/reports_repository.dart';
import 'data/repositories/users_repository.dart';
import 'data/repositories/suppliers_repository.dart';
import 'data/repositories/history_repository.dart';
import 'data/repositories/purchases_repository.dart';
import 'data/repositories/local_customers_repository.dart';
import 'data/repositories/local_expenses_repository.dart';
import 'data/repositories/local_reports_repository.dart';
import 'data/repositories/local_users_repository.dart';
import 'data/repositories/local_suppliers_repository.dart';
import 'data/repositories/local_history_repository.dart';
import 'data/repositories/local_purchases_repository.dart';
import 'data/repositories/local_dining_repository.dart';
import 'data/repositories/local_catalog_repository.dart';
import 'data/repositories/local_master_data_repository.dart';
import 'data/repositories/local_payment_settings_repository.dart';
import 'data/repositories/local_receipt_settings_repository.dart';
import 'data/repositories/local_session_repository.dart';
import 'data/repositories/local_stock_repository.dart';
import 'data/repositories/local_store_repository.dart';
import 'data/repositories/catalog_repository.dart';
import 'data/repositories/master_data_repository.dart';
import 'data/repositories/payment_settings_repository.dart';
import 'data/repositories/receipt_settings_repository.dart';
import 'data/repositories/session_repository.dart';
import 'data/repositories/stock_repository.dart';
import 'data/repositories/store_repository.dart';
import 'data/services/receipt_printer.dart';
import 'routing/router.dart';
import 'utils/result.dart';
import 'ui/settings/app_settings_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final databasePath = await resolveDatabasePath();
  final store = await LakunaStore.open(databasePath, isDebugMode: kDebugMode);
  final environment = AppEnvironment(
    databasePath: databasePath,
    deviceId: store.deviceId.uuid,
    version: appVersion,
  );
  final preferences = LocalPreferences(store.session);
  final settingsRepository = LocalAppSettingsRepository(preferences);
  final settings = AppSettingsViewModel(repository: settingsRepository);
  await settings.load.execute();
  final storeRepository = LocalStoreRepository(store);
  if (await storeRepository.load() case Error(:final error)) {
    // Wizard tetap tampil; galatnya dicatat agar bisa dilacak.
    debugPrint('Konteks toko gagal dimuat: $error');
  }
  final sessionRepository = LocalSessionRepository(
    store,
    stores: storeRepository,
  );
  final cashDrawerRepository = LocalCashDrawerRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
  );
  final catalogRepository = LocalCatalogRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
  );
  final stockRepository = LocalStockRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
  );
  final masterDataRepository = LocalMasterDataRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
  );
  final cashierRepository = LocalCashierRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
    preferences: preferences,
  );
  final diningRepository = LocalDiningRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
    preferences: preferences,
  );
  final historyRepository = LocalHistoryRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
    preferences: preferences,
  );
  final purchasesRepository = LocalPurchasesRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
  );
  final customersRepository = LocalCustomersRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
    preferences: preferences,
  );
  final suppliersRepository = LocalSuppliersRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
  );
  final expensesRepository = LocalExpensesRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
  );
  final reportsRepository = LocalReportsRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
  );
  final usersRepository = LocalUsersRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
  );
  final diningAdminRepository = LocalDiningAdminRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
  );
  final paymentSettingsRepository = LocalPaymentSettingsRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
  );
  final receiptSettingsRepository = LocalReceiptSettingsRepository(
    store,
    stores: storeRepository,
    session: sessionRepository,
    preferences: preferences,
  );
  final receiptPrinter = PlatformReceiptPrinter();

  runApp(
    MultiProvider(
      providers: [
        Provider<LakunaStore>.value(value: store),
        Provider<AppEnvironment>.value(value: environment),
        Provider<AppSettingsRepository>.value(value: settingsRepository),
        ChangeNotifierProvider<AppSettingsViewModel>.value(value: settings),
        ChangeNotifierProvider<StoreRepository>.value(value: storeRepository),
        ChangeNotifierProvider<SessionRepository>.value(
          value: sessionRepository,
        ),
        Provider<CashDrawerRepository>.value(value: cashDrawerRepository),
        Provider<CatalogRepository>.value(value: catalogRepository),
        Provider<CashierRepository>.value(value: cashierRepository),
        Provider<DiningRepository>.value(value: diningRepository),
        Provider<DiningAdminRepository>.value(value: diningAdminRepository),
        Provider<HistoryRepository>.value(value: historyRepository),
        Provider<PurchasesRepository>.value(value: purchasesRepository),
        Provider<CustomersRepository>.value(value: customersRepository),
        Provider<SuppliersRepository>.value(value: suppliersRepository),
        Provider<ExpensesRepository>.value(value: expensesRepository),
        Provider<ReportsRepository>.value(value: reportsRepository),
        Provider<UsersRepository>.value(value: usersRepository),
        Provider<StockRepository>.value(value: stockRepository),
        Provider<MasterDataRepository>.value(value: masterDataRepository),
        Provider<PaymentSettingsRepository>.value(
          value: paymentSettingsRepository,
        ),
        Provider<ReceiptSettingsRepository>.value(
          value: receiptSettingsRepository,
        ),
        Provider<ReceiptPrinter>.value(value: receiptPrinter),
      ],
      child: LakunaApp(
        settings: settings,
        router: createRouter(
          settings: settings,
          store: storeRepository,
          session: sessionRepository,
          cashDrawer: cashDrawerRepository,
          catalog: catalogRepository,
          stock: stockRepository,
          masterData: masterDataRepository,
          cashier: cashierRepository,
          dining: diningRepository,
          diningAdmin: diningAdminRepository,
          history: historyRepository,
          purchases: purchasesRepository,
          customers: customersRepository,
          suppliers: suppliersRepository,
          expenses: expensesRepository,
          reports: reportsRepository,
          users: usersRepository,
          paymentSettings: paymentSettingsRepository,
          receiptSettings: receiptSettingsRepository,
          receiptPrinter: receiptPrinter,
        ),
      ),
    ),
  );
}
