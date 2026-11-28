import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/breakpoints.dart';
import '../products/product_widgets.dart' show ChoicePill;
import '../settings/settings_card.dart';
import 'hosting_section.dart' show UploadProgressList;
import 'hosting_texts.dart';
import 'hosting_view_model.dart';

/// Layar 2.1 *Aktifkan versi hosting*: stepper 4 langkah (F2-01).
class ActivationView extends StatelessWidget {
  const ActivationView({super.key, required this.viewModel});

  final HostingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    return SettingsCard(
      key: const ValueKey('hosting-activation'),
      title: l10n.hostingActivate,
      child: LayoutBuilder(
        builder: (context, c) {
          final compact = LayoutSize.of(c.maxWidth) == LayoutSize.mobile;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              _StepHeader(step: vm.step, compact: compact),
              switch (vm.step) {
                ActivationStep.server => _ServerStep(viewModel: vm),
                ActivationStep.owner => _OwnerStep(viewModel: vm),
                ActivationStep.upload => _UploadStep(viewModel: vm),
                ActivationStep.done => _DoneStep(viewModel: vm),
              },
            ],
          );
        },
      ),
    );
  }
}

String _stepLabel(AppLocalizations l10n, ActivationStep s) => switch (s) {
  ActivationStep.server => l10n.hostingStepServer,
  ActivationStep.owner => l10n.hostingStepOwner,
  ActivationStep.upload => l10n.hostingStepUpload,
  ActivationStep.done => l10n.hostingStepDone,
};

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step, required this.compact});

  final ActivationStep step;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    Widget dot(ActivationStep s) {
      final done = s.index < step.index;
      final current = s == step;
      return Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done || current
              ? theme.colors.primary
              : theme.colors.secondary,
        ),
        child: done
            ? Icon(
                TablerIcons.check,
                size: 14,
                color: theme.colors.primaryForeground,
              )
            : Text(
                '${s.index + 1}',
                style: theme.typography.body.xs.copyWith(
                  fontWeight: FontWeight.w700,
                  color: current
                      ? theme.colors.primaryForeground
                      : theme.colors.mutedForeground,
                ),
              ),
      );
    }

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Row(
            spacing: 6,
            children: [for (final s in ActivationStep.values) dot(s)],
          ),
          Text(
            '${step.index + 1}/4 · ${_stepLabel(l10n, step)}',
            key: const ValueKey('hosting-step-title'),
            style: theme.typography.body.md.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }
    // Label boleh turun ke baris kedua agar empat langkah muat di kartu
    // pengaturan selebar ~700 px.
    return Row(
      children: [
        for (final s in ActivationStep.values) ...[
          if (s.index > 0)
            Container(
              width: 24,
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: s.index <= step.index
                  ? theme.colors.primary
                  : theme.colors.border,
            ),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                dot(s),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _stepLabel(l10n, s),
                    key: s == step
                        ? const ValueKey('hosting-step-title')
                        : null,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: s == step ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

Widget _error(AppLocalizations l10n, Object error, String key) => FAlert(
  key: ValueKey(key),
  variant: .destructive,
  title: Text(hostingErrorText(l10n, error)),
);

class _ServerStep extends StatelessWidget {
  const _ServerStep({required this.viewModel});

  final HostingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    final status = vm.serverStatus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (vm.lakunaServerUrl != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoicePill(
                key: const ValueKey('hosting-server-lakuna'),
                label: l10n.hostingServerLakuna,
                selected: vm.serverChoice == ServerChoice.lakuna,
                onTap: () => vm.chooseServer(ServerChoice.lakuna),
              ),
              ChoicePill(
                key: const ValueKey('hosting-server-own'),
                label: l10n.hostingServerOwn,
                selected: vm.serverChoice == ServerChoice.own,
                onTap: () => vm.chooseServer(ServerChoice.own),
              ),
            ],
          ),
        Text(
          vm.serverChoice == ServerChoice.lakuna
              ? l10n.hostingServerLakunaBody
              : l10n.hostingServerOwnBody,
          style: muted,
        ),
        if (vm.serverChoice == ServerChoice.own)
          FTextField(
            key: const ValueKey('hosting-server-url'),
            label: Text(l10n.hostingServerUrlLabel),
            hint: l10n.hostingServerUrlHint,
            keyboardType: TextInputType.url,
            autocorrect: false,
            control: .managed(
              initial: TextEditingValue(text: vm.serverUrl),
              onChange: (v) => vm.setOwnUrl(v.text),
            ),
          ),
        FTextField(
          key: const ValueKey('hosting-activation-code'),
          label: Text(l10n.hostingActivationCodeLabel),
          autocorrect: false,
          textCapitalization: TextCapitalization.characters,
          control: .managed(
            initial: TextEditingValue(text: vm.activationCode),
            onChange: (v) => vm.setActivationCode(v.text),
          ),
        ),
        if (status != null)
          Row(
            key: const ValueKey('hosting-server-ok'),
            spacing: 8,
            children: [
              Icon(
                TablerIcons.circleCheck,
                size: 18,
                color: theme.colors.primary,
              ),
              Expanded(
                child: Text(
                  l10n.hostingServerOk(status.serverVersion),
                  style: theme.typography.body.sm,
                ),
              ),
            ],
          ),
        if (vm.check.result case Error(:final error))
          _error(l10n, error, 'hosting-check-error'),
        _Buttons(
          children: [
            FButton(
              key: const ValueKey('hosting-cancel'),
              variant: .outline,
              mainAxisSize: .min,
              onPress: vm.busy ? null : vm.cancelActivation,
              child: Flexible(child: Text(l10n.hostingCancel)),
            ),
            if (status == null)
              FButton(
                key: const ValueKey('hosting-check'),
                mainAxisSize: .min,
                onPress: vm.canCheck ? vm.check.execute : null,
                prefix: vm.check.running
                    ? const FCircularProgress()
                    : const Icon(TablerIcons.plugConnected),
                child: Flexible(child: Text(l10n.hostingCheck)),
              )
            else
              FButton(
                key: const ValueKey('hosting-next'),
                mainAxisSize: .min,
                onPress: vm.canLeaveServerStep
                    ? () => vm.goTo(ActivationStep.owner)
                    : null,
                suffix: const Icon(TablerIcons.arrowRight),
                child: Flexible(child: Text(l10n.hostingNext)),
              ),
          ],
        ),
      ],
    );
  }
}

class _OwnerStep extends StatelessWidget {
  const _OwnerStep({required this.viewModel});

  final HostingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final register = vm.ownerMode == OwnerMode.register;
    final issue = vm.passwordIssue;
    final error = switch ((
      vm.signIn.result,
      vm.sendCode.result,
      vm.createAccount.result,
    )) {
      (Error(), _, _) => l10n.hostingErrorLogin,
      (_, Error(:final error), _) => hostingErrorText(l10n, error),
      (_, _, Error()) => l10n.hostingErrorRegistration,
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          l10n.hostingOwnerIntro,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoicePill(
              key: const ValueKey('hosting-owner-signin'),
              label: l10n.hostingOwnerSignIn,
              selected: !register,
              onTap: () => vm.setOwnerMode(OwnerMode.signIn),
            ),
            ChoicePill(
              key: const ValueKey('hosting-owner-register'),
              label: l10n.hostingOwnerRegister,
              selected: register,
              onTap: () => vm.setOwnerMode(OwnerMode.register),
            ),
          ],
        ),
        FTextField(
          key: const ValueKey('hosting-email'),
          label: Text(l10n.hostingEmail),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enabled: !(register && vm.codeSent),
          control: .managed(
            initial: TextEditingValue(text: vm.email),
            onChange: (v) => vm.setEmail(v.text),
          ),
        ),
        if (register && vm.codeSent) ...[
          Text(
            l10n.hostingCodeSent(vm.email),
            key: const ValueKey('hosting-code-sent'),
            style: theme.typography.body.sm,
          ),
          FTextField(
            key: const ValueKey('hosting-verification-code'),
            label: Text(l10n.hostingVerificationCode),
            keyboardType: TextInputType.number,
            control: .managed(onChange: (v) => vm.setVerificationCode(v.text)),
          ),
        ],
        if (!register || vm.codeSent)
          FTextField(
            key: const ValueKey('hosting-password'),
            label: Text(l10n.hostingPassword),
            obscureText: true,
            onSubmit: (_) {
              if (!register && vm.canSignIn) vm.signIn.execute();
            },
            control: .managed(onChange: (v) => vm.setPassword(v.text)),
          ),
        if (register && vm.codeSent)
          FTextField(
            key: const ValueKey('hosting-password-repeat'),
            label: Text(l10n.hostingPasswordRepeat),
            obscureText: true,
            control: .managed(onChange: (v) => vm.setPasswordRepeat(v.text)),
          ),
        if (register && issue != null)
          Text(
            switch (issue) {
              PasswordIssue.short => l10n.hostingPasswordShort,
              PasswordIssue.mismatch => l10n.hostingPasswordMismatch,
            },
            key: const ValueKey('hosting-password-issue'),
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.destructive,
            ),
          ),
        if (error != null)
          FAlert(
            key: const ValueKey('hosting-owner-error'),
            variant: .destructive,
            title: Text(error),
          ),
        _Buttons(
          children: [
            FButton(
              key: const ValueKey('hosting-back'),
              variant: .outline,
              mainAxisSize: .min,
              onPress: vm.busy ? null : () => vm.goTo(ActivationStep.server),
              prefix: const Icon(TablerIcons.arrowLeft),
              child: Flexible(child: Text(l10n.hostingBack)),
            ),
            if (!register)
              FButton(
                key: const ValueKey('hosting-signin'),
                mainAxisSize: .min,
                onPress: vm.canSignIn ? vm.signIn.execute : null,
                prefix: vm.signIn.running
                    ? const FCircularProgress()
                    : const Icon(TablerIcons.login),
                child: Flexible(child: Text(l10n.hostingOwnerSignIn)),
              )
            else if (!vm.codeSent)
              FButton(
                key: const ValueKey('hosting-send-code'),
                mainAxisSize: .min,
                onPress: vm.canSendCode ? vm.sendCode.execute : null,
                prefix: vm.sendCode.running
                    ? const FCircularProgress()
                    : const Icon(TablerIcons.mail),
                child: Flexible(child: Text(l10n.hostingSendCode)),
              )
            else
              FButton(
                key: const ValueKey('hosting-create-account'),
                mainAxisSize: .min,
                onPress: vm.canCreateAccount ? vm.createAccount.execute : null,
                prefix: vm.createAccount.running
                    ? const FCircularProgress()
                    : const Icon(TablerIcons.userPlus),
                child: Flexible(child: Text(l10n.hostingCreateAccount)),
              ),
          ],
        ),
      ],
    );
  }
}

class _UploadStep extends StatelessWidget {
  const _UploadStep({required this.viewModel});

  final HostingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final started = vm.state?.active ?? false;
    final paused = vm.state?.paused ?? false;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        if (vm.signedInAs case final email?)
          Text(
            l10n.hostingSignedIn(email),
            key: const ValueKey('hosting-signed-in'),
            style: theme.typography.body.sm,
          ),
        Text(
          l10n.hostingServerLine(serverHost(vm.serverUrl)),
          style: muted,
        ),
        if (started) UploadProgressList(progress: vm.progress),
        Text(l10n.hostingUploadIntro, style: muted),
        if (vm.activate.result case Error(:final error))
          _error(l10n, error, 'hosting-activate-error'),
        if (vm.setPaused.result case Error(:final error))
          _error(l10n, error, 'hosting-pause-error'),
        _Buttons(
          children: [
            if (!started) ...[
              FButton(
                key: const ValueKey('hosting-back'),
                variant: .outline,
                mainAxisSize: .min,
                onPress: vm.busy ? null : () => vm.goTo(ActivationStep.owner),
                prefix: const Icon(TablerIcons.arrowLeft),
                child: Flexible(child: Text(l10n.hostingBack)),
              ),
              FButton(
                key: const ValueKey('hosting-activate-now'),
                mainAxisSize: .min,
                onPress: vm.activate.running ? null : vm.activate.execute,
                prefix: vm.activate.running
                    ? const FCircularProgress()
                    : const Icon(TablerIcons.cloudUpload),
                child: Flexible(child: Text(l10n.hostingActivateNow)),
              ),
            ] else
              FButton(
                key: const ValueKey('hosting-upload-pause'),
                variant: .outline,
                mainAxisSize: .min,
                onPress: vm.setPaused.running
                    ? null
                    : () => vm.setPaused.execute(!paused),
                prefix: Icon(
                  paused ? TablerIcons.playerPlay : TablerIcons.playerPause,
                ),
                child: Flexible(
                  child: Text(
                    paused ? l10n.hostingResumeUpload : l10n.hostingPauseUpload,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({required this.viewModel});

  final HostingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    return Column(
      key: const ValueKey('hosting-done'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(TablerIcons.cloudCheck, color: theme.colors.primary),
            Expanded(
              child: Text(
                l10n.hostingDoneTitle,
                style: theme.typography.body.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        Text(l10n.hostingDoneBody(serverHost(vm.serverUrl))),
        UploadProgressList(progress: vm.progress),
        _Buttons(
          children: [
            FButton(
              key: const ValueKey('hosting-finish'),
              mainAxisSize: .min,
              onPress: vm.finishActivation,
              child: Flexible(child: Text(l10n.hostingDoneClose)),
            ),
          ],
        ),
      ],
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    alignment: WrapAlignment.end,
    children: children,
  );
}
