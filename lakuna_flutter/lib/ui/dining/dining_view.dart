import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/dining_repository.dart';
import '../../data/services/receipt_printer.dart';
import '../../l10n/gen/app_localizations.dart';
import '../cashier/cashier_view_model.dart' show SaleOption, saleOptionsFor;
import '../cashier/payment_view.dart' show tabularFigures;
import '../core/format.dart';
import '../floor_plan/floor_canvas.dart';
import '../products/product_widgets.dart';
import '../receipt/receipt_content.dart' show percentLabel;
import '../receipt/receipt_paper_view.dart';
import 'dining_view_model.dart';
import 'kitchen_ticket.dart';
import 'modifier_sheet.dart';

/// Layar Meja & open bill (1.7 / 1.7e, F1-10). Memiliki [DiningViewModel].
class DiningScreen extends StatefulWidget {
  const DiningScreen({
    super.key,
    required this.repository,
    required this.printer,
    required this.onPay,
    this.onSplit,
    this.onArrange,
    this.initialBill,
  });

  final DiningRepository repository;
  final ReceiptPrinter printer;

  /// *Tutup & bayar*: membuka kasir mode bill.
  final void Function(UuidValue billId) onPay;

  /// *Split bill*: membuka layar split (1.9).
  final void Function(UuidValue billId)? onSplit;

  /// *Atur denah* (1.7d) untuk area denah yang tampil (atau area pertama).
  final void Function(UuidValue? area)? onArrange;

  /// Bill yang langsung dipilih (kembali dari tahap bayar).
  final String? initialBill;

  @override
  State<DiningScreen> createState() => _DiningScreenState();
}

class _DiningScreenState extends State<DiningScreen> {
  late final _viewModel = DiningViewModel(
    repository: widget.repository,
    printer: widget.printer,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _viewModel.load.execute();
    final id = widget.initialBill;
    if (id == null) return;
    final bill = _viewModel.data?.overview.bills
        .where((b) => b.id.uuid == id)
        .firstOrNull;
    if (bill != null) {
      if (bill.isTakeAway) _viewModel.setMode(DiningMode.takeAway);
      _viewModel.select(bill);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DiningView(
    viewModel: _viewModel,
    onPay: widget.onPay,
    onSplit: widget.onSplit,
    onArrange: widget.onArrange,
  );
}

/// Galat aksi bill untuk ditampilkan.
String diningErrorMessage(AppLocalizations l10n, Exception error) =>
    switch (error) {
      BillItemLocked() => l10n.diningErrorLocked,
      SplitLocked() => l10n.diningErrorSplitLocked,
      TableOccupied() => l10n.diningErrorOccupied,
      NothingToSend() => l10n.diningErrorNothingToSend,
      BillNotFound() => l10n.diningErrorNotFound,
      BillNotEmpty() => l10n.diningErrorNotEmpty,
      SaleItemUnavailable() => l10n.diningErrorUnavailable,
      BillInputInvalid(field: BillField.voidReason) =>
        l10n.diningVoidReasonInvalid,
      BillInputInvalid(field: BillField.guests) => l10n.diningGuestsInvalid,
      BillInputInvalid(field: BillField.note) => l10n.diningNoteTooLong,
      BillInputInvalid() => l10n.diningErrorInput,
      NotPermitted() => l10n.diningErrorPermission,
      ModifierSelectionInvalid(error: ModifierSelectionError.unavailable) =>
        l10n.diningErrorModifierSoldOut,
      ModifierSelectionInvalid() => l10n.diningErrorModifierRequired,
      ModifierPriceInvalid() => l10n.diningErrorModifierPrice,
      _ => l10n.diningErrorGeneric,
    };

/// Lama bill terbuka: "35 mnt", "1 j 5 mnt", "2 hari".
String diningDuration(AppLocalizations l10n, Duration d) {
  final minutes = d.inMinutes < 0 ? 0 : d.inMinutes;
  if (minutes < 60) return l10n.diningMinutes(minutes);
  if (minutes < 24 * 60) return l10n.diningHours(minutes ~/ 60, minutes % 60);
  return l10n.diningDays(minutes ~/ (24 * 60));
}

TextStyle _muted(BuildContext context) => context.theme.typography.body.sm
    .copyWith(color: context.theme.colors.mutedForeground);

TextStyle _errorStyle(BuildContext context) => context.theme.typography.body.sm
    .copyWith(color: context.theme.colors.destructive);

// --- Warna status -------------------------------------------------------------

enum _Tone { amber, sky, green, neutral }

(Color, Color) _toneColors(BuildContext context, _Tone tone) {
  final dark = context.theme.colors.brightness == Brightness.dark;
  return switch ((tone, dark)) {
    (_Tone.amber, false) => (const Color(0xFFFEF3C6), const Color(0xFF973C00)),
    (_Tone.amber, true) => (const Color(0xFF461901), const Color(0xFFFFD230)),
    (_Tone.sky, false) => (const Color(0xFFDFF2FE), const Color(0xFF00598A)),
    (_Tone.sky, true) => (const Color(0xFF052F4A), const Color(0xFF74D4FF)),
    (_Tone.green, false) => (const Color(0xFFDCFCE7), const Color(0xFF016630)),
    (_Tone.green, true) => (const Color(0xFF032E15), const Color(0xFF7BF1A8)),
    (_Tone.neutral, _) => (
      context.theme.colors.secondary,
      context.theme.colors.secondaryForeground,
    ),
  };
}

class _Tag extends StatelessWidget {
  const _Tag({super.key, required this.text, required this.tone});

  final String text;
  final _Tone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _toneColors(context, tone);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          text,
          maxLines: 1,
          style: context.theme.typography.body.xs.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

(String, _Tone) _kitchenTag(AppLocalizations l10n, KitchenStatus? status) =>
    switch (status) {
      KitchenStatus.sent => (l10n.diningStatusKitchen, _Tone.sky),
      KitchenStatus.served => (l10n.diningStatusServed, _Tone.green),
      _ => (l10n.diningStatusNew, _Tone.amber),
    };

(String, _Tone) _takeAwayTag(AppLocalizations l10n, TakeAwayState state) =>
    switch (state) {
      TakeAwayState.empty => (l10n.diningStatusEmpty, _Tone.neutral),
      TakeAwayState.pending => (l10n.diningStatusNew, _Tone.amber),
      TakeAwayState.inKitchen => (l10n.diningStatusKitchen, _Tone.sky),
      TakeAwayState.ready => (l10n.diningStatusReady, _Tone.green),
    };

// --- Tampilan utama -----------------------------------------------------------

class DiningView extends StatelessWidget {
  const DiningView({
    super.key,
    required this.viewModel,
    required this.onPay,
    this.onSplit,
    this.onArrange,
    this.clock = DateTime.now,
  });

  final DiningViewModel viewModel;
  final void Function(UuidValue billId) onPay;
  final void Function(UuidValue billId)? onSplit;
  final void Function(UuidValue? area)? onArrange;

  /// Jam untuk lama bill terbuka (bisa diganti di tes).
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final vm = viewModel;
      if (!vm.loaded) {
        if (vm.load.error) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: LoadFailedAlert(
              key: const ValueKey('dining-load-error'),
              message: AppLocalizations.of(context).diningLoadFailed,
              onRetry: vm.load.execute,
            ),
          );
        }
        return const Center(child: FCircularProgress());
      }
      return _TicketListener(
        viewModel: vm,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            final narrow = constraints.maxWidth < 600;
            final selected = vm.selectedBill;
            final main = _MainPane(
              viewModel: vm,
              narrow: narrow,
              clock: clock,
              onArrange: onArrange,
            );
            if (!wide) {
              if (selected == null) return main;
              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) vm.clearSelection();
                },
                child: _BillPanel(
                  viewModel: vm,
                  bill: selected,
                  onPay: onPay,
                  onSplit: onSplit,
                  clock: clock,
                  showBack: true,
                  narrow: narrow,
                ),
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: main),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: context.theme.colors.border),
                    ),
                  ),
                  child: SizedBox(
                    width: 400,
                    child: selected == null
                        ? const _NoSelection()
                        : _BillPanel(
                            viewModel: vm,
                            bill: selected,
                            onPay: onPay,
                            onSplit: onSplit,
                            clock: clock,
                            showBack: false,
                            narrow: false,
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

/// Menampilkan dialog tiket dapur setiap kali kiriman baru berhasil.
class _TicketListener extends StatefulWidget {
  const _TicketListener({required this.viewModel, required this.child});

  final DiningViewModel viewModel;
  final Widget child;

  @override
  State<_TicketListener> createState() => _TicketListenerState();
}

class _TicketListenerState extends State<_TicketListener> {
  KitchenSendResult? _shown;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_check);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_check);
    super.dispose();
  }

  void _check() {
    final ticket = widget.viewModel.lastTicket;
    if (ticket == null || identical(ticket, _shown)) return;
    _shown = ticket;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showFDialog<void>(
        context: context,
        builder: (context, style, animation) => FDialog(
          animation: animation,
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
          builder: (context, style) =>
              _TicketDialog(viewModel: widget.viewModel),
        ),
      );
      _shown = null;
      widget.viewModel.clearTicket();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _NoSelection extends StatelessWidget {
  const _NoSelection();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Icon(
            TablerIcons.receipt,
            size: 32,
            color: context.theme.colors.mutedForeground,
          ),
          Text(
            AppLocalizations.of(context).diningSelectHint,
            key: const ValueKey('dining-select-hint'),
            textAlign: TextAlign.center,
            style: _muted(context),
          ),
        ],
      ),
    ),
  );
}

class _MainPane extends StatelessWidget {
  const _MainPane({
    required this.viewModel,
    required this.narrow,
    required this.clock,
    this.onArrange,
  });

  final DiningViewModel viewModel;
  final bool narrow;
  final DateTime Function() clock;
  final void Function(UuidValue? area)? onArrange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final modes = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoicePill(
          key: const ValueKey('dining-mode-dine-in'),
          label: l10n.diningDineIn,
          selected: vm.mode == DiningMode.dineIn,
          onTap: () => vm.setMode(DiningMode.dineIn),
        ),
        ChoicePill(
          key: const ValueKey('dining-mode-take-away'),
          label: l10n.diningTakeAway,
          selected: vm.mode == DiningMode.takeAway,
          onTap: () => vm.setMode(DiningMode.takeAway),
        ),
        if (vm.hasFloor && vm.mode == DiningMode.dineIn) ...[
          ChoicePill(
            key: const ValueKey('dining-layout-grid'),
            label: l10n.diningLayoutGrid,
            selected: vm.layout == DiningLayout.grid,
            onTap: () => vm.setLayout(DiningLayout.grid),
          ),
          ChoicePill(
            key: const ValueKey('dining-layout-floor'),
            label: l10n.diningLayoutFloor,
            selected: vm.layout == DiningLayout.floor,
            onTap: () => vm.setLayout(DiningLayout.floor),
          ),
        ],
        if (onArrange case final arrange? when vm.canArrange)
          FButton(
            key: const ValueKey('dining-arrange'),
            variant: .outline,
            size: .sm,
            mainAxisSize: .min,
            prefix: const Icon(TablerIcons.layoutBoardSplit, size: 16),
            onPress: () => arrange(
              vm.layout == DiningLayout.floor
                  ? vm.floorArea?.id
                  : vm.areaId ?? vm.areas.firstOrNull?.id,
            ),
            child: Flexible(child: Text(l10n.diningArrange)),
          ),
      ],
    );
    final floor =
        vm.mode == DiningMode.dineIn && vm.layout == DiningLayout.floor;
    final pad = narrow ? 16.0 : 24.0;
    return FloorScrollLock(
      builder: (context, physics) => CustomScrollView(
        physics: physics,
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  PageHeader(
                    title: l10n.diningTitle,
                    subtitle: l10n.diningSubtitle(
                      vm.staffName,
                      vm.occupiedCount,
                      vm.tables.length,
                    ),
                    action: modes,
                  ),
                  if (vm.actionError case final e? when vm.selectedBill == null)
                    Text(
                      diningErrorMessage(l10n, e),
                      key: const ValueKey('dining-action-error'),
                      style: _errorStyle(context),
                    ),
                  if (floor) ...[
                    const _Legend(),
                    _FloorAreaTabs(viewModel: vm),
                  ] else if (vm.mode == DiningMode.dineIn) ...[
                    const _Legend(),
                    if (vm.areas.isNotEmpty) _AreaTabs(viewModel: vm),
                  ] else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FButton(
                        key: const ValueKey('dining-take-away-new'),
                        mainAxisSize: .min,
                        prefix: const Icon(TablerIcons.plus, size: 16),
                        onPress: vm.busy
                            ? null
                            : () => _newTakeAway(context, vm),
                        child: Flexible(child: Text(l10n.diningTakeAwayNew)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(pad),
            sliver: floor
                ? SliverToBoxAdapter(
                    child: _FloorPane(
                      key: ValueKey('dining-floor-${vm.floorArea?.id}'),
                      viewModel: vm,
                      narrow: narrow,
                    ),
                  )
                : vm.mode == DiningMode.dineIn
                ? _TableGrid(viewModel: vm, narrow: narrow, clock: clock)
                : _TakeAwayList(viewModel: vm),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget item(_Tone tone, String label, {bool outline = false}) {
      final (bg, fg) = _toneColors(context, tone);
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: outline ? context.theme.colors.card : bg,
              border: Border.all(
                color: outline ? context.theme.colors.border : fg,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Flexible(child: Text(label, style: _muted(context))),
        ],
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        item(_Tone.neutral, l10n.diningLegendEmpty, outline: true),
        item(_Tone.sky, l10n.diningLegendOpen),
        item(_Tone.amber, l10n.diningLegendRequested),
      ],
    );
  }
}

class _AreaTabs extends StatelessWidget {
  const _AreaTabs({required this.viewModel});

  final DiningViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: [
          ChoicePill(
            key: const ValueKey('dining-area-all'),
            label: l10n.diningAllAreas,
            selected: vm.areaId == null,
            onTap: () => vm.setArea(null),
          ),
          for (final a in vm.areas)
            ChoicePill(
              key: ValueKey('dining-area-${a.id.uuid}'),
              label: a.name,
              selected: vm.areaId == a.id,
              onTap: () => vm.setArea(a.id),
            ),
        ],
      ),
    );
  }
}

class _FloorAreaTabs extends StatelessWidget {
  const _FloorAreaTabs({required this.viewModel});

  final DiningViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: [
          for (final a in vm.floorAreas)
            ChoicePill(
              key: ValueKey('dining-floor-area-${a.name}'),
              label: a.name,
              selected: vm.floorArea?.id == a.id,
              onTap: () => vm.setFloorArea(a.id),
            ),
        ],
      ),
    );
  }
}

/// Denah area terpilih (1.7b): meja terkunci di posisinya, warna status,
/// geser & zoom tampilan saja. Meja tanpa posisi tampil sebagai chip.
class _FloorPane extends StatefulWidget {
  const _FloorPane({super.key, required this.viewModel, required this.narrow});

  final DiningViewModel viewModel;
  final bool narrow;

  @override
  State<_FloorPane> createState() => _FloorPaneState();
}

class _FloorPaneState extends State<_FloorPane> {
  final _canvas = FloorCanvasController();

  @override
  void dispose() {
    _canvas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = widget.viewModel;
    final area = vm.floorArea;
    if (area == null) {
      return Text(l10n.diningNoFloorArea, style: _muted(context));
    }
    final image = vm.floorImage(area);
    final placed = vm.floorTables(area, placed: true);
    final unplaced = vm.floorTables(area, placed: false);
    final byKey = {for (final t in placed) t.id.uuid: t};

    (Color, Color, Color) colors(DiningTable t) {
      final bill = vm.billFor(t);
      final selected = bill != null && vm.selectedBill?.id == bill.id;
      final tone = switch (vm.tableState(t)) {
        TableState.empty => null,
        TableState.open => _Tone.sky,
        TableState.billRequested => _Tone.amber,
      };
      final (bg, fg) = tone == null
          ? (theme.colors.card, theme.colors.foreground)
          : _toneColors(context, tone);
      final border = selected
          ? theme.colors.primary
          : tone == null
          ? theme.colors.border
          : fg;
      return (bg, fg, border);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        SizedBox(
          height: widget.narrow ? 420 : 560,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FloorCanvas(
                      key: const ValueKey('dining-floor-canvas'),
                      controller: _canvas,
                      world: image?.world ?? floorWorldSize(null, null),
                      image: image,
                      tables: [
                        for (final t in placed)
                          FloorTableSpec(
                            key: t.id.uuid,
                            x: t.posX!,
                            y: t.posY ?? 0,
                            width: t.width,
                            height: t.height,
                            shape: t.shape,
                          ),
                      ],
                      tableBuilder: (context, key) {
                        final t = byKey[key];
                        if (t == null) return const SizedBox.shrink();
                        final (bg, fg, border) = colors(t);
                        final bill = vm.billFor(t);
                        return FloorTableBox(
                          key: ValueKey('dining-floor-table-${t.name}'),
                          name: t.name,
                          detail: bill == null
                              ? null
                              : formatMoney(context, bill.charges.total),
                          shape: t.shape,
                          background: bg,
                          foreground: fg,
                          border: border,
                          borderWidth: border == theme.colors.primary
                              ? 2.5
                              : 1.5,
                        );
                      },
                      onTap: (key) {
                        final t = byKey[key];
                        if (t != null && !vm.busy) _tapTable(context, vm, t);
                      },
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colors.background.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: theme.colors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        child: Text(
                          l10n.diningFloorLocked,
                          key: const ValueKey('dining-floor-locked'),
                          style: theme.typography.body.xs.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: FloorZoomControls(controller: _canvas),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (unplaced.isNotEmpty) ...[
          Text(
            l10n.diningUnplaced,
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in unplaced)
                Builder(
                  builder: (context) {
                    final (bg, fg, border) = colors(t);
                    return FTappable(
                      key: ValueKey('dining-unplaced-${t.name}'),
                      semanticsLabel: t.name,
                      onPress: vm.busy ? null : () => _tapTable(context, vm, t),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: bg,
                          border: Border.all(color: border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(
                            t.name,
                            style: theme.typography.body.sm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: fg,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _TableGrid extends StatelessWidget {
  const _TableGrid({
    required this.viewModel,
    required this.narrow,
    required this.clock,
  });

  final DiningViewModel viewModel;
  final bool narrow;
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) {
    final tables = viewModel.visibleTables;
    if (tables.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            AppLocalizations.of(context).diningNoTables,
            key: const ValueKey('dining-no-tables'),
            textAlign: TextAlign.center,
            style: _muted(context),
          ),
        ),
      );
    }
    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: narrow ? 200 : 190,
        mainAxisExtent: 112,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: tables.length,
      itemBuilder: (context, i) =>
          _TableCard(viewModel: viewModel, table: tables[i], clock: clock),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({
    required this.viewModel,
    required this.table,
    required this.clock,
  });

  final DiningViewModel viewModel;
  final DiningTable table;
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final state = vm.tableState(table);
    final bill = vm.billFor(table);
    final selected = bill != null && vm.selectedBill?.id == bill.id;
    final tone = switch (state) {
      TableState.empty => null,
      TableState.open => _Tone.sky,
      TableState.billRequested => _Tone.amber,
    };
    final (bg, fg) = tone == null
        ? (theme.colors.card, theme.colors.foreground)
        : _toneColors(context, tone);
    final info = switch (state) {
      TableState.empty => l10n.diningSeats(table.seats),
      TableState.billRequested => l10n.diningLegendRequested,
      TableState.open => diningDuration(
        l10n,
        clock().difference(bill!.sale.openedAt ?? bill.sale.soldAt),
      ),
    };
    return FTappable(
      key: ValueKey('dining-table-${table.name}'),
      semanticsLabel: table.name,
      selected: selected,
      onPress: vm.busy ? null : () => _tapTable(context, vm, table),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(
            color: selected
                ? theme.colors.primary
                : tone == null
                ? theme.colors.border
                : fg.withValues(alpha: 0.35),
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      table.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.display.lg.copyWith(
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ),
                  if (bill != null)
                    Text(
                      l10n.diningBillGuests(bill.sale.guestCount ?? 0),
                      style: theme.typography.body.xs.copyWith(color: fg),
                    ),
                ],
              ),
              Text(
                bill == null ? ' ' : formatMoney(context, bill.charges.total),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tabularFigures(
                  theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
              Text(
                info,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.xs.copyWith(
                  color: tone == null ? theme.colors.mutedForeground : fg,
                  fontWeight: state == TableState.billRequested
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TakeAwayList extends StatelessWidget {
  const _TakeAwayList({required this.viewModel});

  final DiningViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final list = vm.takeAways;
    if (list.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            l10n.diningTakeAwayNone,
            key: const ValueKey('dining-take-away-none'),
            textAlign: TextAlign.center,
            style: _muted(context),
          ),
        ),
      );
    }
    final timezone = vm.data?.timezone;
    return SliverList.separated(
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final bill = list[i];
        final (tag, tone) = _takeAwayTag(l10n, bill.takeAwayStatus);
        final selected = vm.selectedBill?.id == bill.id;
        final name = bill.sale.customerName?.trim() ?? '';
        return FTappable(
          key: ValueKey('dining-take-away-${bill.label}'),
          semanticsLabel: bill.label,
          selected: selected,
          onPress: () => vm.select(bill),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.card,
              border: Border.all(
                color: selected ? theme.colors.primary : theme.colors.border,
                width: selected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          name.isEmpty ? bill.label : '${bill.label} · $name',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.body.md.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          l10n.diningTakeAwayItems(
                            bill.items.length,
                            formatClock(
                              bill.sale.openedAt ?? bill.sale.soldAt,
                              timezone,
                            ),
                          ),
                          style: _muted(context),
                        ),
                        if (bill.items.isEmpty)
                          FButton(
                            key: ValueKey('dining-delete-empty-${bill.label}'),
                            size: .sm,
                            mainAxisSize: .min,
                            variant: .ghost,
                            prefix: const Icon(TablerIcons.trash, size: 14),
                            onPress: vm.busy
                                ? null
                                : () => vm.deleteEmpty.execute(bill.id),
                            child: Flexible(
                              child: Text(l10n.diningDeleteEmpty),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 6,
                    children: [
                      _Tag(text: tag, tone: tone),
                      if (bill.items.isNotEmpty)
                        Text(
                          formatMoney(context, bill.charges.total),
                          style: tabularFigures(
                            theme.typography.body.sm.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- Panel bill ---------------------------------------------------------------

class _BillPanel extends StatelessWidget {
  const _BillPanel({
    required this.viewModel,
    required this.bill,
    required this.onPay,
    required this.onSplit,
    required this.clock,
    required this.showBack,
    required this.narrow,
  });

  final DiningViewModel viewModel;
  final OpenBill bill;
  final void Function(UuidValue billId) onPay;
  final void Function(UuidValue billId)? onSplit;
  final DateTime Function() clock;
  final bool showBack;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final sale = bill.sale;
    final openedAt = sale.openedAt ?? sale.soldAt;
    final name = sale.customerName?.trim() ?? '';
    final meta = [
      if (!bill.isTakeAway) l10n.diningBillGuests(sale.guestCount ?? 0),
      if (bill.isTakeAway && name.isNotEmpty) name,
      l10n.diningBillOpened(formatClock(openedAt, vm.data?.timezone)),
      diningDuration(l10n, clock().difference(openedAt)),
      if (bill.openedByName.isNotEmpty)
        l10n.diningBillServer(bill.openedByName),
    ].join(' · ');
    final charges = bill.charges;
    final busy = vm.busy;
    final pad = narrow ? 16.0 : 20.0;
    final split = bill.split;
    // Sudah ada pembayaran bagian: item, batal, dan bayar penuh terkunci.
    final locked = split?.locked ?? false;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        if (showBack)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FButton(
              key: const ValueKey('dining-bill-back'),
              size: .sm,
              mainAxisSize: .min,
              variant: .ghost,
              prefix: const Icon(TablerIcons.arrowLeft, size: 16),
              onPress: vm.clearSelection,
              child: Flexible(child: Text(l10n.diningBack)),
            ),
          ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: Text(
                bill.isTakeAway
                    ? l10n.diningBillTakeAwayTitle(bill.label)
                    : l10n.diningBillTableTitle(bill.label),
                key: const ValueKey('dining-bill-title'),
                style: theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            FButton(
              key: const ValueKey('dining-add-menu'),
              size: .sm,
              mainAxisSize: .min,
              variant: .outline,
              prefix: const Icon(TablerIcons.plus, size: 16),
              onPress: busy || locked
                  ? null
                  : () => _openMenu(context, vm, bill),
              child: Flexible(child: Text(l10n.diningAddMenu)),
            ),
          ],
        ),
        Text(meta, style: _muted(context)),
      ],
    );

    final items = bill.items.isEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              l10n.diningBillEmpty,
              key: const ValueKey('dining-bill-empty'),
              textAlign: TextAlign.center,
              style: _muted(context),
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final item in bill.items)
                _BillItemRow(
                  viewModel: vm,
                  item: item,
                  modifiers: bill.modifiersOf(item),
                ),
            ],
          );

    Widget totalRow(String label, Money amount, {bool bold = false}) {
      final style = bold
          ? theme.typography.body.md.copyWith(fontWeight: FontWeight.w800)
          : theme.typography.body.sm;
      return Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(formatMoney(context, amount), style: tabularFigures(style)),
        ],
      );
    }

    final totals = Column(
      key: const ValueKey('dining-bill-totals'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        totalRow(l10n.diningSubtotal, charges.subtotal),
        if (charges.service.value != 0)
          totalRow(
            l10n.diningService(percentLabel(l10n, bill.rates.service.value)),
            charges.service,
          ),
        if (charges.tax.value != 0)
          totalRow(
            l10n.diningTax(percentLabel(l10n, bill.rates.tax.value)),
            charges.tax,
          ),
        totalRow(l10n.diningTotal, charges.total, bold: true),
      ],
    );

    Widget textAction(
      String key,
      String label,
      IconData icon,
      VoidCallback? onPress, {
      bool destructive = false,
    }) => FButton(
      key: ValueKey(key),
      size: .sm,
      mainAxisSize: .min,
      variant: destructive ? .ghost : .ghost,
      prefix: Icon(
        icon,
        size: 16,
        color: destructive && onPress != null ? theme.colors.destructive : null,
      ),
      onPress: onPress,
      child: Flexible(
        child: Text(
          label,
          style: destructive && onPress != null
              ? TextStyle(color: theme.colors.destructive)
              : null,
        ),
      ),
    );

    // Aksi tambahan ikut digulir bersama item; ringkasan, kirim, dan bayar
    // tetap di bawah agar muat di ponsel.
    final secondary = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        if (!bill.isTakeAway)
          FButton(
            key: const ValueKey('dining-request-bill'),
            variant: .outline,
            onPress: busy || bill.items.isEmpty
                ? null
                : () => vm.requestBill.execute(!bill.billRequested),
            child: Flexible(
              child: Text(
                bill.billRequested
                    ? l10n.diningCancelRequest
                    : l10n.diningRequestBill,
              ),
            ),
          ),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            if (!bill.isTakeAway)
              textAction(
                'dining-move',
                l10n.diningMove,
                TablerIcons.arrowsExchange,
                busy ? null : () => _moveBill(context, vm, bill),
              ),
            textAction(
              'dining-split',
              l10n.diningSplit,
              TablerIcons.arrowsSplit,
              busy || bill.items.isEmpty || !vm.canPay || onSplit == null
                  ? null
                  : () => onSplit!(bill.id),
            ),
            if (bill.items.isEmpty)
              textAction(
                'dining-delete-empty',
                l10n.diningDeleteEmpty,
                TablerIcons.trash,
                busy ? null : () => vm.deleteEmpty.execute(bill.id),
                destructive: true,
              )
            else if (vm.canVoid)
              textAction(
                'dining-void',
                l10n.diningVoid,
                TablerIcons.ban,
                busy ? null : () => _voidBill(context, vm, bill),
                destructive: true,
              ),
          ],
        ),
      ],
    );

    final actions = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        if (vm.actionError case final e?)
          Text(
            diningErrorMessage(l10n, e),
            key: const ValueKey('dining-bill-error'),
            style: _errorStyle(context),
          ),
        FButton(
          key: const ValueKey('dining-send'),
          prefix: const Icon(TablerIcons.chefHat, size: 18),
          onPress: busy || bill.pendingCount == 0 ? null : vm.send.execute,
          child: Flexible(
            child: Text(
              l10n.diningSend(bill.pendingCount),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (split != null)
          Text(
            l10n.diningSplitStatus(
              split.parts.where((p) => p.status == SplitPartStatus.paid).length,
              // Nominal bebas: jumlah tamu = bagian yang sudah ada.
              split.mode == SplitKind.amount
                  ? split.parts.length
                  : split.guests,
            ),
            key: const ValueKey('dining-split-status'),
            textAlign: TextAlign.center,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        if (split != null)
          FButton(
            key: const ValueKey('dining-pay'),
            size: .lg,
            onPress: busy || bill.items.isEmpty || onSplit == null
                ? null
                : () => onSplit!(bill.id),
            child: Flexible(
              child: Text(
                // Belum lunas = sisa + QRIS yang masih menunggu.
                l10n.diningContinueSplit(
                  formatMoney(context, split.total - split.paid),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        else
          FButton(
            key: const ValueKey('dining-pay'),
            size: .lg,
            onPress: busy || !vm.canPay || bill.items.isEmpty
                ? null
                : () => onPay(bill.id),
            child: Flexible(
              child: Text(
                l10n.diningPay(formatMoney(context, charges.total)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        if (!vm.canPay)
          Text(
            l10n.diningPayNoPermission,
            textAlign: TextAlign.center,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
      ],
    );

    return ColoredBox(
      color: theme.colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(pad, pad, pad, 12),
              children: [
                header,
                const SizedBox(height: 12),
                const FDivider(),
                items,
                const SizedBox(height: 12),
                secondary,
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.colors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, 12, pad, pad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10,
                  children: [totals, actions],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BillItemRow extends StatelessWidget {
  const _BillItemRow({
    required this.viewModel,
    required this.item,
    this.modifiers = const [],
  });

  final DiningViewModel viewModel;
  final SaleItem item;
  final List<SaleItemModifier> modifiers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final (tag, tone) = _kitchenTag(l10n, item.kitchenStatus);
    final pending =
        item.kitchenStatus == null ||
        item.kitchenStatus == KitchenStatus.pending;
    final busy = vm.busy;
    // Split bill berpembayaran: jumlah item terkunci (F1-10c).
    final locked = vm.selectedBill?.split?.locked ?? false;
    final qty = Qty(item.quantityMilli);
    final name = '${item.productName} ${item.variantName}'.trim();
    final unit = item.productUnitId == null ? '' : ' ${item.unitName}';
    final key = item.id.uuid;
    final modifierText = modifiers.map((m) => m.name).join(', ');

    Widget qtyButton(String k, IconData icon, Qty to, String label) =>
        FButton.icon(
          key: ValueKey(k),
          size: .sm,
          variant: .outline,
          semanticsLabel: label,
          onPress: busy || locked
              ? null
              : () => vm.setQuantity.execute((item.id, to)),
          child: Icon(icon, size: 14),
        );

    return Padding(
      key: ValueKey(
        modifierText.isEmpty
            ? 'dining-item-$name'
            : 'dining-item-$name + $modifierText',
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                '${formatQty(context, qty)}$unit ×',
                style: tabularFigures(
                  theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      name,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.guestLabel case final guest?)
                      Text(
                        l10n.billSplitGuest(guest),
                        key: ValueKey('dining-item-guest-$key'),
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.primary,
                        ),
                      ),
                    if (modifierText.isNotEmpty)
                      Text(
                        '+ $modifierText',
                        key: ValueKey('dining-item-modifiers-$key'),
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    if (item.note case final note? when note.trim().isNotEmpty)
                      Text(
                        '* ${note.trim()}',
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                formatMoney(context, Money(item.lineTotal)),
                style: tabularFigures(
                  theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Row(
            spacing: 6,
            children: [
              _Tag(
                key: ValueKey('dining-item-status-$key'),
                text: tag,
                tone: tone,
              ),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (pending) ...[
                      qtyButton(
                        'dining-item-remove-$key',
                        TablerIcons.trash,
                        Qty.zero,
                        l10n.diningRemoveItem,
                      ),
                      qtyButton(
                        'dining-item-minus-$key',
                        TablerIcons.minus,
                        qty - Qty.one,
                        '−',
                      ),
                      qtyButton(
                        'dining-item-plus-$key',
                        TablerIcons.plus,
                        qty + Qty.one,
                        '+',
                      ),
                    ] else if (item.kitchenStatus == KitchenStatus.sent)
                      FButton(
                        key: ValueKey('dining-item-served-$key'),
                        size: .sm,
                        mainAxisSize: .min,
                        variant: .ghost,
                        prefix: const Icon(TablerIcons.check, size: 14),
                        onPress: busy
                            ? null
                            : () => vm.markServed.execute(item.id),
                        child: Flexible(child: Text(l10n.diningMarkServed)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Dialog -------------------------------------------------------------------

Widget _dialogFrame(
  BuildContext context, {
  required String title,
  String? body,
  required List<Widget> children,
  required List<Widget> actions,
  Key? key,
}) {
  final theme = context.theme;
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          title,
          style: theme.typography.display.lg.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (body != null) Text(body, style: _muted(context)),
        ...children,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: actions,
        ),
      ],
    ),
  );
}

Future<T?> _showDialog<T>(BuildContext context, WidgetBuilder builder) =>
    showFDialog<T>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
        builder: (context, style) => builder(context),
      ),
    );

/// Jumlah tamu untuk membuka [table]; `null` = batal.
/// Ketuk meja (grid atau denah): pilih bill, atau tanya jumlah tamu lalu
/// buka meja kosong.
Future<void> _tapTable(
  BuildContext context,
  DiningViewModel vm,
  DiningTable table,
) async {
  if (vm.tapTable(table)) return;
  final guests = await _askGuests(context, table);
  if (guests != null) await vm.openTable.execute((table.id, guests));
}

Future<int?> _askGuests(BuildContext context, DiningTable table) =>
    _showDialog<int>(context, (context) => _GuestsDialog(table: table));

class _GuestsDialog extends StatefulWidget {
  const _GuestsDialog({required this.table});

  final DiningTable table;

  @override
  State<_GuestsDialog> createState() => _GuestsDialogState();
}

class _GuestsDialogState extends State<_GuestsDialog> {
  late var _text = '${widget.table.seats}';
  var _invalid = false;

  void _submit() {
    final n = int.tryParse(_text.trim());
    if (n == null || n < 1 || n > FnbLimits.guestsMax) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _dialogFrame(
      context,
      key: const ValueKey('dining-guests-dialog'),
      title: l10n.diningOpenTitle(widget.table.name),
      children: [
        FTextField(
          key: const ValueKey('dining-guests'),
          label: Text(l10n.diningGuests),
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          error: _invalid ? Text(l10n.diningGuestsInvalid) : null,
          control: .managed(
            initial: TextEditingValue(
              text: _text,
              selection: TextSelection(
                baseOffset: 0,
                extentOffset: _text.length,
              ),
            ),
            onChange: (v) => _text = v.text,
          ),
          onSubmit: (_) => _submit(),
        ),
      ],
      actions: [
        FButton(
          variant: .outline,
          mainAxisSize: .min,
          onPress: () => Navigator.of(context).pop(),
          child: Flexible(child: Text(l10n.diningCancel)),
        ),
        FButton(
          key: const ValueKey('dining-guests-open'),
          mainAxisSize: .min,
          onPress: _submit,
          child: Flexible(child: Text(l10n.diningOpen)),
        ),
      ],
    );
  }
}

Future<void> _newTakeAway(BuildContext context, DiningViewModel vm) async {
  final name = await _showDialog<String>(
    context,
    (context) => const _TakeAwayDialog(),
  );
  if (name == null) return;
  await vm.openTakeAway.execute(name.trim().isEmpty ? null : name.trim());
}

class _TakeAwayDialog extends StatefulWidget {
  const _TakeAwayDialog();

  @override
  State<_TakeAwayDialog> createState() => _TakeAwayDialogState();
}

class _TakeAwayDialogState extends State<_TakeAwayDialog> {
  var _name = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _dialogFrame(
      context,
      key: const ValueKey('dining-take-away-dialog'),
      title: l10n.diningTakeAwayNew,
      children: [
        FTextField(
          key: const ValueKey('dining-customer-name'),
          label: Text(l10n.diningCustomerName),
          autofocus: true,
          maxLength: FnbLimits.customerName,
          control: .managed(onChange: (v) => _name = v.text),
          onSubmit: (_) => Navigator.of(context).pop(_name),
        ),
      ],
      actions: [
        FButton(
          variant: .outline,
          mainAxisSize: .min,
          onPress: () => Navigator.of(context).pop(),
          child: Flexible(child: Text(l10n.diningCancel)),
        ),
        FButton(
          key: const ValueKey('dining-take-away-create'),
          mainAxisSize: .min,
          onPress: () => Navigator.of(context).pop(_name),
          child: Flexible(child: Text(l10n.diningCreate)),
        ),
      ],
    );
  }
}

Future<void> _moveBill(
  BuildContext context,
  DiningViewModel vm,
  OpenBill bill,
) async {
  final targets = vm.moveTargets;
  final target = await _showDialog<DiningTable>(context, (context) {
    final l10n = AppLocalizations.of(context);
    return _dialogFrame(
      context,
      key: const ValueKey('dining-move-dialog'),
      title: l10n.diningMoveTitle(bill.label),
      children: [
        if (targets.isEmpty)
          Text(l10n.diningMoveNone, style: _muted(context))
        else
          Flexible(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final t in targets)
                    FButton(
                      key: ValueKey('dining-move-to-${t.name}'),
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: () => Navigator.of(context).pop(t),
                      child: Flexible(child: Text(t.name)),
                    ),
                ],
              ),
            ),
          ),
      ],
      actions: [
        FButton(
          variant: .ghost,
          mainAxisSize: .min,
          onPress: () => Navigator.of(context).pop(),
          child: Flexible(child: Text(l10n.diningCancel)),
        ),
      ],
    );
  });
  if (target != null) await vm.move.execute(target.id);
}

Future<void> _voidBill(
  BuildContext context,
  DiningViewModel vm,
  OpenBill bill,
) async {
  final reason = await _showDialog<String>(
    context,
    (context) => _VoidDialog(bill: bill),
  );
  if (reason != null) await vm.voidBill.execute(reason);
}

class _VoidDialog extends StatefulWidget {
  const _VoidDialog({required this.bill});

  final OpenBill bill;

  @override
  State<_VoidDialog> createState() => _VoidDialogState();
}

class _VoidDialogState extends State<_VoidDialog> {
  var _reason = '';
  var _invalid = false;

  void _submit() {
    final text = _reason.trim();
    if (text.isEmpty || text.characters.length > FnbLimits.voidReason) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _dialogFrame(
      context,
      key: const ValueKey('dining-void-dialog'),
      title: l10n.diningVoidTitle(widget.bill.label),
      body: switch (widget.bill.split) {
        final split? when split.paid > Money.zero =>
          '${l10n.diningVoidBody} '
              '${l10n.diningVoidSplitPaid(formatMoney(context, split.paid))}',
        _ => l10n.diningVoidBody,
      },
      children: [
        FTextField(
          key: const ValueKey('dining-void-reason'),
          label: Text(l10n.diningVoidReason),
          autofocus: true,
          maxLength: FnbLimits.voidReason,
          error: _invalid ? Text(l10n.diningVoidReasonInvalid) : null,
          control: .managed(onChange: (v) => _reason = v.text),
          onSubmit: (_) => _submit(),
        ),
      ],
      actions: [
        FButton(
          variant: .outline,
          mainAxisSize: .min,
          onPress: () => Navigator.of(context).pop(),
          child: Flexible(child: Text(l10n.diningVoidKeep)),
        ),
        FButton(
          key: const ValueKey('dining-void-confirm'),
          variant: .destructive,
          mainAxisSize: .min,
          onPress: _submit,
          child: Flexible(child: Text(l10n.diningVoid)),
        ),
      ],
    );
  }
}

// --- Pilih menu ---------------------------------------------------------------

Future<void> _openMenu(
  BuildContext context,
  DiningViewModel vm,
  OpenBill bill,
) {
  // Galat panel lama (mis. tidak ada item baru) tidak ikut ke lembar menu.
  vm.clearActionError();
  return showFDialog<void>(
    context: context,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 760),
      builder: (context, style) => _MenuSheet(viewModel: vm, bill: bill),
    ),
  );
}

class _MenuSheet extends StatefulWidget {
  const _MenuSheet({required this.viewModel, required this.bill});

  final DiningViewModel viewModel;
  final OpenBill bill;

  @override
  State<_MenuSheet> createState() => _MenuSheetState();
}

class _MenuSheetState extends State<_MenuSheet> {
  var _note = '';
  var _noteRev = 0;
  String? _added;

  DiningViewModel get _vm => widget.viewModel;

  Future<void> _add(SaleOption option) async {
    var input = BillItemInput(option, note: _note.trim());
    final groups = _vm.modifierGroupsOf(option.product);
    if (groups.isNotEmpty) {
      final picked = await showModifierSheet(
        context,
        option: option,
        groups: groups,
        note: _note.trim(),
      );
      if (picked == null || !mounted) return;
      input = picked;
    }
    await _vm.addItem.execute(input);
    if (!mounted || !_vm.addItem.completed) return;
    setState(() {
      _added = option.label.isEmpty
          ? option.product.name
          : '${option.product.name} · ${option.label}';
      _note = '';
      _noteRev++;
    });
  }

  Future<void> _tap(CatalogProduct product) async {
    final options = saleOptionsFor(product);
    if (options.length == 1) return _add(options.single);
    final picked = await _showDialog<SaleOption>(
      context,
      (context) => _dialogFrame(
        context,
        title: product.name,
        children: [
          for (final (i, o) in options.indexed)
            FButton(
              key: ValueKey('dining-option-$i'),
              variant: .outline,
              onPress: () => Navigator.of(context).pop(o),
              child: Expanded(
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Text(
                        o.label.isEmpty ? product.baseUnit : o.label,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(formatMoney(context, o.price)),
                  ],
                ),
              ),
            ),
        ],
        actions: [
          FButton(
            variant: .ghost,
            mainAxisSize: .min,
            onPress: () => Navigator.of(context).pop(),
            child: Flexible(
              child: Text(AppLocalizations.of(context).diningCancel),
            ),
          ),
        ],
      ),
    );
    if (picked != null) await _add(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final height = MediaQuery.sizeOf(context).height;
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final vm = _vm;
        final products = vm.menuProducts;
        final error = vm.actionError;
        return SizedBox(
          height: (height * 0.8).clamp(320, 720),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              key: const ValueKey('dining-menu'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  l10n.diningMenuTitle(widget.bill.label),
                  style: theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                FTextField(
                  key: const ValueKey('dining-menu-search'),
                  hint: l10n.diningSearch,
                  prefixBuilder: (context, style, variants) => const Padding(
                    padding: EdgeInsetsDirectional.only(start: 10),
                    child: Icon(TablerIcons.search, size: 16),
                  ),
                  control: .managed(
                    initial: TextEditingValue(text: vm.menuQuery),
                    onChange: (v) => vm.setMenuQuery(v.text),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 8,
                    children: [
                      ChoicePill(
                        key: const ValueKey('dining-menu-category-all'),
                        label: l10n.cashierAllCategories,
                        selected: vm.menuCategory == null,
                        onTap: () => vm.setMenuCategory(null),
                      ),
                      for (final c in vm.menuCategories)
                        ChoicePill(
                          key: ValueKey('dining-menu-category-${c.name}'),
                          label: c.name,
                          dot: categoryColor(c.color),
                          selected: vm.menuCategory == c.id,
                          onTap: () => vm.setMenuCategory(c.id),
                        ),
                    ],
                  ),
                ),
                FTextField(
                  key: ValueKey('dining-menu-note-$_noteRev'),
                  hint: l10n.diningNote,
                  maxLength: FnbLimits.itemNote,
                  control: .managed(onChange: (v) => _note = v.text),
                ),
                Expanded(
                  child: products.isEmpty
                      ? Center(
                          child: Text(
                            l10n.diningNoMenu,
                            style: _muted(context),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 170,
                                mainAxisExtent: 132,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                              ),
                          itemCount: products.length,
                          itemBuilder: (context, i) => _MenuTile(
                            product: products[i],
                            enabled: !vm.addItem.running,
                            onTap: () => _tap(products[i]),
                          ),
                        ),
                ),
                if (error != null)
                  Text(
                    key: const ValueKey('dining-menu-error'),
                    diningErrorMessage(l10n, error),
                    style: _errorStyle(context),
                  )
                else if (_added case final added?)
                  Text(
                    l10n.diningAdded(added),
                    key: const ValueKey('dining-menu-added'),
                    style: _muted(context),
                  ),
                FButton(
                  key: const ValueKey('dining-menu-done'),
                  onPress: () => Navigator.of(context).pop(),
                  child: Flexible(child: Text(l10n.diningDone)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.product,
    required this.enabled,
    required this.onTap,
  });

  final CatalogProduct product;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final prices = product.variants.map((v) => v.sellPrice).toSet();
    final low = prices.reduce((a, b) => a < b ? a : b);
    final price = prices.length == 1
        ? formatMoney(context, low)
        : AppLocalizations.of(context).cashierPriceFrom(
            formatMoney(context, low),
          );
    return FTappable(
      key: ValueKey('dining-menu-${product.name}'),
      semanticsLabel: product.name,
      onPress: enabled ? onTap : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.card,
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              // Dialog beranimasi dari ukuran kecil: gambar ikut menyusut.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final size = c.biggest.shortestSide.clamp(0.0, 44.0);
                    return Align(
                      alignment: Alignment.topLeft,
                      child: size < 20
                          ? const SizedBox.shrink()
                          : ProductThumb(name: product.name, size: size),
                    );
                  },
                ),
              ),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                price,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tabularFigures(
                  theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w800,
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

// --- Tiket dapur --------------------------------------------------------------

class _TicketDialog extends StatelessWidget {
  const _TicketDialog({required this.viewModel});

  final DiningViewModel viewModel;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = viewModel;
      final ticket = vm.lastTicket;
      if (ticket == null) return const SizedBox.shrink();
      final lines = kitchenTicketLines(
        l10n,
        result: ticket,
        timezone: vm.data?.timezone,
        paper: vm.paper,
      );
      final height = MediaQuery.sizeOf(context).height;
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          key: const ValueKey('dining-ticket'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              l10n.ticketDialogTitle,
              style: theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height * 0.55),
              child: SingleChildScrollView(
                child: ReceiptPaperView(lines: lines, paper: vm.paper),
              ),
            ),
            if (vm.printFailure != null ||
                (vm.printTicket.error && vm.printFailure == null))
              Text(
                l10n.ticketPrintFailed,
                key: const ValueKey('dining-ticket-print-failed'),
                style: _errorStyle(context),
              )
            else if (vm.ticketPrinted)
              Text(l10n.ticketPrinted, style: _muted(context)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                FButton(
                  key: const ValueKey('dining-ticket-close'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(context).pop(),
                  child: Flexible(child: Text(l10n.ticketClose)),
                ),
                FButton(
                  key: const ValueKey('dining-ticket-print'),
                  mainAxisSize: .min,
                  prefix: const Icon(TablerIcons.printer, size: 16),
                  onPress: vm.printTicket.running
                      ? null
                      : () => vm.printTicket.execute(lines),
                  child: Flexible(child: Text(l10n.ticketPrint)),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
