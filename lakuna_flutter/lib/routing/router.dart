import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/cash_drawer_repository.dart';
import '../data/repositories/cashier_repository.dart';
import '../data/repositories/catalog_repository.dart';
import '../data/repositories/dining_admin_repository.dart';
import '../data/repositories/dining_repository.dart';
import '../data/repositories/master_data_repository.dart';
import '../data/repositories/payment_settings_repository.dart';
import '../data/repositories/receipt_settings_repository.dart';
import '../data/repositories/session_repository.dart';
import '../data/repositories/stock_repository.dart';
import '../data/repositories/store_repository.dart';
import '../data/services/image_file_picker.dart';
import '../data/services/receipt_printer.dart';
import '../ui/cash_session/cash_session_view.dart';
import '../ui/cashier/cashier_view.dart';
import '../ui/coming_soon/coming_soon_view.dart';
import '../ui/core/app_shell.dart';
import '../ui/core/menu.dart';
import '../ui/dining/dining_view.dart';
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
  required PaymentSettingsRepository paymentSettings,
  required ReceiptSettingsRepository receiptSettings,
  required ReceiptPrinter receiptPrinter,
  ImageFilePicker imagePicker = const FileSelectorImagePicker(),
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
                HomeView(store: store, session: session),
          ),
          GoRoute(
            path: Routes.settings,
            builder: (context, state) => SettingsScreen(
              settings: settings,
              paymentSettings: paymentSettings,
              receiptSettings: receiptSettings,
              receiptPrinter: receiptPrinter,
              imagePicker: imagePicker,
              session: session,
              store: store,
              diningAdmin: diningAdmin,
            ),
          ),
          GoRoute(
            path: Routes.cashSession,
            builder: (context, state) => CashSessionScreen(
              repository: cashDrawer,
              store: store,
              session: session,
            ),
          ),
          GoRoute(
            path: Routes.cashier,
            builder: (context, state) {
              final bill = state.uri.queryParameters['bill'];
              return CashierScreen(
                key: ValueKey('cashier-${bill ?? ''}'),
                repository: cashier,
                printer: receiptPrinter,
                billId: bill,
                onLeaveBill: bill == null
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
              initialBill: state.uri.queryParameters['bill'],
              onPay: (id) => context.go(Routes.cashierBill(id.uuid)),
            ),
          ),
          // Rute saudara (bukan bersarang) supaya kembali ke daftar
          // membuat layar baru yang memuat ulang katalog.
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
            ),
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
