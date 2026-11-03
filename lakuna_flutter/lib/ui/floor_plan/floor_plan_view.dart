import 'package:flutter/material.dart' show Material, Slider, SliderTheme;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/dining_admin_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../l10n/gen/app_localizations.dart';
import '../products/product_widgets.dart' show ChoicePill, PageHeader;
import '../master/dining_tables_tab.dart' show diningSetupErrorMessage;
import 'floor_canvas.dart';
import 'floor_plan_view_model.dart';

/// Pesan galat *Atur denah*.
String floorErrorMessage(AppLocalizations l10n, Exception error) =>
    switch (error) {
      FloorImageInvalid(error: FloorImageError.tooLarge) =>
        l10n.floorErrorImageTooLarge,
      FloorImageInvalid() => l10n.floorErrorImageFormat,
      FloorAreaInvalid(:final cause) => diningSetupErrorMessage(
        l10n,
        cause,
        nameMax: FnbLimits.areaName,
      ),
      DiningNameInvalid(error: DiningNameError.empty) =>
        l10n.floorErrorNameEmpty,
      DiningNameInvalid(error: DiningNameError.tooLong) =>
        l10n.floorErrorNameTooLong,
      DiningNameInvalid() => l10n.floorErrorNameDuplicate,
      FloorTableInvalid(error: FloorTableError.seats) => l10n.floorErrorSeats,
      FloorTableInvalid(error: FloorTableError.size) => l10n.floorErrorSize,
      FloorTableInvalid() => l10n.floorErrorPosition,
      DiningInUse() => l10n.floorErrorInUse,
      NotPermitted() => l10n.floorErrorPermission,
      _ => l10n.floorErrorGeneric,
    };

String floorShapeLabel(AppLocalizations l10n, TableShape shape) =>
    switch (shape) {
      TableShape.round => l10n.floorShapeRound,
      TableShape.square => l10n.floorShapeSquare,
      TableShape.long => l10n.floorShapeLong,
      TableShape.bar => l10n.floorShapeBar,
    };

/// Layar *Atur denah* (1.7d) dengan panel unggah (1.7c), rute
/// `/meja/denah?area=`. Memiliki [FloorPlanViewModel].
class FloorPlanScreen extends StatefulWidget {
  const FloorPlanScreen({
    super.key,
    required this.repository,
    required this.picker,
    required this.onBack,
    this.initialArea,
  });

  final DiningAdminRepository repository;
  final ImageFilePicker picker;
  final VoidCallback onBack;
  final UuidValue? initialArea;

  @override
  State<FloorPlanScreen> createState() => _FloorPlanScreenState();
}

class _FloorPlanScreenState extends State<FloorPlanScreen> {
  late final _viewModel = FloorPlanViewModel(
    repository: widget.repository,
    picker: widget.picker,
    initialArea: widget.initialArea,
  );
  final _canvas = FloorCanvasController(snap: true);

  @override
  void initState() {
    super.initState();
    _viewModel.load.execute();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _canvas.dispose();
    super.dispose();
  }

  Future<void> _back() async {
    if (_viewModel.dirty && !await confirmDiscard(context)) return;
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _back();
    },
    child: FloorPlanView(
      viewModel: _viewModel,
      canvas: _canvas,
      onBack: _back,
      canTakePhoto: widget.picker.canTakePhoto,
    ),
  );
}

/// *Buang perubahan?* — `true` bila pengguna memilih buang.
Future<bool> confirmDiscard(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final result = await showFDialog<bool>(
    context: context,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      builder: (context, style) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          key: const ValueKey('floor-discard'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              l10n.floorDiscardTitle,
              style: context.theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(l10n.floorDiscardBody),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                FButton(
                  key: const ValueKey('floor-discard-cancel'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(context).pop(false),
                  child: Text(l10n.floorDiscardKeep),
                ),
                FButton(
                  key: const ValueKey('floor-discard-confirm'),
                  variant: .destructive,
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(context).pop(true),
                  child: Text(l10n.floorDiscardConfirm),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

class FloorPlanView extends StatelessWidget {
  const FloorPlanView({
    super.key,
    required this.viewModel,
    required this.canvas,
    required this.onBack,
    this.canTakePhoto = false,
  });

  final FloorPlanViewModel viewModel;
  final FloorCanvasController canvas;
  final VoidCallback onBack;
  final bool canTakePhoto;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final vm = viewModel;
      if (!vm.loaded) {
        return Center(
          child: vm.load.error
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12,
                  children: [
                    Text(
                      vm.loadError is NotPermitted
                          ? l10n.floorErrorPermission
                          : l10n.floorLoadFailed,
                      key: const ValueKey('floor-load-error'),
                    ),
                    FButton(
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: onBack,
                      child: Text(l10n.floorBack),
                    ),
                  ],
                )
              : const FCircularProgress(),
        );
      }
      canvas.snap = vm.snap;
      return LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1100;
          final narrow = constraints.maxWidth < 600;
          final pad = narrow ? 16.0 : 24.0;
          final header = _Header(viewModel: vm, onBack: onBack);
          if (vm.area == null) {
            return ListView(
              padding: EdgeInsets.all(pad),
              children: [
                header,
                const SizedBox(height: 24),
                Text(
                  l10n.floorNoArea,
                  key: const ValueKey('floor-no-area'),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }
          final center = _Center(
            viewModel: vm,
            canvas: canvas,
            canTakePhoto: canTakePhoto,
            narrow: narrow,
          );
          final palette = _Palette(
            viewModel: vm,
            canvas: canvas,
            compact: !wide,
          );
          final side = _SidePanel(viewModel: vm);
          if (wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(pad, pad, pad, 12),
                  child: header,
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 250,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(pad, 0, 12, pad),
                          child: palette,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, pad),
                          child: center,
                        ),
                      ),
                      SizedBox(
                        width: 320,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(16, 0, pad, pad),
                          child: side,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return FloorScrollLock(
            builder: (context, physics) => SingleChildScrollView(
              physics: physics,
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  header,
                  SizedBox(
                    height: vm.showCanvas ? (narrow ? 460 : 520) : null,
                    child: center,
                  ),
                  palette,
                  side,
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.viewModel, required this.onBack});

  final FloorPlanViewModel viewModel;
  final VoidCallback onBack;

  Future<void> _switch(BuildContext context, UuidValue id) async {
    if (viewModel.dirty && !await confirmDiscard(context)) return;
    viewModel.selectArea(id);
  }

  Future<void> _addArea(BuildContext context) async {
    if (viewModel.dirty && !await confirmDiscard(context)) return;
    if (!context.mounted) return;
    final name = await showFDialog<String>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
        builder: (context, style) => const _AreaNameDialog(),
      ),
    );
    if (name != null) await viewModel.addArea.execute(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    return PageHeader(
      leading: FButton(
        key: const ValueKey('floor-back'),
        variant: .ghost,
        size: .sm,
        mainAxisSize: .min,
        onPress: onBack,
        prefix: const Icon(TablerIcons.arrowLeft, size: 16),
        child: Text(l10n.floorBack),
      ),
      title: l10n.floorTitle,
      subtitle: l10n.floorSubtitle,
      action: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final a in vm.areas)
            ChoicePill(
              key: ValueKey('floor-area-${a.name}'),
              label: a.name,
              selected: vm.area?.id == a.id,
              onTap: () => _switch(context, a.id),
            ),
          ChoicePill(
            key: const ValueKey('floor-area-add'),
            label: l10n.floorAddArea,
            selected: false,
            onTap: () => _addArea(context),
          ),
        ],
      ),
    );
  }
}

class _AreaNameDialog extends StatefulWidget {
  const _AreaNameDialog();

  @override
  State<_AreaNameDialog> createState() => _AreaNameDialogState();
}

class _AreaNameDialogState extends State<_AreaNameDialog> {
  var _name = '';

  void _save() {
    if (_name.trim().isEmpty) return;
    Navigator.of(context).pop(_name.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            l10n.floorAddAreaTitle,
            style: context.theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          FTextField(
            key: const ValueKey('floor-area-name'),
            label: Text(l10n.floorAreaName),
            maxLength: FnbLimits.areaName,
            autofocus: true,
            control: .managed(onChange: (v) => _name = v.text),
            onSubmit: (_) => _save(),
          ),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            children: [
              FButton(
                variant: .outline,
                mainAxisSize: .min,
                onPress: () => Navigator.of(context).pop(),
                child: Text(l10n.floorDiscardKeep),
              ),
              FButton(
                key: const ValueKey('floor-area-save'),
                mainAxisSize: .min,
                onPress: _save,
                child: Text(l10n.floorAddAreaSave),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _titledCard(
  BuildContext context, {
  Key? key,
  required String title,
  required Widget child,
}) => FCard(
  key: key,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          title,
          style: context.theme.typography.body.md.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        child,
      ],
    ),
  ),
);

// --- Tengah: toolbar + kanvas / unggah / info grid --------------------------

class _Center extends StatelessWidget {
  const _Center({
    required this.viewModel,
    required this.canvas,
    required this.canTakePhoto,
    required this.narrow,
  });

  final FloorPlanViewModel viewModel;
  final FloorCanvasController canvas;
  final bool canTakePhoto;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final area = vm.area!;
    if (vm.mode == DiningLayoutMode.grid) {
      return _titledCard(
        context,
        key: const ValueKey('floor-grid-info'),
        title: l10n.floorGridInfoTitle,
        child: Text(
          l10n.floorGridInfoBody(area.name),
          style: context.theme.typography.body.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
      );
    }
    if (vm.image == null) {
      return _UploadPanel(
        viewModel: vm,
        canTakePhoto: canTakePhoto,
        narrow: narrow,
      );
    }
    final theme = context.theme;
    final selected = vm.selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        _Toolbar(viewModel: vm, canvas: canvas),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: theme.colors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FloorCanvas(
                      key: const ValueKey('floor-canvas'),
                      controller: canvas,
                      world: vm.world,
                      image: vm.image,
                      opacity: vm.opacity,
                      editable: true,
                      selected: selected?.key,
                      onSelect: vm.select,
                      onMoved: vm.moveTo,
                      onResized: vm.resizeTo,
                      tables: [
                        for (final t in vm.placed)
                          FloorTableSpec(
                            key: t.key,
                            x: t.x!,
                            y: t.y!,
                            width: t.width,
                            height: t.height,
                            shape: t.shape,
                          ),
                      ],
                      tableBuilder: (context, key) {
                        final t = vm.items
                            .where((i) => i.key == key)
                            .firstOrNull;
                        if (t == null) return const SizedBox.shrink();
                        final isSelected = t.key == vm.selected?.key;
                        final isError = t.key == vm.errorItem?.key;
                        return FloorTableBox(
                          key: ValueKey('floor-table-${t.name}'),
                          name: t.name,
                          detail: l10n.floorSeats(t.seats),
                          shape: t.shape,
                          background: isSelected
                              ? theme.colors.primary.withValues(alpha: 0.12)
                              : theme.colors.card,
                          foreground: theme.colors.foreground,
                          border: isError
                              ? theme.colors.destructive
                              : theme.colors.primary,
                          borderWidth: isSelected || isError ? 2.5 : 1.5,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: FloorZoomControls(controller: canvas),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.viewModel, required this.canvas});

  final FloorPlanViewModel viewModel;
  final FloorCanvasController canvas;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final label = theme.typography.body.sm.copyWith(
      fontWeight: FontWeight.w600,
    );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FButton.icon(
          key: const ValueKey('floor-undo'),
          variant: .outline,
          semanticsLabel: l10n.floorUndo,
          onPress: vm.canUndo ? vm.undo : null,
          child: const Icon(TablerIcons.arrowBackUp, size: 16),
        ),
        FButton.icon(
          key: const ValueKey('floor-redo'),
          variant: .outline,
          semanticsLabel: l10n.floorRedo,
          onPress: vm.canRedo ? vm.redo : null,
          child: const Icon(TablerIcons.arrowForwardUp, size: 16),
        ),
        FButton(
          key: const ValueKey('floor-replace-image'),
          variant: .outline,
          mainAxisSize: .min,
          onPress: vm.upload.running ? null : () => vm.upload.execute(false),
          child: Text(l10n.floorReplaceImage),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(l10n.floorOpacity, style: label)),
            SizedBox(
              width: 120,
              child: Material(
                type: .transparency,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: theme.colors.primary,
                    thumbColor: theme.colors.primary,
                    inactiveTrackColor: theme.colors.secondary,
                  ),
                  child: Slider(
                    key: const ValueKey('floor-opacity'),
                    value: vm.opacity,
                    min: 0.2,
                    semanticFormatterCallback: (v) => '${(v * 100).round()}%',
                    onChanged: vm.setOpacity,
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Flexible(
              child: Text(l10n.floorSnap(FloorLimits.grid), style: label),
            ),
            FSwitch(
              key: const ValueKey('floor-snap'),
              semanticsLabel: l10n.floorSnap(FloorLimits.grid),
              value: vm.snap,
              onChange: (_) => vm.toggleSnap(),
            ),
          ],
        ),
        ValueListenableBuilder(
          valueListenable: canvas.zoom,
          builder: (context, zoom, _) => Text(
            l10n.floorZoom((zoom * 100).round()),
            key: const ValueKey('floor-zoom'),
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}

class _UploadPanel extends StatelessWidget {
  const _UploadPanel({
    required this.viewModel,
    required this.canTakePhoto,
    required this.narrow,
  });

  final FloorPlanViewModel viewModel;
  final bool canTakePhoto;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final busy = vm.upload.running;
    final upload = DecoratedBox(
      key: const ValueKey('floor-upload'),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: narrow ? 28 : 56,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Icon(
                  TablerIcons.upload,
                  size: 28,
                  color: theme.colors.primary,
                ),
              ),
            ),
            Text(
              l10n.floorUploadTitle(vm.area!.name),
              textAlign: TextAlign.center,
              style: theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              l10n.floorUploadBody,
              textAlign: TextAlign.center,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            if (vm.error case final e?)
              Text(
                floorErrorMessage(l10n, e),
                key: const ValueKey('floor-upload-error'),
                textAlign: TextAlign.center,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.destructive,
                ),
              ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                FButton(
                  key: const ValueKey('floor-pick-file'),
                  mainAxisSize: .min,
                  onPress: busy ? null : () => vm.upload.execute(false),
                  child: Text(l10n.floorPickFile),
                ),
                if (canTakePhoto)
                  FButton(
                    key: const ValueKey('floor-take-photo'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: busy ? null : () => vm.upload.execute(true),
                    child: Text(l10n.floorTakePhoto),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    final tips = _titledCard(
      context,
      key: const ValueKey('floor-tips'),
      title: l10n.floorTipsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          for (final (k, v) in [
            (l10n.floorTipAngle, l10n.floorTipAngleValue),
            (l10n.floorTipSize, l10n.floorTipSizeValue),
            (l10n.floorTipContent, l10n.floorTipContentValue),
          ])
            Row(
              children: [
                Expanded(
                  child: Text(
                    k,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    v,
                    textAlign: TextAlign.end,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          FAlert(title: Text(l10n.floorTipStorage)),
          Text(
            l10n.floorTipGrid,
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [upload, tips],
      );
    }
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Expanded(child: upload),
          SizedBox(width: 300, child: tips),
        ],
      ),
    );
  }
}

// --- Panel kiri: palet + belum ditempatkan ------------------------------------

class _Palette extends StatelessWidget {
  const _Palette({
    required this.viewModel,
    required this.canvas,
    required this.compact,
  });

  final FloorPlanViewModel viewModel;
  final FloorCanvasController canvas;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final enabled = vm.showCanvas;
    final heading = theme.typography.body.md.copyWith(
      fontWeight: FontWeight.w600,
    );
    final muted = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );

    Widget preset(int i, TablePreset p) {
      final shape = tableShapeOf(p.shape);
      final label = l10n.floorPreset(floorShapeLabel(l10n, shape), p.seats);
      final round = shape == TableShape.round || shape == TableShape.bar;
      final icon = Container(
        width: p.width / 3,
        height: p.height / 3,
        decoration: BoxDecoration(
          shape: round ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: round ? null : BorderRadius.circular(4),
          border: Border.all(color: theme.colors.primary, width: 1.5),
        ),
      );
      return FTappable(
        key: ValueKey('floor-preset-$i'),
        semanticsLabel: label,
        onPress: enabled
            ? () {
                final c = canvas.center;
                vm.addPreset(p, cx: c.dx, cy: c.dy);
              }
            : null,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.card,
            border: Border.all(color: theme.colors.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
              spacing: 12,
              children: [
                SizedBox(width: 60, child: Center(child: icon)),
                Flexible(
                  child: Text(
                    label,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                      color: enabled ? null : theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final unplaced = vm.unplaced;
    final presets = [
      for (final (i, p) in TablePreset.all.indexed) preset(i, p),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        Text(l10n.floorAddTable, style: heading),
        Text(l10n.floorAddTableHint, style: muted),
        if (compact)
          Wrap(spacing: 8, runSpacing: 8, children: presets)
        else
          ...presets,
        const SizedBox(height: 6),
        Text(l10n.floorUnplaced, style: heading),
        Text(l10n.floorUnplacedHint, style: muted),
        if (unplaced.isEmpty)
          Text(
            l10n.floorUnplacedNone,
            key: const ValueKey('floor-unplaced-none'),
            style: muted,
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in unplaced)
              FTappable(
                key: ValueKey('floor-unplaced-${t.name}'),
                semanticsLabel: t.name,
                onPress: enabled
                    ? () {
                        final c = canvas.center;
                        vm.place(t.key, cx: c.dx, cy: c.dy);
                      }
                    : null,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colors.card,
                    border: Border.all(color: theme.colors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: t.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(
                            text: '  ${l10n.floorSeats(t.seats)}',
                            style: muted,
                          ),
                        ],
                      ),
                      style: theme.typography.body.sm,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// --- Panel kanan: mode + properti + simpan ----------------------------------

final _digits3 = [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(3),
];

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.viewModel});

  final FloorPlanViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final heading = theme.typography.body.md.copyWith(
      fontWeight: FontWeight.w600,
    );
    final busy = vm.save.running;

    Widget modeCard(DiningLayoutMode mode, String title, String body) {
      final selected = vm.mode == mode;
      return FTappable(
        key: ValueKey('floor-mode-${mode.name}'),
        semanticsLabel: title,
        selected: selected,
        onPress: busy ? null : () => vm.setMode(mode),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected
                ? theme.colors.primary.withValues(alpha: 0.1)
                : theme.colors.card,
            border: Border.all(
              color: selected ? theme.colors.primary : theme.colors.border,
              width: selected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Icon(
                  selected ? TablerIcons.circleDot : TablerIcons.circle,
                  size: 18,
                  color: selected
                      ? theme.colors.primary
                      : theme.colors.mutedForeground,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        title,
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        body,
                        style: theme.typography.body.xs.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final t = vm.selected;
    final epoch = vm.formEpoch;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(l10n.floorModeTitle(vm.area!.name), style: heading),
        modeCard(
          DiningLayoutMode.grid,
          l10n.floorModeGrid,
          l10n.floorModeGridHint,
        ),
        modeCard(
          DiningLayoutMode.floor,
          l10n.floorModeFloor,
          l10n.floorModeFloorHint,
        ),
        if (t != null && vm.showCanvas) ...[
          const FDivider(),
          Text(
            l10n.floorSelected(t.name),
            key: const ValueKey('floor-selected'),
            style: heading,
          ),
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: FTextField(
                  key: ValueKey('floor-name-${t.key}-$epoch'),
                  label: Text(l10n.floorName),
                  maxLength: FnbLimits.tableName,
                  control: .managed(
                    initial: TextEditingValue(text: t.name),
                    onChange: (v) => vm.setName(v.text),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: FTextField(
                  key: ValueKey('floor-seats-${t.key}-$epoch'),
                  label: Text(l10n.floorSeatsLabel),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  control: .managed(
                    initial: TextEditingValue(text: '${t.seats}'),
                    onChange: (v) => vm.setSeats(int.tryParse(v.text)),
                  ),
                ),
              ),
            ],
          ),
          Text(
            l10n.floorShape,
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in TableShape.values)
                ChoicePill(
                  key: ValueKey('floor-shape-${s.name}'),
                  label: floorShapeLabel(l10n, s),
                  selected: t.shape == s,
                  onTap: () => vm.setShape(s),
                ),
            ],
          ),
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FTextField(
                  key: ValueKey('floor-width-${t.key}-$epoch'),
                  label: Text(l10n.floorWidth),
                  keyboardType: TextInputType.number,
                  inputFormatters: _digits3,
                  control: .managed(
                    initial: TextEditingValue(text: '${t.width}'),
                    onChange: (v) => vm.setWidth(int.tryParse(v.text)),
                  ),
                ),
              ),
              Expanded(
                child: FTextField(
                  key: ValueKey('floor-height-${t.key}-$epoch'),
                  label: Text(l10n.floorHeight),
                  keyboardType: TextInputType.number,
                  inputFormatters: _digits3,
                  control: .managed(
                    initial: TextEditingValue(text: '${t.height}'),
                    onChange: (v) => vm.setHeight(int.tryParse(v.text)),
                  ),
                ),
              ),
            ],
          ),
          Text(
            l10n.floorOrientation,
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              ChoicePill(
                key: const ValueKey('floor-orientation-0'),
                label: l10n.floorHorizontal,
                selected: !t.vertical,
                onTap: () => vm.setVertical(false),
              ),
              ChoicePill(
                key: const ValueKey('floor-orientation-90'),
                label: l10n.floorVertical,
                selected: t.vertical,
                onTap: () => vm.setVertical(true),
              ),
            ],
          ),
          FSwitch(
            key: const ValueKey('floor-can-merge'),
            label: Text(l10n.floorCanMerge),
            value: t.canMerge,
            onChange: vm.setCanMerge,
          ),
          FButton(
            key: const ValueKey('floor-delete'),
            variant: .outline,
            onPress: busy ? null : vm.deleteSelected,
            prefix: Icon(
              TablerIcons.trash,
              size: 16,
              color: theme.colors.destructive,
            ),
            child: Text(
              l10n.floorDelete,
              style: TextStyle(color: theme.colors.destructive),
            ),
          ),
        ] else if (vm.showCanvas)
          Text(
            l10n.floorSelectHint,
            key: const ValueKey('floor-select-hint'),
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        // Galat unggah pertama tampil di panel unggah.
        if (vm.error case final e?
            when vm.mode == DiningLayoutMode.grid || vm.image != null)
          FAlert(
            key: const ValueKey('floor-error'),
            variant: .destructive,
            title: Text(
              vm.errorItem == null
                  ? floorErrorMessage(l10n, e)
                  : l10n.floorErrorOn(
                      vm.errorItem!.name,
                      floorErrorMessage(l10n, e),
                    ),
            ),
          ),
        if (vm.dirty)
          Text(
            l10n.floorUnsaved,
            key: const ValueKey('floor-unsaved'),
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        FButton(
          key: const ValueKey('floor-save'),
          onPress: busy || !vm.dirty ? null : vm.save.execute,
          child: Text(busy ? l10n.floorSaving : l10n.floorSave),
        ),
      ],
    );
  }
}
