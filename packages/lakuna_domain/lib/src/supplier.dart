import 'package:characters/characters.dart';

import 'customer.dart' show CustomerLimits, normalizePhone;
import 'document_number.dart';
import 'purchase.dart' show PurchaseLimits;

// Supplier & hutang (F1-14, layar 1.21). Hutang per pembelian dihitung dari
// dokumen (`purchaseDebt`), tidak pernah disimpan sebagai saldo.

/// Batas isian supplier, dalam karakter.
abstract final class SupplierLimits {
  static const name = PurchaseLimits.supplierName;
  static const contactName = 60;
  static const category = 60;
  static const address = 200;
  static const note = 500;

  /// No. bukti transfer bayar hutang.
  static const reference = 60;

  /// Catatan pembayaran hutang.
  static const paymentNote = 200;
  static const maxTermDays = 365;

  /// Tempo standar supplier baru.
  static const defaultTermDays = 14;

  /// Batas foto bukti bayar.
  static const proofMaxBytes = 5 * 1024 * 1024;
}

enum SupplierIssue {
  name,
  phone,
  contactName,
  category,
  address,
  note,
  termDays,
}

int _len(String? s) => (s ?? '').trim().characters.length;

/// Galat isian supplier. [phone] mentah (dinormalisasi di sini).
Set<SupplierIssue> validateSupplier({
  required String name,
  required int termDays,
  String? phone,
  String? contactName,
  String? category,
  String? address,
  String? note,
}) {
  final digits = normalizePhone(phone ?? '').length;
  return {
    if (_len(name) == 0 || _len(name) > SupplierLimits.name) SupplierIssue.name,
    if (digits > 0 &&
        (digits < CustomerLimits.phoneMinDigits ||
            digits > CustomerLimits.phoneMaxDigits))
      SupplierIssue.phone,
    if (_len(contactName) > SupplierLimits.contactName)
      SupplierIssue.contactName,
    if (_len(category) > SupplierLimits.category) SupplierIssue.category,
    if (_len(address) > SupplierLimits.address) SupplierIssue.address,
    if (_len(note) > SupplierLimits.note) SupplierIssue.note,
    if (termDays < 0 || termDays > SupplierLimits.maxTermDays)
      SupplierIssue.termDays,
  };
}

/// Urutan alokasi bayar hutang: jatuh tempo terdekat dulu (tanpa jatuh
/// tempo paling akhir), lalu tanggal beli, lalu nomor.
class PayableOrder implements Comparable<PayableOrder> {
  const PayableOrder({
    required this.dueOn,
    required this.purchasedOn,
    required this.number,
  });

  final DateTime? dueOn;
  final DateTime purchasedOn;
  final String number;

  @override
  int compareTo(PayableOrder other) {
    final a = dueOn;
    final b = other.dueOn;
    if (a == null && b != null) return 1;
    if (a != null && b == null) return -1;
    if (a != null && b != null) {
      final c = a.compareTo(b);
      if (c != 0) return c;
    }
    final p = purchasedOn.compareTo(other.purchasedOn);
    return p != 0 ? p : number.compareTo(other.number);
  }
}

/// `BH-PST-D01-261104-0007` (bayar hutang supplier).
String supplierPaymentNumber(
  String outletCode,
  String deviceCode,
  DateTime localDate,
  int counter,
) => documentNumber('BH', outletCode, deviceCode, localDate, counter);
