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
  final local = outletLocalTime(time, timezone);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.hour)}.${two(local.minute)}';
}

/// Tanggal dan jam `dd/MM HH.mm` di zona waktu cabang, untuk daftar yang
/// mencakup lebih dari satu hari.
String formatDayClock(DateTime time, String? timezone) {
  final local = outletLocalTime(time, timezone);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)} ${formatClock(time, timezone)}';
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

/// Field tambahan harga yang boleh negatif (`-3.000` = potongan). Tanda
/// minus hanya di depan; maksimal 9 digit.
class SignedRupiahInputFormatter extends TextInputFormatter {
  const SignedRupiahInputFormatter();

  static const maxDigits = 9;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final negative = newValue.text.trimLeft().startsWith('-');
    var digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    digits = digits.replaceFirst(RegExp('^0+(?=[0-9])'), '');
    final grouped = digits.isEmpty
        ? ''
        : groupThousands(int.parse(digits), '.');
    final text = '${negative ? '-' : ''}$grouped';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Nilai dari [SignedRupiahInputFormatter]; kosong atau `-` = nol.
Money parseSignedRupiah(String text) {
  final digits = text.replaceAll(RegExp('[^0-9]'), '');
  if (digits.isEmpty) return Money.zero;
  final value = int.parse(digits);
  return Money(text.trimLeft().startsWith('-') ? -value : value);
}

bool _isEnglish(BuildContext context) =>
    Localizations.localeOf(context).languageCode == 'en';

/// Pemisah desimal jumlah barang sesuai bahasa: `,` (id) atau `.` (en).
String qtyDecimalSeparator(BuildContext context) =>
    _isEnglish(context) ? '.' : ',';

/// Jumlah barang sesuai bahasa: `12,5` / `1.250` (id) atau `12.5` / `1,250`
/// (en). [grouped] `false` untuk isi awal field (tanpa pemisah ribuan).
String formatQty(BuildContext context, Qty qty, {bool grouped = true}) {
  final en = _isEnglish(context);
  return qty.format(
    decimal: en ? '.' : ',',
    group: grouped ? (en ? ',' : '.') : '',
  );
}

/// Membaca jumlah dari field (tanpa pemisah ribuan). Kosong → nol;
/// tidak sah → `null`.
Qty? parseQtyInput(BuildContext context, String text) {
  if (text.trim().isEmpty) return Qty.zero;
  return Qty.tryParse(text, decimal: qtyDecimalSeparator(context), group: '');
}

/// Field jumlah barang: hanya angka dan satu pemisah desimal [decimal],
/// paling banyak tiga desimal dan 12 digit bulat. Input lain ditolak
/// (nilai lama dipertahankan).
class QtyInputFormatter extends TextInputFormatter {
  const QtyInputFormatter({this.decimal = ','});

  final String decimal;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = RegExp.escape(decimal);
    final ok = RegExp('^\\d{0,12}(?:$d\\d{0,3})?\$').hasMatch(newValue.text);
    return ok ? newValue : oldValue;
  }
}
