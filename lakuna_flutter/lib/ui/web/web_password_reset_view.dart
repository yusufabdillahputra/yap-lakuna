import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show
        EmailAccountPasswordResetException,
        EmailAccountPasswordResetExceptionReason;
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/web_join_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../hosting/hosting_texts.dart';
import 'web_password_reset_view_model.dart';

/// Kartu *Lupa kata sandi?* di layar login web: email → kode dari email
/// + kata sandi baru dua kali → selesai, kembali ke *Masuk*.
class WebPasswordResetCard extends StatefulWidget {
  const WebPasswordResetCard({
    super.key,
    required this.repository,
    required this.serverUrl,
    required this.onClose,
    this.email = '',
  });

  final WebLoginRepository repository;
  final String serverUrl;
  final String email;
  final VoidCallback onClose;

  @override
  State<WebPasswordResetCard> createState() => _WebPasswordResetCardState();
}

class _WebPasswordResetCardState extends State<WebPasswordResetCard> {
  late final _vm = WebPasswordResetViewModel(
    repository: widget.repository,
    serverUrl: widget.serverUrl,
    email: widget.email,
  );

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) {
            final error = switch (_vm.step) {
              WebResetStep.email => _vm.send.result,
              _ => _vm.save.result,
            };
            final passwordError = switch (_vm.passwordError) {
              WebResetPasswordError.tooShort => l10n.hostingPasswordShort,
              WebResetPasswordError.mismatch => l10n.hostingPasswordMismatch,
              null => null,
            };
            return Column(
              key: ValueKey('web-reset-step-${_vm.step.name}'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  l10n.webResetTitle,
                  style: theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ...switch (_vm.step) {
                  WebResetStep.email => [
                    Text(
                      l10n.webResetBody,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    FTextField(
                      key: const ValueKey('web-reset-email'),
                      label: Text(l10n.webLoginEmail),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enabled: !_vm.busy,
                      control: .managed(
                        initial: TextEditingValue(text: _vm.email),
                        onChange: (v) => _vm.setEmail(v.text),
                      ),
                    ),
                  ],
                  WebResetStep.code => [
                    Text(
                      l10n.webResetCodeBody(_vm.email),
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                    FTextField(
                      key: const ValueKey('web-reset-code'),
                      label: Text(l10n.webResetCode),
                      autocorrect: false,
                      enabled: !_vm.busy,
                      control: .managed(onChange: (v) => _vm.setCode(v.text)),
                    ),
                    FTextField(
                      key: const ValueKey('web-reset-password'),
                      label: Text(l10n.webResetNewPassword),
                      obscureText: true,
                      autocorrect: false,
                      enabled: !_vm.busy,
                      control: .managed(
                        onChange: (v) => _vm.setPassword(v.text),
                      ),
                    ),
                    FTextField(
                      key: const ValueKey('web-reset-password-again'),
                      label: Text(l10n.webResetNewPasswordAgain),
                      obscureText: true,
                      autocorrect: false,
                      enabled: !_vm.busy,
                      control: .managed(
                        onChange: (v) => _vm.setPasswordAgain(v.text),
                      ),
                    ),
                    if (passwordError != null)
                      Text(
                        passwordError,
                        key: const ValueKey('web-reset-password-error'),
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.destructive,
                        ),
                      ),
                  ],
                  WebResetStep.done => [
                    FAlert(
                      key: const ValueKey('web-reset-done'),
                      icon: const Icon(TablerIcons.circleCheck),
                      title: Text(l10n.webResetDone),
                    ),
                  ],
                },
                if (error case Error(:final error))
                  Text(
                    _resetErrorText(l10n, error),
                    key: const ValueKey('web-reset-error'),
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.destructive,
                    ),
                  ),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_vm.step != WebResetStep.done)
                      FButton(
                        key: const ValueKey('web-reset-cancel'),
                        variant: .outline,
                        mainAxisSize: .min,
                        onPress: _vm.busy ? null : widget.onClose,
                        child: Text(l10n.webLoginBack),
                      ),
                    switch (_vm.step) {
                      WebResetStep.email => FButton(
                        key: const ValueKey('web-reset-send'),
                        mainAxisSize: .min,
                        onPress: _vm.canSend ? _vm.send.execute : null,
                        prefix: _vm.send.running
                            ? const FCircularProgress()
                            : const Icon(TablerIcons.mail),
                        child: Text(l10n.webResetSend),
                      ),
                      WebResetStep.code => FButton(
                        key: const ValueKey('web-reset-save'),
                        mainAxisSize: .min,
                        onPress: _vm.canSave ? _vm.save.execute : null,
                        prefix: _vm.save.running
                            ? const FCircularProgress()
                            : const Icon(TablerIcons.check),
                        child: Text(l10n.webResetSave),
                      ),
                      WebResetStep.done => FButton(
                        key: const ValueKey('web-reset-close'),
                        mainAxisSize: .min,
                        onPress: widget.onClose,
                        child: Text(l10n.webLoginTitle),
                      ),
                    },
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _resetErrorText(AppLocalizations l10n, Exception error) =>
    switch (error) {
      EmailAccountPasswordResetException(:final reason) => switch (reason) {
        EmailAccountPasswordResetExceptionReason.expired =>
          l10n.webResetErrExpired,
        EmailAccountPasswordResetExceptionReason.tooManyAttempts =>
          l10n.webResetErrTooMany,
        EmailAccountPasswordResetExceptionReason.policyViolation =>
          l10n.webResetErrPolicy,
        _ => l10n.webResetErrInvalid,
      },
      _ => hostingErrorText(l10n, error),
    };
