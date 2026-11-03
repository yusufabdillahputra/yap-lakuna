import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/dining_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../cashier/payment_view.dart'
    show billOrderLabel, paymentMethodLabel, tabularFigures;
import '../core/format.dart';
import '../products/product_widgets.dart' show ChoicePill, PageHeader;
import '../receipt/receipt_content.dart' show percentLabel;
import 'split_bill_view_model.dart';

/// Pesan galat aksi split bill.
String splitErrorMessage(
  AppLocalizations l10n,
  Exception error,
) => switch (error) {
  SplitLocked() => l10n.billSplitErrorLocked,
  SplitInvalid(error: SplitError.guests) => l10n.billSplitErrorGuests,
  SplitInvalid(error: SplitError.unassigned) => l10n.billSplitErrorUnassigned,
  SplitInvalid(error: SplitError.partPaid) => l10n.billSplitErrorPartPaid,
  SplitInvalid(error: SplitError.amount) => l10n.billSplitErrorAmount,
  SplitInvalid(error: SplitError.nothingDue) => l10n.billSplitErrorNothingDue,
  SplitInvalid(error: SplitError.pending) => l10n.billSplitErrorPending,
  CashSessionNotOpen() => l10n.paymentErrorSession,
  NotPermitted() => l10n.diningErrorPermission,
  BillNotFound() => l10n.diningErrorNotFound,
  _ => l10n.billSplitErrorGeneric,
};

/// Layar split bill 1.9 (`/meja/split/:bill`).
class SplitBillScreen extends StatefulWidget {
  const SplitBillScreen({
    super.key,
    required this.repository,
    required this.billId,
    required this.onBack,
    required this.onPay,
  });

  final DiningRepository repository;
  final UuidValue billId;

  /// Kembali ke layar Meja.
  final VoidCallback onBack;

  /// *Bayar bagian*: tamu [guest] (per item / rata) atau nominal [amount].
  final void Function(String? guest, Money? amount) onPay;

  @override
  State<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends State<SplitBillScreen> {
  late final _viewModel = SplitBillViewModel(
    repository: widget.repository,
    billId: widget.billId,
  );
  var _doneShown = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onChange);
    _viewModel.load.execute();
  }

  @override
  void dispose() {
    _viewModel
      ..removeListener(_onChange)
      ..dispose();
    super.dispose();
  }

  Future<void> _onChange() async {
    final done = _viewModel.completed;
    if (done == null || _doneShown || !mounted) return;
    _doneShown = true;
    final l10n = AppLocalizations.of(context);
    await showFDialog<void>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
        builder: (context, style) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('split-done'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                l10n.billSplitDone,
                style: context.theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(l10n.billSplitDoneBody(done.sale.number)),
              FButton(
                key: const ValueKey('split-done-back'),
                onPress: () => Navigator.of(context).pop(),
                child: Text(l10n.cashierBillBack),
              ),
            ],
          ),
        ),
      ),
    );
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) => SplitBillView(
        viewModel: _viewModel,
        narrow: constraints.maxWidth < 900,
        onBack: widget.onBack,
        onPay: widget.onPay,
      ),
    ),
  );
}

class SplitBillView extends StatelessWidget {
  const SplitBillView({
    super.key,
    required this.viewModel,
    required this.narrow,
    required this.onBack,
    required this.onPay,
  });

  final SplitBillViewModel viewModel;
  final bool narrow;
  final VoidCallback onBack;
  final void Function(String? guest, Money? amount) onPay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final bill = vm.bill;
    if (bill == null) {
      return Center(
        child: vm.load.error
            ? Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  Text(l10n.billSplitLoadFailed),
                  FButton(
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: onBack,
                    child: Text(l10n.cashierBillBack),
                  ),
                ],
              )
            : const FCircularProgress(),
      );
    }
    final split = vm.split;
    final rates = bill.rates;
    final ratesText = rates.service.value == 0 && rates.tax.value == 0
        ? l10n.billSplitRatesOff
        : l10n.billSplitRates(
            percentLabel(l10n, rates.service.value),
            percentLabel(l10n, rates.tax.value),
          );
    final pad = narrow ? 16.0 : 24.0;
    final controls = _Controls(viewModel: vm);
    final error = vm.error;
    final top = <Widget>[
      PageHeader(
        leading: FButton(
          key: const ValueKey('split-back'),
          variant: .ghost,
          size: .sm,
          mainAxisSize: .min,
          onPress: onBack,
          prefix: const Icon(TablerIcons.arrowLeft, size: 16),
          child: Text(l10n.cashierBillBack),
        ),
        title: l10n.billSplitTitle(billOrderLabel(l10n, bill), vm.guests),
        subtitle: ratesText,
      ),
      controls,
      if (vm.locked)
        FAlert(
          key: const ValueKey('split-locked'),
          title: Text(l10n.billSplitLocked),
        ),
      if (error != null)
        FAlert(
          key: const ValueKey('split-error'),
          variant: .destructive,
          title: Text(splitErrorMessage(l10n, error)),
        ),
    ];
    final items = _ItemsCard(viewModel: vm);
    final guests = split == null
        ? null
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              for (final part in split.parts)
                part.payments.isEmpty && split.mode == SplitKind.amount
                    ? _AmountCard(
                        key: ValueKey('split-guest-${part.label}'),
                        viewModel: vm,
                        part: part,
                        onPay: () => onPay(null, vm.amount),
                      )
                    : _GuestCard(
                        key: ValueKey('split-guest-${part.label}'),
                        viewModel: vm,
                        part: part,
                        onPay: () => onPay(part.label, null),
                      ),
              _Summary(split: split),
            ],
          );
    return SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          ...top,
          if (narrow || guests == null) ...[items, ?guests],
          if (!narrow && guests != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Expanded(child: items),
                SizedBox(width: 380, child: guests),
              ],
            ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.viewModel});

  final SplitBillViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    void choose(SplitMode m) {
      if (vm.canEdit && vm.mode != m) vm.setMode.execute(m);
    }

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (m, label) in [
              (SplitMode.item, l10n.billSplitModeItem),
              (SplitMode.equal, l10n.billSplitModeEqual),
              (SplitMode.amount, l10n.billSplitModeAmount),
            ])
              ChoicePill(
                key: ValueKey('split-mode-${m.name}'),
                label: label,
                selected: vm.mode == m,
                onTap: () => choose(m),
              ),
          ],
        ),
        if (vm.mode != SplitMode.amount)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              Text(
                l10n.billSplitGuests,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              FButton.icon(
                key: const ValueKey('split-guests-less'),
                size: .sm,
                variant: .outline,
                semanticsLabel: l10n.billSplitGuestLess,
                onPress: vm.mode != null && vm.canRemoveGuest
                    ? () => vm.setGuests.execute(vm.guests - 1)
                    : null,
                child: const Icon(TablerIcons.minus, size: 16),
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '${vm.guests}',
                  key: const ValueKey('split-guests'),
                  textAlign: TextAlign.center,
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              FButton.icon(
                key: const ValueKey('split-guests-more'),
                size: .sm,
                variant: .outline,
                semanticsLabel: l10n.billSplitGuestMore,
                onPress: vm.mode != null && vm.canAddGuest
                    ? () => vm.setGuests.execute(vm.guests + 1)
                    : null,
                child: const Icon(TablerIcons.plus, size: 16),
              ),
            ],
          ),
        if (vm.mode != null && vm.canEdit)
          FButton(
            key: const ValueKey('split-cancel'),
            variant: .ghost,
            size: .sm,
            mainAxisSize: .min,
            onPress: () => vm.setMode.execute(null),
            child: Text(l10n.billSplitCancel),
          ),
        if (vm.mode == null)
          Text(
            l10n.billSplitChooseMode,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
      ],
    );
  }
}

String _itemName(OpenBill bill, SaleItem item) => [
  '${item.productName} ${item.variantName}'.trim(),
  ...bill.modifiersOf(item).map((m) => m.name),
].join(' · ');

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.viewModel});

  final SplitBillViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final bill = vm.bill!;
    final byItem = vm.mode == SplitMode.item;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    final unassigned = vm.unassigned.length;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              l10n.billSplitItems,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            for (final item in bill.items)
              _ItemRow(
                // Nama bisa kembar (modifier berbeda); kunci saudara wajib
                // unik.
                key: ValueKey(item.id),
                viewModel: vm,
                item: item,
                byItem: byItem,
              ),
            if (byItem) ...[
              Text(l10n.billSplitItemsHint, style: muted),
              if (unassigned > 0)
                Text(
                  l10n.billSplitUnassignedCount(
                    vm.unassigned.fold(
                      0,
                      (n, i) => n + (Qty(i.quantityMilli).milli + 999) ~/ 1000,
                    ),
                  ),
                  key: const ValueKey('split-unassigned'),
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.destructive,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    super.key,
    required this.viewModel,
    required this.item,
    required this.byItem,
  });

  final SplitBillViewModel viewModel;
  final SaleItem item;
  final bool byItem;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final bill = vm.bill!;
    final qty = formatQty(context, Qty(item.quantityMilli));
    final unit = Money(item.unitPrice + item.modifierDelta);
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          '$qty× ${_itemName(bill, item)}',
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          byItem
              ? l10n.billSplitPortionPrice(formatMoney(context, unit))
              : formatMoney(context, Money(item.lineTotal)),
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    );
    if (!byItem) return text;
    final guests = vm.guests;
    final chips = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var i = 0; i < guests; i++)
          _GuestChip(
            key: ValueKey(
              'split-chip-${item.productName}-'
              '${item.guestLabel ?? '-'}-${guestLabel(i)}',
            ),
            label: guestLabel(i),
            selected: item.guestLabel == guestLabel(i),
            onTap: vm.canEdit
                ? () => vm.assign.execute((
                    item.id,
                    item.guestLabel == guestLabel(i) ? null : guestLabel(i),
                  ))
                : null,
          ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [text, chips],
    );
  }
}

class _GuestChip extends StatelessWidget {
  const _GuestChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.theme.colors;
    return FTappable(
      onPress: onTap,
      selected: selected,
      semanticsLabel: l10n.billSplitGuest(label),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.card,
          border: Border.all(
            color: selected ? colors.primary : colors.border,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
            color: selected
                ? colors.primaryForeground
                : onTap == null
                ? colors.mutedForeground
                : colors.foreground,
          ),
        ),
      ),
    );
  }
}

(Color, Color) _statusColors(BuildContext context, SplitPartStatus status) {
  final dark = context.theme.colors.brightness == Brightness.dark;
  return switch ((status, dark)) {
    (SplitPartStatus.paid, false) => (
      const Color(0xFFDCFCE7),
      const Color(0xFF016630),
    ),
    (SplitPartStatus.paid, true) => (
      const Color(0xFF032E15),
      const Color(0xFF7BF1A8),
    ),
    (SplitPartStatus.pending, false) => (
      const Color(0xFFFEF3C6),
      const Color(0xFF973C00),
    ),
    (SplitPartStatus.pending, true) => (
      const Color(0xFF461901),
      const Color(0xFFFFD230),
    ),
    (SplitPartStatus.unpaid, _) => (
      context.theme.colors.secondary,
      context.theme.colors.secondaryForeground,
    ),
  };
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: context.theme.typography.body.sm.copyWith(
          color: colors.primaryForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GuestCard extends StatelessWidget {
  const _GuestCard({
    super.key,
    required this.viewModel,
    required this.part,
    required this.onPay,
  });

  final SplitBillViewModel viewModel;
  final GuestPart part;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final status = part.status;
    final (bg, fg) = _statusColors(context, status);
    final methods = {
      for (final p in part.payments) paymentMethodLabel(l10n, p.method),
    }.join(' + ');
    final statusText = switch (status) {
      SplitPartStatus.unpaid => l10n.billSplitStatusUnpaid,
      SplitPartStatus.pending => l10n.billSplitStatusPending,
      SplitPartStatus.paid => l10n.billSplitStatusPaid(methods),
    };
    final waiting = part.payments
        .where((p) => p.status == PaymentStatus.pending)
        .firstOrNull;
    final byItem = vm.mode == SplitMode.item;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Row(
              spacing: 10,
              children: [
                _Avatar(label: part.label),
                Expanded(
                  child: Text(
                    l10n.billSplitGuest(part.label),
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  formatMoney(context, part.due ?? Money.zero),
                  key: ValueKey('split-due-${part.label}'),
                  style: tabularFigures(
                    theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (byItem)
              if (part.items.isEmpty)
                Text(
                  l10n.billSplitGuestEmpty,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                )
              else
                for (final i in part.items)
                  Text(
                    '${formatQty(context, Qty(i.quantityMilli))}× '
                    '${_itemName(vm.bill!, i)}',
                    style: theme.typography.body.xs,
                  ),
            Align(
              alignment: Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  child: Text(
                    statusText,
                    key: ValueKey('split-status-${part.label}'),
                    style: theme.typography.body.xs.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            if (waiting != null)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (vm.canConfirm)
                    FButton(
                      key: ValueKey('split-confirm-${part.label}'),
                      size: .sm,
                      mainAxisSize: .min,
                      onPress: vm.busy
                          ? null
                          : () => vm.confirm.execute(waiting.id),
                      prefix: const Icon(TablerIcons.check, size: 16),
                      child: Text(l10n.qrisPaid),
                    ),
                  FButton(
                    key: ValueKey('split-cancel-payment-${part.label}'),
                    variant: .outline,
                    size: .sm,
                    mainAxisSize: .min,
                    onPress: vm.busy
                        ? null
                        : () => vm.cancel.execute(waiting.id),
                    child: Text(l10n.billSplitCancelPayment),
                  ),
                ],
              )
            else if (part.payments.isEmpty)
              FButton(
                key: ValueKey('split-pay-${part.label}'),
                onPress: vm.canPayPart(part) ? onPay : null,
                child: Flexible(
                  child: Text(
                    l10n.billSplitPay(part.label),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    super.key,
    required this.viewModel,
    required this.part,
    required this.onPay,
  });

  final SplitBillViewModel viewModel;
  final GuestPart part;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final remaining = vm.split!.remaining;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Row(
              spacing: 10,
              children: [
                _Avatar(label: part.label),
                Expanded(
                  child: Text(
                    l10n.billSplitNextGuest(part.label),
                    style: theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            FTextField(
              key: const ValueKey('split-amount'),
              label: Text(l10n.billSplitAmount),
              hint: l10n.billSplitAmountHint(formatMoney(context, remaining)),
              keyboardType: TextInputType.number,
              inputFormatters: const [RupiahInputFormatter()],
              control: .managed(
                onChange: (v) => vm.setAmount(parseSignedRupiah(v.text)),
              ),
            ),
            FButton(
              key: const ValueKey('split-pay-amount'),
              onPress: vm.canPayAmount ? onPay : null,
              child: Text(l10n.billSplitPayAmount),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.split});

  final BillSplit split;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    String labels(SplitPartStatus s) => [
      for (final p in split.parts)
        if (p.status == s) p.label,
    ].join(', ');
    Widget line(String label, Money amount, {bool bold = false, Key? key}) {
      final style = bold
          ? theme.typography.body.md.copyWith(fontWeight: FontWeight.w700)
          : theme.typography.body.sm;
      return Row(
        spacing: 8,
        children: [
          Expanded(child: Text(label, style: style)),
          Text(
            formatMoney(context, amount),
            key: key,
            style: tabularFigures(style),
          ),
        ],
      );
    }

    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          key: const ValueKey('split-summary'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 6,
          children: [
            line(l10n.billSplitTotal, split.total),
            if (split.paid > Money.zero)
              line(
                l10n.billSplitPaid(labels(SplitPartStatus.paid)),
                split.paid,
              ),
            if (split.pending > Money.zero)
              line(
                l10n.billSplitPending(labels(SplitPartStatus.pending)),
                split.pending,
              ),
            const FDivider(),
            line(
              l10n.billSplitRemaining,
              split.remaining,
              bold: true,
              key: const ValueKey('split-remaining'),
            ),
            Text(
              l10n.billSplitNote,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
