import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/repository_errors.dart';
import '../../l10n/gen/app_localizations.dart';

/// `07.00–15.00` dari baris shift.
String shiftRange(Shift s) => shiftRangeLabel(s.startMinute, s.endMinute);

/// Pesan galat isian shift (F1-03g).
String shiftIssueMessage(AppLocalizations l10n, ShiftIssue issue) =>
    switch (issue) {
      ShiftIssue.name => l10n.shiftErrName(ShiftLimits.name),
      ShiftIssue.start || ShiftIssue.end => l10n.shiftErrTime,
      ShiftIssue.sameTime => l10n.shiftErrSameTime,
    };

/// Pesan galat simpan/hapus shift dan buka sesi dengan shift.
String shiftErrorMessage(AppLocalizations l10n, Object error) =>
    switch (error) {
      ShiftInvalid(:final issues) when issues.isNotEmpty => shiftIssueMessage(
        l10n,
        issues.first,
      ),
      ShiftNameTaken() => l10n.shiftErrNameTaken,
      ShiftNotFound() => l10n.shiftErrNotFound,
      ShiftInUse(:final sessions) => l10n.shiftErrInUse(sessions),
      NotPermitted() || ShiftActorNotPermitted() => l10n.shiftErrNotPermitted,
      _ => l10n.shiftErrGeneric,
    };
