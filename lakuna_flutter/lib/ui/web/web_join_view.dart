import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalCupertinoLocalizations, GlobalWidgetsLocalizations;
import 'package:forui/forui.dart';
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
import 'web_join_view_model.dart';

/// Aplikasi kecil layar masuk web, dipakai sebelum database toko terbuka
/// (belum ada pengaturan tema dan bahasa toko, jadi mengikuti sistem).
class WebJoinApp extends StatelessWidget {
  const WebJoinApp({
    super.key,
    required this.repository,
    required this.sessions,
    required this.onJoined,
    this.initialServer = '',
    this.reload,
    this.locale,
  });

  final WebJoinRepository repository;
  final WebSessionStore sessions;
  final Future<void> Function() onJoined;
  final String initialServer;

  /// Bahasa tetap (tes); bawaan mengikuti browser.
  final Locale? locale;

  /// Memuat ulang halaman (Batal saat pull berjalan).
  final Future<void> Function()? reload;

  @override
  Widget build(BuildContext context) {
    final light = lakunaLightTheme(touch: false);
    final dark = lakunaDarkTheme(touch: false);
    return MaterialApp(
      title: 'Lakuna',
      debugShowCheckedModeBanner: false,
      locale: locale,
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
      home: WebJoinView(
        repository: repository,
        sessions: sessions,
        onJoined: onJoined,
        initialServer: initialServer,
        reload: reload,
      ),
    );
  }
}

/// Layar masuk web tahap 1 (kode pasang) dan *Menyiapkan data toko*.
class WebJoinView extends StatefulWidget {
  const WebJoinView({
    super.key,
    required this.repository,
    required this.sessions,
    required this.onJoined,
    this.initialServer = '',
    this.reload,
    this.onCancelled,
    this.onUseLogin,
  });

  final WebJoinRepository repository;
  final WebSessionStore sessions;
  final Future<void> Function() onJoined;
  final String initialServer;
  final Future<void> Function()? reload;

  /// *Batal* di *Menyiapkan data toko* selesai (login web kembali ke
  /// formulir masuk).
  final VoidCallback? onCancelled;

  /// Tautan *Masuk dengan akun pemilik* di bawah formulir kode pasang.
  final VoidCallback? onUseLogin;

  @override
  State<WebJoinView> createState() => _WebJoinViewState();
}

class _WebJoinViewState extends State<WebJoinView> {
  late final _vm = WebJoinViewModel(
    repository: widget.repository,
    sessions: widget.sessions,
    onJoined: widget.onJoined,
    initialServer: widget.initialServer,
    reload: widget.reload,
  );

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ColoredBox(
      color: theme.colors.background,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: ListenableBuilder(
                listenable: _vm,
                builder: (context, _) => FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _vm.preparing
                        ? _Preparing(vm: _vm, onCancelled: widget.onCancelled)
                        : _Form(vm: _vm, onUseLogin: widget.onUseLogin),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _errorText(AppLocalizations l10n, Exception error) => switch (error) {
  WebJoinNoOutlet() => l10n.webJoinNoOutlet,
  _ => hostingErrorText(l10n, error),
};

class _Form extends StatelessWidget {
  const _Form({required this.vm, this.onUseLogin});

  final WebJoinViewModel vm;
  final VoidCallback? onUseLogin;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final error = switch (vm.start.result) {
      Error(:final error) => error,
      _ => null,
    };
    return Column(
      key: const ValueKey('web-join'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          l10n.webJoinTitle,
          style: theme.typography.display.lg.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          l10n.webJoinBody,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        FTextField(
          key: ValueKey('web-join-server-${vm.serverRevision}'),
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
          key: const ValueKey('web-join-code-0'),
          label: Text(l10n.webJoinCodeLabel),
          autocorrect: false,
          textCapitalization: TextCapitalization.characters,
          enabled: !vm.busy,
          control: .managed(
            initial: TextEditingValue(text: vm.code),
            onChange: (v) => vm.setCode(v.text),
          ),
        ),
        if (error != null)
          Text(
            _errorText(l10n, error),
            key: const ValueKey('web-join-error'),
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.destructive,
            ),
          ),
        FButton(
          key: const ValueKey('web-join-submit'),
          onPress: vm.canSubmit ? vm.start.execute : null,
          prefix: vm.start.running
              ? const FCircularProgress()
              : const Icon(TablerIcons.login2),
          child: Text(l10n.webJoinSubmit),
        ),
        if (onUseLogin case final onUseLogin?)
          FButton(
            key: const ValueKey('web-join-use-login'),
            variant: .ghost,
            size: .sm,
            onPress: vm.busy ? null : onUseLogin,
            child: Text(l10n.webLoginOwnerLink),
          ),
      ],
    );
  }
}

class _Preparing extends StatelessWidget {
  const _Preparing({required this.vm, this.onCancelled});

  final WebJoinViewModel vm;
  final VoidCallback? onCancelled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final total = vm.total;
    final error = switch (vm.start.result) {
      Error(:final error) => error,
      _ => null,
    };
    return Column(
      key: const ValueKey('web-preparing'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        Text(
          l10n.webPreparingTitle,
          style: theme.typography.display.lg.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          l10n.webPreparingBody,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        if (total != null && total > 0)
          FDeterminateProgress(value: vm.pulled / total)
        else if (error == null)
          const FProgress(),
        Text(
          total == null
              ? l10n.webPreparingCount(formatCount(vm.pulled))
              : l10n.webPreparingProgress(
                  formatCount(vm.pulled),
                  formatCount(total),
                ),
          key: const ValueKey('web-preparing-count'),
          style: theme.typography.body.sm,
        ),
        if (error != null)
          Text(
            _errorText(l10n, error),
            key: const ValueKey('web-preparing-error'),
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.destructive,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 8,
          children: [
            FButton(
              key: const ValueKey('web-preparing-cancel'),
              variant: .outline,
              mainAxisSize: .min,
              onPress: vm.cancel.running
                  ? null
                  : () async {
                      await vm.cancel.execute();
                      if (!vm.preparing) onCancelled?.call();
                    },
              child: Text(l10n.webPreparingCancel),
            ),
            if (error != null)
              FButton(
                key: const ValueKey('web-preparing-retry'),
                mainAxisSize: .min,
                onPress: vm.busy ? null : vm.start.execute,
                prefix: const Icon(TablerIcons.refresh),
                child: Text(l10n.webPreparingRetry),
              ),
          ],
        ),
      ],
    );
  }
}
