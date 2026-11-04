import 'customer.dart';
import 'money.dart';

// Import pelanggan dari CSV/XLSX (F1-13). Pembacaan berkas ada di aplikasi;
// di sini hanya tabel sel → baris pelanggan.

/// Mengurai CSV (pemisah koma atau titik koma, dideteksi dari baris judul).
/// Mendukung kutip ganda, `""` di dalam kutip, dan baris baru di dalam
/// kutip. Baris kosong dilewati.
List<List<String>> parseCsv(String text) {
  var src = text.startsWith('﻿') ? text.substring(1) : text;
  src = src.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final firstLine = src.split('\n').first;
  final sep =
      ';'.allMatches(firstLine).length > ','.allMatches(firstLine).length
      ? ';'
      : ',';
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var quoted = false;
  void endCell() {
    row.add(cell.toString());
    cell.clear();
  }

  void endRow() {
    endCell();
    if (row.any((c) => c.trim().isNotEmpty)) rows.add(row);
    row = <String>[];
  }

  for (var i = 0; i < src.length; i++) {
    final ch = src[i];
    if (quoted) {
      if (ch == '"') {
        if (i + 1 < src.length && src[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        cell.write(ch);
      }
    } else if (ch == '"') {
      quoted = true;
    } else if (ch == sep) {
      endCell();
    } else if (ch == '\n') {
      endRow();
    } else {
      cell.write(ch);
    }
  }
  if (cell.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}

/// Alasan baris import dilewati.
enum ImportRejectReason { name, phone, creditLimit, text, duplicatePhone }

/// Baris pelanggan sah dari berkas. Kolom kosong = `null` (data lama
/// dipertahankan saat memperbarui pelanggan dengan HP yang sama).
class CustomerImportRow {
  const CustomerImportRow({
    required this.line,
    required this.name,
    this.phone,
    this.address,
    this.groupName,
    this.creditLimit,
    this.note,
  });

  /// Nomor baris di berkas (1 = baris judul).
  final int line;
  final String name;

  /// Sudah dinormalisasi.
  final String? phone;
  final String? address;
  final String? groupName;
  final Money? creditLimit;
  final String? note;
}

class ImportRejected {
  const ImportRejected(this.line, this.reason);

  final int line;
  final ImportRejectReason reason;
}

class CustomerImportResult {
  const CustomerImportResult({
    this.rows = const [],
    this.rejected = const [],
    this.missingName = false,
  });

  final List<CustomerImportRow> rows;
  final List<ImportRejected> rejected;

  /// Baris judul tidak punya kolom nama: seluruh berkas ditolak.
  final bool missingName;
}

const _columns = {
  'nama': 'name',
  'name': 'name',
  'hp': 'phone',
  'no hp': 'phone',
  'no. hp': 'phone',
  'telepon': 'phone',
  'phone': 'phone',
  'alamat': 'address',
  'address': 'address',
  'grup': 'group',
  'group': 'group',
  'limit': 'limit',
  'limit kredit': 'limit',
  'credit_limit': 'limit',
  'credit limit': 'limit',
  'catatan': 'note',
  'note': 'note',
};

/// Baris tabel (baris pertama = judul) → pelanggan sah + baris ditolak.
CustomerImportResult customerImportRows(List<List<String>> table) {
  if (table.isEmpty) return const CustomerImportResult(missingName: true);
  final index = <String, int>{};
  for (var i = 0; i < table.first.length; i++) {
    final key = _columns[table.first[i].trim().toLowerCase()];
    if (key != null) index.putIfAbsent(key, () => i);
  }
  if (!index.containsKey('name')) {
    return const CustomerImportResult(missingName: true);
  }
  final rows = <CustomerImportRow>[];
  final rejected = <ImportRejected>[];
  final phones = <String>{};
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
    final limitRaw = cell('limit');
    Money? limit;
    if (limitRaw != null) {
      final digits = limitRaw.replaceAll(
        RegExp(r'[.\s]|^Rp', caseSensitive: false),
        '',
      );
      final parsed = int.tryParse(digits);
      if (parsed == null || parsed < 0) {
        rejected.add(ImportRejected(line, ImportRejectReason.creditLimit));
        continue;
      }
      limit = Money(parsed);
    }
    final issues = validateCustomer(
      name: name,
      phone: phoneRaw,
      address: cell('address'),
      note: cell('note'),
      groupName: cell('group'),
      creditLimit: limit ?? Money.zero,
    );
    final reason = issues.contains(CustomerIssue.name)
        ? ImportRejectReason.name
        : issues.contains(CustomerIssue.phone) ||
              (phoneRaw != null && phone!.isEmpty)
        ? ImportRejectReason.phone
        : issues.isNotEmpty
        ? ImportRejectReason.text
        : phone != null && phones.contains(phone)
        ? ImportRejectReason.duplicatePhone
        : null;
    if (reason != null) {
      rejected.add(ImportRejected(line, reason));
      continue;
    }
    if (phone != null) phones.add(phone);
    rows.add(
      CustomerImportRow(
        line: line,
        name: name,
        phone: phone,
        address: cell('address'),
        groupName: cell('group'),
        creditLimit: limit,
        note: cell('note'),
      ),
    );
  }
  return CustomerImportResult(rows: rows, rejected: rejected);
}
