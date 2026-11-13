import 'dart:convert';
import 'dart:typed_data';

import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:serverpod_database/serverpod_database.dart'
    show DatabaseSession, Transaction;

import 'media.dart';
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
    this.logoMediaId,
    this.showLogo = false,
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
      logoMediaId: switch (json['logoMediaId']) {
        final String id => UuidValue.fromString(id),
        _ => null,
      },
      showLogo: json['showLogo'] == true,
    );
  }

  final ReceiptPaper paper;

  /// Header multi-baris; `null` = alamat dan telepon cabang.
  final String? header;

  /// Footer multi-baris; `null` = ucapan bawaan sesuai bahasa.
  final String? footer;

  /// Cetak otomatis ke printer langsung setelah bayar.
  final bool autoPrint;

  /// Logo struk di `media_files` (F1-06b); diatur lewat
  /// [saveReceiptSettings], bukan [copyWith].
  final UuidValue? logoMediaId;

  /// *Tampilkan logo di struk*; selalu `false` tanpa logo.
  final bool showLogo;

  Map<String, Object?> toJson() => {
    'paper': paper.name,
    'header': header,
    'footer': footer,
    'autoPrint': autoPrint,
    'logoMediaId': logoMediaId?.uuid,
    'showLogo': showLogo,
  };

  ReceiptSettings copyWith({
    ReceiptPaper? paper,
    String? header,
    String? footer,
    bool? autoPrint,
    bool? showLogo,
  }) => ReceiptSettings(
    paper: paper ?? this.paper,
    header: header ?? this.header,
    footer: footer ?? this.footer,
    autoPrint: autoPrint ?? this.autoPrint,
    logoMediaId: logoMediaId,
    showLogo: showLogo ?? this.showLogo,
  );

  ReceiptSettings _normalized(UuidValue? logo, {required bool showLogo}) =>
      ReceiptSettings(
        paper: paper,
        header: header == null ? null : receiptTextLines(header).join('\n'),
        footer: footer == null ? null : receiptTextLines(footer).join('\n'),
        autoPrint: autoPrint,
        logoMediaId: logo,
        showLogo: logo != null && showLogo,
      );
}

/// Pengaturan struk cabang beserta header bawaannya.
class ReceiptConfig {
  const ReceiptConfig({
    required this.settings,
    this.defaultHeader = '',
    this.logoImage,
  });

  final ReceiptSettings settings;

  /// Berkas logo struk (F1-06b); `null` bila belum ada atau berkasnya belum
  /// ada di perangkat ini. Untuk pratinjau di pengaturan.
  final Uint8List? logoImage;

  /// Logo yang dicetak: hanya bila *Tampilkan logo* aktif.
  Uint8List? get logoBytes => settings.showLogo ? logoImage : null;

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
  final settings = row == null ? const ReceiptSettings() : _decode(row);
  final logo = await _logo(store.session, null, scope, settings.logoMediaId);
  return ReceiptConfig(
    settings: settings,
    logoImage: logo == null ? null : await readMediaFile(store, logo),
    defaultHeader: [
      outlet?.address?.trim(),
      outlet?.phone?.trim(),
    ].whereType<String>().where((s) => s.isNotEmpty).join('\n'),
  );
}

/// Logo struk baru yang dipilih pemilik (F1-06b).
class ReceiptLogoUpload {
  const ReceiptLogoUpload({required this.bytes, required this.fileName});

  final Uint8List bytes;
  final String fileName;
}

/// Berkas logo ditolak (format atau ukuran).
class ReceiptLogoInvalid implements Exception {
  const ReceiptLogoInvalid(this.error);

  final ReceiptLogoError error;

  @override
  String toString() => 'ReceiptLogoInvalid($error)';
}

/// Menyimpan pengaturan struk cabang [scope]. [logo] baru menggantikan logo
/// lama dan menyalakan *Tampilkan logo*; [removeLogo] melepas logo. Tanpa
/// keduanya logo lama tetap. Gagal dengan [ReceiptSettingsInvalid] atau
/// [ReceiptLogoInvalid] tanpa menulis apa pun.
Future<ReceiptConfig> saveReceiptSettings(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required ReceiptSettings settings,
  ReceiptLogoUpload? logo,
  bool removeLogo = false,
}) async {
  final errors = validateReceiptSettings(
    header: settings.header,
    footer: settings.footer,
  );
  if (errors.isNotEmpty) throw ReceiptSettingsInvalid(errors);
  ImageHeader? header;
  if (logo != null) {
    if (checkReceiptLogo(logo.bytes) case final error?) {
      throw ReceiptLogoInvalid(error);
    }
    header = readImageHeader(logo.bytes);
  }
  await store.write(actor: staffId, (w) async {
    final current = await _row(w.session, w.transaction, scope);
    final previous = current == null ? null : _decode(current);
    final s = await w.stamp();
    // Id lama dipertahankan walau barisnya belum ada di perangkat ini
    // (mis. belum tersinkron); berkas yang hilang dilewati saat dibaca.
    var logoId = removeLogo ? null : previous?.logoMediaId;
    if (logo != null) {
      final media = await storeMediaFile(
        w,
        store,
        scope,
        bytes: logo.bytes,
        header: header!,
        fileName: logo.fileName,
        kind: MediaKind.receiptLogo,
        outletId: scope.outletId,
        stamp: s,
      );
      logoId = media.id;
    }
    final value = jsonEncode(
      settings._normalized(logoId, showLogo: settings.showLogo).toJson(),
    );
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

/// Baris media logo struk milik cabang [scope]; `null` bila tidak ada.
Future<MediaFile?> _logo(
  DatabaseSession session,
  Transaction? transaction,
  CatalogScope scope,
  UuidValue? id,
) async {
  if (id == null) return null;
  return MediaFile.db.findFirstRow(
    session,
    where: (t) =>
        t.id.equals(id) &
        t.tenantId.equals(scope.tenantId) &
        t.outletId.equals(scope.outletId) &
        t.kind.equals(MediaKind.receiptLogo) &
        t.deletedAt.equals(null),
    transaction: transaction,
  );
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

/// Kunci preferensi lokal printer dapur di perangkat ini (F1-10e).
const kitchenPrinterKey = 'printer.kitchen';

/// Printer dapur khusus: tiket dapur dicetak otomatis ke sini saat
/// *Kirim ke dapur*. Hanya jaringan atau Bluetooth (cetak langsung).
class KitchenPrinter {
  const KitchenPrinter({required this.printer, this.paper = ReceiptPaper.mm58});

  final PrinterSelection printer;

  /// Lebar kertas tiket dapur, terpisah dari struk.
  final ReceiptPaper paper;

  KitchenPrinter copyWith({PrinterSelection? printer, ReceiptPaper? paper}) =>
      KitchenPrinter(
        printer: printer ?? this.printer,
        paper: paper ?? this.paper,
      );

  @override
  bool operator ==(Object other) =>
      other is KitchenPrinter &&
      other.printer == printer &&
      other.paper == paper;

  @override
  int get hashCode => Object.hash(printer, paper);

  @override
  String toString() => 'KitchenPrinter($printer, $paper)';
}

/// Printer dapur perangkat ini; `null` = sama dengan printer struk.
Future<KitchenPrinter?> loadKitchenPrinter(LocalPreferences prefs) async {
  final raw = await prefs.get(kitchenPrinterKey);
  if (raw == null || raw.isEmpty) return null;
  try {
    final json = jsonDecode(raw);
    final printer = PrinterSelection.fromJson(json);
    if (printer == null || !printer.isDirect || printer.address.isEmpty) {
      return null;
    }
    final paper = ReceiptPaper.values
        .where((p) => p.name == (json as Map<String, Object?>)['paper'])
        .firstOrNull;
    return KitchenPrinter(printer: printer, paper: paper ?? ReceiptPaper.mm58);
  } on FormatException {
    return null;
  }
}

/// Menyimpan printer dapur; `null` kembali ke printer struk.
Future<void> saveKitchenPrinter(
  LocalPreferences prefs,
  KitchenPrinter? kitchen,
) => prefs.set(
  kitchenPrinterKey,
  kitchen == null
      ? ''
      : jsonEncode({...kitchen.printer.toJson(), 'paper': kitchen.paper.name}),
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
