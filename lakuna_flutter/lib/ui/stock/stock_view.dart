import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/purchases_repository.dart' show PurchaseRestock;
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/stock_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../data/services/report_document.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/confirm_discard.dart';
import '../core/format.dart';
import '../core/leave_guard.dart';
import '../core/route_return.dart';
import '../products/product_widgets.dart';
import '../reports/report_labels.dart' show moneyLabel;
import 'stock_print.dart';
import 'stock_view_model.dart';

/// Layar *Stok* (1.18, F1-08). Memiliki [StockViewModel] dan memuat stok
/// lokasi bawaan saat dibuka.
class StockScreen extends StatefulWidget {
  const StockScreen({
    super.key,
    required this.repository,
    required this.session,
    required this.store,
    this.exporter = const PlatformSpreadsheetExporter(),
    this.initialTab,
    this.initialVariantId,
    this.initialLocationId,
    this.onRestock,
    this.restockDrafts,
    this.onOpenDraft,
    this.leaveGuard,
  });

  /// Penjaga keluar rute: draf penyesuaian yang berisi ditanyakan (F1-08k).
  final LeaveGuard? leaveGuard;

  /// *Buat pembelian* dari daftar stok minimum (F1-08c); `null` bila staf
  /// tidak boleh mengelola pembelian. Selesai saat staf kembali ke Stok;
  /// layar lalu memuat ulang stok agar daftar minimum tidak basi.
  final Future<void> Function(PurchaseRestock)? onRestock;

  /// Draf pembelian yang sudah memuat barang di bawah minimum (F1-08g);
  /// bila ada, staf ditawari membuka draf itu dulu.
  final Future<Result<List<RestockDraft>>> Function(
    UuidValue locationId,
    Iterable<UuidValue> variantIds,
  )?
  restockDrafts;

  /// Membuka draf pembelian [purchaseId] dengan barang [restock] yang belum
  /// ada ditambahkan (F1-08i); selesai saat staf kembali.
  final Future<void> Function(UuidValue purchaseId, PurchaseRestock restock)?
  onOpenDraft;

  final StockRepository repository;
  final SessionRepository session;
  final StoreRepository store;

  /// Penyimpan PDF *Cetak stok* (F1-08b).
  final SpreadsheetExporter exporter;

  /// Tab yang dibuka pertama (mis. dari Master data › Lokasi stok).
  final StockTab? initialTab;

  /// Kartu stok yang dibuka pertama (dari detail pembelian, F1-12c).
  final UuidValue? initialVariantId;
  final UuidValue? initialLocationId;

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen>
    with RouteReturnMixin<StockScreen> {
  late final _viewModel = StockViewModel(
    repository: widget.repository,
    exporter: widget.exporter,
    canAdjust:
        widget.session.current?.permissions.contains(Permission.stockAdjust) ??
        false,
    // Tanda "sudah di draf" hanya untuk staf yang boleh membuat pembelian
    // (F1-08h). Ditangkap sekali: ganti kasir selalu lewat /login yang
    // membuang layar ini, dan repositori tetap memeriksa izin.
    restockDrafts: widget.onRestock == null ? null : widget.restockDrafts,
  );

  @override
  void initState() {
    super.initState();
    if (widget.initialTab case final tab?) _viewModel.setTab(tab);
    if (widget.initialVariantId case final variant?) {
      _viewModel.focusCard(
        variantId: variant,
        locationId: widget.initialLocationId,
      );
    }
    _viewModel.load.execute();
    widget.leaveGuard?.check = _confirmLeave;
  }

  @override
  void didUpdateWidget(StockScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.leaveGuard != widget.leaveGuard) {
      if (oldWidget.leaveGuard?.check == _confirmLeave) {
        oldWidget.leaveGuard?.check = null;
      }
      widget.leaveGuard?.check = _confirmLeave;
    }
  }

  /// Draf penyesuaian tersimpan di perangkat (F1-08o), jadi layar ini
  /// hanya bertanya sebelum ditinggalkan bila draf belum tersimpan (F1-08k).
  /// Selama simpan berjalan, keluar ditahan.
  Future<bool> _confirmLeave() async {
    final vm = _viewModel;
    if (!mounted || isRouteClosing(context)) return true;
    if (vm.busy) return false;
    // Ketukan menu kedua selama menunggu memakai jawaban yang sama
    // ([LeaveGuard.canLeave]).
    await vm.flushDraft();
    if (!mounted) return true;
    if (!vm.hasUnsavedChanges) {
      // Hapus draf yang gagal (baris terakhir dibuang) dicoba lagi.
      if (vm.draftWriteFailed) await _discardStoredDraft();
      return true;
    }
    final leave = await confirmDiscardChanges(
      context,
      body: AppLocalizations.of(context).stockDiscardBody,
      key: 'stock-discard',
      // Simpan hanya bila tombol Simpan penyesuaian sendiri aktif (F1-08n).
      onSave: vm.canSave ? _saveBeforeLeaving : null,
    );
    // *Buang*: draf lama yang tersimpan ikut dibuang.
    if (leave && vm.hasDraftContent) await _discardStoredDraft();
    return leave;
  }

  /// Menghapus draf tersimpan sebelum layar ditinggalkan, selagi sesi staf
  /// yang sekarang masih berlaku (ganti kasir) (F1-08o).
  Future<void> _discardStoredDraft() async {
    _viewModel.clearDraft();
    await _viewModel.flushDraft();
  }

  /// *Simpan* di dialog keluar (F1-08n): selama simpan, navigasi lain
  /// ditolak; bila gagal, tetap di layar.
  Future<bool> _saveBeforeLeaving() async {
    final guard = widget.leaveGuard?..saving = true;
    try {
      return await _saveAdjustmentFromDialog(_viewModel);
    } finally {
      guard?.saving = false;
    }
  }

  @override
  void dispose() {
    if (widget.leaveGuard?.check == _confirmLeave) {
      widget.leaveGuard?.check = null;
    }
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void onRouteReturn() => unawaited(_viewModel.load.execute());

  /// Pencarian draf sedang berjalan (F1-08g). Terpisah dari [isAway] karena
  /// halaman Stok masih rute teratas selama menunggu, jadi pembangunan ulang
  /// router bisa melepas penjaga [whileAway] sebelum dialog atau form
  /// terbuka; kueri lokal selalu selesai, jadi bendera ini aman dilepas di
  /// `finally`.
  var _checkingDraft = false;

  Future<void> _restock(PurchaseRestock r) async {
    // Ketukan ganda tidak membuka dua form pembelian.
    if (isAway || _checkingDraft) return;
    final List<RestockDraft>? draft;
    _checkingDraft = true;
    try {
      draft = await _existingDraft(r);
    } finally {
      _checkingDraft = false;
    }
    if (!mounted) return;
    try {
      // Dialog dan form didorong sinkron di sini, jadi Stok langsung bukan
      // rute teratas dan penjaga [whileAway] tidak dilepas terlalu dini.
      await whileAway(() async {
        final found = draft;
        if (found == null) return widget.onRestock!(r);
        switch (await _askDraft(found, r)) {
          case _DraftChoice.open:
            // Barang yang sudah ada di draf lain tidak ditambahkan lagi,
            // agar tidak dipesan dua kali (F1-08i).
            final elsewhere = {
              for (final d in found.skip(1)) ...d.variantIds,
            };
            await widget.onOpenDraft!(
              found.first.purchaseId,
              PurchaseRestock(
                locationId: r.locationId,
                locationName: r.locationName,
                lines: [
                  for (final l in r.lines)
                    if (!elsewhere.contains(l.variantId)) l,
                ],
              ),
            );
          case _DraftChoice.create:
            await widget.onRestock!(r);
          case null:
            break;
        }
      });
    } finally {
      if (mounted) await _viewModel.load.execute();
    }
  }

  /// Draf yang sudah memuat barang ini (F1-08g); galat baca diabaikan agar
  /// *Buat pembelian* tetap bisa dipakai.
  Future<List<RestockDraft>?> _existingDraft(PurchaseRestock r) async {
    final find = widget.restockDrafts;
    if (find == null || widget.onOpenDraft == null) return null;
    final result = await find(r.locationId, {
      for (final l in r.lines) l.variantId,
    });
    return switch (result) {
      Ok(:final value) when value.isNotEmpty => value,
      _ => null,
    };
  }

  Future<_DraftChoice?> _askDraft(
    List<RestockDraft> drafts,
    PurchaseRestock r,
  ) => showFDialog<_DraftChoice>(
    context: context,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      builder: (context, style) {
        final l10n = AppLocalizations.of(context);
        final first = drafts.first;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('stock-restock-draft'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                l10n.stockRestockDraftTitle,
                style: context.theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                l10n.stockRestockDraftBody(
                  first.number,
                  first.matched,
                  r.lines.length,
                ),
              ),
              if (drafts.length > 1)
                Text(
                  l10n.stockRestockDraftOthers(drafts.length - 1),
                  style: _muted(context),
                ),
              // Tombol bertumpuk agar muat di ponsel 360 px.
              FButton(
                key: const ValueKey('stock-restock-open-draft'),
                onPress: () => Navigator.of(context).pop(_DraftChoice.open),
                child: Flexible(
                  child: Text(
                    l10n.stockRestockDraftOpen,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              FButton(
                key: const ValueKey('stock-restock-new'),
                variant: .outline,
                onPress: () => Navigator.of(context).pop(_DraftChoice.create),
                child: Flexible(
                  child: Text(
                    l10n.stockRestockDraftNew,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              FButton(
                key: const ValueKey('stock-restock-cancel'),
                variant: .ghost,
                onPress: () => Navigator.of(context).pop(),
                child: Flexible(
                  child: Text(
                    l10n.stockRestockDraftCancel,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    final outlet = widget.store.current?.outlet;
    return StockView(
      viewModel: _viewModel,
      staffName: widget.session.current?.name ?? '',
      outletName: outlet?.name ?? '',
      timezone: outlet?.timezone,
      onRestock: widget.onRestock == null ? null : _restock,
    );
  }
}

class StockView extends StatelessWidget {
  const StockView({
    super.key,
    required this.viewModel,
    required this.staffName,
    required this.outletName,
    this.timezone,
    this.onRestock,
  });

  final StockViewModel viewModel;
  final String staffName;
  final String outletName;
  final String? timezone;
  final ValueChanged<PurchaseRestock>? onRestock;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        final l10n = AppLocalizations.of(context);
        final vm = viewModel;
        if (!vm.loaded) {
          if (vm.load.error) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: LoadFailedAlert(
                key: const ValueKey('stock-load-error'),
                message: l10n.stockLoadFailed,
                onRetry: vm.load.execute,
              ),
            );
          }
          return const Center(child: FCircularProgress());
        }
        final width = constraints.maxWidth;
        final narrow = width < 600;
        final location = vm.location;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              PageHeader(
                title: l10n.stockTitle,
                subtitle: l10n.stockSubtitle(location?.name ?? '', outletName),
                action: _HeaderActions(
                  narrow: narrow,
                  print: FButton(
                    key: const ValueKey('stock-print'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: vm.canPrint ? () => _print(context) : null,
                    prefix: vm.printList.running
                        ? const SizedBox.square(
                            dimension: 16,
                            child: FCircularProgress(),
                          )
                        : const Icon(TablerIcons.printer),
                    child: Flexible(child: Text(l10n.stockPrint)),
                  ),
                  location: vm.locations.length > 1
                      ? IgnorePointer(
                          // Ganti lokasi selagi menyimpan akan membuang draf.
                          ignoring: vm.save.running || vm.printList.running,
                          child: _LocationSelect(viewModel: vm),
                        )
                      : null,
                ),
              ),
              if (vm.printList.completed && vm.printPath != null)
                FAlert(
                  key: const ValueKey('stock-print-saved'),
                  title: Text(l10n.stockPrintSaved(vm.printPath!)),
                )
              else if (vm.printList.error)
                FAlert(
                  key: const ValueKey('stock-print-failed'),
                  variant: .destructive,
                  title: Text(l10n.stockPrintFailed),
                ),
              if (narrow)
                _TabPills(viewModel: vm)
              else
                _TabBar(viewModel: vm, scrollable: width < 900),
              if (vm.load.error)
                LoadFailedAlert(
                  key: const ValueKey('stock-reload-error'),
                  message: l10n.stockLoadFailed,
                  onRetry: vm.load.execute,
                ),
              switch (vm.tab) {
                StockTab.list => _ListTab(viewModel: vm, narrow: narrow),
                StockTab.adjustment => _AdjustmentTab(
                  viewModel: vm,
                  staffName: staffName,
                  timezone: timezone,
                  narrow: narrow,
                  sideBySide: width >= 900,
                  onRestock: onRestock,
                ),
                StockTab.card => _StockCardPanel(
                  viewModel: vm,
                  timezone: timezone,
                ),
                StockTab.minimum => _MinimumPanel(
                  viewModel: vm,
                  onRestock: onRestock,
                ),
                StockTab.locations => _LocationsTab(viewModel: vm),
              },
            ],
          ),
        );
      },
    ),
  );

  /// *Cetak stok* (F1-08b): semua baris lokasi terpilih, tanpa saringan
  /// pencarian.
  void _print(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final location = vm.printLocationName;
    final now = DateTime.now();
    final rows = vm.printRows;
    vm.printList.execute((
      () => reportPdf(
        stockPrintTable(
          l10n,
          rows: rows,
          location: location,
          outlet: outletName,
          staff: staffName,
          printedAt: now,
          timezone: timezone,
        ),
        money: (v) => moneyLabel(l10n, Money(v)),
      ),
      stockPrintFileName(location, now, timezone),
    ));
  }
}

/// Tombol kepala layar Stok: *Cetak stok* dan pilihan lokasi (bila > 1).
/// Ponsel: bertumpuk selebar layar.
class _HeaderActions extends StatelessWidget {
  const _HeaderActions({
    required this.narrow,
    required this.print,
    this.location,
  });

  final bool narrow;
  final Widget print;
  final Widget? location;

  @override
  Widget build(BuildContext context) {
    final location = this.location;
    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [?location, print],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        print,
        if (location != null) SizedBox(width: 220, child: location),
      ],
    );
  }
}

// --- Bantuan tampilan ---------------------------------------------------------

String _tabLabel(AppLocalizations l10n, StockTab tab) => switch (tab) {
  StockTab.list => l10n.stockTabList,
  StockTab.adjustment => l10n.stockTabAdjustment,
  StockTab.card => l10n.stockTabCard,
  StockTab.minimum => l10n.stockTabMinimum,
  StockTab.locations => l10n.stockTabLocations,
};

String stockReasonLabel(AppLocalizations l10n, StockAdjustmentReason r) =>
    switch (r) {
      StockAdjustmentReason.routineCheck => l10n.stockReasonRoutineCheck,
      StockAdjustmentReason.damaged => l10n.stockReasonDamaged,
      StockAdjustmentReason.lost => l10n.stockReasonLost,
      StockAdjustmentReason.expired => l10n.stockReasonExpired,
      StockAdjustmentReason.other => l10n.stockReasonOther,
    };

String stockErrorMessage(AppLocalizations l10n, StockAdjustmentError? e) =>
    switch (e) {
      StockAdjustmentError.empty => l10n.stockErrorEmpty,
      StockAdjustmentError.negative => l10n.stockErrorNegative,
      StockAdjustmentError.duplicate => l10n.stockErrorDuplicate,
      StockAdjustmentError.notGoods => l10n.stockErrorNotGoods,
      StockAdjustmentError.unknownVariant => l10n.stockErrorUnknownVariant,
      StockAdjustmentError.unknownLocation => l10n.stockErrorUnknownLocation,
      StockAdjustmentError.noChange => l10n.stockErrorNoChange,
      StockAdjustmentError.noteTooLong => l10n.stockErrorNoteTooLong,
      null => l10n.stockErrorGeneric,
    };

String _locationErrorMessage(
  AppLocalizations l10n,
  StockLocationNameError e,
) => switch (e) {
  StockLocationNameError.empty => l10n.stockLocationErrorEmpty,
  StockLocationNameError.tooLong => l10n.stockLocationErrorTooLong,
  StockLocationNameError.duplicate => l10n.stockLocationErrorDuplicate,
};

String _sourceLabel(AppLocalizations l10n, StockSourceType t) => switch (t) {
  StockSourceType.opening => l10n.stockSourceOpening,
  StockSourceType.adjustment => l10n.stockSourceAdjustment,
  StockSourceType.sale => l10n.stockSourceSale,
  StockSourceType.saleReturn => l10n.stockSourceSaleReturn,
  StockSourceType.purchase => l10n.stockSourcePurchase,
  StockSourceType.purchaseReturn => l10n.stockSourcePurchaseReturn,
  StockSourceType.transfer => l10n.stockSourceTransfer,
};

/// "Penyesuaian SA-… · Rusak (Budi)".
/// Catatan gerak stok untuk ditampilkan; penanda `void` dari pembatalan
/// nota diterjemahkan. Kosong menjadi `null`.
String? stockEntryNote(AppLocalizations l10n, String? note) => switch (note) {
  null || '' => null,
  voidMovementNote => l10n.stockNoteVoid,
  final n => n,
};

String _entryDescription(AppLocalizations l10n, StockCardEntry e) {
  final buf = StringBuffer(_sourceLabel(l10n, e.sourceType));
  if (e.documentNumber case final n?) buf.write(' $n');
  if (e.reason case final r?) buf.write(' · ${stockReasonLabel(l10n, r)}');
  if (e.staffName case final s? when s.isNotEmpty) buf.write(' ($s)');
  return buf.toString();
}

/// `03/11/26` di zona waktu cabang.
String _formatDate(DateTime time, String? timezone) {
  final t = outletLocalTime(time, timezone);
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(t.day)}/${two(t.month)}/${two(t.year % 100)}';
}

/// `03/11/26 09.15` di zona waktu cabang.
String _formatDateTime(DateTime time, String? timezone) =>
    '${_formatDate(time, timezone)} ${formatClock(time, timezone)}';

/// Selisih bertanda: `+1,5`, `-0,3`, `0`.
String _signedQty(BuildContext context, Qty q) =>
    q.isPositive ? '+${formatQty(context, q)}' : formatQty(context, q);

/// Warna selisih: merah bila berkurang, hijau bila bertambah.
Color _diffColor(BuildContext context, int sign) {
  final theme = context.theme;
  if (sign < 0) return theme.colors.destructive;
  if (sign > 0) {
    return theme.colors.brightness == Brightness.dark
        ? const Color(0xFF7BF1A8)
        : const Color(0xFF016630);
  }
  return theme.colors.mutedForeground;
}

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

const _tabular = [FontFeature.tabularFigures()];

/// Pil merah *Minus*.
class _NegativePill extends StatelessWidget {
  const _NegativePill();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final dark = theme.colors.brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF460809) : const Color(0xFFFFE2E2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(
          AppLocalizations.of(context).stockBadgeNegative,
          style: theme.typography.body.xs.copyWith(
            fontWeight: FontWeight.w700,
            color: dark ? const Color(0xFFFFA2A2) : const Color(0xFF9F0712),
          ),
        ),
      ),
    );
  }
}

/// Tanda status baris stok: *Minus* atau *Di bawah minimum*.
Widget? _statusBadge(BuildContext context, StockRow r) {
  if (r.stock.milli < 0) return const _NegativePill();
  if (r.belowMinimum) {
    return StockPill(
      text: AppLocalizations.of(context).stockBadgeLow,
      low: true,
    );
  }
  return null;
}

/// Simpan penyesuaian dari dialog *Buang perubahan?* (F1-08n): `true` bila
/// tersimpan. Bila gagal, tab *Penyesuaian* dibuka agar pesan galat di bawah
/// draf terlihat.
Future<bool> _saveAdjustmentFromDialog(StockViewModel vm) async {
  await vm.save.execute();
  if (vm.save.result is Ok) return true;
  vm.setTab(StockTab.adjustment);
  return false;
}

// --- Kepala: lokasi dan tab --------------------------------------------------

class _LocationSelect extends StatefulWidget {
  const _LocationSelect({required this.viewModel});

  final StockViewModel viewModel;

  @override
  State<_LocationSelect> createState() => _LocationSelectState();
}

class _LocationSelectState extends State<_LocationSelect> {
  /// Naik saat ganti lokasi dibatalkan, agar pilihan kembali ke lokasi
  /// semula (F1-08k).
  var _revision = 0;

  Future<void> _select(String id) async {
    final vm = widget.viewModel;
    final target = UuidValue.fromString(id);
    if (target == vm.location?.id) return;
    // Lokasi tidak bisa diganti selama penyesuaian disimpan (F1-08o).
    if (vm.busy) {
      setState(() => _revision++);
      return;
    }
    await vm.flushDraft();
    if (!mounted) return;
    if (vm.hasUnsavedChanges) {
      final discard =
          !vm.busy &&
          await confirmDiscardChanges(
            context,
            body: AppLocalizations.of(context).stockLocationDiscardBody,
            key: 'stock-location-discard',
            // Simpan di lokasi lama lalu pindah (F1-08n).
            onSave: vm.canSave ? () => _saveAdjustmentFromDialog(vm) : null,
          );
      if (!mounted) return;
      if (!discard) {
        setState(() => _revision++);
        return;
      }
      // *Buang*: draf lama lokasi ini yang tersimpan ikut dibuang (F1-08o).
      if (vm.hasDraftContent) vm.clearDraft();
    }
    await vm.selectLocation(target);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = widget.viewModel;
    return FSelect<String>(
      // Dibangun ulang bila daftar atau nama lokasi berubah, atau ganti
      // lokasi dibatalkan.
      key: ValueKey(
        'stock-location-select-${vm.locations.map((l) => l.name).join('|')}'
        '${_revision == 0 ? '' : '-$_revision'}',
      ),
      hint: l10n.stockLocation,
      items: {for (final l in vm.locations) l.name: l.id.uuid},
      control: .managed(
        initial: vm.location?.id.uuid,
        onChange: (id) {
          if (id != null) unawaited(_select(id));
        },
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.viewModel, required this.scrollable});

  final StockViewModel viewModel;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FTabs(
      scrollable: scrollable,
      control: .lifted(
        index: viewModel.tab.index,
        onChange: (i) => viewModel.setTab(StockTab.values[i]),
      ),
      children: [
        for (final tab in StockTab.values)
          FTabEntry(
            label: Text(
              _tabLabel(l10n, tab),
              key: ValueKey('stock-tab-${tab.name}'),
            ),
            child: const SizedBox.shrink(),
          ),
      ],
    );
  }
}

class _TabPills extends StatelessWidget {
  const _TabPills({required this.viewModel});

  final StockViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: [
          for (final tab in StockTab.values)
            ChoicePill(
              key: ValueKey('stock-pill-${tab.name}'),
              label: _tabLabel(l10n, tab),
              selected: viewModel.tab == tab,
              onTap: () => viewModel.setTab(tab),
            ),
        ],
      ),
    );
  }
}

// --- Tab Daftar produk -------------------------------------------------------

void _openCard(StockViewModel vm, UuidValue variantId) {
  vm.setTab(StockTab.card);
  vm.selectCardVariant(variantId);
}

class _ListTab extends StatelessWidget {
  const _ListTab({required this.viewModel, required this.narrow});

  final StockViewModel viewModel;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    if (vm.rows.isEmpty) {
      return FCard(
        key: const ValueKey('stock-empty'),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.stockEmpty,
            textAlign: TextAlign.center,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        ),
      );
    }
    final rows = vm.filteredRows;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        FTextField(
          key: const ValueKey('stock-search'),
          hint: l10n.stockSearchHint,
          prefixBuilder: (context, style, _) => Padding(
            padding: const EdgeInsetsDirectional.only(start: 12),
            child: Icon(
              TablerIcons.search,
              size: 18,
              color: theme.colors.mutedForeground,
            ),
          ),
          control: .managed(
            initial: TextEditingValue(text: vm.query),
            onChange: (v) => vm.setQuery(v.text),
          ),
        ),
        Text(
          l10n.stockValueTotal(formatMoney(context, vm.stockValue)),
          key: const ValueKey('stock-value-total'),
          style: theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              l10n.stockNoMatch,
              textAlign: TextAlign.center,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          )
        else if (narrow)
          for (final r in rows)
            _StockRowCard(row: r, onTap: () => _openCard(vm, r.variantId))
        else
          _Table(
            header: [
              (l10n.stockColProduct, 40, false),
              (l10n.stockColStock, 14, true),
              (l10n.stockColMinimum, 14, true),
              (l10n.stockColValue, 18, true),
            ],
            rows: [
              for (final r in rows)
                _StockTableRow(
                  row: r,
                  onTap: () => _openCard(vm, r.variantId),
                ),
            ],
          ),
      ],
    );
  }
}

/// Tabel dalam kartu bergaris: kepala ([label], flex, rata kanan) lalu
/// baris-baris.
class _Table extends StatelessWidget {
  const _Table({required this.header, required this.rows, this.trailing});

  final List<(String, int, bool)> header;
  final List<Widget> rows;

  /// Lebar kolom kosong di kanan (mis. tombol hapus baris).
  final double? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final style = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
      fontWeight: FontWeight.w600,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.card,
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.muted,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                spacing: 12,
                children: [
                  for (final (label, flex, end) in header)
                    Expanded(
                      flex: flex,
                      child: Text(
                        label,
                        style: style,
                        textAlign: end ? TextAlign.end : TextAlign.start,
                      ),
                    ),
                  if (trailing case final w?) SizedBox(width: w),
                ],
              ),
            ),
          ),
          for (var i = 0; i < rows.length; i++)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.colors.border)),
              ),
              child: rows[i],
            ),
        ],
      ),
    );
  }
}

class _StockTableRow extends StatelessWidget {
  const _StockTableRow({required this.row, required this.onTap});

  final StockRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final r = row;
    final body = theme.typography.body.sm.copyWith(fontFeatures: _tabular);
    final badge = _statusBadge(context, r);
    return FTappable(
      key: ValueKey('stock-row-${r.variantId.uuid}'),
      onPress: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              flex: 40,
              child: Row(
                spacing: 8,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: body.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          [?r.sku, r.baseUnit].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _muted(context),
                        ),
                      ],
                    ),
                  ),
                  ?badge,
                ],
              ),
            ),
            Expanded(
              flex: 14,
              child: Text(
                formatQty(context, r.stock),
                textAlign: TextAlign.end,
                style: body.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              flex: 14,
              child: Text(
                r.minStock.isPositive ? formatQty(context, r.minStock) : '—',
                textAlign: TextAlign.end,
                style: body,
              ),
            ),
            Expanded(
              flex: 18,
              child: Text(
                formatMoney(context, r.value),
                textAlign: TextAlign.end,
                style: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockRowCard extends StatelessWidget {
  const _StockRowCard({required this.row, required this.onTap});

  final StockRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final r = row;
    final badge = _statusBadge(context, r);
    return FTappable(
      key: ValueKey('stock-row-${r.variantId.uuid}'),
      onPress: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.card,
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      r.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      [
                        ?r.sku,
                        if (r.minStock.isPositive)
                          '${l10n.stockColMinimum} '
                              '${formatQty(context, r.minStock)}',
                        formatMoney(context, r.value),
                      ].join(' · '),
                      style: _muted(context),
                    ),
                    ?badge,
                  ],
                ),
              ),
              Text(
                '${formatQty(context, r.stock)} ${r.baseUnit}',
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: _tabular,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Tab Penyesuaian ---------------------------------------------------------

class _AdjustmentTab extends StatelessWidget {
  const _AdjustmentTab({
    required this.viewModel,
    required this.staffName,
    required this.timezone,
    required this.narrow,
    required this.sideBySide,
    this.onRestock,
  });

  final StockViewModel viewModel;
  final String staffName;
  final String? timezone;
  final bool narrow;
  final bool sideBySide;
  final ValueChanged<PurchaseRestock>? onRestock;

  @override
  Widget build(BuildContext context) {
    final card = _StockCardPanel(viewModel: viewModel, timezone: timezone);
    final minimum = _MinimumPanel(viewModel: viewModel, onRestock: onRestock);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        _AdjustmentCard(
          viewModel: viewModel,
          staffName: staffName,
          narrow: narrow,
        ),
        if (sideBySide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Expanded(flex: 3, child: card),
              Expanded(flex: 2, child: minimum),
            ],
          )
        else ...[
          card,
          minimum,
        ],
        _RecentPanel(viewModel: viewModel, timezone: timezone),
      ],
    );
  }
}

class _AdjustmentCard extends StatelessWidget {
  const _AdjustmentCard({
    required this.viewModel,
    required this.staffName,
    required this.narrow,
  });

  final StockViewModel viewModel;
  final String staffName;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final rev = vm.draftRevision;
    final meta = Text(
      l10n.stockAdjustmentMeta(vm.nextNumber ?? '—', staffName),
      key: const ValueKey('stock-adjustment-meta'),
      style: _muted(context),
    );
    if (!vm.canAdjust) {
      return SectionCard(
        title: l10n.stockAdjustmentNew,
        child: FAlert(
          key: const ValueKey('stock-no-permission'),
          title: Text(l10n.stockNoPermission),
        ),
      );
    }
    final reason = FSelect<StockAdjustmentReason>(
      key: ValueKey('stock-reason-$rev'),
      label: Text(l10n.stockReasonLabel),
      items: {
        for (final r in StockAdjustmentReason.values)
          stockReasonLabel(l10n, r): r,
      },
      control: .managed(
        initial: vm.reason,
        onChange: (r) {
          if (r != null) vm.setReason(r);
        },
      ),
    );
    final note = FTextField(
      key: ValueKey('stock-note-$rev'),
      enabled: !vm.save.running && !vm.draftLoading,
      label: Text(l10n.stockNoteLabel),
      hint: l10n.stockNoteHint,
      maxLength: StockLimits.note,
      control: .managed(
        initial: TextEditingValue(text: vm.note),
        onChange: (v) => vm.setNote(v.text),
      ),
    );
    final lines = vm.lines;
    return SectionCard(
      title: l10n.stockAdjustmentNew,
      trailing: narrow ? null : meta,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          if (narrow) meta,
          if (narrow) ...[
            reason,
            note,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                SizedBox(width: 220, child: reason),
                Expanded(child: note),
              ],
            ),
          if (lines.isEmpty)
            Text(
              l10n.stockLinesEmpty,
              key: const ValueKey('stock-lines-empty'),
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            )
          else if (narrow)
            for (final line in lines)
              _LineCard(viewModel: vm, line: line, revision: rev)
          else
            _Table(
              header: [
                (l10n.stockColProduct, _lineFlex.product, false),
                (l10n.stockColSystem, _lineFlex.system, true),
                (l10n.stockColPhysical, _lineFlex.physical, false),
                (l10n.stockColDifference, _lineFlex.diff, true),
                (l10n.stockColReason, _lineFlex.note, false),
                (l10n.stockColValue, _lineFlex.value, true),
              ],
              trailing: 32,
              rows: [
                for (final line in lines)
                  _LineRow(viewModel: vm, line: line, revision: rev),
              ],
            ),
          _AddProductField(viewModel: vm),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.stockTotal,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                formatMoney(context, vm.totalValue),
                key: const ValueKey('stock-total'),
                style: theme.typography.body.md.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: _tabular,
                  color: _diffColor(context, vm.totalValue.value.sign),
                ),
              ),
            ],
          ),
          if (vm.saveError != null || (vm.save.error && vm.lastSaved == null))
            FAlert(
              key: const ValueKey('stock-save-error'),
              variant: .destructive,
              title: Text(stockErrorMessage(l10n, vm.saveError)),
            )
          else if (vm.lastSaved case final number?)
            FAlert(
              key: const ValueKey('stock-saved'),
              icon: const Icon(TablerIcons.circleCheck),
              title: Text(l10n.stockSaved(number)),
            ),
          if (vm.hasDraftContent) _DraftStatus(failed: vm.draftWriteFailed),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              FButton(
                key: const ValueKey('stock-clear'),
                variant: .outline,
                mainAxisSize: .min,
                onPress: lines.isEmpty || vm.save.running
                    ? null
                    : vm.clearDraft,
                child: Flexible(child: Text(l10n.stockClear)),
              ),
              FButton(
                key: const ValueKey('stock-save'),
                mainAxisSize: .min,
                prefix: const Icon(TablerIcons.deviceFloppy),
                onPress: vm.canSave ? vm.save.execute : null,
                child: Flexible(child: Text(l10n.stockSave)),
              ),
            ],
          ),
          Text(l10n.stockPermissionNote, style: _muted(context)),
        ],
      ),
    );
  }
}

/// Keterangan draf tersimpan / gagal tersimpan di perangkat (F1-08o).
class _DraftStatus extends StatelessWidget {
  const _DraftStatus({required this.failed});

  final bool failed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.theme.colors;
    final color = failed ? colors.destructive : colors.mutedForeground;
    return Row(
      key: ValueKey(failed ? 'stock-draft-failed' : 'stock-draft-stored'),
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 6,
      children: [
        Icon(
          failed ? TablerIcons.alertTriangle : TablerIcons.deviceFloppy,
          size: 14,
          color: color,
        ),
        Flexible(
          child: Text(
            failed ? l10n.stockDraftFailed : l10n.stockDraftStored,
            style: context.theme.typography.body.xs.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

/// Lebar relatif kolom tabel penyesuaian (1.18).
const _lineFlex = (
  product: 26,
  system: 10,
  physical: 14,
  diff: 10,
  note: 22,
  value: 14,
);

/// Field jumlah fisik: kosong = belum dihitung (`null`).
class _PhysicalField extends StatelessWidget {
  const _PhysicalField({
    required this.viewModel,
    required this.line,
    required this.revision,
  });

  final StockViewModel viewModel;
  final AdjustmentDraftLine line;
  final int revision;

  @override
  Widget build(BuildContext context) {
    final id = line.row.variantId;
    final physical = line.physical;
    return FTextField(
      key: ValueKey('stock-physical-${id.uuid}-$revision'),
      // Isian selama menyimpan akan hilang saat draf dikosongkan.
      enabled: !viewModel.save.running && !viewModel.draftLoading,
      hint: AppLocalizations.of(context).stockColPhysical,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        QtyInputFormatter(decimal: qtyDecimalSeparator(context)),
      ],
      control: .managed(
        initial: TextEditingValue(
          text: physical == null
              ? ''
              : formatQty(context, physical, grouped: false),
        ),
        onChange: (v) {
          final text = v.text.trim();
          if (text.isEmpty) {
            viewModel.setPhysical(id, null);
          } else if (parseQtyInput(context, text) case final q?) {
            viewModel.setPhysical(id, q);
          }
        },
      ),
    );
  }
}

class _LineNoteField extends StatelessWidget {
  const _LineNoteField({
    required this.viewModel,
    required this.line,
    required this.revision,
  });

  final StockViewModel viewModel;
  final AdjustmentDraftLine line;
  final int revision;

  @override
  Widget build(BuildContext context) {
    final id = line.row.variantId;
    return FTextField(
      key: ValueKey('stock-line-note-${id.uuid}-$revision'),
      enabled: !viewModel.save.running && !viewModel.draftLoading,
      hint: AppLocalizations.of(context).stockLineNoteHint,
      maxLength: StockLimits.lineNote,
      control: .managed(
        initial: TextEditingValue(text: line.note),
        onChange: (v) => viewModel.setLineNote(id, v.text),
      ),
    );
  }
}

class _DiffText extends StatelessWidget {
  const _DiffText({required this.line});

  final AdjustmentDraftLine line;

  @override
  Widget build(BuildContext context) {
    final diff = line.difference;
    return Text(
      diff == null ? '—' : _signedQty(context, diff),
      key: ValueKey('stock-diff-${line.row.variantId.uuid}'),
      textAlign: TextAlign.end,
      style: context.theme.typography.body.sm.copyWith(
        fontWeight: FontWeight.w700,
        fontFeatures: _tabular,
        color: _diffColor(context, diff?.milli.sign ?? 0),
      ),
    );
  }
}

class _RemoveLineButton extends StatelessWidget {
  const _RemoveLineButton({required this.viewModel, required this.line});

  final StockViewModel viewModel;
  final AdjustmentDraftLine line;

  @override
  Widget build(BuildContext context) => FButton.icon(
    key: ValueKey('stock-remove-${line.row.variantId.uuid}'),
    variant: .ghost,
    size: .sm,
    semanticsLabel: AppLocalizations.of(context).stockRemoveLine,
    onPress: () => viewModel.removeLine(line.row.variantId),
    child: const Icon(TablerIcons.x, size: 16),
  );
}

class _LineRow extends StatelessWidget {
  const _LineRow({
    required this.viewModel,
    required this.line,
    required this.revision,
  });

  final StockViewModel viewModel;
  final AdjustmentDraftLine line;
  final int revision;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final r = line.row;
    final body = theme.typography.body.sm.copyWith(fontFeatures: _tabular);
    return Padding(
      key: ValueKey('stock-line-${r.variantId.uuid}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            flex: _lineFlex.product,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: body.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  [?r.sku, r.baseUnit].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _muted(context),
                ),
              ],
            ),
          ),
          Expanded(
            flex: _lineFlex.system,
            child: Text(
              formatQty(context, r.stock),
              textAlign: TextAlign.end,
              style: body,
            ),
          ),
          Expanded(
            flex: _lineFlex.physical,
            child: _PhysicalField(
              viewModel: viewModel,
              line: line,
              revision: revision,
            ),
          ),
          Expanded(
            flex: _lineFlex.diff,
            child: _DiffText(line: line),
          ),
          Expanded(
            flex: _lineFlex.note,
            child: _LineNoteField(
              viewModel: viewModel,
              line: line,
              revision: revision,
            ),
          ),
          Expanded(
            flex: _lineFlex.value,
            child: Text(
              formatMoney(context, line.value),
              textAlign: TextAlign.end,
              style: body.copyWith(
                color: _diffColor(context, line.value.value.sign),
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: _RemoveLineButton(viewModel: viewModel, line: line),
          ),
        ],
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({
    required this.viewModel,
    required this.line,
    required this.revision,
  });

  final StockViewModel viewModel;
  final AdjustmentDraftLine line;
  final int revision;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final r = line.row;
    return DecoratedBox(
      key: ValueKey('stock-line-${r.variantId.uuid}'),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.displayName,
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${l10n.stockColSystem} '
                        '${formatQty(context, r.stock)} ${r.baseUnit}',
                        style: _muted(context),
                      ),
                    ],
                  ),
                ),
                _RemoveLineButton(viewModel: viewModel, line: line),
              ],
            ),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: _PhysicalField(
                    viewModel: viewModel,
                    line: line,
                    revision: revision,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _DiffText(line: line),
                    Text(
                      formatMoney(context, line.value),
                      style: _muted(context).copyWith(fontFeatures: _tabular),
                    ),
                  ],
                ),
              ],
            ),
            _LineNoteField(
              viewModel: viewModel,
              line: line,
              revision: revision,
            ),
          ],
        ),
      ),
    );
  }
}

/// *+ Scan / tambah produk*: Enter menambah barcode/SKU persis atau nama
/// yang hanya cocok satu produk; saran nama tampil saat mengetik.
class _AddProductField extends StatefulWidget {
  const _AddProductField({required this.viewModel});

  final StockViewModel viewModel;

  @override
  State<_AddProductField> createState() => _AddProductFieldState();
}

class _AddProductFieldState extends State<_AddProductField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  var _query = '';
  String? _notFound;
  var _already = false;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _query = '';
      _notFound = null;
      _already = false;
    });
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;
    switch (widget.viewModel.addByCode(text)) {
      case AddByCodeResult.added:
        _clear();
      case AddByCodeResult.already:
        _clear();
        setState(() => _already = true);
      case AddByCodeResult.notFound:
        setState(() => _notFound = text.trim());
    }
    // Tetap fokus agar pemindai bisa langsung memindai barang berikutnya.
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final q = _query.trim().toLowerCase();
    final suggestions = q.isEmpty
        ? const <StockRow>[]
        : widget.viewModel.addableRows
              .where(
                (r) =>
                    r.displayName.toLowerCase().contains(q) ||
                    (r.sku?.toLowerCase().startsWith(q) ?? false) ||
                    (r.barcode?.startsWith(q) ?? false),
              )
              .take(6)
              .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        FTextField(
          key: const ValueKey('stock-add'),
          enabled:
              !widget.viewModel.save.running && !widget.viewModel.draftLoading,
          label: Text(l10n.stockAddLabel),
          hint: l10n.stockAddHint,
          focusNode: _focus,
          textInputAction: TextInputAction.done,
          prefixBuilder: (context, style, _) => Padding(
            padding: const EdgeInsetsDirectional.only(start: 12),
            child: Icon(
              TablerIcons.barcode,
              size: 18,
              color: theme.colors.mutedForeground,
            ),
          ),
          control: .managed(
            controller: _controller,
            onChange: (v) {
              if (v.text == _query) return;
              setState(() {
                _query = v.text;
                _notFound = null;
                _already = false;
              });
            },
          ),
          onSubmit: _submit,
        ),
        if (_already)
          Text(
            l10n.stockAddAlready,
            key: const ValueKey('stock-add-already'),
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        if (_notFound case final code?)
          Text(
            l10n.stockAddNotFound(code),
            key: const ValueKey('stock-add-not-found'),
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.destructive,
            ),
          ),
        if (suggestions.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in suggestions)
                ChoicePill(
                  key: ValueKey('stock-add-suggest-${r.variantId.uuid}'),
                  label: r.displayName,
                  selected: false,
                  onTap: () {
                    widget.viewModel.addLine(r.variantId);
                    _clear();
                  },
                ),
            ],
          ),
      ],
    );
  }
}

// --- Kartu stok --------------------------------------------------------------

class _StockCardPanel extends StatelessWidget {
  const _StockCardPanel({required this.viewModel, required this.timezone});

  final StockViewModel viewModel;
  final String? timezone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final card = vm.card;
    final row = vm.cardRow;
    return SectionCard(
      key: const ValueKey('stock-card'),
      title: l10n.stockCardTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (vm.cardFocusMissing)
            FAlert(
              key: const ValueKey('stock-card-focus-missing'),
              title: Text(l10n.stockCardFocusMissing),
            ),
          if (vm.rows.isEmpty)
            Text(l10n.stockEmpty, style: _muted(context))
          else
            FSelect<String>(
              key: ValueKey('stock-card-product-${vm.cardVariantId?.uuid}'),
              label: Text(l10n.stockCardProduct),
              items: {
                for (final MapEntry(:key, :value) in uniqueStockLabels(
                  vm.rows,
                ).entries)
                  value: key.uuid,
              },
              control: .managed(
                initial: vm.cardVariantId?.uuid,
                onChange: (id) {
                  if (id != null) {
                    vm.selectCardVariant(UuidValue.fromString(id));
                  }
                },
              ),
            ),
          if (card != null && row != null) ...[
            Text(
              card.minStock.isPositive
                  ? l10n.stockCardCurrent(
                      formatQty(context, card.current),
                      formatQty(context, card.minStock),
                    )
                  : l10n.stockCardCurrentNoMin(
                      formatQty(context, card.current),
                    ),
              key: const ValueKey('stock-card-current'),
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (card.entries.isEmpty)
              Text(l10n.stockCardEmpty, style: _muted(context))
            else ...[
              if (card.openingBalance != Qty.zero)
                Text(
                  l10n.stockCardOpening(
                    formatQty(context, card.openingBalance),
                  ),
                  style: _muted(context),
                ),
              LayoutBuilder(
                builder: (context, constraints) => constraints.maxWidth < 480
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: 8,
                        children: [
                          for (var i = 0; i < card.entries.length; i++)
                            _EntryTile(
                              key: ValueKey('stock-card-entry-$i'),
                              entry: card.entries[i],
                              timezone: timezone,
                            ),
                        ],
                      )
                    : _Table(
                        header: [
                          (l10n.stockColTime, 18, false),
                          (l10n.stockColDescription, 46, false),
                          (l10n.stockColInOut, 16, true),
                          (l10n.stockColBalance, 14, true),
                        ],
                        rows: [
                          for (var i = 0; i < card.entries.length; i++)
                            _EntryRow(
                              key: ValueKey('stock-card-entry-$i'),
                              entry: card.entries[i],
                              timezone: timezone,
                            ),
                        ],
                      ),
              ),
            ],
          ],
          Text(l10n.stockCardNote, style: _muted(context)),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({super.key, required this.entry, required this.timezone});

  final StockCardEntry entry;
  final String? timezone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final e = entry;
    final body = theme.typography.body.sm.copyWith(fontFeatures: _tabular);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            flex: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatDate(e.occurredAt, timezone), style: body),
                Text(
                  formatClock(e.occurredAt, timezone),
                  style: _muted(context),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 46,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_entryDescription(l10n, e), style: body),
                if (stockEntryNote(l10n, e.note) case final n?)
                  Text(n, style: _muted(context)),
              ],
            ),
          ),
          Expanded(
            flex: 16,
            child: Text(
              _signedQty(context, e.quantity),
              textAlign: TextAlign.end,
              style: body.copyWith(
                fontWeight: FontWeight.w700,
                color: _diffColor(context, e.quantity.milli.sign),
              ),
            ),
          ),
          Expanded(
            flex: 14,
            child: Text(
              formatQty(context, e.balance),
              textAlign: TextAlign.end,
              style: body,
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({super.key, required this.entry, required this.timezone});

  final StockCardEntry entry;
  final String? timezone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final e = entry;
    return Row(
      spacing: 12,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _entryDescription(l10n, e),
                style: theme.typography.body.sm,
              ),
              Text(
                [
                  _formatDateTime(e.occurredAt, timezone),
                  ?stockEntryNote(l10n, e.note),
                ].join(' · '),
                style: _muted(context),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _signedQty(context, e.quantity),
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: _tabular,
                color: _diffColor(context, e.quantity.milli.sign),
              ),
            ),
            Text(
              '${l10n.stockColBalance} ${formatQty(context, e.balance)}',
              style: _muted(context),
            ),
          ],
        ),
      ],
    );
  }
}

// --- Stok minimum ------------------------------------------------------------

/// *Cukup untuk saran* / *Kurang … dari saran* di bawah keterangan draf
/// stok minimum (F1-08p).
class _DraftCover extends StatelessWidget {
  const _DraftCover({required this.row, required this.mark});

  final StockRow row;
  final DraftMark mark;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final short = StockViewModel.shortfallOf(row, mark);
    final enough = short == Qty.zero;
    final color = enough
        ? _diffColor(context, 1)
        : context.theme.colors.mutedForeground;
    return Row(
      key: ValueKey('stock-min-cover-${row.variantId.uuid}'),
      spacing: 4,
      children: [
        if (enough) Icon(TablerIcons.circleCheck, size: 14, color: color),
        Flexible(
          child: Text(
            enough
                ? l10n.stockMinimumDraftEnough
                : l10n.stockMinimumDraftShort(
                    formatQty(context, short),
                    row.baseUnit,
                  ),
            style: context.theme.typography.body.xs.copyWith(
              color: color,
              fontWeight: enough ? FontWeight.w600 : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _MinimumPanel extends StatelessWidget {
  const _MinimumPanel({required this.viewModel, this.onRestock});

  final StockViewModel viewModel;
  final ValueChanged<PurchaseRestock>? onRestock;

  /// *Sudah di draf …: dipesan dari saran …* (F1-08h/F1-08l). Saran sama
  /// dengan jumlah yang diisi *Buat pembelian* (F1-08c).
  static String _inDraftText(
    BuildContext context,
    AppLocalizations l10n,
    StockRow r,
    DraftMark m,
  ) {
    final ordered = formatQty(context, m.ordered);
    final suggested = formatQty(context, StockViewModel.suggestedOf(r));
    return m.drafts > 1
        ? l10n.stockMinimumInDraftsQty(
            m.drafts,
            m.number,
            ordered,
            suggested,
            r.baseUnit,
          )
        : l10n.stockMinimumInDraftQty(
            m.number,
            ordered,
            suggested,
            r.baseUnit,
          );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final below = vm.below;
    return SectionCard(
      key: const ValueKey('stock-minimum'),
      title: l10n.stockMinimumTitle,
      trailing: Text(
        l10n.stockMinimumCount(below.length),
        style: _muted(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          if (below.isEmpty)
            Text(l10n.stockMinimumEmpty, style: _muted(context))
          else
            for (final r in below)
              FTappable(
                key: ValueKey('stock-min-${r.variantId.uuid}'),
                onPress: () => _openCard(vm, r.variantId),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              [?r.sku, r.baseUnit].join(' · '),
                              style: _muted(context),
                            ),
                            if (vm.draftMarkOf(r.variantId) case final m?) ...[
                              Text(
                                _inDraftText(context, l10n, r, m),
                                key: ValueKey(
                                  'stock-min-draft-${r.variantId.uuid}',
                                ),
                                // Nomor draf dibungkus utuh (tanpa elipsis)
                                // agar draf tetap bisa dibedakan di ponsel.
                                style: theme.typography.body.xs.copyWith(
                                  // Biru muda di tema gelap (kontras 4.5:1,
                                  // spec F0).
                                  color: theme.colors.brightness == .dark
                                      ? const Color(0xFF74D4FF)
                                      : theme.colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              _DraftCover(row: r, mark: m),
                            ],
                          ],
                        ),
                      ),
                      StockPill(
                        text:
                            '${formatQty(context, r.stock)} / '
                            '${formatQty(context, r.minStock)}',
                        low: true,
                      ),
                    ],
                  ),
                ),
              ),
          if (onRestock case final open? when below.isNotEmpty)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FButton(
                key: const ValueKey('stock-restock'),
                variant: .outline,
                mainAxisSize: .min,
                onPress: switch (vm.restock) {
                  final r? => () => open(r),
                  null => null,
                },
                prefix: const Icon(TablerIcons.shoppingCartPlus),
                child: Flexible(child: Text(l10n.stockRestock)),
              ),
            ),
        ],
      ),
    );
  }
}

// --- Penyesuaian terakhir ----------------------------------------------------

class _RecentPanel extends StatelessWidget {
  const _RecentPanel({required this.viewModel, required this.timezone});

  final StockViewModel viewModel;
  final String? timezone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final recent = viewModel.recent;
    return SectionCard(
      title: l10n.stockRecentTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          if (recent.isEmpty)
            Text(l10n.stockRecentEmpty, style: _muted(context))
          else
            for (var i = 0; i < recent.length; i++)
              Row(
                key: ValueKey('stock-recent-$i'),
                spacing: 12,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recent[i].number,
                          style: theme.typography.body.sm.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          [
                            _formatDateTime(recent[i].adjustedAt, timezone),
                            l10n.stockRecentMeta(
                              stockReasonLabel(l10n, recent[i].reason),
                              recent[i].itemCount,
                              recent[i].staffName,
                            ),
                            recent[i].locationName,
                          ].join(' · '),
                          style: _muted(context),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatMoney(context, recent[i].totalValue),
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: _tabular,
                      color: _diffColor(
                        context,
                        recent[i].totalValue.value.sign,
                      ),
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}

// --- Lokasi stok -------------------------------------------------------------

class _LocationsTab extends StatefulWidget {
  const _LocationsTab({required this.viewModel});

  final StockViewModel viewModel;

  @override
  State<_LocationsTab> createState() => _LocationsTabState();
}

class _LocationsTabState extends State<_LocationsTab> {
  final _newName = TextEditingController();
  UuidValue? _editing;
  var _editName = '';
  var _busy = false;

  @override
  void dispose() {
    _newName.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await widget.viewModel.addLocation(_newName.text);
    if (!mounted) return;
    if (ok) _newName.clear();
    setState(() => _busy = false);
  }

  Future<void> _rename(UuidValue id) async {
    if (_busy) return;
    setState(() => _busy = true);
    final ok = await widget.viewModel.renameLocation(id, _editName);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (ok) _editing = null;
    });
  }

  void _startEdit(StockLocation l) {
    widget.viewModel.clearLocationError();
    setState(() {
      _editing = l.id;
      _editName = l.name;
    });
  }

  void _cancelEdit() {
    widget.viewModel.clearLocationError();
    setState(() => _editing = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = widget.viewModel;
    final error = vm.locationError;
    Widget errorText() => Text(
      _locationErrorMessage(l10n, error!),
      key: const ValueKey('stock-location-error'),
      style: theme.typography.body.xs.copyWith(
        color: theme.colors.destructive,
      ),
    );
    return SectionCard(
      title: l10n.stockTabLocations,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(l10n.stockLocationsHint, style: _muted(context)),
          for (final l in vm.locations)
            if (_editing == l.id)
              Column(
                key: ValueKey('stock-location-${l.id.uuid}'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  FTextField(
                    key: ValueKey('stock-location-edit-${l.id.uuid}'),
                    label: Text(l10n.stockLocationNameLabel),
                    maxLength: StockLimits.locationName,
                    autofocus: true,
                    control: .managed(
                      initial: TextEditingValue(text: l.name),
                      onChange: (v) => _editName = v.text,
                    ),
                    onSubmit: (_) => _rename(l.id),
                  ),
                  if (error != null) errorText(),
                  Wrap(
                    spacing: 8,
                    children: [
                      FButton(
                        key: ValueKey('stock-location-save-${l.id.uuid}'),
                        mainAxisSize: .min,
                        onPress: _busy ? null : () => _rename(l.id),
                        child: Flexible(child: Text(l10n.stockLocationSave)),
                      ),
                      FButton(
                        variant: .outline,
                        mainAxisSize: .min,
                        onPress: _busy ? null : _cancelEdit,
                        child: Flexible(child: Text(l10n.stockLocationCancel)),
                      ),
                    ],
                  ),
                ],
              )
            else
              Row(
                key: ValueKey('stock-location-${l.id.uuid}'),
                spacing: 8,
                children: [
                  Icon(
                    TablerIcons.buildingWarehouse,
                    size: 18,
                    color: theme.colors.mutedForeground,
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l.name,
                          style: theme.typography.body.sm.copyWith(
                            fontWeight: vm.location?.id == l.id
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        if (l.isDefault)
                          FBadge(
                            variant: .secondary,
                            child: Text(l10n.stockLocationDefault),
                          ),
                      ],
                    ),
                  ),
                  if (vm.canAdjust)
                    FButton.icon(
                      key: ValueKey('stock-location-rename-${l.id.uuid}'),
                      variant: .ghost,
                      size: .sm,
                      semanticsLabel: l10n.stockLocationRename,
                      onPress: _busy ? null : () => _startEdit(l),
                      child: const Icon(TablerIcons.pencil, size: 16),
                    ),
                ],
              ),
          if (vm.canAdjust && _editing == null) ...[
            FTextField(
              key: const ValueKey('stock-location-new'),
              label: Text(l10n.stockLocationNameLabel),
              maxLength: StockLimits.locationName,
              control: .managed(controller: _newName),
              onSubmit: (_) => _add(),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FButton(
                key: const ValueKey('stock-location-add'),
                mainAxisSize: .min,
                prefix: const Icon(TablerIcons.plus),
                onPress: _busy ? null : _add,
                child: Flexible(child: Text(l10n.stockLocationAdd)),
              ),
            ),
            if (error != null) errorText(),
          ],
        ],
      ),
    );
  }
}

/// Pilihan saat draf pembelian berisi barang yang sama sudah ada (F1-08g).
enum _DraftChoice { open, create }
