import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/hosting_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/format.dart';
import '../settings/settings_card.dart';
import 'activation_view.dart';
import 'hosting_texts.dart';
import 'hosting_view_model.dart';

/// Bagian *Versi hosting* di Pengaturan (F2-01): kartu status, atau stepper
/// aktivasi 2.1 saat *Aktifkan versi hosting* ditekan.
class HostingSection extends StatelessWidget {
  const HostingSection({
    super.key,
    required this.viewModel,
    required this.onJoin,
    this.timezone,
  });

  final HostingViewModel viewModel;

  /// Membuka dialog gabung (perangkat ini dipakai untuk toko lain).
  final VoidCallback onJoin;
  final String? timezone;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => viewModel.activating
        ? ActivationView(viewModel: viewModel)
        : _HostingCard(
            viewModel: viewModel,
            onJoin: onJoin,
            timezone: timezone,
          ),
  );
}

class _HostingCard extends StatelessWidget {
  const _HostingCard({
    required this.viewModel,
    required this.onJoin,
    this.timezone,
  });

  final HostingViewModel viewModel;
  final VoidCallback onJoin;
  final String? timezone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final state = vm.state;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    if (state == null) {
      return SettingsCard(
        key: const ValueKey('hosting-section'),
        title: l10n.settingsSectionHosting,
        child: switch (vm.load.result) {
          Error(:final error) => FAlert(
            variant: .destructive,
            title: Text(hostingErrorText(l10n, error)),
          ),
          _ => const Center(child: FCircularProgress()),
        },
      );
    }
    if (!state.active) {
      return SettingsCard(
        key: const ValueKey('hosting-section'),
        title: l10n.settingsSectionHosting,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(TablerIcons.cloudOff, size: 18, color: muted.color),
                Text(
                  l10n.hostingInactiveTitle,
                  key: const ValueKey('hosting-status'),
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(l10n.hostingInactiveBody, style: muted),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FButton(
                  key: const ValueKey('hosting-activate'),
                  mainAxisSize: .min,
                  onPress: vm.startActivation,
                  prefix: const Icon(TablerIcons.cloudUpload),
                  child: Flexible(child: Text(l10n.hostingActivate)),
                ),
                FButton(
                  key: const ValueKey('hosting-join'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: onJoin,
                  prefix: const Icon(TablerIcons.devicesPlus),
                  child: Flexible(child: Text(l10n.hostingJoinOther)),
                ),
              ],
            ),
          ],
        ),
      );
    }
    final at = state.lastSyncAt;
    final error = state.lastError;
    final pairingError = switch (vm.createPairing.result) {
      Error(:final error) => error,
      _ => null,
    };
    return SettingsCard(
      key: const ValueKey('hosting-section'),
      title: l10n.settingsSectionHosting,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 8,
            children: [
              Icon(
                TablerIcons.cloudCheck,
                size: 18,
                color: theme.colors.primary,
              ),
              Expanded(
                child: Text(
                  l10n.hostingActiveTitle(serverHost(state.serverUrl ?? '')),
                  key: const ValueKey('hosting-status'),
                  style: theme.typography.body.md.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Text(
            [
              if (at == null)
                l10n.hostingNeverSynced
              else
                l10n.hostingLastSync(
                  '${formatDayMonth(at, timezone)} ${formatClock(at, timezone)}',
                ),
              l10n.hostingPending(state.pending),
              if (state.conflicts > 0) l10n.hostingConflicts(state.conflicts),
            ].join(' · '),
            key: const ValueKey('hosting-summary'),
            style: muted,
          ),
          if (vm.uploading) UploadProgressList(progress: vm.progress),
          if (state.paused)
            FAlert(
              key: const ValueKey('hosting-paused'),
              title: Text(l10n.hostingPausedNote),
            )
          else if (error != null)
            FAlert(
              key: const ValueKey('hosting-error'),
              variant: error == 'network' ? .primary : .destructive,
              title: Text(syncErrorText(l10n, error)),
            ),
          if (pairingError != null)
            FAlert(
              key: const ValueKey('hosting-pairing-error'),
              variant: .destructive,
              title: Text(hostingErrorText(l10n, pairingError)),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FButton(
                key: const ValueKey('hosting-sync-now'),
                mainAxisSize: .min,
                onPress: state.paused ? null : vm.syncNow,
                prefix: const Icon(TablerIcons.refresh),
                child: Flexible(child: Text(l10n.hostingSyncNow)),
              ),
              FButton(
                key: const ValueKey('hosting-pairing'),
                variant: .outline,
                mainAxisSize: .min,
                onPress: vm.createPairing.running
                    ? null
                    : () => unawaited(_pair(context)),
                prefix: vm.createPairing.running
                    ? const FCircularProgress()
                    : const Icon(TablerIcons.devicesPlus),
                child: Flexible(child: Text(l10n.hostingPairingCreate)),
              ),
              FButton(
                key: const ValueKey('hosting-pause'),
                variant: .outline,
                mainAxisSize: .min,
                onPress: vm.setPaused.running
                    ? null
                    : () => vm.setPaused.execute(!state.paused),
                prefix: Icon(
                  state.paused
                      ? TablerIcons.playerPlay
                      : TablerIcons.playerPause,
                ),
                child: Flexible(
                  child: Text(
                    state.paused ? l10n.hostingResume : l10n.hostingPause,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pair(BuildContext context) async {
    await viewModel.createPairing.execute();
    if (!context.mounted) return;
    if (viewModel.createPairing.result case Ok(:final value)) {
      await showPairingCode(context, value, timezone: timezone);
    }
  }
}

/// Progres unggah per kelompok (langkah 3 dan kartu saat unggah berjalan).
class UploadProgressList extends StatelessWidget {
  const UploadProgressList({super.key, required this.progress});

  final List<UploadGroupProgress> progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Column(
      key: const ValueKey('hosting-upload-progress'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        for (final g in progress)
          Column(
            key: ValueKey('hosting-upload-${g.group.name}'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: [
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: Text(
                      uploadGroupLabel(l10n, g.group),
                      style: theme.typography.body.sm,
                    ),
                  ),
                  Text(
                    '${formatCount(g.acked)} / ${formatCount(g.total)}',
                    style: theme.typography.body.sm.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (g.acked >= g.total)
                    Icon(
                      TablerIcons.check,
                      size: 16,
                      color: theme.colors.primary,
                    ),
                ],
              ),
              FDeterminateProgress(
                value: g.total == 0 ? 1 : g.acked / g.total,
              ),
            ],
          ),
      ],
    );
  }
}

/// Dialog kode pasang: kode besar, kode lengkap `<alamat>#<kode>` untuk
/// disalin, dan batas berlaku 15 menit.
Future<void> showPairingCode(
  BuildContext context,
  PairingCodeShare share, {
  String? timezone,
  DateTime Function() clock = DateTime.now,
}) => showFDialog<void>(
  context: context,
  builder: (context, style, animation) => FDialog(
    animation: animation,
    constraints: const BoxConstraints(minWidth: 280, maxWidth: 480),
    builder: (context, style) =>
        _PairingCodeView(share: share, timezone: timezone, clock: clock),
  ),
);

class _PairingCodeView extends StatefulWidget {
  const _PairingCodeView({
    required this.share,
    required this.timezone,
    required this.clock,
  });

  final PairingCodeShare share;
  final String? timezone;
  final DateTime Function() clock;

  @override
  State<_PairingCodeView> createState() => _PairingCodeViewState();
}

class _PairingCodeViewState extends State<_PairingCodeView> {
  Timer? _tick;
  var _copied = false;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final share = widget.share;
    final expired = !share.expiresAt.isAfter(widget.clock().toUtc());
    final code = share.code;
    final shown = code.length == 8
        ? '${code.substring(0, 4)} ${code.substring(4)}'
        : code;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        key: const ValueKey('hosting-pairing-dialog'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            l10n.hostingPairingTitle,
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            l10n.hostingPairingBody,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          Center(
            child: Text(
              shown,
              key: const ValueKey('hosting-pairing-code'),
              style: theme.typography.display.xl3.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
                decoration: expired ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            share.shareText,
            key: const ValueKey('hosting-pairing-share'),
            textAlign: TextAlign.center,
            style: theme.typography.body.sm,
          ),
          if (expired)
            FAlert(
              key: const ValueKey('hosting-pairing-expired'),
              variant: .destructive,
              title: Text(l10n.hostingPairingExpired),
            )
          else
            Text(
              l10n.hostingPairingExpires(
                formatClock(share.expiresAt, widget.timezone),
              ),
              key: const ValueKey('hosting-pairing-expires'),
              textAlign: TextAlign.center,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          if (_copied)
            Text(
              l10n.hostingPairingCopied,
              key: const ValueKey('hosting-pairing-copied'),
              textAlign: TextAlign.center,
              style: theme.typography.body.sm,
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              FButton(
                key: const ValueKey('hosting-pairing-close'),
                variant: .outline,
                mainAxisSize: .min,
                onPress: () => Navigator.of(context).pop(),
                child: Flexible(child: Text(l10n.hostingPairingClose)),
              ),
              FButton(
                key: const ValueKey('hosting-pairing-copy'),
                mainAxisSize: .min,
                onPress: expired
                    ? null
                    : () async {
                        await Clipboard.setData(
                          ClipboardData(text: share.shareText),
                        );
                        if (mounted) setState(() => _copied = true);
                      },
                prefix: const Icon(TablerIcons.copy),
                child: Flexible(child: Text(l10n.hostingPairingCopy)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
