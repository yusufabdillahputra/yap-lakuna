import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/cashier_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import 'cashier_view.dart' show cashierKeepsFocus;
import '../receipt/printer_labels.dart';
import '../receipt/receipt_content.dart';
import '../receipt/receipt_paper_view.dart';
import 'cashier_view_model.dart';
import 'qris_panel.dart';
import 'split_panel.dart';

/// "Meja M4" / "Take away TA-07".
String billOrderLabel(AppLocalizations l10n, OpenBill bill) => bill.isTakeAway
    ? l10n.billTakeAwayLabel(bill.label)
    : l10n.billTableLabel(bill.label);

/// Nama metode bayar untuk layar dan struk.
String paymentMethodLabel(AppLocalizations l10n, PaymentMethod method) =>
    switch (method) {
      PaymentMethod.cash => l10n.paymentCash,
      PaymentMethod.card => l10n.paymentCard,
      PaymentMethod.transfer => l10n.paymentTransfer,
      PaymentMethod.qrisStatic => l10n.paymentQris,
    };

/// Pesan galat simpan pembayaran.
String paymentErrorMessage(AppLocalizations l10n, Exception error) =>
    switch (error) {
      CashSessionNotOpen() => l10n.paymentErrorSession,
      SaleItemUnavailable() => l10n.paymentErrorUnavailable,
      SalePaymentShort() => l10n.paymentErrorShort,
      SalePaymentUnsupported() => l10n.paymentErrorQrisOff,
      SalePaymentUnconfirmed() => l10n.paymentErrorUnconfirmed,
      SalePaymentInvalid() => l10n.paymentErrorSplit,
      NotPermitted(permission: Permission.paymentsConfirm) =>
        l10n.paymentErrorConfirmPermission,
      NotPermitted() => l10n.paymentErrorPermission,
      _ => l10n.paymentErrorGeneric,
    };

TextStyle _tabular(TextStyle style) => tabularFigures(style);

/// Angka rata lebar (nominal, struk).
TextStyle tabularFigures(TextStyle style) =>
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

/// Kartu putih berbingkai di layar bayar.
class PaymentPanel extends StatelessWidget {
  const PaymentPanel({super.key, required this.child, this.panelKey});

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
      title: l10n.paymentTitle(formatMoney(context, vm.payTotal)),
      subtitle: vm.bill == null
          ? l10n.paymentLines(vm.payLineCount)
          : l10n.paymentBillLines(
              billOrderLabel(l10n, vm.bill!),
              vm.payLineCount,
            ),
      onBack: vm.pay.running ? null : vm.backToCart,
      backLabel: l10n.paymentBack,
    );
    final methods = _MethodChoice(viewModel: vm, compact: narrow);
    final detail = switch (vm.mode) {
      PayMode.cash => _CashPanel(viewModel: vm, compact: narrow),
      PayMode.card || PayMode.transfer => _ReferencePanel(
        key: ValueKey(vm.mode),
        viewModel: vm,
      ),
      PayMode.qris => QrisPanel(viewModel: vm, compact: narrow),
      PayMode.split => SplitPanel(viewModel: vm),
    };
    final error = vm.error;
    final errorAlert = error == null
        ? null
        : FAlert(
            key: const ValueKey('payment-error'),
            variant: .destructive,
            title: Text(paymentErrorMessage(l10n, error)),
          );
    final finish = vm.mode == PayMode.qris
        ? QrisActions(viewModel: vm)
        : _FinishButton(viewModel: vm);

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                if (vm.mode == PayMode.cash) _ChangeBox(viewModel: vm),
                finish,
              ],
            ),
          ),
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

  static IconData _icon(PayMode m) => switch (m) {
    PayMode.cash => TablerIcons.cash,
    PayMode.card => TablerIcons.creditCard,
    PayMode.transfer => TablerIcons.buildingBank,
    PayMode.qris => TablerIcons.qrcode,
    PayMode.split => TablerIcons.arrowsSplit2,
  };

  static String _label(AppLocalizations l10n, PayMode m) => switch (m) {
    PayMode.cash => l10n.paymentCash,
    PayMode.card => l10n.paymentCard,
    PayMode.transfer => l10n.paymentTransfer,
    PayMode.qris => l10n.paymentQris,
    PayMode.split => l10n.paymentSplit,
  };

  static String _hint(AppLocalizations l10n, PayMode m) => switch (m) {
    PayMode.cash => l10n.paymentCashHint,
    PayMode.card => l10n.paymentCardHint,
    PayMode.transfer => l10n.paymentTransferHint,
    PayMode.qris => l10n.paymentQrisHint,
    PayMode.split => l10n.paymentSplitHint,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final modes = [
      PayMode.cash,
      PayMode.card,
      PayMode.transfer,
      if (vm.qris != null) PayMode.qris,
      PayMode.split,
    ];
    Widget card(PayMode m) {
      final selected = vm.mode == m;
      final icon = _icon(m);
      return FTappable(
        key: ValueKey('payment-method-${m.name}'),
        semanticsLabel: _label(l10n, m),
        selected: selected,
        onPress: vm.pay.running ? null : () => vm.setMode(m),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Icon(icon, size: 20, color: theme.colors.primary),
                      Text(
                        _label(l10n, m),
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
                              _label(l10n, m),
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
      // Tiga kartu per baris agar label tetap terbaca di ponsel; kartu
      // sebaris sama tinggi walau labelnya satu atau dua baris.
      return Column(
        spacing: 8,
        children: [
          for (var i = 0; i < modes.length; i += 3)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  for (var j = i; j < i + 3; j++)
                    Expanded(
                      child: j < modes.length
                          ? card(modes[j])
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [for (final m in modes) card(m)],
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
    final total = vm.payTotal;
    final quick = vm.quickAmounts;
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '000', '0'];
    return PaymentPanel(
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
            autofocus: cashierKeepsFocus && !widget.compact,
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
          if (!widget.compact) _ChangeBox(viewModel: vm),
        ],
      ),
    );
  }
}

/// Kembalian, atau "Kurang X" bila uang diterima belum cukup. Di ponsel
/// berada di atas tombol selesai agar selalu terlihat.
class _ChangeBox extends StatelessWidget {
  const _ChangeBox({required this.viewModel});

  final CashierViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final change = vm.change;
    return DecoratedBox(
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
            Expanded(
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
    final method = vm.method!;
    final card = method == PaymentMethod.card;
    return PaymentPanel(
      panelKey: const ValueKey('payment-noncash'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text(
            paymentMethodLabel(l10n, method),
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            l10n.paymentNonCashNote(formatMoney(context, vm.payTotal)),
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
    final payments = result.payments;
    final cash = payments.any((p) => p.method == PaymentMethod.cash);
    final methodText = payments.length == 1
        ? paymentMethodLabel(l10n, payments.single.method)
        : l10n.paymentSplitSummary(payments.length);
    final lines = layoutReceipt(
      saleReceiptContent(
        l10n,
        result: result,
        businessName: data.businessName,
        outletName: data.outletName,
        staffName: data.staffName,
        timezone: data.timezone,
        config: data.receipt,
        orderLabel: vm.bill == null ? null : billOrderLabel(l10n, vm.bill!),
      ),
      vm.receiptPaper,
    );
    if (vm.shouldAutoPrint) {
      WidgetsBinding.instance.addPostFrameCallback((_) => vm.autoPrint(lines));
    }

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
                      methodText,
                      formatMoney(context, Money(sale.total)),
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
          PaymentPanel(
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
                  formatMoney(context, Money(sale.changeAmount)),
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
        _ReceiptActions(viewModel: vm, lines: lines),
        FButton(
          key: const ValueKey('success-new'),
          size: .lg,
          prefix: const Icon(TablerIcons.plus),
          onPress: vm.canStartNewTransaction ? vm.newTransaction : null,
          child: Flexible(
            child: Text(
              vm.billMode ? l10n.successBackToTables : l10n.successNew,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );

    final receipt = ConstrainedBox(
      key: const ValueKey('success-receipt'),
      constraints: BoxConstraints(
        maxWidth: vm.receiptPaper == ReceiptPaper.mm58 ? 280 : 400,
      ),
      child: ReceiptPaperView(lines: lines, paper: vm.receiptPaper),
    );
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

/// Kartu printer + *Cetak struk* / *Bagikan PDF* di layar sukses (1.12).
class _ReceiptActions extends StatelessWidget {
  const _ReceiptActions({required this.viewModel, required this.lines});

  final CashierViewModel viewModel;
  final List<ReceiptLine> lines;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final printer = vm.printer;
    final direct = printer?.isDirect ?? false;
    final busy = vm.printing;
    Widget spinner() =>
        const SizedBox.square(dimension: 16, child: FCircularProgress());

    final print = FButton(
      key: const ValueKey('receipt-print'),
      variant: direct ? .primary : .outline,
      onPress: busy ? null : () => vm.printReceipt.execute(lines),
      prefix: vm.printReceipt.running
          ? spinner()
          : const Icon(TablerIcons.printer),
      child: Flexible(
        child: Text(l10n.receiptPrint, overflow: TextOverflow.ellipsis),
      ),
    );
    final share = FButton(
      key: const ValueKey('receipt-share'),
      variant: .outline,
      onPress: busy ? null : () => vm.shareReceipt.execute(lines),
      prefix: vm.shareReceipt.running
          ? spinner()
          : const Icon(TablerIcons.share),
      child: Flexible(
        child: Text(l10n.receiptShare, overflow: TextOverflow.ellipsis),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        PaymentPanel(
          child: Row(
            key: const ValueKey('receipt-printer'),
            spacing: 12,
            children: [
              Icon(
                TablerIcons.printer,
                size: 22,
                color: printer == null
                    ? theme.colors.mutedForeground
                    : theme.colors.primary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      printer == null
                          ? l10n.receiptPrinterNone
                          : l10n.receiptPrinterTitle,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      printer == null
                          ? l10n.receiptPrinterNoneHint
                          : printerSummary(l10n, printer, vm.receiptPaper),
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
        Row(
          spacing: 8,
          children: [
            Expanded(child: print),
            Expanded(child: share),
          ],
        ),
        if (vm.printFailure != null || vm.printReceipt.error)
          FAlert(
            key: const ValueKey('receipt-print-error'),
            variant: .destructive,
            title: Text(printerFailureMessage(l10n, vm.printFailure)),
            subtitle: GestureDetector(
              key: const ValueKey('receipt-print-retry'),
              onTap: busy ? null : () => vm.printReceipt.execute(lines),
              child: Text(
                l10n.printerRetry,
                style: const TextStyle(decoration: TextDecoration.underline),
              ),
            ),
          )
        else if (vm.shareReceipt.error)
          FAlert(
            key: const ValueKey('receipt-share-error'),
            variant: .destructive,
            title: Text(l10n.receiptShareError),
          )
        else if (vm.printed)
          FAlert(
            key: const ValueKey('receipt-printed'),
            icon: const Icon(TablerIcons.circleCheck),
            title: Text(l10n.receiptPrinted),
          )
        else if (vm.sharedPath case final path?)
          FAlert(
            key: const ValueKey('receipt-pdf-saved'),
            icon: const Icon(TablerIcons.fileTypePdf),
            title: Text(l10n.receiptPdfSaved(path)),
          ),
        if (!vm.autoPrintEnabled)
          Text(
            key: const ValueKey('receipt-auto-print-note'),
            l10n.successPrintNote,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
      ],
    );
  }
}
