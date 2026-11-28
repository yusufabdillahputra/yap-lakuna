import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart' show SelectableText;
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/hosting_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../core/qr_image.dart';
import 'hosting_texts.dart';
import 'two_factor_view_model.dart';

/// Dialog atur verifikasi 2 langkah (F2-02 aturan 12–14). Hasil `true` bila
/// status di server berubah.
Future<bool> showTwoFactorDialog(
  BuildContext context, {
  required HostingRepository hosting,
  required SessionRepository session,
  required TwoFactorMode mode,
}) async {
  final changed = await showFDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 480),
      builder: (context, style) =>
          _TwoFactorDialog(hosting: hosting, session: session, mode: mode),
    ),
  );
  return changed ?? false;
}

class _TwoFactorDialog extends StatefulWidget {
  const _TwoFactorDialog({
    required this.hosting,
    required this.session,
    required this.mode,
  });

  final HostingRepository hosting;
  final SessionRepository session;
  final TwoFactorMode mode;

  @override
  State<_TwoFactorDialog> createState() => _TwoFactorDialogState();
}

class _TwoFactorDialogState extends State<_TwoFactorDialog> {
  late final _vm = TwoFactorViewModel(
    hosting: widget.hosting,
    session: widget.session,
    mode: widget.mode,
  );
  var _copied = false;

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop(_vm.serverChanged);

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final muted = theme.typography.body.sm.copyWith(
        color: theme.colors.mutedForeground,
      );
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          key: ValueKey('two-factor-${_vm.step.name}'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              _vm.step == TwoFactorStep.backupCodes
                  ? l10n.twoFactorBackupTitle
                  : l10n.twoFactorDialogTitle,
              style: theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            ...switch (_vm.step) {
              TwoFactorStep.pin => [
                Text(l10n.twoFactorPinBody, style: muted),
                FTextField(
                  key: const ValueKey('two-factor-pin'),
                  label: Text(l10n.twoFactorPinLabel),
                  obscureText: true,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  control: .managed(onChange: (v) => _vm.setPin(v.text)),
                  onSubmit: (_) {
                    if (_vm.canSubmitPin) _vm.submitPin.execute();
                  },
                ),
                _error(l10n, _vm.submitPin),
              ],
              TwoFactorStep.account => [
                Text(l10n.twoFactorAccountBody, style: muted),
                FTextField(
                  key: const ValueKey('two-factor-email'),
                  label: Text(l10n.twoFactorEmail),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: true,
                  control: .managed(onChange: (v) => _vm.setEmail(v.text)),
                ),
                FTextField(
                  key: const ValueKey('two-factor-password'),
                  label: Text(l10n.twoFactorPassword),
                  obscureText: true,
                  control: .managed(onChange: (v) => _vm.setPassword(v.text)),
                  onSubmit: (_) {
                    if (_vm.canSubmitAccount) _vm.submitAccount.execute();
                  },
                ),
                _error(l10n, _vm.submitAccount),
              ],
              TwoFactorStep.enroll => [
                Text(l10n.twoFactorScanBody, style: muted),
                Center(
                  child: QrImage(
                    _vm.enrollment!.otpauthUri,
                    key: const ValueKey('two-factor-qr'),
                    size: 180,
                  ),
                ),
                Text(l10n.twoFactorSecretLabel, style: muted),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      child: SelectableText(
                        _vm.secretGroups,
                        key: const ValueKey('two-factor-secret'),
                        style: theme.typography.body.md.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    FButton(
                      key: const ValueKey('two-factor-secret-copy'),
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: () => _copy(_vm.enrollment!.secretBase32),
                      prefix: const Icon(TablerIcons.copy),
                      child: Flexible(
                        child: Text(
                          _copied ? l10n.twoFactorCopied : l10n.twoFactorCopy,
                        ),
                      ),
                    ),
                  ],
                ),
                _codeField(l10n, l10n.twoFactorCodeLabel, () {
                  if (_vm.canSubmitCode) _vm.submitCode.execute();
                }),
                _error(l10n, _vm.submitCode),
              ],
              TwoFactorStep.backupCodes => [
                Text(l10n.twoFactorBackupBody, style: muted),
                Wrap(
                  key: const ValueKey('two-factor-backup-codes'),
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    for (final c in _vm.backupCodes)
                      SizedBox(
                        width: 120,
                        child: SelectableText(
                          c,
                          style: theme.typography.body.md.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              TwoFactorStep.disable => [
                Text(l10n.twoFactorDisableBody, style: muted),
                _codeField(l10n, l10n.twoFactorDisableCodeLabel, () {
                  if (_vm.canSubmitDisable) _vm.submitDisable.execute();
                }),
                _error(l10n, _vm.submitDisable),
              ],
              TwoFactorStep.done => [
                FAlert(
                  key: const ValueKey('two-factor-done'),
                  title: Text(
                    _vm.alreadyEnabled
                        ? l10n.twoFactorAlreadyEnabled
                        : widget.mode == TwoFactorMode.disable
                        ? l10n.twoFactorDoneDisabled
                        : l10n.twoFactorDoneEnabled,
                  ),
                ),
              ],
            },
            _actions(l10n),
          ],
        ),
      );
    },
  );

  Widget _codeField(AppLocalizations l10n, String label, VoidCallback submit) =>
      FTextField(
        key: ValueKey('two-factor-code-${_vm.revision}'),
        label: Text(label),
        autofocus: true,
        autocorrect: false,
        keyboardType: _vm.step == TwoFactorStep.enroll
            ? TextInputType.number
            : TextInputType.text,
        textCapitalization: TextCapitalization.characters,
        control: .managed(onChange: (v) => _vm.setCode(v.text)),
        onSubmit: (_) => submit(),
      );

  Widget _error(AppLocalizations l10n, Command<Object?> command) =>
      switch (command.result) {
        Error(:final error) => Text(
          hostingErrorText(l10n, error),
          key: const ValueKey('two-factor-error'),
          style: context.theme.typography.body.sm.copyWith(
            color: context.theme.colors.destructive,
          ),
        ),
        _ => const SizedBox.shrink(),
      };

  Widget _actions(AppLocalizations l10n) {
    final (label, onPress, running) = switch (_vm.step) {
      TwoFactorStep.pin => (
        l10n.twoFactorNext,
        _vm.canSubmitPin ? _vm.submitPin.execute : null,
        _vm.submitPin.running,
      ),
      TwoFactorStep.account => (
        l10n.twoFactorNext,
        _vm.canSubmitAccount ? _vm.submitAccount.execute : null,
        _vm.submitAccount.running,
      ),
      TwoFactorStep.enroll => (
        l10n.twoFactorEnable,
        _vm.canSubmitCode ? _vm.submitCode.execute : null,
        _vm.submitCode.running,
      ),
      TwoFactorStep.disable => (
        widget.mode == TwoFactorMode.reset
            ? l10n.twoFactorReset
            : l10n.twoFactorDisable,
        _vm.canSubmitDisable ? _vm.submitDisable.execute : null,
        _vm.submitDisable.running,
      ),
      TwoFactorStep.backupCodes => (
        l10n.twoFactorBackupDone,
        _vm.finish,
        false,
      ),
      TwoFactorStep.done => (l10n.twoFactorClose, _close, false),
    };
    final finished =
        _vm.step == TwoFactorStep.done || _vm.step == TwoFactorStep.backupCodes;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        if (_vm.step == TwoFactorStep.backupCodes)
          FButton(
            key: const ValueKey('two-factor-backup-copy'),
            variant: .outline,
            mainAxisSize: .min,
            onPress: () => _copy(_vm.backupCodes.join('\n')),
            prefix: const Icon(TablerIcons.copy),
            child: Flexible(
              child: Text(
                _copied ? l10n.twoFactorCopied : l10n.twoFactorBackupCopy,
              ),
            ),
          ),
        if (!finished)
          FButton(
            key: const ValueKey('two-factor-cancel'),
            variant: .outline,
            mainAxisSize: .min,
            onPress: _close,
            child: Flexible(child: Text(l10n.twoFactorCancel)),
          ),
        FButton(
          key: const ValueKey('two-factor-submit'),
          mainAxisSize: .min,
          onPress: running ? null : onPress,
          prefix: running ? const FCircularProgress() : null,
          child: Flexible(child: Text(label)),
        ),
      ],
    );
  }
}
