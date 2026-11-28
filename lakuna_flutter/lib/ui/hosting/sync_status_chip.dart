import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/hosting_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import '../core/offline_badge.dart';

/// Teks chip status sync (spec F2-01, *Chip status di bilah atas*).
String syncChipText(
  AppLocalizations l10n,
  SyncStatus status, {
  String? timezone,
}) => switch (status.kind) {
  SyncChipKind.local => l10n.offlineBadge,
  SyncChipKind.synced => switch (status.lastSyncAt) {
    final at? => l10n.syncChipSynced(formatClock(at, timezone)),
    null => l10n.syncChipSyncedNow,
  },
  SyncChipKind.syncing => l10n.syncChipSyncing(status.pending),
  SyncChipKind.waiting => l10n.syncChipWaiting(status.pending),
  SyncChipKind.paused => l10n.syncChipPaused(status.pending),
  SyncChipKind.attention => switch (status.error) {
    'clock' => l10n.syncChipClock,
    _ => l10n.syncChipAttention,
  },
};

/// Chip status di bilah atas: *Offline · data di perangkat ini* sebelum
/// versi hosting aktif, lalu keadaan sync. *Perlu perhatian* membuka kartu
/// *Versi hosting* ([onOpen]). Di layar sempit hanya ikon dengan titik
/// warna; teks tetap ada untuk pembaca layar.
class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({
    super.key,
    required this.repository,
    this.compact = false,
    this.timezone,
    this.onOpen,
  });

  final HostingRepository? repository;
  final bool compact;
  final String? timezone;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final repo = repository;
    if (repo == null) return OfflineBadge(compact: compact);
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) => _chip(context, repo.status),
    );
  }

  Widget _chip(BuildContext context, SyncStatus status) {
    if (status.kind == SyncChipKind.local) {
      return OfflineBadge(compact: compact);
    }
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final text = syncChipText(l10n, status, timezone: timezone);
    final (icon, dot) = switch (status.kind) {
      SyncChipKind.local => (
        TablerIcons.cloudOff,
        theme.colors.mutedForeground,
      ),
      SyncChipKind.synced => (TablerIcons.cloudCheck, const Color(0xFF16A34A)),
      SyncChipKind.syncing => (TablerIcons.refresh, theme.colors.primary),
      SyncChipKind.waiting => (TablerIcons.wifiOff, const Color(0xFFD97706)),
      SyncChipKind.paused => (
        TablerIcons.playerPause,
        theme.colors.mutedForeground,
      ),
      SyncChipKind.attention => (
        TablerIcons.alertTriangle,
        theme.colors.destructive,
      ),
    };
    final attention = status.kind == SyncChipKind.attention;
    Widget badge = FBadge(
      key: ValueKey('sync-chip-${status.kind.name}'),
      variant: attention ? .destructive : .secondary,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 14),
              if (compact)
                Positioned(
                  right: -3,
                  top: -3,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: dot,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          if (!compact) Text(text),
        ],
      ),
    );
    if (compact) {
      badge = Semantics(
        label: text,
        child: FTooltip(tipBuilder: (context, _) => Text(text), child: badge),
      );
    }
    final open = onOpen;
    if (open == null) return badge;
    return FTappable(
      key: const ValueKey('sync-chip'),
      semanticsLabel: text,
      onPress: open,
      child: badge,
    );
  }
}
