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
