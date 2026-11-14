import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

/// Foto (nota, faktur) layar penuh yang bisa diperbesar. Kunci widget:
/// `<keyPrefix>-full` dan `<keyPrefix>-full-close`.
Future<void> showPhotoViewer(
  BuildContext context, {
  required Uint8List bytes,
  required String keyPrefix,
  required String closeLabel,
}) => showFDialog<void>(
  context: context,
  builder: (context, style, animation) => FDialog(
    animation: animation,
    constraints: const BoxConstraints(minWidth: 280, maxWidth: 900),
    builder: (context, style) => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        key: ValueKey('$keyPrefix-full'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Flexible(
            child: InteractiveViewer(
              maxScale: 5,
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FButton(
              key: ValueKey('$keyPrefix-full-close'),
              mainAxisSize: .min,
              onPress: () => Navigator.of(context).pop(),
              child: Text(closeLabel),
            ),
          ),
        ],
      ),
    ),
  ),
);
