import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/cashier_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import 'cashier_view_model.dart';
import 'payment_view.dart' show PaymentPanel, tabularFigures;

/// Warna status tetap (sama di tema terang dan gelap) agar terbaca.
const qrisAmber = Color(0xFFFEF3C6);

/// Teks di atas [qrisAmber].
const qrisAmberInk = Color(0xFF973C00);

/// Gambar stiker QRIS utuh dengan rasio asli (tidak dipotong).
class QrisSticker extends StatelessWidget {
  const QrisSticker({
    super.key,
    required this.image,
    this.maxHeight = 420,
    this.onTap,
    this.semanticsLabel,
  });

  final Uint8List image;
  final double maxHeight;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final sticker = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Image.memory(
            image,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            semanticLabel: semanticsLabel,
            errorBuilder: (context, error, stack) => SizedBox(
              height: 160,
              child: Center(
                child: Icon(
                  TablerIcons.photoOff,
                  size: 32,
                  color: theme.colors.mutedForeground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (onTap == null) return sticker;
    return FTappable(
      key: const ValueKey('qris-image'),
      semanticsLabel: semanticsLabel,
      onPress: onTap,
      child: sticker,
    );
  }
}

/// Stiker QRIS layar penuh, bisa di-zoom.
Future<void> showQrisFullscreen(BuildContext context, Uint8List image) {
  final l10n = AppLocalizations.of(context);
  return showGeneralDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierLabel: l10n.qrisClose,
    barrierColor: const Color(0xE6000000),
    pageBuilder: (context, _, _) => SafeArea(
      child: Stack(
        key: const ValueKey('qris-fullscreen'),
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              maxScale: 5,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Image.memory(image, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: FButton.icon(
              key: const ValueKey('qris-fullscreen-close'),
              variant: .secondary,
              semanticsLabel: l10n.qrisClose,
              onPress: () => Navigator.of(context).pop(),
              child: const Icon(TablerIcons.x),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Lencana "Menunggu konfirmasi kasir".
class _PendingBadge extends StatelessWidget {
  const _PendingBadge();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: qrisAmber,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              const Icon(TablerIcons.clock, size: 14, color: qrisAmberInk),
              Flexible(
                child: Text(
                  AppLocalizations.of(context).qrisPending,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.xs.copyWith(
                    color: qrisAmberInk,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Nama merchant · NMID dan "Dana masuk ke".
List<Widget> _merchantLines(BuildContext context, CashierQris qris) {
  final l10n = AppLocalizations.of(context);
  final theme = context.theme;
  final muted = theme.typography.body.sm.copyWith(
    color: theme.colors.mutedForeground,
  );
  final merchant = [
    if (qris.merchantName.isNotEmpty) qris.merchantName,
    if (qris.nmid.isNotEmpty) 'NMID ${qris.nmid}',
    if (qris.terminalCode.isNotEmpty) qris.terminalCode,
  ].join(' · ');
  return [
    if (merchant.isNotEmpty) Text(merchant, style: muted),
    if (qris.settlementNote.isNotEmpty)
      Text(
        l10n.qrisSettlement(qris.settlementNote),
        key: const ValueKey('qris-settlement'),
        style: muted,
      ),
  ];
}

/// Peringatan agar tidak konfirmasi dari tangkapan layar pelanggan.
class _ScreenshotWarning extends StatelessWidget {
  const _ScreenshotWarning();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: qrisAmber,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            const Icon(
              TablerIcons.alertTriangle,
              size: 18,
              color: qrisAmberInk,
            ),
            Expanded(
              child: Text(
                AppLocalizations.of(context).qrisWarning,
                style: theme.typography.body.sm.copyWith(color: qrisAmberInk),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Panel QRIS statis (1.6 tablet/desktop, 1.6m ponsel): stiker utuh,
/// nominal yang harus diketik pelanggan, langkah, dan peringatan.
class QrisPanel extends StatelessWidget {
  const QrisPanel({super.key, required this.viewModel, required this.compact});

  final CashierViewModel viewModel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final qris = viewModel.qris!;
    final total = viewModel.totals.total;
    void open() => showQrisFullscreen(context, qris.image);

    Widget amount({required bool withMerchant}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          l10n.qrisInstruction,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        Text(
          formatMoney(context, total),
          key: const ValueKey('qris-amount'),
          style: tabularFigures(
            theme.typography.display.xl3.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (withMerchant) ..._merchantLines(context, qris),
      ],
    );
    final steps = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        for (final (i, step) in [
          l10n.qrisStep1,
          l10n.qrisStep2(formatMoney(context, total)),
          l10n.qrisStep3,
          l10n.qrisStep4,
        ].indexed)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              SizedBox.square(
                dimension: 22,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: Text(step, style: theme.typography.body.sm)),
            ],
          ),
      ],
    );
    final enlarge = FButton(
      key: const ValueKey('qris-enlarge'),
      variant: .outline,
      prefix: const Icon(TablerIcons.maximize),
      onPress: open,
      child: Flexible(
        child: Text(l10n.qrisEnlarge, overflow: TextOverflow.ellipsis),
      ),
    );

    if (compact) {
      return PaymentPanel(
        panelKey: const ValueKey('payment-qris'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            const _PendingBadge(),
            // Ponsel (1.6m): stiker langsung di bawah nominal.
            amount(withMerchant: false),
            QrisSticker(
              image: qris.image,
              maxHeight: 460,
              onTap: open,
              semanticsLabel: l10n.qrisImageLabel,
            ),
            Text(
              l10n.qrisTapFullscreen,
              textAlign: TextAlign.center,
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            ..._merchantLines(context, qris),
            const _ScreenshotWarning(),
          ],
        ),
      );
    }
    return PaymentPanel(
      panelKey: const ValueKey('payment-qris'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          SizedBox(
            width: 260,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                QrisSticker(
                  image: qris.image,
                  onTap: open,
                  semanticsLabel: l10n.qrisImageLabel,
                ),
                enlarge,
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [
                const _PendingBadge(),
                amount(withMerchant: true),
                steps,
                const _ScreenshotWarning(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// *Belum masuk* dan *Sudah Terbayar* untuk QRIS tunggal.
class QrisActions extends StatelessWidget {
  const QrisActions({super.key, required this.viewModel});

  final CashierViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        if (!vm.canConfirmPayments)
          Text(
            l10n.qrisNoPermission,
            key: const ValueKey('qris-no-permission'),
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.destructive,
            ),
          ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: FButton(
                key: const ValueKey('qris-not-received'),
                variant: .outline,
                size: .lg,
                onPress: vm.pay.running ? null : vm.qrisNotReceived,
                child: Flexible(
                  child: Text(
                    l10n.qrisNotReceived,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: FButton(
                key: const ValueKey('qris-confirm'),
                size: .lg,
                onPress: vm.canConfirmQris ? vm.pay.execute : null,
                prefix: vm.pay.running
                    ? const SizedBox.square(
                        dimension: 16,
                        child: FCircularProgress(),
                      )
                    : const Icon(TablerIcons.check),
                child: Flexible(
                  child: Text(l10n.qrisPaid, overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Dialog konfirmasi bagian QRIS di split: `true` = *Sudah Terbayar*,
/// `false` = *Belum masuk*, `null` = ditutup.
Future<bool?> showQrisPartDialog(
  BuildContext context, {
  required CashierQris qris,
  required Money amount,
  required bool canConfirm,
}) => showFDialog<bool>(
  context: context,
  builder: (context, style, animation) => FDialog(
    animation: animation,
    builder: (context, style) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('qris-dialog'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              const _PendingBadge(),
              Text(
                l10n.qrisInstruction,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              Text(
                formatMoney(context, amount),
                style: tabularFigures(
                  theme.typography.display.xl2.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ..._merchantLines(context, qris),
              QrisSticker(
                image: qris.image,
                maxHeight: 340,
                semanticsLabel: l10n.qrisImageLabel,
              ),
              const _ScreenshotWarning(),
              if (!canConfirm)
                Text(
                  l10n.qrisNoPermission,
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.destructive,
                  ),
                ),
              Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: FButton(
                      key: const ValueKey('qris-dialog-reject'),
                      variant: .outline,
                      onPress: () => Navigator.of(context).pop(false),
                      child: Flexible(
                        child: Text(
                          l10n.qrisNotReceived,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FButton(
                      key: const ValueKey('qris-dialog-confirm'),
                      onPress: canConfirm
                          ? () => Navigator.of(context).pop(true)
                          : null,
                      prefix: const Icon(TablerIcons.check),
                      child: Flexible(
                        child: Text(
                          l10n.qrisPaid,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  ),
);
