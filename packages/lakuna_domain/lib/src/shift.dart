import 'package:characters/characters.dart';

/// Batas isian shift kasir (F1-03g), dihitung per karakter.
abstract final class ShiftLimits {
  static const name = 40;

  /// Menit dalam sehari; jam shift `0 ≤ menit < minutesPerDay`.
  static const minutesPerDay = 24 * 60;
}

final _hourOnly = RegExp(r'^\d{1,2}$');
final _separated = RegExp(r'^(\d{1,2})[.:](\d{2})$');
final _compact = RegExp(r'^(\d{1,2})(\d{2})$');

/// Jam shift dari isian `7`, `07.00`, `7:30`, atau `0730`, dalam menit sejak
/// tengah malam; `null` bila bukan jam 00.00–23.59.
int? parseShiftTime(String raw) {
  final s = raw.trim();
  int? hour;
  var minute = 0;
  if (_hourOnly.hasMatch(s)) {
    hour = int.parse(s);
  } else if ((_separated.firstMatch(s) ?? _compact.firstMatch(s))
      case final m?) {
    hour = int.parse(m.group(1)!);
    minute = int.parse(m.group(2)!);
  }
  if (hour == null || hour > 23 || minute > 59) return null;
  return hour * 60 + minute;
}

/// `07.05` dari menit sejak tengah malam.
String formatShiftTime(int minute) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(minute ~/ 60)}.${two(minute % 60)}';
}

/// `07.00–15.00`.
String shiftRangeLabel(int start, int end) =>
    '${formatShiftTime(start)}–${formatShiftTime(end)}';

enum ShiftIssue {
  name,
  start,
  end,

  /// Jam mulai sama dengan jam selesai.
  sameTime,
}

bool _validMinute(int? m) =>
    m != null && m >= 0 && m < ShiftLimits.minutesPerDay;

/// Galat isian shift. [start]/[end] `null` = isian jam tidak terbaca.
Set<ShiftIssue> validateShift({
  required String name,
  required int? start,
  required int? end,
}) {
  final length = name.trim().characters.length;
  return {
    if (length == 0 || length > ShiftLimits.name) ShiftIssue.name,
    if (!_validMinute(start)) ShiftIssue.start,
    if (!_validMinute(end)) ShiftIssue.end,
    if (_validMinute(start) && start == end) ShiftIssue.sameTime,
  };
}

/// [minute] berada di shift [start]–[end] (mulai termasuk, selesai tidak);
/// shift boleh melewati tengah malam (mis. 22.00–06.00).
bool shiftContains(int start, int end, int minute) => start < end
    ? minute >= start && minute < end
    : minute >= start || minute < end;

/// Indeks shift yang sedang berjalan pada [minute]; bila beberapa shift
/// tumpang tindih (serah terima), yang paling baru mulai, karena kasir yang
/// membuka sesi biasanya kasir shift berikutnya. `null` bila tidak ada.
int? currentShiftIndex(List<({int start, int end})> shifts, int minute) {
  int? best;
  int? bestElapsed;
  for (final (i, s) in shifts.indexed) {
    if (!shiftContains(s.start, s.end, minute)) continue;
    final elapsed = (minute - s.start) % ShiftLimits.minutesPerDay;
    if (bestElapsed == null || elapsed < bestElapsed) {
      best = i;
      bestElapsed = elapsed;
    }
  }
  return best;
}
