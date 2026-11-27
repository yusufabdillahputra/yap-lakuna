import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/payment_settings_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Lebar maks foto kamera stiker QRIS (F1-18f): cukup tajam untuk tablet
/// (disarankan >= 1000 px) tanpa membuat file besar.
const qrisCameraMaxWidth = 2000;

/// Asal gambar stiker: *Pilih file* atau *Foto stiker* (F1-18f).
enum QrisPickSource { file, camera }

/// Isian yang bisa diisi otomatis dari QR (F1-18g).
enum QrisAutoField { merchantName, nmid, terminalCode }

/// Pengaturan › Metode pembayaran › QRIS statis (1.26b, F1-18).
class PaymentSettingsViewModel extends ChangeNotifier {
  PaymentSettingsViewModel({required this._repository, required this._picker}) {
    load = Command0(_load)..addListener(notifyListeners);
    pickImage = Command0(
      () => _choose(
        QrisPickSource.file,
        ({required maxBytes}) => _picker.pickImage(maxBytes: maxBytes),
      ),
    )..addListener(notifyListeners);
    takePhoto = Command0(
      () => _choose(
        QrisPickSource.camera,
        ({required maxBytes}) => _picker.takePhoto(
          maxBytes: maxBytes,
          maxWidth: qrisCameraMaxWidth,
        ),
      ),
    )..addListener(notifyListeners);
    save = Command0(_save)..addListener(notifyListeners);
  }

  final PaymentSettingsRepository _repository;
  final ImageFilePicker _picker;

  late final Command0<QrisConfig> load;
  late final Command0<void> pickImage;

  /// *Foto stiker* dari kamera (F1-18f, 1.26b).
  late final Command0<void> takePhoto;
  late final Command0<QrisConfig> save;

  QrisConfig? _config;
  var _draft = const QrisStaticSettings();
  PickedImage? _picked;
  QrisImageCheck? _pickedCheck;
  Set<QrisSettingsError> _errors = const {};
  var _saved = false;
  QrisPickSource? _pickFailed;

  /// Hasil baca QR gambar tersimpan dan gambar baru (F1-18g).
  QrisQrRead? _savedQr;
  QrisQrRead? _pickedQr;
  var _savedReading = false;
  var _pickedReading = false;

  /// Token per sumber: hasil baca yang basi (gambar sudah berganti)
  /// dibuang. Baca gambar tersimpan tidak dibatalkan oleh *Batal*/simpan
  /// isian, karena gambarnya tetap.
  var _savedToken = 0;
  var _pickedToken = 0;

  /// Naik hanya untuk isian yang diisi dari QR, supaya field lain (yang
  /// mungkin sedang diketik) tidak kehilangan fokus.
  final _fills = <QrisAutoField, int>{};
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

  /// Perangkat punya kamera untuk *Foto stiker* (Android/iOS).
  bool get canTakePhoto => _picker.canTakePhoto;

  /// Sumber yang gagal dibuka (mis. izin kamera ditolak); `null` = tidak ada.
  QrisPickSource? get pickFailed => _pickFailed;

  bool get picking => pickImage.running || takePhoto.running;

  /// Sedang membaca QR gambar yang tampil (*Membaca QR…*).
  bool get qrReading => _picked != null ? _pickedReading : _savedReading;

  /// Naik setiap [field] diisi dari QR; dipakai di kunci field teks.
  int fillRevision(QrisAutoField field) => _fills[field] ?? 0;

  /// Hasil baca QR gambar yang tampil; `null` = belum dibaca / tanpa gambar.
  QrisQrRead? get qr => _picked != null ? _pickedQr : _savedQr;

  /// NMID di QR bila berbeda dengan NMID isian yang tidak kosong.
  String? get qrNmidMismatch {
    final qrNmid = qr?.payload?.nmid;
    if (qrNmid == null || _draft.nmid.trim().isEmpty) return null;
    final fromQr = normalizeNmid(qrNmid);
    return normalizeNmid(_draft.nmid) == fromQr ? null : fromQr;
  }

  /// Simpan menunggu baca QR gambar baru selesai, supaya isian otomatis
  /// tidak datang setelah tersimpan.
  bool get canSave =>
      loaded &&
      !save.running &&
      !picking &&
      !(_picked != null && _pickedReading) &&
      _pickedCheck?.error == null;

  void setEnabled(bool v) => _edit(_draft.copyWith(enabled: v));

  /// *Kasir boleh konfirmasi tanpa PIN manajer* (F1-05h).
  void setCashierWithoutPin(bool v) =>
      _edit(_draft.copyWith(cashierConfirmWithoutPin: v));
  void setShowOnPhone(bool v) => _edit(_draft.copyWith(showOnPhone: v));
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
    if (_savedQr == null && !_savedReading) _readSavedQr();
    notifyListeners();
  }

  void _reset() {
    _draft = _config?.settings ?? const QrisStaticSettings();
    _picked = null;
    _pickedCheck = null;
    _pickedQr = null;
    _pickedToken++;
    _pickedReading = false;
    _pickFailed = null;
    _errors = const {};
    _saved = false;
    _revision++;
  }

  Future<Result<QrisConfig>> _load() async {
    final result = await _repository.loadQris();
    if (result case Ok(:final value)) {
      _config = value;
      _reset();
      _readSavedQr();
    }
    return result;
  }

  /// Gambar tersimpan: hasil pemeriksaan saja, tanpa isi otomatis.
  void _readSavedQr() {
    _savedQr = null;
    final token = ++_savedToken;
    final bytes = _config?.imageBytes;
    _savedReading = bytes != null;
    if (bytes == null) return;
    notifyListeners();
    unawaited(() async {
      final read = await _repository.readQr(bytes);
      if (token != _savedToken) return;
      _savedReading = false;
      _savedQr = read;
      notifyListeners();
    }());
  }

  /// Gambar baru: hasil pemeriksaan + isi otomatis isian yang kosong.
  void _readPickedQr(Uint8List bytes) {
    final token = ++_pickedToken;
    _pickedReading = true;
    notifyListeners();
    unawaited(() async {
      final read = await _repository.readQr(bytes);
      if (token != _pickedToken) return;
      _pickedReading = false;
      _pickedQr = read;
      _fillFromQr(read.payload);
      notifyListeners();
    }());
  }

  /// Isi *Nama merchant*, *NMID*, *Kode terminal* dari QR bila isiannya
  /// masih kosong; isian yang sudah diketik tidak ditimpa.
  void _fillFromQr(QrisPayload? payload) {
    if (payload == null) return;
    String cut(String v, int max) => v.length > max ? v.substring(0, max) : v;
    var next = _draft;
    final filled = <QrisAutoField>{};
    if (next.merchantName.trim().isEmpty && payload.merchantName.isNotEmpty) {
      next = next.copyWith(
        merchantName: cut(payload.merchantName, maxQrisMerchantNameLength),
      );
      filled.add(QrisAutoField.merchantName);
    }
    if (next.nmid.trim().isEmpty) {
      next = next.copyWith(
        nmid: cut(normalizeNmid(payload.nmid), maxQrisNmidLength),
      );
      filled.add(QrisAutoField.nmid);
    }
    if (next.terminalCode.trim().isEmpty && payload.terminalLabel.isNotEmpty) {
      next = next.copyWith(
        terminalCode: cut(payload.terminalLabel, maxQrisTerminalCodeLength),
      );
      filled.add(QrisAutoField.terminalCode);
    }
    if (filled.isEmpty) return;
    _draft = next;
    _saved = false;
    // Hanya field yang diisi membaca nilai awal lagi.
    for (final field in filled) {
      _fills[field] = fillRevision(field) + 1;
    }
  }

  Future<Result<void>> _choose(
    QrisPickSource source,
    Future<PickedImage?> Function({required int maxBytes}) pick,
  ) async {
    try {
      final picked = await pick(maxBytes: maxQrisImageBytes);
      if (picked == null) return const Result.ok(null);
      _pickFailed = null;
      _picked = picked;
      final bytes = picked.bytes;
      _pickedCheck = bytes == null
          ? const QrisImageCheck(error: QrisImageError.tooLarge)
          : checkQrisImage(bytes);
      _saved = false;
      _pickedQr = null;
      _pickedToken++;
      _pickedReading = false;
      if (bytes != null && _pickedCheck?.error == null) {
        _readPickedQr(bytes);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      _pickFailed = source;
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
        final newImage = _picked != null && _pickedQr != null;
        final pickedQr = _pickedQr;
        _config = value;
        _reset();
        _saved = true;
        // Gambar baru kini tersimpan: pakai hasil bacanya, atau baca ulang.
        if (newImage) {
          _savedToken++;
          _savedReading = false;
          _savedQr = pickedQr;
        } else if (picked != null) {
          _readSavedQr();
        }
      case Error(:final error):
        if (error case QrisSettingsInvalid(:final errors)) _errors = errors;
    }
    return result;
  }
}
