import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/cashier_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../routing/routes.dart';
import '../core/format.dart';
import '../products/product_list_view.dart' show priceRange;
import '../products/product_widgets.dart';
import 'cashier_view_model.dart';
import 'payment_view.dart';

/// Layar kasir retail (1.4 / 1.11 / 1.11b, F1-04) beserta tahap bayar
/// (1.5 / 1.5c, F1-05). Memiliki [CashierViewModel].
class CashierScreen extends StatefulWidget {
  const CashierScreen({super.key, required this.repository});

  final CashierRepository repository;

  @override
  State<CashierScreen> createState() => _CashierScreenState();
}

class _CashierScreenState extends State<CashierScreen> {
  late final _viewModel = CashierViewModel(repository: widget.repository);

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
  Widget build(BuildContext context) => CashierView(
    viewModel: _viewModel,
    onOpenSession: () => context.go(Routes.cashSession),
  );
}

class CashierView extends StatelessWidget {
  const CashierView({
    super.key,
    required this.viewModel,
    required this.onOpenSession,
  });

  final CashierViewModel viewModel;
  final VoidCallback onOpenSession;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        final vm = viewModel;
        if (!vm.loaded) {
          if (vm.load.error) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: LoadFailedAlert(
                key: const ValueKey('cashier-load-error'),
                message: AppLocalizations.of(context).cashierLoadFailed,
                onRetry: vm.load.execute,
              ),
            );
          }
          return const Center(child: FCircularProgress());
        }
        if (!vm.hasSession) {
          return _NoSession(onOpenSession: onOpenSession);
        }
        final narrow = constraints.maxWidth < 600;
        return switch (vm.stage) {
          CashierStage.pay => PaymentView(viewModel: vm, narrow: narrow),
          CashierStage.done => SuccessView(viewModel: vm, narrow: narrow),
          CashierStage.browse =>
            narrow
                ? _MobileCashier(viewModel: vm)
                : _WideCashier(
                    viewModel: vm,
                    panelWidth: constraints.maxWidth >= 1000 ? 380 : 320,
                  ),
        };
      },
    ),
  );
}

class _NoSession extends StatelessWidget {
  const _NoSession({required this.onOpenSession});

  final VoidCallback onOpenSession;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: FCard(
            key: const ValueKey('cashier-no-session'),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Icon(
                    TablerIcons.cashRegister,
                    size: 32,
                    color: theme.colors.primary,
                  ),
                  Text(
                    l10n.cashierNoSessionTitle,
                    style: theme.typography.display.lg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    l10n.cashierNoSessionBody,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FButton(
                    key: const ValueKey('cashier-open-session'),
                    prefix: const Icon(TablerIcons.cashRegister),
                    onPress: onOpenSession,
                    child: Flexible(
                      child: Text(
                        l10n.cashierOpenSession,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Baris konteks: "Warung Contoh · Cabang Pusat" dan kasir + jam buka sesi.
class _ContextLine extends StatelessWidget {
  const _ContextLine({required this.viewModel});

  final CashierViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final data = viewModel.data!;
    final session = data.session!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${data.businessName} · ${data.outletName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.body.md.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          l10n.cashierContext(
            data.staffName,
            formatClock(session.openedAt, data.timezone),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

// --- Cari / scan --------------------------------------------------------------

class _SearchField extends StatefulWidget {
  const _SearchField({required this.viewModel, required this.compact});

  final CashierViewModel viewModel;
  final bool compact;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit(String text) {
    widget.viewModel.scan(text);
    _controller.clear();
    // Scanner berikutnya langsung masuk lagi ke kolom ini.
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final unknown = widget.viewModel.unknownCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        FTextField(
          key: const ValueKey('cashier-search'),
          hint: l10n.cashierSearchHint,
          focusNode: _focus,
          autofocus: !widget.compact,
          // Tablet/desktop: kolom tetap fokus saat produk atau tombol
          // keranjang diklik, agar scanner (keyboard) tidak kehilangan input.
          onTapOutside: widget.compact ? null : (_) {},
          textInputAction: TextInputAction.done,
          prefixBuilder: (context, style, _) => Padding(
            padding: const EdgeInsetsDirectional.only(start: 12),
            child: Icon(
              TablerIcons.scan,
              size: 18,
              color: theme.colors.mutedForeground,
            ),
          ),
          suffixBuilder: widget.compact
              ? null
              : (context, style, _) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: FBadge(
                    variant: .secondary,
                    child: Text(l10n.cashierScannerReady),
                  ),
                ),
          onSubmit: _submit,
          control: .managed(
            controller: _controller,
            onChange: (v) => widget.viewModel.setQuery(v.text),
          ),
        ),
        if (unknown != null)
          Text(
            l10n.cashierScanUnknown(unknown),
            key: const ValueKey('cashier-scan-unknown'),
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.destructive,
            ),
          ),
      ],
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories({required this.viewModel});

  final CashierViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: [
          ChoicePill(
            key: const ValueKey('cashier-category-all'),
            label: l10n.cashierAllCategories,
            selected: vm.categoryId == null,
            onTap: () => vm.setCategory(null),
          ),
          for (final c in vm.categories)
            ChoicePill(
              key: ValueKey('cashier-category-${c.id.uuid}'),
              label: c.name,
              selected: vm.categoryId == c.id,
              onTap: () => vm.setCategory(c.id),
            ),
        ],
      ),
    );
  }
}

// --- Produk -------------------------------------------------------------------

/// Teks stok produk: total stok, atau `null` untuk jasa/menu.
String? _stockText(BuildContext context, CatalogProduct p) => p.tracksStock
    ? AppLocalizations.of(context)
          .cashierStock(formatQty(context, p.totalStock))
    : null;

/// Harga di kartu produk: satu harga, atau "mulai Rp X" bila varian
/// berbeda harga (rentang penuh terlalu panjang untuk kartu).
String _tilePrice(BuildContext context, CatalogProduct p) {
  final prices = p.variants.map((v) => v.sellPrice).toSet();
  final low = formatMoney(context, prices.reduce((a, b) => a < b ? a : b));
  return prices.length == 1
      ? low
      : AppLocalizations.of(context).cashierPriceFrom(low);
}

Color _stockColor(BuildContext context, CatalogProduct p) {
  final colors = context.theme.colors;
  if (p.totalStock.milli <= 0) return colors.destructive;
  return p.isLowStock ? const Color(0xFFD08700) : colors.mutedForeground;
}

/// Menambah [product] ke keranjang; produk dengan beberapa varian/satuan
/// membuka dialog pilihan.
Future<void> _tapProduct(
  BuildContext context,
  CashierViewModel vm,
  CatalogProduct product,
) async {
  if (vm.tapProduct(product)) return;
  final options = vm.optionsFor(product);
  final picked = await showFDialog<SaleOption>(
    context: context,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      builder: (context, style) => _OptionPicker(
        product: product,
        options: options,
      ),
    ),
  );
  if (picked != null) vm.addOption(picked);
}

class _OptionPicker extends StatelessWidget {
  const _OptionPicker({required this.product, required this.options});

  final CatalogProduct product;
  final List<SaleOption> options;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Text(
            product.name,
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            l10n.cashierPickTitle,
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [
                  for (final (i, o) in options.indexed)
                    FButton(
                      key: ValueKey('cashier-option-$i'),
                      variant: .outline,
                      onPress: () => Navigator.of(context).pop(o),
                      child: Expanded(
                        child: Row(
                          spacing: 8,
                          children: [
                            Expanded(
                              child: Text(
                                o.label.isEmpty ? product.baseUnit : o.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              formatMoney(context, o.price),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          FButton(
            variant: .ghost,
            onPress: () => Navigator.of(context).pop(),
            child: Flexible(
              child: Text(l10n.cashierCancel, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.viewModel});

  final CatalogProduct product;
  final CashierViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final p = product;
    final stock = _stockText(context, p);
    return FTappable(
      key: ValueKey('cashier-product-${p.id.uuid}'),
      semanticsLabel: p.name,
      onPress: () => _tapProduct(context, viewModel, p),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.card,
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) => Center(
                    child: ProductThumb(
                      name: p.name,
                      size: c.biggest.shortestSide.clamp(32, 72),
                    ),
                  ),
                ),
              ),
              Text(
                p.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _tilePrice(context, p),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                stock ?? '—',
                style: theme.typography.body.xs.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _stockColor(context, p),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.viewModel});

  final CashierViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final products = viewModel.products;
    if (products.isEmpty) return _NoProducts(viewModel: viewModel);
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisExtent: 196,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) =>
          _ProductTile(product: products[i], viewModel: viewModel),
    );
  }
}

class _NoProducts extends StatelessWidget {
  const _NoProducts({required this.viewModel});

  final CashierViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final none = viewModel.data?.products.isEmpty ?? true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Text(
        none ? l10n.cashierNoProducts : l10n.cashierNoMatch,
        key: const ValueKey('cashier-no-products'),
        textAlign: TextAlign.center,
        style: theme.typography.body.sm.copyWith(
          color: theme.colors.mutedForeground,
        ),
      ),
    );
  }
}

// --- Keranjang ----------------------------------------------------------------

Future<void> _editQuantity(
  BuildContext context,
  CashierViewModel vm,
  int index,
) async {
  final line = vm.lines[index];
  final qty = await showFDialog<Qty>(
    context: context,
    builder: (context, style, animation) => FDialog(
      animation: animation,
      builder: (context, style) => _QuantityDialog(line: line),
    ),
  );
  if (qty != null) vm.setQuantity(index, qty);
}

class _QuantityDialog extends StatefulWidget {
  const _QuantityDialog({required this.line});

  final CartLine line;

  @override
  State<_QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<_QuantityDialog> {
  late String _text;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _text = formatQty(context, widget.line.quantity, grouped: false);
  }

  void _save() {
    final qty = parseQtyInput(context, _text);
    if (qty == null) return;
    Navigator.of(context).pop(qty);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            l10n.cashierQtyTitle,
            style: theme.typography.display.lg.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(widget.line.title, style: theme.typography.body.sm),
          FTextField(
            key: const ValueKey('cashier-qty-input'),
            label: Text(l10n.cashierQtyLabel(widget.line.unitName)),
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            inputFormatters: [
              QtyInputFormatter(decimal: qtyDecimalSeparator(context)),
            ],
            onSubmit: (_) => _save(),
            control: .managed(
              initial: TextEditingValue(
                text: _text,
                selection: TextSelection(
                  baseOffset: 0,
                  extentOffset: _text.length,
                ),
              ),
              onChange: (v) => _text = v.text,
            ),
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: FButton(
                  variant: .outline,
                  onPress: () => Navigator.of(context).pop(),
                  child: Flexible(
                    child: Text(
                      l10n.cashierCancel,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FButton(
                  key: const ValueKey('cashier-qty-save'),
                  onPress: _save,
                  child: Flexible(
                    child: Text(
                      l10n.cashierQtySave,
                      overflow: TextOverflow.ellipsis,
                    ),
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

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.buttonKey,
    required this.icon,
    required this.label,
    required this.onPress,
  });

  final Key buttonKey;
  final IconData icon;
  final String label;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 36,
    child: FButton.icon(
      key: buttonKey,
      variant: .outline,
      semanticsLabel: label,
      onPress: onPress,
      child: Icon(icon, size: 16),
    ),
  );
}

class _CartRow extends StatelessWidget {
  const _CartRow({
    super.key,
    required this.viewModel,
    required this.index,
    required this.line,
  });

  final CashierViewModel viewModel;
  final int index;
  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final muted = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );
    final tier = line.priced.tier;
    final k = 'cashier-line-${line.key}';
    return Padding(
      key: ValueKey(k),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  line.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  [
                    '${formatQty(context, line.quantity)} × '
                        '${formatMoney(context, line.priced.unitPrice)}',
                    line.unitName,
                    if (tier != null)
                      l10n.cashierTierNote(formatQty(context, tier.minQty)),
                  ].join(' · '),
                  style: muted,
                ),
              ],
            ),
          ),
          _QtyButton(
            buttonKey: ValueKey('$k-dec'),
            icon: TablerIcons.minus,
            label: l10n.cashierDecrease,
            onPress: () => viewModel.decrement(index),
          ),
          FTappable(
            key: ValueKey('$k-qty'),
            semanticsLabel: l10n.cashierQtyTitle,
            onPress: () => _editQuantity(context, viewModel, index),
            child: SizedBox(
              width: 36,
              child: Text(
                formatQty(context, line.quantity),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _QtyButton(
            buttonKey: ValueKey('$k-inc'),
            icon: TablerIcons.plus,
            label: l10n.cashierIncrease,
            onPress: () => viewModel.increment(index),
          ),
          SizedBox(
            width: 84,
            child: Text(
              formatMoney(context, line.priced.lineTotal),
              textAlign: TextAlign.end,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsBlock extends StatelessWidget {
  const _TotalsBlock({required this.viewModel});

  final CashierViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final t = viewModel.totals;
    Widget line(String label, String value, {bool strong = false, Key? key}) =>
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: strong
                    ? theme.typography.body.lg.copyWith(
                        fontWeight: FontWeight.w700,
                      )
                    : theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
              ),
            ),
            Text(
              value,
              key: key,
              style:
                  (strong ? theme.typography.body.lg : theme.typography.body.sm)
                      .copyWith(
                        fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
            ),
          ],
        );
    return Column(
      spacing: 6,
      children: [
        line(l10n.cashierSubtotal, formatMoney(context, t.subtotal)),
        if (t.tierDiscount.value > 0)
          line(
            l10n.cashierTierDiscount,
            '− ${formatMoney(context, t.tierDiscount)}',
            key: const ValueKey('cashier-tier-discount'),
          ),
        line(
          l10n.cashierTotal,
          formatMoney(context, t.total),
          strong: true,
          key: const ValueKey('cashier-total'),
        ),
      ],
    );
  }
}

/// Panel *Pesanan* (kanan di tablet/desktop, sheet bawah di ponsel).
class _OrderPanel extends StatelessWidget {
  const _OrderPanel({required this.viewModel, this.onPay});

  final CashierViewModel viewModel;

  /// Bawaan: [CashierViewModel.startPayment].
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final lines = vm.lines;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.cashierOrder,
                style: theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                l10n.cashierWalkIn,
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: lines.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.cashierCartEmpty,
                      key: const ValueKey('cashier-empty-cart'),
                      textAlign: TextAlign.center,
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: lines.length,
                  separatorBuilder: (context, _) =>
                      Container(height: 1, color: theme.colors.border),
                  itemBuilder: (context, i) => _CartRow(
                    key: ValueKey(lines[i].key),
                    viewModel: vm,
                    index: i,
                    line: lines[i],
                  ),
                ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.muted,
            border: Border(top: BorderSide(color: theme.colors.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                _TotalsBlock(viewModel: vm),
                Row(
                  spacing: 8,
                  children: [
                    FButton(
                      key: const ValueKey('cashier-clear'),
                      variant: .outline,
                      mainAxisSize: .min,
                      onPress: lines.isEmpty ? null : vm.clearCart,
                      child: Flexible(
                        child: Text(
                          l10n.cashierClear,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Expanded(
                      child: FButton(
                        key: const ValueKey('cashier-pay'),
                        onPress: lines.isEmpty
                            ? null
                            : (onPay ?? vm.startPayment),
                        child: Flexible(
                          child: Text(
                            l10n.cashierPayAmount(
                              formatMoney(context, vm.totals.total),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- Tata letak ---------------------------------------------------------------

class _WideCashier extends StatelessWidget {
  const _WideCashier({required this.viewModel, required this.panelWidth});

  final CashierViewModel viewModel;
  final double panelWidth;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                _ContextLine(viewModel: viewModel),
                _SearchField(viewModel: viewModel, compact: false),
                _Categories(viewModel: viewModel),
                Expanded(child: _ProductGrid(viewModel: viewModel)),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.card,
            border: Border(left: BorderSide(color: theme.colors.border)),
          ),
          child: SizedBox(
            width: panelWidth,
            child: _OrderPanel(viewModel: viewModel),
          ),
        ),
      ],
    );
  }
}

class _MobileProductRow extends StatelessWidget {
  const _MobileProductRow({required this.product, required this.viewModel});

  final CatalogProduct product;
  final CashierViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final p = product;
    final stock = _stockText(context, p);
    return FTappable(
      key: ValueKey('cashier-product-${p.id.uuid}'),
      semanticsLabel: p.name,
      onPress: () => _tapProduct(context, viewModel, p),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          spacing: 10,
          children: [
            ProductThumb(name: p.name, size: 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    [
                      priceRange(context, p.variants.map((v) => v.sellPrice)),
                      ?stock,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.xs.copyWith(
                      color: theme.colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox.square(
              dimension: 40,
              child: FButton.icon(
                variant: .outline,
                semanticsLabel: l10n.cashierIncrease,
                onPress: () => _tapProduct(context, viewModel, p),
                child: const Icon(TablerIcons.plus, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileCashier extends StatelessWidget {
  const _MobileCashier({required this.viewModel});

  final CashierViewModel viewModel;

  Future<void> _showOrder(BuildContext context) async {
    final pay = await showFSheet<bool>(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.85,
      builder: (context) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.theme.colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.85,
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) => _OrderPanel(
              viewModel: viewModel,
              onPay: () => Navigator.of(context).pop(true),
            ),
          ),
        ),
      ),
    );
    if (pay ?? false) viewModel.startPayment();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final products = vm.products;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              _ContextLine(viewModel: vm),
              _SearchField(viewModel: vm, compact: true),
              _Categories(viewModel: vm),
            ],
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? _NoProducts(viewModel: vm)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  separatorBuilder: (context, _) =>
                      Container(height: 1, color: theme.colors.border),
                  itemBuilder: (context, i) =>
                      _MobileProductRow(product: products[i], viewModel: vm),
                ),
        ),
        if (!vm.cartIsEmpty)
          DecoratedBox(
            key: const ValueKey('cashier-mobile-bar'),
            decoration: BoxDecoration(
              color: theme.colors.card,
              border: Border(top: BorderSide(color: theme.colors.border)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(
                    child: FTappable(
                      key: const ValueKey('cashier-view-order'),
                      semanticsLabel: l10n.cashierViewOrder,
                      onPress: () => _showOrder(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.cashierMobileSummary(
                              vm.lineCount,
                              formatQty(context, vm.itemQuantity),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                          Row(
                            spacing: 4,
                            children: [
                              Flexible(
                                child: Text(
                                  formatMoney(context, vm.totals.total),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.typography.body.lg.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Icon(
                                TablerIcons.chevronUp,
                                size: 16,
                                color: theme.colors.mutedForeground,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  FButton(
                    key: const ValueKey('cashier-pay'),
                    mainAxisSize: .min,
                    onPress: vm.startPayment,
                    child: Flexible(
                      child: Text(
                        l10n.cashierPay,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
