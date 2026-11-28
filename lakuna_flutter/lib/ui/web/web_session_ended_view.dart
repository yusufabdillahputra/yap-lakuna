import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../app_root.dart';
import '../../data/repositories/hosting_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../hosting/hosting_texts.dart' show formatCount;

/// Kode galat sync yang berarti token web tidak berlaku lagi (F2-02
/// aturan 5): kedaluwarsa, dicabut, atau tidak dikenal server.
const sessionEndedErrors = {
  'expired',
  'revoked',
  'invalidToken',
  'unknownTenant',
};

/// Mengawasi sync perangkat web (F2-02 aturan 5 dan 7): token ditolak →
/// layar *Sesi berakhir* menggantikan aplikasi, dan peringatan tutup tab
/// menyala selama ada perubahan belum terkirim. Database sesi baru dihapus
/// setelah pengguna menekan *Keluar sekarang* / *Masuk lagi*.
class WebSessionGate extends StatefulWidget {
  const WebSessionGate({super.key, required this.hosting, required this.child});

  final HostingRepository hosting;
  final Widget child;

  @override
  State<WebSessionGate> createState() => _WebSessionGateState();
}

class _WebSessionGateState extends State<WebSessionGate> {
  /// Galat yang mengakhiri sesi; tetap walau status sync berubah lagi.
  String? _ended;

  /// Perubahan belum terkirim saat sesi berakhir; `null` = sedang dihitung.
  int? _unsent;
  bool? _guard;

  @override
  void initState() {
    super.initState();
    widget.hosting.addListener(_onStatus);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onStatus());
  }

  @override
  void dispose() {
    widget.hosting.removeListener(_onStatus);
    super.dispose();
  }

  void _onStatus() {
    if (!mounted) return;
    final status = widget.hosting.status;
    final guard = status.unsent > 0;
    if (guard != _guard) {
      _guard = guard;
      AppRestart.maybeOf(context)?.webSessions?.setUnsentGuard(guard);
    }
    final error = status.error;
    if (_ended == null && sessionEndedErrors.contains(error)) {
      setState(() => _ended = error);
      unawaited(_count());
    }
  }

  Future<void> _count() async {
    final result = await widget.hosting.unsentChanges();
    if (!mounted) return;
    setState(
      () => _unsent = switch (result) {
        Ok(:final value) => value,
        // Tidak bisa dihitung: anggap ada, agar peringatan tetap tampil.
        Error() => widget.hosting.status.unsent,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ended = _ended;
    if (ended == null) return widget.child;
    return WebSessionEndedView(
      expired: ended == 'expired',
      unsent: _unsent,
      onSignOut: AppRestart.maybeOf(context)?.signOut,
    );
  }
}

/// Layar *Sesi berakhir*: alasan, jumlah perubahan yang akan hilang, dan
/// tombol keluar. [unsent] `null` = masih dihitung (tombol menunggu).
class WebSessionEndedView extends StatefulWidget {
  const WebSessionEndedView({
    super.key,
    required this.expired,
    required this.unsent,
    required this.onSignOut,
  });

  final bool expired;
  final int? unsent;
  final Future<void> Function()? onSignOut;

  @override
  State<WebSessionEndedView> createState() => _WebSessionEndedViewState();
}

class _WebSessionEndedViewState extends State<WebSessionEndedView> {
  var _busy = false;

  Future<void> _signOut() async {
    final signOut = widget.onSignOut;
    if (signOut == null) return;
    setState(() => _busy = true);
    try {
      await signOut();
    } finally {
      // Biasanya pohon ini sudah diganti layar masuk.
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final unsent = widget.unsent;
    return ColoredBox(
      color: theme.colors.background,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: FCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    key: const ValueKey('web-session-ended'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [
                      Text(
                        l10n.webSessionEndedTitle,
                        style: theme.typography.display.lg.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        widget.expired
                            ? l10n.webSessionEndedExpired
                            : l10n.webSessionEndedRevoked,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      if (unsent != null && unsent > 0)
                        FAlert(
                          key: const ValueKey('web-session-ended-unsent'),
                          variant: .destructive,
                          icon: const Icon(TablerIcons.alertTriangle),
                          title: Text(
                            l10n.webUnsentChanges(formatCount(unsent)),
                          ),
                        ),
                      FButton(
                        key: const ValueKey('web-session-ended-signout'),
                        variant: unsent != null && unsent > 0
                            ? .destructive
                            : .primary,
                        onPress: unsent == null || _busy ? null : _signOut,
                        prefix: _busy
                            ? const FCircularProgress()
                            : const Icon(TablerIcons.logout),
                        child: Text(
                          unsent != null && unsent > 0
                              ? l10n.webSignOutNow
                              : l10n.webSignInAgain,
                        ),
                      ),
                    ],
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

/// *Keluar* di web (F2-02 aturan 5): satu siklus sync dulu; bila masih ada
/// perubahan belum terkirim, minta konfirmasi. Lalu token dicabut di server
/// (gagal karena offline tetap keluar; token habis sendiri) dan sesi
/// browser dibuang.
Future<void> signOutWeb(
  BuildContext context, {
  required HostingRepository hosting,
}) => _signingOutWeb[hosting] ??= _signOutWeb(
  context,
  hosting,
).whenComplete(() => _signingOutWeb[hosting] = null);

/// *Keluar* yang sedang berjalan per repositori: tombol yang ditekan dua
/// kali tidak keluar dua kali (review I2).
final _signingOutWeb = Expando<Future<void>>();

Future<void> _signOutWeb(
  BuildContext context,
  HostingRepository hosting,
) async {
  final signOut = AppRestart.maybeOf(context)?.signOut;
  if (signOut == null) return;
  final unsent = switch (await hosting.unsentChanges(syncFirst: true)) {
    Ok(:final value) => value,
    Error() => hosting.status.unsent,
  };
  if (unsent > 0) {
    if (!context.mounted) return;
    final confirmed = await _confirmUnsent(context, unsent);
    if (!confirmed) return;
  }
  await hosting.logoutWeb();
  // Layar sudah diganti (mis. sesi lain dimulai): jangan akhiri sesi itu.
  if (!context.mounted) return;
  await signOut();
}

Future<bool> _confirmUnsent(BuildContext context, int unsent) async {
  final l10n = AppLocalizations.of(context);
  final result = await showFDialog<bool>(
    context: context,
    useRootNavigator: true,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      builder: (context, style) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          key: const ValueKey('web-logout-confirm'),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              l10n.webLogoutConfirmTitle,
              style: context.theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(l10n.webUnsentChanges(formatCount(unsent))),
            Text(
              l10n.webLogoutConfirmBody,
              style: context.theme.typography.body.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                FButton(
                  key: const ValueKey('web-logout-cancel'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(context).pop(false),
                  child: Text(l10n.webLogoutCancel),
                ),
                FButton(
                  key: const ValueKey('web-logout-now'),
                  variant: .destructive,
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(context).pop(true),
                  child: Text(l10n.webSignOutNow),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
