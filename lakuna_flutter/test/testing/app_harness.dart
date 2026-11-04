import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_flutter/app.dart';
import 'package:lakuna_flutter/data/services/table_file.dart';
import 'package:lakuna_flutter/config/app_environment.dart';
import 'package:lakuna_flutter/routing/router.dart';
import 'package:lakuna_flutter/routing/routes.dart';
import 'package:lakuna_flutter/ui/settings/app_settings_view_model.dart';
import 'package:provider/provider.dart';

import 'fake_app_settings_repository.dart';
import 'fake_cash_drawer_repository.dart';
import 'fake_cashier_repository.dart';
import 'fake_catalog_repository.dart';
import 'fake_customers_repository.dart';
import 'fake_expenses_repository.dart';
import 'fake_reports_repository.dart';
import 'fake_users_repository.dart';
import 'fake_suppliers_repository.dart';
import 'fake_dining_admin_repository.dart';
import 'fake_dining_repository.dart';
import 'fake_history_repository.dart';
import 'fake_payment_settings_repository.dart';
import 'fake_purchases_repository.dart';
import 'fake_receipt_printer.dart';
import 'fake_receipt_settings_repository.dart';
import 'fake_store_settings_repository.dart';
import 'fake_session_repository.dart';
import 'fake_spreadsheet_exporter.dart';
import 'fake_master_data_repository.dart';
import 'fake_stock_repository.dart';
import 'fake_store_repository.dart';

/// Menjalankan aplikasi lengkap dengan repositori palsu pada ukuran layar
/// tertentu.
Future<AppSettingsViewModel> pumpLakuna(
  WidgetTester tester, {
  Size size = const Size(1280, 800),
  FakeAppSettingsRepository? repository,
  String initialLocation = Routes.home,
  FakeStoreRepository? store,
  FakeSessionRepository? session,
  FakeCashDrawerRepository? cashDrawer,
  FakeCatalogRepository? catalog,
  FakeStockRepository? stock,
  FakeMasterDataRepository? masterData,
  FakeCashierRepository? cashier,
  FakeDiningRepository? dining,
  FakeDiningAdminRepository? diningAdmin,
  FakeHistoryRepository? history,
  FakePurchasesRepository? purchases,
  FakeCustomersRepository? customers,
  FakeSuppliersRepository? suppliers,
  FakeExpensesRepository? expenses,
  FakeReportsRepository? reports,
  FakeUsersRepository? users,
  FakeSpreadsheetExporter? exporter,
  FakePaymentSettingsRepository? paymentSettings,
  FakeImagePicker? imagePicker,
  FakeReceiptSettingsRepository? receiptSettings,
  FakeStoreSettingsRepository? storeSettings,
  FakeReceiptPrinter? receiptPrinter,
  TableFilePicker? tablePicker,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final settings = AppSettingsViewModel(
    repository: repository ?? FakeAppSettingsRepository(),
  );
  await settings.load.execute();
  final storeRepository =
      store ?? FakeStoreRepository(current: sampleStoreContext());
  // Bawaan: toko sudah ada dan pemilik sedang bertugas. Tanpa toko, belum
  // ada yang bertugas.
  final sessionRepository =
      session ??
      (FakeSessionRepository()
        ..current = storeRepository.current == null ? null : sampleStaff());
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AppEnvironment>.value(
          value: const AppEnvironment(
            databasePath: '/tmp/lakuna.sqlite',
            deviceId: '0192f3a1-7c00-7000-8000-000000000001',
            version: '0.1.0',
          ),
        ),
      ],
      child: LakunaApp(
        settings: settings,
        router: createRouter(
          settings: settings,
          store: storeRepository,
          session: sessionRepository,
          cashDrawer: cashDrawer ?? FakeCashDrawerRepository(),
          catalog: catalog ?? FakeCatalogRepository(),
          stock: stock ?? FakeStockRepository(),
          masterData: masterData ?? FakeMasterDataRepository(),
          cashier: cashier ?? FakeCashierRepository(),
          dining: dining ?? FakeDiningRepository(),
          diningAdmin: diningAdmin ?? FakeDiningAdminRepository(),
          history: history ?? FakeHistoryRepository(),
          purchases: purchases ?? FakePurchasesRepository(),
          customers: customers ?? FakeCustomersRepository(),
          suppliers: suppliers ?? FakeSuppliersRepository(),
          expenses: expenses ?? FakeExpensesRepository(),
          reports: reports ?? FakeReportsRepository(),
          users: users ?? FakeUsersRepository(),
          paymentSettings: paymentSettings ?? FakePaymentSettingsRepository(),
          receiptSettings: receiptSettings ?? FakeReceiptSettingsRepository(),
          storeSettings: storeSettings ?? FakeStoreSettingsRepository(),
          receiptPrinter: receiptPrinter ?? FakeReceiptPrinter(),
          imagePicker: imagePicker ?? FakeImagePicker(),
          exporter: exporter ?? FakeSpreadsheetExporter(),
          tablePicker: tablePicker ?? const FileSelectorTablePicker(),
          initialLocation: initialLocation,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return settings;
}
