import 'package:flutter/widgets.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/session_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/approval_dialog.dart';
import '../core/format.dart';

/// Dialog *Persetujuan manajer* untuk *Sudah Terbayar* QRIS [amount]
/// (F1-05h). Penyetuju = staf lain ber-PIN yang lolos [canApprove] (aturan
/// konfirmasi langsung). `null` bila dibatalkan atau tidak ada
/// [ApprovalScope].
Future<StaffProfile?> requestQrisApproval(
  BuildContext context, {
  required Money amount,
  required bool Function(Set<Permission> permissions) canApprove,
}) async {
  final session = ApprovalScope.maybeOf(context);
  if (session == null) return null;
  return requestApproval(
    context,
    session: session,
    permission: Permission.paymentsConfirm,
    reason: AppLocalizations.of(
      context,
    ).approvalQris(formatMoney(context, amount)),
    eligible: (s) => canApprove(s.permissions),
  );
}
