import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/users_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../login/login_view.dart' show roleLabel;
import '../products/product_widgets.dart';
import 'users_labels.dart';
import 'users_view_model.dart';

/// Lebar minimum untuk dua kartu berdampingan.
const _twoColumnWidth = 820.0;

/// *Akun saya* (1.25b): setiap pengguna mengganti PIN dan kata sandinya
/// sendiri, selalu dengan kolom ulangi.
class MyAccountScreen extends StatefulWidget {
  const MyAccountScreen({super.key, required this.repository});

  final UsersRepository repository;

  @override
  State<MyAccountScreen> createState() => _MyAccountScreenState();
}

class _MyAccountScreenState extends State<MyAccountScreen> {
  late final _vm = MyAccountViewModel(repository: widget.repository);

  @override
  void initState() {
    super.initState();
    unawaited(_vm.load.execute());
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final vm = _vm;
      final account = vm.account;
      final pin = _SecretCard(
        id: 'pin',
        title: l10n.accountPinTitle,
        viewModel: vm,
        generation: vm.pinGeneration,
        command: vm.changePin,
        fields: [
          (MyAccountField.pinCurrent, l10n.accountPinCurrent, null),
          (MyAccountField.pin, l10n.accountPinNew, null),
          (MyAccountField.pinRetype, l10n.accountPinRetype, null),
        ],
        pin: true,
        submit: l10n.accountPinSubmit,
        done: l10n.accountPinDone,
      );
      final password = account?.hasPassword ?? false
          ? _SecretCard(
              id: 'password',
              title: l10n.accountPasswordTitle,
              viewModel: vm,
              generation: vm.passwordGeneration,
              command: vm.changePassword,
              fields: [
                (
                  MyAccountField.passwordCurrent,
                  l10n.accountPasswordCurrent,
                  null,
                ),
                (
                  MyAccountField.password,
                  l10n.accountPasswordNew,
                  l10n.accountPasswordNewHint,
                ),
                (
                  MyAccountField.passwordRetype,
                  l10n.accountPasswordRetype,
                  null,
                ),
              ],
              pin: false,
              submit: l10n.accountPasswordSubmit,
              done: l10n.accountPasswordDone,
            )
          : SectionCard(
              title: l10n.accountPasswordTitle,
              child: Text(
                l10n.accountPasswordNone,
                key: const ValueKey('account-password-none'),
                style: context.theme.typography.body.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            );
      return SingleChildScrollView(
        key: const ValueKey('account-scroll'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            PageHeader(
              title: l10n.accountTitle,
              subtitle: account == null
                  ? null
                  : l10n.accountSubtitle(
                      account.name,
                      roleLabel(l10n, account.roleKey, account.roleName),
                    ),
            ),
            if (vm.load.result case Error(:final error))
              LoadFailedAlert(
                message: usersErrorMessage(l10n, error),
                onRetry: vm.load.execute,
              )
            else if (account == null)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: FCircularProgress()),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) =>
                    constraints.maxWidth >= _twoColumnWidth
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16,
                        children: [
                          Expanded(child: password),
                          Expanded(child: pin),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 16,
                        children: [password, pin],
                      ),
              ),
          ],
        ),
      );
    },
  );
}

class _SecretCard extends StatelessWidget {
  const _SecretCard({
    required this.id,
    required this.title,
    required this.viewModel,
    required this.generation,
    required this.command,
    required this.fields,
    required this.pin,
    required this.submit,
    required this.done,
  });

  final String id;
  final String title;
  final MyAccountViewModel viewModel;
  final int generation;
  final Command0<void> command;
  final List<(MyAccountField, String, String?)> fields;
  final bool pin;
  final String submit;
  final String done;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final issues = viewModel.issues;
    return SectionCard(
      title: title,
      child: KeyedSubtree(
        key: ValueKey('account-$id-$generation'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            for (final (field, label, hint) in fields)
              FTextField(
                key: ValueKey('account-${field.name}'),
                label: Text(label),
                description: hint == null ? null : Text(hint),
                obscureText: true,
                keyboardType: pin ? TextInputType.number : null,
                maxLength: pin ? 6 : null,
                inputFormatters: [
                  if (pin) FilteringTextInputFormatter.digitsOnly,
                ],
                error: switch (issues[field]) {
                  final issue? => Text(staffIssueLabel(l10n, issue)),
                  null => null,
                },
                control: .managed(
                  initial: TextEditingValue(text: viewModel.value(field)),
                  onChange: (v) => viewModel.set(field, v.text),
                ),
              ),
            if (command.completed)
              FAlert(key: ValueKey('account-$id-done'), title: Text(done))
            else if (command.result case Error(:final error)
                when error is! StaffFormInvalid)
              Text(
                usersErrorMessage(l10n, error),
                key: ValueKey('account-$id-error'),
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.destructive,
                ),
              ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FButton(
                key: ValueKey('account-$id-submit'),
                mainAxisSize: .min,
                onPress: command.running ? null : command.execute,
                prefix: Icon(pin ? TablerIcons.key : TablerIcons.lock),
                child: Flexible(child: Text(submit)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
