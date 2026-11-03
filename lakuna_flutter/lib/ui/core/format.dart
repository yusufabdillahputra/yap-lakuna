import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

/// Uang sesuai bahasa aplikasi: `Rp 12.500` (id) atau `IDR 12,500` (en).
String formatMoney(BuildContext context, Money money) =>
    Localizations.localeOf(context).languageCode == 'en'
    ? money.formatEn()
    : money.formatIdr();

/// Jam `HH.mm` di zona waktu cabang ([timezone] ID IANA dari
/// [setupTimezones]); zona tak dikenal memakai waktu lokal perangkat.
String formatClock(DateTime time, String? timezone) {
  final zone = setupTimezones.where((z) => z.id == timezone).firstOrNull;
  final local = zone == null
      ? time.toLocal()
      : time.toUtc().add(Duration(hours: zone.utcOffsetHours));
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.hour)}.${two(local.minute)}';
}

/// Field nominal rupiah: hanya angka, dikelompokkan dengan titik saat
/// diketik (`200000` → `200.000`). Kursor tetap di akhir.
class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter();

  /// Batas digit agar tidak meluap `int` (≤ Rp 999 triliun).
  static const maxDigits = 15;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    digits = digits.replaceFirst(RegExp('^0+(?=[0-9])'), '');
    final text = digits.isEmpty ? '' : groupThousands(int.parse(digits), '.');
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
