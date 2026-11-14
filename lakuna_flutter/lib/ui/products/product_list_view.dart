import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../data/services/spreadsheet_exporter.dart';
import '../../data/services/table_file.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../routing/routes.dart';
import '../core/format.dart';
import 'archived_products_dialog.dart';
import 'product_import_dialog.dart';
import 'product_list_view_model.dart';
import 'product_widgets.dart';

/// Layar *Produk & stok* (1.15 / 1.15m, F1-07). Memiliki
/// [ProductListViewModel] dan memuat katalog saat dibuka.
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({
    super.key,
    required this.repository,
    this.tablePicker = const FileSelectorTablePicker(),
    this.exporter = const PlatformSpreadsheetExporter(),
    this.openImport = false,
  });

  final CatalogRepository repository;
  final TableFilePicker tablePicker;

  /// Buka dialog import sekali saat layar tampil (dari setup, F1-01b).
  final bool openImport;

  /// Menyimpan templat import (F1-07g).
  final SpreadsheetExporter exporter;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final _viewModel = ProductListViewModel(repository: widget.repository);

  @override
  void initState() {
    super.initState();
    _viewModel.load.execute();
    if (widget.openImport) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _import();
      });
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProductListView(
    viewModel: _viewModel,
    onAdd: () => context.go(Routes.productNew),
    onOpen: (id) => context.go(Routes.product(id.uuid)),
    onImport: _import,
    onArchived: _archived,
    onLabels: () => context.push<void>(Routes.productLabels),
  );

  Future<void> _archived() async {
    await showArchivedProducts(context, widget.repository);
    // Dimuat ulang juga bila dialog ditutup lewat latar atau Esc.
    if (mounted) await _viewModel.load.execute();
  }

  Future<void> _import() async {
    final done = await showProductImport(
      context,
      widget.repository,
      picker: widget.tablePicker,
      exporter: widget.exporter,
    );
    if (done && mounted) await _viewModel.load.execute();
  }
}

class ProductListView extends StatelessWidget {
  const ProductListView({
    super.key,
    required this.viewModel,
    required this.onAdd,
    required this.onOpen,
    this.onImport,
    this.onArchived,
    this.onLabels,
  });

  final ProductListViewModel viewModel;
  final VoidCallback onAdd;
  final ValueChanged<UuidValue> onOpen;

  /// Import Excel/CSV (F1-07b); `null` menyembunyikan tombolnya.
  final VoidCallback? onImport;

  /// Dialog produk diarsipkan (F1-07d); tombol tampil bila ada arsip.
  final VoidCallback? onArchived;

  /// Halaman cetak label barcode (F1-07e); tombol tampil bila ada produk.
  final VoidCallback? onLabels;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        if (!viewModel.loaded) {
          if (viewModel.load.error) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: LoadFailedAlert(
                key: const ValueKey('products-load-error'),
                message: AppLocalizations.of(context).productsLoadFailed,
                onRetry: viewModel.load.execute,
              ),
            );
          }
          return const Center(child: FCircularProgress());
        }
        final narrow = constraints.maxWidth < 600;
        return narrow
            ? _MobileList(
                viewModel: viewModel,
                onAdd: onAdd,
                onOpen: onOpen,
                onImport: onImport,
                onArchived: viewModel.archivedCount > 0 ? onArchived : null,
                onLabels: viewModel.isEmpty ? null : onLabels,
              )
            : _WideList(
                viewModel: viewModel,
                onAdd: onAdd,
                onOpen: onOpen,
                onImport: onImport,
                onArchived: viewModel.archivedCount > 0 ? onArchived : null,
                onLabels: viewModel.isEmpty ? null : onLabels,
              );
      },
    ),
  );
}

Widget _searchIcon(
  BuildContext context,
  FTextFieldStyle style,
  Set<Object> _,
) => Padding(
  padding: const EdgeInsetsDirectional.only(start: 12),
  child: Icon(
    TablerIcons.search,
    size: 18,
    color: context.theme.colors.mutedForeground,
  ),
);

class _Search extends StatelessWidget {
  const _Search({required this.viewModel});

  final ProductListViewModel viewModel;

  @override
  Widget build(BuildContext context) => FTextField(
    key: const ValueKey('products-search'),
    hint: AppLocalizations.of(context).productsSearchHint,
    prefixBuilder: _searchIcon,
    control: .managed(
      initial: TextEditingValue(text: viewModel.query),
      onChange: (v) => viewModel.setQuery(v.text),
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onAdd, this.onImport});

  final VoidCallback onAdd;
  final VoidCallback? onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return FCard(
      key: const ValueKey('products-empty'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          spacing: 12,
          children: [
            Icon(
              TablerIcons.package,
              size: 40,
              color: theme.colors.mutedForeground,
            ),
            Text(
              l10n.productsEmptyTitle,
              style: theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              l10n.productsEmptyBody,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            FButton(
              key: const ValueKey('products-empty-add'),
              mainAxisSize: .min,
              prefix: const Icon(TablerIcons.plus),
              onPress: onAdd,
              child: Flexible(child: Text(l10n.productsNew)),
            ),
            if (onImport case final onImport?)
              FButton(
                key: const ValueKey('products-empty-import'),
                variant: .outline,
                mainAxisSize: .min,
                prefix: const Icon(TablerIcons.fileImport),
                onPress: onImport,
                child: Flexible(child: Text(l10n.productsImport)),
              ),
          ],
        ),
      ),
    );
  }
}

class _NoMatch extends StatelessWidget {
  const _NoMatch();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Text(
      AppLocalizations.of(context).productsNoMatch,
      key: const ValueKey('products-no-match'),
      textAlign: TextAlign.center,
      style: context.theme.typography.body.sm.copyWith(
        color: context.theme.colors.mutedForeground,
      ),
    ),
  );
}

// --- Layar lebar (1.15) -----------------------------------------------------

class _WideList extends StatelessWidget {
  const _WideList({
    required this.viewModel,
    required this.onAdd,
    required this.onOpen,
    this.onImport,
    this.onArchived,
    this.onLabels,
  });

  final ProductListViewModel viewModel;
  final VoidCallback onAdd;
  final ValueChanged<UuidValue> onOpen;
  final VoidCallback? onImport;
  final VoidCallback? onArchived;
  final VoidCallback? onLabels;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final products = viewModel.products;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Di bawah 900 px kolom Kategori dan Harga beli dilipat.
        final compact = constraints.maxWidth < 900;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 16,
                  children: [
                    PageHeader(
                      title: l10n.productsTitle,
                      subtitle: l10n.productsSummary(
                        viewModel.activeCount,
                        viewModel.lowStockCount,
                      ),
                      action: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          if (onArchived case final onArchived?)
                            FButton(
                              key: const ValueKey('products-archived'),
                              variant: .ghost,
                              mainAxisSize: .min,
                              prefix: const Icon(TablerIcons.archive),
                              onPress: onArchived,
                              child: Flexible(
                                child: Text(
                                  l10n.productsArchived(
                                    viewModel.archivedCount,
                                  ),
                                ),
                              ),
                            ),
                          if (onLabels case final onLabels?)
                            FButton(
                              key: const ValueKey('products-labels'),
                              variant: .outline,
                              mainAxisSize: .min,
                              prefix: const Icon(TablerIcons.barcode),
                              onPress: onLabels,
                              child: Flexible(
                                child: Text(l10n.productsLabels),
                              ),
                            ),
                          if (onImport case final onImport?)
                            FButton(
                              key: const ValueKey('products-import'),
                              variant: .outline,
                              mainAxisSize: .min,
                              prefix: const Icon(TablerIcons.fileImport),
                              onPress: onImport,
                              child: Flexible(
                                child: Text(l10n.productsImport),
                              ),
                            ),
                          FButton(
                            key: const ValueKey('products-add'),
                            mainAxisSize: .min,
                            prefix: const Icon(TablerIcons.plus),
                            onPress: onAdd,
                            child: Flexible(child: Text(l10n.productsNew)),
                          ),
                        ],
                      ),
                    ),
                    if (viewModel.isEmpty)
                      _Empty(onAdd: onAdd, onImport: onImport)
                    else
                      Row(
                        spacing: 12,
                        children: [
                          Expanded(child: _Search(viewModel: viewModel)),
                          SizedBox(
                            width: 220,
                            child: _CategorySelect(viewModel: viewModel),
                          ),
                        ],
                      ),
                    const SizedBox(height: 0),
                  ],
                ),
              ),
            ),
            if (!viewModel.isEmpty) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: DecoratedSliver(
                  decoration: BoxDecoration(
                    color: theme.colors.card,
                    border: Border.all(color: theme.colors.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  sliver: SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(child: _HeaderRow(compact: compact)),
                      if (products.isEmpty)
                        const SliverToBoxAdapter(child: _NoMatch())
                      else
                        SliverList.builder(
                          itemCount: products.length,
                          itemBuilder: (context, i) => _ProductRow(
                            product: products[i],
                            compact: compact,
                            last: i == products.length - 1,
                            onTap: () => onOpen(products[i].id),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l10n.productsStockFootnote,
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CategorySelect extends StatelessWidget {
  const _CategorySelect({required this.viewModel});

  final ProductListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Kunci memuat daftar kategori agar pilihan dibangun ulang saat
    // kategori berubah.
    final categories = viewModel.categories;
    return FSelect<String>(
      key: ValueKey('products-category-${categories.length}'),
      hint: l10n.productsCategoryFilter,
      items: {
        l10n.productsAllCategories: '',
        for (final c in categories) c.name: c.id.uuid,
      },
      control: .managed(
        initial: viewModel.categoryId?.uuid ?? '',
        onChange: (id) => viewModel.setCategory(
          id == null || id.isEmpty ? null : UuidValue.fromString(id),
        ),
      ),
    );
  }
}

/// Lebar relatif kolom tabel 1.15.
const _flex = (
  product: 30,
  category: 14,
  variant: 18,
  cost: 12,
  price: 12,
  tiers: 14,
  stock: 10,
);

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final style = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
      fontWeight: FontWeight.w600,
    );
    Widget cell(int flex, String text, {bool end = false}) => Expanded(
      flex: flex,
      child: Text(
        text,
        style: style,
        textAlign: end ? TextAlign.end : TextAlign.start,
      ),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          spacing: 12,
          children: [
            cell(_flex.product, l10n.productsColProduct),
            if (!compact) cell(_flex.category, l10n.productsColCategory),
            cell(_flex.variant, l10n.productsColVariantUnit),
            if (!compact) cell(_flex.cost, l10n.productsColCost, end: true),
            cell(_flex.price, l10n.productsColPrice, end: true),
            cell(_flex.tiers, l10n.productsColTiers),
            cell(_flex.stock, l10n.productsColStock, end: true),
          ],
        ),
      ),
    );
  }
}

/// "botol · Dus (6)" untuk satu varian, "2 varian · botol" untuk lebih.
String variantUnitLabel(BuildContext context, CatalogProduct p) {
  final l10n = AppLocalizations.of(context);
  if (p.variants.length > 1) {
    return '${l10n.productsVariantsCount(p.variants.length)} · ${p.baseUnit}';
  }
  final unit = p.variants.firstOrNull?.units.firstOrNull;
  if (unit == null) return p.baseUnit;
  return '${p.baseUnit} · ${unit.name} (${formatQty(context, unit.factor)})';
}

/// Harga satu varian, atau rentang "Rp 18.500–36.000".
String priceRange(
  BuildContext context,
  Iterable<Money> prices,
) {
  final sorted = prices.toList()..sort((a, b) => a.compareTo(b));
  if (sorted.isEmpty) return '—';
  final low = formatMoney(context, sorted.first);
  if (sorted.first == sorted.last) return low;
  final en = Localizations.localeOf(context).languageCode == 'en';
  return '$low–${groupThousands(sorted.last.value, en ? ',' : '.')}';
}

/// Tingkat grosir umum pertama varian pertama: "≥6: Rp 35.000". Tingkat
/// grup pelanggan (F1-07c) tidak ditampilkan di sini.
String tierLabel(BuildContext context, CatalogProduct p) {
  final tier = p.variants.firstOrNull?.tiers
      .where((t) => t.groupId == null)
      .firstOrNull;
  if (tier == null) return '—';
  return '≥${formatQty(context, tier.minQty)}: '
      '${formatMoney(context, tier.price)}';
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.compact,
    required this.last,
    required this.onTap,
  });

  final CatalogProduct product;
  final bool compact;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final p = product;
    final muted = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );
    final body = theme.typography.body.sm;
    final sku = p.sku ?? p.variants.firstOrNull?.sku;
    Widget cell(int flex, Widget child, {bool end = false}) => Expanded(
      flex: flex,
      child: Align(
        alignment: end ? Alignment.centerRight : Alignment.centerLeft,
        child: child,
      ),
    );
    return FTappable(
      key: ValueKey('product-row-${p.id.uuid}'),
      onPress: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: last
              ? null
              : Border(bottom: BorderSide(color: theme.colors.border)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                flex: _flex.product,
                child: Row(
                  spacing: 10,
                  children: [
                    ProductThumb(
                      name: p.name,
                      size: 36,
                      photoPath: p.photoPath,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: body.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            [
                              if (compact && p.categoryName != null)
                                p.categoryName!,
                              ?sku,
                              if (!p.isActive) l10n.productsInactive,
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: muted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!compact)
                cell(
                  _flex.category,
                  Text(p.categoryName ?? '—', style: body, maxLines: 1),
                ),
              cell(
                _flex.variant,
                Text(
                  variantUnitLabel(context, p),
                  style: body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!compact)
                cell(
                  _flex.cost,
                  Text(
                    priceRange(context, p.variants.map((v) => v.costPrice)),
                    style: body,
                    textAlign: TextAlign.end,
                  ),
                  end: true,
                ),
              cell(
                _flex.price,
                Text(
                  priceRange(context, p.variants.map((v) => v.sellPrice)),
                  style: body.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.end,
                ),
                end: true,
              ),
              cell(
                _flex.tiers,
                Text(tierLabel(context, p), style: body, maxLines: 2),
              ),
              cell(
                _flex.stock,
                p.tracksStock
                    ? StockPill(
                        text: formatQty(context, p.totalStock),
                        low: p.isLowStock,
                      )
                    : Text('—', style: body),
                end: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Ponsel (1.15m) -------------------------------------------------------

class _MobileList extends StatelessWidget {
  const _MobileList({
    required this.viewModel,
    required this.onAdd,
    required this.onOpen,
    this.onImport,
    this.onArchived,
    this.onLabels,
  });

  final ProductListViewModel viewModel;
  final VoidCallback onAdd;
  final ValueChanged<UuidValue> onOpen;
  final VoidCallback? onImport;
  final VoidCallback? onArchived;
  final VoidCallback? onLabels;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final products = viewModel.products;
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    PageHeader(
                      title: l10n.productsTitleMobile,
                      subtitle: l10n.productsSummaryShort(
                        viewModel.activeCount,
                        viewModel.lowStockCount,
                      ),
                      action: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          if (onArchived case final onArchived?)
                            FButton.icon(
                              key: const ValueKey('products-archived'),
                              variant: .outline,
                              semanticsLabel: l10n.productsArchived(
                                viewModel.archivedCount,
                              ),
                              onPress: onArchived,
                              child: const Icon(TablerIcons.archive),
                            ),
                          if (onLabels case final onLabels?)
                            FButton.icon(
                              key: const ValueKey('products-labels'),
                              variant: .outline,
                              semanticsLabel: l10n.productsLabels,
                              onPress: onLabels,
                              child: const Icon(TablerIcons.barcode),
                            ),
                          if (onImport case final onImport?
                              when !viewModel.isEmpty)
                            FButton.icon(
                              key: const ValueKey('products-import'),
                              variant: .outline,
                              semanticsLabel: l10n.productsImport,
                              onPress: onImport,
                              child: const Icon(TablerIcons.fileImport),
                            ),
                        ],
                      ),
                    ),
                    if (viewModel.isEmpty)
                      _Empty(onAdd: onAdd, onImport: onImport)
                    else ...[
                      _Search(viewModel: viewModel),
                      _Chips(viewModel: viewModel),
                    ],
                  ],
                ),
              ),
            ),
            if (!viewModel.isEmpty)
              if (products.isEmpty)
                const SliverToBoxAdapter(child: _NoMatch())
              else
                SliverPadding(
                  // Ruang untuk tombol mengambang.
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                  sliver: SliverList.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _ProductCard(
                      product: products[i],
                      onTap: () => onOpen(products[i].id),
                    ),
                  ),
                ),
          ],
        ),
        if (!viewModel.isEmpty)
          PositionedDirectional(
            end: 16,
            bottom: 16,
            child: SizedBox.square(
              dimension: 56,
              child: FButton.icon(
                key: const ValueKey('products-fab'),
                variant: .primary,
                semanticsLabel: l10n.productsNew,
                onPress: onAdd,
                child: const Icon(TablerIcons.plus, size: 24),
              ),
            ),
          ),
      ],
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({required this.viewModel});

  final ProductListViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: [
          ChoicePill(
            key: const ValueKey('products-chip-all'),
            label: l10n.productsAllCategories,
            selected: viewModel.categoryId == null && !viewModel.lowStockOnly,
            onTap: () => viewModel.setCategory(null),
          ),
          ChoicePill(
            key: const ValueKey('products-chip-low'),
            label: l10n.productsBelowMinimumChip(viewModel.lowStockCount),
            selected: viewModel.lowStockOnly,
            onTap: () => viewModel.setLowStockOnly(!viewModel.lowStockOnly),
          ),
          for (final c in viewModel.categories)
            ChoicePill(
              key: ValueKey('products-chip-${c.id.uuid}'),
              label: c.name,
              selected: viewModel.categoryId == c.id,
              onTap: () => viewModel.setCategory(c.id),
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final CatalogProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final p = product;
    final lowVariant = p.variants.where((v) => v.isBelowMinimum).firstOrNull;
    final stockText = !p.tracksStock
        ? null
        : p.isLowStock && lowVariant != null
        ? l10n.productsStockMin(
            // Stok varian yang kurang, bukan total semua varian.
            formatQty(context, lowVariant.stock),
            formatQty(context, lowVariant.minStock),
          )
        : l10n.productsStock(formatQty(context, p.totalStock));
    return FTappable(
      key: ValueKey('product-card-${p.id.uuid}'),
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
              ProductThumb(name: p.name, size: 52, photoPath: p.photoPath),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      p.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      [
                        ?p.categoryName,
                        variantUnitLabel(context, p),
                        if (!p.isActive) l10n.productsInactive,
                      ].join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 6,
                  children: [
                    Text(
                      priceRange(context, p.variants.map((v) => v.sellPrice)),
                      textAlign: TextAlign.end,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (stockText != null)
                      StockPill(
                        text: stockText,
                        low: p.isLowStock,
                        mobile: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
