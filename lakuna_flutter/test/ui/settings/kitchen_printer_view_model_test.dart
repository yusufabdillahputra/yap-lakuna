import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/receipt_settings_repository.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';
import 'package:lakuna_flutter/ui/settings/kitchen_printer_view_model.dart';

import '../../testing/fake_receipt_printer.dart';
import '../../testing/fake_receipt_settings_repository.dart';

void main() {
  late FakeReceiptSettingsRepository repo;
  late FakeReceiptPrinter printer;
  late KitchenPrinterViewModel vm;

  const lines = [ReceiptLine('TIKET DAPUR')];
  const bar = PrinterSelection(
    kind: PrinterKind.bluetooth,
    name: 'Bar',
    address: '66:22:B1:00:00:02',
  );
  const lan = PrinterSelection(
    kind: PrinterKind.network,
    name: '10.0.0.9',
    address: '10.0.0.9:9100',
  );

  setUp(() async {
    repo = FakeReceiptSettingsRepository();
    printer = FakeReceiptPrinter()..paired = [bar];
    vm = KitchenPrinterViewModel(repository: repo, printer: printer);
    await vm.load.execute();
  });

  test('muat: belum ada printer dapur = sama dengan printer struk', () {
    expect(vm.loaded, isTrue);
    expect(vm.kitchen, isNull);
    expect(vm.kind, isNull);
    expect(vm.paper, ReceiptPaper.mm58);
  });

  test('muat printer dapur tersimpan: jenis dan alamat terisi', () async {
    repo.kitchen = const KitchenPrinter(
      printer: lan,
      paper: ReceiptPaper.mm80,
    );
    vm = KitchenPrinterViewModel(repository: repo, printer: printer);
    await vm.load.execute();
    expect(vm.kitchen?.printer, lan);
    expect(vm.kind, PrinterKind.network);
    expect(vm.networkAddress, '10.0.0.9:9100');
    expect(vm.paper, ReceiptPaper.mm80);
  });

  test(
    'alamat jaringan: tidak sah ditolak, sah disimpan dengan kertas',
    () async {
      vm.setKind(PrinterKind.network);
      vm.setPaper(ReceiptPaper.mm80);
      vm.setNetworkAddress('bad host');
      await vm.useNetworkAddress();
      expect(vm.networkAddressInvalid, isTrue);
      expect(repo.kitchenSaves, isEmpty);
      vm.setNetworkAddress('10.0.0.9');
      expect(vm.networkAddressInvalid, isFalse);
      await vm.useNetworkAddress();
      expect(
        repo.kitchen,
        const KitchenPrinter(printer: lan, paper: ReceiptPaper.mm80),
      );
      expect(vm.kitchen, repo.kitchen);
    },
  );

  test('Bluetooth: cari lalu pilih', () async {
    vm.setKind(PrinterKind.bluetooth);
    await vm.searchBluetooth.execute();
    expect(vm.bluetoothSearched, isTrue);
    expect(vm.bluetoothPrinters, [bar]);
    await vm.choose.execute(bar);
    expect(repo.kitchen?.printer, bar);
    expect(vm.kind, PrinterKind.bluetooth);
  });

  test('tanpa Bluetooth: pilihan Bluetooth diabaikan', () async {
    vm = KitchenPrinterViewModel(
      repository: repo,
      printer: FakeReceiptPrinter(supportsBluetooth: false),
    );
    await vm.load.execute();
    vm.setKind(PrinterKind.bluetooth);
    expect(vm.kind, isNull);
    vm.setKind(PrinterKind.system);
    expect(vm.kind, isNull);
  });

  test('ganti kertas setelah printer terpilih langsung tersimpan', () async {
    await vm.choose.execute(lan);
    vm.setPaper(ReceiptPaper.mm80);
    await pumpEventQueue();
    expect(repo.kitchen?.paper, ReceiptPaper.mm80);
    expect(vm.paper, ReceiptPaper.mm80);
  });

  test('tes cetak ke printer dapur dengan kertas dapur', () async {
    await vm.choose.execute(lan);
    expect(vm.canTest, isTrue);
    await vm.testPrint.execute(lines);
    expect(printer.prints.single, (lan, lines, ReceiptPaper.mm58));
    expect(vm.testSent, isTrue);
  });

  test('tes cetak gagal menampilkan alasan', () async {
    await vm.choose.execute(lan);
    printer.nextFailure = const PrinterFailure(PrinterFailureReason.connect);
    await vm.testPrint.execute(lines);
    expect(vm.failure, PrinterFailureReason.connect);
    expect(vm.testSent, isFalse);
  });

  test('tanpa printer dapur tidak bisa tes cetak', () {
    expect(vm.canTest, isFalse);
  });

  test('lupakan: kembali ke printer struk', () async {
    await vm.choose.execute(lan);
    await vm.forget.execute();
    expect(repo.kitchen, isNull);
    expect(vm.kitchen, isNull);
    expect(vm.kind, isNull);
  });

  test('pilih Sama dengan printer struk melupakan printer dapur', () async {
    await vm.choose.execute(lan);
    vm.setKind(null);
    await pumpEventQueue();
    expect(repo.kitchen, isNull);
    expect(vm.kitchen, isNull);
    expect(vm.kind, isNull);
  });

  test(
    'kertas tidak menyimpan ulang printer lama saat jenis lain dipilih',
    () async {
      await vm.choose.execute(lan);
      vm.setKind(PrinterKind.bluetooth);
      vm.setPaper(ReceiptPaper.mm80);
      await pumpEventQueue();
      expect(repo.kitchenSaves, hasLength(1));
      expect(vm.kind, PrinterKind.bluetooth);
      await vm.searchBluetooth.execute();
      await vm.choose.execute(bar);
      expect(
        repo.kitchen,
        const KitchenPrinter(printer: bar, paper: ReceiptPaper.mm80),
      );
    },
  );

  test('gagal simpan kertas: kembali ke kertas tersimpan', () async {
    await vm.choose.execute(lan);
    repo.nextError = const NotPermitted(Permission.settingsManage);
    vm.setPaper(ReceiptPaper.mm80);
    await pumpEventQueue();
    expect(vm.paper, ReceiptPaper.mm58);
    expect(repo.kitchen?.paper, ReceiptPaper.mm58);
  });

  test('simpan ditolak tanpa izin: printer dapur tidak berubah', () async {
    repo.nextError = const NotPermitted(Permission.settingsManage);
    await vm.choose.execute(lan);
    expect(vm.choose.error, isTrue);
    expect(vm.kitchen, isNull);
  });
}
