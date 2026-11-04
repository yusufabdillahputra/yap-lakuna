part of 'users_view.dart';

const _permissionColumnWidth = 260.0;
const _roleColumnWidth = 116.0;

/// Tab *Role & izin*: matriks izin per role (1.25) + role custom.
class _RolesMatrix extends StatelessWidget {
  const _RolesMatrix({required this.viewModel});

  final UsersViewModel viewModel;

  Future<void> _roleDialog(BuildContext context, {RoleSummary? role}) async {
    final vm = viewModel;
    (role == null ? vm.createRole : vm.renameRole).clearResult();
    await showFDialog<void>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
        builder: (context, style) => _RoleNameDialog(viewModel: vm, role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final roles = vm.roles;
    final width = _permissionColumnWidth + roles.length * _roleColumnWidth;
    final border = BorderSide(color: theme.colors.border);

    Widget header(RoleSummary r) => SizedBox(
      key: ValueKey('users-role-${r.key}'),
      width: _roleColumnWidth,
      child: Column(
        spacing: 2,
        children: [
          Text(
            roleLabel(l10n, r.key, r.name),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _strong(context),
          ),
          Text(l10n.usersMatrixMembers(r.memberCount), style: _muted(context)),
          if (r.isCustom && vm.canEdit(r))
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FButton.icon(
                  key: ValueKey('users-role-rename-${r.key}'),
                  variant: .ghost,
                  onPress: () => _roleDialog(context, role: r),
                  child: const Icon(TablerIcons.pencil, size: 16),
                ),
                FButton.icon(
                  key: ValueKey('users-role-delete-${r.key}'),
                  variant: .ghost,
                  onPress: vm.deleteRole.running
                      ? null
                      : () => vm.deleteRole.execute(r.key),
                  child: Icon(
                    TablerIcons.trash,
                    size: 16,
                    color: theme.colors.destructive,
                  ),
                ),
              ],
            ),
        ],
      ),
    );

    final matrix = SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _permissionColumnWidth,
                  child: Text(
                    l10n.usersMatrixPermission,
                    style: _muted(context)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                for (final r in roles) header(r),
              ],
            ),
          ),
          for (final p in Permission.values)
            DecoratedBox(
              decoration: BoxDecoration(border: Border(top: border)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: _permissionColumnWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            permissionLabel(l10n, p),
                            style: theme.typography.body.sm,
                          ),
                          Text(
                            p.key,
                            style: _muted(
                              context,
                            ).copyWith(fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                    for (final r in roles)
                      SizedBox(
                        width: _roleColumnWidth,
                        child: Center(
                          child: FCheckbox(
                            key: ValueKey('users-perm-${r.key}-${p.key}'),
                            semanticsLabel:
                                '${roleLabel(l10n, r.key, r.name)}: '
                                '${permissionLabel(l10n, p)}',
                            value: vm.permissionsOf(r.key).contains(p),
                            enabled: vm.canToggle(r, p),
                            onChange: (_) => vm.toggle(r.key, p),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    String? deleteError;
    if (vm.deleteRole.result case Error(:final error)) {
      deleteError = usersErrorMessage(l10n, error);
    }
    String? saveError;
    if (vm.saveMatrix.result case Error(:final error)) {
      saveError = usersErrorMessage(l10n, error);
    }

    return SectionCard(
      title: l10n.usersMatrixTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          SingleChildScrollView(
            key: const ValueKey('users-matrix-scroll'),
            scrollDirection: Axis.horizontal,
            child: matrix,
          ),
          if (deleteError != null)
            _errorText(
              context,
              deleteError,
              key: const ValueKey('users-role-delete-error'),
            ),
          if (saveError != null)
            _errorText(
              context,
              saveError,
              key: const ValueKey('users-matrix-error'),
            )
          else if (vm.saveMatrix.completed && !vm.dirty)
            FAlert(
              key: const ValueKey('users-matrix-saved'),
              title: Text(l10n.usersMatrixSaved),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              FButton(
                key: const ValueKey('users-role-new'),
                size: .sm,
                variant: .outline,
                mainAxisSize: .min,
                onPress: () => _roleDialog(context),
                prefix: const Icon(TablerIcons.plus),
                child: Flexible(child: Text(l10n.usersMatrixNewRole)),
              ),
              if (vm.dirty)
                FButton(
                  key: const ValueKey('users-matrix-discard'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: vm.discard,
                  child: Flexible(child: Text(l10n.usersMatrixDiscard)),
                ),
              FButton(
                key: const ValueKey('users-matrix-save'),
                mainAxisSize: .min,
                onPress: !vm.dirty || vm.saveMatrix.running
                    ? null
                    : vm.saveMatrix.execute,
                child: Flexible(child: Text(l10n.usersMatrixSave)),
              ),
            ],
          ),
          Text(l10n.usersMatrixNote, style: _muted(context)),
        ],
      ),
    );
  }
}

class _RoleNameDialog extends StatefulWidget {
  const _RoleNameDialog({required this.viewModel, this.role});

  final UsersViewModel viewModel;
  final RoleSummary? role;

  @override
  State<_RoleNameDialog> createState() => _RoleNameDialogState();
}

class _RoleNameDialogState extends State<_RoleNameDialog> {
  late var _name = widget.role?.name ?? '';
  var _submitted = false;

  Command<Object?> get _command => widget.role == null
      ? widget.viewModel.createRole
      : widget.viewModel.renameRole;

  Future<void> _save() async {
    setState(() => _submitted = true);
    if (staffNameIssue(_name) != null) return;
    final role = widget.role;
    if (role == null) {
      await widget.viewModel.createRole.execute(_name);
    } else {
      await widget.viewModel.renameRole.execute((role.key, _name));
    }
    if (!mounted) return;
    if (_command.completed) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final issue = _submitted ? staffNameIssue(_name) : null;
      final command = _command;
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          key: const ValueKey('users-role-form'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              widget.role == null
                  ? l10n.usersRoleNewTitle
                  : l10n.usersRoleRenameTitle,
              style: theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            FTextField(
              key: const ValueKey('users-role-name'),
              label: Text(l10n.usersRoleName),
              hint: l10n.usersRoleNameHint,
              autofocus: true,
              maxLength: staffNameMaxLength,
              error: issue == null ? null : Text(staffIssueLabel(l10n, issue)),
              control: .managed(
                initial: TextEditingValue(text: _name),
                onChange: (v) => setState(() => _name = v.text),
              ),
            ),
            if (command.result case Error(:final error))
              _errorText(
                context,
                usersErrorMessage(l10n, error),
                key: const ValueKey('users-role-error'),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                FButton(
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(context).pop(),
                  child: Flexible(child: Text(l10n.usersCancel)),
                ),
                FButton(
                  key: const ValueKey('users-role-save'),
                  mainAxisSize: .min,
                  onPress: command.running ? null : _save,
                  child: Flexible(
                    child: Text(
                      widget.role == null
                          ? l10n.usersRoleCreate
                          : l10n.usersRoleRename,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
