import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../core/photo_viewer.dart';

/// Deretan foto faktur (F1-12m): setiap foto bisa diketuk untuk dilihat
/// layar penuh dan, bila [onRemove] ada, dihapus. Foto tanpa isi (`null`)
/// = berkasnya belum ada di perangkat ini. Kunci:
/// `purchase-invoice-photo-thumb-<i>` dan `purchase-invoice-photo-remove-<i>`.
class InvoicePhotoStrip extends StatelessWidget {
  const InvoicePhotoStrip({
    super.key,
    required this.photos,
    this.onRemove,
    this.busy = false,
    this.size = 72,
  });

  final List<Uint8List?> photos;
  final void Function(int index)? onRemove;
  final bool busy;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Wrap(
      key: const ValueKey('purchase-invoice-photo-strip'),
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (i, bytes) in photos.indexed)
          // Ruang [_overhang] di kanan atas agar tombol hapus utuh bisa
          // diketuk (Stack hanya menerima ketukan di dalam ukurannya).
          SizedBox(
            width: size + _overhang,
            height: size + _overhang,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  bottom: 0,
                  width: size,
                  height: size,
                  child: bytes == null
                      ? _MissingTile(
                          key: ValueKey('purchase-invoice-photo-missing-$i'),
                          label: l10n.purchaseInvoicePhotoMissingShort,
                        )
                      : FTappable(
                          key: ValueKey('purchase-invoice-photo-thumb-$i'),
                          semanticsLabel: l10n.purchaseInvoicePhotoPage(
                            i + 1,
                            photos.length,
                          ),
                          onPress: () => showInvoicePhoto(
                            context,
                            bytes: bytes,
                            index: i,
                            count: photos.length,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(
                              bytes,
                              fit: BoxFit.cover,
                              // Foto sampai 2.000 px: dekode kecil saja.
                              cacheWidth: (size * 3).round(),
                            ),
                          ),
                        ),
                ),
                if (onRemove case final remove?)
                  Positioned(
                    top: 0,
                    right: 0,
                    // Area ketuk 40 × 40 px, lingkaran tampak 24 px.
                    child: FTappable(
                      key: ValueKey('purchase-invoice-photo-remove-$i'),
                      semanticsLabel: l10n.purchaseInvoicePhotoRemoveAt(i + 1),
                      onPress: busy ? null : () => remove(i),
                      child: SizedBox.square(
                        dimension: 40,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colors.background,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.colors.border),
                            ),
                            child: Icon(
                              TablerIcons.x,
                              size: 14,
                              color: theme.colors.destructive,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Jarak tombol hapus menjorok dari gambar kecil.
const _overhang = 8.0;

/// Foto faktur ke-[index] layar penuh dengan judul *Foto 2 dari 3*.
Future<void> showInvoicePhoto(
  BuildContext context, {
  required Uint8List bytes,
  required int index,
  required int count,
}) {
  final l10n = AppLocalizations.of(context);
  return showPhotoViewer(
    context,
    bytes: bytes,
    keyPrefix: 'purchase-invoice-photo',
    closeLabel: l10n.purchaseInvoicePhotoClose,
    title: count > 1 ? l10n.purchaseInvoicePhotoPage(index + 1, count) : null,
  );
}

class _MissingTile extends StatelessWidget {
  const _MissingTile({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.muted,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 2,
          children: [
            Icon(
              TablerIcons.photoOff,
              size: 18,
              color: theme.colors.mutedForeground,
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.typography.body.xs.copyWith(
                fontSize: 9,
                color: theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
