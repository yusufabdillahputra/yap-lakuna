import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';

/// Membuka dialog batal pembayaran piutang/hutang [payment] (F1-13c).
/// [onConfirm] menjalankan batal dan mengembalikan galatnya (`null` =
/// berhasil); [errorMessage] menerjemahkan galat itu. Hasil `true` bila
/// pembayaran dibatalkan.
Future<bool> showDebtPaymentVoidDialog(
  BuildContext context, {
  required DebtPayment payment,
  required Future<Exception?> Function(String reason) onConfirm,
  required String Function(Exception error) errorMessage,
}) async =>
    await showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 480),
        builder: (context, style) => _VoidDialog(
          payment: payment,
          onConfirm: onConfirm,
          errorMessage: errorMessage,
        ),
      ),
    ) ??
    false;

class _VoidDialog extends StatefulWidget {
  const _VoidDialog({
    required this.payment,
    required this.onConfirm,
    required this.errorMessage,
  });

  final DebtPayment payment;
  final Future<Exception?> Function(String reason) onConfirm;
  final String Function(Exception error) errorMessage;

  @override
  State<_VoidDialog> createState() => _VoidDialogState();
}

class _VoidDialogState extends State<_VoidDialog> {
  var _reason = '';
  var _submitted = false;
  var _running = false;
  String? _error;

  bool get _reasonInvalid =>
      _submitted && !validateDebtPaymentVoidReason(_reason);

  Future<void> _confirm() async {
    setState(() {
      _submitted = true;
      _error = null;
    });
    if (!validateDebtPaymentVoidReason(_reason)) return;
    setState(() => _running = true);
    final error = await widget.onConfirm(_reason);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _running = false;
      _error = widget.errorMessage(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    final p = widget.payment;
    final amount = formatMoney(context, Money(p.amount));
    final supplier = p.party == DebtParty.supplier;
    final drawer = debtPaymentTouchesDrawer(p);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Column(
        key: const ValueKey('debt-void-dialog'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  Text(
                    l10n.debtVoidTitle(p.number),
                    style: theme.typography.display.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    amount,
                    style: theme.typography.display.md.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    supplier
                        ? l10n.debtVoidBodySupplier
                        : l10n.debtVoidBodyCustomer,
                    style: muted,
                  ),
                  if (drawer)
                    Text(
                      supplier
                          ? l10n.debtVoidDrawerIn(amount)
                          : l10n.debtVoidDrawerOut(amount),
                      key: const ValueKey('debt-void-drawer'),
                      style: muted,
                    ),
                  FTextField(
                    key: const ValueKey('debt-void-reason'),
                    label: Text(l10n.debtVoidReason),
                    hint: l10n.debtVoidReasonHint,
                    maxLength: debtPaymentVoidReasonMax,
                    autofocus: true,
                    error: _reasonInvalid
                        ? Text(l10n.debtVoidErrReason(debtPaymentVoidReasonMax))
                        : null,
                    control: .managed(
                      onChange: (v) => setState(() => _reason = v.text),
                    ),
                  ),
                  if (_error case final error?)
                    Text(
                      error,
                      key: const ValueKey('debt-void-error'),
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.destructive,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                FButton(
                  key: const ValueKey('debt-void-back'),
                  variant: .outline,
                  mainAxisSize: .min,
                  // Tetap terbuka sampai batal selesai agar hasilnya tidak
                  // hilang (daftar perlu dimuat ulang bila berhasil).
                  onPress: _running
                      ? null
                      : () => Navigator.of(context).pop(false),
                  child: Text(l10n.debtVoidBack),
                ),
                FButton(
                  key: const ValueKey('debt-void-confirm'),
                  variant: .destructive,
                  mainAxisSize: .min,
                  onPress: _running ? null : _confirm,
                  child: Flexible(child: Text(l10n.debtVoidConfirm)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
