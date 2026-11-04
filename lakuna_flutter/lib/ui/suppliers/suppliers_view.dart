import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/suppliers_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import '../customers/customer_labels.dart' show formatPhone;
import '../customers/customers_view.dart' show debtTone;
import '../products/product_widgets.dart';
import '../purchases/purchase_labels.dart' show formatCalendarDayMonth;
import 'supplier_form_dialog.dart';
import 'supplier_panel_view.dart';
import 'supplier_panel_view_model.dart';
import 'suppliers_view_model.dart';

/// Lebar minimum untuk daftar + panel supplier berdampingan (1.21).
const suppliersTwoPaneWidth = 1000.0;

const _tabular = [FontFeature.tabularFigures()];

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

/// Layar *Supplier & hutang* (1.21, F1-14): daftar supplier dengan hutang,
/// panel bayar hutang di samping pada layar lebar.
class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({
    super.key,
    required this.repository,
    required this.onOpenSupplier,
    required this.onOpenPurchase,
    this.imagePicker = const FileSelectorImagePicker(),
  });

  final SuppliersRepository repository;

  /// Layar sempit: membuka `/supplier/:id`; selesai saat kembali.
  final Future<void> Function(UuidValue id) onOpenSupplier;

  /// Membuka detail pembelian; selesai saat kembali.
  final Future<void> Function(UuidValue purchaseId) onOpenPurchase;
  final ImageFilePicker imagePicker;

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  late final _list = SuppliersViewModel(repository: widget.repository);
  SupplierPanelViewModel? _panel;

  @override
  void initState() {
    super.initState();
    _list.load.execute();
  }

  @override
  void dispose() {
    _list.dispose();
    _panel?.dispose();
    super.dispose();
  }

  void _select(UuidValue id) {
    if (_panel?.supplierId == id) return;
    final old = _panel;
    _list.select(id);
    setState(() {
      _panel = SupplierPanelViewModel(
        repository: widget.repository,
        supplierId: id,
        picker: widget.imagePicker,
      )..load.execute();
    });
    old?.dispose();
  }

  void _clearPanel() {
    final old = _panel;
    _list.select(null);
    setState(() => _panel = null);
    old?.dispose();
  }

  Future<void> _open(UuidValue id, bool twoPane) async {
    if (twoPane) {
      _select(id);
      return;
    }
    await widget.onOpenSupplier(id);
    if (mounted) await _list.refresh();
  }

  Future<void> _new(bool twoPane) async {
    final saved = await showSupplierForm(context, widget.repository);
    if (saved == null || !mounted) return;
    await _list.refresh();
    if (twoPane) _select(saved.id);
  }

  Future<void> _openPurchase(UuidValue id) async {
    await widget.onOpenPurchase(id);
    // Pengguna bisa pindah menu saat detail pembelian terbuka.
    if (!mounted) return;
    await _list.refresh();
    await _panel?.load.execute();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final twoPane = constraints.maxWidth >= suppliersTwoPaneWidth;
      return ListenableBuilder(
        listenable: _list,
        builder: (context, _) {
          final l10n = AppLocalizations.of(context);
          final list = _SupplierList(
            viewModel: _list,
            selected: twoPane ? _list.selected : null,
            onOpen: (id) => _open(id, twoPane),
          );
          final panel = _panel;
          return SingleChildScrollView(
            key: const ValueKey('suppliers-scroll'),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                PageHeader(
                  title: l10n.suppliersTitle,
                  subtitle: l10n.suppliersSubtitle(
                    _list.overview?.rows.length ?? 0,
                  ),
                  action: _list.canManage
                      ? FButton(
                          key: const ValueKey('suppliers-new'),
                          mainAxisSize: .min,
                          onPress: () => _new(twoPane),
                          prefix: const Icon(TablerIcons.plus),
                          child: Flexible(child: Text(l10n.suppliersNew)),
                        )
                      : null,
                ),
                if (twoPane)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      Expanded(flex: 37, child: list),
                      Expanded(
                        flex: 63,
                        child: panel == null
                            ? _PickHint(
                                empty:
                                    (_list.overview?.rows ?? const []).isEmpty,
                              )
                            : SupplierPanel(
                                key: ObjectKey(panel),
                                repository: widget.repository,
                                viewModel: panel,
                                onChanged: _list.refresh,
                                onDeleted: () {
                                  _clearPanel();
                                  unawaited(_list.refresh());
                                },
                                onOpenPurchase: _openPurchase,
                              ),
                      ),
                    ],
                  )
                else
                  list,
              ],
            ),
          );
        },
      );
    },
  );
}

class _PickHint extends StatelessWidget {
  const _PickHint({required this.empty});

  final bool empty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FCard(
      key: const ValueKey('suppliers-pick-hint'),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          spacing: 12,
          children: [
            Icon(
              TablerIcons.truckDelivery,
              size: 32,
              color: context.theme.colors.mutedForeground,
            ),
            Text(
              empty ? l10n.suppliersEmpty : l10n.suppliersSelectHint,
              textAlign: TextAlign.center,
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupplierList extends StatelessWidget {
  const _SupplierList({
    required this.viewModel,
    required this.selected,
    required this.onOpen,
  });

  final SuppliersViewModel viewModel;
  final UuidValue? selected;
  final void Function(UuidValue id) onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final overview = vm.overview;
    final rows = vm.rows;
    final head = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
      fontWeight: FontWeight.w600,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        FTextField(
          key: const ValueKey('suppliers-search'),
          hint: l10n.suppliersSearch,
          prefixBuilder: (context, style, _) => Padding(
            padding: const EdgeInsetsDirectional.only(start: 12),
            child: Icon(
              TablerIcons.search,
              size: 18,
              color: theme.colors.mutedForeground,
            ),
          ),
          control: .managed(onChange: (v) => vm.setQuery(v.text)),
        ),
        if (vm.error != null)
          LoadFailedAlert(
            key: const ValueKey('suppliers-load-error'),
            message: l10n.suppliersLoadFailed,
            onRetry: vm.refresh,
          ),
        if (overview == null)
          if (vm.error == null)
            const Center(child: FCircularProgress())
          else
            const SizedBox.shrink()
        else if (rows.isEmpty)
          FCard(
            key: const ValueKey('suppliers-empty'),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                overview.rows.isEmpty
                    ? l10n.suppliersEmpty
                    : l10n.suppliersNoMatch,
                textAlign: TextAlign.center,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          )
        else
          DecoratedBox(
            key: const ValueKey('suppliers-table'),
            decoration: BoxDecoration(
              color: theme.colors.card,
              border: Border.all(color: theme.colors.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colors.muted,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      spacing: 8,
                      children: [
                        Expanded(
                          flex: 64,
                          child: Text(l10n.suppliersColSupplier, style: head),
                        ),
                        Expanded(
                          flex: 36,
                          child: Text(
                            l10n.suppliersColDebt,
                            style: head,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                for (final r in rows)
                  _SupplierRowTile(
                    row: r,
                    selected: r.supplier.id == selected,
                    onTap: () => onOpen(r.supplier.id),
                  ),
              ],
            ),
          ),
        if (overview != null && overview.rows.isNotEmpty)
          _TotalCard(overview: overview),
      ],
    );
  }
}

class _SupplierRowTile extends StatelessWidget {
  const _SupplierRowTile({
    required this.row,
    required this.selected,
    required this.onTap,
  });

  final SupplierRow row;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final s = row.supplier;
    final debt = row.debt > Money.zero;
    final sub = [
      ?s.category,
      if (s.phone case final p?) formatPhone(p),
    ].join(' · ');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? theme.colors.primary.withValues(alpha: 0.08)
            : const Color(0x00000000),
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: FTappable(
        key: ValueKey('suppliers-row-${s.id.uuid}'),
        onPress: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                flex: 64,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (sub.isNotEmpty)
                      Text(
                        sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _muted(context),
                      ),
                    if (row.overdueCount > 0)
                      Text(
                        l10n.suppliersOverdueCount(row.overdueCount),
                        style: _muted(
                          context,
                        ).copyWith(color: theme.colors.destructive),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 36,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatMoney(context, row.debt),
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: debt ? FontWeight.w700 : null,
                      color: debt ? null : theme.colors.mutedForeground,
                      fontFeatures: _tabular,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.overview});

  final SuppliersOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final (bg, fg) = debtTone(context);
    final due = overview.nearestDue;
    final sub = [
      if (due == null)
        l10n.suppliersNoDue
      else
        l10n.suppliersNearestDue(formatCalendarDayMonth(due)),
      if (overview.overdueCount > 0)
        l10n.suppliersOverdueCount(overview.overdueCount),
    ].join(' · ');
    return DecoratedBox(
      key: const ValueKey('suppliers-total'),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              l10n.suppliersTotalDebt,
              style: theme.typography.body.xs.copyWith(color: fg),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formatMoney(context, overview.totalDebt),
                maxLines: 1,
                style: theme.typography.display.xl.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontFeatures: _tabular,
                ),
              ),
            ),
            Text(sub, style: theme.typography.body.xs.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }
}
