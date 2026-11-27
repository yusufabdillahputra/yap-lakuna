import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/shifts_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

/// Master shift di memori dengan aturan `lakuna_domain` yang sama.
class FakeShiftsRepository extends ShiftsRepository {
  final _tenant = UuidValue.fromString(newId());
  final _outlet = UuidValue.fromString(newId());

  final shifts = <Shift>[];

  /// Jumlah sesi pemakai per shift.
  final usage = <UuidValue, int>{};

  /// Galat berikutnya (sekali pakai).
  Exception? nextError;

  Shift add(String name, int start, int end, {int used = 0}) {
    final s = Shift(
      tenantId: _tenant,
      outletId: _outlet,
      name: name,
      startMinute: start,
      endMinute: end,
      hlc: 'h',
    );
    shifts.add(s);
    if (used > 0) usage[s.id] = used;
    return s;
  }

  Exception? _take() {
    final e = nextError;
    nextError = null;
    return e;
  }

  @override
  Future<Result<List<ShiftRow>>> list() async {
    if (_take() case final e?) return Result.error(e);
    final sorted = List.of(shifts)
      ..sort((a, b) => a.startMinute.compareTo(b.startMinute));
    return Result.ok([
      for (final s in sorted) ShiftRow(shift: s, usage: usage[s.id] ?? 0),
    ]);
  }

  @override
  Future<Result<Shift>> save({
    UuidValue? id,
    required String name,
    required int startMinute,
    required int endMinute,
  }) async {
    if (_take() case final e?) return Result.error(e);
    final issues = validateShift(
      name: name,
      start: startMinute,
      end: endMinute,
    );
    if (issues.isNotEmpty) return Result.error(ShiftInvalid(issues));
    final clean = name.trim();
    if (shifts.any(
      (s) => s.id != id && s.name.toLowerCase() == clean.toLowerCase(),
    )) {
      return Result.error(ShiftNameTaken());
    }
    if (id == null) {
      return Result.ok(add(clean, startMinute, endMinute));
    }
    final i = shifts.indexWhere((s) => s.id == id);
    if (i < 0) return Result.error(ShiftNotFound());
    final next = shifts[i].copyWith(
      name: clean,
      startMinute: startMinute,
      endMinute: endMinute,
    );
    shifts[i] = next;
    return Result.ok(next);
  }

  @override
  Future<Result<void>> delete(UuidValue id) async {
    if (_take() case final e?) return Result.error(e);
    final used = usage[id] ?? 0;
    if (used > 0) return Result.error(ShiftInUse(used));
    shifts.removeWhere((s) => s.id == id);
    return const Result.ok(null);
  }
}
