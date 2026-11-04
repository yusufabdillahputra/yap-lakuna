import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/session_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../login/login_view.dart' show roleLabel;
import 'breakpoints.dart';
import 'menu.dart';
import 'offline_badge.dart';

/// Kerangka aplikasi: bilah atas (dengan staf bertugas dan *Ganti kasir*),
/// sidebar (tablet/desktop) atau navigasi bawah (mobile), dan isi halaman.
/// Menu disaring sesuai izin staf yang bertugas.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.location,
    required this.session,
    required this.child,
  });

  /// Jalur yang sedang dibuka, untuk menandai menu terpilih.
  final String location;
  final SessionRepository session;
  final Widget child;

  bool _isSelected(MenuEntry e) =>
      e.path == '/' ? location == '/' : location.startsWith(e.path);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final size = LayoutSize.of(constraints.maxWidth);
          final mobile = size == LayoutSize.mobile;
          final staff = session.current;
          final permissions = staff?.permissions ?? const <Permission>{};
          final header = FHeader(
            title: Text(l10n.appTitle, overflow: TextOverflow.ellipsis),
            suffixes: [
              Center(
                child: OfflineBadge(compact: size != LayoutSize.desktop),
              ),
              if (staff != null)
                _StaffSwitcher(
                  staff: staff,
                  // Tablet sempit: sidebar 200 px menyisakan sedikit ruang.
                  compact: constraints.maxWidth < 900,
                  onSwitch: session.logout,
                ),
            ],
          );
          if (mobile) {
            final items = mobileMenu(permissions);
            final more = mobileMoreMenu(permissions);
            final primary = items.indexWhere(_isSelected);
            final inMore = more.expand((g) => g.entries).any(_isSelected);
            return FScaffold(
              header: header,
              footer: FBottomNavigationBar(
                index: primary >= 0 ? primary : (inMore ? items.length : -1),
                onChange: (i) {
                  if (i < items.length) {
                    context.go(items[i].path);
                  } else {
                    _showMore(context, more);
                  }
                },
                children: [
                  for (final e in items)
                    FBottomNavigationBarItem(
                      key: ValueKey('nav-${e.key}'),
                      icon: Icon(e.icon),
                      label: Text(e.label(l10n)),
                    ),
                  if (more.isNotEmpty)
                    FBottomNavigationBarItem(
                      key: const ValueKey('nav-more'),
                      icon: const Icon(TablerIcons.dots),
                      label: Text(l10n.menuMore),
                    ),
                ],
              ),
              child: child,
            );
          }
          return FScaffold(
            header: header,
            sidebar: _Sidebar(
              groups: visibleMenu(permissions),
              compact: size == LayoutSize.tablet,
              isSelected: _isSelected,
            ),
            child: child,
          );
        },
      ),
    );
  }

  /// Lembar *Lainnya* (mobile): menu yang tidak muat di navigasi bawah.
  void _showMore(BuildContext context, List<MenuGroup> groups) {
    showFSheet<void>(
      context: context,
      side: .btt,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        final theme = sheetContext.theme;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.background,
            border: Border.all(color: theme.colors.border),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                key: const ValueKey('more-sheet'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 4,
                children: [
                  for (final group in groups) ...[
                    if (group.label case final label?)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                        child: Text(
                          label(l10n),
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.mutedForeground,
                          ),
                        ),
                      ),
                    for (final e in group.entries)
                      FItem(
                        key: ValueKey('more-${e.key}'),
                        prefix: Icon(e.icon),
                        title: Text(e.label(l10n)),
                        selected: _isSelected(e),
                        onPress: () {
                          Navigator.of(sheetContext).pop();
                          context.go(e.path);
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Staf yang bertugas dan tombol *Ganti kasir* (ikon saja di mobile).
class _StaffSwitcher extends StatelessWidget {
  const _StaffSwitcher({
    required this.staff,
    required this.compact,
    required this.onSwitch,
  });

  final StaffProfile staff;
  final bool compact;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(left: 8),
        child: FButton.icon(
          key: const ValueKey('switch-cashier'),
          semanticsLabel: '${l10n.switchCashier} (${staff.name})',
          onPress: onSwitch,
          child: const Icon(TablerIcons.switchHorizontal),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FAvatar.raw(size: 32, child: Text(staffInitials(staff.name))),
          const SizedBox(width: 8),
          Column(
            key: const ValueKey('active-staff'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                staff.name,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colors.foreground,
                ),
              ),
              Text(
                roleLabel(l10n, staff.roleKey, staff.roleName),
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          FButton(
            key: const ValueKey('switch-cashier'),
            variant: .outline,
            size: .sm,
            mainAxisSize: .min,
            prefix: const Icon(TablerIcons.switchHorizontal),
            onPress: onSwitch,
            child: Text(l10n.switchCashier),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.groups,
    required this.compact,
    required this.isSelected,
  });

  final List<MenuGroup> groups;
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
          for (final group in groups)
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
