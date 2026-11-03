import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/cashier_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import 'cashier_view_model.dart';

/// Nama metode bayar untuk layar dan struk.
String paymentMethodLabel(AppLocalizations l10n, PaymentMethod method) =>
    switch (method) {
      PaymentMethod.cash => l10n.paymentCash,
      PaymentMethod.card => l10n.paymentCard,
      PaymentMethod.transfer => l10n.paymentTransfer,
      PaymentMethod.qrisStatic => 'QRIS',
    };

/// Pesan galat simpan pembayaran.
String paymentErrorMessage(AppLocalizations l10n, Exception error) =>
    switch (error) {
      CashSessionNotOpen() => l10n.paymentErrorSession,
      SaleItemUnavailable() => l10n.paymentErrorUnavailable,
      SalePaymentShort() => l10n.paymentErrorShort,
      _ => l10n.paymentErrorGeneric,
    };

/// Angka rupiah tanpa "Rp" untuk struk: `200.000` (id) / `200,000` (en).
String _plain(BuildContext context, int value) => groupThousands(
  value,
  Localizations.localeOf(context).languageCode == 'en' ? ',' : '.',
);

TextStyle _tabular(TextStyle style) =>
    style.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

/// Judul halaman dengan tombol kembali opsional.
class _StageHeader extends StatelessWidget {
  const _StageHeader({
    required this.title,
    required this.subtitle,
    this.onBack,
    this.backLabel,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final String? backLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.card,
        border: Border(bottom: BorderSide(color: theme.colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          spacing: 12,
          children: [
            if (onBack != null)
              SizedBox.square(
                dimension: 40,
                child: FButton.icon(
                  key: const ValueKey('payment-back'),
                  variant: .outline,
                  semanticsLabel: backLabel,
                  onPress: onBack,
                  child: const Icon(TablerIcons.arrowLeft, size: 18),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu putih berbingkai.
class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.panelKey});

  final Widget child;
  final Key? panelKey;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      key: panelKey,
      decoration: BoxDecoration(
        color: theme.colors.card,
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

// --- Pembayaran (1.5) ---------------------------------------------------------

/// Tahap bayar di layar kasir (1.5, F1-05): pilih metode, uang diterima
/// (tunai) atau referensi (kartu/transfer), lalu *Selesaikan pembayaran*.
class PaymentView extends StatelessWidget {
  const PaymentView({super.key, required this.viewModel, required this.narrow});

  final CashierViewModel viewModel;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final header = _StageHeader(
      title: l10n.paymentTitle(formatMoney(context, vm.totals.total)),
      subtitle: l10n.paymentLines(vm.lineCount),
      onBack: vm.pay.running ? null : vm.backToCart,
      backLabel: l10n.paymentBack,
    );
    final methods = _MethodChoice(viewModel: vm, compact: narrow);
    final detail = vm.method == PaymentMethod.cash
        ? _CashPanel(viewModel: vm, compact: narrow)
        : _ReferencePanel(key: ValueKey(vm.method), viewModel: vm);
    final error = vm.error;
    final errorAlert = error == null
        ? null
        : FAlert(
            key: const ValueKey('payment-error'),
            variant: .destructive,
            title: Text(paymentErrorMessage(l10n, error)),
          );
    final finish = _FinishButton(viewModel: vm);

    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [methods, detail, ?errorAlert],
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: finish),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Expanded(child: detail),
                SizedBox(
                  width: 340,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [methods, ?errorAlert, finish],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MethodChoice extends StatelessWidget {
  const _MethodChoice({required this.viewModel, required this.compact});

  final CashierViewModel viewModel;
  final bool compact;

  static const _methods = [
    (PaymentMethod.cash, TablerIcons.cash),
    (PaymentMethod.card, TablerIcons.creditCard),
    (PaymentMethod.transfer, TablerIcons.buildingBank),
  ];

  String _hint(AppLocalizations l10n, PaymentMethod m) => switch (m) {
    PaymentMethod.cash => l10n.paymentCashHint,
    PaymentMethod.card => l10n.paymentCardHint,
    _ => l10n.paymentTransferHint,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    Widget card(PaymentMethod m, IconData icon) {
      final selected = vm.method == m;
      return FTappable(
        key: ValueKey('payment-method-${m.name}'),
        semanticsLabel: paymentMethodLabel(l10n, m),
        selected: selected,
        onPress: vm.pay.running ? null : () => vm.setMethod(m),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected
                ? theme.colors.primary.withValues(alpha: 0.08)
                : theme.colors.card,
            border: Border.all(
              color: selected ? theme.colors.primary : theme.colors.border,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(compact ? 10 : 12),
            child: compact
                ? Column(
                    spacing: 4,
                    children: [
                      Icon(icon, size: 20, color: theme.colors.primary),
                      Text(
                        paymentMethodLabel(l10n, m),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.typography.body.xs.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : Row(
                    spacing: 12,
                    children: [
                      Icon(icon, size: 22, color: theme.colors.primary),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paymentMethodLabel(l10n, m),
                              style: theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _hint(l10n, m),
                              style: theme.typography.body.xs.copyWith(
                                color: theme.colors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        Icon(
                          TablerIcons.circleCheckFilled,
                          size: 18,
                          color: theme.colors.primary,
                        ),
                    ],
                  ),
          ),
        ),
      );
    }

    if (compact) {
      return Row(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (m, icon) in _methods) Expanded(child: card(m, icon)),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [for (final (m, icon) in _methods) card(m, icon)],
    );
  }
}

/// Panel tunai: uang diterima (field + keypad), nominal cepat, kembalian.
class _CashPanel extends StatefulWidget {
  const _CashPanel({required this.viewModel, required this.compact});

  final CashierViewModel viewModel;
  final bool compact;

  @override
  State<_CashPanel> createState() => _CashPanelState();
}

class _CashPanelState extends State<_CashPanel> {
  final _controller = TextEditingController();

  static String _text(Money m) =>
      m.value == 0 ? '' : groupThousands(m.value, '.');

  static Money _parse(String text) {
    final digits = text.replaceAll(RegExp('[^0-9]'), '');
    return Money(digits.isEmpty ? 0 : int.parse(digits));
  }

  @override
  void initState() {
    super.initState();
    _controller.text = _text(widget.viewModel.received);
  }

  @override
  void didUpdateWidget(covariant _CashPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  /// Keypad/nominal cepat mengubah nilai di view model; samakan field.
  void _sync() {
    final received = widget.viewModel.received;
    if (_parse(_controller.text) == received) return;
    final text = _text(received);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = widget.viewModel;
    final total = vm.totals.total;
    final change = vm.change;
    final quick = vm.quickAmounts;
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0'];
    return _Panel(
      panelKey: const ValueKey('payment-cash'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(
            l10n.paymentCash,
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          FTextField(
            key: const ValueKey('payment-received'),
            label: Text(l10n.paymentReceived),
            keyboardType: TextInputType.number,
            inputFormatters: const [RupiahInputFormatter()],
            enabled: !vm.pay.running,
            prefixBuilder: (context, style, _) => Padding(
              padding: const EdgeInsetsDirectional.only(start: 12),
              child: Text(
                'Rp',
                style: theme.typography.body.lg.copyWith(
                  color: theme.colors.mutedForeground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            control: .managed(
              controller: _controller,
              onChange: (v) {
                final m = _parse(v.text);
                if (m != vm.received) vm.setReceived(m);
              },
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (i, amount) in quick.indexed)
                FButton(
                  key: ValueKey('payment-quick-$i'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: vm.pay.running ? null : () => vm.setReceived(amount),
                  child: Flexible(
                    child: Text(
                      amount == total
                          ? l10n.paymentExact
                          : formatMoney(context, amount),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
          LayoutBuilder(
            builder: (context, c) {
              final height = widget.compact ? 48.0 : 56.0;
              final width = (c.maxWidth - 16) / 3;
              Widget key(String k, Widget child, {String? label}) => SizedBox(
                width: width,
                height: height,
                child: FButton(
                  key: ValueKey(
                    'payment-key-${k == CashierViewModel.backspace ? 'back' : k}',
                  ),
                  variant: .outline,
                  semanticsLabel: label,
                  onPress: vm.pay.running ? null : () => vm.keypad(k),
                  child: child,
                ),
              );
              final style = theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w700,
              );
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final k in keys) key(k, Text(k, style: style)),
                  key(
                    CashierViewModel.backspace,
                    const Icon(TablerIcons.backspace, size: 20),
                    label: l10n.cashierDecrease,
                  ),
                ],
              );
            },
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: change == null
                  ? theme.colors.destructive.withValues(alpha: 0.1)
                  : theme.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.paymentChange,
                      style: theme.typography.body.md.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: change != null
                        ? Text(
                            formatMoney(context, change),
                            key: const ValueKey('payment-change'),
                            textAlign: TextAlign.end,
                            style: _tabular(
                              theme.typography.display.lg.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        : Text(
                            l10n.paymentShort(formatMoney(context, vm.shortBy)),
                            key: const ValueKey('payment-short'),
                            textAlign: TextAlign.end,
                            style: _tabular(
                              theme.typography.body.md.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colors.destructive,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel kartu/transfer: jumlah = total, referensi opsional.
class _ReferencePanel extends StatelessWidget {
  const _ReferencePanel({super.key, required this.viewModel});

  final CashierViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final card = vm.method == PaymentMethod.card;
    return _Panel(
      panelKey: const ValueKey('payment-noncash'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(
            paymentMethodLabel(l10n, vm.method),
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            l10n.paymentNonCashNote(formatMoney(context, vm.totals.total)),
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          FTextField(
            key: const ValueKey('payment-reference'),
            label: Text(card ? l10n.paymentApproval : l10n.paymentReference),
            hint: card ? l10n.paymentApprovalHint : null,
            enabled: !vm.pay.running,
            error: vm.referenceTooLong
                ? Text(l10n.paymentReferenceTooLong)
                : null,
            control: .managed(
              initial: TextEditingValue(text: vm.reference),
              onChange: (v) => vm.setReference(v.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinishButton extends StatelessWidget {
  const _FinishButton({required this.viewModel});

  final CashierViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    return FButton(
      key: const ValueKey('payment-finish'),
      size: .lg,
      onPress: vm.canPay ? vm.pay.execute : null,
      prefix: vm.pay.running
          ? const SizedBox.square(dimension: 16, child: FCircularProgress())
          : const Icon(TablerIcons.check),
      child: Flexible(
        child: Text(
          AppLocalizations.of(context).paymentFinish,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

// --- Berhasil (1.5c) ----------------------------------------------------------

/// Hasil bayar (1.5c, F1-05): kembalian besar, peringatan stok minus,
/// pratinjau struk, dan *Transaksi baru*.
class SuccessView extends StatelessWidget {
  const SuccessView({super.key, required this.viewModel, required this.narrow});

  final CashierViewModel viewModel;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final result = vm.result!;
    final data = vm.data!;
    final sale = result.sale;
    final payment = result.payment;
    final cash = payment.method == PaymentMethod.cash;

    final summary = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Row(
          spacing: 14,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Icon(
                  TablerIcons.check,
                  size: 32,
                  color: Color(0xFF016630),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.successTitle,
                    key: const ValueKey('success-title'),
                    style: theme.typography.display.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.successDetail(
                      paymentMethodLabel(l10n, payment.method),
                      formatMoney(context, Money(payment.amount)),
                      formatClock(sale.soldAt, data.timezone),
                      data.staffName,
                    ),
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (cash)
          _Panel(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.successChange,
                    style: theme.typography.body.md.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
                Text(
                  formatMoney(context, Money(payment.changeAmount)),
                  key: const ValueKey('success-change'),
                  style: _tabular(
                    theme.typography.display.xl2.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        for (final n in result.negativeStock)
          DecoratedBox(
            key: ValueKey('success-negative-${n.variantId.uuid}'),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  const Icon(
                    TablerIcons.alertTriangle,
                    size: 18,
                    color: Color(0xFF973C00),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          l10n.successNegativeTitle,
                          style: theme.typography.body.sm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF973C00),
                          ),
                        ),
                        Text(
                          l10n.successNegativeBody(
                            n.name,
                            formatQty(context, n.onHand),
                          ),
                          style: theme.typography.body.sm.copyWith(
                            color: const Color(0xFF973C00),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              TablerIcons.printer,
              size: 16,
              color: theme.colors.mutedForeground,
            ),
            Expanded(
              child: Text(
                l10n.successPrintNote,
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          ],
        ),
        FButton(
          key: const ValueKey('success-new'),
          size: .lg,
          prefix: const Icon(TablerIcons.plus),
          onPress: vm.newTransaction,
          child: Flexible(
            child: Text(l10n.successNew, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );

    final receipt = _ReceiptPreview(result: result, data: data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StageHeader(
          title: l10n.successHeader,
          subtitle: l10n.successReceiptNo(sale.number),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(narrow ? 16 : 24),
            child: narrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 20,
                    children: [
                      summary,
                      Center(child: receipt),
                    ],
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 24,
                        children: [
                          Expanded(child: summary),
                          receipt,
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Pratinjau struk 58 mm (teks), sebelum modul Struk & printer.
class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({required this.result, required this.data});

  final CheckoutResult result;
  final CashierData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    const ink = Color(0xFF111111);
    final base = _tabular(
      theme.typography.body.xs.copyWith(color: ink, height: 1.45),
    );
    final bold = base.copyWith(fontWeight: FontWeight.w700);
    final sale = result.sale;
    final payment = result.payment;
    final local = outletLocalTime(sale.soldAt, data.timezone);
    String two(int n) => n.toString().padLeft(2, '0');
    final date =
        '${two(local.day)}/${two(local.month)}/${two(local.year % 100)} '
        '${two(local.hour)}.${two(local.minute)}';

    // [wideLeft]: baris barang (kiri panjang) vs. baris kepala (kanan
    // panjang, mis. nomor nota).
    Widget pair(
      String left,
      String right, {
      TextStyle? style,
      bool wideLeft = false,
    }) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Expanded(
          flex: wideLeft ? 3 : 1,
          child: Text(left, style: style ?? base),
        ),
        Expanded(
          flex: wideLeft ? 2 : 3,
          child: Text(right, textAlign: TextAlign.end, style: style ?? base),
        ),
      ],
    );
    Widget rule() => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        '-' * 32,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: base.copyWith(color: const Color(0xFF9F9FA9)),
      ),
    );

    return Container(
      key: const ValueKey('success-receipt'),
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFFE4E4E7)),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            data.businessName.toUpperCase(),
            textAlign: TextAlign.center,
            style: bold,
          ),
          Text(data.outletName, textAlign: TextAlign.center, style: base),
          rule(),
          pair(l10n.receiptNo, sale.number),
          pair(l10n.receiptDate, date),
          pair(l10n.receiptCashier, data.staffName),
          rule(),
          for (final item in result.items) ...[
            Text(
              '${item.productName} ${item.variantName}'.trim(),
              style: base,
            ),
            pair(
              '  ${formatQty(context, Qty(item.quantityMilli))}'
              '${item.factorMilli == 1000 ? '' : ' ${item.unitName}'}'
              ' x ${_plain(context, item.unitPrice)}',
              _plain(context, item.lineTotal),
              wideLeft: true,
            ),
          ],
          rule(),
          pair(l10n.receiptTotal, _plain(context, sale.total), style: bold),
          pair(
            paymentMethodLabel(l10n, payment.method),
            _plain(context, payment.amount),
          ),
          if (payment.method == PaymentMethod.cash)
            pair(l10n.receiptChange, _plain(context, payment.changeAmount)),
          rule(),
          Text(l10n.receiptThanks, textAlign: TextAlign.center, style: base),
        ],
      ),
    );
  }
}
