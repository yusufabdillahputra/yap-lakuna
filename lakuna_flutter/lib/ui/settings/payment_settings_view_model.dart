import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/payment_settings_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Pengaturan › Metode pembayaran › QRIS statis (1.26b, F1-18).
class PaymentSettingsViewModel extends ChangeNotifier {
  PaymentSettingsViewModel({required this._repository, required this._picker}) {
    load = Command0(_load)..addListener(notifyListeners);
    pickImage = Command0(_pickImage)..addListener(notifyListeners);
    save = Command0(_save)..addListener(notifyListeners);
  }

  final PaymentSettingsRepository _repository;
  final ImageFilePicker _picker;

  late final Command0<QrisConfig> load;
  late final Command0<void> pickImage;
  late final Command0<QrisConfig> save;

  QrisConfig? _config;
  var _draft = const QrisStaticSettings();
  PickedImage? _picked;
  QrisImageCheck? _pickedCheck;
  Set<QrisSettingsError> _errors = const {};
  var _saved = false;
  var _revision = 0;
  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  bool get loaded => _config != null;
  QrisStaticSettings get draft => _draft;

  /// Naik setiap isian dikembalikan (Batal / setelah muat), supaya field
  /// teks membaca nilai awal lagi.
  int get revision => _revision;

  /// Pesan "tersimpan" setelah simpan berhasil, sampai ada perubahan.
  bool get saved => _saved;

  /// Galat isian dari percobaan simpan terakhir.
  Set<QrisSettingsError> get errors => _errors;

  /// Gambar baru yang dipilih tetapi belum disimpan.
  PickedImage? get pickedImage => _picked;

  /// Gambar yang ditampilkan: pilihan baru (bila sah) atau yang tersimpan.
  Uint8List? get previewBytes => _pickedCheck?.error == null && _picked != null
      ? _picked!.bytes
      : _config?.imageBytes;

  String? get previewName => _picked != null && _pickedCheck?.error == null
      ? _picked!.name
      : _config?.media?.fileName;

  int? get previewSize => _picked != null && _pickedCheck?.error == null
      ? _picked!.size
      : _config?.media?.sizeBytes;

  /// Hasil pemeriksaan gambar yang dipilih, atau gambar tersimpan.
  QrisImageCheck? get check {
    if (_pickedCheck case final c?) return c;
    final bytes = _config?.imageBytes;
    return bytes == null ? null : checkQrisImage(bytes);
  }

  bool get hasImage => previewBytes != null;

  bool get canSave =>
      loaded &&
      !save.running &&
      !pickImage.running &&
      _pickedCheck?.error == null;

  void setEnabled(bool v) => _edit(_draft.copyWith(enabled: v));
  void setMerchantName(String v) => _edit(_draft.copyWith(merchantName: v));
  void setNmid(String v) => _edit(_draft.copyWith(nmid: v));
  void setTerminalCode(String v) => _edit(_draft.copyWith(terminalCode: v));
  void setSettlementNote(String v) => _edit(_draft.copyWith(settlementNote: v));

  void _edit(QrisStaticSettings next) {
    _draft = next;
    _saved = false;
    notifyListeners();
  }

  /// *Batal*: kembali ke nilai tersimpan.
  void cancel() {
    _reset();
    notifyListeners();
  }

  void _reset() {
    _draft = _config?.settings ?? const QrisStaticSettings();
    _picked = null;
    _pickedCheck = null;
    _errors = const {};
    _saved = false;
    _revision++;
  }

  Future<Result<QrisConfig>> _load() async {
    final result = await _repository.loadQris();
    if (result case Ok(:final value)) {
      _config = value;
      _reset();
    }
    return result;
  }

  Future<Result<void>> _pickImage() async {
    try {
      final picked = await _picker.pickImage(maxBytes: maxQrisImageBytes);
      if (picked == null) return const Result.ok(null);
      _picked = picked;
      final bytes = picked.bytes;
      _pickedCheck = bytes == null
          ? const QrisImageCheck(error: QrisImageError.tooLarge)
          : checkQrisImage(bytes);
      _saved = false;
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<QrisConfig>> _save() async {
    _saved = false;
    _errors = validateQrisSettings(
      enabled: _draft.enabled,
      hasImage: hasImage,
      merchantName: _draft.merchantName,
      nmid: _draft.nmid,
      terminalCode: _draft.terminalCode,
      settlementNote: _draft.settlementNote,
    );
    if (_errors.isNotEmpty) {
      return Result.error(QrisSettingsInvalid(_errors));
    }
    final picked = _picked;
    final result = await _repository.saveQris(
      _draft,
      image: picked?.bytes == null || _pickedCheck?.error != null
          ? null
          : QrisImageUpload(bytes: picked!.bytes!, fileName: picked.name),
    );
    switch (result) {
      case Ok(:final value):
        _config = value;
        _reset();
        _saved = true;
      case Error(:final error):
        if (error case QrisSettingsInvalid(:final errors)) _errors = errors;
    }
    return result;
  }
}
