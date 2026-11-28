import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

/// Dashboard semua cabang 2.3 (F2-02 tahap 3).
void main() {
  test('rata-rata per nota dibulatkan ke bawah; 0 nota → 0', () {
    expect(averagePerReceipt(const Money(100001), 3), const Money(33333));
    expect(averagePerReceipt(const Money(5000), 0), Money.zero);
  });

  List<Money> hours(Map<int, int> at) => [
    for (var h = 0; h < 24; h++) Money(at[h] ?? 0),
  ];

  test('sumbu jam: jam pertama–terakhir bertransaksi, minimal 08–17', () {
    expect(hourAxis(hours({6: 1000, 21: 500})), (from: 6, to: 21));
    expect(hourAxis(hours({12: 1000})), (from: 8, to: 17));
    expect(hourAxis(hours({})), (from: 8, to: 17));
    expect(hourAxis(hours({7: 1, 9: 1})), (from: 7, to: 17));
  });

  test('perangkat online bila terlihat ≤ 10 menit lalu', () {
    final now = DateTime.utc(2026, 11, 28, 10);
    expect(
      deviceLiveness(now.subtract(const Duration(minutes: 10)), now),
      DeviceLiveness.online,
    );
    expect(
      deviceLiveness(
        now.subtract(const Duration(minutes: 10, seconds: 1)),
        now,
      ),
      DeviceLiveness.offline,
    );
    expect(deviceLiveness(null, now), DeviceLiveness.offline);
  });

  test('perangkat perlu perhatian bila > 1 jam atau belum pernah sync', () {
    final now = DateTime.utc(2026, 11, 28, 10);
    expect(deviceStale(null, now), isTrue);
    expect(deviceStale(now.subtract(const Duration(hours: 1)), now), isFalse);
    expect(
      deviceStale(now.subtract(const Duration(hours: 1, seconds: 1)), now),
      isTrue,
    );
  });

  test('terlaris menggabung varian produk yang sama, urut jumlah lalu '
      'nama, maksimal 5', () {
    final lines = [
      (productId: 'kopi', name: 'Kopi', qty: const Qty(2000)),
      (productId: 'teh', name: 'Teh', qty: const Qty(3000)),
      (productId: 'kopi', name: 'Kopi', qty: const Qty(1500)),
      for (final n in ['Air', 'Bakso', 'Cilok', 'Donat'])
        (productId: n, name: n, qty: const Qty(1000)),
    ];
    final top = topSellingProducts(lines);
    expect(top.map((t) => t.name), ['Kopi', 'Teh', 'Air', 'Bakso', 'Cilok']);
    expect(top.first.sold, const Qty(3500));
    expect(topSellingProducts(lines, limit: 2), hasLength(2));
  });

  test('Fokus review 4: awal hari cabang mengikuti zona cabang', () {
    final now = DateTime.utc(2026, 11, 28, 15, 30);
    // 00.30 WIT tanggal 29 → hari dimulai 29-11 00.00 WIT = 28-11 15.00Z.
    expect(
      outletDayStart(now, 'Asia/Jayapura'),
      DateTime.utc(2026, 11, 28, 15),
    );
    // 22.30 WIB tanggal 28 → 28-11 00.00 WIB = 27-11 17.00Z.
    expect(outletDayStart(now, 'Asia/Jakarta'), DateTime.utc(2026, 11, 27, 17));
  });
}
