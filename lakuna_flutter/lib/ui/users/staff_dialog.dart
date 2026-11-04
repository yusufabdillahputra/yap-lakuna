part of 'users_view.dart';

/// Kolom PIN 6 angka tersamar.
class _PinField extends StatelessWidget {
  const _PinField({
    super.key,
    required this.label,
    this.description,
    required this.value,
    required this.issue,
    required this.onChange,
  });

  final String label;
  final String? description;
  final String value;
  final StaffIssue? issue;
  final ValueChanged<String> onChange;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FTextField(
      label: Text(label),
      description: description == null ? null : Text(description!),
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      error: issue == null ? null : Text(staffIssueLabel(l10n, issue!)),
      control: .managed(
        initial: TextEditingValue(text: value),
        onChange: (v) => onChange(v.text),
      ),
    );
  }
}

/// Dialog *Tambah pengguna* / ubah pengguna + *Reset PIN* (1.25b). Hasil
/// `true` bila pengguna disimpan.
class _StaffDialog extends StatelessWidget {
  const _StaffDialog({required this.viewModel});

  final StaffFormViewModel viewModel;

  Future<void> _save(BuildContext context) async {
    await viewModel.save.execute();
    if (!context.mounted) return;
    if (viewModel.save.completed) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = viewModel;
      final issues = vm.issues;
      final saveError = switch (vm.save.result) {
        Error(error: StaffFormInvalid()) ||
        Error(error: StaffNameTaken()) => null,
        Error(:final error) => usersErrorMessage(l10n, error),
        _ => null,
      };
      return SingleChildScrollView(
        key: const ValueKey('users-form'),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              vm.isNew ? l10n.usersFormNewTitle : l10n.usersFormEditTitle,
              style: theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(l10n.usersFormPermission, style: _muted(context)),
            FTextField(
              key: const ValueKey('users-form-name'),
              label: Text(l10n.usersFieldName),
              autofocus: vm.isNew,
              maxLength: staffNameMaxLength,
              error: switch ((issues[StaffFormField.name], vm.nameTaken)) {
                (final issue?, _) => Text(staffIssueLabel(l10n, issue)),
                (null, true) => Text(l10n.usersErrNameTaken),
                _ => null,
              },
              control: .managed(
                initial: TextEditingValue(text: vm.name),
                onChange: (v) => vm.setName(v.text),
              ),
            ),
            FSelect<String>(
              key: const ValueKey('users-form-role'),
              label: Text(l10n.usersFieldRole),
              description: Text(l10n.usersFieldRoleHint),
              items: {
                for (final r in vm.roles) roleLabel(l10n, r.key, r.name): r.key,
              },
              control: .managed(
                initial: vm.roleKey,
                onChange: (key) {
                  if (key != null) vm.setRole(key);
                },
              ),
            ),
            if (vm.isNew) ...[
              _PinField(
                key: const ValueKey('users-form-pin'),
                label: l10n.usersFieldPin,
                description: l10n.usersFieldPinHint,
                value: '',
                issue: issues[StaffFormField.pin],
                onChange: vm.setPin,
              ),
              _PinField(
                key: const ValueKey('users-form-pin-retype'),
                label: l10n.usersFieldPinRetype,
                value: '',
                issue: issues[StaffFormField.pinRetype],
                onChange: vm.setPinRetype,
              ),
            ],
            FSwitch(
              key: const ValueKey('users-form-active'),
              label: Text(l10n.usersFieldActive),
              description: Text(l10n.usersFieldActiveHint),
              value: vm.active,
              onChange: vm.setActive,
            ),
            if (saveError != null)
              _errorText(
                context,
                saveError,
                key: const ValueKey('users-form-error'),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                FButton(
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(context).pop(false),
                  child: Flexible(child: Text(l10n.usersCancel)),
                ),
                FButton(
                  key: const ValueKey('users-form-save'),
                  mainAxisSize: .min,
                  onPress: vm.save.running ? null : () => _save(context),
                  child: Flexible(child: Text(l10n.usersSave)),
                ),
              ],
            ),
            if (!vm.isNew) ...[
              const FDivider(),
              Text(l10n.usersResetTitle, style: _strong(context)),
              Text(l10n.usersResetHint, style: _muted(context)),
              KeyedSubtree(
                key: ValueKey('users-reset-${vm.resetGeneration}'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    _PinField(
                      key: const ValueKey('users-reset-pin'),
                      label: l10n.usersResetPin,
                      value: '',
                      issue: issues[StaffFormField.resetPin],
                      onChange: vm.setResetPin,
                    ),
                    _PinField(
                      key: const ValueKey('users-reset-retype'),
                      label: l10n.usersResetRetype,
                      value: '',
                      issue: issues[StaffFormField.resetRetype],
                      onChange: vm.setResetRetype,
                    ),
                  ],
                ),
              ),
              if (vm.resetPin.completed)
                FAlert(
                  key: const ValueKey('users-reset-done'),
                  title: Text(l10n.usersResetDone),
                )
              else if (vm.resetPin.result case Error(:final error)
                  when error is! StaffFormInvalid)
                _errorText(
                  context,
                  usersErrorMessage(l10n, error),
                  key: const ValueKey('users-reset-error'),
                ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FButton(
                  key: const ValueKey('users-reset-submit'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: vm.resetPin.running ? null : vm.resetPin.execute,
                  prefix: const Icon(TablerIcons.key),
                  child: Flexible(child: Text(l10n.usersResetSubmit)),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}
