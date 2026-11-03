import 'package:lakuna_client/lakuna_client.dart';
import 'package:serverpod_database/serverpod_database.dart' hide Protocol;

/// Preferensi lokal perangkat (tidak disinkronkan), mis. tema dan bahasa
/// sebelum ada login staf.
class LocalPreferences {
  LocalPreferences(this._session);

  final DatabaseSession _session;

  Future<String?> get(String key) async {
    final row = await LocalPreference.db.findFirstRow(
      _session,
      where: (t) => t.key.equals(key),
    );
    return row?.value;
  }

  Future<void> set(String key, String value) async {
    await _session.db.transaction((tx) async {
      final row = await LocalPreference.db.findFirstRow(
        _session,
        where: (t) => t.key.equals(key),
        transaction: tx,
      );
      if (row == null) {
        await LocalPreference.db.insertRow(
          _session,
          LocalPreference(key: key, value: value),
          transaction: tx,
        );
      } else {
        await LocalPreference.db.updateRow(
          _session,
          row.copyWith(value: value),
          transaction: tx,
        );
      }
    });
  }
}
