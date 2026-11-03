import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_flutter/ui/core/theme/theme.dart';
import 'package:lakuna_flutter/ui/floor_plan/floor_canvas.dart';
import 'package:vyuh_node_flow/vyuh_node_flow.dart';

FloorTableSpec _spec(String key, {int x = 100, int y = 100}) => FloorTableSpec(
  key: key,
  x: x,
  y: y,
  width: 120,
  height: 120,
  shape: TableShape.square,
);

Widget _host(Widget child) => MediaQuery(
  data: const MediaQueryData(size: Size(800, 600)),
  child: Directionality(
    textDirection: TextDirection.ltr,
    child: FTheme(
      data: lakunaLightTheme(touch: true),
      child: child,
    ),
  ),
);

void main() {
  late FloorCanvasController controller;

  setUp(() => controller = FloorCanvasController(snap: true));
  tearDown(() => controller.dispose());

  Widget canvas({
    required List<FloorTableSpec> tables,
    bool editable = false,
    String? selected,
    String label = '',
    ValueChanged<String>? onTap,
  }) => FloorCanvas(
    controller: controller,
    world: (width: 800, height: 560),
    tables: tables,
    editable: editable,
    selected: selected,
    onSelect: (_) {},
    onTap: onTap,
    tableBuilder: (context, key) => Text('$key$label', key: ValueKey('t-$key')),
  );

  testWidgets('node meja dari kanvas sebelumnya dihapus saat dipasang ulang', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(canvas(tables: [_spec('A')], editable: true)),
    );
    await tester.pump();
    // Kanvas dilepas (mis. panel unggah), lalu area lain dipasang.
    await tester.pumpWidget(_host(const SizedBox()));
    await tester.pumpWidget(
      _host(canvas(tables: [_spec('B')], editable: true)),
    );
    await tester.pump();
    expect(controller.flow.nodes.keys.toSet(), {FloorCanvas.backgroundId, 'B'});
  });

  testWidgets('pilih meja & ubah isi tidak membuat ulang node', (tester) async {
    await tester.pumpWidget(
      _host(canvas(tables: [_spec('A')], editable: true)),
    );
    await tester.pump();
    final node = controller.flow.getNode('A');
    await tester.pumpWidget(
      _host(
        canvas(tables: [_spec('A')], editable: true, selected: 'A', label: '!'),
      ),
    );
    await tester.pump();
    expect(identical(controller.flow.getNode('A'), node), isTrue);
    expect(find.text('A!'), findsOneWidget);
  });

  testWidgets('layar Meja: geser di atas meja tidak membuka meja', (
    tester,
  ) async {
    final taps = <String>[];
    await tester.pumpWidget(
      _host(canvas(tables: [_spec('A')], onTap: taps.add)),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byKey(const ValueKey('t-A')), const Offset(0, 120));
    await tester.pumpAndSettle();
    expect(taps, isEmpty);
    await tester.tap(find.byKey(const ValueKey('t-A')));
    // Langsung, tanpa menunggu batas ketuk ganda.
    expect(taps, ['A']);
    await tester.pump(const Duration(milliseconds: 400));
    expect(taps, ['A']);
  });

  testWidgets('sentuhan di kanvas mengunci gulir halaman', (tester) async {
    await tester.pumpWidget(
      _host(
        FloorScrollLock(
          builder: (context, physics) => ListView(
            key: const ValueKey('page'),
            physics: physics,
            children: [
              SizedBox(height: 400, child: canvas(tables: [_spec('A')])),
              const SizedBox(height: 1000),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    ScrollPhysics? physics() =>
        tester.widget<ListView>(find.byKey(const ValueKey('page'))).physics;
    expect(physics(), isNot(isA<NeverScrollableScrollPhysics>()));
    final gesture = await tester.startGesture(const Offset(400, 200));
    await tester.pump();
    expect(physics(), isA<NeverScrollableScrollPhysics>());
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 400));
    expect(physics(), isNot(isA<NeverScrollableScrollPhysics>()));
  });
}
