import 'package:flutter/foundation.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/session_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Langkah wizard setup toko (layar 1.1).
enum OnboardingStep { languageTheme, business, owner, summary }

/// Pilihan langkah 4 *Produk pertama* (F1-01b).
enum FirstProductChoice { add, import, skip }

/// State wizard setup toko pertama (F1-01). Data baru ditulis saat [finish].
class OnboardingViewModel extends ChangeNotifier {
  OnboardingViewModel({
    required this._repository,
    required this._session,
    DateTime Function()? now,
    this.onBeforeSetup,
  }) : _now = now ?? DateTime.now {
    finish = Command0(_finish);
  }

  final StoreRepository _repository;
  final SessionRepository _session;
  final DateTime Function() _now;

  /// Dipanggil tepat sebelum toko ditulis dengan `true` bila pengguna
  /// memilih import, agar router tahu tujuan setelah setup (F1-01b).
  final ValueChanged<bool>? onBeforeSetup;

  late final Command0<StoreContext> finish;

  OnboardingStep _step = OnboardingStep.languageTheme;
  BusinessKind _businessType = BusinessKind.retail;
  final _values = <SetupField, String>{
    for (final f in SetupField.values) f: '',
    SetupField.deviceCode: 'K01',
    SetupField.timezone: setupTimezones.first.id,
  };
  final _shownSteps = <OnboardingStep>{};

  OnboardingStep get step => _step;

  /// Nomor langkah 1–4 untuk "Langkah n dari 4".
  int get stepNumber => _step.index + 1;
  int get stepCount => OnboardingStep.values.length;

  BusinessKind get businessType => _businessType;

  String value(SetupField field) => _values[field]!;

  SetupInput get input => SetupInput(
    businessType: _businessType,
    businessName: value(SetupField.businessName),
    outletName: value(SetupField.outletName),
    outletCode: value(SetupField.outletCode),
    deviceCode: value(SetupField.deviceCode),
    timezone: value(SetupField.timezone),
    ownerName: value(SetupField.ownerName),
    email: value(SetupField.email),
    password: value(SetupField.password),
    passwordConfirm: value(SetupField.passwordConfirm),
    pin: value(SetupField.pin),
    pinConfirm: value(SetupField.pinConfirm),
  );

  /// Galat [field], hanya setelah pengguna mencoba melanjutkan langkahnya.
  SetupError? errorFor(SetupField field) {
    final owner = _stepOf(field);
    if (!_shownSteps.contains(owner)) return null;
    return input.validate(fields: [field])[field];
  }

  /// Contoh nomor nota pertama hari ini dari kode yang diketik. Tanggalnya
  /// mengikuti zona waktu yang dipilih (WIB/WITA/WIT), bukan jam perangkat.
  String get receiptPreview {
    final zone = setupTimezones.firstWhere(
      (z) => z.id == value(SetupField.timezone),
      orElse: () => setupTimezones.first,
    );
    final local = _now().toUtc().add(Duration(hours: zone.utcOffsetHours));
    final outlet = normalizeCode(value(SetupField.outletCode));
    final device = normalizeCode(value(SetupField.deviceCode));
    return receiptNumber(
      outlet.isEmpty ? 'PST' : outlet,
      device.isEmpty ? 'K01' : device,
      local,
      1,
    );
  }

  void setBusinessType(BusinessKind kind) {
    _businessType = kind;
    notifyListeners();
  }

  void setField(SetupField field, String text) {
    _values[field] = text;
    notifyListeners();
  }

  /// Ke langkah berikutnya bila field langkah ini valid; bila tidak, galat
  /// langkah ini ditampilkan.
  void next() {
    final fields = _fieldsOf(_step);
    if (input.validate(fields: fields).isNotEmpty) {
      _shownSteps.add(_step);
      notifyListeners();
      return;
    }
    if (_step.index < OnboardingStep.values.length - 1) {
      _step = OnboardingStep.values[_step.index + 1];
      notifyListeners();
    }
  }

  void back() {
    if (_step.index == 0) return;
    // Galat setup lama tidak relevan lagi setelah isian bisa diubah.
    if (finish.error) finish.clearResult();
    _step = OnboardingStep.values[_step.index - 1];
    notifyListeners();
  }

  /// Menyimpan toko lalu langsung memulai sesi pemilik (F1-02), sehingga
  /// pemilik tidak perlu mengetik PIN tepat setelah setup.
  ///
  /// Jangan menyisipkan `await` di antara `setup` dan `startOwnerSession`:
  /// `setup` memberi tahu router (yang sesaat mengarah ke `/masuk`), dan sesi
  /// harus dimulai pada giliran microtask yang sama agar layar login tidak
  /// sempat tampil. Tes alur onboarding memastikan Beranda langsung terbuka.
  Future<Result<StoreContext>> _finish() async {
    ProductDraft? product;
    if (_productChoice == FirstProductChoice.add) {
      final issues = _productIssues;
      if (issues.isNotEmpty) {
        _productShown = true;
        notifyListeners();
        return Result.error(ProductInputInvalid(issues));
      }
      product = firstProductDraft;
    }
    onBeforeSetup?.call(opensImport);
    final result = await _repository.setup(input, firstProduct: product);
    if (result case Ok(:final value)) _session.startOwnerSession(value);
    return result;
  }

  // --- Langkah 4: produk pertama (F1-01b) ---

  FirstProductChoice _productChoice = FirstProductChoice.add;
  String _productName = '';
  Money? _productSellPrice;
  Money? _productCostPrice;
  String? _productUnit;
  String _productBarcode = '';
  Qty _productOpeningStock = Qty.zero;
  bool _productShown = false;

  FirstProductChoice get firstProductChoice => _productChoice;
  String get productName => _productName;
  Money? get productSellPrice => _productSellPrice;
  Money? get productCostPrice => _productCostPrice;
  String get productBarcode => _productBarcode;
  Qty get productOpeningStock => _productOpeningStock;

  /// Satuan yang diketik, atau bawaan jenis usaha (`porsi` untuk F&B).
  String get productUnit =>
      _productUnit ?? (_businessType == BusinessKind.fnb ? 'porsi' : 'pcs');

  /// F&B mencatat *Menu* tanpa stok; Retail/Campuran mencatat *Barang*.
  ProductKind get productKind =>
      _businessType == BusinessKind.fnb ? ProductKind.menu : ProductKind.goods;
  bool get productTracksStock => productKind.tracksStock;

  /// Setelah toko dibuat, buka layar Produk dengan dialog import.
  bool get opensImport => _productChoice == FirstProductChoice.import;

  void setFirstProductChoice(FirstProductChoice choice) =>
      _editProduct(() => _productChoice = choice);
  void setProductName(String text) => _editProduct(() => _productName = text);
  void setProductSellPrice(Money? value) =>
      _editProduct(() => _productSellPrice = value);
  void setProductCostPrice(Money? value) =>
      _editProduct(() => _productCostPrice = value);
  void setProductUnit(String text) => _editProduct(() => _productUnit = text);
  void setProductBarcode(String text) =>
      _editProduct(() => _productBarcode = text);
  void setProductOpeningStock(Qty value) =>
      _editProduct(() => _productOpeningStock = value);

  void _editProduct(void Function() change) {
    change();
    // Galat setup lama (mis. produk tidak valid) tidak berlaku lagi.
    if (finish.error) finish.clearResult();
    notifyListeners();
  }

  /// Draf produk pertama dari isian langkah 4.
  ProductDraft get firstProductDraft => ProductDraft(
    name: _productName.trim(),
    baseUnit: productUnit.trim(),
    kind: productKind,
    variants: [
      VariantDraft(
        barcode: _productBarcode.trim(),
        costPrice: _productCostPrice ?? Money.zero,
        sellPrice: _productSellPrice ?? Money.zero,
        openingStock: productTracksStock ? _productOpeningStock : Qty.zero,
      ),
    ],
  );

  List<ProductIssue> get _productIssues => [
    ...validateProductDraft(firstProductDraft),
    if (_productSellPrice == null)
      const ProductIssue(ProductField.sellPrice, ProductError.required)
    else if (_productSellPrice!.value <= 0)
      const ProductIssue(ProductField.sellPrice, ProductError.notPositive),
  ];

  /// Galat isian produk pertama, setelah pengguna mencoba *Mulai jualan*.
  ProductError? productError(ProductField field) {
    if (!_productShown || _productChoice != FirstProductChoice.add) {
      return null;
    }
    return _productIssues.where((i) => i.field == field).firstOrNull?.error;
  }

  static List<SetupField> _fieldsOf(OnboardingStep step) => switch (step) {
    OnboardingStep.business => SetupField.businessStep,
    OnboardingStep.owner => SetupField.ownerStep,
    _ => const [],
  };

  static OnboardingStep _stepOf(SetupField field) =>
      SetupField.businessStep.contains(field)
      ? OnboardingStep.business
      : OnboardingStep.owner;
}
