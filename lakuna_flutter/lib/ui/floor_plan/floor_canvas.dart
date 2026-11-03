import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

import '../../l10n/gen/app_localizations.dart';

/// Data node denah: meja ([key]) atau gambar latar.
@immutable
class FloorNodeData {
  const FloorNodeData(this.key, {this.background = false});

  final String key;
  final bool background;
}

/// Node meja: tanpa port, bisa diubah ukurannya (20–600).
class _TableNode extends Node<FloorNodeData>
    with ResizableMixin<FloorNodeData> {
  _TableNode({
    required super.id,
    required super.position,
    required super.data,
    required super.size,
    super.locked,
  }) : super(type: 'table', retainedRendering: RetainedNodeRendering.live);

  @override
  Size get minSize => const Size(
    FloorLimits.minSize + 0.0,
    FloorLimits.minSize + 0.0,
  );

  @override
  Size? get maxSize => const Size(
    FloorLimits.maxSize + 0.0,
    FloorLimits.maxSize + 0.0,
  );
}

/// Meja yang digambar di kanvas. [signature] berubah = isi node digambar
/// ulang (nama, warna, kursi).
@immutable
class FloorTableSpec {
  const FloorTableSpec({
    required this.key,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.shape,
    required this.signature,
  });

  final String key;
  final int x;
  final int y;
  final int width;
  final int height;
  final TableShape shape;
  final Object signature;
}

/// Plugin penerus kejadian akhir geser/ubah ukuran dan zoom.
class _FloorEvents extends NodeFlowPlugin {
  void Function(Set<String> ids)? onDragEnded;
  void Function(String id)? onResizeEnded;
  void Function(double zoom)? onZoom;

  @override
  String get id => 'lakuna-floor-events';

  @override
  void attach(NodeFlowController<dynamic, dynamic> controller) {}

  @override
  void detach() {}

  @override
  void onEvent(GraphEvent event) {
    switch (event) {
      case NodeDragEnded(:final nodeIds):
        onDragEnded?.call(nodeIds);
      case ResizeEnded(:final nodeId):
        onResizeEnded?.call(nodeId);
      case ViewportChanged(:final viewport):
        onZoom?.call(viewport.zoom);
      default:
    }
  }
}

const _minimapFloor = Color(0xFFE4E4E7);

/// Pengendali kanvas denah: zoom, tengah tampilan, snap.
class FloorCanvasController {
  FloorCanvasController({bool snap = false})
    : _snap = SnapPlugin([
        GridSnapDelegate(gridSize: FloorLimits.grid + 0.0),
      ], enabled: snap),
      _events = _FloorEvents() {
    flow = NodeFlowController<FloorNodeData, void>(
      config: NodeFlowConfig(
        minZoom: 0.25,
        maxZoom: 3,
        showAttribution: false,
        plugins: [
          _snap,
          MinimapPlugin(
            visible: true,
            size: const Size(150, 110),
            margin: 12,
            // Gambar denah digambar abu-abu tipis; tanpa ini seluruh peta
            // mini tertutup warna node dan meja tidak terlihat.
            thumbnailBuilder: (canvas, node, bounds, color) {
              if (node.data case FloorNodeData(background: true)) {
                canvas.drawRect(bounds, Paint()..color = _minimapFloor);
                return true;
              }
              return false;
            },
          ),
          _events,
        ],
      ),
    );
    // Tanpa pintasan keyboard bawaan (hapus, gandakan, tempel): semua
    // perubahan meja lewat panel agar draf tetap satu sumber.
    for (final keys in flow.shortcuts.shortcuts.keys.toList()) {
      flow.shortcuts.removeShortcut(keys);
    }
    _events.onZoom = (z) => zoom.value = z;
  }

  late final NodeFlowController<FloorNodeData, void> flow;
  final SnapPlugin _snap;
  final _FloorEvents _events;

  /// Zoom terkini (label "Zoom 100%").
  final zoom = ValueNotifier<double>(1);

  set snap(bool value) => _snap.enabled = value;

  /// Titik tengah tampilan dalam koordinat dunia denah.
  Offset get center => flow.getViewportCenter().offset;

  void zoomIn() => flow.zoomBy(0.2);
  void zoomOut() => flow.zoomBy(-0.2);
  void fit() => flow.fitToView();

  void dispose() {
    flow.dispose();
    zoom.dispose();
  }
}

/// Kanvas denah `vyuh_node_flow`: gambar denah = node terkunci di lapisan
/// latar, meja = node tanpa port. [editable] = *Atur denah* (geser, ubah
/// ukuran); selain itu meja terkunci (geser & zoom tampilan saja).
class FloorCanvas extends StatefulWidget {
  const FloorCanvas({
    super.key,
    required this.controller,
    required this.world,
    required this.tables,
    required this.tableBuilder,
    this.image,
    this.opacity = 1,
    this.editable = false,
    this.selected,
    this.onSelect,
    this.onTap,
    this.onMoved,
    this.onResized,
  });

  final FloorCanvasController controller;
  final ({int width, int height}) world;
  final List<FloorTableSpec> tables;
  final Widget Function(BuildContext context, String key) tableBuilder;
  final FloorImage? image;
  final double opacity;
  final bool editable;

  /// Meja terpilih (editor).
  final String? selected;
  final ValueChanged<String?>? onSelect;

  /// Ketuk meja (layar Meja).
  final ValueChanged<String>? onTap;
  final void Function(String key, int x, int y)? onMoved;
  final void Function(String key, int x, int y, int width, int height)?
  onResized;

  static const backgroundId = '__denah';

  @override
  State<FloorCanvas> createState() => _FloorCanvasState();
}

class _FloorCanvasState extends State<FloorCanvas> {
  final _signatures = <String, Object>{};
  Object? _backgroundSignature;
  var _fitted = false;

  NodeFlowController<FloorNodeData, void> get _flow => widget.controller.flow;

  @override
  void initState() {
    super.initState();
    _wire();
    _sync();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _fitted) return;
      _fitted = true;
      widget.controller.fit();
    });
  }

  @override
  void didUpdateWidget(FloorCanvas old) {
    super.didUpdateWidget(old);
    _wire();
    // Menyentuh node MobX tidak boleh di tengah build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync();
    });
  }

  void _wire() {
    final events = widget.controller._events;
    events.onDragEnded = (ids) {
      for (final id in ids) {
        final node = _flow.getNode(id);
        if (node == null || node.data.background) continue;
        final p = node.position.value;
        widget.onMoved?.call(id, p.dx.round(), p.dy.round());
      }
    };
    events.onResizeEnded = (id) {
      final node = _flow.getNode(id);
      if (node == null || node.data.background) return;
      final p = node.position.value;
      final s = node.size.value;
      widget.onResized?.call(
        id,
        p.dx.round(),
        p.dy.round(),
        s.width.round(),
        s.height.round(),
      );
    };
  }

  void _sync() {
    final flow = _flow;
    final world = widget.world;
    final bg = (widget.image?.media.id, world, widget.opacity);
    if (bg != _backgroundSignature) {
      if (flow.getNode(FloorCanvas.backgroundId) != null) {
        flow.removeNode(FloorCanvas.backgroundId);
      }
      flow.addNode(
        Node<FloorNodeData>(
          id: FloorCanvas.backgroundId,
          type: 'denah',
          position: Offset.zero,
          size: Size(world.width + 0.0, world.height + 0.0),
          data: const FloorNodeData(FloorCanvas.backgroundId, background: true),
          layer: NodeRenderLayer.background,
          locked: true,
          selectable: false,
          initialZIndex: -1,
        ),
      );
      _backgroundSignature = bg;
    }

    final keys = {for (final t in widget.tables) t.key};
    for (final id in _signatures.keys.toList()) {
      if (keys.contains(id)) continue;
      if (flow.getNode(id) != null) flow.removeNode(id);
      _signatures.remove(id);
    }
    for (final t in widget.tables) {
      final position = Offset(t.x + 0.0, t.y + 0.0);
      final size = Size(t.width + 0.0, t.height + 0.0);
      final signature = (t.signature, t.shape, widget.editable);
      final node = flow.getNode(t.key);
      if (node == null || _signatures[t.key] != signature) {
        if (node != null) flow.removeNode(t.key);
        flow.addNode(
          _TableNode(
            id: t.key,
            position: position,
            size: size,
            data: FloorNodeData(t.key),
            locked: !widget.editable,
          ),
        );
        _signatures[t.key] = signature;
        continue;
      }
      if (node.position.value != position) {
        flow.setNodePosition(t.key, position);
      }
      if (node.size.value != size) flow.setNodeSize(t.key, size);
    }

    if (widget.editable) {
      final selected = widget.selected;
      if (selected == null) {
        if (flow.selectedNodeIds.isNotEmpty) flow.clearNodeSelection();
      } else if (!flow.isNodeSelected(selected) &&
          flow.getNode(selected) != null) {
        flow.selectNode(selected);
      }
    }
  }

  NodeFlowTheme _theme(BuildContext context) {
    final colors = context.theme.colors;
    final dark = colors.brightness == Brightness.dark;
    final base = dark ? NodeFlowTheme.dark : NodeFlowTheme.light;
    return base.copyWith(
      backgroundColor: colors.muted,
      nodeTheme: base.nodeTheme.copyWith(
        backgroundColor: Colors.transparent,
        selectedBackgroundColor: Colors.transparent,
        highlightBackgroundColor: Colors.transparent,
        borderColor: Colors.transparent,
        selectedBorderColor: Colors.transparent,
        highlightBorderColor: Colors.transparent,
        borderWidth: 0,
        selectedBorderWidth: 0,
        borderRadius: BorderRadius.zero,
      ),
      gridTheme: GridTheme(
        color: colors.border,
        size: FloorLimits.grid + 0.0,
        thickness: 1,
        style: GridStyles.dots,
      ),
    );
  }

  Widget _background(BuildContext context) {
    final image = widget.image;
    final bytes = image?.bytes;
    final colors = context.theme.colors;
    final Widget content;
    if (image == null || bytes == null) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          color: colors.card,
          border: Border.all(color: colors.border),
        ),
      );
    } else if (image.isSvg) {
      content = SvgPicture.memory(bytes, fit: BoxFit.fill);
    } else {
      content = Image.memory(bytes, fit: BoxFit.fill, gaplessPlayback: true);
    }
    return IgnorePointer(
      child: Opacity(opacity: widget.opacity, child: content),
    );
  }

  @override
  Widget build(BuildContext context) => NodeFlowEditor<FloorNodeData, void>(
    controller: _flow,
    theme: _theme(context),
    behavior: widget.editable
        ? NodeFlowBehavior.design
        : NodeFlowBehavior.preview,
    nodeBuilder: (context, node) => node.data.background
        ? _background(context)
        // Node berbentuk (bulat) membungkus isi dengan Center: isi dipaksa
        // memenuhi ukuran node agar lingkaran tidak menyusut ke ukuran teks.
        : SizedBox.expand(child: widget.tableBuilder(context, node.data.key)),
    nodeShapeBuilder: (context, node) {
      if (node.data.background) return null;
      final spec = widget.tables.where((t) => t.key == node.id).firstOrNull;
      return spec?.shape == TableShape.round || spec?.shape == TableShape.bar
          ? const CircleShape(
              fillColor: Colors.transparent,
              strokeColor: Colors.transparent,
              strokeWidth: 0,
            )
          : null;
    },
    events: NodeFlowEvents<FloorNodeData, void>(
      node: NodeEvents<FloorNodeData>(
        onTap: (node) {
          if (!node.data.background) widget.onTap?.call(node.data.key);
        },
        onSelected: widget.editable
            ? (node) => widget.onSelect?.call(
                node == null || node.data.background ? null : node.data.key,
              )
            : null,
        onBeforeDelete: (_) async => false,
      ),
    ),
  );
}

/// Tombol zoom (+, −, pas layar) di pojok kanvas.
class FloorZoomControls extends StatelessWidget {
  const FloorZoomControls({super.key, required this.controller});

  final FloorCanvasController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget button(String key, IconData icon, String label, VoidCallback f) =>
        FButton.icon(
          key: ValueKey(key),
          variant: .outline,
          semanticsLabel: label,
          onPress: f,
          child: Icon(icon, size: 16),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        button(
          'floor-zoom-in',
          TablerIcons.plus,
          l10n.floorZoomIn,
          controller.zoomIn,
        ),
        button(
          'floor-zoom-out',
          TablerIcons.minus,
          l10n.floorZoomOut,
          controller.zoomOut,
        ),
        button(
          'floor-zoom-fit',
          TablerIcons.arrowsMaximize,
          l10n.floorZoomFit,
          controller.fit,
        ),
      ],
    );
  }
}

/// Isi kotak meja: nama + baris kecil, bentuk bulat untuk meja bulat/bar.
class FloorTableBox extends StatelessWidget {
  const FloorTableBox({
    super.key,
    required this.name,
    required this.shape,
    required this.background,
    required this.foreground,
    required this.border,
    this.detail,
    this.borderWidth = 1.5,
  });

  final String name;
  final String? detail;
  final TableShape shape;
  final Color background;
  final Color foreground;
  final Color border;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final round = shape == TableShape.round || shape == TableShape.bar;
    final typography = context.theme.typography;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        shape: round ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: round ? null : BorderRadius.circular(8),
        border: Border.all(color: border, width: borderWidth),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                style: typography.body.sm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
              if (detail case final d?)
                Text(
                  d,
                  maxLines: 1,
                  style: typography.body.xs.copyWith(
                    fontSize: 10,
                    color: foreground,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
