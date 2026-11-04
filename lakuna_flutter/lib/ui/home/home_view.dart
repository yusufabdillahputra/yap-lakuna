import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' show SelectableText;
import 'package:provider/provider.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../app_root.dart';
import '../../config/app_environment.dart';
import '../../data/repositories/backup_repository.dart';
import '../../data/repositories/dining_repository.dart';
import '../../data/repositories/reports_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/stock_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../routing/routes.dart';
import '../core/format.dart';
import '../core/menu.dart';
import '../login/login_view.dart' show roleLabel;
import 'home_view_model.dart';

/// Beranda (1.10, F1-20): sapaan, penjualan hari ini, grid modul, *Perlu
/// perhatian*, dan info perangkat.
class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.store,
    required this.session,
    this.reports,
    this.stock,
    this.dining,
    this.backup,
    this.clock,
  });

  final StoreRepository store;
  final SessionRepository session;
  final ReportsRepository? reports;
  final StockRepository? stock;
  final DiningRepository? dining;
  final BackupRepository? backup;
  final DateTime Function()? clock;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _vm = HomeViewModel(
    store: widget.store,
    session: widget.session,
    reports: widget.reports,
    stock: widget.stock,
    dining: widget.dining,
    backup: widget.backup,
    clock: widget.clock,
  )..load.execute();

  /// Angka dan sapaan dimuat ulang saat aplikasi kembali dibuka.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () {
      if (!_vm.load.running) _vm.load.execute();
    },
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) => _build(context),
  );

  Widget _build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = _vm;
    final ctx = widget.store.current;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    final name = vm.staffName;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    switch (vm.dayPart) {
                      DayPart.morning => l10n.homeGreetingMorning(name),
                      DayPart.midday => l10n.homeGreetingMidday(name),
                      DayPart.afternoon => l10n.homeGreetingAfternoon(name),
                      DayPart.night => l10n.homeGreetingNight(name),
                    },
                    key: const ValueKey('home-greeting'),
                    style: theme.typography.display.xl2,
                  ),
                  if (ctx != null)
                    Text(
                      '${ctx.tenant.name} · ${ctx.outlet.name}',
                      style: muted,
                    ),
                ],
              ),
              if (AppRestart.maybeOf(context)?.restoreFailed ?? false)
                FAlert(
                  key: const ValueKey('home-restore-failed'),
                  variant: .destructive,
                  icon: const Icon(TablerIcons.alertTriangle),
                  title: Text(l10n.homeRestoreFailedTitle),
                  subtitle: Text(l10n.homeRestoreFailedBody),
                ),
              if (vm.sales case final sales?)
                _SalesCard(
                  total: formatMoney(context, sales.total),
                  detail: l10n.homeSalesTodayDetail(
                    sales.count,
                    formatMoney(context, sales.average),
                  ),
                ),
              if (vm.modules case final modules when modules.isNotEmpty)
                _ModuleGrid(entries: modules),
              ?_attention(context, l10n, vm),
              _DeviceCard(
                l10n: l10n,
                store: widget.store,
                session: widget.session,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _attention(
    BuildContext context,
    AppLocalizations l10n,
    HomeViewModel vm,
  ) {
    final ctx = widget.store.current;
    final tz = ctx?.outlet.timezone ?? ctx?.tenant.timezone;
    final rows = <Widget>[
      if (vm.belowMinimum case final n? when n > 0)
        _AttentionRow(
          kind: 'stock',
          icon: TablerIcons.packages,
          text: l10n.homeAttentionLowStock(n),
          warn: true,
          path: menuEntryByKey('stock')!.path,
        ),
      if (vm.pendingQris case final n? when n > 0)
        _AttentionRow(
          kind: 'qris',
          icon: TablerIcons.qrcode,
          text: l10n.homeAttentionPendingQris(n),
          warn: true,
          path: Routes.tables,
        ),
      if (vm.showBackup)
        _AttentionRow(
          kind: 'backup',
          icon: TablerIcons.databaseExport,
          text: switch ((vm.backupDaysAgo, vm.lastBackupAt)) {
            (null, _) || (_, null) => l10n.homeAttentionBackupNever,
            (0, final at?) => l10n.homeAttentionBackupToday(
              formatClock(at, tz),
            ),
            (1, final at?) => l10n.homeAttentionBackupYesterday(
              formatClock(at, tz),
            ),
            (final d?, _) => l10n.homeAttentionBackupDays(d),
          },
          warn: vm.backupOverdue,
          path: Routes.settingsBackup,
        ),
    ];
    final loaded =
        vm.belowMinimum != null || vm.pendingQris != null || vm.showBackup;
    if (!loaded) return null;
    final theme = context.theme;
    return DecoratedBox(
      key: const ValueKey('home-attention'),
      decoration: BoxDecoration(
        color: theme.colors.card,
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.homeAttentionTitle,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  l10n.homeAttentionClear,
                  key: const ValueKey('home-attention-clear'),
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
              )
            else
              for (final (i, row) in rows.indexed) ...[
                if (i > 0) FDivider(style: .delta(padding: .value(.zero))),
                row,
              ],
          ],
        ),
      ),
    );
  }
}

class _SalesCard extends StatelessWidget {
  const _SalesCard({required this.total, required this.detail});

  final String total;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final fg = theme.colors.primaryForeground;
    return DecoratedBox(
      key: const ValueKey('home-sales'),
      decoration: BoxDecoration(
        color: theme.colors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              l10n.homeSalesTodayTitle,
              style: theme.typography.body.sm.copyWith(color: fg),
            ),
            Text(
              total,
              key: const ValueKey('home-sales-total'),
              style: theme.typography.display.xl2.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              detail,
              key: const ValueKey('home-sales-detail'),
              style: theme.typography.body.sm.copyWith(color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.entries});

  final List<MenuEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Semantics(
      label: l10n.homeModulesLabel,
      container: true,
      child: LayoutBuilder(
        builder: (context, c) {
          final columns = c.maxWidth < 600 ? 4 : 6;
          const gap = 8.0;
          final width = (c.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final e in entries)
                SizedBox(
                  width: width,
                  child: FTappable(
                    key: ValueKey('home-module-${e.key}'),
                    semanticsLabel: e.label(l10n),
                    excludeSemantics: true,
                    onPress: () => context.go(e.path),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        spacing: 6,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colors.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                e.icon,
                                size: 22,
                                color: theme.colors.primary,
                              ),
                            ),
                          ),
                          Text(
                            e.label(l10n),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.typography.body.xs.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({
    required this.kind,
    required this.icon,
    required this.text,
    required this.warn,
    required this.path,
  });

  final String kind;
  final IconData icon;
  final String text;
  final bool warn;
  final String path;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Padding(
      key: ValueKey('home-attention-$kind'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        spacing: 10,
        children: [
          Icon(
            icon,
            size: 20,
            color: warn ? theme.colors.destructive : theme.colors.primary,
          ),
          Expanded(
            child: Text(
              text,
              key: ValueKey('home-attention-$kind-text'),
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          FButton(
            key: ValueKey('home-attention-$kind-view'),
            semanticsLabel: '${l10n.homeAttentionView}: $text',
            variant: .ghost,
            size: .sm,
            mainAxisSize: .min,
            onPress: () => context.go(path),
            child: Text(l10n.homeAttentionView),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.l10n,
    required this.store,
    required this.session,
  });

  final AppLocalizations l10n;
  final StoreRepository store;
  final SessionRepository session;

  @override
  Widget build(BuildContext context) {
    final env = context.read<AppEnvironment>();
    final theme = context.theme;
    final ctx = store.current;
    final staff = session.current;
    return FCard(
      key: const ValueKey('home-device'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              l10n.homeDeviceTitle,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (ctx != null)
              _InfoRow(
                label: l10n.homeStoreLabel,
                value:
                    '${ctx.tenant.name} · ${ctx.outlet.name} · '
                    '${ctx.device.code}',
              ),
            if (staff != null)
              _InfoRow(
                label: l10n.homeStaffLabel,
                value:
                    '${staff.name} · '
                    '${roleLabel(l10n, staff.roleKey, staff.roleName)}',
              ),
            _InfoRow(label: l10n.homeVersionLabel, value: env.version),
            _InfoRow(label: l10n.homeDeviceLabel, value: env.deviceId),
            _InfoRow(label: l10n.homeDataLabel, value: env.databasePath),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        SelectableText(value, style: theme.typography.body.md),
      ],
    );
  }
}
