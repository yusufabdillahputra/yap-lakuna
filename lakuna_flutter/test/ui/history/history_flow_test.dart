import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart' show Money;
import 'package:lakuna_flutter/routing/routes.dart';

import '../../testing/app_harness.dart';
import '../../testing/fake_history_repository.dart';
import '../../testing/fake_receipt_printer.dart';
import '../../testing/fake_session_repository.dart';

Finder _key(String key) => find.byKey(ValueKey(key));

Finder _input(String key) =>
    find.descendant(of: _key(key), matching: find.byType(EditableText));

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key));
  await tester.pumpAndSettle();
  await tester.tap(_key(key));
  await tester.pumpAndSettle();
}

void main() {
  late FakeHistoryRepository history;
  late FakeReceiptPrinter printer;
  late FakeSessionRepository session;
  late CheckoutResult kopi;
  late CheckoutResult roti;

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
    String role = 'owner',
    String location = Routes.history,
    Money? drawerCash,
  }) async {
    history = FakeHistoryRepository(
      canVoid: role == 'owner',
      canReturn: role == 'owner',
    )..drawerCash = drawerCash;
    kopi = history.addSale([('Kopi Susu', 2000, 18000)]);
    roti = history.addSale([
      ('Roti Bakar', 1000, 25000),
    ], method: PaymentMethod.qrisStatic);
    printer = FakeReceiptPrinter();
    session = FakeSessionRepository()
      ..current = sampleStaff(name: 'Sari', role: role);
    await pumpLakuna(
      tester,
      size: size,
      initialLocation: location,
      history: history,
      receiptPrinter: printer,
      session: session,
    );
  }

  testWidgets('desktop: daftar + panel, retur sebagian, cetak ulang', (
    tester,
  ) async {
    await pump(tester);
    expect(tester.takeException(), isNull);
    expect(find.text('Riwayat transaksi'), findsWidgets);
    expect(
      find.text('Hari ini · 2 transaksi · Rp 61.000'),
      findsOneWidget,
    );
    expect(_key('history-table'), findsOneWidget);
    expect(_key('history-pick'), findsOneWidget);

    await _tap(tester, 'history-row-${kopi.sale.id.uuid}');
    expect(_key('history-detail-${kopi.sale.id.uuid}'), findsOneWidget);
    final item = kopi.items.single.id.uuid;
    await _tap(tester, 'history-return-plus-$item');
    await _tap(tester, 'history-reason-wrongItem');
    expect(find.text('Proses retur · Rp 18.000'), findsOneWidget);
    await _tap(tester, 'history-refund-transfer');
    await _tap(tester, 'history-return-submit');
    expect(history.returns.single.amount, 18000);
    expect(history.returns.single.restock, isTrue);
    expect(find.text('Retur sebagian'), findsWidgets);
    expect(find.text('RT-PST-K01-261103-0001'), findsOneWidget);
    // Nota yang sudah diretur tidak bisa di-void.
    expect(
      find.text('Nota ini sudah void atau diretur.'),
      findsOneWidget,
    );

    await _tap(tester, 'history-reprint');
    expect(_key('history-reprint-dialog'), findsOneWidget);
    expect(find.textContaining('CETAK ULANG'), findsOneWidget);
    await _tap(tester, 'history-reprint-print');
    expect(printer.prints, hasLength(1));
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('retur tunai melebihi uang di laci: peringatan (F1-03c)', (
    tester,
  ) async {
    await pump(tester, drawerCash: const Money(20000));
    await _tap(tester, 'history-row-${kopi.sale.id.uuid}');
    final item = kopi.items.single.id.uuid;
    await _tap(tester, 'history-return-plus-$item');
    await _tap(tester, 'history-reason-wrongItem');
    expect(_key('history-drawer-short'), findsNothing);
    await _tap(tester, 'history-return-plus-$item');
    expect(
      find.text(
        'Uang di laci diperkirakan Rp 20.000. Jumlah ini lebih '
        'Rp 16.000 dari perkiraan; pastikan uangnya ada sebelum melanjutkan.',
      ),
      findsOneWidget,
    );
    await _tap(tester, 'history-refund-transfer');
    expect(_key('history-drawer-short'), findsNothing);
    await _tap(tester, 'history-refund-cash');
    await _tap(tester, 'history-return-submit');
    expect(history.returns.single.refundMethod, RefundMethod.cash);
    expect(tester.takeException(), isNull);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('void nota tunai melebihi laci: peringatan (F1-03d)', (
    tester,
  ) async {
    await pump(tester, drawerCash: const Money(20000));
    await _tap(tester, 'history-row-${kopi.sale.id.uuid}');
    await _tap(tester, 'history-void');
    expect(_key('history-void-dialog'), findsOneWidget);
    expect(
      find.text(
        'Uang di laci diperkirakan Rp 20.000. Jumlah ini lebih '
        'Rp 16.000 dari perkiraan; pastikan uangnya ada sebelum melanjutkan.',
      ),
      findsOneWidget,
    );
    await tester.enterText(_key('history-void-reason'), 'Salah input');
    await _tap(tester, 'history-void-confirm');
    expect(history.voids, hasLength(1));
    expect(tester.takeException(), isNull);

    // Nota QRIS tidak mengurangi laci.
    await _tap(tester, 'history-row-${roti.sale.id.uuid}');
    await _tap(tester, 'history-void');
    expect(_key('history-void-drawer-short'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('kasir tanpa izin void: persetujuan PIN manajer lalu void', (
    tester,
  ) async {
    await pump(tester, role: 'cashier');
    await _tap(tester, 'history-row-${roti.sale.id.uuid}');
    // Tanpa sales:return form retur tidak tampil.
    expect(_key('history-return-form'), findsNothing);
    await _tap(tester, 'history-void');
    expect(_key('approval-dialog'), findsOneWidget);
    await tester.enterText(_input('approval-pin'), '123456');
    await _tap(tester, 'approval-submit');
    await _tap(tester, 'history-void-confirm');
    expect(
      find.text('Alasan wajib diisi (maks. 120 karakter).'),
      findsOneWidget,
    );
    await tester.enterText(_input('history-void-reason'), 'Salah input');
    await _tap(tester, 'history-void-confirm');
    expect(history.voids.single.$3, session.staff.single.id);
    expect(_key('history-voided-info'), findsOneWidget);
    expect(find.text('Void'), findsWidgets);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('keluar dari detail nota lewat menu samping: daftar dimuat '
      'ulang (F1-12d)', (tester) async {
    await pump(tester, size: const Size(800, 1280));
    await _tap(tester, 'history-row-${roti.sale.id.uuid}');
    expect(_key('history-detail-back'), findsOneWidget);
    // Nota baru dari kasir lain selama detail terbuka.
    final teh = history.addSale([('Es Teh', 1000, 5000)]);
    await _tap(tester, 'nav-history');
    expect(_key('history-detail-back'), findsNothing);
    expect(_key('history-row-${teh.sale.id.uuid}'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filter status memuat ulang daftar', (tester) async {
    await pump(tester);
    await tester.tap(_key('history-filter-status'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Void').last);
    await tester.pumpAndSettle();
    expect(history.filters.last.status, HistoryStatus.voided);
    expect(_key('history-empty'), findsOneWidget);
    await _tap(tester, 'history-range-week');
    expect(history.filters.last.range, HistoryRange.week);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('cari nota: hasil, batas, tidak cocok, pill tanggal (F1-11b)', (
    tester,
  ) async {
    await pump(tester);
    history.truncateSearch = true;
    await tester.enterText(_input('history-search'), '0002');
    await tester.pumpAndSettle();
    expect(history.filters.last.query, '0002');
    expect(
      find.text('Hasil pencarian · 1 transaksi · Rp 25.000'),
      findsOneWidget,
    );
    expect(_key('history-row-${roti.sale.id.uuid}'), findsOneWidget);
    expect(_key('history-row-${kopi.sale.id.uuid}'), findsNothing);
    expect(_key('history-search-truncated'), findsOneWidget);

    await tester.enterText(_input('history-search'), 'tidak-ada');
    await tester.pumpAndSettle();
    expect(_key('history-search-empty'), findsOneWidget);
    expect(
      find.text('Tidak ada nota yang cocok dengan pencarian.'),
      findsOneWidget,
    );

    await _tap(tester, 'history-range-week');
    expect(history.filters.last.query, '');
    expect(history.filters.last.range, HistoryRange.week);
    final field = tester.widget<EditableText>(_input('history-search'));
    expect(field.controller.text, isEmpty);
    expect(find.text('7 hari · 2 transaksi · Rp 61.000'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(1280, 800), Size(360, 780)]) {
    testWidgets('cari nama barang ${size.width.toInt()} px (F1-11d)', (
      tester,
    ) async {
      await pump(tester, size: size);
      expect(
        find.text('Cari no. nota, pelanggan, barang, atau referensi'),
        findsOneWidget,
      );
      await tester.enterText(_input('history-search'), 'ROTI');
      await tester.pumpAndSettle();
      expect(_key('history-row-${roti.sale.id.uuid}'), findsOneWidget);
      expect(_key('history-row-${kopi.sale.id.uuid}'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('barang cocok di baris hasil ${size.width.toInt()} px '
        '(F1-11i)', (tester) async {
      await pump(tester, size: size);
      Finder match(CheckoutResult s) => find.descendant(
        of: _key('history-match-${s.sale.id.uuid}'),
        matching: find.byType(Text),
        matchRoot: true,
      );
      // Tanpa cari: tidak ada baris barang cocok.
      expect(match(roti), findsNothing);
      await tester.enterText(_input('history-search'), 'ROTI');
      await tester.pumpAndSettle();
      expect(
        _plain(tester.widget<Text>(match(roti))),
        'Barang cocok: Roti Bakar',
      );
      // Lebih dari dua barang: dua nama + n lainnya.
      history.matchedOverride[roti.sale.id] = [
        'Roti Bakar Cokelat Keju Spesial',
        'Roti Bakar Srikaya',
        'Roti Tawar',
        'Roti Sobek',
      ];
      await tester.enterText(_input('history-search'), 'roti b');
      await tester.pumpAndSettle();
      expect(
        _plain(tester.widget<Text>(match(roti))),
        'Barang cocok: Roti Bakar Cokelat Keju Spesial, Roti Bakar Srikaya',
      );
      final more = _key('history-match-more-${roti.sale.id.uuid}');
      expect(tester.widget<Text>(more).data, '+2 lainnya');
      // *+n lainnya* tidak ikut terpotong: utuh di dalam baris, di kanan
      // atau di bawah nama.
      final row = tester.getRect(_key('history-row-${roti.sale.id.uuid}'));
      final moreRect = tester.getRect(more);
      final names = tester.getRect(match(roti));
      expect(row.contains(moreRect.topLeft), isTrue);
      expect(row.contains(moreRect.bottomRight - const Offset(1, 1)), isTrue);
      expect(
        moreRect.left >= names.right - 0.5 || moreRect.top >= names.bottom,
        isTrue,
      );
      // Tabel: *+n* selebar teksnya (tidak terpotong elipsis nama).
      if (size.width > 600) {
        final paragraph = tester.renderObject<RenderParagraph>(
          find.descendant(of: more, matching: find.byType(RichText)),
        );
        expect(
          paragraph.getMaxIntrinsicWidth(double.infinity),
          lessThanOrEqualTo(paragraph.size.width + 0.5),
        );
      }
      // Cocok lewat nomor nota saja: tanpa baris barang.
      history.matchedOverride.clear();
      await tester.enterText(_input('history-search'), roti.sale.number);
      await tester.pumpAndSettle();
      expect(_key('history-row-${roti.sale.id.uuid}'), findsOneWidget);
      expect(match(roti), findsNothing);
      expect(_key('history-match-more-${roti.sale.id.uuid}'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in const [Size(1280, 800), Size(360, 780)]) {
    testWidgets('kata kunci disorot di barang cocok ${size.width.toInt()} px '
        '(F1-11k)', (tester) async {
      await pump(tester, size: size);
      Text match(CheckoutResult s) => tester.widget<Text>(
        find.descendant(
          of: _key('history-match-${s.sale.id.uuid}'),
          matching: find.byType(Text),
          matchRoot: true,
        ),
      );
      history.matchedOverride[roti.sale.id] = [
        'Roti Bakar 5 kg',
        'Roti Tawar',
        'Kue Roti',
      ];
      await tester.enterText(_input('history-search'), 'ROTI 5kg');
      await tester.pumpAndSettle();
      final text = match(roti);
      expect(
        _plain(text),
        'Barang cocok: Roti Bakar 5 kg, Roti Tawar',
      );
      // Bagian yang cocok saja, termasuk spasi di `5 kg` (F1-11j);
      // awalan dan pemisah tidak disorot.
      expect(_highlighted(text), ['Roti', '5 kg', 'Roti']);
      // Kata lain: hanya bagian yang cocok dengan kata itu yang disorot.
      history.matchedOverride.clear();
      await tester.enterText(_input('history-search'), 'bakar');
      await tester.pumpAndSettle();
      expect(_highlighted(match(roti)), ['Bakar']);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('cari catatan barang lalu catatannya tampil di rincian '
      '(F1-11g)', (tester) async {
    await pump(tester);
    final iced = history.addSale(
      [('Es Kopi', 1000, 18000), ('Roti Bakar', 1000, 25000)],
      notes: {0: 'Tanpa es'},
    );
    await tester.enterText(_input('history-search'), 'tanpa es');
    await tester.pumpAndSettle();
    expect(_key('history-row-${iced.sale.id.uuid}'), findsOneWidget);
    expect(_key('history-row-${kopi.sale.id.uuid}'), findsNothing);
    await _tap(tester, 'history-row-${iced.sale.id.uuid}');
    final [es, bakar] = iced.items;
    expect(
      find.descendant(
        of: _key('history-item-${es.id.uuid}'),
        matching: find.text('Catatan: Tanpa es'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: _key('history-item-${bakar.id.uuid}'),
        matching: find.textContaining('Catatan'),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('rincian nota menampilkan modifier barang (F1-11h)', (
    tester,
  ) async {
    await pump(tester);
    final shot = history.addSale(
      [('Es Kopi', 1000, 23000), ('Roti Bakar', 1000, 25000)],
      modifiers: {
        0: ['Extra Shot', 'Boba'],
      },
      notes: {0: 'Tanpa es'},
    );
    await tester.enterText(_input('history-search'), 'extra shot');
    await tester.pumpAndSettle();
    await _tap(tester, 'history-row-${shot.sale.id.uuid}');
    final [es, bakar] = shot.items;
    Finder inItem(SaleItem item, Finder finder) => find.descendant(
      of: _key('history-item-${item.id.uuid}'),
      matching: finder,
    );
    expect(inItem(es, find.text('+ Extra Shot, Boba')), findsOneWidget);
    expect(inItem(es, find.text('Catatan: Tanpa es')), findsOneWidget);
    expect(inItem(bakar, find.textContaining('+ ')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(1280, 800), Size(360, 780)]) {
    testWidgets('rincian nota menulis tambahan harga modifier '
        '${size.width.toInt()} px (F1-11l)', (tester) async {
      await pump(tester, size: size);
      final shot = history.addSale(
        [('Es Kopi Susu', 1000, 28000), ('Teh Tawar', 1000, 4000)],
        modifiers: {
          0: ['Extra Shot', 'Boba', 'Reguler'],
          1: ['Tanpa Gula'],
        },
        modifierDeltas: {'Extra Shot': 5000, 'Boba': 4000, 'Tanpa Gula': -1000},
      );
      await tester.enterText(_input('history-search'), 'extra shot');
      await tester.pumpAndSettle();
      await _tap(tester, 'history-row-${shot.sale.id.uuid}');
      final [kopi, teh] = shot.items;
      Finder inItem(SaleItem item, Finder finder) => find.descendant(
        of: _key('history-item-${item.id.uuid}'),
        matching: finder,
      );
      // Angka sama dengan struk: tambahan per modifier, tanpa harga untuk
      // Rp 0; nama dan tambahannya disambung spasi tak putus.
      expect(
        inItem(
          kopi,
          find.text(
            '+ Extra Shot\u00A0+Rp\u00A05.000, Boba\u00A0+Rp\u00A04.000, '
            'Reguler',
          ),
        ),
        findsOneWidget,
      );
      expect(
        inItem(teh, find.text('+ Tanpa Gula\u00A0-Rp\u00A01.000')),
        findsOneWidget,
      );
      // Harga satuan tetap termasuk modifier (dasar 19.000 + 9.000).
      expect(inItem(kopi, find.textContaining('× Rp 28.000')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('360 px: modifier panjang di rincian tanpa luapan (F1-11h)', (
    tester,
  ) async {
    await pump(tester, size: const Size(360, 780));
    final many = history.addSale(
      [('Es Kopi Susu Gula Aren Spesial', 1000, 30000)],
      modifiers: {
        0: [
          'Extra Shot Espresso',
          'Susu Oat Barista',
          'Sirup Karamel Asin',
          'Boba Gula Merah',
          'Krim Keju Tebal',
          'Ukuran Jumbo',
        ],
      },
    );
    await tester.enterText(_input('history-search'), 'oat');
    await tester.pumpAndSettle();
    await _tap(tester, 'history-row-${many.sale.id.uuid}');
    expect(
      find.textContaining('+ Extra Shot Espresso, Susu Oat Barista'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('360 px: kolom cari dan hasil tanpa luapan (F1-11b)', (
    tester,
  ) async {
    await pump(tester, size: const Size(360, 780));
    expect(_key('history-search'), findsOneWidget);
    history.truncateSearch = true;
    await tester.enterText(_input('history-search'), 'PST-K01');
    await tester.pumpAndSettle();
    expect(_key('history-search-truncated'), findsOneWidget);
    expect(
      find.text('Hasil pencarian · 2 transaksi · Rp 61.000'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('rentang tanggal bebas: batal lalu terapkan (F1-11c)', (
    tester,
  ) async {
    await pump(tester);
    await _tap(tester, 'history-range-custom');
    expect(_key('history-range-dialog'), findsOneWidget);
    await _tap(tester, 'history-range-cancel');
    expect(history.filters.last.range, HistoryRange.today);

    await _tap(tester, 'history-range-custom');
    await _tap(tester, 'history-range-apply');
    expect(_key('history-range-dialog'), findsNothing);
    final f = history.filters.last;
    expect(f.range, HistoryRange.custom);
    expect(f.days!.from, f.days!.to);
    // Pill keempat dan ringkasan menampilkan tanggalnya (mis. *4 Nov 2026*).
    final date = RegExp(r'^\d{1,2} \w{3} \d{4}');
    expect(
      find.descendant(
        of: _key('history-range-custom'),
        matching: find.textContaining(date),
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(RegExp(r'^\d{1,2} \w{3} \d{4} · 2 transaksi')),
      findsOneWidget,
    );
    // Kembali ke Hari ini: pill keempat kembali berlabel Rentang tanggal….
    await _tap(tester, 'history-range-today');
    expect(find.text('Rentang tanggal…'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ekspor Excel dari kepala layar', (tester) async {
    await pump(tester);
    await _tap(tester, 'history-export');
    expect(_key('history-export-saved'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets('${size.width.toInt()} px: diskon manual dan pemberinya '
        '(F1-04i)', (tester) async {
      await pump(tester, size: size);
      final discounted = history.addSale(
        [('Nasi Goreng', 2000, 30000)],
        discount: 6000,
        discountBy: 'Rina',
      );
      // Nota lama sebelum F1-04i: diskon tanpa pemberi tercatat.
      final older = history.addSale([('Teh', 1000, 9000)], discount: 1500);
      await pumpLakuna(
        tester,
        size: size,
        initialLocation: Routes.history,
        history: history,
        receiptPrinter: printer,
        session: session,
      );
      await _tap(tester, 'history-row-${discounted.sale.id.uuid}');
      expect(_key('history-discount'), findsOneWidget);
      expect(find.text('Diskon manual · disetujui Rina'), findsOneWidget);
      expect(find.text('Rp 6.000'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (size.width < 600) await _tap(tester, 'history-detail-back');
      await _tap(tester, 'history-row-${older.sale.id.uuid}');
      expect(find.text('Diskon manual'), findsOneWidget);
      expect(find.text('Rp 1.500'), findsOneWidget);
      if (size.width < 600) await _tap(tester, 'history-detail-back');
      // Nota tanpa diskon: tanpa baris diskon.
      await _tap(tester, 'history-row-${kopi.sale.id.uuid}');
      expect(_key('history-discount'), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  }

  for (final size in const [Size(360, 740), Size(820, 1180)]) {
    testWidgets('${size.width.toInt()} px: kartu/tabel lalu halaman rincian', (
      tester,
    ) async {
      await pump(tester, size: size);
      expect(tester.takeException(), isNull);
      expect(_key('history-pick'), findsNothing);
      await _tap(tester, 'history-row-${kopi.sale.id.uuid}');
      expect(_key('history-detail-page'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await _tap(tester, 'history-return-all');
      await _tap(tester, 'history-return-submit');
      expect(history.returns.single.amount, 36000);
      await _tap(tester, 'history-detail-back');
      expect(_key('history-detail-page'), findsNothing);
      // Daftar dimuat ulang setelah kembali.
      expect(find.text('Diretur'), findsWidgets);
    }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
  }

  for (final size in const [Size(1280, 800), Size(360, 740)]) {
    testWidgets(
      '${size.width.toInt()} px: nota kredit Belum lunas, retur potong piutang',
      (tester) async {
        await pump(tester, size: size);
        final credit = history.addSale(
          [('Beras 5 kg', 2000, 50000)],
          customerName: 'Toko Bu Ani',
          paidAmount: 20000,
          dueOn: DateTime.utc(2026, 11, 17),
        );
        await pumpLakuna(
          tester,
          size: size,
          initialLocation: Routes.history,
          history: history,
          receiptPrinter: printer,
          session: session,
        );
        expect(find.text('Belum lunas'), findsWidgets);
        await _tap(tester, 'history-row-${credit.sale.id.uuid}');
        expect(find.text('Toko Bu Ani'), findsWidgets);
        expect(find.textContaining('Kredit'), findsWidgets);
        final item = credit.items.single.id.uuid;
        await _tap(tester, 'history-return-plus-$item');
        expect(_key('history-return-debt'), findsOneWidget);
        expect(_key('history-refund-transfer'), findsNothing);
        await _tap(tester, 'history-return-submit');
        expect(history.returns.single.refundMethod, RefundMethod.debt);
        expect(history.outstanding[credit.sale.id], const Money(30000));
        expect(tester.takeException(), isNull);
      },
    );
  }
}

/// Teks utuh [Text] biasa atau [Text.rich].
String _plain(Text t) => t.data ?? t.textSpan!.toPlainText();

/// Potongan teks tersorot (berlatar) di [Text.rich] barang cocok (F1-11k).
List<String> _highlighted(Text t) {
  final parts = <String>[];
  t.textSpan?.visitChildren((span) {
    if (span is TextSpan &&
        span.text != null &&
        span.style?.backgroundColor != null) {
      parts.add(span.text!);
    }
    return true;
  });
  return parts;
}
