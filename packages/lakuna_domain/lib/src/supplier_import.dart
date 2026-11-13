import 'customer.dart' show normalizePhone;
import 'supplier.dart';

// Import supplier dari CSV/XLSX (F1-14b). Pembacaan berkas ada di aplikasi
// (`parseCsv` / pembaca XLSX); di sini hanya tabel sel → baris supplier.

/// Alasan baris import supplier dilewati.
enum SupplierImportRejectReason { name, phone, termDays, text, duplicateName }

/// Baris supplier sah dari berkas. Kolom kosong = `null` (data lama
/// dipertahankan saat memperbarui supplier dengan nama yang sama).
class SupplierImportRow {
  const SupplierImportRow({
    required this.line,
    required this.name,
    this.contactName,
    this.phone,
    this.category,
    this.termDays,
    this.address,
    this.note,
  });

  /// Nomor baris di berkas (1 = baris judul).
  final int line;

  /// Sudah dipangkas.
  final String name;
  final String? contactName;

  /// Sudah dinormalisasi.
  final String? phone;
  final String? category;
  final int? termDays;
  final String? address;
  final String? note;
}

class SupplierImportRejected {
  const SupplierImportRejected(this.line, this.reason);

  final int line;
  final SupplierImportRejectReason reason;
}

class SupplierImportResult {
  const SupplierImportResult({
    this.rows = const [],
    this.rejected = const [],
    this.missingName = false,
  });

  final List<SupplierImportRow> rows;
  final List<SupplierImportRejected> rejected;

  /// Baris judul tidak punya kolom nama: seluruh berkas ditolak.
  final bool missingName;
}

const _columns = {
  'nama': 'name',
  'name': 'name',
  'nama supplier': 'name',
  'supplier': 'name',
  'kontak': 'contact',
  'contact': 'contact',
  'nama kontak': 'contact',
  'contact name': 'contact',
  'telepon': 'phone',
  'hp': 'phone',
  'no hp': 'phone',
  'no. hp': 'phone',
  'phone': 'phone',
  'telp': 'phone',
  'telp.': 'phone',
  'no telp': 'phone',
  'no. telp': 'phone',
  'no telepon': 'phone',
  'no. telepon': 'phone',
  'nomor hp': 'phone',
  'nomor telepon': 'phone',
  'whatsapp': 'phone',
  'wa': 'phone',
  'kategori': 'category',
  'category': 'category',
  'tempo': 'term',
  'tempo (hari)': 'term',
  'term': 'term',
  'term days': 'term',
  'term (days)': 'term',
  'alamat': 'address',
  'address': 'address',
  'catatan': 'note',
  'note': 'note',
};

/// Tempo pembayaran dari sel import: bilangan bulat hari 0–365, boleh
/// diikuti `hari`/`days` atau desimal nol (`14.0`). Selain itu `null`.
int? parseImportTermDays(String text) {
  final m = RegExp(
    r'^(\d+)(?:[.,]0+)?\s*(?:hari|days?)?$',
    caseSensitive: false,
  ).firstMatch(text.trim());
  if (m == null) return null;
  final days = int.tryParse(m.group(1)!);
  if (days == null || days > SupplierLimits.maxTermDays) return null;
  return days;
}

/// Baris tabel (baris pertama = judul) → supplier sah + baris ditolak.
SupplierImportResult supplierImportRows(List<List<String>> table) {
  if (table.isEmpty) return const SupplierImportResult(missingName: true);
  final index = <String, int>{};
  for (var i = 0; i < table.first.length; i++) {
    final key = _columns[table.first[i].trim().toLowerCase()];
    if (key != null) index.putIfAbsent(key, () => i);
  }
  if (!index.containsKey('name')) {
    return const SupplierImportResult(missingName: true);
  }
  final rows = <SupplierImportRow>[];
  final rejected = <SupplierImportRejected>[];
  final names = <String>{};
  for (var r = 1; r < table.length; r++) {
    final cells = table[r];
    final line = r + 1;
    if (cells.every((c) => c.trim().isEmpty)) continue;
    String? cell(String key) {
      final i = index[key];
      if (i == null || i >= cells.length) return null;
      final v = cells[i].trim();
      return v.isEmpty ? null : v;
    }

    final name = cell('name') ?? '';
    final phoneRaw = cell('phone');
    final phone = phoneRaw == null ? null : normalizePhone(phoneRaw);
    final termRaw = cell('term');
    final termDays = termRaw == null ? null : parseImportTermDays(termRaw);
    final issues = validateSupplier(
      name: name,
      termDays: termDays ?? SupplierLimits.defaultTermDays,
      phone: phoneRaw,
      contactName: cell('contact'),
      category: cell('category'),
      address: cell('address'),
      note: cell('note'),
    );
    final key = name.toLowerCase();
    final reason = issues.contains(SupplierIssue.name)
        ? SupplierImportRejectReason.name
        : issues.contains(SupplierIssue.phone) ||
              (phoneRaw != null && phone!.isEmpty)
        ? SupplierImportRejectReason.phone
        : termRaw != null && termDays == null
        ? SupplierImportRejectReason.termDays
        : issues.isNotEmpty
        ? SupplierImportRejectReason.text
        : names.contains(key)
        ? SupplierImportRejectReason.duplicateName
        : null;
    if (reason != null) {
      rejected.add(SupplierImportRejected(line, reason));
      continue;
    }
    names.add(key);
    rows.add(
      SupplierImportRow(
        line: line,
        name: name,
        contactName: cell('contact'),
        phone: phone,
        category: cell('category'),
        termDays: termDays,
        address: cell('address'),
        note: cell('note'),
      ),
    );
  }
  return SupplierImportResult(rows: rows, rejected: rejected);
}
