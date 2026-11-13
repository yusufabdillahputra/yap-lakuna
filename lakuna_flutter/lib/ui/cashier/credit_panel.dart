import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import '../customers/customer_labels.dart';
import '../purchases/purchase_labels.dart' show formatCalendarDate;
import 'cashier_view_model.dart';
import '../customers/customer_form_dialog.dart' show CustomerFormScope;
import 'customer_picker.dart'
    show CustomerAvatar, NewCustomerButton, addCashierCustomer;

const _tabular = [FontFeature.tabularFigures()];

/// Panel *Kredit / piutang* di layar bayar (1.5b, F1-13): pilih pelanggan,
/// DP tunai, jatuh tempo, dan ringkasan limit.
class CreditPanel extends StatelessWidget {
  const CreditPanel({super.key, required this.viewModel});

  final CashierViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final muted = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );
    final customer = vm.creditCustomer;
    final Widget body;
    if (vm.creditCustomers == null) {
      body = vm.loadCredit.error
          ? FAlert(
              key: const ValueKey('credit-load-error'),
              variant: .destructive,
              title: Text(l10n.creditLoadFailed),
            )
          : const Center(child: FCircularProgress());
    } else if (customer == null) {
      body = _Picker(viewModel: vm);
    } else {
      body = _Form(viewModel: vm, customer: customer);
    }
    return DecoratedBox(
      key: const ValueKey('credit-panel'),
      decoration: BoxDecoration(
        color: theme.colors.card,
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  l10n.creditTitle,
                  style: theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(l10n.creditSubtitle, style: muted),
              ],
            ),
            body,
            Text(l10n.creditFootnote, style: muted),
          ],
        ),
      ),
    );
  }
}

String _termLine(AppLocalizations l10n, CustomerRow r) => [
  if (r.groupName case final g?) l10n.customerGroupLabel(g),
  l10n.creditTerm(r.termDays),
].join(' · ');

class _Picker extends StatelessWidget {
  const _Picker({required this.viewModel});

  final CashierViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final rows = vm.creditCandidates;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        FTextField(
          key: const ValueKey('credit-search'),
          label: Text(l10n.creditPickCustomer),
          hint: l10n.customersSearch,
          control: .managed(
            initial: TextEditingValue(text: vm.creditQuery),
            onChange: (v) => vm.setCreditQuery(v.text),
          ),
        ),
        if ((vm.creditCustomers?.rows ?? const []).isEmpty)
          Text(
            l10n.creditNoCustomers,
            key: const ValueKey('credit-no-customers'),
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final r in rows.take(50))
                    FTappable(
                      key: ValueKey('credit-customer-${r.customer.id.uuid}'),
                      onPress: () => vm.selectCreditCustomer(r.customer.id),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          spacing: 10,
                          children: [
                            CustomerAvatar(name: r.customer.name),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.customer.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.typography.body.sm.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _termLine(l10n, r),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.typography.body.xs.copyWith(
                                      color: theme.colors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Nominal mengecil, bukan memotong nama, di
                            // layar sempit.
                            Flexible(
                              fit: FlexFit.tight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatMoney(context, r.remainingLimit),
                                      style: theme.typography.body.sm.copyWith(
                                        fontFeatures: _tabular,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      l10n.customerRemaining,
                                      style: theme.typography.body.xs.copyWith(
                                        color: theme.colors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        if (vm.canAddCustomer)
          if (CustomerFormScope.maybeOf(context) case final repo?)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: NewCustomerButton(
                key: const ValueKey('credit-new-customer'),
                compact: true,
                onPress: () async {
                  final created = await addCashierCustomer(
                    context,
                    repo,
                    vm.creditQuery,
                  );
                  if (created != null) await vm.useNewCreditCustomer(created);
                },
              ),
            ),
      ],
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({required this.viewModel, required this.customer});

  final CashierViewModel viewModel;
  final CustomerRow customer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final muted = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );
    final issue = vm.creditIssueNow;
    Widget stat(String key, String label, Money value) => Expanded(
      child: DecoratedBox(
        key: ValueKey(key),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(label, style: muted, maxLines: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  formatMoney(context, value),
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: _tabular,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Widget sumLine(
      String label,
      String value, {
      bool strong = false,
      Color? color,
    }) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: strong
                  ? theme.typography.body.md.copyWith(
                      fontWeight: FontWeight.w700,
                    )
                  : theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
            ),
          ),
          Text(
            value,
            style:
                (strong ? theme.typography.body.md : theme.typography.body.sm)
                    .copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: _tabular,
                      color: color,
                    ),
          ),
        ],
      ),
    );
    final down = FTextField(
      key: const ValueKey('credit-down'),
      label: Text(l10n.creditDownPayment),
      description: Text(l10n.creditDownPaymentHint),
      hint: '0',
      keyboardType: TextInputType.number,
      inputFormatters: const [RupiahInputFormatter()],
      prefixBuilder: (context, style, _) => Padding(
        padding: const EdgeInsetsDirectional.only(start: 12),
        child: Text('Rp', style: muted),
      ),
      control: .managed(
        initial: TextEditingValue(
          text: vm.creditDown.value == 0
              ? ''
              : groupThousands(vm.creditDown.value, '.'),
        ),
        onChange: (v) => vm.setCreditDown(parseSignedRupiah(v.text)),
      ),
    );
    final due = FDateField.calendar(
      key: ValueKey('credit-due-${customer.customer.id.uuid}'),
      label: Text(l10n.creditDueOn),
      description: Text(l10n.creditDueOnHint),
      clearable: false,
      format: (context, value, _) => formatCalendarDate(value),
      selectionControl: .managedSingle(
        initial: vm.creditDue,
        toggleable: false,
        onChange: (d) {
          if (d != null) vm.setCreditDue(d);
        },
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 480;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            DecoratedBox(
              key: const ValueKey('credit-selected'),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  spacing: 10,
                  children: [
                    CustomerAvatar(name: customer.customer.name),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.customer.name,
                            style: theme.typography.body.md.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(_termLine(l10n, customer), style: muted),
                        ],
                      ),
                    ),
                    FButton(
                      key: const ValueKey('credit-change'),
                      variant: .outline,
                      size: .sm,
                      mainAxisSize: .min,
                      onPress: vm.pay.running ? null : vm.clearCreditCustomer,
                      prefix: const Icon(TablerIcons.switchHorizontal),
                      child: Text(l10n.creditChange),
                    ),
                  ],
                ),
              ),
            ),
            if (narrow)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      stat(
                        'credit-limit',
                        l10n.customerLimit,
                        customer.creditLimit,
                      ),
                      stat(
                        'credit-running',
                        l10n.creditRunning,
                        customer.outstanding,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      stat(
                        'credit-remaining',
                        l10n.customerRemaining,
                        customer.remainingLimit,
                      ),
                    ],
                  ),
                ],
              )
            else
              Row(
                spacing: 12,
                children: [
                  stat(
                    'credit-limit',
                    l10n.customerLimit,
                    customer.creditLimit,
                  ),
                  stat(
                    'credit-running',
                    l10n.creditRunning,
                    customer.outstanding,
                  ),
                  stat(
                    'credit-remaining',
                    l10n.customerRemaining,
                    customer.remainingLimit,
                  ),
                ],
              ),
            if (narrow) ...[
              down,
              due,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Expanded(child: down),
                  Expanded(child: due),
                ],
              ),
            DecoratedBox(
              key: const ValueKey('credit-summary'),
              decoration: BoxDecoration(
                color: theme.colors.muted,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    sumLine(
                      l10n.creditInvoiceTotal,
                      formatMoney(context, vm.payTotal),
                    ),
                    sumLine(
                      l10n.creditPaidNow,
                      '- ${formatMoney(context, vm.creditDown)}',
                    ),
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      color: theme.colors.border,
                    ),
                    sumLine(
                      l10n.creditBecomesDebt,
                      formatMoney(context, vm.creditDebt),
                      strong: true,
                    ),
                    sumLine(
                      l10n.creditRemainingAfter,
                      formatMoney(context, vm.creditRemainingAfter),
                      color: vm.creditRemainingAfter.isNegative
                          ? theme.colors.destructive
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            if (issue != null)
              FAlert(
                key: const ValueKey('credit-issue'),
                variant: .destructive,
                icon: const Icon(TablerIcons.alertTriangle),
                title: Text(
                  issue == CreditIssue.overLimit
                      ? l10n.creditOverLimitTitle
                      : creditIssueMessage(l10n, issue),
                ),
                subtitle: issue == CreditIssue.overLimit
                    ? Text(
                        l10n.creditOverLimit(
                          formatMoney(context, customer.creditLimit),
                        ),
                      )
                    : null,
              ),
          ],
        );
      },
    );
  }
}
