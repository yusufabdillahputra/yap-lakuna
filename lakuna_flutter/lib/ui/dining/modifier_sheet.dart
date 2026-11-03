import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../cashier/cashier_view_model.dart' show SaleOption;
import '../core/format.dart';
import '../master/modifier_groups_tab.dart'
    show modifierDeltaLabel, modifierRuleLabel;
import 'dining_view_model.dart' show BillItemInput;
import 'modifier_pick.dart';

/// Sheet 1.8 *Pilih modifier*: mengembalikan item untuk bill, atau `null`
/// bila dibatalkan. [note] = catatan yang sudah diketik di lembar menu.
Future<BillItemInput?> showModifierSheet(
  BuildContext context, {
  required SaleOption option,
  required List<ModifierGroupDetail> groups,
  String note = '',
}) => showFDialog<BillItemInput>(
  context: context,
  builder: (context, style, animation) => FDialog(
    animation: animation,
    constraints: const BoxConstraints(minWidth: 280, maxWidth: 520),
    builder: (context, style) =>
        _ModifierSheet(option: option, groups: groups, note: note),
  ),
);

(Color, Color) _amber(BuildContext context) =>
    context.theme.colors.brightness == Brightness.dark
    ? (const Color(0xFF461901), const Color(0xFFFFD230))
    : (const Color(0xFFFEF3C6), const Color(0xFF973C00));

class _ModifierSheet extends StatefulWidget {
  const _ModifierSheet({
    required this.option,
    required this.groups,
    required this.note,
  });

  final SaleOption option;
  final List<ModifierGroupDetail> groups;
  final String note;

  @override
  State<_ModifierSheet> createState() => _ModifierSheetState();
}

class _ModifierSheetState extends State<_ModifierSheet> {
  late final _pick = ModifierPick(
    widget.groups,
    basePrice: widget.option.price,
  );
  late var _note = widget.note;

  @override
  void dispose() {
    _pick.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_pick.valid) return;
    Navigator.of(context).pop(
      BillItemInput(
        widget.option,
        note: _note,
        quantity: Qty.units(_pick.quantity),
        modifierIds: _pick.ids,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final option = widget.option;
    final height = MediaQuery.sizeOf(context).height;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    return ListenableBuilder(
      listenable: _pick,
      builder: (context, _) {
        final pick = _pick;
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: (height * 0.85).clamp(320, 760),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              key: const ValueKey('modifier-sheet'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  option.product.name,
                  style: theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  [
                    if (option.label.isNotEmpty) option.label,
                    formatMoney(context, option.price),
                  ].join(' · '),
                  style: muted,
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 16,
                      children: [
                        for (final g in pick.groups)
                          _GroupSection(
                            key: ValueKey('modifier-sheet-group-${g.name}'),
                            group: g,
                            pick: pick,
                          ),
                        FTextField(
                          key: const ValueKey('modifier-sheet-note'),
                          label: Text(l10n.diningNote),
                          hint: l10n.modifierSheetNoteHint,
                          maxLength: FnbLimits.itemNote,
                          control: .managed(
                            initial: TextEditingValue(text: _note),
                            onChange: (v) => _note = v.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.modifierSheetQty,
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FButton.icon(
                      key: const ValueKey('modifier-sheet-less'),
                      size: .sm,
                      variant: .outline,
                      semanticsLabel: l10n.modifierSheetLess,
                      onPress: pick.quantity <= 1
                          ? null
                          : () => pick.setQuantity(pick.quantity - 1),
                      child: const Icon(TablerIcons.minus, size: 16),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${pick.quantity}',
                        key: const ValueKey('modifier-sheet-qty'),
                        textAlign: TextAlign.center,
                        style: theme.typography.body.md.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FButton.icon(
                      key: const ValueKey('modifier-sheet-more'),
                      size: .sm,
                      variant: .outline,
                      semanticsLabel: l10n.modifierSheetMore,
                      onPress: pick.quantity >= ModifierPick.maxQuantity
                          ? null
                          : () => pick.setQuantity(pick.quantity + 1),
                      child: const Icon(TablerIcons.plus, size: 16),
                    ),
                  ],
                ),
                if (pick.priceInvalid)
                  Text(
                    l10n.modifierSheetPriceInvalid,
                    key: const ValueKey('modifier-sheet-price-error'),
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
                      child: Flexible(child: Text(l10n.diningCancel)),
                    ),
                    FButton(
                      key: const ValueKey('modifier-sheet-add'),
                      mainAxisSize: .min,
                      onPress: pick.valid ? _submit : null,
                      child: Flexible(
                        child: Text(
                          l10n.modifierSheetAdd(
                            formatMoney(context, pick.total),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GroupSection extends StatelessWidget {
  const _GroupSection({super.key, required this.group, required this.pick});

  final ModifierGroupDetail group;
  final ModifierPick pick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final g = group;
    final (bg, fg) = g.isRequired
        ? _amber(context)
        : (theme.colors.secondary, theme.colors.secondaryForeground);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              g.name,
              style: theme.typography.body.md.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  modifierRuleLabel(l10n, g.group.minSelect, g.group.maxSelect),
                  style: theme.typography.body.xs.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final o in g.options)
              _OptionChip(
                key: ValueKey('modifier-sheet-option-${o.name}'),
                option: o,
                selected: pick.isSelected(g, o),
                enabled: pick.canSelect(g, o),
                single: g.group.maxSelect == 1,
                onTap: () => pick.toggle(g, o),
              ),
          ],
        ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    super.key,
    required this.option,
    required this.selected,
    required this.enabled,
    required this.single,
    required this.onTap,
  });

  final ModifierOption option;
  final bool selected;
  final bool enabled;

  /// Pilihan tunggal (radio) atau ganda (centang).
  final bool single;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final o = option;
    final soldOut = !o.isAvailable;
    final fg = selected
        ? theme.colors.primaryForeground
        : enabled
        ? theme.colors.foreground
        : theme.colors.mutedForeground;
    final delta = modifierDeltaLabel(context, Money(o.priceDelta));
    final icon = single
        ? (selected ? TablerIcons.circleDot : TablerIcons.circle)
        : (selected ? TablerIcons.squareCheck : TablerIcons.square);
    return FTappable(
      onPress: enabled ? onTap : null,
      selected: selected,
      semanticsLabel: [
        o.name,
        delta,
        if (soldOut) l10n.modifierOptionSoldOut,
      ].where((s) => s.isNotEmpty).join(' '),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? theme.colors.primary : theme.colors.card,
          border: Border.all(
            color: selected ? theme.colors.primary : theme.colors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Icon(icon, size: 16, color: fg),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: o.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          decoration: soldOut
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (delta.isNotEmpty)
                        TextSpan(
                          text: '  $delta',
                          style: theme.typography.body.xs.copyWith(color: fg),
                        ),
                      if (soldOut)
                        TextSpan(
                          text: '  ${l10n.modifierOptionSoldOut}',
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.destructive,
                          ),
                        ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm.copyWith(color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
