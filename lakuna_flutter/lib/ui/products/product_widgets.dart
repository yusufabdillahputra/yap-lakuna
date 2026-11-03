import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../l10n/gen/app_localizations.dart';

/// Kepala layar: judul, subjudul, dan aksi di kanan (turun ke bawah judul
/// di layar sempit).
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.action,
  });

  final String title;
  final String? subtitle;

  /// Baris kecil di atas judul (mis. jejak navigasi).
  final Widget? leading;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final titles = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        ?leading,
        Text(
          title,
          style: theme.typography.display.xl2.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle case final s?)
          Text(
            s,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
      ],
    );
    final action = this.action;
    if (action == null) return titles;
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 600
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [titles, action],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Expanded(child: titles),
                action,
              ],
            ),
    );
  }
}

/// Peringatan gagal muat dengan tombol *Coba lagi*.
class LoadFailedAlert extends StatelessWidget {
  const LoadFailedAlert({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => FAlert(
    variant: .destructive,
    title: Text(message),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FButton(
          size: .sm,
          mainAxisSize: .min,
          variant: .outline,
          onPress: onRetry,
          child: Flexible(child: Text(AppLocalizations.of(context).loginRetry)),
        ),
      ),
    ),
  );
}

/// Pengganti foto produk: kotak biru langit berisi inisial nama.
class ProductThumb extends StatelessWidget {
  const ProductThumb({super.key, required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final dark = theme.colors.brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF052F4A) : const Color(0xFFDFF2FE),
        borderRadius: BorderRadius.circular(size >= 48 ? 8 : 6),
      ),
      child: Text(
        staffInitials(name),
        style: theme.typography.body.xs.copyWith(
          fontWeight: FontWeight.w700,
          color: dark ? const Color(0xFF74D4FF) : const Color(0xFF00598A),
        ),
      ),
    );
  }
}

/// Pil stok: kuning bila di bawah minimum. Warna OK biru langit di layar
/// lebar (1.15) dan hijau di ponsel (1.15m), sesuai kanvas.
class StockPill extends StatelessWidget {
  const StockPill({
    super.key,
    required this.text,
    required this.low,
    this.mobile = false,
  });

  final String text;
  final bool low;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final dark = theme.colors.brightness == Brightness.dark;
    final (Color bg, Color fg) = switch ((low, dark, mobile)) {
      (true, false, _) => (const Color(0xFFFEF3C6), const Color(0xFF973C00)),
      (true, true, _) => (const Color(0xFF461901), const Color(0xFFFFD230)),
      (false, false, false) => (
        const Color(0xFFDFF2FE),
        const Color(0xFF016630),
      ),
      (false, false, true) => (
        const Color(0xFFDCFCE7),
        const Color(0xFF016630),
      ),
      (false, true, _) => (const Color(0xFF032E15), const Color(0xFF7BF1A8)),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.typography.body.xs.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

/// Chip filter berbentuk pil (1.15m).
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FTappable(
      onPress: onTap,
      semanticsLabel: label,
      selected: selected,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? theme.colors.primary : theme.colors.secondary,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: theme.typography.body.sm.copyWith(
              fontWeight: FontWeight.w600,
              color: selected
                  ? theme.colors.primaryForeground
                  : theme.colors.secondaryForeground,
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu dengan judul opsional dan isi berjarak 16.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    this.trailing,
    required this.child,
  });

  final String? title;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            if (title case final t?)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t,
                      style: theme.typography.display.lg.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            child,
          ],
        ),
      ),
    );
  }
}
