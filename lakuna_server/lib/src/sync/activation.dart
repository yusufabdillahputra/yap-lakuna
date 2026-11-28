/// Kode aktivasi dari admin server (F2-01 *Pengoperasian server*).
library;

import 'package:lakuna_domain/lakuna_domain.dart' show newShortCode, secretHash;
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Panjang kode aktivasi dan kode pasang.
const shortCodeLength = 8;

/// HLC untuk baris yang dibuat server sebelum data perangkat diunggah:
/// paling kecil, jadi baris dari perangkat selalu menang.
const serverSeedHlc = '0000000000000-0000-server';

/// Membuat kode aktivasi sekali pakai yang berlaku [days] hari dan
/// mengembalikan kodenya (hanya ditampilkan sekali; server menyimpan
/// hash-nya).
Future<String> createActivationCode(
  Session session, {
  required String note,
  int days = 30,
  DateTime? now,
}) async {
  final created = (now ?? DateTime.now()).toUtc();
  final code = newShortCode(shortCodeLength);
  await ActivationCode.db.insertRow(
    session,
    ActivationCode(
      codeHash: secretHash(code),
      note: note.trim(),
      createdAt: created,
      expiresAt: created.add(Duration(days: days)),
    ),
  );
  return code;
}
