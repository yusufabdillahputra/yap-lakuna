import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/stock_repository.dart';

void main() {
  final kopi = UuidValue.fromString('00000000-0000-7000-8000-000000000201');
  final sabun = UuidValue.fromString('00000000-0000-7000-8000-000000000202');

  test('JSON bolak-balik (F1-08o)', () {
    final draft = StockAdjustmentDraft(
      reason: StockAdjustmentReason.damaged,
      note: 'Opname',
      lines: [
        (variantId: kopi, physical: const Qty(1500), note: 'rak atas'),
        (variantId: sabun, physical: null, note: ''),
      ],
    );
    expect(StockAdjustmentDraft.fromJson(draft.toJson()), draft);
  });

  test('JSON tidak sah dibaca sebagai tanpa draf (F1-08o)', () {
    String line(Object? physical, {Object? id, Object? note = ''}) =>
        '{"variantId":${id ?? '"${kopi.uuid}"'},"physical":$physical,'
        '"note":${note is String ? '"$note"' : note}}';
    String doc({
      String reason = '"lost"',
      String note = '""',
      String lines = '[]',
    }) => '{"reason":$reason,"note":$note,"lines":$lines}';

    for (final source in [
      '{rusak',
      '[]',
      'null',
      doc(reason: '"hilang"'),
      doc(reason: '1'),
      doc(note: '5'),
      doc(lines: '{}'),
      '{"reason":"lost","note":""}',
      '{"note":"","lines":[]}',
      doc(lines: '[${line(-1)}]'),
      doc(lines: '[${line('"1"')}]'),
      doc(lines: '[${line(1, id: '"bukan-uuid"')}]'),
      doc(lines: '[${line(1, id: 7)}]'),
      doc(lines: '[${line(1, note: 3)}]'),
      doc(lines: '[7]'),
    ]) {
      expect(StockAdjustmentDraft.fromJson(source), isNull, reason: source);
    }
  });

  test('baris kembar dipakai sekali (F1-08o)', () {
    final draft = StockAdjustmentDraft.fromJson(
      '{"reason":"lost","note":"","lines":['
      '{"variantId":"${kopi.uuid}","physical":1000,"note":"a"},'
      '{"variantId":"${kopi.uuid}","physical":2000,"note":"b"}]}',
    );
    expect(draft!.lines, [(variantId: kopi, physical: Qty.one, note: 'a')]);
  });
}
