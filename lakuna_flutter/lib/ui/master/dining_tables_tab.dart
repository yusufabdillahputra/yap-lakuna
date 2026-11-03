import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../products/product_widgets.dart';
import 'dining_setup_view_model.dart';

/// Pesan galat aksi Meja & area.
String diningSetupErrorMessage(
  AppLocalizations l10n,
  Exception error, {
  List<String> names = const [],
  int nameMax = FnbLimits.tableName,
}) => switch (error) {
  DiningNameInvalid(error: DiningNameError.empty) =>
    l10n.diningSetupErrNameEmpty,
  DiningNameInvalid(error: DiningNameError.tooLong) =>
    l10n.diningSetupErrNameTooLong(nameMax),
  DiningNameInvalid(error: DiningNameError.duplicate, :final index)
      when index < names.length =>
    l10n.diningSetupErrNameDuplicateAt(names[index]),
  DiningNameInvalid() => l10n.diningSetupErrNameDuplicate,
  DiningSeatsInvalid() => l10n.diningSetupErrSeats,
  DiningRangeInvalid() => l10n.diningSetupRangeInvalid,
  DiningInUse(openBill: true) => l10n.diningSetupErrTableBusy,
  DiningInUse(:final tables) => l10n.diningSetupErrAreaInUse(tables),
  _ => l10n.diningSetupErrGeneric,
};

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

/// Tab Master data › Meja & area (F1-10, izin `settings:manage`).
class DiningTablesTab extends StatefulWidget {
  const DiningTablesTab({super.key, required this.viewModel});

  final DiningSetupViewModel viewModel;

  @override
  State<DiningTablesTab> createState() => _DiningTablesTabState();
}

class _DiningTablesTabState extends State<DiningTablesTab> {
  /// Nama dari *Tambah beberapa* terakhir, untuk pesan nama kembar.
  List<String> _lastNames = const [];

  /// Batas nama aksi terakhir (area 40, meja 20).
  int _nameMax = FnbLimits.tableName;

  DiningSetupViewModel get _vm => widget.viewModel;

  Future<void> _areaDialog({DiningArea? area}) async {
    final name = await _showDialog<String>(
      context,
      (context) => _AreaDialog(area: area),
    );
    if (name == null) return;
    _lastNames = const [];
    _nameMax = FnbLimits.areaName;
    if (area == null) {
      await _vm.addArea.execute(name);
    } else {
      await _vm.renameArea.execute((area.id, name));
    }
  }

  Future<void> _tableDialog({DiningTable? table}) async {
    final draft = await _showDialog<DiningTableDraft>(
      context,
      (context) => _TableDialog(table: table, areas: _vm.areas),
    );
    if (draft == null) return;
    _lastNames = const [];
    _nameMax = FnbLimits.tableName;
    await _vm.saveTable.execute((table?.id, draft));
  }

  Future<void> _rangeDialog() async {
    final range = await _showDialog<TableRange>(
      context,
      (context) => _RangeDialog(areas: _vm.areas),
    );
    if (range == null) return;
    _nameMax = FnbLimits.tableName;
    _lastNames =
        DiningSetupViewModel.rangePreview(range.prefix, range.from, range.to) ??
        const [];
    await _vm.addRange.execute(range);
  }

  Future<bool> _confirm(String name) async {
    final ok = await _showDialog<bool>(context, (context) {
      final l10n = AppLocalizations.of(context);
      return _frame(
        context,
        key: const ValueKey('dining-setup-confirm'),
        title: l10n.diningSetupDeleteTitle(name),
        body: l10n.diningSetupDeleteBody,
        children: const [],
        actions: [
          FButton(
            variant: .outline,
            mainAxisSize: .min,
            onPress: () => Navigator.of(context).pop(false),
            child: Flexible(child: Text(l10n.diningSetupCancel)),
          ),
          FButton(
            key: const ValueKey('dining-setup-confirm-delete'),
            variant: .destructive,
            mainAxisSize: .min,
            onPress: () => Navigator.of(context).pop(true),
            child: Flexible(child: Text(l10n.diningSetupDelete)),
          ),
        ],
      );
    });
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = _vm;
      if (!vm.loaded) {
        if (vm.load.error) {
          return LoadFailedAlert(
            key: const ValueKey('dining-setup-load-error'),
            message: l10n.diningSetupLoadFailed,
            onRetry: vm.load.execute,
          );
        }
        return const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: FCircularProgress()),
        );
      }
      final busy = vm.busy;
      final error = vm.error;

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

      Widget row({
        required String key,
        required String title,
        required String subtitle,
        required List<Widget> actions,
      }) => Padding(
        key: ValueKey(key),
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
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(subtitle, style: _muted(context)),
                ],
              ),
            ),
            Wrap(children: actions),
          ],
        ),
      );

      final areas = vm.areas;
      final tables = vm.tables;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          Text(l10n.diningSetupHint, style: _muted(context)),
          if (error != null)
            FAlert(
              key: const ValueKey('dining-setup-error'),
              variant: .destructive,
              title: Text(
                diningSetupErrorMessage(
                  l10n,
                  error,
                  names: _lastNames,
                  nameMax: _nameMax,
                ),
              ),
            ),
          SectionCard(
            title: l10n.diningSetupAreas,
            trailing: FButton(
              key: const ValueKey('dining-setup-area-add'),
              size: .sm,
              mainAxisSize: .min,
              prefix: const Icon(TablerIcons.plus, size: 16),
              onPress: busy ? null : () => _areaDialog(),
              child: Flexible(child: Text(l10n.diningSetupAreaAdd)),
            ),
            child: areas.isEmpty
                ? Text(l10n.diningSetupAreasEmpty, style: _muted(context))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, a) in areas.indexed)
                        row(
                          key: 'dining-setup-area-${a.name}',
                          title: a.name,
                          subtitle: l10n.diningSetupAreaTables(
                            tables.where((t) => t.diningAreaId == a.id).length,
                          ),
                          actions: [
                            iconButton(
                              'dining-setup-area-up-${a.name}',
                              TablerIcons.arrowUp,
                              l10n.diningSetupMoveUp,
                              i == 0
                                  ? null
                                  : () => vm.moveArea.execute((a.id, -1)),
                            ),
                            iconButton(
                              'dining-setup-area-down-${a.name}',
                              TablerIcons.arrowDown,
                              l10n.diningSetupMoveDown,
                              i == areas.length - 1
                                  ? null
                                  : () => vm.moveArea.execute((a.id, 1)),
                            ),
                            iconButton(
                              'dining-setup-area-edit-${a.name}',
                              TablerIcons.pencil,
                              l10n.diningSetupEdit,
                              () => _areaDialog(area: a),
                            ),
                            iconButton(
                              'dining-setup-area-delete-${a.name}',
                              TablerIcons.trash,
                              l10n.diningSetupDelete,
                              () async {
                                if (await _confirm(a.name)) {
                                  _lastNames = const [];
                                  await vm.deleteArea.execute(a.id);
                                }
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
          ),
          SectionCard(
            title: l10n.diningSetupTables,
            // Tombol di bawah judul agar muat di layar 360 px.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FButton(
                        key: const ValueKey('dining-setup-table-range'),
                        size: .sm,
                        mainAxisSize: .min,
                        variant: .outline,
                        onPress: busy ? null : _rangeDialog,
                        child: Flexible(
                          child: Text(l10n.diningSetupTableRange),
                        ),
                      ),
                      FButton(
                        key: const ValueKey('dining-setup-table-add'),
                        size: .sm,
                        mainAxisSize: .min,
                        prefix: const Icon(TablerIcons.plus, size: 16),
                        onPress: busy ? null : () => _tableDialog(),
                        child: Flexible(child: Text(l10n.diningSetupTableAdd)),
                      ),
                    ],
                  ),
                ),
                tables.isEmpty
                    ? Text(l10n.diningSetupTablesEmpty, style: _muted(context))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final (i, t) in tables.indexed)
                            row(
                              key: 'dining-setup-table-${t.name}',
                              title: t.name,
                              subtitle: [
                                vm.areaName(t.diningAreaId) ??
                                    l10n.diningSetupNoArea,
                                l10n.diningSeats(t.seats),
                              ].join(' · '),
                              actions: [
                                iconButton(
                                  'dining-setup-table-up-${t.name}',
                                  TablerIcons.arrowUp,
                                  l10n.diningSetupMoveUp,
                                  i == 0
                                      ? null
                                      : () => vm.moveTable.execute((t.id, -1)),
                                ),
                                iconButton(
                                  'dining-setup-table-down-${t.name}',
                                  TablerIcons.arrowDown,
                                  l10n.diningSetupMoveDown,
                                  i == tables.length - 1
                                      ? null
                                      : () => vm.moveTable.execute((t.id, 1)),
                                ),
                                iconButton(
                                  'dining-setup-table-edit-${t.name}',
                                  TablerIcons.pencil,
                                  l10n.diningSetupEdit,
                                  () => _tableDialog(table: t),
                                ),
                                iconButton(
                                  'dining-setup-table-delete-${t.name}',
                                  TablerIcons.trash,
                                  l10n.diningSetupDelete,
                                  () async {
                                    if (await _confirm(t.name)) {
                                      _lastNames = const [];
                                      await vm.deleteTable.execute(t.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

// --- Dialog -------------------------------------------------------------------

Future<T?> _showDialog<T>(BuildContext context, WidgetBuilder builder) =>
    showFDialog<T>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 440),
        builder: (context, style) => builder(context),
      ),
    );

Widget _frame(
  BuildContext context, {
  required String title,
  String? body,
  required List<Widget> children,
  required List<Widget> actions,
  Key? key,
}) {
  final theme = context.theme;
  return Padding(
    padding: const EdgeInsets.all(20),
    child: SingleChildScrollView(
      child: Column(
        key: key,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            title,
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (body != null)
            Text(
              body,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ...children,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: actions,
          ),
        ],
      ),
    ),
  );
}

List<Widget> _saveCancel(
  BuildContext context, {
  required String saveKey,
  required VoidCallback onSave,
}) {
  final l10n = AppLocalizations.of(context);
  return [
    FButton(
      variant: .outline,
      mainAxisSize: .min,
      onPress: () => Navigator.of(context).pop(),
      child: Flexible(child: Text(l10n.diningSetupCancel)),
    ),
    FButton(
      key: ValueKey(saveKey),
      mainAxisSize: .min,
      onPress: onSave,
      child: Flexible(child: Text(l10n.diningSetupSave)),
    ),
  ];
}

/// Pilihan area untuk FSelect: label unik → id ('' = tanpa area).
Map<String, String> _areaItems(String none, List<DiningArea> areas) {
  final items = <String, String>{none: ''};
  for (final a in areas) {
    var label = a.name;
    for (var n = 2; items.containsKey(label); n++) {
      label = '${a.name} ($n)';
    }
    items[label] = a.id.uuid;
  }
  return items;
}

UuidValue? _areaId(String? v) =>
    v == null || v.isEmpty ? null : UuidValue.fromString(v);

final _digits = [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(2),
];

class _AreaDialog extends StatefulWidget {
  const _AreaDialog({this.area});

  final DiningArea? area;

  @override
  State<_AreaDialog> createState() => _AreaDialogState();
}

class _AreaDialogState extends State<_AreaDialog> {
  late var _name = widget.area?.name ?? '';
  var _empty = false;

  void _save() {
    if (_name.trim().isEmpty) {
      setState(() => _empty = true);
      return;
    }
    Navigator.of(context).pop(_name.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _frame(
      context,
      key: const ValueKey('dining-setup-area-dialog'),
      title: widget.area == null
          ? l10n.diningSetupNewArea
          : l10n.diningSetupRenameArea,
      children: [
        FTextField(
          key: const ValueKey('dining-setup-area-name'),
          label: Text(l10n.diningSetupName),
          autofocus: true,
          maxLength: FnbLimits.areaName,
          error: _empty ? Text(l10n.diningSetupErrNameEmpty) : null,
          control: .managed(
            initial: TextEditingValue(text: _name),
            onChange: (v) => _name = v.text,
          ),
          onSubmit: (_) => _save(),
        ),
      ],
      actions: _saveCancel(
        context,
        saveKey: 'dining-setup-area-save',
        onSave: _save,
      ),
    );
  }
}

class _TableDialog extends StatefulWidget {
  const _TableDialog({this.table, required this.areas});

  final DiningTable? table;
  final List<DiningArea> areas;

  @override
  State<_TableDialog> createState() => _TableDialogState();
}

class _TableDialogState extends State<_TableDialog> {
  late var _name = widget.table?.name ?? '';
  late var _seats = '${widget.table?.seats ?? 4}';
  late UuidValue? _area = widget.table?.diningAreaId;
  var _nameEmpty = false;
  var _seatsBad = false;

  void _save() {
    final seats = int.tryParse(_seats) ?? 0;
    setState(() {
      _nameEmpty = _name.trim().isEmpty;
      _seatsBad = seats < 1 || seats > FnbLimits.seatsMax;
    });
    if (_nameEmpty || _seatsBad) return;
    Navigator.of(context).pop(
      DiningTableDraft(name: _name.trim(), areaId: _area, seats: seats),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _frame(
      context,
      key: const ValueKey('dining-setup-table-dialog'),
      title: widget.table == null
          ? l10n.diningSetupNewTable
          : l10n.diningSetupEditTable,
      children: [
        FTextField(
          key: const ValueKey('dining-setup-table-name'),
          label: Text(l10n.diningSetupName),
          autofocus: true,
          maxLength: FnbLimits.tableName,
          error: _nameEmpty ? Text(l10n.diningSetupErrNameEmpty) : null,
          control: .managed(
            initial: TextEditingValue(text: _name),
            onChange: (v) => _name = v.text,
          ),
        ),
        if (widget.areas.isNotEmpty)
          FSelect<String>(
            key: const ValueKey('dining-setup-table-area'),
            label: Text(l10n.diningSetupArea),
            hint: l10n.diningSetupNoArea,
            items: _areaItems(l10n.diningSetupNoArea, widget.areas),
            control: .managed(
              initial: _area?.uuid ?? '',
              onChange: (v) => _area = _areaId(v),
            ),
          ),
        FTextField(
          key: const ValueKey('dining-setup-table-seats'),
          label: Text(l10n.diningSetupSeats),
          keyboardType: TextInputType.number,
          inputFormatters: _digits,
          error: _seatsBad ? Text(l10n.diningSetupErrSeats) : null,
          control: .managed(
            initial: TextEditingValue(text: _seats),
            onChange: (v) => _seats = v.text,
          ),
          onSubmit: (_) => _save(),
        ),
      ],
      actions: _saveCancel(
        context,
        saveKey: 'dining-setup-table-save',
        onSave: _save,
      ),
    );
  }
}

class _RangeDialog extends StatefulWidget {
  const _RangeDialog({required this.areas});

  final List<DiningArea> areas;

  @override
  State<_RangeDialog> createState() => _RangeDialogState();
}

class _RangeDialogState extends State<_RangeDialog> {
  var _prefix = 'M';
  var _from = '1';
  var _to = '12';
  var _seats = '4';
  UuidValue? _area;
  var _seatsBad = false;

  List<String>? get _names => DiningSetupViewModel.rangePreview(
    _prefix,
    int.tryParse(_from) ?? 0,
    int.tryParse(_to) ?? 0,
  );

  void _save() {
    final seats = int.tryParse(_seats) ?? 0;
    setState(() => _seatsBad = seats < 1 || seats > FnbLimits.seatsMax);
    if (_seatsBad || _names == null) return;
    Navigator.of(context).pop(
      TableRange(
        prefix: _prefix,
        from: int.parse(_from),
        to: int.parse(_to),
        seats: seats,
        areaId: _area,
      ),
    );
  }

  Widget _field(
    String key,
    String label,
    String initial,
    ValueChanged<String> onChange, {
    bool digits = true,
    Widget? error,
  }) => FTextField(
    key: ValueKey(key),
    label: Text(label),
    keyboardType: digits ? TextInputType.number : null,
    inputFormatters: digits ? _digits : null,
    maxLength: digits ? null : 10,
    error: error,
    control: .managed(
      initial: TextEditingValue(text: initial),
      onChange: (v) => setState(() => onChange(v.text)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final names = _names;
    final preview = names == null
        ? l10n.diningSetupRangeInvalid
        : l10n.diningSetupPreview(
            names.length <= 4
                ? names.join(', ')
                : '${names.first}, ${names[1]} … ${names.last} (${names.length})',
          );
    return _frame(
      context,
      key: const ValueKey('dining-setup-range-dialog'),
      title: l10n.diningSetupTableRange,
      children: [
        _field(
          'dining-setup-range-prefix',
          l10n.diningSetupPrefix,
          _prefix,
          (v) => _prefix = v,
          digits: false,
        ),
        Row(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _field(
                'dining-setup-range-from',
                l10n.diningSetupFrom,
                _from,
                (v) => _from = v,
              ),
            ),
            Expanded(
              child: _field(
                'dining-setup-range-to',
                l10n.diningSetupTo,
                _to,
                (v) => _to = v,
              ),
            ),
          ],
        ),
        _field(
          'dining-setup-range-seats',
          l10n.diningSetupSeats,
          _seats,
          (v) => _seats = v,
          error: _seatsBad ? Text(l10n.diningSetupErrSeats) : null,
        ),
        if (widget.areas.isNotEmpty)
          FSelect<String>(
            key: const ValueKey('dining-setup-range-area'),
            label: Text(l10n.diningSetupArea),
            hint: l10n.diningSetupNoArea,
            items: _areaItems(l10n.diningSetupNoArea, widget.areas),
            control: .managed(
              initial: '',
              onChange: (v) => _area = _areaId(v),
            ),
          ),
        Text(
          preview,
          key: const ValueKey('dining-setup-range-preview'),
          style: context.theme.typography.body.sm.copyWith(
            color: names == null
                ? context.theme.colors.destructive
                : context.theme.colors.mutedForeground,
          ),
        ),
      ],
      actions: _saveCancel(
        context,
        saveKey: 'dining-setup-range-save',
        onSave: _save,
      ),
    );
  }
}
