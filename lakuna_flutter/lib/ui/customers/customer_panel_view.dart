import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/customers_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../cashier/payment_view.dart' show paymentMethodLabel;
import '../core/format.dart';
import '../products/product_widgets.dart';
import '../purchases/purchase_labels.dart'
    show formatCalendarDate, formatCalendarDayMonth;
import 'customer_form_dialog.dart';
import 'customer_labels.dart';
import 'customer_panel_view_model.dart';
import 'debt_payment_void_dialog.dart';
import 'customers_view.dart' show debtTone;

const _tabular = [FontFeature.tabularFigures()];

/// Di bawah lebar ini tabel nota dan isian bayar ditumpuk.
const customerPanelNarrowWidth = 520.0;

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

Widget _rpPrefix(
  BuildContext context,
  FTextFieldStyle style,
  Set<FTextFieldVariant> _,
) => Padding(
  padding: const EdgeInsetsDirectional.only(start: 12),
  child: Text('Rp', style: _muted(context)),
);

/// Halaman satu pelanggan di layar sempit (`/pelanggan/:id`).
class CustomerDetailPage extends StatefulWidget {
  const CustomerDetailPage({
    super.key,
    required this.repository,
    required this.customerId,
    required this.onBack,
    required this.onOpenReceipt,
  });

  final CustomersRepository repository;
  final UuidValue customerId;
  final VoidCallback onBack;
  final Future<void> Function(UuidValue paymentId, {bool copy}) onOpenReceipt;

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  late final _vm = CustomerPanelViewModel(
    repository: widget.repository,
    customerId: widget.customerId,
  )..load.execute();

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      key: const ValueKey('customer-page-scroll'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FButton(
              key: const ValueKey('customer-back'),
              variant: .outline,
              mainAxisSize: .min,
              onPress: widget.onBack,
              prefix: const Icon(TablerIcons.chevronLeft),
              child: Flexible(child: Text(l10n.customersTitle)),
            ),
          ),
          CustomerPanel(
            repository: widget.repository,
            viewModel: _vm,
            onChanged: () async {},
            onDeleted: widget.onBack,
            onReceived: (p) async {
              await widget.onOpenReceipt(p.id);
              if (mounted) await _vm.load.execute();
            },
            onOpenReceipt: (id) => widget.onOpenReceipt(id, copy: true),
          ),
        ],
      ),
    );
  }
}

/// Panel pelanggan terpilih (1.20, kanan).
class CustomerPanel extends StatelessWidget {
  const CustomerPanel({
    super.key,
    required this.repository,
    required this.viewModel,
    required this.onChanged,
    required this.onDeleted,
    required this.onReceived,
    required this.onOpenReceipt,
  });

  final CustomersRepository repository;
  final CustomerPanelViewModel viewModel;

  /// Data pelanggan berubah (ubah data): muat ulang daftar.
  final Future<void> Function() onChanged;
  final VoidCallback onDeleted;
  final Future<void> Function(DebtPayment payment) onReceived;
  final Future<void> Function(UuidValue paymentId) onOpenReceipt;

  Future<void> _edit(BuildContext context) async {
    final customer = viewModel.detail?.customer;
    if (customer == null) return;
    final saved = await showCustomerForm(
      context,
      repository,
      customer: customer,
    );
    if (saved == null) return;
    await viewModel.load.execute();
    await onChanged();
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final name = viewModel.detail?.customer.name ?? '';
    final ok = await showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
        builder: (context, style) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('customer-delete-confirm'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                l10n.customerDeleteTitle(name),
                style: context.theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(l10n.customerDeleteBody, style: _muted(context)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  FButton(
                    key: const ValueKey('customer-delete-cancel'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: () => Navigator.of(context).pop(false),
                    child: Flexible(child: Text(l10n.customerCancel)),
                  ),
                  FButton(
                    key: const ValueKey('customer-delete-ok'),
                    variant: .destructive,
                    mainAxisSize: .min,
                    onPress: () => Navigator.of(context).pop(true),
                    child: Flexible(child: Text(l10n.customerDeleteAction)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (ok != true) return;
    await viewModel.delete.execute();
    if (viewModel.delete.result is Ok) onDeleted();
  }

  Future<void> _receive() async {
    await viewModel.receive.execute();
    if (viewModel.receive.result case Ok(:final value)) {
      await onReceived(value);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = viewModel;
      final detail = vm.detail;
      if (detail == null) {
        if (vm.error case final error?) {
          return LoadFailedAlert(
            key: const ValueKey('customer-load-error'),
            message: customerErrorMessage(l10n, error),
            onRetry: vm.load.execute,
          );
        }
        return const FCard(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: FCircularProgress()),
          ),
        );
      }
      final row = detail.row;
      final c = detail.customer;
      final since = c.createdAt;
      final sub = [
        if (row.groupName case final g?) l10n.customerGroupLabel(g),
        l10n.customerSince(formatMonthYear(l10n, since)),
      ].join(' · ');
      final contact = [
        if (c.phone case final p?) formatPhone(p),
        ?c.address,
      ].join(' · ');
      return FCard(
        key: ValueKey('customer-panel-${c.id.uuid}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < customerPanelNarrowWidth;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Text(
                              c.name,
                              style: theme.typography.display.lg.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(sub, style: _muted(context)),
                            if (contact.isNotEmpty)
                              Text(contact, style: _muted(context)),
                            if (c.note case final n?)
                              Text(
                                n,
                                style: _muted(
                                  context,
                                ).copyWith(fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                      ),
                      if (vm.canManage)
                        FButton(
                          key: const ValueKey('customer-edit'),
                          variant: .outline,
                          mainAxisSize: .min,
                          onPress: () => _edit(context),
                          child: Text(l10n.customerEdit),
                        ),
                    ],
                  ),
                  _Stats(row: row, narrow: narrow),
                  if (detail.open.isEmpty)
                    Text(
                      l10n.customerNoDebt,
                      key: const ValueKey('customer-no-debt'),
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    )
                  else ...[
                    if (vm.canReceive) ...[
                      Text(
                        l10n.customerReceiveTitle,
                        style: theme.typography.body.md.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _PaymentFields(viewModel: vm, narrow: narrow),
                    ],
                    _OpenTable(viewModel: vm, narrow: narrow),
                    if (vm.canReceive) ...[
                      _Hint(viewModel: vm),
                      if (vm.receive.result case Error(:final error))
                        Text(
                          customerErrorMessage(l10n, error),
                          key: const ValueKey('customer-receive-error'),
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.destructive,
                          ),
                        ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          FButton(
                            key: const ValueKey('customer-manual'),
                            variant: .outline,
                            mainAxisSize: .min,
                            onPress: () => vm.setManual(!vm.manual),
                            child: Flexible(
                              child: Text(
                                vm.manual
                                    ? l10n.customerAuto
                                    : l10n.customerManual,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          FButton(
                            key: const ValueKey('customer-receive'),
                            mainAxisSize: .min,
                            onPress: vm.canSubmit ? _receive : null,
                            prefix: vm.receive.running
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: FCircularProgress(),
                                  )
                                : const Icon(TablerIcons.printer),
                            child: Flexible(
                              child: Text(
                                l10n.customerSaveAndPrint,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                  _Payments(
                    viewModel: vm,
                    onOpen: onOpenReceipt,
                    onChanged: onChanged,
                  ),
                  if (vm.canManage)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 6,
                        children: [
                          FButton(
                            key: const ValueKey('customer-delete'),
                            variant: .ghost,
                            size: .sm,
                            mainAxisSize: .min,
                            onPress: vm.delete.running
                                ? null
                                : () => _delete(context),
                            prefix: Icon(
                              TablerIcons.trash,
                              color: theme.colors.destructive,
                            ),
                            child: Flexible(
                              child: Text(
                                l10n.customerDelete,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.colors.destructive,
                                ),
                              ),
                            ),
                          ),
                          if (vm.delete.result case Error(:final error))
                            Text(
                              customerErrorMessage(l10n, error),
                              key: const ValueKey('customer-delete-error'),
                              style: theme.typography.body.xs.copyWith(
                                color: theme.colors.destructive,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

class _Stats extends StatelessWidget {
  const _Stats({required this.row, required this.narrow});

  final CustomerRow row;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final (bg, fg) = debtTone(context);
    Widget tile(String key, String label, Money value, {bool debt = false}) =>
        DecoratedBox(
          key: ValueKey(key),
          decoration: BoxDecoration(
            color: debt ? bg : theme.colors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: debt ? fg.withValues(alpha: 0.25) : theme.colors.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  label,
                  style: theme.typography.body.xs.copyWith(
                    color: debt ? fg : theme.colors.mutedForeground,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    formatMoney(context, value),
                    maxLines: 1,
                    style: theme.typography.display.lg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: debt ? fg : null,
                      fontFeatures: _tabular,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    final tiles = [
      tile('customer-limit', l10n.customerLimit, row.creditLimit),
      tile('customer-debt', l10n.customerDebt, row.outstanding, debt: true),
      tile('customer-remaining', l10n.customerRemaining, row.remainingLimit),
    ];
    // Tiga petak sebaris kecuali layar sangat sempit.
    if (narrow && MediaQuery.sizeOf(context).width < 400) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: tiles,
      );
    }
    return Row(
      spacing: 12,
      children: [for (final t in tiles) Expanded(child: t)],
    );
  }
}

class _PaymentFields extends StatelessWidget {
  const _PaymentFields({required this.viewModel, required this.narrow});

  final CustomerPanelViewModel viewModel;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final gen = vm.generation;
    final issue = vm.issue;
    final amount = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        FTextField(
          key: ValueKey('customer-amount-$gen'),
          label: Text(l10n.customerAmount),
          hint: '0',
          keyboardType: TextInputType.number,
          inputFormatters: const [RupiahInputFormatter()],
          prefixBuilder: _rpPrefix,
          error:
              issue == DebtPaymentIssue.amount ||
                  issue == DebtPaymentIssue.overOutstanding
              ? Text(debtPaymentIssueMessage(l10n, issue!))
              : null,
          control: .managed(
            initial: TextEditingValue(
              text: vm.amount.value == 0
                  ? ''
                  : groupThousands(vm.amount.value, '.'),
            ),
            onChange: (v) => vm.setAmount(parseSignedRupiah(v.text)),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FButton(
            key: const ValueKey('customer-pay-all'),
            variant: .outline,
            size: .sm,
            mainAxisSize: .min,
            onPress: vm.payAll,
            child: Flexible(
              child: Text(
                l10n.customerPayAll,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
    final method = FSelect<String>(
      key: ValueKey('customer-method-$gen'),
      label: Text(l10n.customerMethod),
      items: {
        for (final m in debtPaymentMethodOrder)
          paymentMethodLabel(l10n, m): m.name,
      },
      control: .managed(
        initial: vm.method.name,
        onChange: (v) {
          if (v != null) vm.setMethod(PaymentMethod.values.byName(v));
        },
      ),
    );
    final date = FDateField.calendar(
      key: ValueKey('customer-paid-on-$gen'),
      label: Text(l10n.customerPaidOn),
      clearable: false,
      format: (context, value, _) => formatCalendarDate(value),
      selectionControl: .managedSingle(
        initial: vm.paidOn,
        toggleable: false,
        onChange: (d) {
          if (d != null) vm.setPaidOn(d);
        },
      ),
    );
    final cashHint = vm.method == PaymentMethod.cash
        ? Text(
            vm.cashToDrawer
                ? l10n.customerCashDrawerHint
                : l10n.customerCashStoreHint,
            key: const ValueKey('customer-cash-hint'),
            style: _muted(context),
          )
        : null;
    final note = FTextField(
      key: ValueKey('customer-note-$gen'),
      label: Text(l10n.customerNoteOptional),
      maxLength: CustomerLimits.note,
      control: .managed(
        initial: TextEditingValue(text: vm.note),
        onChange: (v) => vm.setNote(v.text),
      ),
    );
    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [amount, method, ?cashHint, date, note],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(child: amount),
            Expanded(child: method),
            Expanded(child: date),
          ],
        ),
        ?cashHint,
        note,
        SizedBox(height: theme.typography.body.xs.fontSize),
      ],
    );
  }
}

class _OpenTable extends StatelessWidget {
  const _OpenTable({required this.viewModel, required this.narrow});

  final CustomerPanelViewModel viewModel;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final detail = vm.detail!;
    final allocations = vm.allocations;
    final showAllocation = vm.canReceive;
    final head = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
      fontWeight: FontWeight.w600,
    );
    final body = theme.typography.body.sm.copyWith(fontFeatures: _tabular);
    final flex = narrow ? const [40, 0, 0, 30, 30] : const [30, 18, 17, 17, 18];
    Widget cells(List<Widget> children, {bool top = true, Color? color}) =>
        DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            border: top
                ? Border(top: BorderSide(color: theme.colors.border))
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              spacing: 8,
              children: [
                for (var i = 0; i < children.length; i++)
                  if (flex[i] > 0) Expanded(flex: flex[i], child: children[i]),
              ],
            ),
          ),
        );
    Text right(String s, {TextStyle? style}) =>
        Text(s, textAlign: TextAlign.end, style: style ?? body);
    final rows = <Widget>[
      cells(top: false, color: theme.colors.muted, [
        Text(l10n.customerColInvoice, style: head),
        Text(l10n.customerColDue, style: head),
        right(l10n.customerColTotal, style: head),
        right(l10n.customerColRest, style: head),
        right(
          showAllocation ? l10n.customerColAllocation : '',
          style: head,
        ),
      ]),
      for (final r in detail.open)
        cells([
          Column(
            key: ValueKey('customer-open-${r.sale.id.uuid}'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nomor nota tidak dipatah di tanda hubung; diperkecil bila
              // kolom sempit.
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  r.sale.number,
                  maxLines: 1,
                  style: body.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                [
                  formatCalendarDayMonth(r.sale.soldAt),
                  if (narrow && r.sale.dueOn != null)
                    l10n.customerDueShort(
                      formatCalendarDayMonth(r.sale.dueOn!),
                    ),
                ].join(' · '),
                style: _muted(context),
              ),
              if (narrow && r.overdue) _OverdueBadge(),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                r.sale.dueOn == null
                    ? '—'
                    : formatCalendarDayMonth(r.sale.dueOn!),
                style: body,
              ),
              if (r.overdue) _OverdueBadge(),
            ],
          ),
          right(formatMoney(context, Money(r.sale.total))),
          right(formatMoney(context, r.outstanding)),
          if (!showAllocation)
            const SizedBox.shrink()
          else if (vm.manual)
            FTextField(
              key: ValueKey(
                'customer-alloc-${r.sale.id.uuid}-${vm.generation}',
              ),
              hint: '0',
              textAlign: TextAlign.end,
              keyboardType: TextInputType.number,
              inputFormatters: const [RupiahInputFormatter()],
              control: .managed(
                initial: TextEditingValue(
                  text: switch (allocations[r.sale.id]) {
                    final m? when m.value > 0 => groupThousands(m.value, '.'),
                    _ => '',
                  },
                ),
                onChange: (v) =>
                    vm.setAllocation(r.sale.id, parseSignedRupiah(v.text)),
              ),
            )
          else
            right(
              formatMoney(context, allocations[r.sale.id] ?? Money.zero),
              style: body.copyWith(
                fontWeight: (allocations[r.sale.id] ?? Money.zero) > Money.zero
                    ? FontWeight.w700
                    : null,
              ),
            ),
        ]),
      cells([
        Text(
          l10n.customerTotalRow,
          style: body.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        right(
          formatMoney(context, detail.row.outstanding),
          style: body.copyWith(fontWeight: FontWeight.w700),
        ),
        right(
          showAllocation ? formatMoney(context, vm.allocatedTotal) : '',
          style: body.copyWith(fontWeight: FontWeight.w700),
        ),
      ]),
    ];
    return DecoratedBox(
      key: const ValueKey('customer-open-table'),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        ),
      ),
    );
  }
}

class _OverdueBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: FBadge(
      variant: .destructive,
      child: Text(AppLocalizations.of(context).customerOverdue),
    ),
  );
}

class _Hint extends StatelessWidget {
  const _Hint({required this.viewModel});

  final CustomerPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final issue = vm.issue;
    final allocationIssue =
        issue != null &&
        issue != DebtPaymentIssue.amount &&
        issue != DebtPaymentIssue.overOutstanding;
    return FAlert(
      key: const ValueKey('customer-hint'),
      variant: allocationIssue ? .destructive : .primary,
      title: Text(
        allocationIssue
            ? debtPaymentIssueMessage(l10n, issue)
            : vm.manual
            ? l10n.customerManualHint
            : l10n.customerAutoHint(
                vm.detail!.customer.name,
                formatMoney(context, vm.balanceAfter),
              ),
      ),
    );
  }
}

class _Payments extends StatelessWidget {
  const _Payments({
    required this.viewModel,
    required this.onOpen,
    required this.onChanged,
  });

  final CustomerPanelViewModel viewModel;
  final Future<void> Function(UuidValue paymentId) onOpen;
  final Future<void> Function() onChanged;

  Future<void> _void(BuildContext context, DebtPayment p) async {
    final l10n = AppLocalizations.of(context);
    final voided = await showDebtPaymentVoidDialog(
      context,
      payment: p,
      onConfirm: (reason) async {
        await viewModel.voidPayment.execute((p.id, reason));
        return switch (viewModel.voidPayment.result) {
          Error(:final error) => error,
          _ => null,
        };
      },
      errorMessage: (e) => e is DebtPaymentNotFound
          ? l10n.debtErrNotFound
          : customerErrorMessage(l10n, e),
    );
    // Ringkasan daftar (total piutang/hutang) ikut berubah.
    if (voided) await onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final payments = viewModel.detail!.payments;
    Widget amount(DebtPayment p) => Text(
      formatMoney(context, Money(p.amount)),
      style: theme.typography.body.sm.copyWith(
        fontWeight: FontWeight.w600,
        fontFeatures: _tabular,
        decoration: p.voidedAt != null ? TextDecoration.lineThrough : null,
        color: p.voidedAt != null ? theme.colors.mutedForeground : null,
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        // Layar sempit: nominal pindah ke bawah nomor agar tombol aksi muat.
        final narrow = constraints.maxWidth < 420;
        return Column(
          key: const ValueKey('customer-payments'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text(
              l10n.customerPayments,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (payments.isEmpty)
              Text(l10n.customerNoPayments, style: _muted(context))
            else
              for (final p in payments)
                Row(
                  spacing: 4,
                  children: [
                    Expanded(
                      child: FTappable(
                        key: ValueKey('customer-payment-${p.id.uuid}'),
                        onPress: () => onOpen(p.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            spacing: 8,
                            children: [
                              Icon(
                                TablerIcons.receipt,
                                size: 18,
                                color: theme.colors.mutedForeground,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 6,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            p.number,
                                            maxLines: 1,
                                            style: theme.typography.body.sm
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        if (p.voidedAt != null)
                                          FBadge(
                                            key: ValueKey(
                                              'customer-payment-voided-${p.id.uuid}',
                                            ),
                                            variant: .destructive,
                                            child: Text(l10n.debtVoided),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      '${formatCalendarDate(p.paidOn)} · '
                                      '${debtPaymentMethodLabel(l10n, p)}',
                                      style: _muted(context),
                                    ),
                                    if (p.voidReason case final reason?)
                                      Text(
                                        l10n.debtVoidedInfo(reason),
                                        style: _muted(context),
                                      ),
                                    if (narrow) amount(p),
                                  ],
                                ),
                              ),
                              if (!narrow) amount(p),
                              Icon(
                                TablerIcons.chevronRight,
                                size: 16,
                                color: theme.colors.mutedForeground,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (viewModel.canVoid(p))
                      FTooltip(
                        tipBuilder: (context, _) => Text(l10n.debtVoidAction),
                        child: FButton.icon(
                          key: ValueKey('customer-payment-void-${p.id.uuid}'),
                          variant: .ghost,
                          onPress: viewModel.voidPayment.running
                              ? null
                              : () => _void(context, p),
                          child: Icon(
                            TablerIcons.ban,
                            color: theme.colors.destructive,
                          ),
                        ),
                      ),
                  ],
                ),
          ],
        );
      },
    );
  }
}
