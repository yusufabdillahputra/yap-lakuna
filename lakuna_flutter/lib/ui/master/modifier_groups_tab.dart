import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/format.dart';
import '../products/product_widgets.dart';
import 'modifier_groups_view_model.dart';

/// Label aturan grup: "Wajib · pilih 1", "Wajib · pilih 1–2",
/// "Opsional · maks 2".
String modifierRuleLabel(AppLocalizations l10n, int min, int max) => min > 0
    ? (min == max
          ? l10n.modifierRuleRequired(min)
          : l10n.modifierRuleRequiredRange(min, max))
    : l10n.modifierRuleOptional(max);

/// Tambahan harga opsi: `+Rp 4.000`, `-Rp 3.000`; nol = kosong.
String modifierDeltaLabel(BuildContext context, Money delta) =>
    delta == Money.zero
    ? ''
    : '${delta.isNegative ? '' : '+'}${formatMoney(context, delta)}';

String modifierErrorMessage(AppLocalizations l10n, ModifierGroupError e) =>
    switch (e) {
      ModifierGroupError.nameEmpty => l10n.modifierErrNameEmpty,
      ModifierGroupError.nameTooLong => l10n.modifierErrNameTooLong(
        ModifierLimits.groupName,
      ),
      ModifierGroupError.nameDuplicate => l10n.modifierErrNameDuplicate,
      ModifierGroupError.selectRange => l10n.modifierErrSelectRange(
        ModifierLimits.selectMax,
      ),
      ModifierGroupError.minAboveOptions => l10n.modifierErrMinAboveOptions,
      ModifierGroupError.optionCount => l10n.modifierErrOptionCount(
        ModifierLimits.optionsMax,
      ),
      ModifierGroupError.optionNameEmpty => l10n.modifierErrOptionNameEmpty,
      ModifierGroupError.optionNameTooLong => l10n.modifierErrNameTooLong(
        ModifierLimits.optionName,
      ),
      ModifierGroupError.optionNameDuplicate =>
        l10n.modifierErrOptionNameDuplicate,
      ModifierGroupError.optionPrice => l10n.modifierErrOptionPrice,
      ModifierGroupError.defaultsAboveMax => l10n.modifierErrDefaultsAboveMax,
    };

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

/// Tab Master data › Grup modifier (F1-10b, 1.17b, izin `products:manage`).
class ModifierGroupsTab extends StatelessWidget {
  const ModifierGroupsTab({super.key, required this.viewModel});

  final ModifierGroupsViewModel viewModel;

  Future<void> _edit(BuildContext context, {ModifierGroupDetail? group}) =>
      showFDialog<void>(
        context: context,
        builder: (context, style, animation) => FDialog(
          animation: animation,
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
          builder: (context, style) =>
              _GroupDialog(viewModel: viewModel, group: group),
        ),
      );

  Future<void> _delete(BuildContext context, ModifierGroupDetail g) async {
    final ok = await showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
        builder: (context, style) {
          final l10n = AppLocalizations.of(context);
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              key: const ValueKey('modifier-confirm'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  l10n.modifierDeleteTitle(g.name),
                  style: context.theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(l10n.modifierDeleteBody, style: _muted(context)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    FButton(
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: () => Navigator.of(context).pop(false),
                      child: Flexible(child: Text(l10n.diningSetupCancel)),
                    ),
                    FButton(
                      key: const ValueKey('modifier-confirm-delete'),
                      variant: .destructive,
                      mainAxisSize: .min,
                      onPress: () => Navigator.of(context).pop(true),
                      child: Flexible(child: Text(l10n.diningSetupDelete)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    if (ok ?? false) await viewModel.delete.execute(g.id);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = viewModel;
      if (!vm.loaded) {
        if (vm.load.error) {
          return LoadFailedAlert(
            key: const ValueKey('modifier-load-error'),
            message: l10n.modifierLoadFailed,
            onRetry: vm.load.execute,
          );
        }
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: FCircularProgress()),
        );
      }
      final busy = vm.busy;
      final groups = vm.groups;

      Widget iconButton(
        String key,
        IconData icon,
        String label,
        VoidCallback? onPress,
      ) => FButton.icon(
        key: ValueKey(key),
        size: .sm,
        variant: .ghost,
        semanticsLabel: label,
        onPress: busy ? null : onPress,
        child: Icon(icon, size: 16),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(l10n.modifierHint, style: _muted(context)),
          if (vm.error case final error?)
            FAlert(
              key: const ValueKey('modifier-error'),
              variant: .destructive,
              title: Text(switch (error) {
                MasterInUse(:final products) => l10n.modifierErrInUse(
                  products,
                ),
                _ => l10n.modifierErrGeneric,
              }),
            ),
          SectionCard(
            title: l10n.modifierGroups,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FButton(
                    key: const ValueKey('modifier-add'),
                    size: .sm,
                    mainAxisSize: .min,
                    prefix: const Icon(TablerIcons.plus, size: 16),
                    onPress: busy ? null : () => _edit(context),
                    child: Flexible(child: Text(l10n.modifierAdd)),
                  ),
                ),
                if (groups.isEmpty)
                  Text(l10n.modifierEmpty, style: _muted(context))
                else
                  for (final (i, g) in groups.indexed)
                    Padding(
                      key: ValueKey('modifier-group-${g.name}'),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 2,
                              children: [
                                Text(
                                  g.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.typography.body.sm.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  [
                                    modifierRuleLabel(
                                      l10n,
                                      g.group.minSelect,
                                      g.group.maxSelect,
                                    ),
                                    l10n.modifierOptionCount(g.options.length),
                                    l10n.modifierUsedBy(g.productCount),
                                  ].join(' · '),
                                  style: _muted(context).copyWith(
                                    color: g.isRequired
                                        ? theme.colors.primary
                                        : null,
                                  ),
                                ),
                                Text(
                                  [
                                    for (final o in g.options)
                                      [
                                        o.name,
                                        modifierDeltaLabel(
                                          context,
                                          Money(o.priceDelta),
                                        ),
                                        if (!o.isAvailable)
                                          '(${l10n.modifierOptionSoldOut})',
                                      ].where((s) => s.isNotEmpty).join(' '),
                                  ].join(', '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: _muted(context),
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            children: [
                              iconButton(
                                'modifier-up-${g.name}',
                                TablerIcons.arrowUp,
                                l10n.diningSetupMoveUp,
                                i == 0
                                    ? null
                                    : () => vm.move.execute((g.id, -1)),
                              ),
                              iconButton(
                                'modifier-down-${g.name}',
                                TablerIcons.arrowDown,
                                l10n.diningSetupMoveDown,
                                i == groups.length - 1
                                    ? null
                                    : () => vm.move.execute((g.id, 1)),
                              ),
                              iconButton(
                                'modifier-edit-${g.name}',
                                TablerIcons.pencil,
                                l10n.diningSetupEdit,
                                () => _edit(context, group: g),
                              ),
                              iconButton(
                                'modifier-delete-${g.name}',
                                TablerIcons.trash,
                                l10n.diningSetupDelete,
                                () => _delete(context, g),
                              ),
                            ],
                          ),
                        ],
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

class _Option {
  _Option(
    this.key, {
    this.id,
    this.name = '',
    this.price = Money.zero,
    this.isDefault = false,
    this.isAvailable = true,
  });

  final int key;
  final String? id;
  String name;
  Money price;
  bool isDefault;
  bool isAvailable;
}

final _digits = [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(2),
];

/// Form grup (buat/ubah). Tetap terbuka sampai simpan berhasil.
class _GroupDialog extends StatefulWidget {
  const _GroupDialog({required this.viewModel, this.group});

  final ModifierGroupsViewModel viewModel;
  final ModifierGroupDetail? group;

  @override
  State<_GroupDialog> createState() => _GroupDialogState();
}

class _GroupDialogState extends State<_GroupDialog> {
  var _next = 0;
  late var _name = widget.group?.name ?? '';
  late var _required = widget.group?.isRequired ?? true;
  late var _min = '${widget.group?.group.minSelect ?? 1}';
  late var _max = '${widget.group?.group.maxSelect ?? 1}';
  late final List<_Option> _options = [
    for (final o in widget.group?.options ?? const <ModifierOption>[])
      _Option(
        _next++,
        id: o.id.uuid,
        name: o.name,
        price: Money(o.priceDelta),
        isDefault: o.isDefault,
        isAvailable: o.isAvailable,
      ),
    if (widget.group == null) _Option(_next++),
  ];
  List<ModifierGroupError> _errors = const [];
  Map<int, ModifierGroupError> _optionErrors = const {};
  var _failed = false;

  ModifierGroupDraft get _draft {
    final max = int.tryParse(_max) ?? 0;
    final min = _required ? (int.tryParse(_min) ?? 0) : 0;
    return ModifierGroupDraft(
      name: _name,
      minSelect: min,
      maxSelect: max,
      options: [
        for (final o in _options)
          ModifierOptionDraft(
            id: o.id,
            name: o.name,
            priceDelta: o.price,
            isDefault: o.isDefault,
            isAvailable: o.isAvailable,
          ),
      ],
    );
  }

  Future<void> _save() async {
    final vm = widget.viewModel;
    await vm.save.execute((widget.group?.id, _draft));
    if (!mounted) return;
    switch (vm.save.result) {
      case Ok():
        Navigator.of(context).pop();
      case Error(:final error):
        setState(() {
          if (error case ModifierGroupInvalid(
            :final errors,
            :final optionErrors,
          )) {
            _errors = errors;
            _optionErrors = optionErrors;
            _failed = false;
          } else {
            _errors = const [];
            _optionErrors = const {};
            _failed = true;
          }
        });
      case null:
        break;
    }
  }

  String? _errorOf(Set<ModifierGroupError> kinds) {
    final e = _errors.where(kinds.contains).firstOrNull;
    return e == null
        ? null
        : modifierErrorMessage(AppLocalizations.of(context), e);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final busy = widget.viewModel.save.running;
    final nameError = _errorOf(const {
      ModifierGroupError.nameEmpty,
      ModifierGroupError.nameTooLong,
      ModifierGroupError.nameDuplicate,
    });
    final selectError = _errorOf(const {
      ModifierGroupError.selectRange,
      ModifierGroupError.minAboveOptions,
    });
    final listError = _errorOf(const {
      ModifierGroupError.optionCount,
      ModifierGroupError.defaultsAboveMax,
    });
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          key: const ValueKey('modifier-dialog'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              widget.group == null
                  ? l10n.modifierNewGroup
                  : l10n.modifierEditGroup,
              style: theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            FTextField(
              key: const ValueKey('modifier-name'),
              label: Text(l10n.modifierName),
              autofocus: true,
              maxLength: ModifierLimits.groupName,
              error: nameError == null ? null : Text(nameError),
              control: .managed(
                initial: TextEditingValue(text: _name),
                onChange: (v) => _name = v.text,
              ),
            ),
            FSwitch(
              key: const ValueKey('modifier-required'),
              label: Text(l10n.modifierRequired),
              description: Text(l10n.modifierRequiredHint),
              value: _required,
              onChange: (v) => setState(() {
                _required = v;
                if (v && (int.tryParse(_min) ?? 0) < 1) _min = '1';
              }),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                if (_required)
                  Expanded(
                    child: FTextField(
                      // Kunci ikut nilai agar teks ikut berubah saat saklar
                      // Wajib menaikkan minimal ke 1.
                      key: ValueKey('modifier-min-$_required'),
                      label: Text(l10n.modifierMin),
                      keyboardType: TextInputType.number,
                      inputFormatters: _digits,
                      control: .managed(
                        initial: TextEditingValue(text: _min),
                        onChange: (v) => _min = v.text,
                      ),
                    ),
                  ),
                Expanded(
                  child: FTextField(
                    key: const ValueKey('modifier-max'),
                    label: Text(l10n.modifierMax),
                    description: Text(l10n.modifierMaxHint),
                    keyboardType: TextInputType.number,
                    inputFormatters: _digits,
                    error: selectError == null ? null : Text(selectError),
                    control: .managed(
                      initial: TextEditingValue(text: _max),
                      onChange: (v) => _max = v.text,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              l10n.modifierOptions,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(l10n.modifierOptionPriceHint, style: _muted(context)),
            if (listError != null)
              Text(
                listError,
                key: const ValueKey('modifier-options-error'),
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.destructive,
                ),
              ),
            for (final (i, o) in _options.indexed)
              _OptionRow(
                key: ValueKey('modifier-option-${o.key}'),
                index: i,
                option: o,
                error: switch (_optionErrors[i]) {
                  final e? => modifierErrorMessage(l10n, e),
                  null => null,
                },
                onChanged: () => setState(() {}),
                onRemove: _options.length <= 1
                    ? null
                    : () => setState(() {
                        _options.remove(o);
                        _optionErrors = const {};
                      }),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FButton(
                key: const ValueKey('modifier-option-add'),
                size: .sm,
                variant: .outline,
                mainAxisSize: .min,
                prefix: const Icon(TablerIcons.plus, size: 16),
                onPress: _options.length >= ModifierLimits.optionsMax
                    ? null
                    : () => setState(() => _options.add(_Option(_next++))),
                child: Flexible(child: Text(l10n.modifierOptionAdd)),
              ),
            ),
            if (_failed)
              FAlert(
                variant: .destructive,
                title: Text(l10n.modifierErrGeneric),
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
                  child: Flexible(child: Text(l10n.diningSetupCancel)),
                ),
                FButton(
                  key: const ValueKey('modifier-save'),
                  mainAxisSize: .min,
                  onPress: busy ? null : _save,
                  child: Flexible(child: Text(l10n.diningSetupSave)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    super.key,
    required this.index,
    required this.option,
    required this.onChanged,
    this.onRemove,
    this.error,
  });

  final int index;
  final _Option option;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final o = option;
    final price = o.price;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Expanded(
                  flex: 3,
                  child: FTextField(
                    key: ValueKey('modifier-option-name-$index'),
                    label: Text(l10n.modifierOptionName),
                    maxLength: ModifierLimits.optionName,
                    error: error == null ? null : Text(error!),
                    control: .managed(
                      initial: TextEditingValue(text: o.name),
                      onChange: (v) => o.name = v.text,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: FTextField(
                    key: ValueKey('modifier-option-price-$index'),
                    label: Text(l10n.modifierOptionPrice),
                    hint: '0',
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                    ),
                    inputFormatters: const [SignedRupiahInputFormatter()],
                    control: .managed(
                      initial: TextEditingValue(
                        text: price == Money.zero
                            ? ''
                            : '${price.isNegative ? '-' : ''}'
                                  '${groupThousands(price.value.abs(), '.')}',
                      ),
                      onChange: (v) => o.price = parseSignedRupiah(v.text),
                    ),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FCheckbox(
                  key: ValueKey('modifier-option-default-$index'),
                  label: Text(l10n.modifierOptionDefault),
                  value: o.isDefault,
                  onChange: (v) {
                    o.isDefault = v;
                    onChanged();
                  },
                ),
                FSwitch(
                  key: ValueKey('modifier-option-available-$index'),
                  label: Text(
                    o.isAvailable
                        ? l10n.modifierOptionAvailable
                        : l10n.modifierOptionSoldOut,
                  ),
                  value: o.isAvailable,
                  onChange: (v) {
                    o.isAvailable = v;
                    onChanged();
                  },
                ),
                FButton.icon(
                  key: ValueKey('modifier-option-remove-$index'),
                  size: .sm,
                  variant: .ghost,
                  semanticsLabel: l10n.modifierOptionRemove,
                  onPress: onRemove,
                  child: const Icon(TablerIcons.trash, size: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
