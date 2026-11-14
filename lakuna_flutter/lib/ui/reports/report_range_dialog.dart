import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../l10n/gen/app_localizations.dart';
import '../purchases/purchase_labels.dart' show formatCalendarDate;

/// Dialog *Pilih rentang tanggal* laporan (F1-16b). Hasil = periode bebas,
/// atau `null` bila dibatalkan.
Future<ReportPeriod?> showReportRangeDialog(
  BuildContext context, {
  required DateRange initial,
  required DateTime today,
}) => showFDialog<ReportPeriod>(
  context: context,
  builder: (context, style, animation) => FDialog(
    animation: animation,
    constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
    builder: (context, style) =>
        _ReportRangeForm(initial: initial, today: today),
  ),
);

class _ReportRangeForm extends StatefulWidget {
  const _ReportRangeForm({required this.initial, required this.today});

  final DateRange initial;
  final DateTime today;

  @override
  State<_ReportRangeForm> createState() => _ReportRangeFormState();
}

class _ReportRangeFormState extends State<_ReportRangeForm> {
  static DateTime _day(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  late final DateTime _today = _day(widget.today);

  // Awal = rentang periode aktif, dipangkas ke hari ini.
  late DateTime _from = _clamp(widget.initial.from);
  late DateTime _to = _clamp(widget.initial.to);

  DateTime _clamp(DateTime d) {
    final day = _day(d);
    return day.isAfter(_today) ? _today : day;
  }

  ReportRangeError? get _error => reportRangeError(_from, _to, _today);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final error = _error;
    Widget field(String key, String label, DateTime value, bool isFrom) =>
        FDateField.calendar(
          key: ValueKey(key),
          label: Text(label),
          clearable: false,
          format: (context, value, _) => formatCalendarDate(value),
          forceErrorText: !isFrom && error != null
              ? switch (error) {
                  ReportRangeError.endBeforeStart => l10n.reportsRangeErrOrder,
                  ReportRangeError.future => l10n.reportsRangeErrFuture,
                  ReportRangeError.tooLong => l10n.reportsRangeErrTooLong(
                    maxReportRangeDays,
                  ),
                }
              : null,
          selectionControl: .managedSingle(
            initial: value,
            toggleable: false,
            onChange: (d) {
              if (d == null) return;
              setState(() {
                if (isFrom) {
                  _from = _day(d);
                } else {
                  _to = _day(d);
                }
              });
            },
          ),
        );
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        key: const ValueKey('reports-range-dialog'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            l10n.reportsRangeTitle,
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          field('reports-range-from', l10n.reportsRangeFrom, _from, true),
          field('reports-range-to', l10n.reportsRangeTo, _to, false),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              FButton(
                key: const ValueKey('reports-range-cancel'),
                variant: .outline,
                mainAxisSize: .min,
                onPress: () => Navigator.of(context).pop(),
                child: Flexible(child: Text(l10n.reportsRangeCancel)),
              ),
              FButton(
                key: const ValueKey('reports-range-apply'),
                mainAxisSize: .min,
                onPress: error != null
                    ? null
                    : () => Navigator.of(
                        context,
                      ).pop(ReportPeriod.custom(_from, _to)),
                child: Flexible(child: Text(l10n.reportsRangeApply)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
