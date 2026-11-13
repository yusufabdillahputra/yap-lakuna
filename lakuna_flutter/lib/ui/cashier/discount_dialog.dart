import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../l10n/gen/app_localizations.dart';
import '../core/approval_dialog.dart';
import '../core/format.dart';
import '../receipt/receipt_content.dart' show percentLabel;
import 'cashier_view_model.dart';

/// Hasil dialog diskon: [discount] `null` = hapus diskon.
typedef DiscountChoice = ({ManualDiscount? discount});

/// Label diskon: "Diskon 10%" atau "Diskon".
String discountLabel(AppLocalizations l10n, ManualDiscount d) =>
    d.kind == DiscountKind.percent
    ? l10n.cashierDiscountPct(percentLabel(l10n, d.bp))
    : l10n.cashierDiscount;

/// Label baris diskon nota: "Diskon nota 10% · disetujui Rina" (Kasir,
/// panel bill 1.7, ringkasan pembayaran 1.5).
String billDiscountRowLabel(
  AppLocalizations l10n,
  ManualDiscount d, {
  String approverName = '',
}) => [
  d.kind == DiscountKind.percent
      ? l10n.cashierBillDiscountPct(percentLabel(l10n, d.bp))
      : l10n.cashierBillDiscount,
  if (approverName.isNotEmpty) l10n.cashierDiscountApprovedBy(approverName),
].join(' · ');

/// Membuka dialog diskon baris [index] atau, bila `null`, diskon nota.
/// Staf tanpa izin diminta persetujuan PIN manajer setelah *Terapkan*.
Future<void> editCashierDiscount(
  BuildContext context,
  CashierViewModel vm, {
  int? index,
}) async {
  if (!vm.canOfferDiscount) return;
  final l10n = AppLocalizations.of(context);
  final session = ApprovalScope.maybeOf(context);
  final line = index == null ? null : vm.lines[index];
  final base = line?.priced.lineTotal ?? vm.linesNet;
  final choice = await showFDialog<DiscountChoice>(
    context: context,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      builder: (context, style) => DiscountDialog(
        title: line == null
            ? l10n.cashierDiscountBillTitle
            : l10n.cashierDiscountLineTitle,
        subtitle: line?.title ?? l10n.cashierDiscountHint,
        base: base,
        initial: line == null ? vm.billDiscount : line.discount,
        needsApproval: vm.discountNeedsApproval,
        issueOf: (d) => index == null
            ? vm.billDiscountIssue(d)
            : vm.lineDiscountIssue(index, d),
      ),
    ),
  );
  if (choice == null || !context.mounted) return;
  if (choice.discount != null && vm.discountNeedsApproval) {
    if (session == null) return;
    final approver = await requestApproval(
      context,
      session: session,
      permission: Permission.salesDiscount,
      reason: l10n.approvalDiscount,
    );
    if (approver == null) return;
    vm.approveDiscounts((id: approver.id, name: approver.name));
  }
  if (index == null) {
    vm.setBillDiscount(choice.discount);
  } else {
    vm.setLineDiscount(index, choice.discount);
  }
}

/// *Bayar* dari Kasir: keranjang berdiskon tanpa penyetuju (nota tersimpan
/// yang dilanjutkan staf tanpa izin) meminta PIN manajer dulu. `true` =
/// boleh lanjut ke pembayaran.
Future<bool> approveCartDiscounts(
  BuildContext context,
  CashierViewModel vm,
) async {
  if (!vm.discountAwaitsApproval) return true;
  final session = ApprovalScope.maybeOf(context);
  if (session == null) return false;
  final approver = await requestApproval(
    context,
    session: session,
    permission: Permission.salesDiscount,
    reason: AppLocalizations.of(context).approvalDiscountResumed,
  );
  if (approver == null) return false;
  vm.approveDiscounts((id: approver.id, name: approver.name));
  return true;
}

/// Dialog *Diskon nota* / *Diskon baris* (1.4b): persen atau rupiah,
/// pratinjau potongan, hapus diskon.
class DiscountDialog extends StatefulWidget {
  const DiscountDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.base,
    required this.initial,
    required this.needsApproval,
    required this.issueOf,
  });

  final String title;
  final String subtitle;

  /// Nilai yang didiskon.
  final Money base;
  final ManualDiscount? initial;
  final bool needsApproval;
  final DiscountIssue? Function(ManualDiscount discount) issueOf;

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  late DiscountKind _kind = widget.initial?.kind ?? DiscountKind.percent;
  late String _text;
  var _textReady = false;
  var _submitted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hanya sekali: perubahan tema/bahasa tidak boleh menimpa isian.
    if (_textReady) return;
    _textReady = true;
    final d = widget.initial;
    final decimal = qtyDecimalSeparator(context);
    _text = d == null
        ? ''
        : d.kind == DiscountKind.percent
        ? _percentText(d.bp, decimal)
        : '${d.amount.value}';
  }

  static String _percentText(int bp, String decimal) {
    final whole = bp ~/ 100;
    final frac = bp % 100;
    if (frac == 0) return '$whole';
    final digits = frac % 10 == 0 ? '${frac ~/ 10}' : '$frac'.padLeft(2, '0');
    return '$whole$decimal$digits';
  }

  ManualDiscount? get _parsed => parseDiscountValue(_text, _kind);

  DiscountIssue? get _issue {
    final d = _parsed;
    if (d == null) return DiscountIssue.invalid;
    return widget.issueOf(d);
  }

  void _apply() {
    setState(() => _submitted = true);
    if (_issue != null) return;
    Navigator.of(context).pop<DiscountChoice>((discount: _parsed));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final parsed = _parsed;
    final issue = _issue;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        key: const ValueKey('discount-dialog'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            widget.title,
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(widget.subtitle, style: muted),
          Row(
            spacing: 8,
            children: [
              for (final (kind, label) in [
                (DiscountKind.percent, l10n.cashierDiscountPercent),
                (DiscountKind.amount, l10n.cashierDiscountAmount),
              ])
                Expanded(
                  child: FButton(
                    key: ValueKey('discount-kind-${kind.name}'),
                    variant: _kind == kind ? .primary : .outline,
                    onPress: () => setState(() => _kind = kind),
                    child: Flexible(
                      child: Text(label, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
            ],
          ),
          FTextField(
            key: ValueKey('discount-value-${_kind.name}'),
            label: Text(l10n.cashierDiscountValue),
            description: Text(
              l10n.cashierDiscountBase(formatMoney(context, widget.base)),
            ),
            autofocus: true,
            keyboardType: TextInputType.numberWithOptions(
              decimal: _kind == DiscountKind.percent,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                _kind == DiscountKind.percent
                    ? RegExp(r'[0-9.,]')
                    : RegExp(r'[0-9.]'),
              ),
            ],
            error: _submitted && issue != null
                ? Text(
                    issue == DiscountIssue.tooLarge
                        ? l10n.cashierDiscountTooLarge
                        : l10n.cashierDiscountInvalid,
                  )
                : null,
            onSubmit: (_) => _apply(),
            control: .managed(
              initial: TextEditingValue(
                text: _text,
                selection: TextSelection(
                  baseOffset: 0,
                  extentOffset: _text.length,
                ),
              ),
              onChange: (v) => setState(() => _text = v.text),
            ),
          ),
          if (parsed != null && issue == null)
            Text(
              l10n.cashierDiscountCut(
                formatMoney(context, parsed.cut(widget.base)),
              ),
              key: const ValueKey('discount-preview'),
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          if (widget.needsApproval)
            Text(
              l10n.cashierDiscountNeedsPin,
              key: const ValueKey('discount-needs-pin'),
              style: muted,
            ),
          if (widget.initial != null)
            FButton(
              key: const ValueKey('discount-remove'),
              variant: .ghost,
              onPress: () =>
                  Navigator.of(context).pop<DiscountChoice>((discount: null)),
              child: Flexible(
                child: Text(
                  l10n.cashierDiscountRemove,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: theme.colors.destructive),
                ),
              ),
            ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: FButton(
                  variant: .outline,
                  onPress: () => Navigator.of(context).pop(),
                  child: Flexible(
                    child: Text(
                      l10n.cashierCancel,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FButton(
                  key: const ValueKey('discount-apply'),
                  onPress: _apply,
                  child: Flexible(
                    child: Text(
                      l10n.cashierDiscountApply,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
