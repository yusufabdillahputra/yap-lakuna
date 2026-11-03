/// Jenis usaha yang dipilih saat setup (sama dengan enum `BusinessType` di
/// model Serverpod; paket ini tidak boleh meng-import Serverpod).
enum BusinessKind { retail, fnb, mixed }

/// Zona waktu Indonesia yang bisa dipilih saat setup.
class SetupTimezone {
  const SetupTimezone(this.id, this.label, this.utcOffsetHours);

  /// ID IANA, mis. `Asia/Jakarta`.
  final String id;

  /// Label singkat: WIB, WITA, WIT.
  final String label;
  final int utcOffsetHours;
}

const setupTimezones = [
  SetupTimezone('Asia/Jakarta', 'WIB', 7),
  SetupTimezone('Asia/Makassar', 'WITA', 8),
  SetupTimezone('Asia/Jayapura', 'WIT', 9),
];

/// Jam dinding cabang untuk [time] di zona [timezone] (ID dari
/// [setupTimezones]); zona tak dikenal memakai waktu lokal perangkat. Hasil
/// berupa `DateTime` UTC yang angkanya = jam dinding (hanya untuk tampilan
/// dan tanggal nota).
DateTime outletLocalTime(DateTime time, String? timezone) {
  final zone = setupTimezones.where((z) => z.id == timezone).firstOrNull;
  return zone == null
      ? time.toLocal()
      : time.toUtc().add(Duration(hours: zone.utcOffsetHours));
}

/// Field wizard setup, dikelompokkan per langkah.
enum SetupField {
  businessName,
  outletName,
  outletCode,
  deviceCode,
  timezone,
  ownerName,
  email,
  password,
  passwordConfirm,
  pin,
  pinConfirm;

  /// Field langkah "Jenis usaha & cabang".
  static const businessStep = [
    businessName,
    outletName,
    outletCode,
    deviceCode,
    timezone,
  ];

  /// Field langkah "Akun pemilik & PIN".
  static const ownerStep = [
    ownerName,
    email,
    password,
    passwordConfirm,
    pin,
    pinConfirm,
  ];
}

enum SetupError {
  required,
  tooLong,
  invalidCode,
  invalidEmail,
  passwordTooShort,
  passwordMismatch,
  invalidPin,
  pinMismatch,
  invalidTimezone,
}

/// Panjang maksimal nama usaha, cabang, dan pemilik.
const setupNameMaxLength = 60;

/// Panjang minimal kata sandi pemilik.
const passwordMinLength = 8;

final _code = RegExp(r'^[A-Z0-9]{2,6}$');
final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
final _pin = RegExp(r'^[0-9]{6}$');

/// Kode cabang/perangkat dinormalkan: dipangkas dan huruf besar.
String normalizeCode(String raw) => raw.trim().toUpperCase();

/// Data wizard setup toko pertama. Teks dinormalkan saat dibuat; [validate]
/// memeriksa aturan F1-01.
class SetupInput {
  SetupInput({
    required this.businessType,
    required String businessName,
    required String outletName,
    required String outletCode,
    required String deviceCode,
    required this.timezone,
    required String ownerName,
    required String email,
    required this.password,
    required this.passwordConfirm,
    required this.pin,
    required this.pinConfirm,
  }) : businessName = businessName.trim(),
       outletName = outletName.trim(),
       outletCode = normalizeCode(outletCode),
       deviceCode = normalizeCode(deviceCode),
       ownerName = ownerName.trim(),
       email = email.trim().toLowerCase();

  final BusinessKind businessType;
  final String businessName;
  final String outletName;
  final String outletCode;
  final String deviceCode;
  final String timezone;
  final String ownerName;
  final String email;
  final String password;
  final String passwordConfirm;
  final String pin;
  final String pinConfirm;

  /// Galat per field. Kosong bila valid. [fields] membatasi pemeriksaan ke
  /// field satu langkah wizard.
  Map<SetupField, SetupError> validate({
    Iterable<SetupField> fields = SetupField.values,
  }) {
    final errors = <SetupField, SetupError>{};
    for (final field in fields) {
      final error = _check(field);
      if (error != null) errors[field] = error;
    }
    return errors;
  }

  SetupError? _check(SetupField field) => switch (field) {
    SetupField.businessName => _name(businessName),
    SetupField.outletName => _name(outletName),
    SetupField.ownerName => _name(ownerName),
    SetupField.outletCode =>
      _code.hasMatch(outletCode) ? null : SetupError.invalidCode,
    SetupField.deviceCode =>
      _code.hasMatch(deviceCode) ? null : SetupError.invalidCode,
    SetupField.timezone =>
      setupTimezones.any((z) => z.id == timezone)
          ? null
          : SetupError.invalidTimezone,
    SetupField.email =>
      email.isEmpty
          ? SetupError.required
          : (_email.hasMatch(email) ? null : SetupError.invalidEmail),
    SetupField.password =>
      password.length < passwordMinLength ? SetupError.passwordTooShort : null,
    SetupField.passwordConfirm => _retype(
      passwordConfirm,
      password,
      SetupError.passwordMismatch,
    ),
    SetupField.pin => _pin.hasMatch(pin) ? null : SetupError.invalidPin,
    SetupField.pinConfirm => _retype(pinConfirm, pin, SetupError.pinMismatch),
  };

  /// Kolom ulangi: kosong → [SetupError.required], beda → [mismatch].
  static SetupError? _retype(
    String retype,
    String source,
    SetupError mismatch,
  ) {
    if (retype.isEmpty) return SetupError.required;
    return retype == source ? null : mismatch;
  }

  static SetupError? _name(String value) {
    if (value.isEmpty) return SetupError.required;
    if (value.length > setupNameMaxLength) return SetupError.tooLong;
    return null;
  }
}
