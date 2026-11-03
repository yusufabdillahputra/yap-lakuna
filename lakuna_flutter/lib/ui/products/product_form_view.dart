import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../routing/routes.dart';
import '../core/format.dart';
import 'product_form_view_model.dart';
import 'product_widgets.dart';

/// Layar form produk 1.16 (F1-07): tambah ([productId] `null`) atau ubah.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({
    super.key,
    required this.repository,
    this.productId,
  });

  final CatalogRepository repository;
  final String? productId;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  late final _viewModel = ProductFormViewModel(
    repository: widget.repository,
    productId: widget.productId,
  );

  @override
  void initState() {
    super.initState();
    _viewModel.load.execute();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ProductFormView(
    viewModel: _viewModel,
    onDone: () => context.go(Routes.products),
  );
}

/// Pesan galat umum form produk.
String productErrorMessage(AppLocalizations l10n, Exception error) =>
    switch (error) {
      NotPermitted(:final permission) => l10n.productErrorNotPermitted(
        permission.key,
      ),
      ProductNotFound() => l10n.productNotFound,
      _ => l10n.productSaveFailed,
    };

int _maxLength(ProductField field) => switch (field) {
  ProductField.name => ProductLimits.name,
  ProductField.category => ProductLimits.category,
  ProductField.baseUnit => ProductLimits.baseUnit,
  ProductField.sku || ProductField.variantSku => ProductLimits.sku,
  ProductField.brand => ProductLimits.brand,
  ProductField.variantName => ProductLimits.variantName,
  ProductField.unitName => ProductLimits.unitName,
  _ => ProductLimits.barcode,
};

/// Teks galat sebuah field.
String productFieldError(
  AppLocalizations l10n,
  ProductField field,
  FieldProblem problem,
) => switch (problem.error) {
  ProductError.required =>
    field == ProductField.variants
        ? l10n.productErrorVariantsRequired
        : l10n.errorRequired,
  ProductError.tooLong => l10n.productErrorTooLong(_maxLength(field)),
  ProductError.negative => l10n.productErrorNegative,
  ProductError.notPositive => l10n.productErrorNotPositive,
  ProductError.duplicate => l10n.productErrorDuplicate,
  ProductError.sameAsBase => l10n.productErrorSameAsBase,
  ProductError.factorTooSmall => l10n.productErrorFactorTooSmall,
  ProductError.minQtyTooSmall => l10n.productErrorMinQtyTooSmall,
  ProductError.taken => l10n.productErrorTaken(problem.takenBy ?? ''),
};

class ProductFormView extends StatelessWidget {
  const ProductFormView({
    super.key,
    required this.viewModel,
    required this.onDone,
  });

  final ProductFormViewModel viewModel;
  final VoidCallback onDone;

  Future<void> _save() async {
    await viewModel.save.execute();
    if (viewModel.save.completed) onDone();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (!viewModel.loaded) {
          if (viewModel.load.error) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: LoadFailedAlert(
                key: const ValueKey('product-load-error'),
                message: l10n.productsLoadFailed,
                onRetry: viewModel.load.execute,
              ),
            );
          }
          return const Center(child: FCircularProgress());
        }
        if (viewModel.notFound) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                FAlert(
                  key: const ValueKey('product-not-found'),
                  variant: .destructive,
                  title: Text(l10n.productNotFound),
                ),
                FButton(
                  mainAxisSize: .min,
                  variant: .outline,
                  onPress: onDone,
                  child: Flexible(child: Text(l10n.productsTitle)),
                ),
              ],
            ),
          );
        }
        final title = viewModel.isNew
            ? l10n.productFormNewTitle
            : l10n.productFormEditTitle(viewModel.originalName);
        final saving = viewModel.save.running;
        final error = viewModel.error;
        final hasProblems = ProductTab.values.any(viewModel.tabHasProblem);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              PageHeader(
                leading: Text(
                  '${l10n.productsTitle} › '
                  '${viewModel.isNew ? l10n.productFormNewTitle : viewModel.originalName}',
                  style: theme.typography.body.xs.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                ),
                title: title,
                action: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    FButton(
                      key: const ValueKey('product-cancel'),
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: saving ? null : onDone,
                      child: Flexible(child: Text(l10n.productFormCancel)),
                    ),
                    FButton(
                      key: const ValueKey('product-save'),
                      mainAxisSize: .min,
                      onPress: saving ? null : _save,
                      prefix: saving
                          ? const SizedBox.square(
                              dimension: 16,
                              child: FCircularProgress(),
                            )
                          : const Icon(TablerIcons.deviceFloppy),
                      child: Flexible(child: Text(l10n.productFormSave)),
                    ),
                  ],
                ),
              ),
              if (error != null)
                FAlert(
                  key: const ValueKey('product-error'),
                  variant: .destructive,
                  title: Text(productErrorMessage(l10n, error)),
                )
              else if (hasProblems ||
                  viewModel.problem(ProductField.name) != null ||
                  viewModel.problem(ProductField.baseUnit) != null)
                FAlert(
                  key: const ValueKey('product-fix-errors'),
                  variant: .destructive,
                  title: Text(l10n.productFixErrors),
                ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final info = _InfoCard(viewModel: viewModel);
                  final tabs = _TabsCard(viewModel: viewModel);
                  if (constraints.maxWidth >= 1000) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 16,
                      children: [
                        SizedBox(width: 360, child: info),
                        Expanded(child: tabs),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [info, tabs],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Field ------------------------------------------------------------------

Widget _rpPrefix(BuildContext context, FTextFieldStyle style, Set<Object> _) =>
    Padding(
      padding: const EdgeInsetsDirectional.only(start: 12),
      child: Text(
        'Rp',
        style: context.theme.typography.body.md.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
    );

Text? _errorText(
  BuildContext context,
  ProductField field,
  FieldProblem? problem,
) => problem == null
    ? null
    : Text(productFieldError(AppLocalizations.of(context), field, problem));

/// Field teks bebas.
class _TextInput extends StatelessWidget {
  const _TextInput({
    super.key,
    required this.field,
    required this.initial,
    required this.onChange,
    this.label,
    this.hint,
    this.problem,
  });

  final ProductField field;
  final String initial;
  final ValueChanged<String> onChange;
  final String? label;
  final String? hint;
  final FieldProblem? problem;

  @override
  Widget build(BuildContext context) => FTextField(
    label: label == null ? null : Text(label!),
    hint: hint,
    error: _errorText(context, field, problem),
    control: .managed(
      initial: TextEditingValue(text: initial),
      onChange: (v) => onChange(v.text),
    ),
  );
}

/// Field rupiah. [optional] `true`: kosong = `null`.
class _MoneyInput extends StatelessWidget {
  const _MoneyInput({
    super.key,
    required this.field,
    required this.initial,
    required this.onChange,
    this.label,
    this.hint,
    this.problem,
  });

  final ProductField field;
  final Money? initial;
  final ValueChanged<Money?> onChange;
  final String? label;
  final String? hint;
  final FieldProblem? problem;

  @override
  Widget build(BuildContext context) {
    final initial = this.initial;
    return FTextField(
      label: label == null ? null : Text(label!),
      hint: hint,
      keyboardType: TextInputType.number,
      inputFormatters: const [RupiahInputFormatter()],
      prefixBuilder: _rpPrefix,
      error: _errorText(context, field, problem),
      control: .managed(
        initial: TextEditingValue(
          text: initial == null ? '' : groupThousands(initial.value, '.'),
        ),
        onChange: (v) {
          final digits = v.text.replaceAll(RegExp('[^0-9]'), '');
          onChange(digits.isEmpty ? null : Money(int.parse(digits)));
        },
      ),
    );
  }
}

/// Field jumlah barang (satuan dasar), mendukung pecahan.
class _QtyInput extends StatelessWidget {
  const _QtyInput({
    super.key,
    required this.field,
    required this.initial,
    required this.onChange,
    this.label,
    this.problem,
  });

  final ProductField field;
  final Qty initial;
  final ValueChanged<Qty> onChange;
  final String? label;
  final FieldProblem? problem;

  @override
  Widget build(BuildContext context) => FTextField(
    label: label == null ? null : Text(label!),
    hint: '0',
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [
      QtyInputFormatter(decimal: qtyDecimalSeparator(context)),
    ],
    error: _errorText(context, field, problem),
    control: .managed(
      initial: TextEditingValue(
        text: initial == Qty.zero
            ? ''
            : formatQty(context, initial, grouped: false),
      ),
      onChange: (v) => onChange(parseQtyInput(context, v.text) ?? Qty.zero),
    ),
  );
}

// --- Info dasar -------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.viewModel});

  final ProductFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    Widget pair(Widget a, Widget b) => LayoutBuilder(
      builder: (context, c) => c.maxWidth < 320
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [a, b],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Expanded(child: a),
                Expanded(child: b),
              ],
            ),
    );
    return SectionCard(
      title: l10n.productFormBasicInfo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Row(
            spacing: 12,
            children: [
              ProductThumb(
                name: vm.name.trim().isEmpty ? '?' : vm.name,
                size: 72,
              ),
              Expanded(
                child: _TextInput(
                  key: const ValueKey('product-name'),
                  field: ProductField.name,
                  label: l10n.productFormName,
                  initial: vm.name,
                  problem: vm.problem(ProductField.name),
                  onChange: vm.setName,
                ),
              ),
            ],
          ),
          pair(
            FAutocomplete.text(
              key: const ValueKey('product-category'),
              items: vm.categorySuggestions,
              label: Text(l10n.productFormCategory),
              hint: l10n.productFormOptional,
              forceErrorText: vm.problem(ProductField.category) == null
                  ? null
                  : productFieldError(
                      l10n,
                      ProductField.category,
                      vm.problem(ProductField.category)!,
                    ),
              control: .managed(
                initial: TextEditingValue(text: vm.category),
                onChange: (v) => vm.setCategory(v.text),
              ),
            ),
            FSelect<ProductKind>(
              key: const ValueKey('product-kind'),
              label: Text(l10n.productFormKind),
              items: {
                l10n.productKindGoods: ProductKind.goods,
                l10n.productKindService: ProductKind.service,
                l10n.productKindMenu: ProductKind.menu,
              },
              control: .managed(
                initial: vm.kind,
                onChange: (k) {
                  if (k != null) vm.setKind(k);
                },
              ),
            ),
          ),
          pair(
            FAutocomplete.text(
              key: const ValueKey('product-base-unit'),
              items: vm.unitSuggestions,
              label: Text(l10n.productFormBaseUnit),
              hint: l10n.productFormBaseUnitHint,
              forceErrorText: vm.problem(ProductField.baseUnit) == null
                  ? null
                  : productFieldError(
                      l10n,
                      ProductField.baseUnit,
                      vm.problem(ProductField.baseUnit)!,
                    ),
              control: .managed(
                initial: TextEditingValue(text: vm.baseUnit),
                onChange: (v) => vm.setBaseUnit(v.text),
              ),
            ),
            _TextInput(
              key: const ValueKey('product-sku'),
              field: ProductField.sku,
              label: l10n.productFormSku,
              hint: l10n.productFormOptional,
              initial: vm.sku,
              problem: vm.problem(ProductField.sku),
              onChange: vm.setSku,
            ),
          ),
          _TextInput(
            key: const ValueKey('product-brand'),
            field: ProductField.brand,
            label: l10n.productFormBrand,
            hint: l10n.productFormOptional,
            initial: vm.brand,
            problem: vm.problem(ProductField.brand),
            onChange: vm.setBrand,
          ),
          FSwitch(
            key: const ValueKey('product-active'),
            label: Text(l10n.productFormActive),
            value: vm.isActive,
            onChange: vm.setActive,
          ),
          FSwitch(
            key: const ValueKey('product-taxable'),
            label: Text(l10n.productFormTaxable),
            description: Text(l10n.productFormTaxableHint),
            value: vm.isTaxable,
            onChange: vm.setTaxable,
          ),
        ],
      ),
    );
  }
}

// --- Kartu tab ----------------------------------------------------------------

class _TabsCard extends StatelessWidget {
  const _TabsCard({required this.viewModel});

  final ProductFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    // Layar sempit memakai label pendek agar tidak terpotong.
    final narrow = MediaQuery.sizeOf(context).width < 600;
    Widget label(ProductTab tab, String text) => Row(
      key: ValueKey('product-tab-${tab.name}'),
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
        if (vm.tabHasProblem(tab)) const _ProblemDot(),
      ],
    );
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FTabs(
          control: .lifted(
            index: vm.tab.index,
            onChange: (i) => vm.setTab(ProductTab.values[i]),
          ),
          children: [
            FTabEntry(
              label: label(ProductTab.variants, l10n.productTabVariants),
              child: _VariantsTab(viewModel: vm),
            ),
            FTabEntry(
              label: label(
                ProductTab.units,
                narrow ? l10n.productTabUnitsShort : l10n.productTabUnits,
              ),
              child: _UnitsTab(viewModel: vm),
            ),
            FTabEntry(
              label: label(
                ProductTab.tiers,
                narrow ? l10n.productTabTiersShort : l10n.productTabTiers,
              ),
              child: _TiersTab(viewModel: vm),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProblemDot extends StatelessWidget {
  const _ProblemDot();

  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(
      color: context.theme.colors.destructive,
      shape: BoxShape.circle,
    ),
  );
}

/// Satu kolom tabel yang bisa diedit.
class _Col {
  const _Col(this.label, this.flex, this.build);

  final String label;
  final int flex;

  /// [labeled] `true` di layar sempit (baris ditumpuk dengan label).
  final Widget Function(bool labeled) build;
}

/// Tabel isian: baris [Row] dengan kepala kolom di layar lebar, kartu kecil
/// berlabel di layar sempit (< 640 px).
class _EditableTable extends StatelessWidget {
  const _EditableTable({required this.rows, this.leading});

  /// `(kunci, judul baris, kolom, hapus)`; kepala tabel memakai label kolom
  /// baris pertama.
  final List<(Key, String, List<_Col>, VoidCallback?)> rows;

  /// Baris tetap di atas baris isian (mis. satuan dasar).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        Widget remove(Key key, VoidCallback? onRemove) => SizedBox.square(
          dimension: 36,
          child: onRemove == null
              ? null
              : FButton.icon(
                  key: ValueKey('${(key as ValueKey<String>).value}-remove'),
                  variant: .ghost,
                  semanticsLabel: l10n.productRemoveRow,
                  onPress: onRemove,
                  child: const Icon(TablerIcons.trash, size: 18),
                ),
        );
        if (wide) {
          final header = rows.isEmpty ? const <_Col>[] : rows.first.$3;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              if (rows.isNotEmpty)
                Row(
                  spacing: 8,
                  children: [
                    for (final c in header)
                      Expanded(
                        flex: c.flex,
                        child: Text(
                          c.label,
                          style: theme.typography.body.xs.copyWith(
                            color: theme.colors.mutedForeground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 36),
                  ],
                ),
              ?leading,
              for (final (key, _, cols, onRemove) in rows)
                Row(
                  key: key,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    for (final c in cols)
                      Expanded(flex: c.flex, child: c.build(false)),
                    remove(key, onRemove),
                  ],
                ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            ?leading,
            for (final (key, title, cols, onRemove) in rows)
              DecoratedBox(
                key: key,
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 10,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: theme.typography.body.sm.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          remove(key, onRemove),
                        ],
                      ),
                      for (final c in cols) c.build(true),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.buttonKey,
    required this.label,
    required this.onPress,
  });

  final Key buttonKey;
  final String label;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: FButton(
      key: buttonKey,
      variant: .outline,
      size: .sm,
      mainAxisSize: .min,
      prefix: const Icon(TablerIcons.plus),
      onPress: onPress,
      child: Flexible(child: Text(label)),
    ),
  );
}

class _Help extends StatelessWidget {
  const _Help(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.theme.typography.body.xs.copyWith(
      color: context.theme.colors.mutedForeground,
    ),
  );
}

String _baseUnitName(AppLocalizations l10n, ProductFormViewModel vm) =>
    vm.baseUnit.trim().isEmpty ? l10n.productBaseUnitPlaceholder : vm.baseUnit;

String _variantTitle(AppLocalizations l10n, EditableVariant v, int index) =>
    v.name.trim().isEmpty ? l10n.productVariantFallback(index + 1) : v.name;

class _VariantsTab extends StatelessWidget {
  const _VariantsTab({required this.viewModel});

  final ProductFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final tracks = vm.kind.tracksStock;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          _EditableTable(
            rows: [
              for (final (i, v) in vm.variants.indexed)
                (
                  ValueKey('variant-${v.key}'),
                  _variantTitle(l10n, v, i),
                  _variantCols(context, vm, i, v, tracks),
                  vm.variants.length > 1 ? () => vm.removeVariant(i) : null,
                ),
            ],
          ),
          _AddButton(
            buttonKey: const ValueKey('product-add-variant'),
            label: l10n.productAddVariant,
            onPress: vm.addVariant,
          ),
          if (tracks) _Help(l10n.productUnitsHelpBase(_baseUnitName(l10n, vm))),
        ],
      ),
    );
  }

  List<_Col> _variantCols(
    BuildContext context,
    ProductFormViewModel vm,
    int i,
    EditableVariant v,
    bool tracks,
  ) {
    final l10n = AppLocalizations.of(context);
    FieldProblem? p(ProductField f) => vm.problem(f, variant: v.key);
    String? l(bool labeled, String text) => labeled ? text : null;
    void edit(ProductField f, void Function(EditableVariant v) change) =>
        vm.editVariant(i, f, change);
    return [
      _Col(
        l10n.productVariantName,
        14,
        (labeled) => _TextInput(
          key: ValueKey('variant-${v.key}-name'),
          field: ProductField.variantName,
          label: l(labeled, l10n.productVariantName),
          hint: l10n.productVariantNameHint,
          initial: v.name,
          problem: p(ProductField.variantName),
          onChange: (s) => edit(ProductField.variantName, (v) => v.name = s),
        ),
      ),
      _Col(
        l10n.productVariantSku,
        14,
        (labeled) => _TextInput(
          key: ValueKey('variant-${v.key}-sku'),
          field: ProductField.variantSku,
          label: l(labeled, l10n.productVariantSku),
          initial: v.sku,
          problem: p(ProductField.variantSku),
          onChange: (s) => edit(ProductField.variantSku, (v) => v.sku = s),
        ),
      ),
      _Col(
        l10n.productVariantBarcode,
        16,
        (labeled) => _TextInput(
          key: ValueKey('variant-${v.key}-barcode'),
          field: ProductField.variantBarcode,
          label: l(labeled, l10n.productVariantBarcode),
          initial: v.barcode,
          problem: p(ProductField.variantBarcode),
          onChange: (s) =>
              edit(ProductField.variantBarcode, (v) => v.barcode = s),
        ),
      ),
      _Col(
        l10n.productCostPrice,
        15,
        (labeled) => _MoneyInput(
          key: ValueKey('variant-${v.key}-cost'),
          field: ProductField.costPrice,
          label: l(labeled, l10n.productCostPrice),
          initial: v.costPrice == Money.zero ? null : v.costPrice,
          problem: p(ProductField.costPrice),
          onChange: (m) => edit(
            ProductField.costPrice,
            (v) => v.costPrice = m ?? Money.zero,
          ),
        ),
      ),
      _Col(
        l10n.productSellPrice,
        15,
        (labeled) => _MoneyInput(
          key: ValueKey('variant-${v.key}-price'),
          field: ProductField.sellPrice,
          label: l(labeled, l10n.productSellPrice),
          initial: v.sellPrice == Money.zero ? null : v.sellPrice,
          problem: p(ProductField.sellPrice),
          onChange: (m) => edit(
            ProductField.sellPrice,
            (v) => v.sellPrice = m ?? Money.zero,
          ),
        ),
      ),
      if (tracks)
        _Col(
          l10n.productMinStock,
          10,
          (labeled) => _QtyInput(
            key: ValueKey('variant-${v.key}-min'),
            field: ProductField.minStock,
            label: l(labeled, l10n.productMinStock),
            initial: v.minStock,
            problem: p(ProductField.minStock),
            onChange: (q) => edit(ProductField.minStock, (v) => v.minStock = q),
          ),
        ),
      if (tracks)
        _Col(
          l10n.productOpeningStock,
          10,
          (labeled) => v.isNew
              ? _QtyInput(
                  key: ValueKey('variant-${v.key}-opening'),
                  field: ProductField.openingStock,
                  label: l(labeled, l10n.productOpeningStock),
                  initial: v.openingStock,
                  problem: p(ProductField.openingStock),
                  onChange: (q) => edit(
                    ProductField.openingStock,
                    (v) => v.openingStock = q,
                  ),
                )
              : labeled
              ? const SizedBox.shrink()
              : const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text('—', textAlign: TextAlign.center),
                ),
        ),
    ];
  }
}

/// Pilihan varian di tab Satuan dan Harga grosir (bila lebih dari satu).
class _VariantPicker extends StatelessWidget {
  const _VariantPicker({required this.viewModel, required this.tab});

  final ProductFormViewModel viewModel;
  final ProductTab tab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          l10n.productSelectVariant,
          style: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        for (final (i, v) in vm.variants.indexed)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              ChoicePill(
                key: ValueKey('${tab.name}-variant-$i'),
                label: _variantTitle(l10n, v, i),
                selected: vm.selectedVariant == i,
                onTap: () => vm.selectVariant(i),
              ),
              if (vm.variantHasProblem(tab, v.key)) const _ProblemDot(),
            ],
          ),
      ],
    );
  }
}

class _UnitsTab extends StatelessWidget {
  const _UnitsTab({required this.viewModel});

  final ProductFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final vi = vm.selectedVariant;
    final v = vm.variants[vi];
    final base = _baseUnitName(l10n, vm);
    final first = v.units.firstOrNull;
    final baseRow = DecoratedBox(
      key: const ValueKey('unit-base-row'),
      decoration: BoxDecoration(
        color: theme.colors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          '$base (${l10n.productBaseUnitRow}) · 1 · '
          '${formatMoney(context, v.costPrice)} · '
          '${formatMoney(context, v.sellPrice)}'
          '${v.barcode.trim().isEmpty ? '' : ' · ${v.barcode.trim()}'}',
          style: theme.typography.body.sm,
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (vm.variants.length > 1)
            _VariantPicker(viewModel: vm, tab: ProductTab.units),
          _EditableTable(
            leading: baseRow,
            rows: [
              for (final (j, u) in v.units.indexed)
                (
                  ValueKey('unit-${u.key}'),
                  u.name.trim().isEmpty ? l10n.productUnitName : u.name,
                  _unitCols(context, vm, vi, j, u),
                  () => vm.removeUnit(vi, j),
                ),
            ],
          ),
          if (v.units.isEmpty) _Help(l10n.productUnitsEmpty),
          _AddButton(
            buttonKey: const ValueKey('product-add-unit'),
            label: l10n.productAddUnit,
            onPress: () => vm.addUnit(vi),
          ),
          _Help(
            first == null ||
                    first.name.trim().isEmpty ||
                    first.factor == Qty.zero
                ? l10n.productUnitsHelpBase(base)
                : l10n.productUnitsHelp(
                    base,
                    first.name.trim(),
                    formatQty(context, first.factor),
                  ),
          ),
        ],
      ),
    );
  }

  List<_Col> _unitCols(
    BuildContext context,
    ProductFormViewModel vm,
    int vi,
    int j,
    EditableUnit u,
  ) {
    final l10n = AppLocalizations.of(context);
    final v = vm.variants[vi];
    final base = _baseUnitName(l10n, vm);
    FieldProblem? p(ProductField f) =>
        vm.problem(f, variant: v.key, unit: u.key);
    String? l(bool labeled, String text) => labeled ? text : null;
    void edit(ProductField f, void Function(EditableUnit u) change) =>
        vm.editUnit(vi, j, f, change);
    String? defaultHint(Money price) => u.factor == Qty.zero
        ? l10n.productUnitPriceHint
        : groupThousands(
            conversionSellPrice(variantPrice: price, factor: u.factor).value,
            '.',
          );
    return [
      _Col(
        l10n.productUnitName,
        14,
        (labeled) => _TextInput(
          key: ValueKey('unit-${u.key}-name'),
          field: ProductField.unitName,
          label: l(labeled, l10n.productUnitName),
          hint: 'dus',
          initial: u.name,
          problem: p(ProductField.unitName),
          onChange: (s) => edit(ProductField.unitName, (u) => u.name = s),
        ),
      ),
      _Col(
        l10n.productUnitFactor(base),
        10,
        (labeled) => _QtyInput(
          key: ValueKey('unit-${u.key}-factor'),
          field: ProductField.unitFactor,
          label: l(labeled, l10n.productUnitFactor(base)),
          initial: u.factor,
          problem: p(ProductField.unitFactor),
          onChange: (q) => edit(ProductField.unitFactor, (u) => u.factor = q),
        ),
      ),
      _Col(
        l10n.productCostPrice,
        15,
        (labeled) => _MoneyInput(
          key: ValueKey('unit-${u.key}-cost'),
          field: ProductField.unitCostPrice,
          label: l(labeled, l10n.productCostPrice),
          hint: defaultHint(v.costPrice),
          initial: u.costPrice,
          problem: p(ProductField.unitCostPrice),
          onChange: (m) =>
              edit(ProductField.unitCostPrice, (u) => u.costPrice = m),
        ),
      ),
      _Col(
        l10n.productSellPrice,
        15,
        (labeled) => _MoneyInput(
          key: ValueKey('unit-${u.key}-price'),
          field: ProductField.unitSellPrice,
          label: l(labeled, l10n.productSellPrice),
          hint: defaultHint(v.sellPrice),
          initial: u.sellPrice,
          problem: p(ProductField.unitSellPrice),
          onChange: (m) =>
              edit(ProductField.unitSellPrice, (u) => u.sellPrice = m),
        ),
      ),
      _Col(
        l10n.productVariantBarcode,
        16,
        (labeled) => _TextInput(
          key: ValueKey('unit-${u.key}-barcode'),
          field: ProductField.unitBarcode,
          label: l(labeled, l10n.productVariantBarcode),
          initial: u.barcode,
          problem: p(ProductField.unitBarcode),
          onChange: (s) => edit(ProductField.unitBarcode, (u) => u.barcode = s),
        ),
      ),
    ];
  }
}

class _TiersTab extends StatelessWidget {
  const _TiersTab({required this.viewModel});

  final ProductFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final vi = vm.selectedVariant;
    final v = vm.variants[vi];
    final base = _baseUnitName(l10n, vm);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          if (vm.variants.length > 1)
            _VariantPicker(viewModel: vm, tab: ProductTab.tiers),
          _EditableTable(
            rows: [
              for (final (k, t) in v.tiers.indexed)
                (
                  ValueKey('tier-${t.key}'),
                  '≥ ${formatQty(context, t.minQty)} $base',
                  _tierCols(context, vm, vi, k, t),
                  () => vm.removeTier(vi, k),
                ),
            ],
          ),
          if (v.tiers.isEmpty) _Help(l10n.productTiersEmpty),
          _AddButton(
            buttonKey: const ValueKey('product-add-tier'),
            label: l10n.productAddTier,
            onPress: () => vm.addTier(vi),
          ),
          _Help(l10n.productTiersHelp),
        ],
      ),
    );
  }

  List<_Col> _tierCols(
    BuildContext context,
    ProductFormViewModel vm,
    int vi,
    int k,
    EditableTier t,
  ) {
    final l10n = AppLocalizations.of(context);
    final v = vm.variants[vi];
    final base = _baseUnitName(l10n, vm);
    FieldProblem? p(ProductField f) =>
        vm.problem(f, variant: v.key, tier: t.key);
    String? l(bool labeled, String text) => labeled ? text : null;
    void edit(ProductField f, void Function(EditableTier t) change) =>
        vm.editTier(vi, k, f, change);
    return [
      _Col(
        l10n.productTierMinQty(base),
        12,
        (labeled) => _QtyInput(
          key: ValueKey('tier-${t.key}-qty'),
          field: ProductField.tierMinQty,
          label: l(labeled, l10n.productTierMinQty(base)),
          initial: t.minQty,
          problem: p(ProductField.tierMinQty),
          onChange: (q) => edit(ProductField.tierMinQty, (t) => t.minQty = q),
        ),
      ),
      _Col(
        l10n.productTierPrice(base),
        14,
        (labeled) => _MoneyInput(
          key: ValueKey('tier-${t.key}-price'),
          field: ProductField.tierPrice,
          label: l(labeled, l10n.productTierPrice(base)),
          initial: t.price,
          problem: p(ProductField.tierPrice),
          onChange: (m) => edit(ProductField.tierPrice, (t) => t.price = m),
        ),
      ),
      _Col(
        l10n.productTierAppliesTo,
        14,
        (labeled) => Padding(
          padding: EdgeInsets.symmetric(vertical: labeled ? 0 : 10),
          child: Text(
            labeled
                ? '${l10n.productTierAppliesTo}: ${l10n.productTierAllCustomers}'
                : l10n.productTierAllCustomers,
            style: context.theme.typography.body.sm.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ),
      ),
    ];
  }
}
