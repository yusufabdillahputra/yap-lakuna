import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:lakuna_client/lakuna_client.dart' show UuidValue;
import 'package:lakuna_domain/lakuna_domain.dart' show Money, Permission;

import '../data/repositories/backup_repository.dart';
import '../data/repositories/cash_drawer_repository.dart';
import '../data/repositories/cashier_repository.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/dining_admin_repository.dart';
import '../data/repositories/dining_repository.dart';
import '../data/repositories/customers_repository.dart';
import '../data/repositories/expenses_repository.dart';
import '../data/repositories/reports_repository.dart';
import '../data/repositories/users_repository.dart';
import '../data/repositories/suppliers_repository.dart';
import '../data/repositories/history_repository.dart';
import '../data/repositories/purchases_repository.dart';
import '../data/repositories/master_data_repository.dart';
import '../data/repositories/payment_settings_repository.dart';
import '../data/repositories/receipt_settings_repository.dart';
import '../data/repositories/store_settings_repository.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/stock_repository.dart';
import '../data/repositories/store_repository.dart';
import '../data/services/backup_files.dart';
import '../data/services/image_file_picker.dart';
import '../data/services/receipt_printer.dart';
import '../data/services/spreadsheet_exporter.dart';
import '../data/services/table_file.dart';
import '../ui/cash_session/cash_session_view.dart';
import '../ui/cashier/cashier_view.dart';
import '../ui/cashier/cashier_view_model.dart' show BillPart, CompletedBill;
import '../ui/coming_soon/coming_soon_view.dart';
import '../ui/core/app_shell.dart';
import '../ui/core/menu.dart';
import '../ui/dining/dining_view.dart';
import '../ui/dining/split_bill_view.dart';
import '../ui/floor_plan/floor_plan_view.dart';
import '../ui/customers/customer_panel_view.dart';
import '../ui/customers/customers_view.dart';
import '../ui/customers/kuitansi_view.dart';
import '../ui/history/history_view.dart';
import '../ui/purchases/purchase_detail_view.dart';
import '../ui/purchases/purchases_view.dart';
import '../ui/expenses/expenses_view.dart';
import '../ui/reports/reports_view.dart';
import '../ui/users/my_account_view.dart';
import '../ui/users/users_view.dart';
import '../ui/suppliers/supplier_panel_view.dart';
import '../ui/suppliers/suppliers_view.dart';
import '../ui/home/home_view.dart';
import '../ui/login/login_view.dart';
import '../ui/master/master_view.dart';
import '../ui/onboarding/onboarding_view.dart';
import '../ui/products/product_form_view.dart';
import '../ui/products/product_list_view.dart';
import '../ui/settings/app_settings_view_model.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/stock/stock_view.dart';
import '../ui/stock/stock_view_model.dart' show StockTab;
import 'routes.dart';

/// Router aplikasi:
/// - toko belum ada → [Routes.setup];
/// - toko ada tanpa staf bertugas → [Routes.login];
/// - staf bertugas di [Routes.setup]/[Routes.login] → Beranda;
/// - modul yang izinnya tidak dimiliki staf → Beranda.
GoRouter createRouter({
  required AppSettingsViewModel settings,
  required StoreRepository store,
  required SessionRepository session,
  required CashDrawerRepository cashDrawer,
  required CatalogRepository catalog,
  required StockRepository stock,
  required MasterDataRepository masterData,
  required CashierRepository cashier,
  required DiningRepository dining,
  required DiningAdminRepository diningAdmin,
  required HistoryRepository history,
  required PurchasesRepository purchases,
  required CustomersRepository customers,
  required SuppliersRepository suppliers,
  required ExpensesRepository expenses,
  required ReportsRepository reports,
  required UsersRepository users,
  required PaymentSettingsRepository paymentSettings,
  required ReceiptSettingsRepository receiptSettings,
  required StoreSettingsRepository storeSettings,
  required ReceiptPrinter receiptPrinter,
  required BackupRepository backup,
  BackupFiles backupFiles = const PlatformBackupFiles(),
  ImageFilePicker imagePicker = const FileSelectorImagePicker(),
  SpreadsheetExporter exporter = const PlatformSpreadsheetExporter(),
  TableFilePicker tablePicker = const FileSelectorTablePicker(),
  String initialLocation = Routes.home,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: Listenable.merge([store, session]),
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (store.current == null) {
        return location == Routes.setup ? null : Routes.setup;
      }
      final staff = session.current;
      if (staff == null) {
        return location == Routes.login ? null : Routes.login;
      }
      if (location == Routes.login || location == Routes.setup) {
        return Routes.home;
      }
      final entry = switch (state.pathParameters['key']) {
        final key? => menuEntryByKey(key),
        null => menuEntryByPath(location),
      };
      if (entry != null && !entry.allows(staff.permissions)) {
        return Routes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.setup,
        builder: (context, state) => OnboardingScreen(
          repository: store,
          session: session,
          settings: settings,
        ),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) =>
            LoginScreen(session: session, store: store),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          location: state.uri.path,
          session: session,
          child: child,
        ),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) =>
                HomeView(store: store, session: session, backup: backup),
          ),
          GoRoute(
            path: Routes.settings,
            builder: (context, state) => SettingsScreen(
              settings: settings,
              paymentSettings: paymentSettings,
              receiptSettings: receiptSettings,
              storeSettings: storeSettings,
              receiptPrinter: receiptPrinter,
              imagePicker: imagePicker,
              session: session,
              store: store,
              diningAdmin: diningAdmin,
              backup: backup,
              backupFiles: backupFiles,
              initialSection: SettingsSection.fromQuery(
                state.uri.queryParameters['bagian'],
              ),
            ),
          ),
          GoRoute(
            path: Routes.cashSession,
            builder: (context, state) => CashSessionScreen(
              repository: cashDrawer,
              store: store,
              session: session,
              expenses: expenses,
              imagePicker: imagePicker,
            ),
          ),
          GoRoute(
            path: Routes.cashier,
            builder: (context, state) {
              final query = state.uri.queryParameters;
              final bill = query['bill'];
              final guest = query['guest'];
              final amount = int.tryParse(query['amount'] ?? '');
              final part = bill == null || (guest == null && amount == null)
                  ? null
                  : BillPart(
                      guest: guest,
                      amount: amount == null ? null : Money(amount),
                    );
              return CashierScreen(
                key: ValueKey('cashier-${state.uri.query}'),
                repository: cashier,
                printer: receiptPrinter,
                session: session,
                billId: bill,
                part: part,
                completed: state.extra is CompletedBill
                    ? state.extra! as CompletedBill
                    : null,
                onLeaveBill: bill == null
                    ? null
                    : part == null
                    ? () => context.go(Routes.tablesBill(bill))
                    : () => context.go(Routes.tablesSplit(bill)),
                onBillDone: bill == null
                    ? null
                    : () => context.go(Routes.tablesBill(bill)),
              );
            },
          ),
          GoRoute(
            path: Routes.tables,
            builder: (context, state) => DiningScreen(
              key: ValueKey('tables-${state.uri.queryParameters['bill']}'),
              repository: dining,
              printer: receiptPrinter,
              session: session,
              initialBill: state.uri.queryParameters['bill'],
              onPay: (id) => context.go(Routes.cashierBill(id.uuid)),
              onSplit: (id) => context.go(Routes.tablesSplit(id.uuid)),
              onArrange: (area) => context.go(Routes.tablesFloor(area?.uuid)),
            ),
          ),
          GoRoute(
            path: '${Routes.tables}/denah',
            builder: (context, state) => FloorPlanScreen(
              key: ValueKey('floor-${state.uri.query}'),
              repository: diningAdmin,
              picker: imagePicker,
              initialArea: _uuid(state.uri.queryParameters['area']),
              onBack: () => context.go(Routes.tables),
            ),
          ),
          GoRoute(
            path: '${Routes.tables}/split/:bill',
            // Tautan rusak kembali ke layar Meja.
            redirect: (context, state) =>
                _uuid(state.pathParameters['bill']) == null
                ? Routes.tables
                : null,
            builder: (context, state) {
              final bill = state.pathParameters['bill']!;
              return SplitBillScreen(
                key: ValueKey('split-$bill'),
                repository: dining,
                billId: UuidValue.fromString(bill),
                onBack: () => context.go(Routes.tablesBill(bill)),
                onCompleted: (done) =>
                    context.go(Routes.cashierBill(bill), extra: done),
                onPay: (guest, amount) => context.go(
                  Routes.cashierBillPart(
                    bill,
                    guest: guest,
                    amount: amount?.value,
                  ),
                ),
              );
            },
          ),
          // Rute saudara (bukan bersarang) supaya kembali ke daftar
          // membuat layar baru yang memuat ulang katalog.
          GoRoute(
            path: Routes.history,
            builder: (context, state) => HistoryScreen(
              repository: history,
              session: session,
              printer: receiptPrinter,
              exporter: exporter,
              onOpenSale: (id) =>
                  context.push<void>(Routes.historySale(id.uuid)),
            ),
          ),
          GoRoute(
            path: '${Routes.history}/:sale',
            // Tautan rusak kembali ke daftar riwayat.
            redirect: (context, state) =>
                _uuid(state.pathParameters['sale']) == null
                ? Routes.history
                : null,
            builder: (context, state) {
              final sale = state.pathParameters['sale']!;
              return HistoryScreen(
                key: ValueKey('history-$sale'),
                repository: history,
                session: session,
                printer: receiptPrinter,
                exporter: exporter,
                initialSale: UuidValue.fromString(sale),
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(Routes.history),
              );
            },
          ),
          GoRoute(
            path: Routes.products,
            builder: (context, state) => ProductListScreen(repository: catalog),
          ),
          GoRoute(
            path: Routes.productNew,
            builder: (context, state) => ProductFormScreen(repository: catalog),
          ),
          GoRoute(
            path: '${Routes.products}/:productId',
            builder: (context, state) => ProductFormScreen(
              key: ValueKey(state.pathParameters['productId']),
              repository: catalog,
              productId: state.pathParameters['productId'],
            ),
          ),
          GoRoute(
            path: Routes.stock,
            builder: (context, state) => StockScreen(
              repository: stock,
              session: session,
              store: store,
              initialTab: StockTab.values
                  .where((t) => t.name == state.uri.queryParameters['tab'])
                  .firstOrNull,
            ),
          ),
          GoRoute(
            path: Routes.master,
            builder: (context, state) => MasterDataScreen(
              repository: masterData,
              session: session,
              diningAdmin: diningAdmin,
              customers: customers,
              expenses: expenses,
            ),
          ),
          GoRoute(
            path: Routes.purchases,
            builder: (context, state) => PurchasesScreen(
              repository: purchases,
              onOpenPurchase: (id) =>
                  context.push<void>(Routes.purchase(id.uuid)),
              onNewPurchase: () => context.push<UuidValue>(Routes.purchaseNew),
            ),
          ),
          GoRoute(
            path: Routes.purchaseNew,
            builder: (context, state) => PurchaseFormPage(
              repository: purchases,
              // Setelah diterima, daftar membuka detail pembelian.
              onReceived: (p) => context.canPop()
                  ? context.pop(p.id)
                  : context.go(Routes.purchase(p.id.uuid)),
              onBack: () => context.canPop()
                  ? context.pop()
                  : context.go(Routes.purchases),
            ),
          ),
          GoRoute(
            path: '${Routes.purchases}/:purchase',
            // Tautan rusak kembali ke daftar pembelian.
            redirect: (context, state) =>
                _uuid(state.pathParameters['purchase']) == null
                ? Routes.purchases
                : null,
            builder: (context, state) {
              final id = state.pathParameters['purchase']!;
              return PurchaseDetailScreen(
                key: ValueKey('purchase-$id'),
                repository: purchases,
                purchaseId: UuidValue.fromString(id),
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(Routes.purchases),
                // Bayar hutang (F1-14) butuh `debts:manage`.
                onPayDebt: session.current?.can(Permission.debtsManage) ?? false
                    ? (supplierId) =>
                          context.push<void>(Routes.supplier(supplierId.uuid))
                    : null,
              );
            },
          ),
          GoRoute(
            path: Routes.customers,
            builder: (context, state) => CustomersScreen(
              repository: customers,
              tablePicker: tablePicker,
              onOpenCustomer: (id) =>
                  context.push<void>(Routes.customer(id.uuid)),
              onOpenReceipt: (id, {copy = false}) =>
                  context.push<void>(Routes.kuitansi(id.uuid, copy: copy)),
            ),
          ),
          // Sebelum `/:customer` supaya `kuitansi` tidak dibaca sebagai id.
          GoRoute(
            path: '${Routes.customers}/kuitansi/:payment',
            redirect: (context, state) =>
                _uuid(state.pathParameters['payment']) == null
                ? Routes.customers
                : null,
            builder: (context, state) {
              final id = state.pathParameters['payment']!;
              return KuitansiScreen(
                key: ValueKey('kuitansi-$id'),
                repository: customers,
                printer: receiptPrinter,
                paymentId: UuidValue.fromString(id),
                copy: state.uri.queryParameters['salinan'] == '1',
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(Routes.customers),
              );
            },
          ),
          GoRoute(
            path: '${Routes.customers}/:customer',
            // Tautan rusak kembali ke daftar pelanggan.
            redirect: (context, state) =>
                _uuid(state.pathParameters['customer']) == null
                ? Routes.customers
                : null,
            builder: (context, state) {
              final id = state.pathParameters['customer']!;
              return CustomerDetailPage(
                key: ValueKey('customer-$id'),
                repository: customers,
                customerId: UuidValue.fromString(id),
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(Routes.customers),
                onOpenReceipt: (id, {copy = false}) =>
                    context.push<void>(Routes.kuitansi(id.uuid, copy: copy)),
              );
            },
          ),
          GoRoute(
            path: Routes.suppliers,
            builder: (context, state) => SuppliersScreen(
              repository: suppliers,
              imagePicker: imagePicker,
              onOpenSupplier: (id) =>
                  context.push<void>(Routes.supplier(id.uuid)),
              onOpenPurchase: (id) =>
                  context.push<void>(Routes.purchase(id.uuid)),
            ),
          ),
          GoRoute(
            path: '${Routes.suppliers}/:supplier',
            // Tautan rusak kembali ke daftar supplier.
            redirect: (context, state) =>
                _uuid(state.pathParameters['supplier']) == null
                ? Routes.suppliers
                : null,
            builder: (context, state) {
              final id = state.pathParameters['supplier']!;
              return SupplierDetailPage(
                key: ValueKey('supplier-$id'),
                repository: suppliers,
                supplierId: UuidValue.fromString(id),
                imagePicker: imagePicker,
                onBack: () => context.canPop()
                    ? context.pop()
                    : context.go(Routes.suppliers),
                onOpenPurchase: (id) =>
                    context.push<void>(Routes.purchase(id.uuid)),
              );
            },
          ),
          GoRoute(
            path: Routes.expenses,
            builder: (context, state) => ExpensesScreen(
              repository: expenses,
              imagePicker: imagePicker,
              exporter: exporter,
            ),
          ),
          GoRoute(
            path: Routes.reports,
            builder: (context, state) => ReportsScreen(
              repository: reports,
              permissions: session.current?.permissions ?? const {},
              exporter: exporter,
            ),
          ),
          GoRoute(
            path: Routes.users,
            builder: (context, state) => UsersScreen(
              repository: users,
              session: session,
              outletName: store.current?.outlet.name ?? '',
            ),
          ),
          GoRoute(
            path: Routes.account,
            builder: (context, state) => MyAccountScreen(repository: users),
          ),
          GoRoute(
            path: '/modul/:key',
            builder: (context, state) =>
                ComingSoonView(moduleKey: state.pathParameters['key']!),
          ),
        ],
      ),
    ],
  );
}

UuidValue? _uuid(String? text) {
  if (text == null) return null;
  try {
    return UuidValue.withValidation(text);
  } on FormatException {
    return null;
  }
}
