import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('syncTables', () {
    test('tidak memuat tabel yang hanya ada di perangkat', () {
      final names = syncTables.map((t) => t.name).toSet();
      for (final local in [
        'sync_outbox',
        'sync_state',
        'local_preferences',
        'stock_levels',
      ]) {
        expect(names, isNot(contains(local)), reason: local);
      }
    });

    test('nama tabel unik', () {
      final names = syncTables.map((t) => t.name).toList();
      expect(names.toSet().length, names.length);
    });

    test('setiap induk muncul lebih awal di daftar', () {
      final seen = <String>{};
      for (final t in syncTables) {
        for (final p in t.parents) {
          expect(seen, contains(p), reason: '${t.name} → $p');
        }
        seen.add(t.name);
      }
    });

    test('induk ke diri sendiri lewat selfParentColumn, bukan parents', () {
      final categories = syncTableByName('categories')!;
      expect(categories.parents, isNot(contains('categories')));
      expect(categories.selfParentColumn, 'parentId');
    });

    test('syncTableByName mengembalikan null untuk tabel tak dikenal', () {
      expect(syncTableByName('sync_outbox'), isNull);
      expect(syncTableByName('sales')!.finalStatus!.kind, FinalKind.sale);
    });

    test('aturan final: nota, pembelian, pembayaran piutang, pengeluaran', () {
      expect(syncTableByName('sales')!.finalStatus!.mutableColumns, {
        'status',
        'voidedAt',
        'voidReason',
        'voidedBy',
      });
      expect(
        syncTableByName('purchases')!.finalStatus!.kind,
        FinalKind.purchase,
      );
      expect(
        syncTableByName('debt_payments')!.finalStatus!.kind,
        FinalKind.voidOnly,
      );
      expect(
        syncTableByName('expenses')!.finalStatus!.kind,
        FinalKind.voidOnly,
      );
      expect(syncTableByName('products')!.finalStatus, isNull);
    });
  });

  group('mergeSaleStatus', () {
    test('void menang atas retur sebagian, ke dua arah', () {
      expect(mergeSaleStatus('partiallyReturned', 'voided'), 'voided');
      expect(mergeSaleStatus('voided', 'partiallyReturned'), 'voided');
    });

    test('status tidak pernah mundur', () {
      expect(mergeSaleStatus('completed', 'open'), 'completed');
      expect(mergeSaleStatus('open', 'completed'), 'completed');
      expect(mergeSaleStatus('returned', 'partiallyReturned'), 'returned');
      expect(mergeSaleStatus('voided', 'returned'), 'voided');
    });

    test('status sama tetap', () {
      expect(mergeSaleStatus('completed', 'completed'), 'completed');
    });
  });

  group('mergePurchaseStatus', () {
    test('diterima menang atas draf, ke dua arah', () {
      expect(mergePurchaseStatus('draft', 'received'), 'received');
      expect(mergePurchaseStatus('received', 'draft'), 'received');
    });
  });

  group('isFinal', () {
    test('nota final kecuali open bill', () {
      final rule = syncTableByName('sales')!.finalStatus!;
      expect(rule.isFinal({'status': 'open'}), isFalse);
      expect(rule.isFinal({'status': 'completed'}), isTrue);
    });

    test('pembelian final setelah diterima', () {
      final rule = syncTableByName('purchases')!.finalStatus!;
      expect(rule.isFinal({'status': 'draft'}), isFalse);
      expect(rule.isFinal({'status': 'received'}), isTrue);
    });

    test('pembayaran piutang selalu final', () {
      final rule = syncTableByName('debt_payments')!.finalStatus!;
      expect(rule.isFinal({}), isTrue);
    });
  });
}
