import 'package:flutter/widgets.dart';
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
  });

  final String key;
  final IconData icon;
  final String Function(AppLocalizations) label;
  final String path;
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
  String Function(AppLocalizations) label,
) => MenuEntry(key: key, icon: icon, label: label, path: Routes.module(key));

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
      _module('cashier', TablerIcons.shoppingCart, (l) => l.menuCashier),
      _module('history', TablerIcons.receipt, (l) => l.menuHistory),
    ],
  ),
  MenuGroup(
    label: (l) => l.menuGroupInventory,
    entries: [
      _module('products', TablerIcons.package, (l) => l.menuProducts),
      _module('stock', TablerIcons.buildingWarehouse, (l) => l.menuStock),
      _module('purchases', TablerIcons.truck, (l) => l.menuPurchases),
    ],
  ),
  MenuGroup(
    label: (l) => l.menuGroupContacts,
    entries: [
      _module('customers', TablerIcons.users, (l) => l.menuCustomers),
      _module('suppliers', TablerIcons.addressBook, (l) => l.menuSuppliers),
    ],
  ),
  MenuGroup(
    label: (l) => l.menuGroupFinance,
    entries: [
      _module('expenses', TablerIcons.wallet, (l) => l.menuExpenses),
      _module('reports', TablerIcons.chartBar, (l) => l.menuReports),
    ],
  ),
  MenuGroup(
    label: (l) => l.menuGroupSystem,
    entries: [
      _module('users', TablerIcons.userCog, (l) => l.menuUsers),
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

/// Menu ringkas untuk navigasi bawah di mobile.
List<MenuEntry> get mobileMenu => [
  for (final key in const ['home', 'cashier', 'products', 'settings'])
    allMenuEntries.firstWhere((e) => e.key == key),
];

MenuEntry? menuEntryByKey(String key) {
  for (final e in allMenuEntries) {
    if (e.key == key) return e;
  }
  return null;
}
