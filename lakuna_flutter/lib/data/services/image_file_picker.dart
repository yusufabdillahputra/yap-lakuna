import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

/// Berkas gambar yang dipilih pengguna.
class PickedImage {
  const PickedImage({required this.name, required this.size, this.bytes});

  final String name;

  /// Ukuran berkas (byte).
  final int size;

  /// Isi berkas; `null` bila lebih dari batas yang diminta (tidak dibaca).
  final Uint8List? bytes;
}

/// Memilih satu gambar PNG/JPG/WebP dari perangkat.
abstract class ImageFilePicker {
  /// `null` bila pengguna membatalkan. Berkas lebih dari [maxBytes] tidak
  /// dibaca ([PickedImage.bytes] `null`).
  Future<PickedImage?> pickImage({required int maxBytes});
}

/// [ImageFilePicker] dengan dialog berkas sistem (`file_selector`).
class FileSelectorImagePicker implements ImageFilePicker {
  const FileSelectorImagePicker();

  static const _images = XTypeGroup(
    label: 'PNG, JPG, WebP',
    extensions: ['png', 'jpg', 'jpeg', 'webp'],
    mimeTypes: ['image/png', 'image/jpeg', 'image/webp'],
    uniformTypeIdentifiers: [
      'public.png',
      'public.jpeg',
      'org.webmproject.webp',
    ],
  );

  @override
  Future<PickedImage?> pickImage({required int maxBytes}) async {
    final file = await openFile(acceptedTypeGroups: const [_images]);
    if (file == null) return null;
    final size = await file.length();
    return PickedImage(
      name: file.name,
      size: size,
      bytes: size > maxBytes ? null : await file.readAsBytes(),
    );
  }
}
