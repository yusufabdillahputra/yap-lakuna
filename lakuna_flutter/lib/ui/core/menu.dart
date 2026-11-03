import 'package:flutter/widgets.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

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
  });

  final String key;
  final IconData icon;
  final String Function(AppLocalizations) label;
  final String path;

  /// Izin wajib agar entri tampil dan rutenya bisa dibuka (`null` = semua
  /// staf). Sama dengan pemetaan modul di Storeku.
  final Permission? permission;

  bool allows(Set<Permission> permissions) =>
      permission == null || permissions.contains(permission);
}

/// Kelompok menu di sidebar.
class MenuGroup {
  const MenuGroup({required this.label, required this.entries});

  final String Function(AppLocalizations)? label;
  final List<MenuEntry> entries;
}

MenuEntry _module(
  String key,
  IconData icon,
  String Function(AppLocalizations) label, [
  Permission? permission,
]) => MenuEntry(
  key: key,
  icon: icon,
  label: label,
  path: Routes.module(key),
  permission: permission,
);

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
      _module(
        'cashier',
        TablerIcons.shoppingCart,
        (l) => l.menuCashier,
        Permission.salesCreate,
      ),
      _module(
        'history',
        TablerIcons.receipt,
        (l) => l.menuHistory,
        Permission.salesCreate,
      ),
    ],
  ),
  MenuGroup(
    label: (l) => l.menuGroupInventory,
    entries: [
      _module(
        'products',
        TablerIcons.package,
        (l) => l.menuProducts,
        Permission.productsManage,
      ),
      _module(
        'stock',
        TablerIcons.buildingWarehouse,
        (l) => l.menuStock,
        Permission.stockAdjust,
      ),
      _module(
        'purchases',
        TablerIcons.truck,
        (l) => l.menuPurchases,
        Permission.purchasesManage,
      ),
    ],
  ),
  MenuGroup(
    label: (l) => l.menuGroupContacts,
    entries: [
      _module(
        'customers',
        TablerIcons.users,
        (l) => l.menuCustomers,
        Permission.customersManage,
      ),
      _module(
        'suppliers',
        TablerIcons.addressBook,
        (l) => l.menuSuppliers,
        Permission.suppliersManage,
      ),
    ],
  ),
  MenuGroup(
    label: (l) => l.menuGroupFinance,
    entries: [
      _module(
        'expenses',
        TablerIcons.wallet,
        (l) => l.menuExpenses,
        Permission.expensesManage,
      ),
      _module(
        'reports',
        TablerIcons.chartBar,
        (l) => l.menuReports,
        Permission.reportsView,
      ),
    ],
  ),
  MenuGroup(
    label: (l) => l.menuGroupSystem,
    entries: [
      _module(
        'users',
        TablerIcons.userCog,
        (l) => l.menuUsers,
        Permission.usersManage,
      ),
      MenuEntry(
        key: 'settings',
        icon: TablerIcons.settings,
        label: (l) => l.menuSettings,
        path: Routes.settings,
      ),
      _module('guide', TablerIcons.help, (l) => l.menuGuide),
    ],
  ),
];

Iterable<MenuEntry> get allMenuEntries => appMenu.expand((g) => g.entries);

/// Menu yang boleh dilihat staf dengan [permissions]; kelompok kosong
/// disembunyikan.
List<MenuGroup> visibleMenu(Set<Permission> permissions) => [
  for (final group in appMenu)
    if (group.entries.any((e) => e.allows(permissions)))
      MenuGroup(
        label: group.label,
        entries: [
          for (final e in group.entries)
            if (e.allows(permissions)) e,
        ],
      ),
];

/// Menu ringkas untuk navigasi bawah di mobile, disaring izin.
List<MenuEntry> mobileMenu(Set<Permission> permissions) => [
  for (final key in const ['home', 'cashier', 'products', 'settings'])
    if (allMenuEntries.firstWhere((e) => e.key == key) case final e
        when e.allows(permissions))
      e,
];

MenuEntry? menuEntryByKey(String key) {
  for (final e in allMenuEntries) {
    if (e.key == key) return e;
  }
  return null;
}
