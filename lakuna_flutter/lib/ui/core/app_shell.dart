import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lakuna_client/lakuna_client.dart' show Outlet;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../config/app_platform.dart';
import '../../data/repositories/hosting_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../utils/result.dart';
import '../../l10n/gen/app_localizations.dart';
import '../login/login_view.dart' show roleLabel;
import 'breakpoints.dart';
import 'menu.dart';
import '../../routing/routes.dart';
import '../hosting/sync_status_chip.dart';
import '../web/web_session_ended_view.dart' show signOutWeb;

/// Kerangka aplikasi: bilah atas (dengan staf bertugas dan *Ganti kasir*),
/// sidebar (tablet/desktop) atau navigasi bawah (mobile), dan isi halaman.
/// Menu disaring sesuai izin staf yang bertugas.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.location,
    required this.session,
    required this.child,
    this.canSwitch,
    this.hosting,
    this.timezone,
    this.platform = AppPlatform.native,
    this.store,
  });

  /// Versi hosting (F2-01): chip status menggantikan *Offline · data di
  /// perangkat ini* saat aktif.
  final HostingRepository? hosting;

  /// Web menyembunyikan menu perangkat (F2-02 aturan 3).
  final AppPlatform platform;

  /// Toko untuk pemilih cabang di web (F2-02 aturan 2a).
  final StoreRepository? store;

  /// Zona waktu cabang untuk jam *Tersinkron · 14.32*.
  final String? timezone;

  /// Jalur yang sedang dibuka, untuk menandai menu terpilih.
  final String location;
  final SessionRepository session;
  final Widget child;

  /// Halaman yang terbuka boleh ditinggalkan sebelum *Ganti kasir*
  /// (F1-02b); `null` = langsung ganti.
  final Future<bool> Function()? canSwitch;

  /// *Ganti kasir*: form yang berubah ditanyakan dulu (F1-02b).
  Future<void> _switchCashier() async {
    final canSwitch = this.canSwitch;
    if (canSwitch != null && !await canSwitch()) return;
    session.logout();
  }

  /// *Keluar* di web: form yang berubah ditanyakan dulu, lalu sesi
  /// browser diakhiri (F2-02 aturan 5).
  Future<void> _signOutWeb(BuildContext context) async {
    final canSwitch = this.canSwitch;
    if (canSwitch != null && !await canSwitch()) return;
    if (!context.mounted) return;
    await signOutWeb(context, hosting: hosting!);
  }

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
                child: SyncStatusChip(
                  repository: hosting,
                  compact: size != LayoutSize.desktop,
                  timezone: timezone,
                  onOpen: permissions.contains(Permission.syncManage)
                      ? () => context.go('${Routes.settings}?bagian=hosting')
                      : null,
                ),
              ),
              if (platform.isWeb && store != null)
                _OutletPicker(store: store!, canSwitch: canSwitch),
              if (platform.isWeb && hosting != null)
                FTooltip(
                  tipBuilder: (context, _) => Text(l10n.webLogout),
                  child: FButton.icon(
                    key: const ValueKey('web-logout'),
                    variant: .ghost,
                    onPress: () => unawaited(_signOutWeb(context)),
                    child: Icon(
                      TablerIcons.logout,
                      semanticLabel: l10n.webLogout,
                    ),
                  ),
                ),
              if (staff != null && platform.supportsCashier)
                _StaffSwitcher(
                  staff: staff,
                  // Tablet sempit: sidebar 200 px menyisakan sedikit ruang.
                  compact: constraints.maxWidth < 900,
                  onSwitch: () => unawaited(_switchCashier()),
                ),
            ],
          );
          if (mobile) {
            final items = mobileMenu(permissions, platform: platform);
            final more = mobileMoreMenu(permissions, platform: platform);
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
              groups: visibleMenu(permissions, platform: platform),
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

/// Pemilih cabang di bilah atas web (F2-02 aturan 2a): tampil bila tenant
/// punya lebih dari satu cabang. Form yang belum disimpan ditanyakan
/// lebih dulu lewat [canSwitch].
class _OutletPicker extends StatefulWidget {
  const _OutletPicker({required this.store, this.canSwitch});

  final StoreRepository store;
  final Future<bool> Function()? canSwitch;

  @override
  State<_OutletPicker> createState() => _OutletPickerState();
}

class _OutletPickerState extends State<_OutletPicker> {
  var _outlets = const <Outlet>[];

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final result = await widget.store.outlets();
    if (!mounted) return;
    if (result case Ok(:final value)) setState(() => _outlets = value);
  }

  Future<void> _pick() async {
    final l10n = AppLocalizations.of(context);
    final current = widget.store.current?.outlet.id;
    final picked = await showFDialog<Outlet>(
      context: context,
      useRootNavigator: true,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
        builder: (context, style) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('outlet-picker-dialog'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text(
                l10n.webOutletPickerTitle,
                style: context.theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              for (final o in _outlets)
                FTile(
                  key: ValueKey('outlet-${o.code}'),
                  title: Text(o.name),
                  subtitle: Text(o.code),
                  suffix: o.id == current
                      ? const Icon(TablerIcons.check)
                      : null,
                  onPress: () => Navigator.of(context).pop(o),
                ),
              FButton(
                variant: .outline,
                onPress: () => Navigator.of(context).pop(),
                child: Text(l10n.webOutletPickerCancel),
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || picked.id == current) return;
    final canSwitch = widget.canSwitch;
    if (canSwitch != null && !await canSwitch()) return;
    final result = await widget.store.switchOutlet(picked.id);
    // Halaman yang terbuka memegang data cabang lama: mulai lagi dari
    // Beranda cabang baru.
    if (result is Ok && mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    if (_outlets.length < 2) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final name = widget.store.current?.outlet.name ?? '';
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Semantics(
            label: l10n.webOutletPickerLabel(name),
            child: FButton(
              key: const ValueKey('outlet-picker'),
              variant: .outline,
              size: .sm,
              mainAxisSize: .min,
              prefix: const Icon(TablerIcons.buildingStore),
              onPress: () => unawaited(_pick()),
              child: Text(name, overflow: TextOverflow.ellipsis),
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
