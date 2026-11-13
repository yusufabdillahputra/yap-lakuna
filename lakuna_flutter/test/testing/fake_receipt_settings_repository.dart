import 'package:lakuna_client/lakuna_client.dart';
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

  /// Logo tiap simpan (F1-06b).
  final logoSaves = <(ReceiptLogoUpload?, bool)>[];

  @override
  Future<Result<ReceiptConfig>> saveReceipt(
    ReceiptSettings settings, {
    ReceiptLogoUpload? logo,
    bool removeLogo = false,
  }) async {
    final errors = validateReceiptSettings(
      header: settings.header,
      footer: settings.footer,
    );
    if (errors.isNotEmpty) {
      return Result.error(ReceiptSettingsInvalid(errors));
    }
    if (logo != null) {
      if (checkReceiptLogo(logo.bytes) case final error?) {
        return Result.error(ReceiptLogoInvalid(error));
      }
    }
    return _result(() {
      saves.add(settings);
      logoSaves.add((logo, removeLogo));
      final image = removeLogo ? null : (logo?.bytes ?? config.logoImage);
      final mediaId = image == null
          ? null
          : (logo != null
                ? UuidValue.fromString(newId())
                : config.settings.logoMediaId);
      return config = ReceiptConfig(
        settings: ReceiptSettings(
          paper: settings.paper,
          header: settings.header,
          footer: settings.footer,
          autoPrint: settings.autoPrint,
          logoMediaId: mediaId,
          showLogo: image != null && settings.showLogo,
        ),
        defaultHeader: config.defaultHeader,
        logoImage: image,
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
