import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalCupertinoLocalizations, GlobalWidgetsLocalizations;
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/app_settings_repository.dart'
    show supportedAppLocales;
import '../../data/repositories/web_join_repository.dart';
import '../../data/services/web_session_store.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/theme/theme.dart';
import '../hosting/hosting_texts.dart';
import 'web_join_view.dart';
import 'web_login_view_model.dart';
import 'web_password_reset_view.dart';

/// Build web lepas (tidak disajikan server toko): layar masuk menampilkan
/// isian *Alamat server*. Build dari paket VPS memakai asal halaman.
const webStandalone = bool.fromEnvironment('LAKUNA_WEB_STANDALONE');

/// Lebar mulai dua kolom di layar login 2.2.
const _twoColumnWidth = 600.0;

/// Aplikasi kecil layar login web 2.2, dipakai sebelum database toko
/// terbuka: tema mengikuti sistem, bahasa mengikuti browser dan bisa
/// diganti di layar ini.
class WebLoginApp extends StatefulWidget {
  const WebLoginApp({
    super.key,
    required this.join,
    required this.login,
    required this.sessions,
    required this.onJoined,
    this.initialServer = '',
    this.showServerField = webStandalone,
    this.reload,
    this.locale,
  });

  /// Gabung kode pasang dan pull pertama.
  final WebJoinRepository join;
  final WebLoginRepository login;
  final WebSessionStore sessions;
  final Future<void> Function() onJoined;
  final String initialServer;
  final bool showServerField;
  final Future<void> Function()? reload;

  /// Bahasa awal (tes); bawaan mengikuti browser.
  final Locale? locale;

  @override
  State<WebLoginApp> createState() => _WebLoginAppState();
}

class _WebLoginAppState extends State<WebLoginApp> {
  late Locale? _locale = widget.locale;

  @override
  Widget build(BuildContext context) {
    final light = lakunaLightTheme(touch: false);
    final dark = lakunaDarkTheme(touch: false);
    return MaterialApp(
      title: 'Lakuna',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...FLocalizations.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: lakunaMaterialTheme(light),
      darkTheme: lakunaMaterialTheme(dark),
      builder: (context, child) => FTheme(
        data: Theme.brightnessOf(context) == Brightness.light ? light : dark,
        child: child!,
      ),
      home: WebLoginView(
        join: widget.join,
        login: widget.login,
        sessions: widget.sessions,
        onJoined: widget.onJoined,
        initialServer: widget.initialServer,
        showServerField: widget.showServerField,
        reload: widget.reload,
        onLocale: (l) => setState(() => _locale = l),
      ),
    );
  }
}

enum _Mode { login, pairing, reset }

/// Layar login web 2.2: kolom kiri Sky (judul dan lencana), kolom kanan
/// *Masuk* lalu kartu verifikasi; menumpuk di bawah 600 px. Pull pertama
/// dan gabung kode pasang memakai [WebJoinView].
class WebLoginView extends StatefulWidget {
  const WebLoginView({
    super.key,
    required this.join,
    required this.login,
    required this.sessions,
    required this.onJoined,
    required this.onLocale,
    this.initialServer = '',
    this.showServerField = false,
    this.reload,
  });

  final WebJoinRepository join;
  final WebLoginRepository login;
  final WebSessionStore sessions;
  final Future<void> Function() onJoined;
  final ValueChanged<Locale> onLocale;
  final String initialServer;
  final bool showServerField;
  final Future<void> Function()? reload;

  @override
  State<WebLoginView> createState() => _WebLoginViewState();
}

class _WebLoginViewState extends State<WebLoginView> {
  late final _vm = WebLoginViewModel(
    repository: widget.login,
    sessions: widget.sessions,
    initialServer: widget.initialServer,
  );
  var _mode = _Mode.login;

  /// Naik saat kembali dari *Menyiapkan data toko*, agar [WebJoinView]
  /// dibuat ulang.
  var _joinRevision = 0;

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      if (_vm.step == WebLoginStep.preparing || _mode == _Mode.pairing) {
        return WebJoinView(
          key: ValueKey('web-join-view-$_joinRevision'),
          repository: widget.join,
          sessions: widget.sessions,
          onJoined: widget.onJoined,
          initialServer: _vm.serverUrl,
          reload: widget.reload,
          onCancelled: () => setState(() {
            _vm.back();
            _mode = _Mode.login;
            _joinRevision++;
          }),
          onUseLogin: () => setState(() => _mode = _Mode.login),
        );
      }
      final form = switch (_mode) {
        _Mode.reset => WebPasswordResetCard(
          repository: widget.login,
          serverUrl: _vm.serverUrl,
          email: _vm.email,
          onClose: () => setState(() => _mode = _Mode.login),
        ),
        _ =>
          _vm.step == WebLoginStep.secondFactor
              ? _SecondFactorCard(vm: _vm)
              : _CredentialsCard(
                  vm: _vm,
                  showServerField: widget.showServerField,
                  onForgot: () => setState(() => _mode = _Mode.reset),
                  onPairing: () => setState(() => _mode = _Mode.pairing),
                ),
      };
      return _Layout(form: form, onLocale: widget.onLocale);
    },
  );
}

class _Layout extends StatelessWidget {
  const _Layout({required this.form, required this.onLocale});

  final Widget form;
  final ValueChanged<Locale> onLocale;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ColoredBox(
      color: theme.colors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= _twoColumnWidth;
          final right = SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    key: const ValueKey('web-login-form'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      form,
                      _LanguagePicker(onLocale: onLocale),
                    ],
                  ),
                ),
              ),
            ),
          );
          if (wide) {
            // Tablet sempit: kolom formulir lebih lebar dari kolom Sky.
            final compact = constraints.maxWidth < 960;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: compact ? 2 : 1,
                  child: _Hero(wide: true, compact: compact),
                ),
                Expanded(flex: compact ? 3 : 1, child: right),
              ],
            );
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Hero(wide: false, compact: true),
                // Kolom kanan sudah bisa digulir sendiri di layar lebar;
                // di sini halaman yang digulir.
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    key: const ValueKey('web-login-form'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      form,
                      _LanguagePicker(onLocale: onLocale),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Kolom kiri Sky: merek, judul, dan lencana fitur.
class _Hero extends StatelessWidget {
  const _Hero({required this.wide, required this.compact});

  final bool wide;

  /// Kolom sempit: huruf dan jarak lebih kecil.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final ink = theme.colors.primaryForeground;
    Widget badge(IconData icon, String text) => DecoratedBox(
      decoration: BoxDecoration(
        color: ink.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            Icon(icon, size: 14, color: ink),
            Flexible(
              child: Text(
                text,
                style: theme.typography.body.xs.copyWith(color: ink),
              ),
            ),
          ],
        ),
      ),
    );
    return ColoredBox(
      key: const ValueKey('web-login-hero'),
      color: theme.colors.primary,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(compact ? (wide ? 24 : 20) : 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: wide ? 20 : 12,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Icon(TablerIcons.buildingStore, color: ink, size: 28),
                    Text(
                      'Lakuna',
                      style: theme.typography.display.xl.copyWith(
                        color: ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Text(
                  l10n.webLoginHeadline,
                  style:
                      (!compact
                              ? theme.typography.display.xl3
                              : wide
                              ? theme.typography.display.xl2
                              : theme.typography.display.xl)
                          .copyWith(
                            color: ink,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                ),
                if (wide)
                  Text(
                    l10n.webLoginTagline,
                    style: theme.typography.body.md.copyWith(
                      color: ink.withValues(alpha: 0.85),
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    badge(
                      TablerIcons.buildingStore,
                      l10n.webLoginBadgeBranches,
                    ),
                    badge(TablerIcons.refresh, l10n.webLoginBadgeSync),
                    badge(TablerIcons.shieldLock, l10n.webLoginBadgeSecure),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({required this.onLocale});

  final ValueChanged<Locale> onLocale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final current = Localizations.localeOf(context).languageCode;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Icon(
          TablerIcons.language,
          size: 16,
          semanticLabel: l10n.webLoginLanguage,
          color: context.theme.colors.mutedForeground,
        ),
        for (final (code, label) in const [
          ('id', 'Indonesia'),
          ('en', 'English'),
        ])
          FButton(
            key: ValueKey('web-login-lang-$code'),
            variant: current == code ? .secondary : .ghost,
            size: .sm,
            mainAxisSize: .min,
            onPress: () => onLocale(Locale(code)),
            child: Text(label),
          ),
      ],
    );
  }
}

Exception? _error(Result<void>? result) => switch (result) {
  Error(:final error) => error,
  _ => null,
};

class _CredentialsCard extends StatelessWidget {
  const _CredentialsCard({
    required this.vm,
    required this.showServerField,
    required this.onForgot,
    required this.onPairing,
  });

  final WebLoginViewModel vm;
  final bool showServerField;
  final VoidCallback onForgot;
  final VoidCallback onPairing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final error = _error(vm.submitCredentials.result);
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AutofillGroup(
          child: Column(
            key: const ValueKey('web-login'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                l10n.webLoginTitle,
                style: theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                l10n.webLoginBody,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              if (showServerField)
                FTextField(
                  key: const ValueKey('web-login-server'),
                  label: Text(l10n.webJoinServerLabel),
                  hint: l10n.hostingServerUrlHint,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  enabled: !vm.busy,
                  control: .managed(
                    initial: TextEditingValue(text: vm.serverUrl),
                    onChange: (v) => vm.setServer(v.text),
                  ),
                ),
              FTextField(
                key: const ValueKey('web-login-email'),
                label: Text(l10n.webLoginEmail),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                enabled: !vm.busy,
                control: .managed(
                  initial: TextEditingValue(text: vm.email),
                  onChange: (v) => vm.setEmail(v.text),
                ),
              ),
              FTextField(
                key: const ValueKey('web-login-password'),
                label: Text(l10n.webLoginPassword),
                obscureText: true,
                autocorrect: false,
                autofillHints: const [AutofillHints.password],
                enabled: !vm.busy,
                onSubmit: (_) {
                  if (vm.canSubmitCredentials) vm.submitCredentials.execute();
                },
                control: .managed(
                  initial: TextEditingValue(text: vm.password),
                  onChange: (v) => vm.setPassword(v.text),
                ),
              ),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  FCheckbox(
                    key: const ValueKey('web-login-remember'),
                    label: Text(l10n.webLoginRemember),
                    value: vm.remember,
                    onChange: vm.busy ? null : vm.setRemember,
                  ),
                  FButton(
                    key: const ValueKey('web-login-forgot'),
                    variant: .ghost,
                    size: .sm,
                    mainAxisSize: .min,
                    onPress: vm.busy ? null : onForgot,
                    child: Text(l10n.webLoginForgot),
                  ),
                ],
              ),
              if (error != null)
                Text(
                  hostingErrorText(l10n, error),
                  key: const ValueKey('web-login-error'),
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.destructive,
                  ),
                ),
              FButton(
                key: const ValueKey('web-login-submit'),
                onPress: vm.canSubmitCredentials
                    ? vm.submitCredentials.execute
                    : null,
                prefix: vm.submitCredentials.running
                    ? const FCircularProgress()
                    : const Icon(TablerIcons.login2),
                child: Text(l10n.webLoginTitle),
              ),
              Text(
                l10n.webLoginNote,
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              FButton(
                key: const ValueKey('web-login-pairing'),
                variant: .ghost,
                size: .sm,
                onPress: vm.busy ? null : onPairing,
                child: Text(l10n.webLoginPairingLink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondFactorCard extends StatelessWidget {
  const _SecondFactorCard({required this.vm});

  final WebLoginViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final error = _error(vm.submitCode.result);
    final tenants = vm.tenants;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          key: const ValueKey('web-login-code-step'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(TablerIcons.shieldLock, color: theme.colors.primary),
                Expanded(
                  child: Text(
                    l10n.webLoginCodeTitle,
                    style: theme.typography.display.lg.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              l10n.webLoginCodeBody,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            if (tenants.length > 1)
              FSelect<String>(
                key: const ValueKey('web-login-tenant'),
                label: Text(l10n.webLoginTenantLabel),
                enabled: !vm.busy,
                items: _tenantItems(tenants),
                control: .managed(
                  initial: vm.tenantId?.uuid,
                  onChange: (v) {
                    if (v != null) vm.selectTenant(UuidValue.fromString(v));
                  },
                ),
              ),
            FTextField(
              key: const ValueKey('web-login-code'),
              label: Text(l10n.webLoginCodeLabel),
              autocorrect: false,
              autofocus: true,
              keyboardType: TextInputType.visiblePassword,
              autofillHints: const [AutofillHints.oneTimeCode],
              // Tetap aktif saat memeriksa: isian yang dinonaktifkan
              // kehilangan fokus, padahal kode berikutnya diketik di sini.
              // Enter tidak melepas fokus: bila kode salah, kode berikutnya
              // langsung diketik di sini.
              onEditingComplete: () {},
              onSubmit: (_) {
                if (vm.canSubmitCode) vm.submitCode.execute();
              },
              control: .managed(
                initial: TextEditingValue(text: vm.code),
                onChange: (v) => vm.setCode(v.text),
              ),
            ),
            if (error != null)
              Text(
                hostingErrorText(l10n, error),
                key: const ValueKey('web-login-code-error'),
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.destructive,
                ),
              ),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                FButton(
                  key: const ValueKey('web-login-back'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: vm.busy ? null : vm.back,
                  child: Text(l10n.webLoginBack),
                ),
                FButton(
                  key: const ValueKey('web-login-code-submit'),
                  mainAxisSize: .min,
                  onPress: vm.canSubmitCode ? vm.submitCode.execute : null,
                  prefix: vm.submitCode.running
                      ? const FCircularProgress()
                      : const Icon(TablerIcons.check),
                  child: Text(l10n.webLoginCodeSubmit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Nama toko → id; nama kembar diberi nomor.
Map<String, String> _tenantItems(List<WebTenant> tenants) {
  final items = <String, String>{};
  for (final t in tenants) {
    var label = t.name;
    for (var n = 2; items.containsKey(label); n++) {
      label = '${t.name} ($n)';
    }
    items[label] = t.tenantId.uuid;
  }
  return items;
}
