import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart' show BusinessType;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/routing/routes.dart';
import 'package:lakuna_flutter/utils/result.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_backup_repository.dart';
import '../../testing/fake_dining_repository.dart';
import '../../testing/fake_reports_repository.dart';
import '../../testing/fake_session_repository.dart';
import '../../testing/fake_stock_repository.dart';
import '../../testing/fake_store_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

String? _text(WidgetTester tester, String key) =>
    tester.widget<Text>(_key(key)).data;

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key).last);
  await tester.pumpAndSettle();
  await tester.tap(_key(key).last);
  await tester.pumpAndSettle();
}

void main() {
  for (final size in [const Size(1440, 900), const Size(360, 740)]) {
    testWidgets('Beranda 1.10 di ${size.width.toInt()} px', (tester) async {
      final reports = FakeReportsRepository();
      final report = switch (await reports.load(ReportPeriod.today)) {
        Ok(:final value) => value,
        Error(:final error) => throw error,
      };
      final stock = FakeStockRepository();
      final low = switch (await stock.belowMinimum()) {
        Ok(:final value) => value.length,
        Error(:final error) => throw error,
      };
      await pumpLakuna(tester, size: size, reports: reports, stock: stock);

      expect(_text(tester, 'home-greeting'), contains('Yusuf'));
      expect(
        _text(tester, 'home-sales-detail'),
        startsWith(
          '${report.saleCount} transaksi',
        ),
      );
      for (final key in ['cashier', 'history', 'products', 'reports']) {
        expect(_key('home-module-$key'), findsOneWidget, reason: key);
      }
      expect(low, greaterThan(0));
      expect(
        _text(tester, 'home-attention-stock-text'),
        '$low produk di bawah stok minimum',
      );
      expect(_key('home-attention-qris'), findsNothing);
      expect(_key('home-device'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _tap(tester, 'home-module-history');
      expect(_key('home-greeting'), findsNothing);
    });
  }

  testWidgets('tautan stok minimum membuka Stok', (tester) async {
    await pumpLakuna(tester, size: const Size(1440, 900));
    await _tap(tester, 'home-attention-stock-view');
    expect(_key('home-greeting'), findsNothing);
  });

  testWidgets('kasir: tanpa kartu penjualan dan modul laporan', (
    tester,
  ) async {
    await pumpLakuna(
      tester,
      size: const Size(360, 740),
      session: FakeSessionRepository(
        current: sampleStaff(name: 'Dimas', role: 'cashier'),
      ),
    );
    expect(_text(tester, 'home-greeting'), contains('Dimas'));
    expect(_key('home-sales'), findsNothing);
    expect(_key('home-module-reports'), findsNothing);
    expect(_key('home-module-cashier'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('semua beres bila tidak ada yang perlu ditindak', (
    tester,
  ) async {
    await pumpLakuna(
      tester,
      size: const Size(1440, 900),
      stock: FakeStockRepository(rows: const []),
      initialLocation: Routes.home,
      session: FakeSessionRepository(
        current: sampleStaff(name: 'Rina', role: 'manager'),
      ),
    );
    expect(_key('home-attention-clear'), findsOneWidget);
  });

  testWidgets('F&B: QRIS menunggu dan backup terlambat', (tester) async {
    await pumpLakuna(
      tester,
      size: const Size(360, 740),
      store: FakeStoreRepository(
        current: sampleStoreContext(businessType: BusinessType.fnb),
      ),
      dining: _PendingDining(),
      backup: FakeBackupRepository(
        last: DateTime.now().toUtc().subtract(const Duration(days: 10)),
      ),
    );
    expect(_key('home-module-tables'), findsOneWidget);
    expect(
      _text(tester, 'home-attention-qris-text'),
      '2 pembayaran QRIS menunggu konfirmasi',
    );
    expect(
      _text(tester, 'home-attention-backup-text'),
      'Backup terakhir 10 hari lalu',
    );
    await _tap(tester, 'home-attention-qris-view');
    expect(_key('home-greeting'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('retail: tanpa Meja', (tester) async {
    await pumpLakuna(tester, size: const Size(1440, 900));
    expect(_key('home-module-tables'), findsNothing);
  });
}

class _PendingDining extends FakeDiningRepository {
  @override
  Future<Result<int>> pendingQrisCount() async => const Result.ok(2);
}
