import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/session_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/approval_dialog.dart';
import '../core/drawer_shortfall_note.dart';
import '../core/format.dart';
import '../products/product_widgets.dart';
import '../receipt/printer_labels.dart';
import '../receipt/receipt_content.dart';
import '../receipt/receipt_paper_view.dart';
import 'history_labels.dart';
import 'history_view.dart' show SaleStatusBadge;
import 'history_view_model.dart';

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

const _tabular = [FontFeature.tabularFigures()];

/// Panel rincian nota: ringkasan nilai, item, form retur, cetak ulang, dan
/// void (1.14).
class HistoryDetailPanel extends StatelessWidget {
  const HistoryDetailPanel({
    super.key,
    required this.viewModel,
    required this.session,
    this.onBack,
  });

  final HistoryViewModel viewModel;
  final SessionRepository session;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final detail = vm.detail;
    final back = onBack == null
        ? null
        : FButton(
            key: const ValueKey('history-detail-back'),
            variant: .ghost,
            size: .sm,
            mainAxisSize: .min,
            onPress: onBack,
            prefix: const Icon(TablerIcons.arrowLeft),
            child: Flexible(
              child: Text(l10n.historyBack, overflow: TextOverflow.ellipsis),
            ),
          );
    if (detail == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          ?back,
          if (vm.detailError case final error?)
            FAlert(
              key: const ValueKey('history-detail-error'),
              variant: .destructive,
              title: Text(historyErrorMessage(l10n, error)),
            )
          else
            const Center(child: FCircularProgress()),
        ],
      );
    }
    final sale = detail.sale;
    final tz = vm.data?.timezone;
    final local = outletLocalTime(sale.soldAt, tz);
    final voided = sale.status == SaleStatus.voided;

    Widget textLine(String label, String value) => Row(
      spacing: 8,
      children: [
        Expanded(child: Text(label, style: _muted(context))),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
    Widget amountLine(String label, Money value, {bool strong = false}) => Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: strong
                ? theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  )
                : _muted(context),
          ),
        ),
        Text(
          formatMoney(context, value),
          style: theme.typography.body.sm.copyWith(
            fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
            fontFeatures: _tabular,
          ),
        ),
      ],
    );

    return Column(
      key: ValueKey('history-detail-${sale.id.uuid}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        if (back != null) Align(alignment: Alignment.centerLeft, child: back),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    sale.number,
                    style: theme.typography.display.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${receiptDate(local)} · ${detail.staffName} · '
                    '${historyMethods(l10n, [for (final p in detail.receipt.payments) p.method], credit: sale.customerId != null && sale.paidAmount < sale.total)}',
                    style: _muted(context),
                  ),
                ],
              ),
            ),
            SaleStatusBadge(
              status: sale.status,
              outstanding: detail.outstanding,
            ),
          ],
        ),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              amountLine(l10n.historyTotalOriginal, Money(sale.total)),
              amountLine(l10n.historyReturnedTotal, detail.returnedTotal),
              amountLine(l10n.historyNet, detail.net, strong: true),
              if (detail.credit > Money.zero) ...[
                Container(height: 1, color: theme.colors.border),
                textLine(l10n.historyCustomer, detail.customerName ?? '—'),
                if (detail.dueOn case final due?)
                  textLine(
                    l10n.historyDueOn,
                    '${due.day.toString().padLeft(2, '0')}/'
                    '${due.month.toString().padLeft(2, '0')}/${due.year}',
                  ),
                amountLine(l10n.historyCredit, detail.credit),
                amountLine(
                  l10n.historyOutstanding,
                  detail.outstanding,
                  strong: true,
                ),
              ],
            ],
          ),
        ),
        if (voided)
          FAlert(
            key: const ValueKey('history-voided-info'),
            variant: .destructive,
            title: Text(
              l10n.historyVoidedBy(
                detail.voidedByName ?? '—',
                sale.voidReason ?? '',
              ),
            ),
          ),
        _Items(viewModel: vm),
        if (detail.returns.isNotEmpty) _Returns(viewModel: vm),
        if (vm.returnable) _ReturnForm(viewModel: vm),
        FButton(
          key: const ValueKey('history-reprint'),
          variant: .outline,
          onPress: () => _reprint(context, vm),
          prefix: const Icon(TablerIcons.printer),
          child: Flexible(
            child: Text(l10n.historyReprint, overflow: TextOverflow.ellipsis),
          ),
        ),
        if (!voided) ...[
          FButton(
            key: const ValueKey('history-void'),
            variant: .destructive,
            onPress: vm.voidable && !vm.voidSale.running
                ? () => _void(context, vm, session)
                : null,
            prefix: const Icon(TablerIcons.ban),
            child: Flexible(
              child: Text(l10n.historyVoid, overflow: TextOverflow.ellipsis),
            ),
          ),
          Text(
            switch (detail.voidBlock) {
              final block? => voidBlockLabel(l10n, block),
              null => l10n.historyVoidHint,
            },
            key: const ValueKey('history-void-hint'),
            style: _muted(context),
          ),
          if (vm.voidSale.result case Error(:final error))
            FAlert(
              key: const ValueKey('history-void-error'),
              variant: .destructive,
              title: Text(historyErrorMessage(l10n, error)),
            ),
        ],
      ],
    );
  }
}

class _Items extends StatelessWidget {
  const _Items({required this.viewModel});

  final HistoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final detail = vm.detail!;
    final editable = vm.returnable;
    return SectionCard(
      title: l10n.historyItems,
      trailing: editable
          ? FButton(
              key: const ValueKey('history-return-all'),
              variant: .ghost,
              size: .sm,
              mainAxisSize: .min,
              onPress: vm.returnAll,
              child: Flexible(
                child: Text(
                  l10n.historyReturnAll,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          for (final item in detail.items)
            Column(
              key: ValueKey('history-item-${item.id.uuid}'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 6,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            saleItemName(item),
                            style: theme.typography.body.sm.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            [
                              '${formatQty(context, Qty(item.quantityMilli))} × '
                                  '${formatMoney(context, Money(item.unitPrice + item.modifierDelta))}',
                              if ((detail.returnedMilli[item.id] ?? 0) > 0)
                                l10n.historyItemReturned(
                                  formatQty(
                                    context,
                                    Qty(detail.returnedMilli[item.id]!),
                                  ),
                                ),
                            ].join(' · '),
                            style: _muted(context),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatMoney(context, Money(item.lineTotal)),
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFeatures: _tabular,
                      ),
                    ),
                  ],
                ),
                if (editable && detail.remainingMilli(item) > 0)
                  _ReturnStepper(viewModel: vm, item: item),
              ],
            ),
        ],
      ),
    );
  }
}

class _ReturnStepper extends StatelessWidget {
  const _ReturnStepper({required this.viewModel, required this.item});

  final HistoryViewModel viewModel;
  final SaleItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final qty = vm.returnQty(item);
    final left = vm.detail!.remainingMilli(item);
    final id = item.id.uuid;
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: Text(
            l10n.historyReturnQty(formatQty(context, Qty(left))),
            style: _muted(context),
          ),
        ),
        FButton.icon(
          key: ValueKey('history-return-minus-$id'),
          size: .sm,
          onPress: qty == 0 ? null : () => vm.stepReturn(item, -1),
          child: const Icon(TablerIcons.minus),
        ),
        SizedBox(
          width: 44,
          child: Text(
            formatQty(context, Qty(qty)),
            key: ValueKey('history-return-qty-$id'),
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: _tabular,
            ),
          ),
        ),
        FButton.icon(
          key: ValueKey('history-return-plus-$id'),
          size: .sm,
          onPress: qty >= left ? null : () => vm.stepReturn(item, 1),
          child: const Icon(TablerIcons.plus),
        ),
      ],
    );
  }
}

class _Returns extends StatelessWidget {
  const _Returns({required this.viewModel});

  final HistoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final tz = viewModel.data?.timezone;
    return SectionCard(
      title: l10n.historyReturns,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          for (final r in viewModel.detail!.returns)
            Row(
              key: ValueKey('history-return-${r.number}'),
              spacing: 8,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        r.number,
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        [
                          formatClock(r.returnedAt, tz),
                          returnReasonLabel(l10n, r.reason),
                          refundMethodLabel(l10n, r.refundMethod),
                          if (r.note case final note? when note.isNotEmpty)
                            note,
                        ].join(' · '),
                        style: _muted(context),
                      ),
                    ],
                  ),
                ),
                Text(
                  '−${formatMoney(context, Money(r.amount))}',
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: _tabular,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ReturnForm extends StatelessWidget {
  const _ReturnForm({required this.viewModel});

  final HistoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final running = vm.submitReturn.running;
    final noteError = switch (vm.returnError) {
      ReturnInvalid(error: ReturnError.note) => true,
      _ => false,
    };
    return SectionCard(
      key: const ValueKey('history-return-form'),
      title: l10n.historyReturnTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(l10n.historyReturnReason, style: _muted(context)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in SaleReturnReason.values)
                ChoicePill(
                  key: ValueKey('history-reason-${r.name}'),
                  label: returnReasonLabel(l10n, r),
                  selected: vm.reason == r,
                  onTap: () => vm.setReason(r),
                ),
            ],
          ),
          FTextField(
            key: ValueKey('history-return-note-${vm.formGeneration}'),
            label: Text(
              vm.reason == SaleReturnReason.other
                  ? l10n.historyReturnNoteRequired
                  : l10n.historyReturnNote,
            ),
            maxLength: ReturnLimits.note,
            error: noteError ? Text(l10n.historyErrReturnNote) : null,
            control: .managed(
              initial: TextEditingValue(text: vm.note),
              onChange: (v) => vm.setNote(v.text),
            ),
          ),
          if (vm.returnDebtCut > Money.zero)
            Text(
              vm.returnRefund > Money.zero
                  ? l10n.historyReturnDebtSplit(
                      formatMoney(context, vm.returnDebtCut),
                      formatMoney(context, vm.returnRefund),
                    )
                  : l10n.historyReturnDebtOnly(
                      formatMoney(context, vm.returnDebtCut),
                    ),
              key: const ValueKey('history-return-debt'),
              style: context.theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          if (vm.returnNeedsRefundMethod) ...[
            Text(l10n.historyRefundMethod, style: _muted(context)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in [RefundMethod.cash, RefundMethod.transfer])
                  if (m != RefundMethod.cash || vm.cashRefundAvailable)
                    ChoicePill(
                      key: ValueKey('history-refund-${m.name}'),
                      label: refundMethodLabel(l10n, m),
                      selected: vm.refundMethod == m,
                      onTap: () => vm.setRefundMethod(m),
                    ),
              ],
            ),
            if (!vm.cashRefundAvailable)
              Text(
                l10n.historyRefundCashNeedsSession,
                key: const ValueKey('history-refund-no-session'),
                style: _muted(context),
              ),
            if ((vm.drawerCash, vm.drawerShortfall) case (
              final cash?,
              final over?,
            ))
              DrawerShortfallNote(
                keyPrefix: 'history',
                drawerCash: cash,
                shortfall: over,
              ),
          ],
          Row(
            spacing: 12,
            children: [
              Expanded(child: Text(l10n.historyRestock)),
              FSwitch(
                key: const ValueKey('history-restock'),
                semanticsLabel: l10n.historyRestock,
                value: vm.restock,
                onChange: vm.setRestock,
              ),
            ],
          ),
          if (vm.returnError case final error? when !noteError)
            FAlert(
              key: const ValueKey('history-return-error'),
              variant: .destructive,
              title: Text(historyErrorMessage(l10n, error)),
            ),
          FButton(
            key: const ValueKey('history-return-submit'),
            onPress: !vm.hasReturnLines || running
                ? null
                : vm.submitReturn.execute,
            prefix: running
                ? const SizedBox.square(
                    dimension: 16,
                    child: FCircularProgress(),
                  )
                : const Icon(TablerIcons.receiptRefund),
            child: Flexible(
              child: Text(
                l10n.historyReturnSubmit(formatMoney(context, vm.returnTotal)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Void --------------------------------------------------------------------

Future<void> _void(
  BuildContext context,
  HistoryViewModel vm,
  SessionRepository session,
) async {
  final l10n = AppLocalizations.of(context);
  UuidValue? approverId;
  if (!vm.canVoid) {
    final approver = await requestApproval(
      context,
      session: session,
      permission: Permission.salesVoid,
      reason: l10n.approvalVoidSale,
    );
    if (approver == null || !context.mounted) return;
    approverId = approver.id;
  }
  final reason = await showFDialog<String>(
    context: context,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      builder: (context, style) => SaleVoidDialog(
        number: vm.detail?.sale.number ?? '',
        drawerCash: vm.drawerCash,
        drawerShortfall: vm.voidDrawerShortfall,
      ),
    ),
  );
  if (reason == null) return;
  await vm.voidSale.execute((reason: reason, approverId: approverId));
}

/// Alasan void nota (wajib, maks 120 karakter).
class SaleVoidDialog extends StatefulWidget {
  const SaleVoidDialog({
    super.key,
    required this.number,
    this.drawerCash,
    this.drawerShortfall,
  });

  final String number;

  /// Perkiraan uang di laci dan kelebihan uang tunai nota di atasnya; bila
  /// keduanya ada, dialog menampilkan peringatan (F1-03d).
  final Money? drawerCash;
  final Money? drawerShortfall;

  @override
  State<SaleVoidDialog> createState() => _SaleVoidDialogState();
}

class _SaleVoidDialogState extends State<SaleVoidDialog> {
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
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        key: const ValueKey('history-void-dialog'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            l10n.historyVoidTitle(widget.number),
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(l10n.historyVoidBody, style: _muted(context)),
          if ((widget.drawerCash, widget.drawerShortfall) case (
            final cash?,
            final over?,
          ))
            DrawerShortfallNote(
              keyPrefix: 'history-void',
              drawerCash: cash,
              shortfall: over,
            ),
          FTextField(
            key: const ValueKey('history-void-reason'),
            label: Text(l10n.historyVoidReason),
            autofocus: true,
            maxLength: FnbLimits.voidReason,
            error: _invalid ? Text(l10n.historyErrVoidReason) : null,
            control: .managed(onChange: (v) => _reason = v.text),
            onSubmit: (_) => _submit(),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              FButton(
                variant: .outline,
                mainAxisSize: .min,
                onPress: () => Navigator.of(context).pop(),
                child: Flexible(child: Text(l10n.historyVoidKeep)),
              ),
              FButton(
                key: const ValueKey('history-void-confirm'),
                variant: .destructive,
                mainAxisSize: .min,
                onPress: _submit,
                child: Flexible(child: Text(l10n.historyVoid)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Cetak ulang -------------------------------------------------------------

/// Struk cetak ulang nota terpilih: banner "CETAK ULANG" atau "VOID", plus
/// nilai retur.
List<ReceiptLine> reprintLines(AppLocalizations l10n, HistoryViewModel vm) {
  final detail = vm.detail!;
  final data = vm.data!;
  final voided = detail.sale.status == SaleStatus.voided;
  return layoutReceipt(
    saleReceiptContent(
      l10n,
      result: detail.receipt,
      businessName: data.businessName,
      outletName: data.outletName,
      staffName: detail.staffName,
      timezone: data.timezone,
      config: data.receipt,
      banner: voided ? l10n.receiptBannerVoid : l10n.receiptBannerReprint,
      returned: voided ? 0 : detail.returnedTotal.value,
    ),
    vm.paper,
  );
}

Future<void> _reprint(BuildContext context, HistoryViewModel vm) =>
    showFDialog<void>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 440),
        builder: (context, style) => _ReprintDialog(viewModel: vm),
      ),
    );

class _ReprintDialog extends StatelessWidget {
  const _ReprintDialog({required this.viewModel});

  final HistoryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final vm = viewModel;
        if (vm.detail == null || vm.data == null) {
          return const SizedBox.shrink();
        }
        final lines = reprintLines(l10n, vm);
        final busy = vm.printReceipt.running || vm.shareReceipt.running;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('history-reprint-dialog'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                l10n.historyReprint,
                style: theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Center(
                    child: ReceiptPaperView(
                      lines: lines,
                      paper: vm.paper,
                      logo: vm.receiptLogo,
                    ),
                  ),
                ),
              ),
              if (vm.printFailure != null || vm.printReceipt.error)
                FAlert(
                  key: const ValueKey('history-print-error'),
                  variant: .destructive,
                  title: Text(printerFailureMessage(l10n, vm.printFailure)),
                )
              else if (vm.printed)
                FAlert(
                  key: const ValueKey('history-printed'),
                  title: Text(l10n.receiptPrinted),
                ),
              if (vm.shareReceipt.completed && vm.pdfPath != null)
                FAlert(
                  key: const ValueKey('history-pdf-saved'),
                  title: Text(l10n.receiptPdfSaved(vm.pdfPath!)),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  FButton(
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: () => Navigator.of(context).pop(),
                    child: Flexible(child: Text(l10n.historyClose)),
                  ),
                  FButton(
                    key: const ValueKey('history-reprint-share'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: busy ? null : () => vm.shareReceipt.execute(lines),
                    prefix: const Icon(TablerIcons.share),
                    child: Flexible(child: Text(l10n.receiptShare)),
                  ),
                  FButton(
                    key: const ValueKey('history-reprint-print'),
                    mainAxisSize: .min,
                    onPress: busy ? null : () => vm.printReceipt.execute(lines),
                    prefix: const Icon(TablerIcons.printer),
                    child: Flexible(child: Text(l10n.receiptPrint)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
