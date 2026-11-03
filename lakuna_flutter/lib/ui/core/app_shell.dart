import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/gen/app_localizations.dart';
import 'breakpoints.dart';
import 'menu.dart';
import 'offline_badge.dart';

/// Kerangka aplikasi: bilah atas, sidebar (tablet/desktop) atau navigasi bawah
/// (mobile), dan isi halaman.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  /// Jalur yang sedang dibuka, untuk menandai menu terpilih.
  final String location;
  final Widget child;

  bool _isSelected(MenuEntry e) =>
      e.path == '/' ? location == '/' : location.startsWith(e.path);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = LayoutSize.of(constraints.maxWidth);
        final header = FHeader(
          title: Text(l10n.appTitle, overflow: TextOverflow.ellipsis),
          suffixes: [
            Center(child: OfflineBadge(compact: size == LayoutSize.mobile)),
          ],
        );
        if (size == LayoutSize.mobile) {
          final items = mobileMenu;
          final index = items.indexWhere(_isSelected);
          return FScaffold(
            header: header,
            footer: FBottomNavigationBar(
              index: index,
              onChange: (i) => context.go(items[i].path),
              children: [
                for (final e in items)
                  FBottomNavigationBarItem(
                    key: ValueKey('nav-${e.key}'),
                    icon: Icon(e.icon),
                    label: Text(e.label(l10n)),
                  ),
              ],
            ),
            child: child,
          );
        }
        return FScaffold(
          header: header,
          sidebar: _Sidebar(
            compact: size == LayoutSize.tablet,
            isSelected: _isSelected,
          ),
          child: child,
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.compact, required this.isSelected});

  final bool compact;
  final bool Function(MenuEntry) isSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: compact ? 200 : 256,
      child: FSidebar(
        key: const ValueKey('sidebar'),
        style: .delta(
          constraints: BoxConstraints.tightFor(width: compact ? 200 : 256),
        ),
        children: [
          for (final group in appMenu)
            FSidebarGroup(
              label: group.label == null ? null : Text(group.label!(l10n)),
              children: [
                for (final e in group.entries)
                  FSidebarItem(
                    key: ValueKey('nav-${e.key}'),
                    icon: Icon(e.icon),
                    label: Text(e.label(l10n)),
                    selected: isSelected(e),
                    onPress: () => context.go(e.path),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
