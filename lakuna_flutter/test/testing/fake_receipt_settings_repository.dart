import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/receipt_settings_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

/// [ReceiptSettingsRepository] di memori.
class FakeReceiptSettingsRepository extends ReceiptSettingsRepository {
  FakeReceiptSettingsRepository({
    this.config = const ReceiptConfig(settings: ReceiptSettings()),
    this.printer,
  });

  ReceiptConfig config;
  PrinterSelection? printer;
  Exception? nextError;
  final saves = <ReceiptSettings>[];
  final printerSaves = <PrinterSelection?>[];

  Result<T> _result<T>(T Function() value) {
    final e = nextError;
    nextError = null;
    return e == null ? Result.ok(value()) : Result.error(e);
  }

  @override
  Future<Result<ReceiptConfig>> loadReceipt() async => _result(() => config);

  @override
  Future<Result<ReceiptConfig>> saveReceipt(ReceiptSettings settings) async {
    final errors = validateReceiptSettings(
      header: settings.header,
      footer: settings.footer,
    );
    if (errors.isNotEmpty) {
      return Result.error(ReceiptSettingsInvalid(errors));
    }
    return _result(() {
      saves.add(settings);
      return config = ReceiptConfig(
        settings: settings,
        defaultHeader: config.defaultHeader,
      );
    });
  }

  @override
  Future<Result<PrinterSelection?>> loadPrinter() async =>
      _result(() => printer);

  @override
  Future<Result<void>> savePrinter(PrinterSelection? printer) async =>
      _result(() {
        printerSaves.add(printer);
        this.printer = printer;
      });
}
