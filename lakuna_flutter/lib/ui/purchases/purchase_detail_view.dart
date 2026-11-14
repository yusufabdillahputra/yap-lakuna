import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/purchases_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/format.dart';
import '../core/photo_viewer.dart';
import '../products/product_widgets.dart';
import 'purchase_detail_view_model.dart';
import 'purchase_form_view.dart';
import 'purchase_form_view_model.dart';
import 'purchase_labels.dart';

const _tabular = [FontFeature.tabularFigures()];

/// Lebar minimum untuk tabel barang dan tiga kartu bawah berdampingan.
const purchaseDetailWideWidth = 860.0;

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

/// Kepala halaman pembelian: breadcrumb, judul, dan tombol *Kembali*.
class _PageTop extends StatelessWidget {
  const _PageTop({
    required this.title,
    this.subtitle,
    this.badge,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Widget? badge;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text('${l10n.purchasesTitle} › $title', style: _muted(context)),
        PageHeader(
          title: title,
          subtitle: subtitle,
          action: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ?badge,
              if (onBack != null)
                FButton(
                  key: const ValueKey('purchase-back'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: onBack,
                  prefix: const Icon(TablerIcons.chevronLeft),
                  child: Flexible(child: Text(l10n.buttonBack)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Halaman form pembelian (`/pembelian/baru`, atau draf di layar sempit).
class PurchaseFormPage extends StatefulWidget {
  const PurchaseFormPage({
    super.key,
    required this.repository,
    this.draftId,
    this.restock,
    required this.onReceived,
    required this.onBack,
    this.imagePicker = const FileSelectorImagePicker(),
  });

  final PurchasesRepository repository;
  final UuidValue? draftId;

  /// Foto faktur (F1-12b).
  final ImageFilePicker imagePicker;

  /// Isian dari daftar stok minimum (F1-08c).
  final PurchaseRestock? restock;
  final ValueChanged<Purchase> onReceived;
  final VoidCallback onBack;

  @override
  State<PurchaseFormPage> createState() => _PurchaseFormPageState();
}

class _PurchaseFormPageState extends State<PurchaseFormPage> {
  late final _form = PurchaseFormViewModel(
    repository: widget.repository,
    draftId: widget.draftId,
    restock: widget.restock,
    picker: widget.imagePicker,
  )..load.execute();

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const ValueKey('purchase-form-page'),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        ListenableBuilder(
          listenable: _form,
          builder: (context, _) => _PageTop(
            title: _form.number.isEmpty
                ? AppLocalizations.of(context).purchasesNew
                : _form.number,
            onBack: widget.onBack,
          ),
        ),
        ListenableBuilder(
          listenable: _form,
          builder: (context, _) {
            final l10n = AppLocalizations.of(context);
            final location = _form.restockLocationName;
            if (location == null) return const SizedBox.shrink();
            return FAlert(
              key: const ValueKey('purchase-restock-note'),
              title: Text(
                l10n.purchaseRestockNote(location, _form.restockApplied),
              ),
              subtitle: _form.restockSkipped > 0
                  ? Text(l10n.purchaseRestockSkipped(_form.restockSkipped))
                  : null,
            );
          },
        ),
        PurchaseFormPanel(
          viewModel: _form,
          onReceived: widget.onReceived,
          onDeleted: widget.onBack,
        ),
      ],
    ),
  );
}

/// Halaman `/pembelian/:id`: detail pembelian yang sudah diterima (1.19b),
/// atau form draf.
class PurchaseDetailScreen extends StatefulWidget {
  const PurchaseDetailScreen({
    super.key,
    required this.repository,
    required this.purchaseId,
    required this.onBack,
    this.onPayDebt,
    this.imagePicker = const FileSelectorImagePicker(),
  });

  final PurchasesRepository repository;
  final UuidValue purchaseId;

  /// Foto faktur (F1-12b).
  final ImageFilePicker imagePicker;
  final VoidCallback onBack;

  /// Membuka panel bayar hutang supplier (F1-14); `null` = tanpa izin.
  final Future<void> Function(UuidValue supplierId)? onPayDebt;

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  late final _vm = PurchaseDetailViewModel(
    repository: widget.repository,
    purchaseId: widget.purchaseId,
    picker: widget.imagePicker,
  )..load.execute();

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _vm,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final detail = _vm.detail;
      if (detail == null) {
        if (_vm.error case final error?) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                LoadFailedAlert(
                  key: const ValueKey('purchase-detail-error'),
                  message: error is PurchaseNotFound
                      ? l10n.purchaseErrNotFound
                      : l10n.purchaseDetailLoadFailed,
                  onRetry: _vm.load.execute,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FButton(
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: widget.onBack,
                    child: Text(l10n.buttonBack),
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(child: FCircularProgress());
      }
      if (detail.isDraft) {
        return PurchaseFormPage(
          repository: widget.repository,
          draftId: widget.purchaseId,
          onReceived: (_) => _vm.load.execute(),
          onBack: widget.onBack,
          imagePicker: widget.imagePicker,
        );
      }
      final pay = widget.onPayDebt;
      return PurchaseDetailView(
        viewModel: _vm,
        onBack: widget.onBack,
        onPayDebt: pay == null
            ? null
            : (id) async {
                await pay(id);
                if (mounted) await _vm.load.execute();
              },
      );
    },
  );
}

/// Detail pembelian yang sudah diterima (1.19b).
class PurchaseDetailView extends StatelessWidget {
  const PurchaseDetailView({
    super.key,
    required this.viewModel,
    this.onBack,
    this.onPayDebt,
  });

  final PurchaseDetailViewModel viewModel;
  final VoidCallback? onBack;
  final Future<void> Function(UuidValue supplierId)? onPayDebt;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final l10n = AppLocalizations.of(context);
      final vm = viewModel;
      final d = vm.detail!;
      final p = d.purchase;
      final wide = constraints.maxWidth >= purchaseDetailWideWidth;
      final debt = d.debt;
      final cards = [
        _SummaryCard(viewModel: vm),
        _PaymentsCard(viewModel: vm, onPayDebt: onPayDebt),
        _ActionsCard(viewModel: vm),
      ];
      return SingleChildScrollView(
        key: const ValueKey('purchase-detail'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            _PageTop(
              title: p.number,
              subtitle: l10n.purchaseFrom(
                d.supplier?.name ?? l10n.purchasesNoSupplier,
              ),
              badge: FBadge(
                key: const ValueKey('purchase-status'),
                variant: debt.value > 0 ? .destructive : .secondary,
                child: Text(
                  debt.value > 0
                      ? l10n.purchaseBadgeDebt
                      : l10n.purchaseBadgePaid,
                ),
              ),
              onBack: onBack,
            ),
            _InfoCard(detail: d),
            _InvoicePhotoCard(viewModel: vm),
            _ItemsCard(viewModel: vm, wide: wide),
            if (vm.returning) _ReturnCard(viewModel: vm, wide: wide),
            if (wide)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    Expanded(flex: 4, child: cards[0]),
                    Expanded(flex: 5, child: cards[1]),
                    Expanded(flex: 3, child: cards[2]),
                  ],
                ),
              )
            else
              ...cards,
          ],
        ),
      );
    },
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.detail});

  final PurchaseDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final p = detail.purchase;
    Widget pair(String label, String value) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(label, style: _muted(context)),
        Text(
          value,
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
    return FCard(
      key: const ValueKey('purchase-info'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 32,
          runSpacing: 16,
          children: [
            pair(
              l10n.purchaseSupplier,
              detail.supplier?.name ?? l10n.purchasesNoSupplier,
            ),
            pair(l10n.purchaseInvoiceNo, p.invoiceNo ?? '-'),
            pair(l10n.purchaseDate, formatCalendarDate(p.purchasedOn)),
            pair(l10n.purchaseLocation, detail.locationName),
            pair(
              l10n.purchaseCreatedBy,
              '${detail.staffName} · ${detail.deviceCode}',
            ),
          ],
        ),
      ),
    );
  }
}

/// Foto faktur pembelian yang sudah diterima (F1-12b): lihat, lampirkan,
/// ganti, atau hapus.
class _InvoicePhotoCard extends StatelessWidget {
  const _InvoicePhotoCard({required this.viewModel});

  final PurchaseDetailViewModel viewModel;

  Future<void> _remove(BuildContext context) async {
    final ok = await showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
        builder: (context, style) {
          final l10n = AppLocalizations.of(context);
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              key: const ValueKey('purchase-invoice-photo-confirm'),
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                Text(
                  l10n.purchaseInvoicePhotoRemoveTitle,
                  style: context.theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.purchaseInvoicePhotoRemoveBody,
                  style: _muted(context),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    FButton(
                      key: const ValueKey('purchase-invoice-photo-cancel'),
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: () => Navigator.of(context).pop(false),
                      child: Text(l10n.purchaseInvoicePhotoCancel),
                    ),
                    FButton(
                      key: const ValueKey(
                        'purchase-invoice-photo-confirm-remove',
                      ),
                      variant: .destructive,
                      mainAxisSize: .min,
                      onPress: () => Navigator.of(context).pop(true),
                      child: Text(l10n.purchaseInvoicePhotoRemove),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    if (ok ?? false) await viewModel.removeInvoicePhoto.execute();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final has = vm.detail!.hasInvoicePhoto;
    final bytes = vm.invoicePhoto;
    final busy = vm.photoBusy;
    void view() => showPhotoViewer(
      context,
      bytes: bytes!,
      keyPrefix: 'purchase-invoice-photo',
      closeLabel: l10n.purchaseInvoicePhotoClose,
    );
    Widget button(
      String key,
      IconData icon,
      String label,
      VoidCallback onPress, {
      FButtonVariant variant = .outline,
    }) => FButton(
      key: ValueKey(key),
      variant: variant,
      size: .sm,
      mainAxisSize: .min,
      onPress: busy ? null : onPress,
      prefix: Icon(icon),
      child: Flexible(
        child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
    final error = vm.invoicePhotoRejected
        ? l10n.purchaseInvoicePhotoInvalid
        : vm.attachInvoicePhoto.error || vm.removeInvoicePhoto.error
        ? l10n.purchaseInvoicePhotoFailed
        : null;
    return FCard(
      key: const ValueKey('purchase-invoice-photo-card'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            if (bytes != null)
              FTappable(
                key: const ValueKey('purchase-invoice-photo-thumb'),
                semanticsLabel: l10n.purchaseInvoicePhotoView,
                onPress: view,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.memory(
                    bytes,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    cacheWidth: 216,
                  ),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Text(l10n.purchaseInvoicePhoto, style: _muted(context)),
                  if (bytes == null)
                    Text(
                      has
                          ? l10n.purchaseInvoicePhotoMissing
                          : l10n.purchaseInvoicePhotoNone,
                      key: const ValueKey('purchase-invoice-photo-status'),
                      style: context.theme.typography.body.sm,
                    ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (bytes != null)
                        button(
                          'purchase-invoice-photo-view',
                          TablerIcons.photoSearch,
                          l10n.purchaseInvoicePhotoView,
                          view,
                          variant: .primary,
                        ),
                      button(
                        'purchase-invoice-photo-pick',
                        TablerIcons.photo,
                        has
                            ? l10n.purchaseInvoicePhotoReplace
                            : l10n.purchaseInvoicePhotoPick,
                        () => vm.attachInvoicePhoto.execute(false),
                      ),
                      if (vm.canTakePhoto)
                        button(
                          'purchase-invoice-photo-camera',
                          TablerIcons.camera,
                          l10n.purchaseInvoicePhotoCamera,
                          () => vm.attachInvoicePhoto.execute(true),
                        ),
                      if (has)
                        button(
                          'purchase-invoice-photo-remove',
                          TablerIcons.trash,
                          l10n.purchaseInvoicePhotoRemove,
                          () => _remove(context),
                          variant: .ghost,
                        ),
                    ],
                  ),
                  if (error != null)
                    Text(
                      error,
                      key: const ValueKey('purchase-invoice-photo-error'),
                      style: context.theme.typography.body.xs.copyWith(
                        color: context.theme.colors.destructive,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _qtyUnit(BuildContext context, PurchaseItem item, int milli) =>
    '${formatQty(context, Qty(milli))} ${item.unitName}';

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.viewModel, required this.wide});

  final PurchaseDetailViewModel viewModel;
  final bool wide;

  static const _cols = [24, 10, 12, 13, 19, 11, 17, 8];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final d = vm.detail!;
    final count = vm.checked.length;
    final body = theme.typography.body.sm.copyWith(fontFeatures: _tabular);
    Widget productCell(PurchaseItem item) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.variantName.isEmpty
              ? item.productName
              : '${item.productName} ${item.variantName}',
          style: body.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          [
            ?d.skus[item.variantId],
            item.factorMilli == 1000
                ? item.unitName
                : '${item.unitName} (${formatQty(context, Qty(item.factorMilli))} '
                      '${d.baseUnits[item.variantId] ?? ''})',
          ].join(' · '),
          style: _muted(context),
        ),
      ],
    );
    Widget avgCell(PurchaseItem item) {
      final before = item.avgCostBefore;
      final after = item.avgCostAfter;
      if (before == null || after == null) return Text('-', style: body);
      final unit = d.baseUnits[item.variantId];
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${formatMoney(context, Money(before))} → '),
            TextSpan(
              text: formatMoney(context, Money(after)),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            if (item.factorMilli != 1000 && unit != null)
              TextSpan(text: '/$unit'),
          ],
        ),
        style: body,
      );
    }

    Widget suggestCell(PriceSuggestion? s) {
      if (s == null) return Text('-', style: body);
      return Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(formatMoney(context, s.suggested), style: body),
          FBadge(
            variant: s.below ? .destructive : .secondary,
            child: Text(
              s.below ? l10n.purchaseBelowSuggested : l10n.purchaseSafe,
            ),
          ),
        ],
      );
    }

    Widget check(PriceSuggestion? s) => s == null || !vm.canEditPrices
        ? const SizedBox()
        : FCheckbox(
            key: ValueKey('purchase-change-price-${s.item.id.uuid}'),
            semanticsLabel: l10n.purchaseColChangePrice,
            value: vm.checked.contains(s.item.variantId),
            onChange: (v) => vm.toggle(s.item.variantId, v),
          );

    final Widget table;
    if (wide) {
      final head = theme.typography.body.xs.copyWith(
        color: theme.colors.mutedForeground,
        fontWeight: FontWeight.w600,
      );
      final labels = [
        l10n.purchaseColProduct,
        l10n.purchaseColQty,
        l10n.purchaseColPrice,
        l10n.purchaseColSubtotal,
        l10n.purchaseColAvgCost,
        l10n.purchaseColSellPrice,
        l10n.purchaseColSuggested,
        l10n.purchaseColChangePrice,
      ];
      Widget cell(int i, Widget child) =>
          Expanded(flex: _cols[i], child: child);
      table = DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                spacing: 8,
                children: [
                  for (var i = 0; i < labels.length; i++)
                    cell(
                      i,
                      Text(
                        labels[i],
                        style: head,
                        textAlign: i >= 1 && i <= 3
                            ? TextAlign.end
                            : TextAlign.start,
                      ),
                    ),
                ],
              ),
            ),
            for (final item in d.items)
              DecoratedBox(
                key: ValueKey('purchase-item-${item.id.uuid}'),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: theme.colors.border)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      cell(0, productCell(item)),
                      cell(
                        1,
                        Text(
                          _qtyUnit(context, item, item.quantityMilli),
                          textAlign: TextAlign.end,
                          style: body,
                        ),
                      ),
                      cell(
                        2,
                        Text(
                          formatMoney(context, Money(item.unitPrice)),
                          textAlign: TextAlign.end,
                          style: body,
                        ),
                      ),
                      cell(
                        3,
                        Text(
                          formatMoney(context, Money(item.lineTotal)),
                          textAlign: TextAlign.end,
                          style: body,
                        ),
                      ),
                      cell(4, avgCell(item)),
                      cell(
                        5,
                        Text(
                          formatMoney(
                            context,
                            d.sellPrices[item.variantId] ?? Money.zero,
                          ),
                          style: body,
                        ),
                      ),
                      cell(6, suggestCell(vm.suggestionFor(item))),
                      cell(
                        7,
                        Align(
                          alignment: Alignment.centerLeft,
                          child: check(vm.suggestionFor(item)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      Widget line(String label, Widget value) => Row(
        spacing: 8,
        children: [
          Expanded(child: Text(label, style: _muted(context))),
          Flexible(child: value),
        ],
      );
      table = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          for (final item in d.items)
            DecoratedBox(
              key: ValueKey('purchase-item-${item.id.uuid}'),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 6,
                  children: [
                    Row(
                      children: [
                        Expanded(child: productCell(item)),
                        check(vm.suggestionFor(item)),
                      ],
                    ),
                    line(
                      '${l10n.purchaseColQty} × ${l10n.purchaseColPrice}',
                      Text(
                        '${_qtyUnit(context, item, item.quantityMilli)} × '
                        '${formatMoney(context, Money(item.unitPrice))}',
                        textAlign: TextAlign.end,
                        style: body,
                      ),
                    ),
                    line(
                      l10n.purchaseColSubtotal,
                      Text(
                        formatMoney(context, Money(item.lineTotal)),
                        style: body,
                      ),
                    ),
                    line(l10n.purchaseColAvgCost, avgCell(item)),
                    line(
                      l10n.purchaseColSellPrice,
                      Text(
                        formatMoney(
                          context,
                          d.sellPrices[item.variantId] ?? Money.zero,
                        ),
                        style: body,
                      ),
                    ),
                    line(
                      l10n.purchaseColSuggested,
                      suggestCell(vm.suggestionFor(item)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }
    return FCard(
      key: const ValueKey('purchase-items'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              l10n.purchaseReceivedTitle,
              style: theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              l10n.purchaseReceivedSubtitle(d.locationName),
              style: _muted(context),
            ),
            table,
            Text(l10n.purchaseAvgCostNote, style: _muted(context)),
            if (vm.applyPrices.completed)
              FAlert(
                key: const ValueKey('purchase-prices-applied'),
                title: Text(l10n.purchasePricesApplied),
              )
            else if (vm.applyPrices.result case Error(:final error))
              FAlert(
                variant: .destructive,
                title: Text(purchaseErrorMessage(l10n, error)),
              ),
            if (vm.canEditPrices)
              Align(
                alignment: Alignment.centerLeft,
                child: FButton(
                  key: const ValueKey('purchase-apply-prices'),
                  mainAxisSize: .min,
                  onPress: count == 0 || vm.applyPrices.running
                      ? null
                      : vm.applyPrices.execute,
                  prefix: const Icon(TablerIcons.check),
                  child: Flexible(child: Text(l10n.purchaseApplyPrices(count))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Widget _card(BuildContext context, String key, String title, Widget child) =>
    FCard(
      key: ValueKey(key),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              title,
              style: context.theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            child,
          ],
        ),
      ),
    );

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.viewModel});

  final PurchaseDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final d = viewModel.detail!;
    final p = d.purchase;
    final body = theme.typography.body.sm;
    Widget row(String label, Money value, {bool strong = false, Key? key}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: strong
                      ? body.copyWith(fontWeight: FontWeight.w700)
                      : body.copyWith(color: theme.colors.mutedForeground),
                ),
              ),
              Text(
                formatMoney(context, value),
                key: key,
                style: body.copyWith(
                  fontWeight: strong ? FontWeight.w700 : FontWeight.w600,
                  fontFeatures: _tabular,
                ),
              ),
            ],
          ),
        );
    final due = p.dueOn;
    final days = viewModel.dueInDays;
    return _card(
      context,
      'purchase-summary',
      l10n.purchaseSummary,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(l10n.purchaseSubtotal, Money(p.subtotal)),
          row(l10n.purchaseDiscount, Money(p.discount)),
          row(l10n.purchaseShipping, Money(p.shipping)),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 6),
            color: theme.colors.border,
          ),
          row(l10n.purchaseTotal, Money(p.total), strong: true),
          row(l10n.purchasePaidSoFar, Money(p.paidAmount)),
          if (d.returns.isNotEmpty)
            row(l10n.purchaseReturned, d.returnedAmount),
          row(
            l10n.purchaseDebt,
            d.debt,
            strong: true,
            key: const ValueKey('purchase-debt-left'),
          ),
          if (due != null && days != null) ...[
            const SizedBox(height: 8),
            DecoratedBox(
              key: const ValueKey('purchase-due'),
              decoration: BoxDecoration(
                color: theme.colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Icon(
                      TablerIcons.calendarDue,
                      size: 18,
                      color: days < 0
                          ? theme.colors.destructive
                          : theme.colors.primary,
                    ),
                    Expanded(
                      child: Text(
                        days > 0
                            ? l10n.purchaseDueIn(formatCalendarDate(due), days)
                            : days == 0
                            ? l10n.purchaseDueToday(formatCalendarDate(due))
                            : l10n.purchaseOverdue(
                                formatCalendarDate(due),
                                -days,
                              ),
                        style: body.copyWith(
                          color: days < 0
                              ? theme.colors.destructive
                              : theme.colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentsCard extends StatelessWidget {
  const _PaymentsCard({required this.viewModel, this.onPayDebt});

  final PurchaseDetailViewModel viewModel;
  final Future<void> Function(UuidValue supplierId)? onPayDebt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final d = viewModel.detail!;
    final p = d.purchase;
    final tz = viewModel.timezone;
    final body = theme.typography.body.sm.copyWith(fontFeatures: _tabular);
    final rows = <(String, String, String, Money)>[
      if (p.paidAmount > 0)
        (
          formatCalendarDayMonth(p.purchasedOn),
          l10n.purchaseDownPayment,
          p.fundingSource == null
              ? '-'
              : fundingLabel(l10n, fundingKind(p.fundingSource!)),
          Money(p.paidAmount),
        ),
      for (final l in d.debtPayments)
        (
          formatCalendarDayMonth(l.paidOn),
          l10n.purchaseDebtPayment(l.number),
          l.funding == null ? '-' : fundingLabel(l10n, fundingKind(l.funding!)),
          l.amount,
        ),
      for (final r in d.returns) ...[
        if (r.debtReduction > 0)
          (
            formatDayMonth(r.returnedAt, tz),
            l10n.purchaseReturnReduction(r.number),
            '',
            Money(r.debtReduction),
          ),
        if (r.refundAmount > 0)
          (
            formatDayMonth(r.returnedAt, tz),
            l10n.purchaseReturnRefund(r.number),
            r.refundSource == null
                ? '-'
                : fundingLabel(l10n, fundingKind(r.refundSource!)),
            Money(r.refundAmount),
          ),
      ],
    ];
    return _card(
      context,
      'purchase-payments',
      l10n.purchasePayments,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (rows.isEmpty)
            Text(l10n.purchaseNoPayments, style: _muted(context))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (date, desc, from, amount) in rows)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        SizedBox(width: 44, child: Text(date, style: body)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(desc, style: body),
                              if (from.isNotEmpty)
                                Text(from, style: _muted(context)),
                            ],
                          ),
                        ),
                        Text(formatMoney(context, amount), style: body),
                      ],
                    ),
                  ),
              ],
            ),
          if (d.debt > Money.zero && p.supplierId != null && onPayDebt != null)
            FButton(
              key: const ValueKey('purchase-pay-debt'),
              onPress: () => onPayDebt!(p.supplierId!),
              prefix: const Icon(TablerIcons.cash),
              child: Flexible(child: Text(l10n.purchasePayDebt)),
            ),
        ],
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({required this.viewModel});

  final PurchaseDetailViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final d = vm.detail!;
    final canReturn = d.items.any((i) => d.remainingMilli(i) > 0);
    return _card(
      context,
      'purchase-actions',
      l10n.purchaseActions,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          FButton(
            key: const ValueKey('purchase-return-open'),
            variant: .outline,
            onPress: !canReturn || vm.returning ? null : vm.openReturn,
            prefix: const Icon(TablerIcons.arrowBackUp),
            child: Flexible(child: Text(l10n.purchaseReturnAction)),
          ),
          Text(l10n.purchaseReturnActionNote, style: _muted(context)),
          if (vm.submitReturn.result case Ok(:final value))
            FAlert(
              key: const ValueKey('purchase-return-done'),
              title: Text(l10n.purchaseReturnDone(value.number)),
            ),
          if (d.returns.isNotEmpty) ...[
            Text(
              l10n.purchaseReturnsMade,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            for (final r in d.returns)
              Row(
                key: ValueKey('purchase-return-${r.id.uuid}'),
                spacing: 8,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.number, style: theme.typography.body.xs),
                        Text(
                          formatDayClock(r.returnedAt, vm.timezone),
                          style: _muted(context),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '− ${formatMoney(context, Money(r.amount))}',
                    style: theme.typography.body.xs.copyWith(
                      fontFeatures: _tabular,
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}

class _ReturnCard extends StatelessWidget {
  const _ReturnCard({required this.viewModel, required this.wide});

  final PurchaseDetailViewModel viewModel;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final d = vm.detail!;
    final gen = vm.formGeneration;
    final issues = vm.returnIssues;
    final split = vm.returnSplit;
    final error = vm.returnError;
    return FCard(
      key: const ValueKey('purchase-return-form'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              l10n.purchaseReturnTitle,
              style: theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            for (final item in d.items)
              if (d.remainingMilli(item) > 0)
                Row(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.variantName.isEmpty
                                ? item.productName
                                : '${item.productName} ${item.variantName}',
                            style: theme.typography.body.sm.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            l10n.purchaseReturnRemaining(
                              _qtyUnit(context, item, d.remainingMilli(item)),
                            ),
                            style: _muted(context),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: wide ? 140 : 110,
                      child: FTextField(
                        key: ValueKey(
                          'purchase-return-qty-${item.id.uuid}-$gen',
                        ),
                        hint: '0',
                        textAlign: TextAlign.end,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          QtyInputFormatter(
                            decimal: qtyDecimalSeparator(context),
                          ),
                        ],
                        error: vm.exceeds(item)
                            ? Text(l10n.purchaseReturnErrQty)
                            : null,
                        control: .managed(
                          onChange: (v) {
                            if (parseQtyInput(context, v.text) case final q?) {
                              vm.setReturnQty(item.id, q);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
            FTextField(
              key: ValueKey('purchase-return-note-$gen'),
              label: Text(l10n.purchaseReturnNote),
              maxLength: PurchaseLimits.note,
              control: .managed(onChange: (v) => vm.setReturnNote(v.text)),
            ),
            Text(
              l10n.purchaseReturnSplit(
                formatMoney(context, split.debtReduction),
                formatMoney(context, split.refund),
              ),
              key: const ValueKey('purchase-return-split'),
              style: theme.typography.body.sm,
            ),
            if (split.refund.value > 0)
              FSelect<String>(
                key: ValueKey('purchase-refund-source-$gen'),
                label: Text(l10n.purchaseRefundTo),
                hint: l10n.purchaseRefundToHint,
                forceErrorText:
                    issues.contains(PurchaseReturnIssue.refundSource)
                    ? l10n.purchaseReturnErrRefund
                    : null,
                items: {
                  for (final k in FundingKind.values)
                    if (k != FundingKind.drawer ||
                        (vm.setup?.canUseDrawer ?? false))
                      fundingLabel(l10n, k): k.name,
                },
                control: .managed(
                  initial: vm.refundSource?.name,
                  onChange: (v) {
                    if (v != null) {
                      vm.setRefundSource(FundingKind.values.byName(v));
                    }
                  },
                ),
              ),
            for (final i in issues)
              if (i != PurchaseReturnIssue.refundSource &&
                  i != PurchaseReturnIssue.quantity)
                Text(
                  purchaseReturnIssueMessage(l10n, i),
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.destructive,
                  ),
                ),
            if (error != null)
              FAlert(
                key: const ValueKey('purchase-return-error'),
                variant: .destructive,
                title: Text(purchaseErrorMessage(l10n, error)),
              ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FButton(
                  key: const ValueKey('purchase-return-cancel'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: vm.submitReturn.running ? null : vm.closeReturn,
                  child: Text(l10n.purchaseReturnCancel),
                ),
                FButton(
                  key: const ValueKey('purchase-return-submit'),
                  mainAxisSize: .min,
                  onPress: vm.submitReturn.running
                      ? null
                      : vm.submitReturn.execute,
                  child: Text(
                    l10n.purchaseReturnSubmit(
                      formatMoney(context, vm.returnTotal),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
