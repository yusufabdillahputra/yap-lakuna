import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:lakuna_client/lakuna_client.dart' show UuidValue;
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../data/services/barcode_label_pdf.dart';
import '../../data/services/receipt_printer.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';

/// Satu baris yang bisa dicetak labelnya: varian, atau satuan konversi yang
/// punya barcode sendiri (F1-07e).
@immutable
class LabelRow {
  const LabelRow({
    required this.key,
    required this.productId,
    required this.title,
    required this.price,
    required this.stock,
    this.code,
    this.symbology,
    this.searchCodes = const [],
    this.hasBarcode = false,
  });

  /// `<variantId>` atau `<variantId>/<unitId>`.
  final String key;
  final UuidValue productId;
  final String title;
  final Money price;

  /// Stok dalam satuan baris ini (dibulatkan ke atas untuk satuan).
  final Qty stock;

  /// Barcode, atau SKU bila barcode kosong; `null` = tidak ada kode.
  final String? code;

  /// Kode untuk pencarian: SKU dan barcode varian/satuan.
  final List<String> searchCodes;
  final BarcodeSymbology? symbology;

  /// Kode baris ini barcode (bukan SKU).
  final bool hasBarcode;

  bool get printable => code != null && symbology != null;

  /// Baris satuan konversi (`<variantId>/<unitId>`).
  bool get isUnit => key.contains('/');

  /// Varian baris ini.
  UuidValue get variantId => UuidValue.fromString(key.split('/').first);
}

/// Pembuat PDF; bisa diganti di tes.
typedef BarcodeLabelPdfBuilder = Future<Uint8List> Function(
  BarcodeLabelSheet sheet,
);

/// Halaman *Cetak label barcode* (1.15b, F1-07e).
class BarcodeLabelViewModel extends ChangeNotifier {
  BarcodeLabelViewModel({
    required this._repository,
    required this._printer,
    this._initialProduct,
    this._now = DateTime.now,
    this._buildPdf = buildBarcodeLabelPdf,
    Random? random,
  }) : _random = random ?? Random.secure() {
    load = Command0(_load)..addListener(notifyListeners);
    print = Command1(_print)..addListener(notifyListeners);
    save = Command1(_save)..addListener(notifyListeners);
    generateBarcodes = Command1(_generate)..addListener(notifyListeners);
  }

  /// Jumlah maksimal per baris.
  static const maxPerRow = 999;

  /// Jumlah maksimal label per cetak.
  static const maxTotal = 2000;

  final CatalogRepository _repository;
  final ReceiptPrinter _printer;
  final UuidValue? _initialProduct;
  final DateTime Function() _now;
  final BarcodeLabelPdfBuilder _buildPdf;
  final Random _random;

  late final Command0<void> load;
  late final Command1<void, BarcodeLabelSheet> print;
  late final Command1<String?, BarcodeLabelSheet> save;

  /// Buat barcode EAN-13 toko untuk varian di baris-baris ini lalu simpan
  /// (F1-07j); hasilnya jumlah varian yang diberi barcode.
  late final Command1<BarcodeGenerateSummary, List<LabelRow>> generateBarcodes;

  var _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    for (final c in [load, print, save, generateBarcodes]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  List<LabelRow> _rows = const [];
  List<CatalogProduct> _products = const [];
  final _quantities = <String, int>{};
  Exception? _error;
  var _loaded = false;
  var _query = '';
  var _selectedOnly = false;
  var _paper = BarcodeLabelPaper.a4Sheet;
  var _showPrice = true;
  var _skip = 0;
  PrinterFailureReason? _printFailure;
  String? _savedPath;

  List<LabelRow> get rows => _rows;
  Exception? get error => _error;
  bool get loaded => _loaded;
  String get query => _query;
  bool get selectedOnly => _selectedOnly;
  BarcodeLabelPaper get paper => _paper;
  bool get showPrice => _showPrice;
  int get skip => _skip;
  PrinterFailureReason? get printFailure => _printFailure;

  /// Lokasi PDF di desktop setelah *Simpan PDF*; `null` di ponsel.
  String? get savedPath => _savedPath;

  bool get busy => print.running || save.running || generateBarcodes.running;

  /// Baris terpilih, urut seperti daftar.
  List<LabelRow> get selected => [
    for (final r in _rows)
      if (_quantities.containsKey(r.key)) r,
  ];

  int quantity(LabelRow row) => _quantities[row.key] ?? 0;

  int get total => _quantities.values.fold(0, (a, b) => a + b);

  bool get overLimit => total > maxTotal;

  /// Halaman PDF: lembar A4 (termasuk label yang dilewati) atau satu
  /// halaman per label.
  int get pages => switch (_paper) {
    BarcodeLabelPaper.a4Sheet when total > 0 =>
      (_skip + total + BarcodeLabelPaper.perSheet - 1) ~/
          BarcodeLabelPaper.perSheet,
    BarcodeLabelPaper.a4Sheet => 0,
    _ => total,
  };

  /// Naik setiap jumlah [row] diubah dari luar kolom ketiknya (stepper,
  /// isi sesuai stok, nilai di luar batas), agar kolom itu memuat nilai baru.
  /// Per baris, supaya kolom lain yang sedang diketik tidak kehilangan fokus.
  int revision(LabelRow row) => _revisions[row.key] ?? 0;
  final _revisions = <String, int>{};

  void _bump(String key) => _revisions[key] = (_revisions[key] ?? 0) + 1;

  /// Naik bila kolom *Lewati* dibatasi ke 0–23.
  int get skipRevision => _skipRevision;
  var _skipRevision = 0;

  bool get canPrint => total > 0 && !overLimit && !busy;

  /// Baris terpilih yang garis barcodenya terlalu tipis di kertas ini
  /// (F1-07i).
  List<LabelRow> get denseRows => [
    for (final r in selected)
      if (r.printable && barcodeTooDense(_modules(r), _paper.barcodeWidthMm)) r,
  ];

  /// Baris varian tanpa SKU dan barcode (tidak bisa dicetak), kandidat
  /// *Buat barcode* (F1-07j).
  List<LabelRow> get missingCodeRows => [
    for (final r in _rows)
      if (!r.printable && !r.isUnit && !r.hasBarcode) r,
  ];

  /// Baris padat (F1-07i) yang masih memakai SKU, bisa diganti EAN-13.
  List<LabelRow> get denseWithoutBarcode => [
    for (final r in denseRows)
      if (!r.isUnit && !r.hasBarcode) r,
  ];

  /// Jumlah modul per kode, dihitung sekali karena tidak bergantung pada
  /// kertas (getter [denseRows] dipanggil di setiap rebuild).
  final _moduleCache = <String, int>{};
  int _modules(LabelRow r) => _moduleCache.putIfAbsent(
    '${r.symbology!.name}|${r.code}',
    () => barcodeModules(r.code!, r.symbology!),
  );

  /// Label pertama yang dicetak, untuk pratinjau.
  LabelRow? get preview => selected.firstOrNull;

  /// Baris yang tampil setelah pencarian dan saklar *Hanya yang dipilih*.
  List<LabelRow> get visible {
    final q = _query.trim().toLowerCase();
    return [
      for (final r in _rows)
        if ((!_selectedOnly || _quantities.containsKey(r.key)) &&
            (q.isEmpty ||
                r.title.toLowerCase().contains(q) ||
                r.searchCodes.any(
                  (c) => c.toLowerCase().contains(q) || sameBarcode(c, q),
                )))
          r,
    ];
  }

  Future<Result<void>> _load() async {
    switch (await _repository.loadCatalog()) {
      case Ok(value: final catalog):
        _products = catalog.products;
        _rows = labelRows(catalog.products);
        _error = null;
        final initial = _initialProduct;
        if (!_loaded && initial != null) {
          for (final r in _rows) {
            if (r.productId == initial && r.printable) _quantities[r.key] = 1;
          }
          // Baris produk itu langsung terlihat walau letaknya di bawah.
          _selectedOnly = _quantities.isNotEmpty;
        }
        _loaded = true;
        return const Result.ok(null);
      case Error(:final error):
        _error = error;
        return Result.error(error);
    }
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setSelectedOnly(bool value) {
    _selectedOnly = value;
    notifyListeners();
  }

  void toggle(LabelRow row, bool value) {
    if (value && !row.printable) return;
    if (value) {
      _quantities.putIfAbsent(row.key, () => 1);
    } else {
      _quantities.remove(row.key);
    }
    notifyListeners();
  }

  void setQuantity(LabelRow row, int value) {
    if (!_quantities.containsKey(row.key)) return;
    final clamped = value.clamp(1, maxPerRow);
    if (clamped != value) _bump(row.key);
    _quantities[row.key] = clamped;
    notifyListeners();
  }

  /// Jumlah [row] naik/turun [delta] lewat tombol − / +.
  void step(LabelRow row, int delta) {
    if (!_quantities.containsKey(row.key)) return;
    _bump(row.key);
    setQuantity(row, quantity(row) + delta);
  }

  /// Jumlah baris terpilih = stoknya (minimal 1, maksimal [maxPerRow]).
  void fillFromStock() {
    for (final r in selected) {
      final units = (r.stock.milli + 999) ~/ 1000;
      _quantities[r.key] = units.clamp(1, maxPerRow);
      _bump(r.key);
    }
    notifyListeners();
  }

  void setPaper(BarcodeLabelPaper value) {
    _paper = value;
    notifyListeners();
  }

  void setShowPrice(bool value) {
    _showPrice = value;
    notifyListeners();
  }

  void setSkip(int value) {
    _skip = value.clamp(0, BarcodeLabelPaper.perSheet - 1);
    if (_skip != value) _skipRevision++;
    notifyListeners();
  }

  /// Isi cetakan; [price] memformat harga sesuai bahasa aplikasi.
  BarcodeLabelSheet sheet(String Function(Money) price) => BarcodeLabelSheet(
    paper: _paper,
    skip: _paper == BarcodeLabelPaper.a4Sheet ? _skip : 0,
    labels: [
      for (final r in selected)
        for (var i = 0; i < quantity(r); i++)
          BarcodeLabel(
            title: r.title,
            price: _showPrice ? price(r.price) : null,
            code: r.code!,
            symbology: r.symbology!,
          ),
    ],
  );

  Future<Result<BarcodeGenerateSummary>> _generate(
    List<LabelRow> rows,
  ) async {
    final wanted = {
      for (final r in rows)
        if (!r.isUnit && !r.hasBarcode) r.variantId,
    };
    if (wanted.isEmpty) return const Result.ok(BarcodeGenerateSummary());
    // Draft dibuat dari data terbaru, bukan dari saat layar dibuka, agar
    // perubahan produk di tempat lain tidak tertimpa.
    if (await _load() case Error(:final error)) return Result.error(error);
    final selectedBefore = {..._quantities.keys};
    var saved = 0;
    final failed = <String>[];
    Exception? firstError;
    for (final (draft, count) in assignStoreBarcodes(
      _products,
      wanted,
      _random,
    )) {
      switch (await _repository.save(draft)) {
        case Ok():
          saved += count;
        case Error(:final error):
          // Lanjut ke produk berikutnya; yang gagal disebut di pesan.
          failed.add(draft.name);
          firstError ??= error;
      }
    }
    await _load();
    // Baris yang baru bisa dicetak langsung dipilih.
    for (final r in _rows) {
      if (!r.isUnit &&
          wanted.contains(r.variantId) &&
          r.printable &&
          !selectedBefore.contains(r.key)) {
        _quantities[r.key] = 1;
      }
    }
    final summary = BarcodeGenerateSummary(
      saved: saved,
      failed: failed,
      error: firstError,
    );
    return saved == 0 && firstError != null
        ? Result.error(firstError)
        : Result.ok(summary);
  }

  Future<Result<T>> _guard<T>(Future<T> Function() body) async {
    _printFailure = null;
    try {
      return Result.ok(await body());
    } on PrinterFailure catch (e) {
      _printFailure = e.reason;
      return Result.error(e);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> _print(BarcodeLabelSheet sheet) {
    // Hanya hasil aksi terakhir yang ditampilkan.
    save.clearResult();
    return _guard(() async {
      await _printer.printDocument(
        await _buildPdf(sheet),
        jobName: 'Label barcode',
        format: sheet.paper.pageFormat,
      );
    });
  }

  Future<Result<String?>> _save(BarcodeLabelSheet sheet) {
    print.clearResult();
    return _guard(() async {
      _savedPath = null;
      final t = _now();
      String two(int n) => n.toString().padLeft(2, '0');
      final stamp =
          '${two(t.year % 100)}${two(t.month)}${two(t.day)}-'
          '${two(t.hour)}${two(t.minute)}';
      final path = await _printer.shareDocument(
        await _buildPdf(sheet),
        fileName: 'label-barcode-$stamp.pdf',
      );
      _savedPath = path;
      return path;
    });
  }
}

/// Baris label dari katalog: varian lalu satuan berbarcode, urut nama
/// produk.
List<LabelRow> labelRows(List<CatalogProduct> products) {
  final sorted = [...products]
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  LabelRow row({
    required String key,
    required CatalogProduct product,
    required String title,
    required Money price,
    required Qty stock,
    required String? code,
    required List<String?> searchCodes,
    bool hasBarcode = true,
  }) => LabelRow(
    hasBarcode: hasBarcode,
    key: key,
    productId: product.id,
    title: title,
    price: price,
    stock: stock,
    code: code,
    symbology: code == null ? null : labelSymbology(code),
    searchCodes: [...searchCodes.nonNulls],
  );
  String? nonEmpty(String? s) => (s == null || s.trim().isEmpty) ? null : s;
  String variantTitle(CatalogProduct p, CatalogVariant v) =>
      p.variants.length > 1 && v.name.isNotEmpty
      ? '${p.name} ${v.name}'
      : p.name;
  return [
    for (final p in sorted)
      for (final v in p.variants) ...[
        row(
          key: v.id.uuid,
          product: p,
          title: variantTitle(p, v),
          price: v.sellPrice,
          stock: v.stock,
          code: nonEmpty(v.barcode) ?? nonEmpty(v.sku),
          hasBarcode: nonEmpty(v.barcode) != null,
          searchCodes: [v.sku, v.barcode],
        ),
        for (final u in v.units)
          if (nonEmpty(u.barcode) case final code?)
            row(
              key: '${v.id.uuid}/${u.id.uuid}',
              product: p,
              title: '${variantTitle(p, v)} · ${u.name}',
              price: conversionSellPrice(
                variantPrice: v.sellPrice,
                factor: u.factor,
                unitPrice: u.sellPrice,
              ),
              stock: u.factor.milli <= 0
                  ? Qty.zero
                  : Qty(
                      ((v.stock.milli * 1000) + u.factor.milli - 1) ~/
                          u.factor.milli,
                    ),
              code: code,
              searchCodes: [v.sku, code],
            ),
      ],
  ];
}

/// Hasil *Buat barcode* (F1-07j): jumlah varian yang tersimpan dan nama
/// produk yang gagal disimpan.
@immutable
class BarcodeGenerateSummary {
  const BarcodeGenerateSummary({
    this.saved = 0,
    this.failed = const [],
    this.error,
  });

  final int saved;
  final List<String> failed;

  /// Galat pertama, untuk pesan.
  final Exception? error;
}

/// Draft produk (dan jumlah barcode barunya) dengan barcode EAN-13 toko untuk varian [variantIds] yang
/// barcodenya kosong (F1-07j). Kode tidak sama dengan SKU atau barcode lain
/// di [products] maupun kode lain yang dibuat di sini. Produk tanpa varian
/// yang perlu diisi tidak ikut.
List<(ProductDraft, int)> assignStoreBarcodes(
  List<CatalogProduct> products,
  Set<UuidValue> variantIds,
  Random random,
) {
  bool empty(String? s) => s == null || s.trim().isEmpty;
  final taken = <String>{
    for (final p in products)
      for (final v in p.variants) ...[
        // SKU ikut dihindari: Kasir juga mencocokkan scan dengan SKU.
        if (!empty(v.sku)) barcodeKey(v.sku!),
        if (!empty(v.barcode)) barcodeKey(v.barcode!),
        for (final u in v.units)
          if (!empty(u.barcode)) barcodeKey(u.barcode!),
      ],
  };
  String next() {
    final code = generateStoreEan13(random, isTaken: taken.contains);
    taken.add(code);
    return code;
  }

  return [
    for (final p in products)
      if ({
            for (final v in p.variants)
              if (variantIds.contains(v.id) && empty(v.barcode)) v.id: next(),
          }
          case final codes when codes.isNotEmpty)
        (p.toDraft(barcodes: codes), codes.length),
  ];
}
