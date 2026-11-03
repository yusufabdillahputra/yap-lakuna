import 'package:flutter/foundation.dart';

import 'result.dart';

/// Membungkus aksi asinkron dari UI: status berjalan, hasil terakhir, dan
/// mencegah aksi dijalankan dua kali bersamaan. Pola `Command` dari panduan
/// arsitektur resmi Flutter.
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;
  Result<T>? _result;

  bool get running => _running;
  bool get error => _result is Error;
  bool get completed => _result is Ok;
  Result<T>? get result => _result;

  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> _execute(Future<Result<T>> Function() action) async {
    if (_running) return;
    _running = true;
    _result = null;
    notifyListeners();
    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

class Command0<T> extends Command<T> {
  Command0(this._action);
  final Future<Result<T>> Function() _action;

  Future<void> execute() => _execute(_action);
}

class Command1<T, A> extends Command<T> {
  Command1(this._action);
  final Future<Result<T>> Function(A) _action;

  Future<void> execute(A argument) => _execute(() => _action(argument));
}
