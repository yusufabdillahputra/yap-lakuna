import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/confirm_discard.dart';
import '../products/product_widgets.dart';
import 'shift_labels.dart';
import 'shifts_view_model.dart';

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

/// Tab Master data › Shift (F1-03g, izin `settings:manage`).
class ShiftsTab extends StatelessWidget {
  const ShiftsTab({super.key, required this.viewModel});

  final ShiftsViewModel viewModel;

  Future<void> _edit(BuildContext context, {ShiftRow? row}) {
    // Dikosongkan sebelum dialog dibangun agar tidak memberi tahu
    // pendengar saat framework sedang membangun.
    viewModel.save.clearResult();
    return showFDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (context, style, animation) => TapOutsideToPop(
        child: FDialog(
          animation: animation,
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
          builder: (context, style) =>
              _ShiftDialog(viewModel: viewModel, row: row),
        ),
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
        title: l10n.masterTabShifts,
        trailing: FButton(
          key: const ValueKey('shifts-new'),
          size: .sm,
          mainAxisSize: .min,
          onPress: () => _edit(context),
          prefix: const Icon(TablerIcons.plus),
          child: Text(l10n.shiftsNew),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text(l10n.shiftsHint, style: _muted(context)),
            if (vm.load.error)
              LoadFailedAlert(
                message: l10n.shiftsLoadFailed,
                onRetry: vm.load.execute,
              )
            else if (vm.rows.isEmpty)
              Text(
                l10n.shiftsEmpty,
                key: const ValueKey('shifts-empty'),
                style: _muted(context),
              ),
            for (final r in vm.rows)
              DecoratedBox(
                key: ValueKey('shift-${r.shift.id.uuid}'),
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
                                  r.shift.name,
                                  style: theme.typography.body.sm.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  l10n.shiftsRowSub(
                                    shiftRange(r.shift),
                                    r.usage,
                                  ),
                                  key: ValueKey('shift-sub-${r.shift.id.uuid}'),
                                  style: _muted(context),
                                ),
                              ],
                            ),
                          ),
                          FButton.icon(
                            key: ValueKey('shift-edit-${r.shift.id.uuid}'),
                            variant: .ghost,
                            onPress: () => _edit(context, row: r),
                            child: const Icon(TablerIcons.pencil),
                          ),
                          FButton.icon(
                            key: ValueKey('shift-delete-${r.shift.id.uuid}'),
                            variant: .ghost,
                            onPress: vm.delete.running
                                ? null
                                : () => vm.delete.execute(r.shift.id),
                            child: Icon(
                              TablerIcons.trash,
                              color: theme.colors.destructive,
                            ),
                          ),
                        ],
                      ),
                      if (vm.deleteFailedId == r.shift.id)
                        if (vm.delete.result case Error(:final error))
                          Text(
                            shiftErrorMessage(l10n, error),
                            key: const ValueKey('shift-delete-error'),
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

class _ShiftDialog extends StatefulWidget {
  const _ShiftDialog({required this.viewModel, this.row});

  final ShiftsViewModel viewModel;
  final ShiftRow? row;

  @override
  State<_ShiftDialog> createState() => _ShiftDialogState();
}

class _ShiftDialogState extends State<_ShiftDialog> {
  late var _name = widget.row?.shift.name ?? '';
  late var _start = switch (widget.row) {
    final r? => formatShiftTime(r.shift.startMinute),
    null => '',
  };
  late var _end = switch (widget.row) {
    final r? => formatShiftTime(r.shift.endMinute),
    null => '',
  };
  var _submitted = false;

  /// Isian saat dialog dibuka (tanya sebelum keluar).
  late final ({String name, String start, String end}) _initial;

  ({String name, String start, String end}) get _current =>
      (name: _name.trim(), start: _start.trim(), end: _end.trim());

  bool get _dirty => _current != _initial;

  Set<ShiftIssue> get _issues => validateShift(
    name: _name,
    start: parseShiftTime(_start),
    end: parseShiftTime(_end),
  );

  @override
  void initState() {
    super.initState();
    _initial = _current;
  }

  /// `true` bila tersimpan (dialog tertutup).
  Future<bool> _save() async {
    setState(() => _submitted = true);
    if (_issues.isNotEmpty) return false;
    await widget.viewModel.save.execute((
      id: widget.row?.shift.id,
      name: _name,
      startMinute: parseShiftTime(_start)!,
      endMinute: parseShiftTime(_end)!,
    ));
    if (!mounted || widget.viewModel.save.result is! Ok) return false;
    Navigator.of(context).pop();
    return true;
  }

  Widget? _error(AppLocalizations l10n, Set<ShiftIssue> issues, ShiftIssue i) =>
      issues.contains(i) ? Text(shiftIssueMessage(l10n, i)) : null;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = widget.viewModel;
      final issues = _submitted ? _issues : const <ShiftIssue>{};
      final start = parseShiftTime(_start);
      final end = parseShiftTime(_end);
      final overnight = start != null && end != null && end < start;
      Widget time(
        String key,
        String label,
        String text,
        ShiftIssue issue,
        ValueChanged<String> onChange,
      ) => FTextField(
        key: ValueKey(key),
        label: Text(label),
        hint: l10n.shiftsTimeHint,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.:]')),
          LengthLimitingTextInputFormatter(5),
        ],
        error: _error(l10n, issues, issue),
        control: .managed(
          initial: TextEditingValue(text: text),
          onChange: (v) => setState(() => onChange(v.text)),
        ),
      );
      return DiscardChangesScope(
        dirty: _dirty,
        busy: vm.save.running,
        body: l10n.shiftDiscardBody,
        dialogKey: 'shift-discard',
        onSave: _save,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('shift-form'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                widget.row == null ? l10n.shiftsNewTitle : l10n.shiftsEditTitle,
                style: theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              FTextField(
                key: const ValueKey('shift-name'),
                label: Text(l10n.shiftsName),
                autofocus: true,
                error: _error(l10n, issues, ShiftIssue.name),
                control: .managed(
                  initial: TextEditingValue(text: _name),
                  onChange: (v) => setState(() => _name = v.text),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Expanded(
                    child: time(
                      'shift-start',
                      l10n.shiftsStart,
                      _start,
                      ShiftIssue.start,
                      (v) => _start = v,
                    ),
                  ),
                  Expanded(
                    child: time(
                      'shift-end',
                      l10n.shiftsEnd,
                      _end,
                      issues.contains(ShiftIssue.end)
                          ? ShiftIssue.end
                          : ShiftIssue.sameTime,
                      (v) => _end = v,
                    ),
                  ),
                ],
              ),
              if (overnight)
                Text(
                  l10n.shiftsOvernight(shiftRangeLabel(start, end)),
                  key: const ValueKey('shift-overnight'),
                  style: _muted(context),
                ),
              if (vm.save.result case Error(:final error))
                Text(
                  shiftErrorMessage(l10n, error),
                  key: const ValueKey('shift-error'),
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
                    key: const ValueKey('shift-cancel'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: () => Navigator.of(context).maybePop(),
                    child: Text(l10n.customerCancel),
                  ),
                  FButton(
                    key: const ValueKey('shift-save'),
                    mainAxisSize: .min,
                    onPress: vm.save.running ? null : _save,
                    child: Text(l10n.customerSave),
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
