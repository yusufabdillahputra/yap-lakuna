import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/dining_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

import 'fake_catalog_repository.dart';
import 'floor_seed.dart';
import 'fake_stock_repository.dart' show fakeId;

/// Menu contoh F&B: Kopi Susu Aren 24.000, Nasi Goreng Kampung 29.000, Es
/// Teh Manis 5.000.
const sampleMenu = [
  ProductDraft(
    name: 'Kopi Susu Aren',
    category: 'Minuman',
    baseUnit: 'gelas',
    variants: [VariantDraft(sellPrice: Money(24000))],
  ),
  ProductDraft(
    name: 'Nasi Goreng Kampung',
    category: 'Makanan',
    kind: ProductKind.service,
    baseUnit: 'porsi',
    variants: [VariantDraft(sellPrice: Money(29000))],
  ),
  ProductDraft(
    name: 'Es Teh Manis',
    category: 'Minuman',
    baseUnit: 'gelas',
    variants: [VariantDraft(sellPrice: Money(5000))],
  ),
];

/// Meja & open bill di memori dengan aturan `lakuna_domain` yang sama:
/// area Indoor (M1–M4) dan Teras (M5–M6), service 5%, PB1 10%.
class FakeDiningRepository extends DiningRepository {
  FakeDiningRepository({
    this.permissions,
    this.rates = const FnbRates(
      service: BasisPoints(500),
      tax: BasisPoints(1000),
    ),
    List<ProductDraft> menu = sampleMenu,
  }) : catalog = FakeCatalogRepository(seed: menu) {
    areas.addAll([_area(1, 'Indoor', 0), _area(2, 'Teras', 1)]);
    for (var i = 1; i <= 6; i++) {
      tables.add(
        DiningTable(
          id: fakeId(600 + i),
          tenantId: _tenant,
          outletId: _outlet,
          diningAreaId: fakeId(i <= 4 ? 501 : 502),
          name: 'M$i',
          seats: i.isEven ? 4 : 2,
          sortOrder: i,
          hlc: '',
        ),
      );
    }
  }

  final FakeCatalogRepository catalog;

  /// Izin staf; `null` = semua izin.
  Set<Permission>? permissions;
  FnbRates rates;
  final areas = <DiningArea>[];
  final tables = <DiningTable>[];
  final sales = <Sale>[];
  final items = <SaleItem>[];
  final tickets = <KitchenTicket>[];
  final voided = <UuidValue, String>{};

  /// Penyetuju *Batalkan bill* per bill (F1-11).
  final voidApprovers = <UuidValue, UuidValue>{};

  /// Pembayaran bagian split (F1-10c).
  final payments = <Payment>[];

  /// Sesi kasir terbuka (bayar bagian dan *Sudah Terbayar*).
  var sessionOpen = true;
  var _receipts = 100;

  /// Gambar denah per area (mode Denah 1.7b).
  final floorImages = <UuidValue, FloorImage>{};

  /// Grup modifier per produk (lihat [attachModifiers]).
  final modifierGroups = <UuidValue, List<ModifierGroupDetail>>{};

  /// Modifier terpilih per item.
  final itemModifiers = <UuidValue, List<SaleItemModifier>>{};
  final _tenant = fakeId(1);
  final _outlet = fakeId(2);
  var _next = 700;
  var now = DateTime.utc(2026, 11, 3, 5, 10);

  /// Galat berikutnya (sekali pakai).
  Exception? nextError;
  var loadCalls = 0;

  /// Printer struk dan printer dapur perangkat (F1-10e).
  PrinterSelection? printer;
  KitchenPrinter? kitchenPrinter;

  /// Area [area] (1 = Indoor, 2 = Teras) jadi mode denah dengan gambar
  /// 1600 × 1200 dan meja di [positions] (nama → x, y).
  void useFloorPlan(int area, Map<String, (int, int)> positions) {
    final i = areas.indexWhere((a) => a.id == fakeId(500 + area));
    final media = MediaFile(
      id: fakeId(560 + area),
      tenantId: _tenant,
      outletId: _outlet,
      kind: MediaKind.floorPlan,
      fileName: 'denah.png',
      mimeType: 'image/png',
      sizeBytes: 100,
      sha256: 'x',
      width: 1600,
      height: 1200,
      storageKey: 'x.png',
      hlc: '',
    );
    areas[i] = areas[i].copyWith(
      layoutMode: DiningLayoutMode.floor,
      floorMediaId: media.id,
    );
    floorImages[areas[i].id] = FloorImage(media: media, bytes: samplePng);
    for (final (j, t) in tables.indexed) {
      final pos = positions[t.name];
      if (pos == null) continue;
      tables[j] = t.copyWith(posX: pos.$1, posY: pos.$2);
    }
  }

  /// Ubah sakelar *Kirim ke tiket dapur* / *Bisa catatan bebas* menu
  /// bernama [productName] (F1-10g).
  Future<void> setMenuFlags(
    String productName, {
    bool sendToKitchen = true,
    bool allowNote = true,
  }) async {
    final d = catalog.products
        .firstWhere((p) => p.name == productName)
        .toDraft();
    await catalog.save(
      ProductDraft(
        id: d.id,
        name: d.name,
        category: d.category,
        kind: d.kind,
        baseUnit: d.baseUnit,
        sku: d.sku,
        brand: d.brand,
        isActive: d.isActive,
        isTaxable: d.isTaxable,
        modifierGroupIds: d.modifierGroupIds,
        variants: d.variants,
        sendToKitchen: sendToKitchen,
        allowNote: allowNote,
      ),
    );
  }

  /// Pasang [groups] di menu bernama [productName].
  void attachModifiers(String productName, List<ModifierGroupDetail> groups) {
    final p = catalog.products.firstWhere((p) => p.name == productName);
    modifierGroups[p.id] = groups;
  }

  DiningArea _area(int n, String name, int order) => DiningArea(
    id: fakeId(500 + n),
    tenantId: _tenant,
    outletId: _outlet,
    name: name,
    sortOrder: order,
    hlc: '',
  );

  bool _can(Permission p) => permissions?.contains(p) ?? true;

  Future<Result<T>> _run<T>(T Function() body) async {
    final e = nextError;
    nextError = null;
    if (e != null) return Result.error(e);
    if (!_can(Permission.openBillsManage)) {
      return const Result.error(NotPermitted(Permission.openBillsManage));
    }
    try {
      return Result.ok(body());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  // --- Baca -----------------------------------------------------------------

  OpenBill bill(UuidValue id) {
    final sale = sales.where((s) => s.id == id).firstOrNull;
    if (sale == null || sale.status != SaleStatus.open) throw BillNotFound();
    final own = [
      for (final i in items)
        if (i.saleId == id && i.deletedAt == null) i,
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return OpenBill(
      sale: sale,
      items: own,
      charges: fnbCharges(
        Money.sum(own.map((i) => Money(i.lineTotal))),
        dineIn: sale.orderType == OrderType.dineIn,
        serviceBp: rates.service,
        taxBp: rates.tax,
        discount: billDiscountOf(sale),
      ),
      rates: rates,
      table: tables.where((t) => t.id == sale.diningTableId).firstOrNull,
      openedByName: 'Dimas',
      discountApprovedByName: sale.discountApprovedBy == null ? '' : 'Rina',
      customer: _billCustomer(sale.customerId),
      modifiers: {for (final i in own) i.id: ?itemModifiers[i.id]},
      payments: [
        for (final p in payments)
          if (p.saleId == id && p.deletedAt == null) p,
      ],
    );
  }

  DiningOverview _overview() => DiningOverview(
    areas: List.of(areas),
    tables: List.of(tables),
    bills: [
      for (final s in sales)
        if (s.status == SaleStatus.open && s.deletedAt == null) bill(s.id),
    ],
    rates: rates,
  );

  @override
  Future<Result<DiningData>> load() => _run(() {
    loadCalls++;
    final products = [...catalog.products]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return DiningData(
      overview: _overview(),
      products: products,
      categories: cashierCategories(catalog.categories, {
        for (final p in products) p.categoryId,
      }),
      staffName: 'Dimas',
      timezone: 'Asia/Jakarta',
      canPay: _can(Permission.salesCreate),
      canVoid: _can(Permission.salesVoid),
      modifierGroups: Map.of(modifierGroups),
      floorImages: Map.of(floorImages),
      canArrange: _can(Permission.settingsManage),
      canDiscount: _can(Permission.salesDiscount),
      discountNeedsPin: discountNeedsPin,
      printer: printer,
      kitchenPrinter: kitchenPrinter,
    );
  });

  @override
  Future<Result<DiningOverview>> overview() => _run(_overview);

  @override
  Future<Result<int>> pendingQrisCount() => _run(
    () => payments.where((p) {
      if (p.status != PaymentStatus.pending) return false;
      final sale = sales.where((s) => s.id == p.saleId).firstOrNull;
      return sale != null && sale.status == SaleStatus.open;
    }).length,
  );

  // --- Bill -----------------------------------------------------------------

  Sale _newSale(OrderType type, {UuidValue? table, int? guests, String? name}) {
    final queue = type == OrderType.takeAway
        ? nextDailyNumber(sales.map((s) => s.queueNumber ?? 0))
        : null;
    final number =
        'OB-PST-K01-261103-${(sales.length + 1).toString().padLeft(4, '0')}';
    final sale = Sale(
      id: fakeId(_next++),
      tenantId: _tenant,
      outletId: _outlet,
      deviceId: fakeId(3),
      staffId: fakeId(4),
      number: number,
      billNumber: number,
      status: SaleStatus.open,
      orderType: type,
      diningTableId: table,
      queueNumber: queue,
      customerName: name,
      guestCount: guests,
      openedBy: fakeId(4),
      openedAt: now,
      subtotal: 0,
      tierDiscount: 0,
      total: 0,
      paidAmount: 0,
      changeAmount: 0,
      itemCount: 0,
      soldAt: now,
      hlc: '',
    );
    sales.add(sale);
    return sale;
  }

  void _replaceSale(Sale s) => sales[sales.indexWhere((x) => x.id == s.id)] = s;

  void _replaceItem(SaleItem i) =>
      items[items.indexWhere((x) => x.id == i.id)] = i;

  void _sync(UuidValue billId) {
    final b = bill(billId);
    _replaceSale(
      b.sale.copyWith(itemCount: b.items.length, total: b.charges.total.value),
    );
  }

  @override
  Future<Result<OpenBill>> openTable(UuidValue tableId, int guests) => _run(() {
    if (guests < 1 || guests > FnbLimits.guestsMax) {
      throw const BillInputInvalid(BillField.guests);
    }
    if (!tables.any((t) => t.id == tableId)) throw DiningNotFound();
    final existing = sales
        .where(
          (s) =>
              s.diningTableId == tableId &&
              s.status == SaleStatus.open &&
              s.deletedAt == null,
        )
        .firstOrNull;
    return bill(
      existing?.id ??
          _newSale(OrderType.dineIn, table: tableId, guests: guests).id,
    );
  });

  @override
  Future<Result<OpenBill>> openTakeAway(String? customerName) => _run(() {
    final name = customerName?.trim() ?? '';
    if (name.length > FnbLimits.customerName) {
      throw const BillInputInvalid(BillField.customerName);
    }
    final empty = sales
        .where(
          (s) =>
              s.orderType == OrderType.takeAway &&
              s.status == SaleStatus.open &&
              s.deletedAt == null &&
              s.itemCount == 0,
        )
        .firstOrNull;
    if (empty != null) {
      if (name.isNotEmpty) _replaceSale(empty.copyWith(customerName: name));
      return bill(empty.id);
    }
    return bill(
      _newSale(OrderType.takeAway, name: name.isEmpty ? null : name).id,
    );
  });

  @override
  Future<Result<OpenBill>> addItem(
    UuidValue billId,
    SaleLineRequest line, {
    String? note,
    List<UuidValue> modifierIds = const [],
  }) => _run(() {
    final b = bill(billId);
    _unlocked(b);
    final typed = note?.trim() ?? '';
    if (typed.length > FnbLimits.itemNote) {
      throw const BillInputInvalid(BillField.note);
    }
    final product = catalog.products
        .where((p) => p.variants.any((v) => v.id == line.variantId))
        .firstOrNull;
    if (product == null || !product.isActive) {
      throw SaleItemUnavailable(line.variantId);
    }
    final clean = product.allowNote ? typed : '';
    final variant = product.variants.firstWhere((v) => v.id == line.variantId);
    final groups = modifierGroups[product.id] ?? const <ModifierGroupDetail>[];
    final ids = [for (final id in modifierIds) id.uuid];
    final selError = validateModifierSelection([
      for (final g in groups) g.rule,
    ], ids);
    if (selError != null) throw ModifierSelectionInvalid(selError);
    final chosen = [
      for (final g in groups)
        for (final o in g.options)
          if (modifierIds.contains(o.id)) (g, o),
    ];
    final delta = Money.sum(chosen.map((c) => Money(c.$2.priceDelta)));
    if (modifiedUnitPrice(variant.sellPrice, delta) == null) {
      throw ModifierPriceInvalid();
    }
    final key = modifierKey(ids);
    final same = b.items
        .where(
          (i) =>
              i.kitchenStatus == KitchenStatus.pending &&
              i.variantId == line.variantId &&
              (i.note ?? '') == clean &&
              i.modifierKey == key &&
              i.guestLabel == null &&
              i.splitFromItemId == null &&
              billItemDiscountOf(i) == null,
        )
        .firstOrNull;
    final qty = Qty(same?.quantityMilli ?? 0) + line.quantity;
    final priced = priceSaleLine(
      sellPrice: variant.sellPrice,
      quantity: qty,
      tiers: variant.tiers,
      customerGroupId: _billCustomer(b.sale.customerId)?.groupId?.uuid,
    );
    if (same != null) {
      _replaceItem(
        same.copyWith(
          quantityMilli: qty.milli,
          unitPrice: priced.unitPrice.value,
          lineTotal: (priced.unitPrice + delta).timesMilli(qty.milli).value,
        ),
      );
    } else {
      final itemId = fakeId(_next++);
      if (chosen.isNotEmpty) {
        itemModifiers[itemId] = [
          for (final (n, (g, o)) in chosen.indexed)
            SaleItemModifier(
              tenantId: _tenant,
              saleItemId: itemId,
              modifierId: o.id,
              groupName: g.name,
              name: o.name,
              priceDelta: o.priceDelta,
              sortOrder: n,
              hlc: '',
            ),
        ];
      }
      items.add(
        SaleItem(
          id: itemId,
          tenantId: _tenant,
          saleId: billId,
          variantId: variant.id,
          productName: product.name,
          variantName: variant.name,
          unitName: product.baseUnit,
          factorMilli: 1000,
          quantityMilli: qty.milli,
          listPrice: priced.listPrice.value,
          unitPrice: priced.unitPrice.value,
          lineTotal: (priced.unitPrice + delta).timesMilli(qty.milli).value,
          modifierDelta: delta.value,
          modifierKey: key,
          unitCost: 0,
          tracksStock: product.tracksStock,
          sortOrder: items.length,
          kitchenStatus: KitchenStatus.pending,
          note: clean.isEmpty ? null : clean,
          hlc: '',
        ),
      );
    }
    _sync(billId);
    return bill(billId);
  });

  SaleItem _item(UuidValue id) =>
      items.where((i) => i.id == id && i.deletedAt == null).firstOrNull ??
      (throw BillNotFound());

  @override
  Future<Result<OpenBill>> setItemQuantity(UuidValue itemId, Qty quantity) =>
      _run(() {
        final item = _item(itemId);
        _unlocked(bill(item.saleId));
        if (item.kitchenStatus != KitchenStatus.pending) throw BillItemLocked();
        if (quantity.isPositive) {
          final gross = Money(
            item.unitPrice + item.modifierDelta,
          ).timesMilli(quantity.milli);
          final cut = billItemDiscountOf(item)?.cut(gross) ?? Money.zero;
          _replaceItem(
            item.copyWith(
              quantityMilli: quantity.milli,
              lineTotal: (gross - cut).value,
              discountAmount: cut.value,
            ),
          );
        } else {
          _replaceItem(item.copyWith(deletedAt: now));
        }
        _sync(item.saleId);
        return bill(item.saleId);
      });

  @override
  Future<Result<OpenBill>> markServed(UuidValue itemId) => _run(() {
    final item = _item(itemId);
    if (item.kitchenStatus != KitchenStatus.sent) throw BillItemLocked();
    _replaceItem(item.copyWith(kitchenStatus: KitchenStatus.served));
    return bill(item.saleId);
  });

  @override
  Future<Result<KitchenSendResult>> sendToKitchen(UuidValue billId) => _run(() {
    final pending = [
      for (final i in bill(billId).items)
        if (i.kitchenStatus == KitchenStatus.pending) i,
    ];
    if (pending.isEmpty) throw NothingToSend();
    bool toKitchen(SaleItem i) =>
        catalog.products
            .where((p) => p.variants.any((v) => v.id == i.variantId))
            .firstOrNull
            ?.sendToKitchen ??
        true;
    final served = [
      for (final i in pending)
        if (!toKitchen(i)) i.copyWith(kitchenStatus: KitchenStatus.served),
    ];
    served.forEach(_replaceItem);
    final cooked = [
      for (final i in pending)
        if (toKitchen(i)) i,
    ];
    if (cooked.isEmpty) {
      return KitchenSendResult(
        ticket: null,
        items: const [],
        served: served,
        bill: bill(billId),
        staffName: 'Dimas',
      );
    }
    final ticket = KitchenTicket(
      id: fakeId(_next++),
      tenantId: _tenant,
      outletId: _outlet,
      deviceId: fakeId(3),
      saleId: billId,
      number: tickets.length + 12,
      staffId: fakeId(4),
      sentAt: now,
      hlc: '',
    );
    tickets.add(ticket);
    final sent = [
      for (final i in cooked)
        i.copyWith(
          kitchenStatus: KitchenStatus.sent,
          kitchenTicketId: ticket.id,
        ),
    ];
    sent.forEach(_replaceItem);
    return KitchenSendResult(
      ticket: ticket,
      items: sent,
      served: served,
      bill: bill(billId),
      staffName: 'Dimas',
    );
  });

  @override
  Future<Result<OpenBill>> setBillRequested(UuidValue billId, bool requested) =>
      _run(() {
        final b = bill(billId);
        _replaceSale(b.sale.copyWith(billRequestedAt: requested ? now : null));
        return bill(billId);
      });

  @override
  Future<Result<OpenBill>> moveBill(UuidValue billId, UuidValue tableId) =>
      _run(() {
        final b = bill(billId);
        if (sales.any(
          (s) =>
              s.diningTableId == tableId &&
              s.status == SaleStatus.open &&
              s.deletedAt == null &&
              s.id != billId,
        )) {
          throw TableOccupied();
        }
        _replaceSale(b.sale.copyWith(diningTableId: tableId));
        return bill(billId);
      });

  /// Menandai meja [names] *Boleh digabung* (F1-10d).
  void allowMerge(List<String> names) {
    for (var i = 0; i < tables.length; i++) {
      if (names.contains(tables[i].name)) {
        tables[i] = tables[i].copyWith(canMerge: true);
      }
    }
  }

  @override
  Future<Result<OpenBill>> mergeBill(
    UuidValue targetBillId,
    UuidValue sourceBillId,
  ) => _run(() {
    final target = bill(targetBillId);
    final source = bill(sourceBillId);
    bool mergeable(OpenBill b) =>
        b.sale.orderType == OrderType.dineIn &&
        tables.any((t) => t.id == b.sale.diningTableId && t.canMerge);
    if (target.id == source.id || !mergeable(target) || !mergeable(source)) {
      throw const BillMergeBlocked(BillMergeReason.notAllowed);
    }
    if (target.sale.splitMode != null || source.sale.splitMode != null) {
      throw const BillMergeBlocked(BillMergeReason.split);
    }
    if (source.discount != null) {
      throw const BillMergeBlocked(BillMergeReason.discount);
    }
    if (target.sale.customerId != null &&
        source.sale.customerId != null &&
        target.sale.customerId != source.sale.customerId) {
      throw const BillMergeBlocked(BillMergeReason.customer);
    }
    final guests =
        (target.sale.guestCount ?? 0) + (source.sale.guestCount ?? 0);
    if (guests > FnbLimits.guestsMax) {
      throw const BillMergeBlocked(BillMergeReason.guests);
    }
    var order = target.items.fold(
      0,
      (max, i) => i.sortOrder > max ? i.sortOrder : max,
    );
    for (var i = 0; i < items.length; i++) {
      if (items[i].saleId != source.id) continue;
      items[i] = items[i].copyWith(saleId: target.id, sortOrder: ++order);
    }
    _replaceSale(source.sale.copyWith(deletedAt: now));
    _replaceSale(
      target.sale.copyWith(
        guestCount: guests,
        customerId: target.sale.customerId ?? source.sale.customerId,
        customerName: target.sale.customerName ?? source.sale.customerName,
      ),
    );
    _reprice(target.id);
    merges.add((target.id, source.id));
    return bill(target.id);
  });

  // --- Pelanggan bill (F1-10f) ---------------------------------------------

  /// Pelanggan untuk pemilih bill.
  List<CustomerRow> customerRows = const [];

  /// Nama grup pelanggan per id grup.
  Map<UuidValue, String> groupNames = const {};

  BillCustomer? _billCustomer(UuidValue? id) {
    final row = customerRows.where((r) => r.customer.id == id).firstOrNull;
    if (row == null) return null;
    final c = row.customer;
    return BillCustomer(
      id: c.id,
      name: c.name,
      groupId: c.customerGroupId,
      groupName: groupNames[c.customerGroupId] ?? row.groupName,
    );
  }

  /// Hitung ulang harga semua item bill dengan grup pelanggannya.
  void _reprice(UuidValue billId) {
    final b = bill(billId);
    final group = b.customer?.groupId?.uuid;
    for (final item in b.items) {
      final variant = catalog.products
          .expand((p) => p.variants)
          .where((v) => v.id == item.variantId)
          .firstOrNull;
      if (variant == null) continue;
      final qty = Qty(item.quantityMilli);
      final priced = priceSaleLine(
        sellPrice: variant.sellPrice,
        quantity: qty,
        tiers: variant.tiers,
        customerGroupId: group,
      );
      _replaceItem(
        item.copyWith(
          unitPrice: priced.unitPrice.value,
          lineTotal: (priced.unitPrice + Money(item.modifierDelta))
              .timesMilli(qty.milli)
              .value,
        ),
      );
    }
    _sync(billId);
  }

  @override
  Future<Result<CustomersOverview>> customers() => _run(
    () =>
        CustomersOverview(rows: customerRows, today: DateTime.utc(2026, 11, 3)),
  );

  /// Pilihan pelanggan bill yang berhasil.
  final customerSets = <(UuidValue, UuidValue?)>[];

  @override
  Future<Result<OpenBill>> setBillCustomer(
    UuidValue billId,
    UuidValue? customerId,
  ) => _run(() {
    final b = bill(billId);
    if (b.sale.splitMode != null || b.payments.isNotEmpty) {
      throw BillCustomerBlocked();
    }
    final next = customerId == null ? null : _billCustomer(customerId);
    if (customerId != null && next == null) throw CustomerNotFound();
    final name = b.sale.customerName;
    final keep = name != null && name.isNotEmpty && name != b.customer?.name;
    _replaceSale(
      b.sale.copyWith(
        customerId: next?.id,
        customerName: keep ? name : next?.name,
      ),
    );
    _reprice(billId);
    customerSets.add((billId, customerId));
    return bill(billId);
  });

  /// Gabung meja yang berhasil: (tujuan, sumber).
  final merges = <(UuidValue, UuidValue)>[];

  /// Sakelar *Diskon manual butuh PIN manajer*.
  bool discountNeedsPin = true;

  /// Penyetuju diskon terakhir per bill.
  final discountApprovers = <UuidValue, UuidValue>{};
  final itemDiscountApprovers = <UuidValue, UuidValue>{};

  @override
  Future<Result<OpenBill>> setDiscount(
    UuidValue billId,
    ManualDiscount? discount, {
    UuidValue? approverId,
  }) => _run(() {
    if (discount != null &&
        approverId == null &&
        !_can(Permission.salesDiscount)) {
      throw const NotPermitted(Permission.salesDiscount);
    }
    final b = bill(billId);
    if (b.payments.isNotEmpty) throw SplitLocked();
    if (discount != null) {
      if (discount.issue(b.charges.subtotal) != null) {
        throw const DiscountTooLarge();
      }
      if (approverId != null) discountApprovers[billId] = approverId;
    }
    final next = b.sale.copyWith(
      discountBp: discount?.kind == DiscountKind.percent ? discount!.bp : 0,
      discountAmount: discount?.kind == DiscountKind.amount
          ? discount!.amount.value
          : 0,
      discountApprovedBy: discount == null ? null : approverId,
    );
    _replaceSale(next);
    final after = bill(billId);
    if (discount != null && after.charges.total <= Money.zero) {
      _replaceSale(b.sale);
      throw const DiscountTooLarge();
    }
    return after;
  });

  @override
  Future<Result<OpenBill>> setItemDiscount(
    UuidValue itemId,
    ManualDiscount? discount, {
    UuidValue? approverId,
  }) => _run(() {
    if (discount != null &&
        approverId == null &&
        !_can(Permission.salesDiscount)) {
      throw const NotPermitted(Permission.salesDiscount);
    }
    final item = items.firstWhere((i) => i.id == itemId);
    final b = bill(item.saleId);
    if (b.payments.isNotEmpty) throw SplitLocked();
    final gross = Money(item.lineTotal + item.discountAmount);
    if (discount != null && discount.issue(gross) != null) {
      throw const DiscountTooLarge();
    }
    final cut = discount?.cut(gross) ?? Money.zero;
    _replaceItem(
      item.copyWith(
        discountBp: discount?.kind == DiscountKind.percent ? discount!.bp : 0,
        discountAmount: cut.value,
        lineTotal: (gross - cut).value,
      ),
    );
    if (discount != null && bill(item.saleId).charges.total <= Money.zero) {
      _replaceItem(item);
      throw const DiscountTooLarge();
    }
    if (approverId != null && discount != null) {
      itemDiscountApprovers[itemId] = approverId;
      _replaceSale(b.sale.copyWith(discountApprovedBy: approverId));
    }
    _sync(item.saleId);
    return bill(item.saleId);
  });

  @override
  Future<Result<void>> voidBill(
    UuidValue billId,
    String reason, {
    UuidValue? approverId,
  }) => _run(() {
    if (approverId != null) voidApprovers[billId] = approverId;
    if (approverId == null && !_can(Permission.salesVoid)) {
      throw const NotPermitted(Permission.salesVoid);
    }
    final text = reason.trim();
    if (text.isEmpty || text.length > FnbLimits.voidReason) {
      throw const BillInputInvalid(BillField.voidReason);
    }
    final b = bill(billId);
    // Bagian lunas tetap; QRIS menunggu dihapus (sama dengan voidOpenBill).
    for (final p in [...payments]) {
      if (p.saleId == billId &&
          p.deletedAt == null &&
          p.status == PaymentStatus.pending) {
        _replacePayment(p.copyWith(deletedAt: now));
      }
    }
    voided[billId] = text;
    _replaceSale(b.sale.copyWith(status: SaleStatus.voided));
  });

  @override
  Future<Result<void>> deleteEmptyBill(UuidValue billId) => _run(() {
    final b = bill(billId);
    if (b.items.isNotEmpty) throw BillNotEmpty();
    _replaceSale(b.sale.copyWith(deletedAt: now));
  });

  /// Dipakai kasir palsu saat bill dibayar.
  void markPaid(UuidValue billId) {
    final b = bill(billId);
    _replaceSale(b.sale.copyWith(status: SaleStatus.completed));
  }

  // --- Split bill (F1-10c) --------------------------------------------------

  void _needSales() {
    if (!_can(Permission.salesCreate)) {
      throw const NotPermitted(Permission.salesCreate);
    }
  }

  void _unlocked(OpenBill b) {
    if (b.payments.isNotEmpty) throw SplitLocked();
  }

  @override
  Future<Result<SplitBillData>> loadSplit(UuidValue billId) => _run(
    () => SplitBillData(
      bill: bill(billId),
      canPay: _can(Permission.salesCreate),
      canConfirm: _can(Permission.paymentsConfirm),
    ),
  );

  void _move(SaleItem source, Qty qty, String? label) {
    SaleItem sized(SaleItem row, Qty q) => row.copyWith(
      quantityMilli: q.milli,
      lineTotal: Money(row.unitPrice + row.modifierDelta)
          .timesMilli(q.milli)
          .value,
    );
    final root = source.splitFromItemId ?? source.id;
    final target = items
        .where(
          (i) =>
              i.deletedAt == null &&
              i.id != source.id &&
              (i.splitFromItemId ?? i.id) == root &&
              i.guestLabel == label &&
              i.kitchenStatus == source.kitchenStatus,
        )
        .firstOrNull;
    if (target != null) {
      _replaceItem(sized(target, Qty(target.quantityMilli) + qty));
    } else {
      final id = fakeId(_next++);
      items.add(
        sized(
          source,
          qty,
        ).copyWith(id: id, guestLabel: label, splitFromItemId: root),
      );
      if (itemModifiers[source.id] case final mods?) {
        itemModifiers[id] = [for (final m in mods) m.copyWith(saleItemId: id)];
      }
    }
    final left = Qty(source.quantityMilli) - qty;
    _replaceItem(
      left.isPositive ? sized(source, left) : source.copyWith(deletedAt: now),
    );
  }

  @override
  Future<Result<OpenBill>> setSplit(
    UuidValue billId,
    SplitMode? mode,
    int guests,
  ) => _run(() {
    _needSales();
    if (mode != null && !SplitLimits.validGuests(guests)) {
      throw const SplitInvalid(SplitError.guests);
    }
    final b = bill(billId);
    _unlocked(b);
    final keep = mode == null ? 0 : guests;
    for (final item in b.items) {
      final label = item.guestLabel;
      if (label == null || (guestIndex(label) ?? keep) < keep) continue;
      final current = _item(item.id);
      _move(current, Qty(current.quantityMilli), null);
    }
    _replaceSale(
      bill(billId).sale.copyWith(
        splitMode: mode,
        splitGuests: mode == null ? null : guests,
      ),
    );
    _sync(billId);
    return bill(billId);
  });

  @override
  Future<Result<OpenBill>> assignPortion(UuidValue itemId, String? guest) =>
      _run(() {
        _needSales();
        final item = _item(itemId);
        final b = bill(item.saleId);
        _unlocked(b);
        if (b.sale.splitMode != SplitMode.item) {
          throw const SplitInvalid(SplitError.mode);
        }
        if (guest != null &&
            (guestIndex(guest) ?? 99) >= (b.sale.splitGuests ?? 0)) {
          throw const SplitInvalid(SplitError.guest);
        }
        if (item.guestLabel != guest) {
          _move(item, splitPortion(Qty(item.quantityMilli)), guest);
          _sync(item.saleId);
        }
        return bill(item.saleId);
      });

  /// Bayar bagian (dipakai kasir palsu), aturan sama dengan `paySplitPart`.
  SplitPayResult payPart(
    UuidValue billId, {
    String? guest,
    Money? amount,
    required List<SalePaymentRequest> requests,
    bool pending = false,
  }) {
    if (!sessionOpen) throw CashSessionNotOpen();
    final b = bill(billId);
    final split = b.split ?? (throw const SplitInvalid(SplitError.notSet));
    final String label;
    final Money due;
    if (split.mode == SplitKind.amount) {
      final next =
          split.next ?? (throw const SplitInvalid(SplitError.partPaid));
      if (amount == null || amount <= Money.zero || amount > split.remaining) {
        throw const SplitInvalid(SplitError.amount);
      }
      label = next.label;
      due = amount;
    } else {
      if (guest == null || (guestIndex(guest) ?? 99) >= split.guests) {
        throw const SplitInvalid(SplitError.guest);
      }
      if (split.mode == SplitKind.item && split.unassigned.isNotEmpty) {
        throw const SplitInvalid(SplitError.unassigned);
      }
      final part = split.part(guest);
      if (part.payments.isNotEmpty) {
        throw const SplitInvalid(SplitError.partPaid);
      }
      due = part.due ?? Money.zero;
      if (due <= Money.zero) throw const SplitInvalid(SplitError.nothingDue);
      label = guest;
    }
    if (pending) {
      if (requests.length != 1 ||
          requests.single.method != PaymentMethod.qrisStatic) {
        throw const SplitInvalid(SplitError.pending);
      }
      payments.add(_payment(billId, label, PaymentMethod.qrisStatic, due));
    } else {
      final single = requests.length == 1;
      final amounts = [
        for (final p in requests)
          p.amount ?? (single && !p.isCash ? due : Money.zero),
      ];
      final settlement = settleTender(due, [
        for (final (i, p) in requests.indexed)
          TenderPart(amounts[i], isCash: p.isCash),
      ]);
      if (!settlement.isSettled) {
        throw SalePaymentShort(total: due, received: settlement.paid);
      }
      for (final (i, p) in requests.indexed) {
        payments.add(
          _payment(
            billId,
            label,
            p.method,
            amounts[i],
            change: p.isCash ? settlement.change : Money.zero,
            paid: true,
          ),
        );
      }
    }
    return _finish(billId);
  }

  Payment _payment(
    UuidValue billId,
    String label,
    PaymentMethod method,
    Money amount, {
    Money change = Money.zero,
    bool paid = false,
  }) => Payment(
    id: fakeId(_next++),
    tenantId: _tenant,
    saleId: billId,
    method: method,
    amount: amount.value,
    changeAmount: change.value,
    status: paid ? PaymentStatus.paid : PaymentStatus.pending,
    guestLabel: label,
    paidAt: now,
    createdAt: now,
    hlc: '',
  );

  SplitPayResult _finish(UuidValue billId) {
    final b = bill(billId);
    final split = b.split!;
    if (split.pending > Money.zero || split.paid < b.charges.total) {
      return SplitPayResult(bill: b);
    }
    markPaid(billId);
    final own = b.payments;
    final sale = b.sale.copyWith(
      number: 'PST-K01-261103-${(_receipts++).toString().padLeft(4, '0')}',
      status: SaleStatus.completed,
      subtotal: b.charges.subtotal.value,
      serviceBp: b.rates.service.value,
      taxBp: b.rates.tax.value,
      serviceAmount: b.charges.service.value,
      taxAmount: b.charges.tax.value,
      total: b.charges.total.value,
      paidAmount: b.charges.total.value,
      changeAmount: own.fold<int>(0, (a, p) => a + p.changeAmount),
      soldAt: now,
    );
    return SplitPayResult(
      receipt: CheckoutResult(
        sale: sale,
        items: b.items,
        modifiers: b.modifiers,
        payments: own,
      ),
    );
  }

  Payment _pending(UuidValue paymentId) {
    final p = payments
        .where((p) => p.id == paymentId && p.deletedAt == null)
        .firstOrNull;
    if (p == null) throw BillNotFound();
    if (p.status != PaymentStatus.pending) {
      throw const SplitInvalid(SplitError.notPending);
    }
    return p;
  }

  void _replacePayment(Payment p) =>
      payments[payments.indexWhere((x) => x.id == p.id)] = p;

  @override
  Future<Result<SplitPayResult>> confirmSplitPayment(UuidValue paymentId) =>
      _run(() {
        for (final p in [Permission.salesCreate, Permission.paymentsConfirm]) {
          if (!_can(p)) throw NotPermitted(p);
        }
        if (!sessionOpen) throw CashSessionNotOpen();
        final p = _pending(paymentId);
        _replacePayment(
          p.copyWith(status: PaymentStatus.paid, confirmedBy: fakeId(4)),
        );
        return _finish(p.saleId);
      });

  @override
  Future<Result<OpenBill>> cancelSplitPayment(UuidValue paymentId) => _run(() {
    _needSales();
    final p = _pending(paymentId);
    _replacePayment(p.copyWith(deletedAt: now));
    return bill(p.saleId);
  });
}
