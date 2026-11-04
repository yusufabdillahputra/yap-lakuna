import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/cash_drawer_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

/// Repositori kas laci di memori dengan aturan `lakuna_domain` yang sama.
class FakeCashDrawerRepository extends CashDrawerRepository {
  FakeCashDrawerRepository({
    this.staffName = 'Sari',
    this.permissions,
    DateTime Function()? clock,
  }) : _clock = clock ?? (() => DateTime.utc(2026, 11, 3, 0, 58));

  final String staffName;

  /// Izin staf; `null` = semua izin.
  Set<Permission>? permissions;
  final DateTime Function() _clock;
  final _tenant = UuidValue.fromString(newId());
  final _outlet = UuidValue.fromString(newId());
  final _device = UuidValue.fromString(newId());
  final _staff = UuidValue.fromString(newId());

  CashSession? session;
  final movements = <CashMovement>[];

  /// Label pengeluaran per gerakan kas (F1-15).
  final expenseLabels = <UuidValue, String>{};

  /// Uang keluar dari pengeluaran kas laci (dipanggil
  /// [FakeExpensesRepository.onDrawerExpense] di tes).
  void addExpenseMovement(Money amount, String note, String category) {
    final m = CashMovement(
      tenantId: _tenant,
      outletId: _outlet,
      cashSessionId: session!.id,
      direction: CashDirection.outflow,
      amount: amount.value,
      note: note.trim(),
      source: 'expense',
      createdAt: _clock(),
      hlc: 'h',
    );
    movements.add(m);
    expenseLabels[m.id] = category;
  }

  /// Galat berikutnya yang dikembalikan (sekali pakai).
  Exception? nextError;
  var loadCalls = 0;

  @override
  Future<Result<ActiveCashSession?>> loadCurrent() async {
    loadCalls++;
    if (_takeError() case final e?) return Result.error(e);
    final s = session;
    if (s == null || s.status != CashSessionStatus.opened) {
      return const Result.ok(null);
    }
    return Result.ok(_active(s));
  }

  @override
  Future<Result<ActiveCashSession>> open({
    required Money openingCash,
    String note = '',
  }) async {
    if (_check(Permission.cashSessionOpen) case final e?) {
      return Result.error(e);
    }
    if (validateOpeningCash(openingCash) case final e?) {
      return Result.error(CashInputInvalid(CashField.openingCash, e));
    }
    if (session?.status == CashSessionStatus.opened) {
      return Result.error(CashSessionAlreadyOpen());
    }
    movements.clear();
    final s = CashSession(
      tenantId: _tenant,
      outletId: _outlet,
      deviceId: _device,
      status: CashSessionStatus.opened,
      openedBy: _staff,
      openedAt: _clock(),
      openingCash: openingCash.value,
      openingNote: note.trim().isEmpty ? null : note.trim(),
      hlc: 'h',
    );
    session = s;
    return Result.ok(_active(s));
  }

  @override
  Future<Result<ActiveCashSession>> recordMovement(
    UuidValue sessionId, {
    required CashDirection direction,
    required Money amount,
    required String note,
  }) async {
    if (_check(Permission.cashMovementsCreate) case final e?) {
      return Result.error(e);
    }
    if (validateMovementAmount(amount) case final e?) {
      return Result.error(CashInputInvalid(CashField.amount, e));
    }
    if (validateMovementNote(note) case final e?) {
      return Result.error(CashInputInvalid(CashField.note, e));
    }
    final s = session;
    if (s == null ||
        s.id != sessionId ||
        s.status != CashSessionStatus.opened) {
      return Result.error(CashSessionNotOpen());
    }
    movements.add(
      CashMovement(
        tenantId: _tenant,
        outletId: _outlet,
        cashSessionId: s.id,
        direction: direction,
        amount: amount.value,
        note: note.trim(),
        createdAt: _clock(),
        hlc: 'h',
      ),
    );
    return Result.ok(_active(s));
  }

  @override
  Future<Result<CashSession>> close(
    UuidValue sessionId, {
    required CashCount count,
    String note = '',
  }) async {
    if (_check(Permission.cashSessionClose) case final e?) {
      return Result.error(e);
    }
    final s = session;
    if (s == null ||
        s.id != sessionId ||
        s.status != CashSessionStatus.opened) {
      return Result.error(CashSessionNotOpen());
    }
    final drawer = _drawer(s);
    final difference = drawer.differenceFor(count.total);
    if (validateClosingNote(difference, note) case final e?) {
      return Result.error(CashInputInvalid(CashField.note, e));
    }
    final closed = s.copyWith(
      status: CashSessionStatus.closed,
      closedBy: _staff,
      closedAt: _clock(),
      expectedCash: drawer.expectedCash.value,
      countedCash: count.total.value,
      difference: difference.value,
      closingNote: note.trim().isEmpty ? null : note.trim(),
    );
    session = closed;
    return Result.ok(closed);
  }

  Exception? _check(Permission p) {
    if (_takeError() case final e?) return e;
    final perms = permissions;
    if (perms != null && !perms.contains(p)) return NotPermitted(p);
    return null;
  }

  Exception? _takeError() {
    final e = nextError;
    nextError = null;
    return e;
  }

  CashDrawer _drawer(CashSession s) => cashDrawerOf(s, movements);

  ActiveCashSession _active(CashSession s) => ActiveCashSession(
    session: s,
    openedByName: staffName,
    movements: List.of(movements),
    drawer: _drawer(s),
    expenseLabels: Map.of(expenseLabels),
  );
}
