import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:lakuna_data/lakuna_data.dart' show deleteWebDatabase;
import 'package:web/web.dart' as web;

import 'web_session_store.dart';

const _activeKey = 'lakuna.web.activeDatabase';
const _staleKey = 'lakuna.web.staleDatabases';
const _pendingKey = 'lakuna.web.pendingDatabase';
const _lockName = 'lakuna.web.database';

/// Tidak pernah selesai: kunci tab dipegang selama halaman terbuka.
final _held = Completer<void>();
var _lockHeld = false;

class _LocalStorageWebSessionStore implements WebSessionStore {
  web.Storage get _storage => web.window.localStorage;

  @override
  Future<WebStartProblem?> claim() async {
    try {
      // Mode privat sebagian browser menolak OPFS atau localStorage.
      await web.window.navigator.storage.getDirectory().toDart;
      _storage.getItem(_activeKey);
    } catch (_) {
      return WebStartProblem.storageUnavailable;
    }
    if (_lockHeld) return null;
    final granted = Completer<bool>();
    try {
      web.window.navigator.locks.request(
        _lockName,
        web.LockOptions(ifAvailable: true),
        ((web.Lock? lock) {
          granted.complete(lock != null);
          return lock == null ? null : _held.future.toJS;
        }).toJS,
      );
    } catch (_) {
      // Browser tanpa Web Locks: tetap jalan, seperti satu tab.
      return null;
    }
    if (!await granted.future) return WebStartProblem.otherTab;
    _lockHeld = true;
    return null;
  }

  @override
  String? get pendingDatabase {
    final value = _storage.getItem(_pendingKey);
    return value == null || value.isEmpty ? null : value;
  }

  @override
  Future<void> setPendingDatabase(String? name) async {
    final old = pendingDatabase;
    if (old != null && old != name) {
      _writeStale({...staleDatabases, old}.toList());
    }
    if (name == null) {
      _storage.removeItem(_pendingKey);
    } else {
      _storage.setItem(_pendingKey, name);
    }
  }

  @override
  String? get activeDatabase {
    final value = _storage.getItem(_activeKey);
    return value == null || value.isEmpty ? null : value;
  }

  @override
  List<String> get staleDatabases {
    final raw = _storage.getItem(_staleKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      return [for (final v in jsonDecode(raw) as List) v as String];
    } on FormatException {
      return const [];
    }
  }

  void _writeStale(List<String> names) =>
      _storage.setItem(_staleKey, jsonEncode(names));

  @override
  Future<void> setActiveDatabase(String? name) async {
    final old = activeDatabase;
    if (old != null && old != name) {
      // Dicatat lebih dulu agar penghapusan diulang bila tab tertutup.
      _writeStale({...staleDatabases, old}.toList());
    }
    if (name == null) {
      _storage.removeItem(_activeKey);
    } else {
      _storage.setItem(_activeKey, name);
      if (pendingDatabase == name) _storage.removeItem(_pendingKey);
    }
  }

  @override
  Future<void> purgeStale() async {
    for (final name in staleDatabases) {
      await deleteWebDatabase(name);
      _writeStale([...staleDatabases]..remove(name));
    }
  }
}

WebSessionStore platformWebSessionStore() => _LocalStorageWebSessionStore();
