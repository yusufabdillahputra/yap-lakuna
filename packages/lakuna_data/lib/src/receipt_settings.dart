import 'dart:convert';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'preferences.dart';
import 'settings_scope.dart';
import 'stock.dart';
import 'store.dart';

/// Kunci `settings.key` untuk struk per cabang (F1-06, 1.26).
const receiptSettingKey = 'receipt.settings';

/// Pengaturan › Struk & printer › struk cabang ini.
class ReceiptSettings {
  const ReceiptSettings({
    this.paper = ReceiptPaper.mm58,
    this.header,
    this.footer,
    this.autoPrint = false,
  });

  factory ReceiptSettings.fromJson(Map<String, Object?> json) {
    String? text(String key) =>
        json[key] is String ? json[key]! as String : null;
    return ReceiptSettings(
      paper:
          ReceiptPaper.values
              .where((p) => p.name == json['paper'])
              .firstOrNull ??
          ReceiptPaper.mm58,
      header: text('header'),
      footer: text('footer'),
      autoPrint: json['autoPrint'] == true,
    );
  }

  final ReceiptPaper paper;

  /// Header multi-baris; `null` = alamat dan telepon cabang.
  final String? header;

  /// Footer multi-baris; `null` = ucapan bawaan sesuai bahasa.
  final String? footer;

  /// Cetak otomatis ke printer langsung setelah bayar.
  final bool autoPrint;

  Map<String, Object?> toJson() => {
    'paper': paper.name,
    'header': header,
    'footer': footer,
    'autoPrint': autoPrint,
  };

  ReceiptSettings copyWith({
    ReceiptPaper? paper,
    String? header,
    String? footer,
    bool? autoPrint,
  }) => ReceiptSettings(
    paper: paper ?? this.paper,
    header: header ?? this.header,
    footer: footer ?? this.footer,
    autoPrint: autoPrint ?? this.autoPrint,
  );

  ReceiptSettings _normalized() => ReceiptSettings(
    paper: paper,
    header: header == null ? null : receiptTextLines(header).join('\n'),
    footer: footer == null ? null : receiptTextLines(footer).join('\n'),
    autoPrint: autoPrint,
  );
}

/// Pengaturan struk cabang beserta header bawaannya.
class ReceiptConfig {
  const ReceiptConfig({required this.settings, this.defaultHeader = ''});

  final ReceiptSettings settings;

  /// Alamat dan telepon cabang (baris terpisah), header bila belum diatur.
  final String defaultHeader;

  /// Header yang dipakai (isian atau bawaan).
  String get headerText => settings.header ?? defaultHeader;

  List<String> get headerLines => receiptTextLines(headerText);

  /// `null` = footer bawaan sesuai bahasa aplikasi.
  List<String>? get footerLines =>
      settings.footer == null ? null : receiptTextLines(settings.footer);
}

/// Isian struk tidak sah.
class ReceiptSettingsInvalid implements Exception {
  const ReceiptSettingsInvalid(this.errors);

  final Set<ReceiptSettingsError> errors;

  @override
  String toString() => 'ReceiptSettingsInvalid($errors)';
}

/// Pengaturan struk cabang [scope] (bawaan: 58 mm, header dari cabang).
Future<ReceiptConfig> loadReceiptConfig(
  LakunaStore store,
  CatalogScope scope,
) async {
  final row = await _row(store.session, null, scope);
  final outlet = await Outlet.db.findById(store.session, scope.outletId);
  return ReceiptConfig(
    settings: row == null ? const ReceiptSettings() : _decode(row),
    defaultHeader: [
      outlet?.address?.trim(),
      outlet?.phone?.trim(),
    ].whereType<String>().where((s) => s.isNotEmpty).join('\n'),
  );
}

/// Menyimpan pengaturan struk cabang [scope]. Gagal dengan
/// [ReceiptSettingsInvalid] tanpa menulis apa pun.
Future<ReceiptConfig> saveReceiptSettings(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required ReceiptSettings settings,
}) async {
  final errors = validateReceiptSettings(
    header: settings.header,
    footer: settings.footer,
  );
  if (errors.isNotEmpty) throw ReceiptSettingsInvalid(errors);
  final value = jsonEncode(settings._normalized().toJson());
  await store.write(actor: staffId, (w) async {
    final current = await _row(w.session, w.transaction, scope);
    final s = await w.stamp();
    if (current == null) {
      await w.insert(
        Setting(
          tenantId: scope.tenantId,
          outletId: scope.outletId,
          scopeKey: settingScopeOutlet(scope.outletId),
          key: receiptSettingKey,
          valueJson: value,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: staffId,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    } else {
      await w.update(
        current.copyWith(
          valueJson: value,
          version: current.version + 1,
          updatedAt: s.now,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
  });
  return loadReceiptConfig(store, scope);
}

ReceiptSettings _decode(Setting row) {
  try {
    final json = jsonDecode(row.valueJson);
    return json is Map<String, Object?>
        ? ReceiptSettings.fromJson(json)
        : const ReceiptSettings();
  } on FormatException {
    return const ReceiptSettings();
  }
}

Future<Setting?> _row(
  DatabaseSession session,
  Transaction? transaction,
  CatalogScope scope,
) => Setting.db.findFirstRow(
  session,
  where: (t) =>
      t.tenantId.equals(scope.tenantId) &
      t.scopeKey.equals(settingScopeOutlet(scope.outletId)) &
      t.key.equals(receiptSettingKey) &
      t.deletedAt.equals(null),
  transaction: transaction,
);

// --- Printer perangkat (preferensi lokal, tidak disinkronkan) ---

/// Kunci preferensi lokal printer terpilih di perangkat ini.
const printerSelectionKey = 'printer.selected';

/// Port printer jaringan ESC/POS bawaan (raw / JetDirect).
const defaultPrinterPort = 9100;

enum PrinterKind {
  /// Bluetooth klasik (SPP), Android.
  bluetooth,

  /// Soket TCP ke printer jaringan (LAN/Wi-Fi).
  network,

  /// PDF ke dialog cetak sistem operasi.
  system,
}

/// Printer yang dipilih di perangkat ini.
class PrinterSelection {
  const PrinterSelection({
    required this.kind,
    required this.name,
    this.address = '',
  });

  final PrinterKind kind;
  final String name;

  /// MAC Bluetooth, atau `host:port` untuk jaringan; kosong untuk sistem.
  final String address;

  /// Cetak langsung byte ESC/POS (bukan lewat dialog).
  bool get isDirect => kind != PrinterKind.system;

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'name': name,
    'address': address,
  };

  static PrinterSelection? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final kind = PrinterKind.values
        .where((k) => k.name == json['kind'])
        .firstOrNull;
    final name = json['name'];
    final address = json['address'];
    if (kind == null || name is! String) return null;
    return PrinterSelection(
      kind: kind,
      name: name,
      address: address is String ? address : '',
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PrinterSelection &&
      other.kind == kind &&
      other.name == name &&
      other.address == address;

  @override
  int get hashCode => Object.hash(kind, name, address);

  @override
  String toString() => 'PrinterSelection($kind, $name, $address)';
}

Future<PrinterSelection?> loadPrinterSelection(LocalPreferences prefs) async {
  final raw = await prefs.get(printerSelectionKey);
  if (raw == null || raw.isEmpty) return null;
  try {
    return PrinterSelection.fromJson(jsonDecode(raw));
  } on FormatException {
    return null;
  }
}

/// Menyimpan printer [printer]; `null` melupakan printer.
Future<void> savePrinterSelection(
  LocalPreferences prefs,
  PrinterSelection? printer,
) => prefs.set(
  printerSelectionKey,
  printer == null ? '' : jsonEncode(printer.toJson()),
);

final _hostPattern = RegExp(r'^[A-Za-z0-9.\-]+$');

/// `host[:port]` → (host, port); port bawaan [defaultPrinterPort]. `null`
/// bila tidak sah.
(String, int)? parseNetworkAddress(String text) {
  final t = text.trim();
  if (t.isEmpty) return null;
  final i = t.lastIndexOf(':');
  final host = i < 0 ? t : t.substring(0, i);
  final port = i < 0 ? defaultPrinterPort : int.tryParse(t.substring(i + 1));
  if (port == null || port < 1 || port > 65535) return null;
  if (!_hostPattern.hasMatch(host)) return null;
  return (host, port);
}
