import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:lakuna_flutter/data/repositories/history_repository.dart';
import 'package:lakuna_flutter/utils/result.dart';

UuidValue _id() => UuidValue.fromString(newId());

/// Riwayat palsu di memori (F1-11), meniru aturan `lakuna_data`: nilai retur
/// proporsional, batas sisa, catatan *Lainnya*, tunai butuh sesi, dan void
/// hanya untuk nota `completed` tanpa retur.
class FakeHistoryRepository extends HistoryRepository {
  FakeHistoryRepository({
    this.canReturn = true,
    this.canVoid = true,
    this.hasOpenSession = true,
    List<HistoryStaff>? staff,
  }) : staff = staff ?? [(id: _id(), name: 'Yusuf')];

  bool canReturn;
  bool canVoid;
  bool hasOpenSession;

  /// Perkiraan uang di laci (F1-03c); berkurang oleh retur tunai.
  Money? drawerCash;

  /// Sesi kasir terbuka; nota baru tercatat di sesi ini (F1-03d).
  final openSessionId = _id();
  final List<HistoryStaff> staff;
  final _tenant = _id();

  final sales = <CheckoutResult>[];
  final staffNames = <UuidValue, String>{};
  final returns = <SaleReturn>[];
  final returnItems = <SaleReturnItem>[];
  final filters = <HistoryFilter>[];
  final voids = <(UuidValue, String, UuidValue?)>[];

  /// Pengaturan struk cabang (logo F1-06b).
  ReceiptConfig receipt = const ReceiptConfig(settings: ReceiptSettings());

  /// Galat berikutnya untuk [list] (sekali pakai).
  Exception? listError;

  /// Hasil pencarian ditandai terpotong (F1-11b).
  bool truncateSearch = false;

  /// Sisa piutang nota kredit (F1-13).
  final outstanding = <UuidValue, Money>{};

  /// Nota ini tidak bisa di-void karena alasan ini (mis. kemarin).
  final blocked = <UuidValue, VoidBlock>{};
  var _counter = 0;
  var _returnCounter = 0;

  /// Nama pemberi diskon per nota (F1-04i).
  final discountGivers = <UuidValue, String>{};

  /// Menambah nota lunas: [items] = (nama, jumlah milli, harga satuan).
  CheckoutResult addSale(
    List<(String, int, int)> items, {
    PaymentMethod method = PaymentMethod.cash,
    String staffName = 'Yusuf',
    int? total,
    DateTime? soldAt,
    String? customerName,
    int? paidAmount,
    DateTime? dueOn,
    bool inOpenSession = true,
    int discount = 0,
    String? discountBy,
  }) {
    _counter++;
    final lines = [for (final (_, q, p) in items) q * p ~/ 1000];
    final subtotal = lines.fold(0, (a, b) => a + b);
    final staffId = staff.first.id;
    final sale = Sale(
      tenantId: _tenant,
      outletId: _id(),
      deviceId: _id(),
      cashSessionId: inOpenSession ? openSessionId : _id(),
      staffId: staffId,
      number: 'PST-K01-261103-${_counter.toString().padLeft(4, '0')}',
      status: SaleStatus.completed,
      subtotal: subtotal,
      tierDiscount: 0,
      discountAmount: discount,
      discountApprovedBy: discountBy == null ? null : _id(),
      changeAmount: 0,
      total: total ?? subtotal - discount,
      paidAmount: paidAmount ?? total ?? subtotal - discount,
      customerId: customerName == null ? null : _id(),
      customerName: customerName,
      dueOn: dueOn,
      itemCount: items.length,
      soldAt: soldAt ?? DateTime.utc(2026, 11, 3, 3, _counter),
      hlc: '',
    );
    if (discountBy != null) discountGivers[sale.id] = discountBy;
    final result = CheckoutResult(
      sale: sale,
      items: [
        for (final (i, (name, q, p)) in items.indexed)
          SaleItem(
            tenantId: _tenant,
            saleId: sale.id,
            variantId: _id(),
            productName: name,
            variantName: '',
            unitName: 'pcs',
            factorMilli: 1000,
            quantityMilli: q,
            listPrice: p,
            unitPrice: p,
            lineTotal: lines[i],
            unitCost: 0,
            tracksStock: true,
            sortOrder: i,
            hlc: '',
          ),
      ],
      payments: [
        Payment(
          tenantId: _tenant,
          saleId: sale.id,
          method: method,
          amount: paidAmount ?? total ?? subtotal - discount,
          changeAmount: 0,
          status: PaymentStatus.paid,
          paidAt: sale.soldAt,
          hlc: '',
        ),
      ],
      negativeStock: const [],
    );
    sales.add(result);
    staffNames[sale.id] = staffName;
    if (customerName != null) {
      outstanding[sale.id] = Money(sale.total - sale.paidAmount);
    }
    return result;
  }

  CheckoutResult _sale(UuidValue id) => sales.firstWhere(
    (s) => s.sale.id == id,
    orElse: () => throw SaleNotFound(),
  );

  void _replace(Sale sale) {
    final i = sales.indexWhere((s) => s.sale.id == sale.id);
    final old = sales[i];
    sales[i] = CheckoutResult(
      sale: sale,
      items: old.items,
      payments: old.payments,
      negativeStock: const [],
    );
  }

  Money _returned(UuidValue saleId) => Money.sum(
    returns.where((r) => r.saleId == saleId).map((r) => Money(r.amount)),
  );

  @override
  Future<Result<HistoryData>> load() async => Result.ok(
    HistoryData(
      staff: staff,
      businessName: 'Toko Bu Ani',
      outletName: 'Cabang Pusat',
      timezone: 'Asia/Jakarta',
      canReturn: canReturn,
      canVoid: canVoid,
      hasOpenSession: hasOpenSession,
      drawerCash: hasOpenSession ? drawerCash : null,
      openSessionId: hasOpenSession ? openSessionId : null,
      receipt: receipt,
    ),
  );

  @override
  Future<Result<HistoryPage>> list(HistoryFilter filter) async {
    filters.add(filter);
    if (listError case final e?) {
      listError = null;
      return Result.error(e);
    }
    final rows = <HistoryRow>[
      for (final s in sales.reversed)
        if (_matches(s, filter))
          HistoryRow(
            sale: s.sale,
            staffName: staffNames[s.sale.id] ?? '',
            methods: [for (final p in s.payments) p.method],
            returned: _returned(s.sale.id),
            outstanding: outstanding[s.sale.id] ?? Money.zero,
          ),
    ];
    return Result.ok(
      HistoryPage(
        rows: rows,
        from: DateTime.utc(2026, 11, 2, 17),
        searching: filter.searching,
        truncated: filter.searching && truncateSearch,
      ),
    );
  }

  bool _matches(CheckoutResult s, HistoryFilter f) {
    final status = s.sale.status;
    final okStatus = switch (f.status) {
      HistoryStatus.all => true,
      HistoryStatus.completed => status == SaleStatus.completed,
      HistoryStatus.returned =>
        status == SaleStatus.partiallyReturned || status == SaleStatus.returned,
      HistoryStatus.voided => status == SaleStatus.voided,
    };
    final okMethod =
        f.method == null || s.payments.any((p) => p.method == f.method);
    final okStaff = f.staffId == null || s.sale.staffId == f.staffId;
    final q = f.trimmedQuery.toLowerCase();
    bool has(String? v) => v != null && v.toLowerCase().contains(q);
    final okQuery =
        q.isEmpty ||
        has(s.sale.number) ||
        has(s.sale.customerName) ||
        s.payments.any((p) => has(p.reference));
    return okStatus && okMethod && okStaff && okQuery;
  }

  @override
  Future<Result<SaleDetail>> detail(UuidValue saleId) async {
    try {
      return Result.ok(_detail(saleId));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  SaleDetail _detail(UuidValue saleId) {
    final s = _sale(saleId);
    final mine = returns.where((r) => r.saleId == saleId).toList();
    final ids = {for (final r in mine) r.id};
    final returned = <UuidValue, int>{};
    for (final i in returnItems.where((i) => ids.contains(i.saleReturnId))) {
      returned[i.saleItemId] = (returned[i.saleItemId] ?? 0) + i.quantityMilli;
    }
    final shares = lineShares(Money(s.sale.total), [
      for (final i in s.items) i.lineTotal,
    ]);
    return SaleDetail(
      receipt: s,
      staffName: staffNames[saleId] ?? '',
      voidedByName: s.sale.voidedBy == null
          ? null
          : staff.where((e) => e.id == s.sale.voidedBy).firstOrNull?.name ??
                'Manajer',
      discountApprovedByName: discountGivers[saleId],
      returns: mine,
      returnedMilli: returned,
      outstanding: outstanding[saleId] ?? Money.zero,
      shares: {
        for (final (i, item) in s.items.indexed) item.id: shares[i],
      },
      voidBlock: s.sale.status != SaleStatus.completed
          ? VoidBlock.status
          : mine.isNotEmpty
          ? VoidBlock.returned
          : blocked[saleId],
    );
  }

  @override
  Future<Result<SaleReturn>> returnSale({
    required UuidValue saleId,
    required List<ReturnLine> lines,
    required SaleReturnReason reason,
    String? note,
    required RefundMethod refundMethod,
    required bool restock,
  }) async {
    try {
      if (!canReturn) throw const NotPermitted(Permission.salesReturn);
      final d = _detail(saleId);
      if (validateReturnNote(
            other: reason == SaleReturnReason.other,
            note: note,
          ) !=
          null) {
        throw const ReturnInvalid(ReturnError.note);
      }
      if (!d.canReturn) throw const ReturnInvalid(ReturnError.status);
      if (lines.every((l) => l.quantity.milli <= 0)) {
        throw const ReturnInvalid(ReturnError.empty);
      }
      var amount = Money.zero;
      final items = <(SaleItem, int, Money)>[];
      for (final (i, line) in lines.indexed) {
        final item = d.items.where((x) => x.id == line.saleItemId).firstOrNull;
        if (item == null || line.quantity.milli > d.remainingMilli(item)) {
          throw ReturnInvalid(ReturnError.quantity, index: i);
        }
        final value = d.returnValue(item, line.quantity.milli);
        amount += value;
        items.add((item, line.quantity.milli, value));
      }
      // Nota kredit: nilai retur memotong piutang dulu (F1-13).
      final split = purchaseReturnSplit(amount: amount, debt: d.outstanding);
      final method =
          split.refund == Money.zero && split.debtReduction > Money.zero
          ? RefundMethod.debt
          : refundMethod;
      if (method == RefundMethod.debt &&
          (split.refund > Money.zero || split.debtReduction == Money.zero)) {
        throw const ReturnInvalid(ReturnError.refundMethod);
      }
      if (method == RefundMethod.cash && !hasOpenSession) {
        throw CashSessionNotOpen();
      }
      if (split.debtReduction > Money.zero) {
        outstanding[saleId] = d.outstanding - split.debtReduction;
      }
      if (method == RefundMethod.cash && drawerCash != null) {
        drawerCash = drawerCash! - split.refund;
      }
      _returnCounter++;
      final ret = SaleReturn(
        tenantId: _tenant,
        outletId: d.sale.outletId,
        deviceId: d.sale.deviceId,
        saleId: saleId,
        staffId: staff.first.id,
        number:
            'RT-PST-K01-261103-${_returnCounter.toString().padLeft(4, '0')}',
        reason: reason,
        note: note,
        refundMethod: method,
        amount: amount.value,
        restock: restock,
        returnedAt: DateTime.utc(2026, 11, 3, 4),
        hlc: '',
      );
      returns.add(ret);
      for (final (item, q, value) in items) {
        returnItems.add(
          SaleReturnItem(
            tenantId: _tenant,
            saleReturnId: ret.id,
            saleItemId: item.id,
            quantityMilli: q,
            amount: value.value,
            hlc: '',
          ),
        );
      }
      final after = _detail(saleId);
      final state = returnState(
        sold: [for (final i in after.items) i.quantityMilli],
        returned: [for (final i in after.items) after.returnedMilli[i.id] ?? 0],
      );
      _replace(
        d.sale.copyWith(
          status: state == ReturnState.full
              ? SaleStatus.returned
              : SaleStatus.partiallyReturned,
        ),
      );
      return Result.ok(ret);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Sale>> voidSale({
    required UuidValue saleId,
    required String reason,
    UuidValue? approverId,
  }) async {
    voids.add((saleId, reason, approverId));
    try {
      if (approverId == null && !canVoid) {
        throw const NotPermitted(Permission.salesVoid);
      }
      final text = reason.trim();
      if (text.isEmpty || text.length > FnbLimits.voidReason) {
        throw const SaleVoidInvalid(VoidError.reason);
      }
      final d = _detail(saleId);
      if (d.voidBlock case final block?) {
        throw SaleVoidInvalid(VoidError.blocked, block: block);
      }
      final sale = d.sale.copyWith(
        status: SaleStatus.voided,
        voidReason: text,
        voidedBy: approverId ?? staff.first.id,
        voidedAt: DateTime.utc(2026, 11, 3, 4),
      );
      _replace(sale);
      return Result.ok(sale);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
