import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart' show Customer;
import 'package:lakuna_data/lakuna_data.dart' show CustomerRow;
import 'package:lakuna_domain/lakuna_domain.dart' show Money;
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/customers_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import '../customers/customer_form_dialog.dart';
import '../products/product_widgets.dart' show LoadFailedAlert;
import 'cashier_view_model.dart';

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.take(2).map((w) => w.characters.first.toUpperCase()).join();
}

/// Lingkaran inisial pelanggan (Kasir, pemilih kredit).
class CustomerAvatar extends StatelessWidget {
  const CustomerAvatar({super.key, required this.name, this.size = 36});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials(name),
        style: theme.typography.body.xs.copyWith(
          color: theme.colors.primaryForeground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Membuka dialog *Pilih pelanggan* (1.4b). Pilihan langsung dipasang ke
/// nota lewat [CashierViewModel.selectCustomer].
Future<void> pickCashierCustomer(
  BuildContext context,
  CashierViewModel vm,
) async {
  vm.setCustomerQuery('');
  vm.customers.execute();
  // Dialog berada di atas layar Kasir: repositori pelanggan dibaca di sini.
  final customers = vm.canAddCustomer
      ? CustomerFormScope.maybeOf(context)
      : null;
  await showFDialog<void>(
    context: context,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 440),
      builder: (context, style) =>
          CustomerPicker(viewModel: vm, customers: customers),
    ),
  );
}

/// Form *Pelanggan baru* dari Kasir (F1-04f) dengan isian awal dari kata
/// pencarian [query]. Hasil `null` bila dibatalkan.
Future<Customer?> addCashierCustomer(
  BuildContext context,
  CustomersRepository customers,
  String query,
) {
  final draft = customerDraftFromQuery(query);
  return showCustomerForm(
    context,
    customers,
    initialName: draft.name,
    initialPhone: draft.phone,
  );
}

/// Tombol *Pelanggan baru* (pemilih Kasir dan panel kredit).
class NewCustomerButton extends StatelessWidget {
  const NewCustomerButton({
    super.key,
    required this.onPress,
    this.compact = false,
  });

  final VoidCallback? onPress;
  final bool compact;

  @override
  Widget build(BuildContext context) => FButton(
    variant: .outline,
    size: compact ? .sm : .md,
    prefix: const Icon(TablerIcons.userPlus, size: 16),
    onPress: onPress,
    child: Flexible(
      child: Text(
        AppLocalizations.of(context).cashierCustomerNew,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

/// Isi dialog *Pilih pelanggan*: cari nama/HP, sisa limit, lewat tempo.
class CustomerPicker extends StatelessWidget {
  const CustomerPicker({super.key, required this.viewModel, this.customers});

  final CashierViewModel viewModel;

  /// Repositori untuk *Pelanggan baru*; `null` = tombol tidak tampil.
  final CustomersRepository? customers;

  Future<void> _addNew(BuildContext context, CustomersRepository repo) async {
    final created = await addCashierCustomer(
      context,
      repo,
      viewModel.customerQuery,
    );
    if (created == null || !context.mounted) return;
    await viewModel.useNewCustomer(created);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final vm = viewModel;
        final all = vm.customerList?.rows ?? const <CustomerRow>[];
        final rows = vm.customerCandidates;
        final Widget body;
        if (vm.customerList == null && vm.customers.error) {
          body = LoadFailedAlert(
            key: const ValueKey('customer-picker-error'),
            message: l10n.cashierCustomerLoadFailed,
            onRetry: vm.customers.execute,
          );
        } else if (vm.customerList == null) {
          body = const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: FCircularProgress()),
          );
        } else if (all.isEmpty) {
          body = Text(
            l10n.cashierCustomerNone,
            key: const ValueKey('customer-picker-none'),
            style: muted,
          );
        } else if (rows.isEmpty) {
          body = Text(
            l10n.cashierCustomerNoMatch,
            key: const ValueKey('customer-picker-no-match'),
            style: muted,
          );
        } else {
          body = Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final r in rows.take(50))
                    _CustomerTile(
                      row: r,
                      onPress: () {
                        vm.selectCustomer(r);
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
          );
        }
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              key: const ValueKey('customer-picker'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  l10n.cashierCustomerPick,
                  style: theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                FTextField(
                  key: const ValueKey('customer-picker-search'),
                  hint: l10n.cashierCustomerSearch,
                  autofocus: true,
                  prefixBuilder: (context, style, variants) => Padding(
                    padding: const EdgeInsetsDirectional.only(start: 10),
                    child: Icon(
                      TablerIcons.search,
                      size: 16,
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  control: .managed(
                    initial: TextEditingValue(text: vm.customerQuery),
                    onChange: (v) => vm.setCustomerQuery(v.text),
                  ),
                ),
                body,
                if (customers case final repo?)
                  NewCustomerButton(
                    key: const ValueKey('customer-picker-new'),
                    onPress: () => _addNew(context, repo),
                  ),
                FButton(
                  key: const ValueKey('customer-picker-close'),
                  variant: .outline,
                  onPress: () => Navigator.of(context).pop(),
                  child: Flexible(
                    child: Text(
                      l10n.cashierCancel,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({required this.row, required this.onPress});

  final CustomerRow row;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final c = row.customer;
    final sub = [
      if (c.phone case final phone? when phone.isNotEmpty) phone,
      ?row.groupName,
    ].join(' · ');
    final xs = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );
    return FTappable(
      key: ValueKey('customer-picker-${c.id.uuid}'),
      semanticsLabel: c.name,
      onPress: onPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          spacing: 10,
          children: [
            CustomerAvatar(name: c.name),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (sub.isNotEmpty)
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: xs,
                    ),
                  if (row.creditLimit > Money.zero)
                    Text(
                      l10n.cashierCustomerRemaining(
                        formatMoney(context, row.remainingLimit),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: xs,
                    ),
                  if (row.overdueCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: FBadge(
                        key: ValueKey('customer-picker-overdue-${c.id.uuid}'),
                        variant: .destructive,
                        child: Text(l10n.cashierCustomerOverdue),
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
