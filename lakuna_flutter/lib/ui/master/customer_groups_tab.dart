import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../customers/customer_labels.dart';
import '../products/product_widgets.dart';
import 'customer_groups_view_model.dart';

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

/// Tab Master data › Grup pelanggan (F1-13, izin `customers:manage`).
class CustomerGroupsTab extends StatelessWidget {
  const CustomerGroupsTab({super.key, required this.viewModel});

  final CustomerGroupsViewModel viewModel;

  Future<void> _edit(BuildContext context, {CustomerGroupRow? row}) {
    // Dikosongkan sebelum dialog dibangun (bukan di initState) agar tidak
    // memberi tahu pendengar saat framework sedang membangun.
    viewModel.save.clearResult();
    return showFDialog<void>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
        builder: (context, style) =>
            _GroupDialog(viewModel: viewModel, row: row),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = viewModel;
      return SectionCard(
        title: l10n.masterTabCustomerGroups,
        trailing: FButton(
          key: const ValueKey('customer-groups-new'),
          size: .sm,
          mainAxisSize: .min,
          onPress: () => _edit(context),
          prefix: const Icon(TablerIcons.plus),
          child: Text(l10n.customerGroupsNew),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text(l10n.customerGroupsHint, style: _muted(context)),
            if (vm.load.error)
              LoadFailedAlert(
                message: l10n.customersLoadFailed,
                onRetry: vm.load.execute,
              )
            else if (vm.groups.isEmpty)
              Text(
                l10n.customerGroupsEmpty,
                key: const ValueKey('customer-groups-empty'),
                style: _muted(context),
              ),
            for (final r in vm.groups)
              DecoratedBox(
                key: ValueKey('customer-group-${r.group.id.uuid}'),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: theme.colors.border)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 4,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.group.name,
                                  style: theme.typography.body.sm.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  l10n.customerGroupsRowSub(
                                    r.group.termDays,
                                    r.customerCount,
                                  ),
                                  style: _muted(context),
                                ),
                              ],
                            ),
                          ),
                          FButton.icon(
                            key: ValueKey(
                              'customer-group-edit-${r.group.id.uuid}',
                            ),
                            variant: .ghost,
                            onPress: () => _edit(context, row: r),
                            child: const Icon(TablerIcons.pencil),
                          ),
                          FButton.icon(
                            key: ValueKey(
                              'customer-group-delete-${r.group.id.uuid}',
                            ),
                            variant: .ghost,
                            onPress: vm.delete.running
                                ? null
                                : () => vm.delete.execute(r.group.id),
                            child: Icon(
                              TablerIcons.trash,
                              color: theme.colors.destructive,
                            ),
                          ),
                        ],
                      ),
                      if (vm.deleteFailedId == r.group.id)
                        if (vm.delete.result case Error(:final error))
                          Text(
                            customerErrorMessage(l10n, error),
                            key: const ValueKey('customer-group-delete-error'),
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.destructive,
                            ),
                          ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class _GroupDialog extends StatefulWidget {
  const _GroupDialog({required this.viewModel, this.row});

  final CustomerGroupsViewModel viewModel;
  final CustomerGroupRow? row;

  @override
  State<_GroupDialog> createState() => _GroupDialogState();
}

class _GroupDialogState extends State<_GroupDialog> {
  late var _name = widget.row?.group.name ?? '';
  late var _term = widget.row?.group.termDays ?? CustomerLimits.defaultTermDays;
  var _submitted = false;

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (validateCustomerGroup(name: _name, termDays: _term).isNotEmpty) return;
    await widget.viewModel.save.execute((
      id: widget.row?.group.id,
      name: _name,
      termDays: _term,
    ));
    if (!mounted) return;
    if (widget.viewModel.save.result is Ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = widget.viewModel;
      final issues = _submitted
          ? validateCustomerGroup(name: _name, termDays: _term)
          : const <CustomerGroupIssue>{};
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          key: const ValueKey('customer-group-form'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              widget.row == null
                  ? l10n.customerGroupsNewTitle
                  : l10n.customerGroupsEditTitle,
              style: theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            FTextField(
              key: const ValueKey('customer-group-name'),
              label: Text(l10n.customerGroupsName),
              autofocus: true,
              error: issues.contains(CustomerGroupIssue.name)
                  ? Text(
                      customerGroupIssueMessage(l10n, CustomerGroupIssue.name),
                    )
                  : null,
              control: .managed(
                initial: TextEditingValue(text: _name),
                onChange: (v) => setState(() => _name = v.text),
              ),
            ),
            FTextField(
              key: const ValueKey('customer-group-term'),
              label: Text(l10n.customerGroupsTerm),
              description: Text(l10n.customerGroupsTermHint),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              error: issues.contains(CustomerGroupIssue.termDays)
                  ? Text(
                      customerGroupIssueMessage(
                        l10n,
                        CustomerGroupIssue.termDays,
                      ),
                    )
                  : null,
              control: .managed(
                initial: TextEditingValue(text: '$_term'),
                onChange: (v) =>
                    setState(() => _term = int.tryParse(v.text) ?? -1),
              ),
            ),
            if (vm.save.result case Error(:final error))
              Text(
                customerErrorMessage(l10n, error),
                key: const ValueKey('customer-group-error'),
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.destructive,
                ),
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
                  child: Text(l10n.customerCancel),
                ),
                FButton(
                  key: const ValueKey('customer-group-save'),
                  mainAxisSize: .min,
                  onPress: vm.save.running ? null : _save,
                  child: Text(l10n.customerSave),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
