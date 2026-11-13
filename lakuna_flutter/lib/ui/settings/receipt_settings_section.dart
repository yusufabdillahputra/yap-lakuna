import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../products/product_widgets.dart' show ChoicePill;
import '../receipt/printer_device_row.dart';
import '../receipt/printer_labels.dart';
import '../receipt/receipt_content.dart';
import '../receipt/receipt_paper_view.dart';
import 'kitchen_printer_card.dart';
import 'kitchen_printer_view_model.dart';
import 'receipt_settings_view_model.dart';
import 'settings_card.dart';

/// Pengaturan › Struk & printer (1.26, F1-06): printer perangkat ini, struk
/// cabang ini, dan pratinjau.
class ReceiptSettingsSection extends StatelessWidget {
  const ReceiptSettingsSection({
    super.key,
    required this.viewModel,
    required this.businessName,
    required this.outletName,
    required this.staffName,
    this.kitchen,
    this.clock = DateTime.now,
  });

  final ReceiptSettingsViewModel viewModel;

  /// Kartu *Printer dapur* (F1-10e); `null` tanpa modul meja.
  final KitchenPrinterViewModel? kitchen;
  final String businessName;
  final String outletName;
  final String staffName;

  /// Jam untuk tanggal struk contoh (tes memakai jam tetap).
  final DateTime Function() clock;

  List<ReceiptLine> _sampleLines(AppLocalizations l10n) => layoutReceipt(
    sampleReceiptContent(
      l10n,
      businessName: businessName,
      outletName: outletName,
      staffName: staffName,
      config: viewModel.previewConfig,
      now: clock(),
    ),
    viewModel.paper,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        if (!vm.loaded) {
          return vm.load.error
              ? FAlert(
                  key: const ValueKey('receipt-settings-load-error'),
                  variant: .destructive,
                  title: Text(l10n.receiptSettingsLoadError),
                )
              : const Center(child: FCircularProgress());
        }
        final lines = _sampleLines(l10n);
        return LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 720;
            final actions = _Actions(viewModel: vm);
            final preview = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Text(
                  l10n.receiptPreviewTitle,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Center(
                  child: ReceiptPaperView(
                    key: const ValueKey('receipt-preview'),
                    lines: lines,
                    paper: vm.paper,
                    logo: vm.previewLogo,
                  ),
                ),
              ],
            );
            final printerCard = _PrinterCard(viewModel: vm, lines: lines);
            final receiptCard = _ReceiptCard(
              viewModel: vm,
              preview: wide ? preview : null,
            );
            return Column(
              key: const ValueKey('receipt-settings'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 12,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            l10n.settingsSectionReceipt,
                            style: theme.typography.display.xl2,
                          ),
                          Text(
                            l10n.settingsBranchScope(outletName),
                            style: theme.typography.body.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (wide) SizedBox(width: 240, child: actions),
                  ],
                ),
                if (vm.saved)
                  FAlert(
                    key: const ValueKey('receipt-settings-saved'),
                    icon: const Icon(TablerIcons.circleCheck),
                    title: Text(l10n.receiptSettingsSaved),
                  ),
                if (vm.save.error && vm.errors.isEmpty)
                  FAlert(
                    key: const ValueKey('receipt-settings-error'),
                    variant: .destructive,
                    title: Text(l10n.settingsSaveError),
                  ),
                printerCard,
                if (kitchen case final k?)
                  KitchenPrinterCard(
                    viewModel: k,
                    staffName: staffName,
                    clock: clock,
                  ),
                receiptCard,
                if (!wide) ...[preview, actions],
              ],
            );
          },
        );
      },
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.viewModel});

  final ReceiptSettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: FButton(
            key: const ValueKey('receipt-settings-cancel'),
            variant: .outline,
            onPress: vm.save.running ? null : vm.cancel,
            child: Flexible(
              child: Text(
                l10n.receiptSettingsCancel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        Expanded(
          child: FButton(
            key: const ValueKey('receipt-settings-save'),
            onPress: vm.canSave ? vm.save.execute : null,
            prefix: vm.save.running
                ? const SizedBox.square(
                    dimension: 16,
                    child: FCircularProgress(),
                  )
                : null,
            child: Flexible(
              child: Text(
                l10n.receiptSettingsSave,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrinterCard extends StatelessWidget {
  const _PrinterCard({required this.viewModel, required this.lines});

  final ReceiptSettingsViewModel viewModel;
  final List<ReceiptLine> lines;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final printer = vm.printer;
    final busy = vm.printerBusy;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    Widget spinner() =>
        const SizedBox.square(dimension: 16, child: FCircularProgress());

    final body = switch (vm.kind) {
      PrinterKind.bluetooth => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FButton(
              key: const ValueKey('printer-search'),
              variant: .outline,
              mainAxisSize: .min,
              onPress: busy ? null : vm.searchBluetooth.execute,
              prefix: vm.searchBluetooth.running
                  ? spinner()
                  : const Icon(TablerIcons.bluetooth),
              child: Text(l10n.printerSearch),
            ),
          ),
          for (final (i, p) in vm.bluetoothPrinters.indexed)
            PrinterDeviceRow(
              key: ValueKey('printer-bt-$i'),
              title: p.name,
              subtitle: p.address,
              selected: p == printer,
              onChoose: busy ? null : () => vm.choosePrinter.execute(p),
            ),
          if (vm.bluetoothSearched && vm.bluetoothPrinters.isEmpty)
            Text(
              l10n.printerBluetoothEmpty,
              key: const ValueKey('printer-bt-empty'),
              style: muted,
            ),
        ],
      ),
      PrinterKind.network => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          FTextField(
            key: ValueKey('printer-address-${vm.revision}'),
            label: Text(l10n.printerAddress),
            description: Text(l10n.printerAddressHint),
            error: vm.networkAddressInvalid
                ? Text(l10n.printerAddressInvalid)
                : null,
            keyboardType: TextInputType.url,
            control: .managed(
              initial: TextEditingValue(text: vm.networkAddress),
              onChange: (v) => vm.setNetworkAddress(v.text),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FButton(
              key: const ValueKey('printer-use-address'),
              variant: .outline,
              mainAxisSize: .min,
              onPress: busy ? null : vm.useNetworkAddress,
              child: Text(l10n.printerUseAddress),
            ),
          ),
        ],
      ),
      PrinterKind.system => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Text(l10n.printerSystemNote, style: muted),
          if (printer?.kind != PrinterKind.system)
            Align(
              alignment: Alignment.centerLeft,
              child: FButton(
                key: const ValueKey('printer-use-system'),
                variant: .outline,
                mainAxisSize: .min,
                onPress: busy ? null : vm.useSystemDialog,
                child: Text(l10n.printerUseSystem),
              ),
            ),
        ],
      ),
    };

    return SettingsCard(
      title: l10n.receiptDeviceTitle,
      subtitle: l10n.receiptDeviceSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            key: const ValueKey('printer-status'),
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Icon(
                TablerIcons.printer,
                size: 22,
                color: printer == null
                    ? theme.colors.mutedForeground
                    : theme.colors.primary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      printer == null
                          ? l10n.receiptPrinterNone
                          : printerSummary(l10n, printer, vm.paper),
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (printer != null)
                      FButton(
                        key: const ValueKey('printer-forget'),
                        variant: .outline,
                        size: .sm,
                        mainAxisSize: .min,
                        onPress: busy ? null : vm.forgetPrinter.execute,
                        child: Flexible(
                          child: Text(
                            l10n.printerForget,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final kind in PrinterKind.values)
                if (kind != PrinterKind.bluetooth || vm.supportsBluetooth)
                  ChoicePill(
                    key: ValueKey('printer-kind-${kind.name}'),
                    label: printerKindLabel(l10n, kind),
                    selected: kind == vm.kind,
                    onTap: () => vm.setKind(kind),
                  ),
            ],
          ),
          if (!vm.supportsBluetooth)
            Text(
              l10n.printerBluetoothUnsupported,
              key: const ValueKey('printer-bt-unsupported'),
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          body,
          const FDivider(),
          Align(
            alignment: Alignment.centerLeft,
            child: FButton(
              key: const ValueKey('printer-test'),
              mainAxisSize: .min,
              onPress: busy ? null : () => vm.testPrint.execute(lines),
              prefix: vm.testPrint.running
                  ? spinner()
                  : const Icon(TablerIcons.printer),
              child: Text(l10n.printerTest),
            ),
          ),
          if (vm.printerFailure != null)
            FAlert(
              key: const ValueKey('printer-error'),
              variant: .destructive,
              title: Text(printerFailureMessage(l10n, vm.printerFailure)),
            )
          else if (vm.testSent)
            FAlert(
              key: const ValueKey('printer-test-sent'),
              icon: const Icon(TablerIcons.circleCheck),
              title: Text(l10n.printerTestSent),
            ),
        ],
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  const _ReceiptCard({required this.viewModel, this.preview});

  final ReceiptSettingsViewModel viewModel;

  /// Pratinjau di samping isian (layar lebar).
  final Widget? preview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final errors = vm.errors;
    Widget? error(ReceiptSettingsError many, ReceiptSettingsError long) =>
        errors.contains(many)
        ? Text(l10n.receiptTooManyLines)
        : errors.contains(long)
        ? Text(l10n.receiptLineTooLong)
        : null;
    final r = vm.revision;
    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(
              l10n.receiptPaperWidth,
              style: context.theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final paper in ReceiptPaper.values)
                  ChoicePill(
                    key: ValueKey('receipt-paper-${paper.name}'),
                    label: l10n.receiptPaperOption(
                      paper == ReceiptPaper.mm58 ? 58 : 80,
                      paper.columns,
                    ),
                    selected: paper == vm.paper,
                    onTap: () => vm.setPaper(paper),
                  ),
              ],
            ),
          ],
        ),
        FTextField(
          key: ValueKey('receipt-header-$r'),
          label: Text(l10n.receiptHeader),
          description: Text(l10n.receiptHeaderHint),
          minLines: 2,
          maxLines: 5,
          error: error(
            ReceiptSettingsError.headerTooManyLines,
            ReceiptSettingsError.headerLineTooLong,
          ),
          control: .managed(
            initial: TextEditingValue(text: vm.headerText),
            onChange: (v) => vm.setHeader(v.text),
          ),
        ),
        FTextField(
          key: ValueKey('receipt-footer-$r'),
          label: Text(l10n.receiptFooter),
          description: Text(l10n.receiptFooterHint),
          minLines: 2,
          maxLines: 5,
          error: error(
            ReceiptSettingsError.footerTooManyLines,
            ReceiptSettingsError.footerLineTooLong,
          ),
          control: .managed(
            initial: TextEditingValue(
              text: vm.footerText ?? l10n.receiptThanks,
            ),
            onChange: (v) => vm.setFooter(v.text),
          ),
        ),
        _LogoField(viewModel: vm),
        FSwitch(
          key: const ValueKey('receipt-auto-print'),
          label: Text(l10n.receiptAutoPrint),
          description: Text(l10n.receiptAutoPrintHint),
          value: vm.autoPrint,
          onChange: vm.setAutoPrint,
        ),
      ],
    );
    return SettingsCard(
      title: l10n.receiptOutletTitle,
      child: preview == null
          ? form
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Expanded(child: form),
                SizedBox(width: 280, child: preview),
              ],
            ),
    );
  }
}

/// Logo struk (F1-06b): kotak pratinjau, pilih/ganti/hapus, sakelar tampil.
class _LogoField extends StatelessWidget {
  const _LogoField({required this.viewModel});

  final ReceiptSettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final preview = vm.logoPreview;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(
          l10n.receiptLogo,
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w600),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Container(
              key: const ValueKey('receipt-logo-box'),
              width: 96,
              height: 64,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                border: Border.all(color: theme.colors.border),
                borderRadius: BorderRadius.circular(8),
              ),
              child: preview == null
                  ? Icon(
                      TablerIcons.photo,
                      color: theme.colors.mutedForeground,
                    )
                  : Image.memory(
                      preview,
                      fit: BoxFit.contain,
                      cacheWidth: 200,
                      errorBuilder: (_, _, _) => Icon(
                        TablerIcons.photoOff,
                        color: theme.colors.mutedForeground,
                      ),
                    ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FButton(
                        key: const ValueKey('receipt-logo-pick'),
                        variant: .outline,
                        size: .sm,
                        mainAxisSize: .min,
                        onPress: vm.pickLogo.running || vm.save.running
                            ? null
                            : vm.pickLogo.execute,
                        prefix: const Icon(TablerIcons.photo),
                        child: Flexible(
                          child: Text(
                            vm.hasLogo
                                ? l10n.receiptLogoChange
                                : l10n.receiptLogoPick,
                          ),
                        ),
                      ),
                      if (vm.hasLogo)
                        FButton(
                          key: const ValueKey('receipt-logo-remove'),
                          variant: .ghost,
                          size: .sm,
                          mainAxisSize: .min,
                          onPress: vm.save.running ? null : vm.removeLogo,
                          prefix: const Icon(TablerIcons.trash),
                          child: Flexible(child: Text(l10n.receiptLogoRemove)),
                        ),
                    ],
                  ),
                  if (vm.logoError case final error?)
                    Text(
                      switch (error) {
                        ReceiptLogoError.unsupported =>
                          l10n.receiptLogoUnsupported,
                        ReceiptLogoError.tooLarge => l10n.receiptLogoTooLarge,
                      },
                      key: const ValueKey('receipt-logo-error'),
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.destructive,
                      ),
                    )
                  else if (vm.hasLogo && preview == null)
                    Text(l10n.receiptLogoMissing, style: muted)
                  else
                    Text(l10n.receiptLogoHint, style: muted),
                ],
              ),
            ),
          ],
        ),
        FSwitch(
          key: const ValueKey('receipt-show-logo'),
          label: Text(l10n.receiptShowLogo),
          value: vm.showLogo,
          onChange: vm.hasLogo ? vm.setShowLogo : null,
        ),
      ],
    );
  }
}
