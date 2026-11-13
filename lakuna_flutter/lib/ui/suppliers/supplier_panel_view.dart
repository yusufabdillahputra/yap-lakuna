import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart' show DebtPaymentNotFound;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/suppliers_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/format.dart';
import '../customers/customer_labels.dart' show formatPhone;
import '../products/product_widgets.dart';
import '../purchases/purchase_labels.dart'
    show formatCalendarDate, formatCalendarDayMonth;
import 'supplier_form_dialog.dart';
import 'supplier_labels.dart';
import '../customers/debt_payment_void_dialog.dart';
import 'supplier_panel_view_model.dart';
import 'supplier_purchases_dialog.dart';

const _tabular = [FontFeature.tabularFigures()];

/// Di bawah lebar ini tabel pembelian dan isian bayar ditumpuk.
const supplierPanelNarrowWidth = 560.0;

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

/// Halaman satu supplier di layar sempit (`/supplier/:id`).
class SupplierDetailPage extends StatefulWidget {
  const SupplierDetailPage({
    super.key,
    required this.repository,
    required this.supplierId,
    required this.onBack,
    required this.onOpenPurchase,
    this.imagePicker = const FileSelectorImagePicker(),
  });

  final SuppliersRepository repository;
  final UuidValue supplierId;
  final VoidCallback onBack;
  final Future<void> Function(UuidValue purchaseId) onOpenPurchase;
  final ImageFilePicker imagePicker;

  @override
  State<SupplierDetailPage> createState() => _SupplierDetailPageState();
}

class _SupplierDetailPageState extends State<SupplierDetailPage> {
  late final _vm = SupplierPanelViewModel(
    repository: widget.repository,
    supplierId: widget.supplierId,
    picker: widget.imagePicker,
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
      key: const ValueKey('supplier-page-scroll'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FButton(
              key: const ValueKey('supplier-back'),
              variant: .outline,
              mainAxisSize: .min,
              onPress: widget.onBack,
              prefix: const Icon(TablerIcons.chevronLeft),
              child: Flexible(child: Text(l10n.suppliersTitle)),
            ),
          ),
          SupplierPanel(
            repository: widget.repository,
            viewModel: _vm,
            onChanged: () async {},
            onDeleted: widget.onBack,
            onOpenPurchase: (id) async {
              await widget.onOpenPurchase(id);
              if (mounted) await _vm.load.execute();
            },
          ),
        ],
      ),
    );
  }
}

/// Panel supplier terpilih (1.21, kanan): bayar hutang.
class SupplierPanel extends StatelessWidget {
  const SupplierPanel({
    super.key,
    required this.repository,
    required this.viewModel,
    required this.onChanged,
    required this.onDeleted,
    required this.onOpenPurchase,
  });

  final SuppliersRepository repository;
  final SupplierPanelViewModel viewModel;

  /// Data supplier atau hutang berubah: muat ulang daftar.
  final Future<void> Function() onChanged;
  final VoidCallback onDeleted;
  final Future<void> Function(UuidValue purchaseId) onOpenPurchase;

  Future<void> _edit(BuildContext context) async {
    final supplier = viewModel.detail?.supplier;
    if (supplier == null) return;
    final saved = await showSupplierForm(
      context,
      repository,
      supplier: supplier,
    );
    if (saved == null) return;
    await viewModel.load.execute();
    await onChanged();
  }

  Future<void> _history(BuildContext context) async {
    final supplier = viewModel.detail?.supplier;
    if (supplier == null) return;
    final id = await showSupplierPurchases(context, repository, supplier);
    if (id != null) await onOpenPurchase(id);
  }

  Future<void> _delete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final name = viewModel.detail?.supplier.name ?? '';
    final ok = await showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
        builder: (context, style) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('supplier-delete-confirm'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                l10n.supplierDeleteTitle(name),
                style: context.theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(l10n.supplierDeleteBody, style: _muted(context)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  FButton(
                    key: const ValueKey('supplier-delete-cancel'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: () => Navigator.of(context).pop(false),
                    child: Flexible(child: Text(l10n.supplierCancel)),
                  ),
                  FButton(
                    key: const ValueKey('supplier-delete-ok'),
                    variant: .destructive,
                    mainAxisSize: .min,
                    onPress: () => Navigator.of(context).pop(true),
                    child: Flexible(child: Text(l10n.supplierDeleteAction)),
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

  Future<void> _pay() async {
    await viewModel.pay.execute();
    if (viewModel.pay.result is Ok) await onChanged();
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
            key: const ValueKey('supplier-load-error'),
            message: supplierErrorMessage(l10n, error),
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
      final s = detail.supplier;
      final hasDebt = detail.open.isNotEmpty;
      final sub = [
        if (s.contactName case final c?) l10n.supplierContact(c),
        l10n.supplierTerm(s.termDays),
      ].join(' · ');
      final contact = [
        if (s.phone case final p?) formatPhone(p),
        ?s.category,
        ?s.address,
      ].join(' · ');
      return FCard(
        key: ValueKey('supplier-panel-${s.id.uuid}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < supplierPanelNarrowWidth;
              final actions = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FButton(
                    key: const ValueKey('supplier-history-open'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: () => _history(context),
                    child: Flexible(
                      child: Text(
                        l10n.supplierHistory,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (vm.canManage)
                    FButton(
                      key: const ValueKey('supplier-edit'),
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: () => _edit(context),
                      child: Flexible(
                        child: Text(
                          l10n.supplierEdit,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              );
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    hasDebt && vm.canPay
                        ? l10n.supplierPayTitle(s.name)
                        : s.name,
                    style: theme.typography.display.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(sub, style: _muted(context)),
                  if (contact.isNotEmpty) Text(contact, style: _muted(context)),
                  if (s.note case final n?)
                    Text(
                      n,
                      style: _muted(
                        context,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                ],
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  if (narrow) ...[
                    title,
                    actions,
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Expanded(child: title),
                        actions,
                      ],
                    ),
                  if (vm.pay.result case Ok(:final value))
                    FAlert(
                      key: const ValueKey('supplier-paid'),
                      title: Text(l10n.supplierPaid(value.number)),
                    ),
                  if (!hasDebt)
                    Text(
                      l10n.supplierNoDebt,
                      key: const ValueKey('supplier-no-debt'),
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    )
                  else ...[
                    if (vm.canPay)
                      _PaymentFields(viewModel: vm, narrow: narrow),
                    _OpenTable(viewModel: vm, narrow: narrow),
                    if (vm.canPay) ...[
                      _Hints(viewModel: vm),
                      if (vm.pay.result case Error(:final error))
                        Text(
                          supplierErrorMessage(l10n, error),
                          key: const ValueKey('supplier-pay-error'),
                          style: theme.typography.body.sm.copyWith(
                            color: theme.colors.destructive,
                          ),
                        ),
                      _Proof(viewModel: vm),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          FButton(
                            key: const ValueKey('supplier-manual'),
                            variant: .outline,
                            mainAxisSize: .min,
                            onPress: () => vm.setManual(!vm.manual),
                            child: Flexible(
                              child: Text(
                                vm.manual
                                    ? l10n.supplierAuto
                                    : l10n.supplierManual,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          FButton(
                            key: const ValueKey('supplier-pay'),
                            mainAxisSize: .min,
                            onPress: vm.canSubmit ? _pay : null,
                            prefix: vm.pay.running
                                ? const SizedBox.square(
                                    dimension: 16,
                                    child: FCircularProgress(),
                                  )
                                : const Icon(TablerIcons.check),
                            child: Flexible(
                              child: Text(
                                l10n.supplierSavePayment,
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
                    repository: repository,
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
                            key: const ValueKey('supplier-delete'),
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
                                l10n.supplierDelete,
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
                              supplierErrorMessage(l10n, error),
                              key: const ValueKey('supplier-delete-error'),
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

class _PaymentFields extends StatelessWidget {
  const _PaymentFields({required this.viewModel, required this.narrow});

  final SupplierPanelViewModel viewModel;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final gen = vm.generation;
    final issue = vm.issue;
    final amount = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        FTextField(
          key: ValueKey('supplier-amount-$gen'),
          label: Text(l10n.supplierAmount),
          hint: '0',
          keyboardType: TextInputType.number,
          inputFormatters: const [RupiahInputFormatter()],
          prefixBuilder: _rpPrefix,
          error:
              issue == DebtPaymentIssue.amount ||
                  issue == DebtPaymentIssue.overOutstanding
              ? Text(supplierPaymentIssueMessage(l10n, issue!))
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
            key: const ValueKey('supplier-pay-all'),
            variant: .outline,
            size: .sm,
            mainAxisSize: .min,
            onPress: vm.payAll,
            child: Flexible(
              child: Text(
                l10n.supplierPayAll,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
    final funding = FSelect<String>(
      key: ValueKey('supplier-funding-$gen'),
      label: Text(l10n.supplierFunding),
      items: {
        for (final f in supplierFundingOrder)
          supplierFundingLabel(l10n, f): f.name,
      },
      control: .managed(
        initial: vm.funding.name,
        onChange: (v) {
          if (v != null) vm.setFunding(FundingSource.values.byName(v));
        },
      ),
    );
    final reference = FTextField(
      key: ValueKey('supplier-reference-$gen'),
      label: Text(l10n.supplierReference),
      hint: l10n.supplierReferenceHint,
      maxLength: SupplierLimits.reference,
      control: .managed(
        initial: TextEditingValue(text: vm.reference),
        onChange: (v) => vm.setReference(v.text),
      ),
    );
    final date = FDateField.calendar(
      key: ValueKey('supplier-paid-on-$gen'),
      label: Text(l10n.supplierPaidOn),
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
    final note = FTextField(
      key: ValueKey('supplier-note-$gen'),
      label: Text(l10n.supplierNoteOptional),
      maxLength: SupplierLimits.paymentNote,
      control: .managed(
        initial: TextEditingValue(text: vm.note),
        onChange: (v) => vm.setNote(v.text),
      ),
    );
    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [amount, funding, reference, date, note],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(child: amount),
            Expanded(child: funding),
            Expanded(child: reference),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(child: date),
            Expanded(flex: 2, child: note),
          ],
        ),
      ],
    );
  }
}

class _OpenTable extends StatelessWidget {
  const _OpenTable({required this.viewModel, required this.narrow});

  final SupplierPanelViewModel viewModel;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final detail = vm.detail!;
    final allocations = vm.allocations;
    final showPay = vm.canPay;
    final head = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
      fontWeight: FontWeight.w600,
    );
    final body = theme.typography.body.sm.copyWith(fontFeatures: _tabular);
    final flex = narrow ? const [40, 0, 0, 30, 30] : const [30, 16, 18, 18, 18];
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
    Widget right(String s, {TextStyle? style}) => FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(
        s,
        maxLines: 1,
        textAlign: TextAlign.end,
        style: style ?? body,
      ),
    );
    final rows = <Widget>[
      cells(top: false, color: theme.colors.muted, [
        Text(l10n.supplierColPurchase, style: head),
        Text(l10n.supplierColDue, style: head),
        right(l10n.supplierColTotal, style: head),
        right(l10n.supplierColRest, style: head),
        right(showPay ? l10n.supplierColPay : '', style: head),
      ]),
      for (final r in detail.open)
        cells([
          Column(
            key: ValueKey('supplier-open-${r.purchase.id.uuid}'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  r.purchase.number,
                  maxLines: 1,
                  style: body.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                [
                  formatCalendarDayMonth(r.purchase.purchasedOn),
                  if (narrow && r.purchase.dueOn != null)
                    l10n.supplierDueShort(
                      formatCalendarDayMonth(r.purchase.dueOn!),
                    ),
                ].join(' · '),
                style: _muted(context),
              ),
              if (narrow && r.overdue) const _OverdueBadge(),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                r.purchase.dueOn == null
                    ? '—'
                    : formatCalendarDayMonth(r.purchase.dueOn!),
                style: r.overdue
                    ? body.copyWith(color: theme.colors.destructive)
                    : body,
              ),
              if (r.overdue) const _OverdueBadge(),
            ],
          ),
          right(formatMoney(context, Money(r.purchase.total))),
          right(formatMoney(context, r.outstanding)),
          if (!showPay)
            const SizedBox.shrink()
          else if (vm.manual)
            FTextField(
              key: ValueKey(
                'supplier-alloc-${r.purchase.id.uuid}-${vm.generation}',
              ),
              hint: '0',
              textAlign: TextAlign.end,
              keyboardType: TextInputType.number,
              inputFormatters: const [RupiahInputFormatter()],
              control: .managed(
                initial: TextEditingValue(
                  text: switch (allocations[r.purchase.id]) {
                    final m? when m.value > 0 => groupThousands(m.value, '.'),
                    _ => '',
                  },
                ),
                onChange: (v) => vm.setAllocation(
                  r.purchase.id,
                  parseSignedRupiah(v.text),
                ),
              ),
            )
          else
            right(
              formatMoney(context, allocations[r.purchase.id] ?? Money.zero),
              style: body.copyWith(
                fontWeight:
                    (allocations[r.purchase.id] ?? Money.zero) > Money.zero
                    ? FontWeight.w700
                    : null,
              ),
            ),
        ]),
      cells([
        Text(
          l10n.supplierTotalRow,
          style: body.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox.shrink(),
        const SizedBox.shrink(),
        right(
          formatMoney(context, detail.row.debt),
          style: body.copyWith(fontWeight: FontWeight.w700),
        ),
        right(
          showPay ? formatMoney(context, vm.allocatedTotal) : '',
          style: body.copyWith(fontWeight: FontWeight.w700),
        ),
      ]),
    ];
    return DecoratedBox(
      key: const ValueKey('supplier-open-table'),
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
  const _OverdueBadge();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: FBadge(
      variant: .destructive,
      child: Text(AppLocalizations.of(context).supplierOverdue),
    ),
  );
}

class _Hints extends StatelessWidget {
  const _Hints({required this.viewModel});

  final SupplierPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final issue = vm.issue;
    final allocationIssue =
        issue != null &&
        issue != DebtPaymentIssue.amount &&
        issue != DebtPaymentIssue.overOutstanding;
    final name = vm.detail!.supplier.name;
    final rest = formatMoney(context, vm.balanceAfter);
    final due = vm.nextDueAfter;
    final drawer = vm.drawerIssue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        FAlert(
          key: const ValueKey('supplier-hint'),
          variant: allocationIssue ? .destructive : .primary,
          title: Text(
            allocationIssue
                ? supplierPaymentIssueMessage(l10n, issue)
                : vm.manual
                ? l10n.supplierManualHint
                : due == null
                ? l10n.supplierAutoHint(name, rest)
                : l10n.supplierAutoHintDue(
                    name,
                    rest,
                    formatCalendarDayMonth(due),
                  ),
          ),
        ),
        if (vm.funding == FundingSource.drawer)
          FAlert(
            key: const ValueKey('supplier-drawer-hint'),
            variant: drawer == null ? .primary : .destructive,
            title: Text(
              drawer == null
                  ? l10n.supplierDrawerHint
                  : drawerIssueMessage(l10n, drawer),
            ),
          ),
      ],
    );
  }
}

class _Proof extends StatelessWidget {
  const _Proof({required this.viewModel});

  final SupplierPanelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final proof = vm.proof;
    final busy = vm.pickProof.running;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        if (proof != null)
          Row(
            key: const ValueKey('supplier-proof-preview'),
            spacing: 10,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.memory(
                  proof.bytes,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              ),
              Expanded(
                child: Text(
                  proof.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm,
                ),
              ),
              FButton.icon(
                key: const ValueKey('supplier-proof-remove'),
                variant: .ghost,
                onPress: vm.removeProof,
                child: Icon(TablerIcons.x, color: theme.colors.destructive),
              ),
            ],
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FButton(
              key: const ValueKey('supplier-proof-pick'),
              variant: .outline,
              mainAxisSize: .min,
              onPress: busy ? null : () => vm.pickProof.execute(false),
              prefix: const Icon(TablerIcons.paperclip),
              child: Flexible(
                child: Text(
                  l10n.supplierAttachProof,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (vm.canTakePhoto)
              FButton(
                key: const ValueKey('supplier-proof-camera'),
                variant: .outline,
                mainAxisSize: .min,
                onPress: busy ? null : () => vm.pickProof.execute(true),
                prefix: const Icon(TablerIcons.camera),
                child: Flexible(
                  child: Text(
                    l10n.supplierTakePhoto,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
        if (vm.proofIssue case final issue?)
          Text(
            proofIssueMessage(l10n, issue),
            key: const ValueKey('supplier-proof-error'),
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.destructive,
            ),
          ),
      ],
    );
  }
}

class _Payments extends StatelessWidget {
  const _Payments({
    required this.viewModel,
    required this.repository,
    required this.onChanged,
  });

  final SupplierPanelViewModel viewModel;
  final SuppliersRepository repository;
  final Future<void> Function() onChanged;

  Future<void> _showProof(BuildContext context, DebtPayment p) async {
    final result = await repository.proof(p.id);
    if (!context.mounted) return;
    final bytes = switch (result) {
      Ok(:final value) => value,
      Error() => null,
    };
    await showFDialog<void>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 520),
        builder: (context, style) =>
            _ProofDialog(number: p.number, bytes: bytes),
      ),
    );
  }

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
          : supplierErrorMessage(l10n, e),
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
          key: const ValueKey('supplier-payments'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Text(
              l10n.supplierPayments,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (payments.isEmpty)
              Text(l10n.supplierNoPayments, style: _muted(context))
            else
              for (final p in payments)
                Padding(
                  key: ValueKey('supplier-payment-${p.id.uuid}'),
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
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    p.number,
                                    maxLines: 1,
                                    style: theme.typography.body.sm.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (p.voidedAt != null)
                                  FBadge(
                                    key: ValueKey(
                                      'supplier-payment-voided-${p.id.uuid}',
                                    ),
                                    variant: .destructive,
                                    child: Text(l10n.debtVoided),
                                  ),
                              ],
                            ),
                            Text(
                              [
                                formatCalendarDate(p.paidOn),
                                if (p.fundingSource case final f?)
                                  supplierFundingLabel(l10n, f),
                                ?p.reference,
                              ].join(' · '),
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
                      if (p.proofMediaId != null)
                        FButton.icon(
                          key: ValueKey('supplier-payment-proof-${p.id.uuid}'),
                          variant: .ghost,
                          onPress: () => _showProof(context, p),
                          child: const Icon(TablerIcons.photo),
                        ),
                      if (viewModel.canVoid(p))
                        FTooltip(
                          tipBuilder: (context, _) => Text(l10n.debtVoidAction),
                          child: FButton.icon(
                            key: ValueKey('supplier-payment-void-${p.id.uuid}'),
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
                ),
          ],
        );
      },
    );
  }
}

class _ProofDialog extends StatelessWidget {
  const _ProofDialog({required this.number, required this.bytes});

  final String number;
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final image = bytes;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        key: const ValueKey('supplier-proof-dialog'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            l10n.supplierProofTitle(number),
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (image == null)
            Text(l10n.supplierProofMissing, style: _muted(context))
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.6,
              ),
              child: Image.memory(image, fit: BoxFit.contain),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: FButton(
              key: const ValueKey('supplier-proof-close'),
              variant: .outline,
              mainAxisSize: .min,
              onPress: () => Navigator.of(context).pop(),
              child: Text(l10n.supplierClose),
            ),
          ),
        ],
      ),
    );
  }
}
