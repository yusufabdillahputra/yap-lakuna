import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/session_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/breakpoints.dart';
import 'login_view_model.dart';

/// Layar 1.2 *Login & ganti kasir*. Memiliki [LoginViewModel] dan memuat
/// daftar staf saat dibuka.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.session, required this.store});

  final SessionRepository session;
  final StoreRepository store;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final _viewModel = LoginViewModel(session: widget.session);

  @override
  void initState() {
    super.initState();
    _viewModel.load.execute();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      LoginView(viewModel: _viewModel, store: widget.store.current);
}

/// Nama role untuk ditampilkan: role bawaan dari terjemahan, role custom
/// memakai [roleName], selain itu kuncinya apa adanya.
String roleLabel(
  AppLocalizations l10n,
  String roleKey, [
  String? roleName,
]) => switch (roleKey) {
  'owner' => l10n.roleOwner,
  'manager' => l10n.roleManager,
  'cashier' => l10n.roleCashier,
  'waiter' => l10n.roleWaiter,
  'stock_keeper' => l10n.roleStockKeeper,
  _ => roleName ?? roleKey,
};

String _errorText(AppLocalizations l10n, LoginViewModel vm, Exception e) =>
    switch (e) {
      WrongPin(:final remainingAttempts) => l10n.loginWrongPin(
        remainingAttempts,
      ),
      CredentialsLocked(:final retryAfter) => l10n.loginLocked(
        vm.lockSecondsLeft ?? retryAfter.inSeconds,
      ),
      WrongCredentials() => l10n.loginWrongCredentials,
      StaffUnavailable() => l10n.loginStaffUnavailable,
      _ => l10n.loginFailed,
    };

/// Pesan di kartu PIN/pemilik: hitung mundur selama dikunci (juga saat
/// kembali ke staf atau email yang masih dikunci), selain itu galat terakhir.
String? _message(AppLocalizations l10n, LoginViewModel vm, Exception? error) {
  if (vm.lockSecondsLeft case final seconds?) return l10n.loginLocked(seconds);
  return error == null ? null : _errorText(l10n, vm, error);
}

/// "Siapa yang bertugas?": grid staf di kiri dan kartu PIN di kanan
/// (tablet/desktop), atau satu kolom bergantian (mobile).
class LoginView extends StatelessWidget {
  const LoginView({super.key, required this.viewModel, required this.store});

  final LoginViewModel viewModel;
  final StoreContext? store;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || viewModel.passwordMode) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace) {
      viewModel.backspace();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      viewModel.clearPin();
      return KeyEventResult.handled;
    }
    final char = event.character;
    if (char != null && char.length == 1 && '0123456789'.contains(char)) {
      viewModel.addDigit(int.parse(char));
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ColoredBox(
      color: theme.colors.background,
      child: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: _onKey,
          child: ListenableBuilder(
            listenable: Listenable.merge([
              viewModel,
              viewModel.load,
              viewModel.submitPin,
              viewModel.submitPassword,
            ]),
            builder: (context, _) => LayoutBuilder(
              builder: (context, constraints) {
                final mobile =
                    LayoutSize.of(constraints.maxWidth) == LayoutSize.mobile;
                return mobile ? _mobile(context) : _wide(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _wide(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(32),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _StaffPanel(
                viewModel: viewModel,
                store: store,
                showOwnerLink: true,
              ),
            ),
            const SizedBox(width: 32),
            SizedBox(
              width: 360,
              child: viewModel.passwordMode
                  ? _OwnerCard(viewModel: viewModel)
                  : _PinCard(viewModel: viewModel),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _mobile(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pickable = viewModel.staff.where((s) => s.hasPin).length;
    final Widget child;
    if (viewModel.passwordMode) {
      child = _OwnerCard(viewModel: viewModel);
    } else if (viewModel.selected != null) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ContextLine(store: store),
          const SizedBox(height: 16),
          _PinCard(viewModel: viewModel),
          const SizedBox(height: 8),
          if (pickable > 1)
            FButton(
              key: const ValueKey('login-back-to-staff'),
              variant: .ghost,
              prefix: const Icon(TablerIcons.arrowLeft),
              onPress: viewModel.clearSelection,
              child: Flexible(child: Text(l10n.loginBackToStaff)),
            ),
          _OwnerLink(viewModel: viewModel),
        ],
      );
    } else {
      child = _StaffPanel(
        viewModel: viewModel,
        store: store,
        showOwnerLink: true,
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _ContextLine extends StatelessWidget {
  const _ContextLine({required this.store});

  final StoreContext? store;

  @override
  Widget build(BuildContext context) {
    final ctx = store;
    if (ctx == null) return const SizedBox.shrink();
    final theme = context.theme;
    return Text(
      '${ctx.tenant.name} · ${ctx.outlet.name} · ${ctx.device.name}',
      key: const ValueKey('login-context'),
      style: theme.typography.body.sm.copyWith(
        color: theme.colors.mutedForeground,
      ),
    );
  }
}

class _OwnerLink extends StatelessWidget {
  const _OwnerLink({required this.viewModel});

  final LoginViewModel viewModel;

  @override
  Widget build(BuildContext context) => FButton(
    key: const ValueKey('login-owner-link'),
    variant: .ghost,
    mainAxisSize: .min,
    prefix: const Icon(TablerIcons.mail),
    onPress: viewModel.showPasswordForm,
    // Flexible: teks panjang dibungkus di ponsel, bukan meluap.
    child: Flexible(child: Text(AppLocalizations.of(context).loginOwnerLink)),
  );
}

class _StaffPanel extends StatelessWidget {
  const _StaffPanel({
    required this.viewModel,
    required this.store,
    required this.showOwnerLink,
  });

  final LoginViewModel viewModel;
  final StoreContext? store;
  final bool showOwnerLink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ContextLine(store: store),
        const SizedBox(height: 8),
        Text(
          l10n.loginTitle,
          style: theme.typography.display.xl2.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colors.foreground,
          ),
        ),
        const SizedBox(height: 24),
        if (viewModel.load.error)
          FAlert(
            key: const ValueKey('login-load-error'),
            variant: .destructive,
            title: Text(l10n.loginLoadFailed),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FButton(
                  size: .sm,
                  mainAxisSize: .min,
                  variant: .outline,
                  onPress: viewModel.load.execute,
                  child: Text(l10n.loginRetry),
                ),
              ),
            ),
          )
        else if (viewModel.load.running && viewModel.staff.isEmpty)
          const Center(child: FCircularProgress())
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = (constraints.maxWidth / 200).floor().clamp(1, 3);
              const gap = 12.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final s in viewModel.staff)
                    SizedBox(
                      width: width,
                      child: _StaffTile(
                        staff: s,
                        selected:
                            !viewModel.passwordMode &&
                            viewModel.selected?.id == s.id,
                        onPress: () => viewModel.select(s),
                      ),
                    ),
                ],
              );
            },
          ),
        if (showOwnerLink) ...[
          const SizedBox(height: 16),
          _OwnerLink(viewModel: viewModel),
        ],
      ],
    );
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({
    required this.staff,
    required this.selected,
    required this.onPress,
  });

  final StaffProfile staff;
  final bool selected;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final colors = theme.colors;
    return FTappable(
      key: ValueKey('staff-${staff.id}'),
      semanticsLabel:
          '${staff.name}, ${roleLabel(l10n, staff.roleKey, staff.roleName)}',
      selected: selected,
      onPress: staff.hasPin ? onPress : null,
      builder: (context, variants, _) {
        final hovered =
            variants.contains(FTappableVariant.hovered) ||
            variants.contains(FTappableVariant.pressed);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          // Bingkai terpilih 2 px: padding dikurangi agar ukuran tetap.
          padding: EdgeInsets.all(selected ? 15 : 16),
          decoration: BoxDecoration(
            color: hovered && staff.hasPin ? colors.secondary : colors.card,
            borderRadius: theme.style.borderRadius.lg,
            border: Border.all(
              color: selected ? colors.foreground : colors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              FAvatar.raw(size: 44, child: Text(staffInitials(staff.name))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.md.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.foreground,
                      ),
                    ),
                    Text(
                      staff.hasPin
                          ? roleLabel(l10n, staff.roleKey, staff.roleName)
                          : l10n.loginNoPin,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PinCard extends StatelessWidget {
  const _PinCard({required this.viewModel});

  final LoginViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final colors = theme.colors;
    final selected = viewModel.selected;
    final error = switch (viewModel.submitPin.result) {
      Error(:final error) => error,
      _ => null,
    };
    final enabled =
        selected != null && !viewModel.locked && !viewModel.submitPin.running;
    Widget key(String id, Widget label, VoidCallback onPress, {String? hint}) =>
        SizedBox(
          height: 64,
          child: FButton(
            key: ValueKey('pin-key-$id'),
            variant: .outline,
            semanticsLabel: hint,
            onPress: enabled ? onPress : null,
            // Label diperkecil bila tombol sempit (mis. "Cancel" di ponsel).
            child: Flexible(
              child: FittedBox(fit: BoxFit.scaleDown, child: label),
            ),
          ),
        );
    Widget digit(int d) => key(
      '$d',
      // Hanya ukuran: warna mengikuti tombol agar keadaan nonaktif terlihat.
      Text('$d', style: TextStyle(fontSize: theme.typography.body.xl.fontSize)),
      () => viewModel.addDigit(d),
    );
    return FCard(
      key: const ValueKey('pin-card'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              selected == null
                  ? l10n.loginSelectStaff
                  : l10n.loginEnterPinFor(selected.name),
              textAlign: TextAlign.center,
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.foreground,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              key: const ValueKey('pin-dots'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pinLength; i++)
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < viewModel.pin.length
                          ? colors.foreground
                          : null,
                      border: Border.all(
                        color: colors.mutedForeground,
                        width: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (viewModel.submitPin.running)
              const Center(child: FCircularProgress())
            else if (_message(l10n, viewModel, error) case final message?)
              FAlert(
                key: const ValueKey('login-error'),
                variant: .destructive,
                title: Text(message),
              ),
            const SizedBox(height: 16),
            for (final row in const [
              [1, 2, 3],
              [4, 5, 6],
              [7, 8, 9],
            ]) ...[
              Row(
                children: [
                  for (final d in row) ...[
                    Expanded(child: digit(d)),
                    if (d != row.last) const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Expanded(
                  child: key(
                    'cancel',
                    Text(l10n.loginKeypadCancel),
                    viewModel.clearPin,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: digit(0)),
                const SizedBox(width: 8),
                Expanded(
                  child: key(
                    'delete',
                    const Icon(TablerIcons.backspace),
                    viewModel.backspace,
                    hint: l10n.loginKeypadDelete,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.loginPinNote,
              textAlign: TextAlign.center,
              style: theme.typography.body.sm.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  const _OwnerCard({required this.viewModel});

  final LoginViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final error = switch (viewModel.submitPassword.result) {
      Error(:final error) => error,
      _ => null,
    };
    final canSubmit =
        viewModel.canSubmitPassword && !viewModel.submitPassword.running;
    return FCard(
      key: const ValueKey('owner-card'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.loginOwnerTitle,
              style: theme.typography.body.lg.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colors.foreground,
              ),
            ),
            const SizedBox(height: 16),
            FTextField(
              key: const ValueKey('login-email'),
              label: Text(l10n.fieldEmail),
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              control: .managed(
                initial: TextEditingValue(text: viewModel.email),
                onChange: (v) => viewModel.setEmail(v.text),
              ),
            ),
            const SizedBox(height: 12),
            FTextField(
              key: const ValueKey('login-password'),
              label: Text(l10n.fieldPassword),
              obscureText: true,
              onSubmit: (_) {
                if (canSubmit) viewModel.submitPassword.execute();
              },
              control: .managed(
                onChange: (v) => viewModel.setPassword(v.text),
              ),
            ),
            const SizedBox(height: 16),
            if (_message(l10n, viewModel, error) case final message?) ...[
              FAlert(
                key: const ValueKey('login-error'),
                variant: .destructive,
                title: Text(message),
              ),
              const SizedBox(height: 16),
            ],
            FButton(
              key: const ValueKey('login-submit'),
              onPress: canSubmit ? viewModel.submitPassword.execute : null,
              prefix: viewModel.submitPassword.running
                  ? const FCircularProgress()
                  : null,
              child: Text(l10n.loginSubmit),
            ),
            const SizedBox(height: 8),
            FButton(
              key: const ValueKey('login-back-to-pin'),
              variant: .ghost,
              prefix: const Icon(TablerIcons.arrowLeft),
              onPress: viewModel.showPinForm,
              child: Text(l10n.loginBackToPin),
            ),
          ],
        ),
      ),
    );
  }
}
