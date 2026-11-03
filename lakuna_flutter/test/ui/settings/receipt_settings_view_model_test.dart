import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/services/receipt_printer.dart';
import 'package:lakuna_flutter/ui/settings/receipt_settings_view_model.dart';

import '../../testing/fake_receipt_printer.dart';
import '../../testing/fake_receipt_settings_repository.dart';

void main() {
  late FakeReceiptSettingsRepository repo;
  late FakeReceiptPrinter printer;
  late ReceiptSettingsViewModel vm;

  const lines = [ReceiptLine('TOKO')];
  const rpp = PrinterSelection(
    kind: PrinterKind.bluetooth,
    name: 'RPP02N',
    address: '66:22:B1:00:00:01',
  );

  setUp(() async {
    repo = FakeReceiptSettingsRepository(
      config: const ReceiptConfig(
        settings: ReceiptSettings(),
        defaultHeader: 'Jl. Melati 12',
      ),
    );
    printer = FakeReceiptPrinter()..paired = [rpp];
    vm = ReceiptSettingsViewModel(repository: repo, printer: printer);
    await vm.load.execute();
  });

  test('muat: draf dari bawaan, jenis printer awal Bluetooth', () {
    expect(vm.loaded, isTrue);
    expect(vm.paper, ReceiptPaper.mm58);
    expect(vm.headerText, 'Jl. Melati 12');
    expect(vm.footerText, isNull); // UI mengisi ucapan bawaan
    expect(vm.printer, isNull);
    expect(vm.kind, PrinterKind.bluetooth);
  });

  test('tanpa Bluetooth: jenis awal jaringan', () async {
    vm = ReceiptSettingsViewModel(
      repository: repo,
      printer: FakeReceiptPrinter(supportsBluetooth: false),
    );
    await vm.load.execute();
    expect(vm.kind, PrinterKind.network);
    vm.setKind(PrinterKind.bluetooth);
    expect(vm.kind, PrinterKind.network);
  });

  test(
    'ubah isian, pratinjau ikut, simpan; header tak disentuh tetap null',
    () async {
      vm
        ..setPaper(ReceiptPaper.mm80)
        ..setFooter('Makasih ya')
        ..setAutoPrint(true);
      expect(vm.previewConfig.settings.paper, ReceiptPaper.mm80);
      expect(vm.previewConfig.footerLines, ['Makasih ya']);
      expect(vm.previewConfig.headerLines, ['Jl. Melati 12']);
      await vm.save.execute();
      expect(vm.saved, isTrue);
      final saved = repo.saves.single;
      expect(saved.paper, ReceiptPaper.mm80);
      expect(saved.header, isNull);
      expect(saved.footer, 'Makasih ya');
      expect(saved.autoPrint, isTrue);
      final revision = vm.revision;
      vm.setHeader('');
      expect(vm.saved, isFalse);
      expect(vm.previewConfig.headerLines, isEmpty);
      vm.cancel();
      expect(vm.revision, greaterThan(revision));
      expect(vm.headerText, 'Jl. Melati 12');
    },
  );

  test('header dikembalikan sama dengan bawaan → disimpan null agar ikut '
      'alamat cabang lagi', () async {
    vm.setHeader('Ruko Baru');
    await vm.save.execute();
    expect(repo.config.settings.header, 'Ruko Baru');
    vm.setHeader(' Jl. Melati 12 ');
    await vm.save.execute();
    expect(repo.config.settings.header, isNull);
    vm.setHeader('');
    await vm.save.execute();
    expect(repo.config.settings.header, '');
  });

  test('isian terlalu panjang: galat per field, tidak tersimpan', () async {
    vm.setHeader('x' * 49);
    await vm.save.execute();
    expect(vm.errors, {ReceiptSettingsError.headerLineTooLong});
    expect(repo.saves, isEmpty);
  });

  test('Bluetooth: cari, pilih, tes cetak, lupakan', () async {
    await vm.searchBluetooth.execute();
    expect(vm.bluetoothPrinters, [rpp]);
    await vm.choosePrinter.execute(rpp);
    expect(vm.printer, rpp);
    expect(repo.printerSaves.single, rpp);

    await vm.testPrint.execute(lines);
    expect(printer.prints.single.$1, rpp);
    expect(printer.prints.single.$3, ReceiptPaper.mm58);
    expect(vm.testSent, isTrue);

    printer.nextFailure = const PrinterFailure(PrinterFailureReason.connect);
    await vm.testPrint.execute(lines);
    expect(vm.printerFailure, PrinterFailureReason.connect);
    expect(vm.testSent, isFalse);

    await vm.forgetPrinter.execute();
    expect(vm.printer, isNull);
    expect(vm.printerFailure, isNull);
  });

  test('cari Bluetooth saat mati → galat bluetoothOff', () async {
    printer.nextFailure = const PrinterFailure(
      PrinterFailureReason.bluetoothOff,
    );
    await vm.searchBluetooth.execute();
    expect(vm.printerFailure, PrinterFailureReason.bluetoothOff);
    expect(vm.bluetoothSearched, isFalse);
  });

  test('jaringan: alamat tidak sah ditolak, alamat sah dipilih', () async {
    vm.setKind(PrinterKind.network);
    vm.setNetworkAddress('bad host');
    await vm.useNetworkAddress();
    expect(vm.networkAddressInvalid, isTrue);
    expect(repo.printerSaves, isEmpty);

    vm.setNetworkAddress('192.168.1.50');
    expect(vm.networkAddressInvalid, isFalse);
    await vm.useNetworkAddress();
    expect(
      vm.printer,
      const PrinterSelection(
        kind: PrinterKind.network,
        name: '192.168.1.50',
        address: '192.168.1.50:9100',
      ),
    );
  });

  test(
    'dialog sistem: dipilih; tanpa printer tes cetak memakai dialog',
    () async {
      await vm.testPrint.execute(lines);
      expect(printer.prints.single.$1.kind, PrinterKind.system);
      vm.setKind(PrinterKind.system);
      await vm.useSystemDialog();
      expect(vm.printer!.kind, PrinterKind.system);
    },
  );

  test('muat dengan printer jaringan tersimpan mengisi alamat', () async {
    repo.printer = const PrinterSelection(
      kind: PrinterKind.network,
      name: 'Dapur',
      address: '10.0.0.9:9100',
    );
    await vm.load.execute();
    expect(vm.kind, PrinterKind.network);
    expect(vm.networkAddress, '10.0.0.9:9100');
  });
}
