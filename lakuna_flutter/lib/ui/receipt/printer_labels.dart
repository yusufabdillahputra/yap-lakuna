import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/services/receipt_printer.dart';
import '../../l10n/gen/app_localizations.dart';

String printerKindLabel(AppLocalizations l10n, PrinterKind kind) =>
    switch (kind) {
      PrinterKind.bluetooth => l10n.printerKindBluetooth,
      PrinterKind.network => l10n.printerKindNetwork,
      PrinterKind.system => l10n.printerKindSystem,
    };

/// "RPP02N · Bluetooth · 58 mm"; dialog sistem tanpa nama.
String printerSummary(
  AppLocalizations l10n,
  PrinterSelection printer,
  ReceiptPaper paper,
) => [
  if (printer.name.isNotEmpty) printer.name,
  printerKindLabel(l10n, printer.kind),
  '${paper == ReceiptPaper.mm58 ? 58 : 80} mm',
].join(' · ');

String printerFailureMessage(
  AppLocalizations l10n,
  PrinterFailureReason? reason,
) => switch (reason) {
  PrinterFailureReason.bluetoothOff => l10n.printerErrorBluetoothOff,
  PrinterFailureReason.permission => l10n.printerErrorPermission,
  PrinterFailureReason.connect => l10n.printerErrorConnect,
  PrinterFailureReason.write => l10n.printerErrorWrite,
  PrinterFailureReason.timeout => l10n.printerErrorTimeout,
  PrinterFailureReason.unsupported => l10n.printerErrorUnsupported,
  null => l10n.printerErrorGeneric,
};
