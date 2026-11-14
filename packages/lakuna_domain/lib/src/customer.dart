import 'package:characters/characters.dart';

import 'money.dart';

/// Batas isian pelanggan dan grup (F1-13), dihitung per karakter.
abstract final class CustomerLimits {
  static const name = 80;
  static const address = 160;
  static const note = 200;
  static const groupName = 40;
  static const phoneMinDigits = 8;
  static const phoneMaxDigits = 15;
  static const maxTermDays = 365;

  /// Tempo standar tanpa grup.
  static const defaultTermDays = 14;
}

/// Nomor HP dinormalisasi: hanya digit, awalan `62` (dari `+62`) → `0`.
/// Kosong bila tidak ada digit.
String normalizePhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('62')) return '0${digits.substring(2)}';
  // Nomor seluler dari sel angka Excel kehilangan nol depan (`813…`).
  if (digits.startsWith('8')) return '0$digits';
  return digits;
}

/// Digit minimum agar kata kunci dicocokkan dengan nomor HP (F1-13d).
const phoneQueryMinDigits = 3;

final _phoneQueryPattern = RegExp(r'^[\d\s+\-().]+$');

/// Tanda arah tak terlihat yang ikut tersalin dari WhatsApp / kontak
/// Android (U+200E/F, U+202A–E, U+2066–9, U+FEFF).
final _invisibleMarks = RegExp(
  '[\u200E\u200F\u202A-\u202E\u2066-\u2069\uFEFF]',
);

/// Tanda hubung Unicode (U+2010–2015, minus U+2212) dan spasi tak putus.
final _unicodeDashes = RegExp('[\u2010-\u2015\u2212]');

/// Kunci pencarian HP dari kata kunci [raw] (F1-13d), dicocokkan secara
/// "memuat" dengan nomor HP tersimpan (sudah dinormalisasi, `08…`).
///
/// Kosong bila [raw] berisi selain digit, spasi, `+ - ( ) .` (tanda arah
/// tak terlihat dibuang, tanda hubung Unicode dianggap `-`) atau digitnya
/// kurang dari [phoneQueryMinDigits]. Nomor internasional Indonesia
/// (`+62…`, atau `62…` minimal 10 digit) menjadi satu kunci dengan awalan
/// `62` diganti `0`; selain itu kunci = digit apa adanya (cocok untuk
/// potongan di tengah). `62` di tengah nomor tidak diubah.
List<String> phoneSearchKeys(String raw) {
  final q = raw
      .replaceAll(_invisibleMarks, '')
      .replaceAll(_unicodeDashes, '-')
      .replaceAll('\u00A0', ' ')
      .trim();
  if (!_phoneQueryPattern.hasMatch(q)) return const [];
  final digits = q.replaceAll(RegExp(r'\D'), '');
  if (digits.length < phoneQueryMinDigits) return const [];
  final international =
      digits.startsWith('62') && (q.startsWith('+') || digits.length >= 10);
  if (!international) return [digits];
  // HP tersimpan selalu `0…`, jadi kunci `62…` hanya cocok di tengah nomor
  // (hasil palsu); pakai kunci lokal saja.
  final local = '0${digits.substring(2)}';
  return local.length >= phoneQueryMinDigits ? [local] : const [];
}

/// [phone] tersimpan cocok dengan kata kunci [raw] (lihat [phoneSearchKeys]).
bool phoneMatchesQuery(String? phone, String raw) {
  if (phone == null || phone.isEmpty) return false;
  return phoneSearchKeys(raw).any(phone.contains);
}

enum CustomerIssue { name, phone, address, note, group, creditLimit }

int _len(String? s) => (s ?? '').trim().characters.length;

/// Galat isian pelanggan. [phone] mentah (dinormalisasi di sini).
Set<CustomerIssue> validateCustomer({
  required String name,
  String? phone,
  String? address,
  String? note,
  String? groupName,
  Money creditLimit = Money.zero,
}) {
  final digits = normalizePhone(phone ?? '').length;
  return {
    if (_len(name) == 0 || _len(name) > CustomerLimits.name) CustomerIssue.name,
    if (digits > 0 &&
        (digits < CustomerLimits.phoneMinDigits ||
            digits > CustomerLimits.phoneMaxDigits))
      CustomerIssue.phone,
    if (_len(address) > CustomerLimits.address) CustomerIssue.address,
    if (_len(note) > CustomerLimits.note) CustomerIssue.note,
    if (_len(groupName) > CustomerLimits.groupName) CustomerIssue.group,
    if (creditLimit.isNegative) CustomerIssue.creditLimit,
  };
}

enum CustomerGroupIssue { name, termDays }

/// Galat isian grup pelanggan.
Set<CustomerGroupIssue> validateCustomerGroup({
  required String name,
  required int termDays,
}) => {
  if (_len(name) == 0 || _len(name) > CustomerLimits.groupName)
    CustomerGroupIssue.name,
  if (termDays < 0 || termDays > CustomerLimits.maxTermDays)
    CustomerGroupIssue.termDays,
};
