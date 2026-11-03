import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:test/test.dart';

void main() {
  group('lineShares', () {
    test('total nota (service, PB1) dibagi proporsional ke baris', () {
      // Subtotal 30.000 (10.000 + 20.000), total 33.495.
      expect(lineShares(const Money(33495), [10000, 20000]), [
        const Money(11165),
        const Money(22330),
      ]);
    });

    test('jumlah bagian selalu sama dengan total', () {
      final shares = lineShares(const Money(10000), [1, 1, 1]);
      expect(Money.sum(shares), const Money(10000));
      expect(shares, [const Money(3334), const Money(3333), const Money(3333)]);
    });

    test('semua baris nol tetapi total ada: dibagi rata', () {
      expect(lineShares(const Money(1001), [0, 0]), [
        const Money(501),
        const Money(500),
      ]);
    });

    test('baris nol (gratis) tidak mendapat bagian', () {
      expect(lineShares(const Money(5000), [5000, 0]), [
        const Money(5000),
        Money.zero,
      ]);
    });
  });

  group('returnAmount', () {
    test('retur bertahap: dibulatkan ke bawah, retur terakhir ambil sisa', () {
      // Bagian baris 10.000 untuk 3 porsi.
      const share = Money(10000);
      const sold = 3000;
      final first = returnAmount(
        share: share,
        soldMilli: sold,
        returnedMilli: 0,
        returningMilli: 1000,
      );
      expect(first, const Money(3333));
      final second = returnAmount(
        share: share,
        soldMilli: sold,
        returnedMilli: 1000,
        returningMilli: 1000,
      );
      expect(second, const Money(3333));
      final last = returnAmount(
        share: share,
        soldMilli: sold,
        returnedMilli: 2000,
        returningMilli: 1000,
      );
      expect(last, const Money(3334));
      expect(first + second + last, share);
    });

    test('retur penuh sekaligus = bagian baris', () {
      expect(
        returnAmount(
          share: const Money(7777),
          soldMilli: 2500,
          returnedMilli: 0,
          returningMilli: 2500,
        ),
        const Money(7777),
      );
    });

    test('melebihi sisa ditolak', () {
      expect(
        () => returnAmount(
          share: const Money(1000),
          soldMilli: 2000,
          returnedMilli: 1500,
          returningMilli: 1000,
        ),
        throwsArgumentError,
      );
      expect(
        () => returnAmount(
          share: const Money(1000),
          soldMilli: 2000,
          returnedMilli: 0,
          returningMilli: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  test('returnState: belum, sebagian, penuh', () {
    expect(returnState(sold: [1000, 2000], returned: [0, 0]), ReturnState.none);
    expect(
      returnState(sold: [1000, 2000], returned: [1000, 0]),
      ReturnState.partial,
    );
    expect(
      returnState(sold: [1000, 2000], returned: [1000, 2000]),
      ReturnState.full,
    );
  });

  test('nomor retur RT-OUTLET-PERANGKAT-yymmdd-0001', () {
    expect(
      saleReturnNumber('pst', 'k01', DateTime(2026, 11, 3), 7),
      'RT-PST-K01-261103-0007',
    );
  });

  test('catatan retur: wajib untuk Lainnya, maks 200', () {
    expect(validateReturnNote(other: false, note: null), isNull);
    expect(
      validateReturnNote(other: true, note: '  '),
      ReturnNoteError.missing,
    );
    expect(
      validateReturnNote(other: false, note: 'x' * 201),
      ReturnNoteError.tooLong,
    );
    expect(
      validateReturnNote(other: true, note: 'tamu berubah pikiran'),
      isNull,
    );
  });

  test('restok bawaan: tidak untuk barang rusak/kedaluwarsa', () {
    expect(restockByDefault(ReturnReasonKind.damaged), isFalse);
    expect(restockByDefault(ReturnReasonKind.expired), isFalse);
    expect(restockByDefault(ReturnReasonKind.wrongItem), isTrue);
    expect(restockByDefault(ReturnReasonKind.other), isTrue);
  });
}
