import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart' show UuidValue;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:pdf/widgets.dart' as pw show Barcode;
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../data/services/barcode_label_pdf.dart';
import '../../data/services/receipt_printer.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/format.dart';
import '../receipt/printer_labels.dart';
import 'barcode_label_view_model.dart';
import 'product_widgets.dart';

/// Lebar minimum untuk daftar dan panel berdampingan.
const barcodeLabelWideWidth = 960.0;

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

/// Halaman *Cetak label barcode* (1.15b, F1-07e).
class BarcodeLabelScreen extends StatefulWidget {
  const BarcodeLabelScreen({
    super.key,
    required this.repository,
    required this.printer,
    required this.onBack,
    this.initialProduct,
  });

  final CatalogRepository repository;
  final ReceiptPrinter printer;
  final VoidCallback onBack;

  /// Produk yang barisnya sudah dipilih (dibuka dari form produk).
  final UuidValue? initialProduct;

  @override
  State<BarcodeLabelScreen> createState() => _BarcodeLabelScreenState();
}

class _BarcodeLabelScreenState extends State<BarcodeLabelScreen> {
  late final _vm = BarcodeLabelViewModel(
    repository: widget.repository,
    printer: widget.printer,
    initialProduct: widget.initialProduct,
  )..load.execute();

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BarcodeLabelView(viewModel: _vm, onBack: widget.onBack);
}

class BarcodeLabelView extends StatelessWidget {
  const BarcodeLabelView({
    super.key,
    required this.viewModel,
    required this.onBack,
  });

  final BarcodeLabelViewModel viewModel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final vm = viewModel;
      final back = FButton(
        key: const ValueKey('labels-back'),
        variant: .outline,
        mainAxisSize: .min,
        onPress: onBack,
        prefix: const Icon(TablerIcons.chevronLeft),
        child: Flexible(child: Text(l10n.labelsBack)),
      );
      if (!vm.loaded) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              if (vm.error != null)
                LoadFailedAlert(
                  key: const ValueKey('labels-load-error'),
                  message: l10n.productsLoadFailed,
                  onRetry: vm.load.execute,
                )
              else
                const Center(child: FCircularProgress()),
              Align(alignment: Alignment.centerLeft, child: back),
            ],
          ),
        );
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= barcodeLabelWideWidth;
          final list = _RowList(viewModel: vm);
          final panel = _Panel(viewModel: vm);
          final scroll = SingleChildScrollView(
            key: const ValueKey('labels-scroll'),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                PageHeader(
                  leading: Text(
                    '${l10n.productsTitle} › ${l10n.labelsTitle}',
                    style: _muted(context),
                  ),
                  title: l10n.labelsTitle,
                  subtitle: l10n.labelsSubtitle,
                  action: back,
                ),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      Expanded(flex: 60, child: list),
                      Expanded(flex: 40, child: panel),
                    ],
                  )
                else ...[
                  list,
                  panel,
                ],
              ],
            ),
          );
          if (wide || vm.total == 0) return scroll;
          // Ponsel: daftar panjang, jadi jumlah dan tombol cetak selalu
          // terlihat di bawah.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: scroll),
              _BottomBar(viewModel: vm),
            ],
          );
        },
      );
    },
  );
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.viewModel});

  final BarcodeLabelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    return DecoratedBox(
      key: const ValueKey('labels-bar'),
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Text(
                l10n.labelsTotal(vm.total, vm.pages),
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            FButton(
              key: const ValueKey('labels-bar-print'),
              mainAxisSize: .min,
              onPress: vm.canPrint
                  ? () => vm.print.execute(
                      vm.sheet((m) => formatMoney(context, m)),
                    )
                  : null,
              prefix: const Icon(TablerIcons.printer),
              child: Text(l10n.labelsPrint),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowList extends StatelessWidget {
  const _RowList({required this.viewModel});

  final BarcodeLabelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final rows = vm.visible;
    return FCard(
      key: const ValueKey('labels-list'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            FTextField(
              key: const ValueKey('labels-search'),
              hint: l10n.labelsSearch,
              prefixBuilder: (context, style, variants) => Padding(
                padding: const EdgeInsetsDirectional.only(start: 10),
                child: Icon(
                  TablerIcons.search,
                  size: 16,
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              control: .managed(
                initial: TextEditingValue(text: vm.query),
                onChange: (v) => vm.setQuery(v.text),
              ),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FSwitch(
                  key: const ValueKey('labels-selected-only'),
                  label: Text(l10n.labelsSelectedOnly(vm.selected.length)),
                  value: vm.selectedOnly,
                  onChange: vm.setSelectedOnly,
                ),
                FButton(
                  key: const ValueKey('labels-fill-stock'),
                  variant: .outline,
                  size: .sm,
                  mainAxisSize: .min,
                  prefix: const Icon(TablerIcons.packages),
                  onPress: vm.selected.isEmpty ? null : vm.fillFromStock,
                  child: Flexible(child: Text(l10n.labelsFillStock)),
                ),
              ],
            ),
            if (rows.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  l10n.labelsEmpty,
                  key: const ValueKey('labels-empty'),
                  textAlign: TextAlign.center,
                  style: _muted(context),
                ),
              )
            else
              for (final (i, r) in rows.indexed) ...[
                if (i > 0)
                  Container(height: 1, color: context.theme.colors.border),
                _RowTile(viewModel: vm, row: r),
              ],
          ],
        ),
      ),
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({required this.viewModel, required this.row});

  final BarcodeLabelViewModel viewModel;
  final LabelRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final r = row;
    final qty = vm.quantity(r);
    final selected = qty > 0;
    final note = switch (r) {
      LabelRow(code: null) => l10n.labelsNoCode,
      LabelRow(symbology: null) => l10n.labelsBadCode,
      LabelRow(:final code?) => code,
    };
    return Padding(
      key: ValueKey('labels-row-${r.key}'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Ponsel: stepper turun ke bawah nama agar nama dan harga terbaca.
          final stacked = constraints.maxWidth < 400;
          final stepper = selected
              ? _QtyStepper(viewModel: vm, row: r, quantity: qty)
              : null;
          final line = Row(
            spacing: 10,
            children: [
              FCheckbox(
                key: ValueKey('labels-check-${r.key}'),
                value: selected,
                enabled: r.printable,
                onChange: (v) => vm.toggle(r, v),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      r.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: r.printable
                            ? null
                            : theme.colors.mutedForeground,
                      ),
                    ),
                    Text(
                      '$note · ${formatMoney(context, r.price)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _muted(context),
                    ),
                  ],
                ),
              ),
              if (stepper != null && !stacked) stepper,
            ],
          );
          if (stepper == null || !stacked) return line;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 6,
            children: [line, stepper],
          );
        },
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.viewModel,
    required this.row,
    required this.quantity,
  });

  final BarcodeLabelViewModel viewModel;
  final LabelRow row;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final key = row.key;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        FButton.icon(
          key: ValueKey('labels-less-$key'),
          variant: .outline,
          size: .sm,
          semanticsLabel: l10n.labelsLess,
          onPress: quantity > 1 ? () => vm.step(row, -1) : null,
          child: const Icon(TablerIcons.minus),
        ),
        SizedBox(
          width: 64,
          child: FTextField(
            key: ValueKey('labels-qty-$key-${vm.revision(row)}'),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            control: .managed(
              initial: TextEditingValue(text: '$quantity'),
              onChange: (v) {
                if (int.tryParse(v.text) case final n?) {
                  vm.setQuantity(row, n);
                }
              },
            ),
          ),
        ),
        FButton.icon(
          key: ValueKey('labels-more-$key'),
          variant: .outline,
          size: .sm,
          semanticsLabel: l10n.labelsMore,
          onPress: quantity < BarcodeLabelViewModel.maxPerRow
              ? () => vm.step(row, 1)
              : null,
          child: const Icon(TablerIcons.plus),
        ),
      ],
    );
  }
}

String _paperSize(BarcodeLabelPaper paper) => switch (paper) {
  BarcodeLabelPaper.a4Sheet => 'A4',
  BarcodeLabelPaper.roll50x30 => '50 × 30 mm',
  BarcodeLabelPaper.roll38x25 => '38 × 25 mm',
};

class _Panel extends StatelessWidget {
  const _Panel({required this.viewModel});

  final BarcodeLabelViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    String price(Money m) => formatMoney(context, m);
    final failed = [
      vm.print.result,
      vm.save.result,
    ].whereType<Error<Object?>>().firstOrNull;
    return FCard(
      key: const ValueKey('labels-panel'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Text(
              l10n.labelsSettings,
              style: theme.typography.display.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            FSelectTileGroup<BarcodeLabelPaper>(
              key: const ValueKey('labels-paper'),
              label: Text(l10n.labelsPaper),
              control: .managedRadio(
                initial: vm.paper,
                onChange: (s) {
                  if (s.isNotEmpty) vm.setPaper(s.first);
                },
              ),
              children: [
                for (final p in BarcodeLabelPaper.values)
                  FSelectTile<BarcodeLabelPaper>(
                    key: ValueKey('labels-paper-${p.name}'),
                    title: Text(
                      p == BarcodeLabelPaper.a4Sheet
                          ? l10n.labelsPaperA4
                          : l10n.labelsPaperRoll(_paperSize(p)),
                    ),
                    subtitle: Text(
                      p == BarcodeLabelPaper.a4Sheet
                          ? l10n.labelsPaperA4Hint
                          : l10n.labelsPaperRollHint,
                    ),
                    value: p,
                  ),
              ],
            ),
            if (vm.paper == BarcodeLabelPaper.a4Sheet)
              FTextField(
                key: ValueKey('labels-skip-${vm.skipRevision}'),
                label: Text(l10n.labelsSkip),
                description: Text(l10n.labelsSkipHint),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                control: .managed(
                  initial: TextEditingValue(text: '${vm.skip}'),
                  onChange: (v) => vm.setSkip(int.tryParse(v.text) ?? 0),
                ),
              ),
            FSwitch(
              key: const ValueKey('labels-show-price'),
              label: Text(l10n.labelsShowPrice),
              value: vm.showPrice,
              onChange: vm.setShowPrice,
            ),
            Text(l10n.labelsPreview, style: _muted(context)),
            if (vm.preview case final row?)
              LabelPreview(
                key: const ValueKey('labels-preview'),
                paper: vm.paper,
                title: row.title,
                price: vm.showPrice ? price(row.price) : null,
                code: row.code!,
                symbology: row.symbology!,
              )
            else
              Text(
                l10n.labelsPreviewEmpty,
                key: const ValueKey('labels-preview-empty'),
                style: _muted(context),
              ),
            Text(
              l10n.labelsTotal(vm.total, vm.pages),
              key: const ValueKey('labels-total'),
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (vm.overLimit)
              FAlert(
                key: const ValueKey('labels-over-limit'),
                variant: .destructive,
                title: Text(
                  l10n.labelsOverLimit(BarcodeLabelViewModel.maxTotal),
                ),
              ),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: FButton(
                    key: const ValueKey('labels-print'),
                    onPress: vm.canPrint
                        ? () => vm.print.execute(vm.sheet(price))
                        : null,
                    prefix: const Icon(TablerIcons.printer),
                    child: Flexible(
                      child: Text(
                        l10n.labelsPrint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FButton(
                    key: const ValueKey('labels-save'),
                    variant: .outline,
                    onPress: vm.canPrint
                        ? () => vm.save.execute(vm.sheet(price))
                        : null,
                    prefix: const Icon(TablerIcons.fileDownload),
                    child: Flexible(
                      child: Text(
                        l10n.labelsSave,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (failed != null)
              FAlert(
                key: const ValueKey('labels-failed'),
                variant: .destructive,
                title: Text(printerFailureMessage(l10n, vm.printFailure)),
              )
            else if (vm.savedPath case final path? when vm.save.completed)
              Text(
                l10n.labelsSaved(path),
                key: const ValueKey('labels-saved'),
                style: _muted(context),
              ),
          ],
        ),
      ),
    );
  }
}

/// Pratinjau satu label di layar, sebanding dengan ukuran kertasnya.
class LabelPreview extends StatelessWidget {
  const LabelPreview({
    super.key,
    required this.paper,
    required this.title,
    required this.code,
    required this.symbology,
    this.price,
  });

  final BarcodeLabelPaper paper;
  final String title;
  final String? price;
  final String code;
  final BarcodeSymbology symbology;

  static const _ink = Color(0xFF18181B);

  @override
  Widget build(BuildContext context) {
    final (w, h) = switch (paper) {
      BarcodeLabelPaper.a4Sheet => (70.0, 37.125),
      BarcodeLabelPaper.roll50x30 => (50.0, 30.0),
      BarcodeLabelPaper.roll38x25 => (38.0, 25.0),
    };
    final barcode = switch (symbology) {
      BarcodeSymbology.ean13 => pw.Barcode.ean13(),
      BarcodeSymbology.ean8 => pw.Barcode.ean8(),
      BarcodeSymbology.upcA => pw.Barcode.upcA(),
      BarcodeSymbology.code128 => pw.Barcode.code128(),
    };
    // 4 px per mm: label A4 = 280 × 148 px.
    const scale = 4.0;
    return Center(
      child: Container(
        width: w * scale,
        height: h * scale,
        padding: const EdgeInsets.all(3 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(color: context.theme.colors.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _ink,
                height: 1.15,
              ),
            ),
            if (price case final price?)
              Text(
                price,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            const SizedBox(height: 2),
            Expanded(
              child: SvgPicture.string(
                barcode.toSvg(code, width: 200, height: 80),
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
