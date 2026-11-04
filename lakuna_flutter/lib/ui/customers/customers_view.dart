import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/customers_repository.dart';
import '../../data/services/table_file.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import '../products/product_widgets.dart';
import 'customer_form_dialog.dart';
import 'customer_import_dialog.dart';
import 'customer_labels.dart';
import 'customer_panel_view.dart';
import 'customer_panel_view_model.dart';
import 'customers_view_model.dart';

/// Lebar minimum untuk daftar + panel pelanggan berdampingan (1.20).
const customersTwoPaneWidth = 1000.0;

const _tabular = [FontFeature.tabularFigures()];

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

/// Warna kotak piutang (kuning lembut) di terang dan gelap.
(Color, Color) debtTone(BuildContext context) =>
    context.theme.colors.brightness == Brightness.dark
    ? (const Color(0xFF461901), const Color(0xFFFFD230))
    : (const Color(0xFFFEF3C6), const Color(0xFF973C00));

/// Layar *Pelanggan & piutang* (1.20, F1-13): daftar pelanggan dengan
/// piutang, panel terima pembayaran di samping pada layar lebar.
class CustomersScreen extends StatefulWidget {
  const CustomersScreen({
    super.key,
    required this.repository,
    required this.onOpenCustomer,
    required this.onOpenReceipt,
    this.tablePicker = const FileSelectorTablePicker(),
  });

  final CustomersRepository repository;

  /// Layar sempit: membuka `/pelanggan/:id`; selesai saat kembali.
  final Future<void> Function(UuidValue id) onOpenCustomer;

  /// Membuka kuitansi pembayaran [paymentId]; [copy] = cetak ulang.
  final Future<void> Function(UuidValue paymentId, {bool copy}) onOpenReceipt;
  final TableFilePicker tablePicker;

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late final _list = CustomersViewModel(repository: widget.repository);
  CustomerPanelViewModel? _panel;

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
    if (_panel?.customerId == id) return;
    final old = _panel;
    _list.select(id);
    setState(() {
      _panel = CustomerPanelViewModel(
        repository: widget.repository,
        customerId: id,
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
    await widget.onOpenCustomer(id);
    if (mounted) await _list.refresh();
  }

  Future<void> _new(bool twoPane) async {
    final saved = await showCustomerForm(context, widget.repository);
    if (saved == null || !mounted) return;
    await _list.refresh();
    if (twoPane) _select(saved.id);
  }

  Future<void> _import() async {
    final done = await showCustomerImport(
      context,
      widget.repository,
      picker: widget.tablePicker,
    );
    if (done && mounted) await _list.refresh();
  }

  Future<void> _received(DebtPayment payment) async {
    unawaited(_list.refresh());
    await widget.onOpenReceipt(payment.id);
    // Pengguna bisa pindah menu saat kuitansi terbuka.
    if (!mounted) return;
    await _list.refresh();
    await _panel?.load.execute();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final twoPane = constraints.maxWidth >= customersTwoPaneWidth;
      return ListenableBuilder(
        listenable: _list,
        builder: (context, _) {
          final l10n = AppLocalizations.of(context);
          final list = _CustomerList(
            viewModel: _list,
            selected: twoPane ? _list.selected : null,
            onOpen: (id) => _open(id, twoPane),
          );
          final panel = _panel;
          return SingleChildScrollView(
            key: const ValueKey('customers-scroll'),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                PageHeader(
                  title: l10n.customersTitle,
                  subtitle: l10n.customersSubtitle(
                    _list.overview?.rows.length ?? 0,
                  ),
                  action: _list.canManage
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FButton(
                              key: const ValueKey('customers-import'),
                              variant: .outline,
                              mainAxisSize: .min,
                              onPress: _import,
                              prefix: const Icon(TablerIcons.fileImport),
                              child: Flexible(
                                child: Text(l10n.customersImport),
                              ),
                            ),
                            FButton(
                              key: const ValueKey('customers-new'),
                              mainAxisSize: .min,
                              onPress: () => _new(twoPane),
                              prefix: const Icon(TablerIcons.plus),
                              child: Flexible(child: Text(l10n.customersNew)),
                            ),
                          ],
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
                            : CustomerPanel(
                                key: ObjectKey(panel),
                                repository: widget.repository,
                                viewModel: panel,
                                onChanged: _list.refresh,
                                onDeleted: () {
                                  _clearPanel();
                                  unawaited(_list.refresh());
                                },
                                onReceived: _received,
                                onOpenReceipt: (id) =>
                                    widget.onOpenReceipt(id, copy: true),
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
      key: const ValueKey('customers-pick-hint'),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          spacing: 12,
          children: [
            Icon(
              TablerIcons.users,
              size: 32,
              color: context.theme.colors.mutedForeground,
            ),
            Text(
              empty ? l10n.customersEmpty : l10n.customersSelectHint,
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

class _CustomerList extends StatelessWidget {
  const _CustomerList({
    required this.viewModel,
    required this.selected,
    required this.onOpen,
  });

  final CustomersViewModel viewModel;
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
          key: const ValueKey('customers-search'),
          hint: l10n.customersSearch,
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
            key: const ValueKey('customers-load-error'),
            message: l10n.customersLoadFailed,
            onRetry: vm.refresh,
          ),
        if (overview == null)
          if (vm.error == null)
            const Center(child: FCircularProgress())
          else
            const SizedBox.shrink()
        else if (rows.isEmpty)
          FCard(
            key: const ValueKey('customers-empty'),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                overview.rows.isEmpty
                    ? l10n.customersEmpty
                    : l10n.customersNoMatch,
                textAlign: TextAlign.center,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          )
        else
          DecoratedBox(
            key: const ValueKey('customers-table'),
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
                          flex: 46,
                          child: Text(l10n.customersColCustomer, style: head),
                        ),
                        Expanded(
                          flex: 22,
                          child: Text(l10n.customersColGroup, style: head),
                        ),
                        Expanded(
                          flex: 32,
                          child: Text(
                            l10n.customersColDebt,
                            style: head,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                for (final r in rows)
                  _CustomerRowTile(
                    row: r,
                    selected: r.customer.id == selected,
                    onTap: () => onOpen(r.customer.id),
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

class _CustomerRowTile extends StatelessWidget {
  const _CustomerRowTile({
    required this.row,
    required this.selected,
    required this.onTap,
  });

  final CustomerRow row;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final c = row.customer;
    final debt = row.outstanding > Money.zero;
    final sub = [
      if (c.phone case final p?) formatPhone(p),
      if (row.overdueCount > 0) l10n.customerOverdueCount(row.overdueCount),
    ].join(' · ');
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? theme.colors.primary.withValues(alpha: 0.08)
            : const Color(0x00000000),
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: FTappable(
        key: ValueKey('customers-row-${c.id.uuid}'),
        onPress: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            spacing: 8,
            children: [
              Expanded(
                flex: 46,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
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
                        style: row.overdueCount > 0
                            ? _muted(
                                context,
                              ).copyWith(color: theme.colors.destructive)
                            : _muted(context),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 22,
                child: Text(
                  row.groupName ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm,
                ),
              ),
              Expanded(
                flex: 32,
                child: Text(
                  formatMoney(context, row.outstanding),
                  textAlign: TextAlign.end,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: debt ? FontWeight.w700 : null,
                    color: debt ? null : theme.colors.mutedForeground,
                    fontFeatures: _tabular,
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

  final CustomersOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final (bg, fg) = debtTone(context);
    return DecoratedBox(
      key: const ValueKey('customers-total'),
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
              l10n.customersTotalDebt,
              style: theme.typography.body.xs.copyWith(color: fg),
            ),
            Text(
              formatMoney(context, overview.totalOutstanding),
              style: theme.typography.display.xl.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
                fontFeatures: _tabular,
              ),
            ),
            Text(
              l10n.customersTotalDebtSub(
                overview.debtorCount,
                overview.overdueCount,
              ),
              style: theme.typography.body.xs.copyWith(color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
