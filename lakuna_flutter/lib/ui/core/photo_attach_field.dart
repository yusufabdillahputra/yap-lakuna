import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Lampiran satu foto (nota/bukti): pratinjau + hapus, tombol pilih berkas
/// dan kamera, serta pesan galat. Kunci widget: `<keyPrefix>-preview`,
/// `-remove`, `-pick`, `-camera`, `-error`.
class PhotoAttachField extends StatelessWidget {
  const PhotoAttachField({
    super.key,
    required this.keyPrefix,
    required this.pickLabel,
    required this.cameraLabel,
    required this.onPick,
    required this.onRemove,
    this.bytes,
    this.fileName,
    this.busy = false,
    this.canTakePhoto = false,
    this.error,
  });

  final String keyPrefix;
  final String pickLabel;
  final String cameraLabel;

  /// Argumen `true` = kamera.
  final void Function(bool camera) onPick;
  final VoidCallback onRemove;
  final Uint8List? bytes;
  final String? fileName;
  final bool busy;
  final bool canTakePhoto;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bytes = this.bytes;
    Widget button(String suffix, IconData icon, String label, bool camera) =>
        FButton(
          key: ValueKey('$keyPrefix-$suffix'),
          variant: .outline,
          mainAxisSize: .min,
          onPress: busy ? null : () => onPick(camera),
          prefix: Icon(icon),
          child: Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        if (bytes != null)
          Row(
            key: ValueKey('$keyPrefix-preview'),
            spacing: 10,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.memory(
                  bytes,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  // Foto kamera sampai 20 MB: dekode kecil saja (F1-15b).
                  cacheWidth: 168,
                ),
              ),
              Expanded(
                child: Text(
                  fileName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm,
                ),
              ),
              FButton.icon(
                key: ValueKey('$keyPrefix-remove'),
                variant: .ghost,
                onPress: onRemove,
                child: Icon(TablerIcons.x, color: theme.colors.destructive),
              ),
            ],
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              button('pick', TablerIcons.photo, pickLabel, false),
              if (canTakePhoto)
                button('camera', TablerIcons.camera, cameraLabel, true),
            ],
          ),
        if (error case final message?)
          Text(
            message,
            key: ValueKey('$keyPrefix-error'),
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.destructive,
            ),
          ),
      ],
    );
  }
}
