import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../core/confirm_discard.dart';
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
  const DiningTablesTab({super.key, required this.viewModel, this.onArrange});

  final DiningSetupViewModel viewModel;

  /// *Atur denah* area (1.7d).
  final void Function(UuidValue area)? onArrange;

  @override
  State<DiningTablesTab> createState() => _DiningTablesTabState();
}

class _DiningTablesTabState extends State<DiningTablesTab> {
  DiningSetupViewModel get _vm => widget.viewModel;

  /// Menjalankan simpan dari dalam dialog (F1-10o): `null` bila berhasil,
  /// selain itu galatnya, yang diubah menjadi pesan oleh dialog sendiri
  /// (tab ini bisa dibangun ulang selama dialog terbuka, mis. saat jendela
  /// melewati 900 px). Galat tidak ikut tampil di tab.
  Future<Exception?> _saveFromDialog<A>(
    Command1<void, A> command,
    A argument,
  ) async {
    await command.execute(argument);
    final result = command.result;
    _vm.clearError();
    return switch (result) {
      Ok() => null,
      Error(:final error) => error,
      // Perintah yang sama masih berjalan: anggap gagal, dialog tetap buka.
      null => _SaveNotRun(),
    };
  }

  Future<void> _areaDialog({DiningArea? area}) => _showDialog<void>(
    context,
    (context) => _AreaDialog(
      area: area,
      onSave: (name) => area == null
          ? _saveFromDialog(_vm.addArea, name)
          : _saveFromDialog(_vm.renameArea, (area.id, name)),
    ),
  );

  Future<void> _tableDialog({DiningTable? table}) => _showDialog<void>(
    context,
    (context) => _TableDialog(
      table: table,
      areas: _vm.areas,
      onSave: (draft) => _saveFromDialog(_vm.saveTable, (table?.id, draft)),
    ),
  );

  Future<void> _rangeDialog() => _showDialog<void>(
    context,
    (context) => _RangeDialog(
      areas: _vm.areas,
      onSave: (range) => _saveFromDialog(_vm.addRange, range),
    ),
  );

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
                // Galat simpan tampil di dialog (F1-10o); di sini hanya
                // galat hapus / urut.
                diningSetupErrorMessage(l10n, error),
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
                          subtitle: [
                            l10n.diningSetupAreaTables(
                              tables
                                  .where((t) => t.diningAreaId == a.id)
                                  .length,
                            ),
                            if (a.layoutMode == DiningLayoutMode.floor)
                              l10n.diningLayoutFloor,
                          ].join(' · '),
                          actions: [
                            if (widget.onArrange case final arrange?)
                              iconButton(
                                'dining-setup-area-floor-${a.name}',
                                TablerIcons.layoutBoardSplit,
                                l10n.diningArrange,
                                () => arrange(a.id),
                              ),
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
                                if (t.canMerge) l10n.diningSetupCanMerge,
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
      // Menutupi menu samping; ketukan di luar dan Esc lewat `maybePop`
      // agar dialog yang berubah bertanya dulu (F1-10n).
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (context, style, animation) => TapOutsideToPop(
        child: FDialog(
          animation: animation,
          constraints: const BoxConstraints(minWidth: 280, maxWidth: 440),
          builder: (context, style) => builder(context),
        ),
      ),
    );

Widget _frame(
  BuildContext context, {
  required String title,
  String? body,
  required List<Widget> children,
  required List<Widget> actions,
  Key? key,
  String? error,
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
          if (error != null)
            FAlert(
              key: const ValueKey('dining-setup-dialog-error'),
              variant: .destructive,
              title: Text(error),
            ),
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
  required String cancelKey,
  required VoidCallback? onSave,
}) {
  final l10n = AppLocalizations.of(context);
  return [
    FButton(
      key: ValueKey(cancelKey),
      variant: .outline,
      mainAxisSize: .min,
      // Ikut ditanyakan bila isian berubah (F1-10n).
      onPress: () => Navigator.of(context).maybePop(),
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

/// Simpan dari dalam dialog (F1-10o): `null` bila berhasil, selain itu
/// galat penyimpanan.
typedef _DialogSave<T> = Future<Exception?> Function(T value);

/// Simpan yang tidak berjalan (perintah yang sama masih berjalan) atau
/// gagal tanpa `Exception`; tampil sebagai *Aksi gagal. Coba lagi.*
class _SaveNotRun implements Exception {}

/// Keadaan simpan bersama dialog area, meja, dan rentang (F1-10o): simpan
/// berjalan menahan dialog, galat simpan tampil di dialog dan hilang saat
/// isian diubah.
mixin _DialogSaving<W extends StatefulWidget> on State<W> {
  var saving = false;
  String? saveError;

  /// Mengubah isian sekaligus menghapus galat simpan.
  void edit(VoidCallback change) => setState(() {
    change();
    saveError = null;
  });

  Future<void> runSave<T>(
    _DialogSave<T> onSave,
    T value, {
    List<String> names = const [],
    int nameMax = FnbLimits.tableName,
  }) async {
    setState(() {
      saving = true;
      saveError = null;
    });
    Exception? error;
    try {
      error = await onSave(value);
    } on Object {
      // Galat tak terduga (mis. `StateError`) tidak boleh mengunci dialog.
      error = _SaveNotRun();
    }
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    final message = diningSetupErrorMessage(
      AppLocalizations.of(context),
      error,
      names: names,
      nameMax: nameMax,
    );
    setState(() {
      saving = false;
      saveError = message;
    });
  }
}

class _AreaDialog extends StatefulWidget {
  const _AreaDialog({this.area, required this.onSave});

  final DiningArea? area;
  final _DialogSave<String> onSave;

  @override
  State<_AreaDialog> createState() => _AreaDialogState();
}

class _AreaDialogState extends State<_AreaDialog>
    with _DialogSaving<_AreaDialog> {
  late var _name = widget.area?.name ?? '';
  var _empty = false;

  /// Nama saat dialog dibuka (F1-10n).
  late final _initial = _name.trim();

  void _save() {
    if (saving) return;
    if (_name.trim().isEmpty) {
      setState(() => _empty = true);
      return;
    }
    runSave(widget.onSave, _name.trim(), nameMax: FnbLimits.areaName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DiscardChangesScope(
      dirty: _name.trim() != _initial,
      busy: saving,
      body: l10n.diningAreaDiscardBody,
      dialogKey: 'dining-area-discard',
      child: _frame(
        context,
        key: const ValueKey('dining-setup-area-dialog'),
        title: widget.area == null
            ? l10n.diningSetupNewArea
            : l10n.diningSetupRenameArea,
        error: saveError,
        children: [
          FTextField(
            key: const ValueKey('dining-setup-area-name'),
            label: Text(l10n.diningSetupName),
            autofocus: true,
            maxLength: FnbLimits.areaName,
            error: _empty ? Text(l10n.diningSetupErrNameEmpty) : null,
            control: .managed(
              initial: TextEditingValue(text: _name),
              onChange: (v) {
                // Geser kursor saja bukan perubahan isian.
                if (v.text != _name) edit(() => _name = v.text);
              },
            ),
            onSubmit: (_) => _save(),
          ),
        ],
        actions: _saveCancel(
          context,
          saveKey: 'dining-setup-area-save',
          cancelKey: 'dining-setup-area-cancel',
          onSave: saving ? null : _save,
        ),
      ),
    );
  }
}

class _TableDialog extends StatefulWidget {
  const _TableDialog({
    this.table,
    required this.areas,
    required this.onSave,
  });

  final DiningTable? table;
  final List<DiningArea> areas;
  final _DialogSave<DiningTableDraft> onSave;

  @override
  State<_TableDialog> createState() => _TableDialogState();
}

class _TableDialogState extends State<_TableDialog>
    with _DialogSaving<_TableDialog> {
  late var _name = widget.table?.name ?? '';
  late var _seats = '${widget.table?.seats ?? 4}';
  late UuidValue? _area = widget.table?.diningAreaId;
  late var _canMerge = widget.table?.canMerge ?? false;
  var _nameEmpty = false;
  var _seatsBad = false;

  /// Isian saat dialog dibuka (F1-10n).
  late final _initial = _signature;

  /// Isian yang menentukan apakah dialog berubah, dibandingkan seperti saat
  /// disimpan (nama tanpa spasi tepi, kursi sebagai angka).
  (String, UuidValue?, int, bool) get _signature =>
      (_name.trim(), _area, int.tryParse(_seats) ?? 0, _canMerge);

  void _save() {
    if (saving) return;
    final seats = int.tryParse(_seats) ?? 0;
    setState(() {
      _nameEmpty = _name.trim().isEmpty;
      _seatsBad = seats < 1 || seats > FnbLimits.seatsMax;
    });
    if (_nameEmpty || _seatsBad) return;
    runSave(
      widget.onSave,
      DiningTableDraft(
        name: _name.trim(),
        areaId: _area,
        seats: seats,
        canMerge: _canMerge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DiscardChangesScope(
      dirty: _signature != _initial,
      busy: saving,
      body: l10n.diningTableDiscardBody,
      dialogKey: 'dining-table-discard',
      child: _frame(
        context,
        key: const ValueKey('dining-setup-table-dialog'),
        title: widget.table == null
            ? l10n.diningSetupNewTable
            : l10n.diningSetupEditTable,
        error: saveError,
        children: [
          FTextField(
            key: const ValueKey('dining-setup-table-name'),
            label: Text(l10n.diningSetupName),
            autofocus: true,
            maxLength: FnbLimits.tableName,
            error: _nameEmpty ? Text(l10n.diningSetupErrNameEmpty) : null,
            control: .managed(
              initial: TextEditingValue(text: _name),
              onChange: (v) {
                if (v.text != _name) edit(() => _name = v.text);
              },
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
                onChange: (v) => edit(() => _area = _areaId(v)),
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
              onChange: (v) {
                if (v.text != _seats) edit(() => _seats = v.text);
              },
            ),
            onSubmit: (_) => _save(),
          ),
          FSwitch(
            key: const ValueKey('dining-setup-table-merge'),
            label: Text(l10n.floorCanMerge),
            description: Text(l10n.diningSetupCanMergeHint),
            value: _canMerge,
            onChange: (v) => edit(() => _canMerge = v),
          ),
        ],
        actions: _saveCancel(
          context,
          saveKey: 'dining-setup-table-save',
          cancelKey: 'dining-setup-table-cancel',
          onSave: saving ? null : _save,
        ),
      ),
    );
  }
}

class _RangeDialog extends StatefulWidget {
  const _RangeDialog({required this.areas, required this.onSave});

  final List<DiningArea> areas;
  final _DialogSave<TableRange> onSave;

  @override
  State<_RangeDialog> createState() => _RangeDialogState();
}

class _RangeDialogState extends State<_RangeDialog>
    with _DialogSaving<_RangeDialog> {
  var _prefix = 'M';
  var _from = '1';
  var _to = '12';
  var _seats = '4';
  UuidValue? _area;
  var _seatsBad = false;

  /// Isian saat dialog dibuka (F1-10n).
  late final _initial = _signature;

  /// Isian yang menentukan apakah dialog berubah; angka dibandingkan sebagai
  /// angka ("04" = 4).
  (String, int?, int?, int?, UuidValue?) get _signature => (
    _prefix.trim(),
    int.tryParse(_from),
    int.tryParse(_to),
    int.tryParse(_seats),
    _area,
  );

  List<String>? get _names => DiningSetupViewModel.rangePreview(
    _prefix,
    int.tryParse(_from) ?? 0,
    int.tryParse(_to) ?? 0,
  );

  void _save() {
    if (saving) return;
    final seats = int.tryParse(_seats) ?? 0;
    setState(() => _seatsBad = seats < 1 || seats > FnbLimits.seatsMax);
    if (_seatsBad || _names == null) return;
    runSave(
      widget.onSave,
      TableRange(
        prefix: _prefix,
        from: int.parse(_from),
        to: int.parse(_to),
        seats: seats,
        areaId: _area,
      ),
      names: _names!,
    );
  }

  Widget _field(
    String key,
    String label,
    ValueGetter<String> value,
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
      initial: TextEditingValue(text: value()),
      onChange: (v) {
        // Geser kursor saja bukan perubahan isian.
        if (v.text != value()) edit(() => onChange(v.text));
      },
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
    return DiscardChangesScope(
      dirty: _signature != _initial,
      busy: saving,
      body: l10n.diningRangeDiscardBody,
      dialogKey: 'dining-range-discard',
      child: _frame(
        context,
        key: const ValueKey('dining-setup-range-dialog'),
        title: l10n.diningSetupTableRange,
        error: saveError,
        children: [
          _field(
            'dining-setup-range-prefix',
            l10n.diningSetupPrefix,
            () => _prefix,
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
                  () => _from,
                  (v) => _from = v,
                ),
              ),
              Expanded(
                child: _field(
                  'dining-setup-range-to',
                  l10n.diningSetupTo,
                  () => _to,
                  (v) => _to = v,
                ),
              ),
            ],
          ),
          _field(
            'dining-setup-range-seats',
            l10n.diningSetupSeats,
            () => _seats,
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
                onChange: (v) => edit(() => _area = _areaId(v)),
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
          cancelKey: 'dining-setup-range-cancel',
          onSave: saving ? null : _save,
        ),
      ),
    );
  }
}
