import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Berkas gambar yang dipilih pengguna.
class PickedImage {
  const PickedImage({required this.name, required this.size, this.bytes});

  final String name;

  /// Ukuran berkas (byte).
  final int size;

  /// Isi berkas; `null` bila lebih dari batas yang diminta (tidak dibaca).
  final Uint8List? bytes;
}

/// Memilih satu gambar PNG/JPG/WebP (dan SVG bila [vector]) dari
/// perangkat, atau memotret dengan kamera (denah meja 1.7c).
abstract class ImageFilePicker {
  const ImageFilePicker();

  /// `null` bila pengguna membatalkan. Berkas lebih dari [maxBytes] tidak
  /// dibaca ([PickedImage.bytes] `null`).
  Future<PickedImage?> pickImage({required int maxBytes, bool vector = false});

  /// Perangkat punya kamera untuk [takePhoto] (Android/iOS).
  bool get canTakePhoto => false;

  /// Foto dari kamera; `null` bila dibatalkan.
  Future<PickedImage?> takePhoto({required int maxBytes}) async => null;
}

/// [ImageFilePicker] dengan dialog berkas sistem (`file_selector`) dan
/// kamera (`image_picker`) di Android/iOS.
class FileSelectorImagePicker extends ImageFilePicker {
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

  static const _vector = XTypeGroup(
    label: 'PNG, JPG, WebP, SVG',
    extensions: ['png', 'jpg', 'jpeg', 'webp', 'svg'],
    mimeTypes: ['image/png', 'image/jpeg', 'image/webp', 'image/svg+xml'],
    uniformTypeIdentifiers: [
      'public.png',
      'public.jpeg',
      'org.webmproject.webp',
      'public.svg-image',
    ],
  );

  @override
  Future<PickedImage?> pickImage({
    required int maxBytes,
    bool vector = false,
  }) async {
    final file = await openFile(
      acceptedTypeGroups: [vector ? _vector : _images],
    );
    return file == null ? null : _read(file, maxBytes);
  }

  @override
  bool get canTakePhoto =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<PickedImage?> takePhoto({required int maxBytes}) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 2400,
      imageQuality: 85,
    );
    return file == null ? null : _read(file, maxBytes);
  }

  Future<PickedImage> _read(XFile file, int maxBytes) async {
    final size = await file.length();
    return PickedImage(
      name: file.name,
      size: size,
      bytes: size > maxBytes ? null : await file.readAsBytes(),
    );
  }
}
