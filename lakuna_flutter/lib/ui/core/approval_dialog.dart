import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/repository_errors.dart';
import '../../data/repositories/session_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';

/// Menyediakan [SessionRepository] untuk dialog persetujuan di layar yang
/// tombolnya jauh di dalam pohon widget (mis. *Batalkan bill* di Meja).
class ApprovalScope extends InheritedWidget {
  const ApprovalScope({super.key, required this.session, required super.child});

  final SessionRepository session;

  static SessionRepository? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ApprovalScope>()?.session;

  @override
  bool updateShouldNotify(ApprovalScope oldWidget) =>
      session != oldWidget.session;
}

/// *Persetujuan manajer* (F1-11): staf bertugas tidak punya [permission],
/// jadi staf lain yang berizin di cabang ini memasukkan PIN-nya. Hasilnya
/// penyetuju yang terverifikasi, atau `null` bila dibatalkan.
Future<StaffProfile?> requestApproval(
  BuildContext context, {
  required SessionRepository session,
  required Permission permission,
  required String reason,
}) => showFDialog<StaffProfile>(
  context: context,
  builder: (context, style, animation) => FDialog(
    animation: animation,
    constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
    builder: (context, style) => ApprovalDialog(
      session: session,
      permission: permission,
      reason: reason,
    ),
  ),
);

class ApprovalDialog extends StatefulWidget {
  const ApprovalDialog({
    super.key,
    required this.session,
    required this.permission,
    required this.reason,
  });

  final SessionRepository session;
  final Permission permission;

  /// Kalimat yang menjelaskan apa yang disetujui.
  final String reason;

  @override
  State<ApprovalDialog> createState() => _ApprovalDialogState();
}

class _ApprovalDialogState extends State<ApprovalDialog> {
  List<StaffProfile>? _approvers;
  StaffProfile? _selected;
  var _pin = '';
  var _busy = false;
  Exception? _error;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await widget.session.listStaff();
    if (!mounted) return;
    final me = widget.session.current?.id;
    setState(() {
      _approvers = switch (result) {
        Ok(:final value) => [
          for (final s in value)
            if (s.id != me && s.hasPin && s.can(widget.permission)) s,
        ],
        Error() => const [],
      };
      _selected = _approvers!.firstOrNull;
    });
    _tick();
  }

  /// Hitung mundur selama PIN penyetuju terpilih dikunci.
  void _tick() {
    _ticker?.cancel();
    final id = _selected?.id;
    if (id == null || widget.session.pinRetryAfter(id) == null) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      if (widget.session.pinRetryAfter(id) == null) _ticker?.cancel();
    });
  }

  Future<void> _submit() async {
    final staff = _selected;
    if (staff == null || _busy || _pin.length != 6) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await widget.session.verifyApprover(
      staff.id,
      _pin,
      widget.permission,
    );
    if (!mounted) return;
    switch (result) {
      case Ok(:final value):
        Navigator.of(context).pop(value);
      case Error(:final error):
        setState(() {
          _busy = false;
          _error = error;
        });
        _tick();
    }
  }

  String? _message(AppLocalizations l10n) {
    if (_selected case final staff?) {
      if (widget.session.pinRetryAfter(staff.id) case final wait?) {
        return l10n.loginLocked(wait.inSeconds + 1);
      }
    }
    return switch (_error) {
      null => null,
      WrongPin(:final remainingAttempts) => l10n.loginWrongPin(
        remainingAttempts,
      ),
      CredentialsLocked(:final retryAfter) => l10n.loginLocked(
        retryAfter.inSeconds,
      ),
      StaffUnavailable() => l10n.loginStaffUnavailable,
      NotPermitted() => l10n.approvalNotPermitted,
      _ => l10n.loginFailed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final approvers = _approvers;
    final message = _message(l10n);
    final locked =
        _selected != null &&
        widget.session.pinRetryAfter(_selected!.id) != null;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        key: const ValueKey('approval-dialog'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            l10n.approvalTitle,
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            widget.reason,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          if (approvers == null)
            const Center(child: FCircularProgress())
          else if (approvers.isEmpty)
            FAlert(
              key: const ValueKey('approval-none'),
              variant: .destructive,
              title: Text(l10n.approvalNone),
            )
          else ...[
            FSelect<String>(
              key: const ValueKey('approval-staff'),
              label: Text(l10n.approvalStaff),
              items: {
                for (final s in approvers) _label(approvers, s): s.id.uuid,
              },
              control: .managed(
                initial: _selected!.id.uuid,
                onChange: (v) => setState(() {
                  _selected = approvers
                      .where((s) => s.id.uuid == v)
                      .firstOrNull;
                  _error = null;
                  _tick();
                }),
              ),
            ),
            FTextField(
              key: const ValueKey('approval-pin'),
              label: Text(l10n.approvalPin),
              obscureText: true,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              control: .managed(
                onChange: (v) => setState(() => _pin = v.text),
              ),
              onSubmit: (_) => _submit(),
            ),
            if (message != null)
              FAlert(
                key: const ValueKey('approval-error'),
                variant: .destructive,
                title: Text(message),
              ),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              FButton(
                variant: .outline,
                mainAxisSize: .min,
                onPress: () => Navigator.of(context).pop(),
                child: Flexible(child: Text(l10n.approvalCancel)),
              ),
              FButton(
                key: const ValueKey('approval-submit'),
                mainAxisSize: .min,
                onPress:
                    approvers == null ||
                        approvers.isEmpty ||
                        _busy ||
                        locked ||
                        _pin.length != 6
                    ? null
                    : _submit,
                child: Flexible(child: Text(l10n.approvalSubmit)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Label pilihan staf; nama kembar diberi nomor agar kunci peta unik.
  String _label(List<StaffProfile> all, StaffProfile s) {
    final same = all.where((o) => o.name == s.name).toList();
    if (same.length == 1) return s.name;
    return '${s.name} (${same.indexOf(s) + 1})';
  }
}
