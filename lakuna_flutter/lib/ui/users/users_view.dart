import 'dart:async';

import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart' show UuidValue;
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/session_repository.dart';
import '../../data/repositories/users_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../login/login_view.dart' show roleLabel;
import '../products/product_widgets.dart';
import 'users_labels.dart';
import 'users_view_model.dart';

part 'staff_dialog.dart';
part 'roles_matrix.dart';

/// Di bawah lebar ini daftar pengguna tampil sebagai kartu.
const _tableWidth = 720.0;

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

TextStyle _strong(BuildContext context) =>
    context.theme.typography.body.sm.copyWith(fontWeight: FontWeight.w600);

Widget _errorText(BuildContext context, String text, {Key? key}) => Text(
  text,
  key: key,
  style: context.theme.typography.body.sm.copyWith(
    color: context.theme.colors.destructive,
  ),
);

/// Layar *Pengguna & role* (1.25, F1-17), izin `users:manage`.
class UsersScreen extends StatefulWidget {
  const UsersScreen({
    super.key,
    required this.repository,
    required this.session,
    required this.outletName,
  });

  final UsersRepository repository;
  final SessionRepository session;
  final String outletName;

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late final _vm = UsersViewModel(
    repository: widget.repository,
    actor: widget.session.current,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_vm.load.execute());
  }

  /// Memperbarui hitung mundur kunci PIN tiap detik selama ada yang dikunci.
  Timer? _lockTicker;
  Map<UuidValue, int> _shownLocks = const {};

  Map<UuidValue, int> _lockSnapshot() => {
    for (final a in _vm.accounts)
      if (_vm.lockedFor(a) case final d?) a.id: d.inSeconds,
  };

  void _syncLockTicker() {
    if (_vm.anyLocked) {
      _lockTicker ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final now = _lockSnapshot();
        // Bangun ulang hanya bila angka hitung mundur berubah.
        if (!mapEquals(now, _shownLocks)) setState(() {});
        if (!_vm.anyLocked) {
          _lockTicker?.cancel();
          _lockTicker = null;
        }
      });
    }
  }

  @override
  void dispose() {
    _lockTicker?.cancel();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _openStaff({StaffAccount? account}) async {
    final form = StaffFormViewModel(
      repository: widget.repository,
      roles: _vm.roles,
      account: account,
      actor: widget.session.current,
    );
    await showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 480),
        builder: (context, style) => ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: _StaffDialog(viewModel: form),
        ),
      ),
    );
    form.dispose();
    if (!mounted) return;
    // Reset PIN juga mengubah status kunci, jadi daftar selalu dimuat ulang.
    unawaited(_vm.load.execute());
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final vm = _vm;
      final loaded = vm.load.completed || vm.roles.isNotEmpty;
      _shownLocks = _lockSnapshot();
      _syncLockTicker();
      return SingleChildScrollView(
        key: const ValueKey('users-scroll'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            PageHeader(
              title: l10n.menuUsers,
              subtitle: l10n.usersSubtitle,
              action: vm.tab == UsersTab.users && loaded
                  ? FButton(
                      key: const ValueKey('users-add'),
                      mainAxisSize: .min,
                      onPress: _openStaff,
                      prefix: const Icon(TablerIcons.userPlus),
                      child: Flexible(child: Text(l10n.usersAdd)),
                    )
                  : null,
            ),
            if (vm.load.result case Error(:final error))
              LoadFailedAlert(
                key: const ValueKey('users-error'),
                message: usersErrorMessage(l10n, error),
                onRetry: vm.load.execute,
              )
            else if (!loaded)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: FCircularProgress()),
              )
            else ...[
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FTabs(
                  key: const ValueKey('users-tabs'),
                  scrollable: true,
                  control: .lifted(
                    index: vm.tab.index,
                    onChange: (i) => vm.setTab(UsersTab.values[i]),
                  ),
                  children: [
                    for (final tab in UsersTab.values)
                      FTabEntry(
                        label: Text(
                          switch (tab) {
                            UsersTab.users => l10n.usersTabUsers,
                            UsersTab.roles => l10n.usersTabRoles,
                          },
                          key: ValueKey('users-tab-${tab.name}'),
                        ),
                        child: const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
              switch (vm.tab) {
                UsersTab.users => _UserList(
                  viewModel: vm,
                  outletName: widget.outletName,
                  onOpen: (a) => _openStaff(account: a),
                ),
                UsersTab.roles => _RolesMatrix(viewModel: vm),
              },
            ],
          ],
        ),
      );
    },
  );
}

class _UserList extends StatelessWidget {
  const _UserList({
    required this.viewModel,
    required this.outletName,
    required this.onOpen,
  });

  final UsersViewModel viewModel;
  final String outletName;
  final ValueChanged<StaffAccount> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    return SectionCard(
      title: l10n.usersListTitle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final table = constraints.maxWidth >= _tableWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              Text(
                l10n.usersListCount(outletName, vm.activeCount),
                key: const ValueKey('users-count'),
                style: _muted(context),
              ),
              if (table) const _HeaderRow(),
              for (final a in vm.accounts)
                _UserRow(
                  key: ValueKey('users-row-${a.id.uuid}'),
                  viewModel: vm,
                  account: a,
                  outletName: outletName,
                  table: table,
                  onOpen: vm.canManage(a) ? () => onOpen(a) : null,
                ),
              if (vm.accounts.length <= 1)
                Text(l10n.usersEmpty, style: _muted(context)),
              if (vm.unlock.result case Error(:final error))
                _errorText(context, usersErrorMessage(l10n, error)),
              FAlert(
                title: Text(l10n.usersResetHint),
                subtitle: Text(l10n.usersOwnerHint),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = _muted(
      context,
    ).copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.3);
    return Row(
      spacing: 12,
      children: [
        Expanded(flex: 4, child: Text(l10n.usersColUser, style: style)),
        Expanded(flex: 2, child: Text(l10n.usersColRole, style: style)),
        Expanded(flex: 2, child: Text(l10n.usersColOutlet, style: style)),
        Expanded(flex: 3, child: Text(l10n.usersColStatus, style: style)),
      ],
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    super.key,
    required this.viewModel,
    required this.account,
    required this.outletName,
    required this.table,
    required this.onOpen,
  });

  final UsersViewModel viewModel;
  final StaffAccount account;
  final String outletName;
  final bool table;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final a = account;
    final locked = viewModel.lockedFor(a);
    final user = Row(
      spacing: 10,
      children: [
        FAvatar.raw(size: 36, child: Text(staffInitials(a.name))),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.name, style: _strong(context)),
              Text(
                a.email ?? (a.hasPin ? l10n.usersPinOnly : l10n.loginNoPin),
                style: _muted(context),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
    final role = Text(
      roleLabel(l10n, a.roleKey, a.roleName),
      style: theme.typography.body.sm,
    );
    final outlet = Text(
      a.isOwner ? l10n.usersAllOutlets : outletName,
      style: theme.typography.body.sm,
    );
    final status = Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FBadge(
          key: ValueKey('users-status-${a.id.uuid}'),
          variant: locked != null
              ? .destructive
              : (a.isActive ? .primary : .secondary),
          child: Text(
            locked != null
                ? l10n.usersStatusLocked(locked.inSeconds)
                : (a.isActive
                      ? l10n.usersStatusActive
                      : l10n.usersStatusInactive),
          ),
        ),
        if (locked != null && viewModel.canManage(a))
          FButton(
            key: ValueKey('users-unlock-${a.id.uuid}'),
            size: .sm,
            variant: .outline,
            mainAxisSize: .min,
            onPress: viewModel.unlock.running
                ? null
                : () => viewModel.unlock.execute(a.id),
            prefix: const Icon(TablerIcons.lockOpen),
            child: Flexible(child: Text(l10n.usersUnlock)),
          ),
      ],
    );
    final content = table
        ? Row(
            spacing: 12,
            children: [
              Expanded(flex: 4, child: user),
              Expanded(flex: 2, child: role),
              Expanded(flex: 2, child: outlet),
              Expanded(flex: 3, child: status),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              user,
              Wrap(
                spacing: 8,
                children: [
                  role,
                  Text('·', style: _muted(context)),
                  outlet,
                ],
              ),
              status,
            ],
          );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: FTappable(
        onPress: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: content,
        ),
      ),
    );
  }
}
