import 'package:lakuna_domain/lakuna_domain.dart' show DateRange;

import '../../l10n/gen/app_localizations.dart';

/// Label rentang tanggal bebas (F1-16b): `5 Nov 2026`, `1–15 Nov 2026`,
/// `28 Okt – 3 Nov 2026`, `28 Des 2025 – 3 Jan 2026` (en: `Nov 5, 2026`,
/// `Nov 1–15, 2026`, `Oct 28 – Nov 3, 2026`, `Dec 28, 2025 – Jan 3, 2026`).
String reportRangeLabel(AppLocalizations l10n, DateRange r) {
  final en = l10n.localeName.startsWith('en');
  final months = en ? _enShortMonths : _idShortMonths;
  final a = r.from;
  final b = r.to;
  String m(DateTime d) => months[d.month - 1];
  if (a == b) {
    return en ? '${m(a)} ${a.day}, ${a.year}' : '${a.day} ${m(a)} ${a.year}';
  }
  if (a.year == b.year && a.month == b.month) {
    return en
        ? '${m(a)} ${a.day}–${b.day}, ${a.year}'
        : '${a.day}–${b.day} ${m(a)} ${a.year}';
  }
  if (a.year == b.year) {
    return en
        ? '${m(a)} ${a.day} – ${m(b)} ${b.day}, ${b.year}'
        : '${a.day} ${m(a)} – ${b.day} ${m(b)} ${b.year}';
  }
  return en
      ? '${m(a)} ${a.day}, ${a.year} – ${m(b)} ${b.day}, ${b.year}'
      : '${a.day} ${m(a)} ${a.year} – ${b.day} ${m(b)} ${b.year}';
}

const _idShortMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', //
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

const _enShortMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
