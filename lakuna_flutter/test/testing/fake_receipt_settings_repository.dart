import 'dart:async';

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
    this.kitchen,
    this.bar,
  });

  ReceiptConfig config;
  PrinterSelection? printer;
  Exception? nextError;
  final saves = <ReceiptSettings>[];
  final printerSaves = <PrinterSelection?>[];

  /// Printer dapur (F1-10e).
  KitchenPrinter? kitchen;
  final kitchenSaves = <KitchenPrinter?>[];

  /// Printer bar (F1-10j).
  KitchenPrinter? bar;
  final barSaves = <KitchenPrinter?>[];

  /// Kategori menu induk untuk printer bar.
  List<ProductCategory> categories = const [];

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

  @override
  Future<Result<KitchenPrinter?>> loadKitchenPrinter() async =>
      _result(() => kitchen);

  @override
  Future<Result<void>> saveKitchenPrinter(KitchenPrinter? kitchen) async =>
      _result(() {
        kitchenSaves.add(kitchen);
        this.kitchen = kitchen;
      });

  @override
  Future<Result<KitchenPrinter?>> loadBarPrinter() async => _result(() => bar);

  /// Bila diisi, simpan printer bar menunggu sampai selesai.
  Completer<void>? barSaveGate;

  @override
  Future<Result<void>> saveBarPrinter(KitchenPrinter? bar) async {
    await barSaveGate?.future;
    return _result(() {
      barSaves.add(bar);
      this.bar = bar;
    });
  }

  @override
  Future<Result<List<ProductCategory>>> menuCategories() async =>
      _result(() => categories);
}
