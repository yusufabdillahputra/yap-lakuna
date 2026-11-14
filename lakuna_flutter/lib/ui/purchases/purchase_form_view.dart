import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../utils/result.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import '../core/photo_attach_field.dart';
import '../products/product_widgets.dart';
import 'purchase_form_view_model.dart';
import 'purchase_labels.dart';

const _tabular = [FontFeature.tabularFigures()];
const _newSupplier = '__new';

/// Form di bawah lebar ini memakai satu kolom dan kartu per baris.
const purchaseFormNarrowWidth = 520.0;

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

Widget _rpPrefix(BuildContext context, FTextFieldStyle style, Set<Object> _) =>
    Padding(
      padding: const EdgeInsetsDirectional.only(start: 12),
      child: Text(
        'Rp',
        style: context.theme.typography.body.sm.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
    );

/// Label satuan baris: dasar `karung`, konversi `dus (6)`.
String purchaseUnitLabel(BuildContext context, PurchaseUnitOption unit) =>
    unit.isBase
    ? unit.name
    : '${unit.name} (${formatQty(context, unit.factor)})';

/// Panel form *Pembelian baru* / *Draf* (1.19). [onReceived] dipanggil
/// setelah barang diterima; [onSaved] setelah draf disimpan atau dihapus.
class PurchaseFormPanel extends StatelessWidget {
  const PurchaseFormPanel({
    super.key,
    required this.viewModel,
    this.onReceived,
    this.onSaved,
    this.onDeleted,
  });

  final PurchaseFormViewModel viewModel;
  final ValueChanged<Purchase>? onReceived;
  final ValueChanged<Purchase>? onSaved;
  final VoidCallback? onDeleted;

  Future<void> _saveDraft() async {
    await viewModel.saveDraft.execute();
    if (viewModel.saveDraft.result case Ok(:final value)) onSaved?.call(value);
  }

  Future<void> _receive() async {
    await viewModel.receive.execute();
    if (viewModel.receive.result case Ok(:final value)) {
      onReceived?.call(value);
    }
  }

  Future<void> _delete() async {
    await viewModel.deleteDraft.execute();
    if (viewModel.deleteDraft.completed) onDeleted?.call();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = viewModel;
      if (vm.setup == null) {
        if (vm.error case final error?) {
          return LoadFailedAlert(
            key: const ValueKey('purchase-form-error'),
            message: purchaseErrorMessage(l10n, error),
            onRetry: vm.load.execute,
          );
        }
        return const Center(child: FCircularProgress());
      }
      return FCard(
        key: const ValueKey('purchase-form'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < purchaseFormNarrowWidth;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Text(
                          vm.isDraft
                              ? l10n.purchaseFormDraft(vm.number)
                              : l10n.purchaseFormNew(vm.number),
                          key: const ValueKey('purchase-form-title'),
                          style: theme.typography.display.lg.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (vm.isDraft)
                        FButton(
                          key: const ValueKey('purchase-delete-draft'),
                          variant: .ghost,
                          size: .sm,
                          mainAxisSize: .min,
                          onPress: vm.busy ? null : _delete,
                          prefix: const Icon(TablerIcons.trash),
                          child: Flexible(
                            child: Text(l10n.purchaseDeleteDraft),
                          ),
                        ),
                    ],
                  ),
                  _HeaderFields(viewModel: vm, narrow: narrow),
                  _InvoicePhotoField(viewModel: vm),
                  _Lines(viewModel: vm, narrow: narrow),
                  _ScanField(viewModel: vm),
                  if (vm.hasIssue(PurchaseField.lines))
                    Text(
                      l10n.purchaseErrLines,
                      key: const ValueKey('purchase-error-lines'),
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.destructive,
                      ),
                    ),
                  _PaymentAndTotals(viewModel: vm, narrow: narrow),
                  if (vm.actionError case final error?)
                    FAlert(
                      key: const ValueKey('purchase-action-error'),
                      variant: .destructive,
                      title: Text(purchaseErrorMessage(l10n, error)),
                    ),
                  if (vm.saveDraft.completed)
                    FAlert(
                      key: const ValueKey('purchase-draft-saved'),
                      title: Text(l10n.purchaseDraftSaved(vm.number)),
                    ),
                  Flex(
                    direction: narrow ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: narrow
                        ? CrossAxisAlignment.stretch
                        : CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                      FButton(
                        key: const ValueKey('purchase-save-draft'),
                        variant: .outline,
                        mainAxisSize: narrow ? .max : .min,
                        onPress: vm.busy ? null : _saveDraft,
                        child: Text(l10n.purchaseSaveDraft),
                      ),
                      _expandedIf(
                        !narrow,
                        FButton(
                          key: const ValueKey('purchase-receive'),
                          onPress: vm.busy ? null : _receive,
                          prefix: vm.receive.running
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: FCircularProgress(),
                                )
                              : const Icon(TablerIcons.packageImport),
                          child: Flexible(child: Text(l10n.purchaseReceive)),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    l10n.purchaseReceiveNote(vm.locationName ?? ''),
                    style: _muted(context),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

Widget _expandedIf(bool expand, Widget child) =>
    expand ? Expanded(child: child) : child;

/// Dua kolom (atau satu kolom di layar sempit).
class _Grid extends StatelessWidget {
  const _Grid({required this.narrow, required this.children});

  final bool narrow;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: children,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        for (var i = 0; i < children.length; i += 2)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Expanded(child: children[i]),
              Expanded(
                child: i + 1 < children.length
                    ? children[i + 1]
                    : const SizedBox(),
              ),
            ],
          ),
      ],
    );
  }
}

/// Lampiran foto faktur (F1-12b); tersimpan bersama pembelian.
class _InvoicePhotoField extends StatelessWidget {
  const _InvoicePhotoField({required this.viewModel});

  final PurchaseFormViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final error = vm.invoicePhotoRejected
        ? l10n.purchaseInvoicePhotoInvalid
        : vm.pickInvoicePhoto.error
        ? l10n.purchaseInvoicePhotoFailed
        : null;
    return Column(
      key: const ValueKey('purchase-invoice-photo-field'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        Text(
          l10n.purchaseInvoicePhoto,
          style: context.theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        PhotoAttachField(
          keyPrefix: 'purchase-invoice-photo',
          pickLabel: l10n.purchaseInvoicePhotoPick,
          cameraLabel: l10n.purchaseInvoicePhotoCamera,
          bytes: vm.invoicePhoto,
          // Nama berkas hanya untuk foto baru yang belum disimpan.
          fileName: vm.invoicePhotoUnsaved ? vm.invoicePhotoName : null,
          busy: vm.pickInvoicePhoto.running || vm.busy,
          canTakePhoto: vm.canTakePhoto,
          onPick: vm.pickInvoicePhoto.execute,
          onRemove: vm.removeInvoicePhoto,
          error: error,
        ),
        if (vm.invoicePhotoMissing)
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  l10n.purchaseInvoicePhotoMissing,
                  key: const ValueKey('purchase-invoice-photo-missing'),
                  style: _muted(context),
                ),
              ),
              FButton(
                key: const ValueKey('purchase-invoice-photo-clear'),
                variant: .ghost,
                size: .sm,
                mainAxisSize: .min,
                onPress: vm.busy ? null : vm.removeInvoicePhoto,
                child: Text(l10n.purchaseInvoicePhotoRemove),
              ),
            ],
          ),
      ],
    );
  }
}

class _HeaderFields extends StatelessWidget {
  const _HeaderFields({required this.viewModel, required this.narrow});

  final PurchaseFormViewModel viewModel;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final setup = vm.setup!;
    final gen = vm.generation;
    final supplierError = vm.hasIssue(PurchaseField.supplier)
        ? Text(l10n.purchaseErrSupplier)
        : null;
    final supplier = vm.newSupplier
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 4,
            children: [
              FTextField(
                key: ValueKey('purchase-supplier-name-$gen'),
                label: Text(l10n.purchaseSupplierNewName),
                autofocus: true,
                maxLength: PurchaseLimits.supplierName,
                error: supplierError,
                control: .managed(
                  initial: TextEditingValue(text: vm.newSupplierName),
                  onChange: (v) => vm.setNewSupplierName(v.text),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FButton(
                  key: const ValueKey('purchase-supplier-pick'),
                  variant: .ghost,
                  size: .sm,
                  mainAxisSize: .min,
                  onPress: () => vm.selectSupplier(null),
                  child: Text(l10n.purchaseSupplierPick),
                ),
              ),
            ],
          )
        : FSelect<String>(
            key: ValueKey('purchase-supplier-$gen-${setup.suppliers.length}'),
            label: Text(l10n.purchaseSupplier),
            forceErrorText: vm.hasIssue(PurchaseField.supplier)
                ? l10n.purchaseErrSupplier
                : null,
            items: {
              l10n.purchasesNoSupplier: '',
              for (final s in setup.suppliers) s.name: s.id.uuid,
              l10n.purchaseSupplierNew: _newSupplier,
            },
            control: .managed(
              initial: vm.supplierId?.uuid ?? '',
              onChange: (v) {
                if (v == _newSupplier) {
                  vm.useNewSupplier();
                } else {
                  vm.selectSupplier(
                    v == null || v.isEmpty ? null : UuidValue.fromString(v),
                  );
                }
              },
            ),
          );
    return _Grid(
      narrow: narrow,
      children: [
        supplier,
        FTextField(
          key: ValueKey('purchase-invoice-$gen'),
          label: Text(l10n.purchaseInvoiceNo),
          hint: 'SP/XI/0457',
          maxLength: PurchaseLimits.invoiceNo,
          error: vm.hasIssue(PurchaseField.invoiceNo)
              ? Text(l10n.purchaseErrInvoiceNo(PurchaseLimits.invoiceNo))
              : null,
          control: .managed(
            initial: TextEditingValue(text: vm.invoiceNo),
            onChange: (v) => vm.setInvoiceNo(v.text),
          ),
        ),
        FDateField.calendar(
          key: ValueKey('purchase-date-$gen'),
          label: Text(l10n.purchaseDate),
          clearable: false,
          format: (context, value, _) => formatCalendarDate(value),
          selectionControl: .managedSingle(
            initial: vm.purchasedOn,
            toggleable: false,
            onChange: (d) {
              if (d != null) vm.setPurchasedOn(d);
            },
          ),
        ),
        FSelect<String>(
          key: ValueKey('purchase-location-$gen'),
          label: Text(l10n.purchaseLocation),
          items: {for (final l in setup.locations) l.name: l.id.uuid},
          control: .managed(
            initial: vm.locationId?.uuid,
            onChange: (v) {
              if (v != null) vm.setLocation(UuidValue.fromString(v));
            },
          ),
        ),
      ],
    );
  }
}

class _Lines extends StatelessWidget {
  const _Lines({required this.viewModel, required this.narrow});

  final PurchaseFormViewModel viewModel;
  final bool narrow;

  static const _cols = [25, 18, 10, 22, 17];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    if (vm.lines.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            l10n.purchaseNoLines,
            key: const ValueKey('purchase-no-lines'),
            textAlign: TextAlign.center,
            style: _muted(context),
          ),
        ),
      );
    }
    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          for (final (i, line) in vm.lines.indexed)
            _LineCard(viewModel: vm, line: line, index: i),
        ],
      );
    }
    final head = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
      fontWeight: FontWeight.w600,
    );
    final labels = [
      l10n.purchaseColProduct,
      l10n.purchaseColUnit,
      l10n.purchaseColQty,
      l10n.purchaseColPrice,
      l10n.purchaseColSubtotal,
    ];
    return DecoratedBox(
      key: const ValueKey('purchase-lines'),
      decoration: BoxDecoration(
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
                spacing: 8,
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      flex: _cols[i],
                      child: Text(
                        labels[i],
                        style: head,
                        textAlign: i == 4 ? TextAlign.end : TextAlign.start,
                      ),
                    ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
          ),
          for (final (i, line) in vm.lines.indexed)
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.colors.border)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      flex: _cols[0],
                      child: _ProductName(line: line),
                    ),
                    Expanded(
                      flex: _cols[1],
                      child: _UnitSelect(viewModel: vm, line: line),
                    ),
                    Expanded(
                      flex: _cols[2],
                      child: _QtyField(viewModel: vm, line: line, index: i),
                    ),
                    Expanded(
                      flex: _cols[3],
                      child: _PriceField(viewModel: vm, line: line, index: i),
                    ),
                    Expanded(
                      flex: _cols[4],
                      child: Text(
                        formatMoney(context, line.lineTotal),
                        textAlign: TextAlign.end,
                        style: theme.typography.body.sm.copyWith(
                          fontFeatures: _tabular,
                        ),
                      ),
                    ),
                    _RemoveButton(viewModel: vm, line: line),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductName extends StatelessWidget {
  const _ProductName({required this.line});

  final PurchaseFormLine line;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final p = line.product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p.displayName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w600),
        ),
        if (p.sku ?? p.barcode case final code?)
          Text(
            code,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _muted(context),
          ),
      ],
    );
  }
}

class _UnitSelect extends StatelessWidget {
  const _UnitSelect({required this.viewModel, required this.line});

  final PurchaseFormViewModel viewModel;
  final PurchaseFormLine line;

  @override
  Widget build(BuildContext context) {
    final units = line.product.units;
    if (units.length == 1) {
      return Text(
        purchaseUnitLabel(context, line.unit),
        key: ValueKey('purchase-unit-${line.key}'),
        style: context.theme.typography.body.sm,
      );
    }
    final items = <String, String>{};
    for (final u in units) {
      var label = purchaseUnitLabel(context, u);
      for (var n = 2; items.containsKey(label); n++) {
        label = '${purchaseUnitLabel(context, u)} ($n)';
      }
      items[label] = u.productUnitId?.uuid ?? '';
    }
    return FSelect<String>(
      key: ValueKey('purchase-unit-${line.key}-${viewModel.generation}'),
      items: items,
      control: .managed(
        initial: line.unit.productUnitId?.uuid ?? '',
        onChange: (v) => viewModel.setUnit(
          line.key,
          v == null || v.isEmpty ? null : UuidValue.fromString(v),
        ),
      ),
    );
  }
}

class _QtyField extends StatelessWidget {
  const _QtyField({
    required this.viewModel,
    required this.line,
    required this.index,
  });

  final PurchaseFormViewModel viewModel;
  final PurchaseFormLine line;
  final int index;

  @override
  Widget build(BuildContext context) => FTextField(
    key: ValueKey('purchase-qty-${line.key}-${viewModel.generation}'),
    hint: '0',
    textAlign: TextAlign.end,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [QtyInputFormatter(decimal: qtyDecimalSeparator(context))],
    error: viewModel.hasIssue(PurchaseField.quantity, index)
        ? Text(AppLocalizations.of(context).purchaseErrQty)
        : null,
    control: .managed(
      initial: TextEditingValue(
        text: formatQty(context, line.quantity, grouped: false),
      ),
      onChange: (v) {
        if (parseQtyInput(context, v.text) case final q?) {
          viewModel.setQuantity(line.key, q);
        }
      },
    ),
  );
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.viewModel,
    required this.line,
    required this.index,
  });

  final PurchaseFormViewModel viewModel;
  final PurchaseFormLine line;
  final int index;

  @override
  Widget build(BuildContext context) => FTextField(
    key: ValueKey(
      'purchase-price-${line.key}-${line.priceRev}-${viewModel.generation}',
    ),
    hint: '0',
    textAlign: TextAlign.end,
    keyboardType: TextInputType.number,
    inputFormatters: const [RupiahInputFormatter()],
    prefixBuilder: _rpPrefix,
    error: viewModel.hasIssue(PurchaseField.price, index)
        ? Text(AppLocalizations.of(context).purchaseErrPrice)
        : null,
    control: .managed(
      initial: TextEditingValue(
        text: line.unitPrice.value == 0
            ? ''
            : groupThousands(line.unitPrice.value, '.'),
      ),
      onChange: (v) =>
          viewModel.setUnitPrice(line.key, parseSignedRupiah(v.text)),
    ),
  );
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.viewModel, required this.line});

  final PurchaseFormViewModel viewModel;
  final PurchaseFormLine line;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 32,
    child: Semantics(
      label: AppLocalizations.of(context).purchaseRemoveLine,
      button: true,
      child: FButton.icon(
        key: ValueKey('purchase-remove-${line.key}'),
        variant: .ghost,
        onPress: () => viewModel.removeLine(line.key),
        child: const Icon(TablerIcons.x, size: 16),
      ),
    ),
  );
}

class _LineCard extends StatelessWidget {
  const _LineCard({
    required this.viewModel,
    required this.line,
    required this.index,
  });

  final PurchaseFormViewModel viewModel;
  final PurchaseFormLine line;
  final int index;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return DecoratedBox(
      key: ValueKey('purchase-line-${line.key}'),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              children: [
                Expanded(child: _ProductName(line: line)),
                _RemoveButton(viewModel: viewModel, line: line),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Expanded(
                  child: _labeled(
                    context,
                    l10n.purchaseColUnit,
                    _UnitSelect(viewModel: viewModel, line: line),
                  ),
                ),
                Expanded(
                  child: _labeled(
                    context,
                    l10n.purchaseColQty,
                    _QtyField(viewModel: viewModel, line: line, index: index),
                  ),
                ),
              ],
            ),
            _labeled(
              context,
              l10n.purchaseColPrice,
              _PriceField(viewModel: viewModel, line: line, index: index),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(l10n.purchaseColSubtotal, style: _muted(context)),
                ),
                Text(
                  formatMoney(context, line.lineTotal),
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFeatures: _tabular,
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

Widget _labeled(BuildContext context, String label, Widget child) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  spacing: 4,
  children: [
    Text(label, style: _muted(context)),
    child,
  ],
);

/// *+ Scan / cari produk*: Enter menambah barcode/SKU persis (barcode
/// satuan konversi memilih satuannya) atau nama yang hanya cocok satu
/// varian; saran nama tampil saat mengetik.
class _ScanField extends StatefulWidget {
  const _ScanField({required this.viewModel});

  final PurchaseFormViewModel viewModel;

  @override
  State<_ScanField> createState() => _ScanFieldState();
}

class _ScanFieldState extends State<_ScanField> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  var _query = '';
  String? _notFound;

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
    });
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;
    if (widget.viewModel.addByCode(text) == PurchaseScanResult.notFound) {
      setState(() => _notFound = text.trim());
    } else {
      _clear();
    }
    // Tetap fokus agar pemindai bisa langsung memindai barang berikutnya.
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final suggestions = widget.viewModel.suggestions(_query);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        FTextField(
          key: const ValueKey('purchase-scan'),
          label: Text(l10n.purchaseScan),
          hint: l10n.purchaseScanHint,
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
              });
            },
          ),
          onSubmit: _submit,
        ),
        if (_notFound case final code?)
          Text(
            l10n.purchaseScanNotFound(code),
            key: const ValueKey('purchase-scan-not-found'),
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.destructive,
            ),
          ),
        if (suggestions.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final o in suggestions)
                ChoicePill(
                  key: ValueKey('purchase-suggest-${o.variantId.uuid}'),
                  label: o.displayName,
                  selected: false,
                  onTap: () {
                    widget.viewModel.addProduct(o.variantId);
                    _clear();
                  },
                ),
            ],
          ),
      ],
    );
  }
}

class _PaymentAndTotals extends StatelessWidget {
  const _PaymentAndTotals({required this.viewModel, required this.narrow});

  final PurchaseFormViewModel viewModel;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final gen = vm.generation;
    final totals = vm.totals;
    final debt = vm.debt;
    final payment = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        FTextField(
          key: ValueKey('purchase-paid-$gen'),
          label: Text(l10n.purchasePaidNow),
          hint: '0',
          keyboardType: TextInputType.number,
          inputFormatters: const [RupiahInputFormatter()],
          prefixBuilder: _rpPrefix,
          error: vm.hasIssue(PurchaseField.paid)
              ? Text(l10n.purchaseErrPaid)
              : null,
          control: .managed(
            initial: TextEditingValue(
              text: vm.paid.value == 0
                  ? ''
                  : groupThousands(vm.paid.value, '.'),
            ),
            onChange: (v) => vm.setPaid(parseSignedRupiah(v.text)),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FButton(
            key: const ValueKey('purchase-pay-full'),
            variant: .outline,
            size: .sm,
            mainAxisSize: .min,
            onPress: totals.total.value <= 0 ? null : vm.payInFull,
            child: Text(l10n.purchasePayInFull),
          ),
        ),
        if (vm.paid.value > 0) ...[
          FSelect<String>(
            key: ValueKey('purchase-funding-$gen'),
            label: Text(l10n.purchaseFundingFrom),
            items: {
              for (final k in FundingKind.values)
                if (k != FundingKind.drawer ||
                    (vm.setup?.canUseDrawer ?? false) ||
                    vm.funding == k)
                  fundingLabel(l10n, k): k.name,
            },
            control: .managed(
              initial: vm.funding.name,
              onChange: (v) {
                if (v != null) vm.setFunding(FundingKind.values.byName(v));
              },
            ),
          ),
          if (vm.funding == FundingKind.drawer &&
              !(vm.setup?.hasOpenSession ?? false))
            Text(
              l10n.purchaseErrDrawer,
              key: const ValueKey('purchase-drawer-hint'),
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.destructive,
              ),
            ),
        ],
        if (debt.value > 0)
          FDateField.calendar(
            key: ValueKey('purchase-due-$gen'),
            label: Text(l10n.purchaseDueOn),
            clearable: false,
            format: (context, value, _) => formatCalendarDate(value),
            forceErrorText: vm.hasIssue(PurchaseField.dueOn)
                ? l10n.purchaseErrDueOn
                : null,
            selectionControl: .managedSingle(
              initial: vm.dueOn,
              toggleable: false,
              onChange: (d) {
                if (d != null) vm.setDueOn(d);
              },
            ),
          ),
        FTextField(
          key: ValueKey('purchase-note-$gen'),
          label: Text(l10n.purchaseNote),
          maxLength: PurchaseLimits.note,
          error: vm.hasIssue(PurchaseField.note)
              ? Text(l10n.purchaseErrNote(PurchaseLimits.note))
              : null,
          control: .managed(
            initial: TextEditingValue(text: vm.note),
            onChange: (v) => vm.setNote(v.text),
          ),
        ),
      ],
    );
    final body = theme.typography.body.sm;
    Widget row(String label, Widget value, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Text(
              label,
              style: strong
                  ? body.copyWith(fontWeight: FontWeight.w700)
                  : body.copyWith(color: theme.colors.mutedForeground),
            ),
          ),
          value,
        ],
      ),
    );
    Text money(Money m, {Color? color, bool strong = true}) => Text(
      formatMoney(context, m),
      style: body.copyWith(
        fontWeight: strong ? FontWeight.w700 : null,
        fontFeatures: _tabular,
        color: color,
      ),
    );
    Widget amountField(
      String key,
      Money value,
      ValueChanged<Money> onChange, {
      String? error,
    }) => SizedBox(
      width: 150,
      child: FTextField(
        key: ValueKey('$key-$gen'),
        hint: '0',
        textAlign: TextAlign.end,
        keyboardType: TextInputType.number,
        inputFormatters: const [RupiahInputFormatter()],
        prefixBuilder: _rpPrefix,
        error: error == null ? null : Text(error),
        control: .managed(
          initial: TextEditingValue(
            text: value.value == 0 ? '' : groupThousands(value.value, '.'),
          ),
          onChange: (v) => onChange(parseSignedRupiah(v.text)),
        ),
      ),
    );
    final summary = Column(
      key: const ValueKey('purchase-totals'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row(l10n.purchaseSubtotal, money(totals.subtotal)),
        row(
          l10n.purchaseDiscount,
          amountField(
            'purchase-discount',
            vm.discount,
            vm.setDiscount,
            error: vm.hasIssue(PurchaseField.discount)
                ? l10n.purchaseErrDiscount
                : null,
          ),
        ),
        row(
          l10n.purchaseShipping,
          amountField('purchase-shipping', vm.shipping, vm.setShipping),
        ),
        Container(height: 1, color: theme.colors.border),
        row(l10n.purchaseTotal, money(totals.total), strong: true),
        row(
          l10n.purchaseDebtLeft,
          Text(
            formatMoney(context, debt),
            key: const ValueKey('purchase-debt'),
            style: body.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: _tabular,
              color: debt.value > 0 ? theme.colors.destructive : null,
            ),
          ),
        ),
      ],
    );
    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [summary, payment],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        Expanded(child: payment),
        Expanded(child: summary),
      ],
    );
  }
}
