import 'package:flutter/widgets.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../config/app_platform.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../routing/routes.dart';

/// Satu entri menu navigasi.
class MenuEntry {
  const MenuEntry({
    required this.key,
    required this.icon,
    required this.label,
    required this.path,
    this.permission,
    this.orPermission,
    this.deviceOnly = false,
  });

  final String key;
  final IconData icon;
  final String Function(AppLocalizations) label;
  final String path;

  /// Izin wajib agar entri tampil dan rutenya bisa dibuka (`null` = semua
  /// staf). Sama dengan pemetaan modul di Storeku.
  final Permission? permission;

  /// Izin pengganti [permission] (mis. Riwayat: `sales:create` atau
  /// `reports:view`).
  final Permission? orPermission;

  /// Hanya di aplikasi perangkat, tidak di web (kasir, meja, sesi kasir;
  /// F2-02 aturan 3).
  final bool deviceOnly;

  bool availableOn(AppPlatform platform) =>
      !deviceOnly || platform.supportsCashier;

  bool allows(Set<Permission> permissions) =>
      permission == null ||
      permissions.contains(permission) ||
      (orPermission != null && permissions.contains(orPermission));
}

/// Kelompok menu di sidebar.
class MenuGroup {
  const MenuGroup({required this.label, required this.entries});

  final String Function(AppLocalizations)? label;
  final List<MenuEntry> entries;
}

/// Menu aplikasi fase 1, urutannya mengikuti kanvas desain.
final List<MenuGroup> appMenu = [
  MenuGroup(
    label: null,
    entries: [
      MenuEntry(
        key: 'home',
        icon: TablerIcons.home,
        label: (l) => l.menuHome,
        path: Routes.home,
      ),
    ],
  ),
  MenuGroup(
    label: (l) => l.menuGroupSales,
    entries: [
      MenuEntry(
        key: 'cashier',
        icon: TablerIcons.shoppingCart,
        label: (l) => l.menuCashier,
        path: Routes.cashier,
        permission: Permission.salesCreate,
        deviceOnly: true,
      ),
      MenuEntry(
        key: 'tables',
        icon: TablerIcons.armchair,
        label: (l) => l.menuTables,
        path: Routes.tables,
        permission: Permission.openBillsManage,
        deviceOnly: true,
      ),
      MenuEntry(
        key: 'cash_session',
        icon: TablerIcons.cashRegister,
        label: (l) => l.menuCashSession,
        path: Routes.cashSession,
        permission: Permission.cashSessionOpen,
        deviceOnly: true,
      ),
      MenuEntry(
        key: 'history',
        icon: TablerIcons.receipt,
        label: (l) => l.menuHistory,
        path: Routes.history,
        permission: Permission.salesCreate,
        orPermission: Permission.reportsView,
      ),
    ],
  ),
  MenuGroup(
    label: (l) => l.menuGroupInventory,
    entries: [
      MenuEntry(
        key: 'products',
        icon: TablerIcons.package,
        label: (l) => l.menuProducts,
        path: Routes.products,
        permission: Permission.productsManage,
      ),
      MenuEntry(
        key: 'stock',
        icon: TablerIcons.buildingWarehouse,
        label: (l) => l.menuStock,
        path: Routes.stock,
        permission: Permission.stockAdjust,
      ),
      MenuEntry(
        key: 'master',
        icon: TablerIcons.category,
        label: (l) => l.menuMasterData,
        path: Routes.master,
        permission: Permission.productsManage,
      ),
      MenuEntry(
        key: 'purchases',
        icon: TablerIcons.truck,
        label: (l) => l.menuPurchases,
        path: Routes.purchases,
        permission: Permission.purchasesManage,
      ),
    ],
  ),
  MenuGroup(
    label: (l) => l.menuGroupContacts,
    entries: [
      MenuEntry(
        key: 'customers',
        icon: TablerIcons.users,
        label: (l) => l.menuCustomers,
        path: Routes.customers,
        permission: Permission.customersManage,
        orPermission: Permission.debtsManage,
      ),
      MenuEntry(
        key: 'suppliers',
        icon: TablerIcons.addressBook,
        label: (l) => l.menuSuppliers,
        path: Routes.suppliers,
        permission: Permission.suppliersManage,
        orPermission: Permission.debtsManage,
      ),
    ],
  ),
  MenuGroup(
    label: (l) => l.menuGroupFinance,
    entries: [
      MenuEntry(
        key: 'expenses',
        icon: TablerIcons.wallet,
        label: (l) => l.menuExpenses,
        path: Routes.expenses,
        permission: Permission.expensesManage,
      ),
      MenuEntry(
        key: 'reports',
        icon: TablerIcons.chartBar,
        label: (l) => l.menuReports,
        path: Routes.reports,
        permission: Permission.reportsView,
      ),
    ],
  ),
  MenuGroup(
    label: (l) => l.menuGroupSystem,
    entries: [
      MenuEntry(
        key: 'users',
        icon: TablerIcons.userCog,
        label: (l) => l.menuUsers,
        path: Routes.users,
        permission: Permission.usersManage,
      ),
      MenuEntry(
        key: 'account',
        icon: TablerIcons.userCircle,
        label: (l) => l.menuAccount,
        path: Routes.account,
      ),
      MenuEntry(
        key: 'settings',
        icon: TablerIcons.settings,
        label: (l) => l.menuSettings,
        path: Routes.settings,
      ),
      MenuEntry(
        key: 'guide',
        icon: TablerIcons.help,
        label: (l) => l.menuGuide,
        path: Routes.guide,
      ),
    ],
  ),
];

Iterable<MenuEntry> get allMenuEntries => appMenu.expand((g) => g.entries);

bool _shows(MenuEntry e, Set<Permission> permissions, AppPlatform platform) =>
    e.allows(permissions) && e.availableOn(platform);

/// Menu yang boleh dilihat staf dengan [permissions] di [platform];
/// kelompok kosong disembunyikan.
List<MenuGroup> visibleMenu(
  Set<Permission> permissions, {
  AppPlatform platform = AppPlatform.native,
}) => [
  for (final group in appMenu)
    if (group.entries.any((e) => _shows(e, permissions, platform)))
      MenuGroup(
        label: group.label,
        entries: [
          for (final e in group.entries)
            if (_shows(e, permissions, platform)) e,
        ],
      ),
];

/// Entri navigasi bawah mobile sesuai kanvas 1.15m (Beranda, Kasir, Produk,
/// Riwayat), disaring izin. Sisanya ada di *Lainnya* ([mobileMoreMenu]).
const _mobilePrimary = ['home', 'cashier', 'products', 'history'];

List<MenuEntry> mobileMenu(
  Set<Permission> permissions, {
  AppPlatform platform = AppPlatform.native,
}) => [
  for (final key in _mobilePrimary)
    if (allMenuEntries.firstWhere((e) => e.key == key) case final e
        when _shows(e, permissions, platform))
      e,
];

/// Menu *Lainnya* di mobile: entri yang boleh dilihat tetapi tidak ada di
/// navigasi bawah, per kelompok.
List<MenuGroup> mobileMoreMenu(
  Set<Permission> permissions, {
  AppPlatform platform = AppPlatform.native,
}) => [
  for (final group in visibleMenu(permissions, platform: platform))
    if (group.entries.any((e) => !_mobilePrimary.contains(e.key)))
      MenuGroup(
        label: group.label,
        entries: [
          for (final e in group.entries)
            if (!_mobilePrimary.contains(e.key)) e,
        ],
      ),
];

MenuEntry? menuEntryByKey(String key) {
  for (final e in allMenuEntries) {
    if (e.key == key) return e;
  }
  return null;
}

/// Entri menu dengan jalur [path] persis (rute modul yang sudah dibangun).
/// Entri menu untuk [path], termasuk subrute (`/produk/baru` → Produk).
MenuEntry? menuEntryByPath(String path) {
  for (final e in allMenuEntries) {
    if (e.path == path) return e;
  }
  for (final e in allMenuEntries) {
    if (e.path != '/' && path.startsWith('${e.path}/')) return e;
  }
  return null;
}
