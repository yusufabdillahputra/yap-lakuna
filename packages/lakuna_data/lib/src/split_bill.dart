part of 'open_bill.dart';

// Split bill F&B (F1-10c, layar 1.9): satu nota, pembayaran per tamu. Porsi
// mode *per item* dipecah menjadi baris `sale_items` sendiri dengan
// `guest_label` dan `split_from_item_id` = baris asal; pembayaran bagian
// disimpan di `payments` nota yang sama dengan `guest_label`.

/// Bill sudah punya pembayaran bagian (menunggu atau lunas): item, split,
/// batal bill, dan *Tutup & bayar* biasa ditolak.
class SplitLocked implements Exception {
  @override
  String toString() => 'SplitLocked';
}

enum SplitError {
  /// Bill belum di-split.
  notSet,

  /// Jumlah tamu di luar 2–8.
  guests,

  /// Aksi tidak cocok dengan mode split (mis. bagi porsi di mode rata).
  mode,

  /// Label tamu tidak sah untuk bill ini.
  guest,

  /// Mode per item: masih ada porsi tanpa tamu.
  unassigned,

  /// Tamu ini sudah punya pembayaran.
  partPaid,

  /// Tagihan tamu nol (tidak punya porsi).
  nothingDue,

  /// Nominal bebas kosong, nol, atau melebihi sisa.
  amount,

  /// Hanya satu pembayaran QRIS statis yang boleh menunggu konfirmasi.
  pending,

  /// Pembayaran bukan pembayaran bagian yang menunggu.
  notPending,
}

class SplitInvalid implements Exception {
  const SplitInvalid(this.error);

  final SplitError error;

  @override
  String toString() => 'SplitInvalid(${error.name})';
}

enum SplitPartStatus { unpaid, pending, paid }

/// Bagian satu tamu.
class GuestPart {
  const GuestPart({
    required this.label,
    required this.due,
    required this.items,
    required this.payments,
    required this.paid,
    required this.pending,
  });

  /// `A`–`H`.
  final String label;

  /// Tagihan tamu; `null` untuk tamu berikutnya di mode nominal bebas.
  final Money? due;

  /// Porsi tamu (mode per item).
  final List<SaleItem> items;
  final List<Payment> payments;

  /// Σ (jumlah − kembalian) pembayaran lunas.
  final Money paid;

  /// Σ pembayaran menunggu konfirmasi.
  final Money pending;

  SplitPartStatus get status => payments.isEmpty
      ? SplitPartStatus.unpaid
      : payments.any((p) => p.status == PaymentStatus.pending)
      ? SplitPartStatus.pending
      : SplitPartStatus.paid;

  Money get itemsTotal => Money.sum(items.map((i) => Money(i.lineTotal)));
}

/// Keadaan split sebuah bill.
class BillSplit {
  const BillSplit({
    required this.mode,
    required this.guests,
    required this.total,
    required this.parts,
    required this.unassigned,
    required this.paid,
    required this.pending,
  });

  final SplitKind mode;
  final int guests;
  final Money total;
  final List<GuestPart> parts;

  /// Porsi tanpa tamu (mode per item).
  final List<SaleItem> unassigned;
  final Money paid;
  final Money pending;

  Money get remaining => total - paid - pending;

  /// Ada pembayaran bagian: split dan item terkunci.
  bool get locked => parts.any((p) => p.payments.isNotEmpty);

  GuestPart part(String label) => parts.firstWhere((p) => p.label == label);

  /// Tamu berikutnya yang belum bayar (mode nominal bebas).
  GuestPart? get next => parts.where((p) => p.payments.isEmpty).firstOrNull;
}

Money _net(Payment p) => p.status == PaymentStatus.paid
    ? Money(p.amount - p.changeAmount)
    : Money.zero;

Money _waiting(Payment p) =>
    p.status == PaymentStatus.pending ? Money(p.amount) : Money.zero;

/// Keadaan split [bill]; `null` bila tidak di-split.
BillSplit? billSplit(OpenBill bill) =>
    _computeSplit(bill.sale, bill.items, bill.charges.total, bill.payments);

BillSplit? _computeSplit(
  Sale sale,
  List<SaleItem> items,
  Money total,
  List<Payment> payments,
) {
  final mode = sale.splitMode;
  if (mode == null) return null;
  final kind = SplitKind.values.byName(mode.name);
  final guests = SplitLimits.clampGuests(sale.splitGuests ?? 2);
  final paid = Money.sum(payments.map(_net));
  final pending = Money.sum(payments.map(_waiting));
  List<Payment> paymentsOf(String label) => [
    for (final p in payments)
      if (p.guestLabel == label) p,
  ];

  final List<String> labels;
  if (kind == SplitKind.amount) {
    final used = {for (final p in payments) ?p.guestLabel}.toList()..sort();
    labels = used;
    if (total - paid - pending > Money.zero &&
        used.length < SplitLimits.maxGuests) {
      labels.add(
        [for (var i = 0; i < SplitLimits.maxGuests; i++) guestLabel(i)]
            .firstWhere((l) => !used.contains(l)),
      );
    }
  } else {
    labels = [for (var i = 0; i < guests; i++) guestLabel(i)];
  }

  bool owned(SaleItem i, String label) =>
      kind == SplitKind.item && i.guestLabel == label;
  final dues = splitDues(
    mode: kind,
    total: total,
    guests: guests,
    guestSubtotals: [
      for (final l in labels)
        Money.sum([
          for (final i in items)
            if (owned(i, l)) Money(i.lineTotal),
        ]),
    ],
  );
  final unpaid = [
    for (final l in labels)
      if (paymentsOf(l).isEmpty) l,
  ];
  Money? dueOf(int index, String label) {
    final own = paymentsOf(label);
    if (kind == SplitKind.amount) {
      return own.isEmpty
          ? null
          : Money.sum(own.map((p) => _net(p) + _waiting(p)));
    }
    // Tamu terakhir yang belum bayar menanggung sisa, agar jumlah bagian
    // selalu sama dengan total.
    if (own.isEmpty && unpaid.length == 1) return total - paid - pending;
    return dues[index];
  }

  return BillSplit(
    mode: kind,
    guests: guests,
    total: total,
    parts: [
      for (final (index, label) in labels.indexed)
        GuestPart(
          label: label,
          due: dueOf(index, label),
          items: [
            for (final i in items)
              if (owned(i, label)) i,
          ],
          payments: paymentsOf(label),
          paid: Money.sum(paymentsOf(label).map(_net)),
          pending: Money.sum(paymentsOf(label).map(_waiting)),
        ),
    ],
    unassigned: kind != SplitKind.item
        ? const []
        : [
            for (final i in items)
              if (i.guestLabel == null ||
                  (guestIndex(i.guestLabel!) ?? guests) >= guests)
                i,
          ],
    paid: paid,
    pending: pending,
  );
}

/// Pembayaran (belum dihapus) bill [saleIds], urut dibuat.
Future<List<Payment>> _billPayments(
  DatabaseSession session,
  UuidValue tenantId,
  Iterable<UuidValue> saleIds, {
  Transaction? transaction,
}) async {
  final ids = saleIds.toSet();
  if (ids.isEmpty) return const [];
  return Payment.db.find(
    session,
    where: (p) =>
        p.tenantId.equals(tenantId) &
        p.saleId.inSet(ids) &
        p.deletedAt.equals(null),
    orderBy: (p) => p.createdAt,
    transaction: transaction,
  );
}

Future<void> _assertUnlocked(
  SyncTx w,
  CatalogScope scope,
  UuidValue saleId,
) async {
  final payments = await _billPayments(w.session, scope.tenantId, [
    saleId,
  ], transaction: w.transaction);
  if (payments.isNotEmpty) throw SplitLocked();
}

/// Soft delete baris modifier item [itemId].
Future<void> _deleteItemModifiers(
  SyncTx w,
  CatalogScope scope,
  UuidValue itemId,
  SyncStamp s,
  UuidValue staffId,
) async {
  final mods = await itemModifiers(w.session, scope.tenantId, [
    itemId,
  ], transaction: w.transaction);
  for (final m in mods[itemId] ?? const <SaleItemModifier>[]) {
    await w.update(
      m.copyWith(
        deletedAt: s.now,
        version: m.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
  }
}

/// Memindah [qty] dari baris [source] ke tamu [label] (`null` = belum
/// dibagi). Digabung ke baris dari asal yang sama bila ada; selain itu
/// baris baru (modifier disalin). [rows] diperbarui di tempat.
Future<void> _moveQuantity(
  SyncTx w,
  CatalogScope scope,
  List<SaleItem> rows,
  SaleItem source,
  Qty qty,
  String? label,
  SyncStamp s,
  UuidValue staffId,
) async {
  void replace(SaleItem row) {
    final i = rows.indexWhere((r) => r.id == row.id);
    if (i >= 0) rows[i] = row;
  }

  SaleItem sized(SaleItem row, Qty q) => row.copyWith(
    quantityMilli: q.milli,
    lineTotal: _lineTotal(Money(row.unitPrice), row.modifierDelta, q).value,
  );

  final root = source.splitFromItemId ?? source.id;
  final target = rows
      .where(
        (i) =>
            i.id != source.id &&
            (i.splitFromItemId ?? i.id) == root &&
            i.guestLabel == label &&
            i.kitchenStatus == source.kitchenStatus &&
            i.kitchenTicketId == source.kitchenTicketId,
      )
      .firstOrNull;
  if (target != null) {
    replace(
      await w.update(
        sized(target, Qty(target.quantityMilli) + qty).copyWith(
          version: target.version + 1,
          updatedAt: s.now,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      ),
    );
  } else {
    final inserted = await w.insert(
      sized(source, qty).copyWith(
        id: UuidValue.fromString(newId()),
        guestLabel: label,
        splitFromItemId: root,
        version: 1,
        createdAt: s.now,
        updatedAt: s.now,
        createdBy: staffId,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    rows.add(inserted);
    final mods = await itemModifiers(w.session, scope.tenantId, [
      source.id,
    ], transaction: w.transaction);
    for (final m in mods[source.id] ?? const <SaleItemModifier>[]) {
      await w.insert(
        m.copyWith(
          id: UuidValue.fromString(newId()),
          saleItemId: inserted.id,
          version: 1,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: staffId,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    }
  }

  final left = Qty(source.quantityMilli) - qty;
  if (left.isPositive) {
    replace(
      await w.update(
        sized(source, left).copyWith(
          version: source.version + 1,
          updatedAt: s.now,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      ),
    );
  } else {
    await w.update(
      source.copyWith(
        deletedAt: s.now,
        version: source.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    await _deleteItemModifiers(w, scope, source.id, s, staffId);
    rows.removeWhere((r) => r.id == source.id);
  }
}

/// Mengatur split bill [billId]: [mode] dan jumlah tamu [guests] (2–8).
/// [mode] `null` membatalkan split. Porsi tamu yang tidak ada lagi (atau
/// semua porsi saat dibatalkan) kembali ke *belum dibagi*.
Future<OpenBill> setBillSplit(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue billId,
  required SplitMode? mode,
  int guests = SplitLimits.minGuests,
}) async {
  if (mode != null && !SplitLimits.validGuests(guests)) {
    throw const SplitInvalid(SplitError.guests);
  }
  await store.write(actor: staffId, (w) async {
    final sale = await _openSale(
      w.session,
      scope,
      billId,
      transaction: w.transaction,
    );
    await _assertUnlocked(w, scope, sale.id);
    final rows = [
      ...await _items(w.session, scope.tenantId, [
        sale.id,
      ], transaction: w.transaction),
    ];
    final s = await w.stamp();
    final keep = mode == null ? 0 : guests;
    for (final item in [...rows]) {
      final label = item.guestLabel;
      if (label == null || (guestIndex(label) ?? keep) < keep) continue;
      final current = rows.firstWhere((r) => r.id == item.id);
      await _moveQuantity(
        w,
        scope,
        rows,
        current,
        Qty(current.quantityMilli),
        null,
        s,
        staffId,
      );
    }
    final updated = await w.update(
      sale.copyWith(
        splitMode: mode,
        splitGuests: mode == null ? null : guests,
        version: sale.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    await _refreshTotals(w, scope, updated, s, staffId);
  });
  return loadOpenBill(store, scope, billId);
}

/// Mode per item: memindah satu porsi baris [itemId] ke tamu [guest]
/// (`null` = kembali ke *belum dibagi*). Jumlah pecahan atau satu porsi
/// dipindah utuh.
Future<OpenBill> assignPortion(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue itemId,
  required String? guest,
}) async {
  final billId = await store.write(actor: staffId, (w) async {
    final (sale, item) = await _billItem(w, scope, itemId);
    await _assertUnlocked(w, scope, sale.id);
    if (sale.splitMode != SplitMode.item) {
      throw const SplitInvalid(SplitError.mode);
    }
    if (guest != null) {
      final index = guestIndex(guest);
      if (index == null || index >= (sale.splitGuests ?? 0)) {
        throw const SplitInvalid(SplitError.guest);
      }
    }
    if (item.guestLabel == guest) return sale.id;
    final rows = [
      ...await _items(w.session, scope.tenantId, [
        sale.id,
      ], transaction: w.transaction),
    ];
    final s = await w.stamp();
    await _moveQuantity(
      w,
      scope,
      rows,
      item,
      splitPortion(Qty(item.quantityMilli)),
      guest,
      s,
      staffId,
    );
    await _refreshTotals(w, scope, sale, s, staffId);
    return sale.id;
  });
  return loadOpenBill(store, scope, billId);
}

/// Hasil bayar bagian: bill terkini, atau [receipt] bila bill lunas.
class SplitPayResult {
  const SplitPayResult({this.bill, this.receipt});

  final OpenBill? bill;
  final CheckoutResult? receipt;
}

/// Membayar bagian tamu [guest] (mode per item / rata) atau tamu berikutnya
/// sebesar [amount] (nominal bebas). Tagihan dihitung ulang dari data.
/// [pending] menyimpan satu pembayaran QRIS statis sebagai *menunggu*.
/// Bill lunas (Σ pembayaran lunas = total) langsung diselesaikan.
Future<SplitPayResult> paySplitPart(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue billId,
  String? guest,
  Money? amount,
  required List<SalePaymentRequest> payments,
  bool pending = false,
}) async {
  checkPaymentRequests(payments);
  final receipt = await store.write(actor: staffId, (w) async {
    final cash = await requireOpenCashSession(store, w, scope);
    final sale = await _openSale(
      w.session,
      scope,
      billId,
      transaction: w.transaction,
    );
    final items = await _items(w.session, scope.tenantId, [
      sale.id,
    ], transaction: w.transaction);
    if (items.isEmpty) throw SaleEmpty();
    final rates = await loadFnbRates(
      w.session,
      scope,
      transaction: w.transaction,
    );
    final charges = _charges(sale, items, rates);
    final existing = await _billPayments(w.session, scope.tenantId, [
      sale.id,
    ], transaction: w.transaction);
    final split =
        _computeSplit(sale, items, charges.total, existing) ??
        (throw const SplitInvalid(SplitError.notSet));

    final String label;
    final Money due;
    if (split.mode == SplitKind.amount) {
      final next =
          split.next ?? (throw const SplitInvalid(SplitError.partPaid));
      final last = guestIndex(next.label) == SplitLimits.maxGuests - 1;
      if (amount == null ||
          amount <= Money.zero ||
          amount > split.remaining ||
          (last && amount != split.remaining)) {
        throw const SplitInvalid(SplitError.amount);
      }
      label = next.label;
      due = amount;
    } else {
      final index = guest == null ? null : guestIndex(guest);
      if (index == null || index >= split.guests) {
        throw const SplitInvalid(SplitError.guest);
      }
      if (split.mode == SplitKind.item && split.unassigned.isNotEmpty) {
        throw const SplitInvalid(SplitError.unassigned);
      }
      final part = split.part(guest!);
      if (part.payments.isNotEmpty) {
        throw const SplitInvalid(SplitError.partPaid);
      }
      due = part.due ?? Money.zero;
      if (due <= Money.zero) throw const SplitInvalid(SplitError.nothingDue);
      label = guest;
    }

    if (pending) {
      if (payments.length != 1 ||
          payments.single.method != PaymentMethod.qrisStatic) {
        throw const SplitInvalid(SplitError.pending);
      }
      final ready = await qrisStaticReady(
        w.session,
        scope,
        transaction: w.transaction,
      );
      if (!ready) {
        throw const SalePaymentUnsupported(PaymentMethod.qrisStatic);
      }
      final s = await w.stamp();
      await w.insert(
        Payment(
          tenantId: scope.tenantId,
          saleId: sale.id,
          method: PaymentMethod.qrisStatic,
          amount: due.value,
          changeAmount: 0,
          status: PaymentStatus.pending,
          guestLabel: label,
          paidAt: s.now,
          createdAt: s.now,
          updatedAt: s.now,
          createdBy: staffId,
          updatedBy: staffId,
          hlc: s.hlc.toString(),
          originDeviceId: s.deviceId,
        ),
        s,
      );
    } else {
      final (amounts, change) = await settlePayments(w, scope, due, payments);
      await insertPayments(
        w,
        scope,
        saleId: sale.id,
        staffId: staffId,
        payments: payments,
        amounts: amounts,
        change: change,
        stamp: await w.stamp(),
        guestLabel: label,
      );
    }
    return _completeIfPaid(
      w,
      scope,
      cash: cash,
      sale: sale,
      items: items,
      rates: rates,
      charges: charges,
      staffId: staffId,
    );
  });
  return receipt != null
      ? SplitPayResult(receipt: receipt)
      : SplitPayResult(bill: await loadOpenBill(store, scope, billId));
}

/// Menyelesaikan bill bila Σ pembayaran lunas mencapai total.
Future<CheckoutResult?> _completeIfPaid(
  SyncTx w,
  CatalogScope scope, {
  required CashSession cash,
  required Sale sale,
  required List<SaleItem> items,
  required FnbRates rates,
  required FnbCharges charges,
  required UuidValue staffId,
}) async {
  final payments = await _billPayments(w.session, scope.tenantId, [
    sale.id,
  ], transaction: w.transaction);
  if (payments.any((p) => p.status != PaymentStatus.paid)) return null;
  if (Money.sum(payments.map(_net)) < charges.total) return null;
  return _completeBill(
    w,
    scope,
    cash: cash,
    sale: sale,
    items: items,
    rates: rates,
    charges: charges,
    payments: payments,
    staffId: staffId,
    stamp: await w.stamp(),
  );
}

Future<(Sale, Payment)> _pendingPayment(
  SyncTx w,
  CatalogScope scope,
  UuidValue paymentId,
) async {
  final payment = await Payment.db.findFirstRow(
    w.session,
    where: (p) =>
        p.id.equals(paymentId) &
        p.tenantId.equals(scope.tenantId) &
        p.deletedAt.equals(null),
    transaction: w.transaction,
  );
  if (payment == null) throw BillNotFound();
  final sale = await _openSale(
    w.session,
    scope,
    payment.saleId,
    transaction: w.transaction,
  );
  if (payment.status != PaymentStatus.pending) {
    throw const SplitInvalid(SplitError.notPending);
  }
  return (sale, payment);
}

/// *Sudah Terbayar* untuk bagian QRIS yang menunggu. Bill lunas langsung
/// diselesaikan. Izin `payments:confirm` diperiksa di repositori.
Future<SplitPayResult> confirmSplitPayment(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue paymentId,
}) async {
  late UuidValue billId;
  final receipt = await store.write(actor: staffId, (w) async {
    final cash = await requireOpenCashSession(store, w, scope);
    final (sale, payment) = await _pendingPayment(w, scope, paymentId);
    billId = sale.id;
    final s = await w.stamp();
    await w.update(
      payment.copyWith(
        status: PaymentStatus.paid,
        confirmedBy: staffId,
        confirmedAt: s.now,
        paidAt: s.now,
        version: payment.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    final items = await _items(w.session, scope.tenantId, [
      sale.id,
    ], transaction: w.transaction);
    final rates = await loadFnbRates(
      w.session,
      scope,
      transaction: w.transaction,
    );
    return _completeIfPaid(
      w,
      scope,
      cash: cash,
      sale: sale,
      items: items,
      rates: rates,
      charges: _charges(sale, items, rates),
      staffId: staffId,
    );
  });
  return receipt != null
      ? SplitPayResult(receipt: receipt)
      : SplitPayResult(bill: await loadOpenBill(store, scope, billId));
}

/// Membatalkan bagian QRIS yang menunggu (soft delete).
Future<OpenBill> cancelSplitPayment(
  LakunaStore store,
  CatalogScope scope, {
  required UuidValue staffId,
  required UuidValue paymentId,
}) async {
  final billId = await store.write(actor: staffId, (w) async {
    final (sale, payment) = await _pendingPayment(w, scope, paymentId);
    final s = await w.stamp();
    await w.update(
      payment.copyWith(
        deletedAt: s.now,
        version: payment.version + 1,
        updatedAt: s.now,
        updatedBy: staffId,
        hlc: s.hlc.toString(),
        originDeviceId: s.deviceId,
      ),
      s,
    );
    return sale.id;
  });
  return loadOpenBill(store, scope, billId);
}
