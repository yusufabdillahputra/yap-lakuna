import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart' show PaymentMethod;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import '../products/product_widgets.dart' show ChoicePill;
import 'cashier_view_model.dart';
import 'payment_view.dart'
    show PaymentPanel, paymentMethodLabel, tabularFigures;
import 'qris_panel.dart' show qrisAmber, qrisAmberInk, showQrisPartDialog;

/// Split payment (panel kanan 1.5): bagian-bagian pembayaran, form tambah
/// metode, sisa, dan kembalian. Bagian QRIS menunggu *Sudah Terbayar*.
class SplitPanel extends StatefulWidget {
  const SplitPanel({super.key, required this.viewModel});

  final CashierViewModel viewModel;

  @override
  State<SplitPanel> createState() => _SplitPanelState();
}

class _SplitPanelState extends State<SplitPanel> {
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  var _referenceRevision = 0;

  static String _text(Money m) =>
      m.value <= 0 ? '' : groupThousands(m.value, '.');

  static Money _parse(String text) {
    final digits = text.replaceAll(RegExp('[^0-9]'), '');
    return Money(digits.isEmpty ? 0 : int.parse(digits));
  }

  @override
  void initState() {
    super.initState();
    _amount.text = _text(widget.viewModel.draftAmount);
    _reference.text = widget.viewModel.draftReference;
    _referenceRevision = widget.viewModel.draftReferenceRevision;
  }

  @override
  void didUpdateWidget(covariant SplitPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  /// Nominal bawaan (sisa) berubah setelah tambah/hapus bagian.
  void _sync() {
    // Isian referensi dikosongkan VM setelah bagian ditambah (F1-05b).
    final vm = widget.viewModel;
    if (vm.draftReferenceRevision != _referenceRevision) {
      _referenceRevision = vm.draftReferenceRevision;
      _reference.text = vm.draftReference;
    }
    final amount = widget.viewModel.draftAmount;
    if (_parse(_amount.text) == amount) return;
    final text = _text(amount);
    _amount.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _confirm(int index) async {
    final vm = widget.viewModel;
    final part = vm.parts[index];
    final ok = await showQrisPartDialog(
      context,
      qris: vm.qris!,
      amount: part.amount,
      canConfirm: vm.canConfirmPayments,
    );
    if (!mounted || ok == null) return;
    if (ok) {
      vm.confirmPart(index);
    } else {
      vm.removePart(index);
    }
  }

  String? _draftError(AppLocalizations l10n, SplitDraftError? e) => switch (e) {
    SplitDraftError.cashExists => l10n.splitCashExists,
    SplitDraftError.overRemaining => l10n.splitOverRemaining,
    SplitDraftError.referenceTooLong => l10n.paymentReferenceTooLong,
    SplitDraftError.settled || SplitDraftError.empty || null => null,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = widget.viewModel;
    final settlement = vm.splitSettlement;
    final running = vm.pay.running;
    final draftError = vm.draftError;
    final settled = draftError == SplitDraftError.settled;

    Widget badge(SplitPart p) {
      final pending = p.isPending;
      // Warna status tetap agar terbaca di tema terang dan gelap.
      return DecoratedBox(
        decoration: BoxDecoration(
          color: pending ? qrisAmber : const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text(
            pending ? l10n.splitPending : l10n.splitReceived,
            style: theme.typography.body.xs.copyWith(
              fontWeight: FontWeight.w700,
              color: pending ? qrisAmberInk : const Color(0xFF016630),
            ),
          ),
        ),
      );
    }

    Widget row(int i, SplitPart p) => DecoratedBox(
      key: ValueKey('split-part-$i'),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
        child: Row(
          spacing: 8,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    paymentMethodLabel(l10n, p.method),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (p.reference.isNotEmpty)
                    Text(
                      '${p.method == PaymentMethod.card ? l10n.receiptApproval : l10n.receiptTransferRef} ${p.reference}',
                      key: ValueKey('split-part-$i-reference'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  badge(p),
                ],
              ),
            ),
            Text(
              formatMoney(context, p.amount),
              style: tabularFigures(
                theme.typography.body.md.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            if (p.isPending)
              FButton(
                key: ValueKey('split-part-$i-confirm'),
                size: .sm,
                mainAxisSize: .min,
                onPress: running ? null : () => _confirm(i),
                child: Text(l10n.splitConfirm),
              ),
            SizedBox.square(
              dimension: 36,
              child: FButton.icon(
                key: ValueKey('split-part-$i-remove'),
                variant: .ghost,
                semanticsLabel: l10n.splitRemove,
                onPress: running ? null : () => vm.removePart(i),
                child: const Icon(TablerIcons.trash, size: 16),
              ),
            ),
          ],
        ),
      ),
    );

    Widget total(String label, Money value, String key, {Color? color}) => Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          formatMoney(context, value),
          key: ValueKey(key),
          style: tabularFigures(
            theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );

    final referenceError = draftError == SplitDraftError.referenceTooLong;
    final error = referenceError ? null : _draftError(l10n, draftError);
    return PaymentPanel(
      panelKey: const ValueKey('payment-split'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            l10n.splitTitle,
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            l10n.splitHint,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          for (final (i, p) in vm.parts.indexed) row(i, p),
          if (!settled) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in vm.splitMethods)
                  ChoicePill(
                    key: ValueKey('split-method-${m.name}'),
                    label: paymentMethodLabel(l10n, m),
                    selected: vm.draftMethod == m,
                    onTap: () => vm.setDraftMethod(m),
                  ),
              ],
            ),
            FTextField(
              key: const ValueKey('split-amount'),
              label: Text(l10n.splitAmount),
              keyboardType: TextInputType.number,
              inputFormatters: const [RupiahInputFormatter()],
              enabled: !running,
              error: error == null
                  ? null
                  : Text(error, key: const ValueKey('split-draft-error')),
              prefixBuilder: (context, style, _) => Padding(
                padding: const EdgeInsetsDirectional.only(start: 12),
                child: Text(
                  'Rp',
                  style: theme.typography.body.md.copyWith(
                    color: theme.colors.mutedForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              control: .managed(
                controller: _amount,
                onChange: (v) {
                  final m = _parse(v.text);
                  if (m != vm.draftAmount) vm.setDraftAmount(m);
                },
              ),
              onSubmit: (_) => vm.addPart(),
            ),
            if (vm.draftTakesReference)
              FTextField(
                key: const ValueKey('split-reference'),
                label: Text(
                  vm.draftMethod == PaymentMethod.card
                      ? l10n.paymentApproval
                      : l10n.paymentReference,
                ),
                hint: vm.draftMethod == PaymentMethod.card
                    ? l10n.paymentApprovalHint
                    : null,
                enabled: !running,
                error: referenceError
                    ? Text(
                        l10n.paymentReferenceTooLong,
                        key: const ValueKey('split-reference-error'),
                      )
                    : null,
                control: .managed(
                  controller: _reference,
                  onChange: (v) => vm.setDraftReference(v.text),
                ),
                onSubmit: (_) => vm.addPart(),
              ),
            FButton(
              key: const ValueKey('split-add'),
              variant: .outline,
              prefix: const Icon(TablerIcons.plus),
              onPress: !running && draftError == null ? vm.addPart : null,
              child: Flexible(
                child: Text(l10n.splitAdd, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          const FDivider(),
          total(
            l10n.splitRemaining,
            settlement.remaining,
            'split-remaining',
            color: settlement.remaining > Money.zero
                ? theme.colors.destructive
                : null,
          ),
          if (settlement.change > Money.zero)
            total(l10n.paymentChange, settlement.change, 'split-change'),
          if (vm.hasPendingQris)
            DecoratedBox(
              decoration: BoxDecoration(
                color: qrisAmber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  l10n.splitPendingNote,
                  key: const ValueKey('split-pending-note'),
                  style: theme.typography.body.xs.copyWith(
                    color: qrisAmberInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
