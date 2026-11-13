import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../dining/kitchen_ticket.dart';
import '../products/product_widgets.dart' show ChoicePill;
import '../receipt/printer_device_row.dart';
import '../receipt/printer_labels.dart';
import 'kitchen_printer_view_model.dart';
import 'settings_card.dart';

/// Kartu *Printer dapur* (F1-10e) di Pengaturan › Struk & printer (1.26).
class KitchenPrinterCard extends StatelessWidget {
  const KitchenPrinterCard({
    super.key,
    required this.viewModel,
    required this.staffName,
    this.clock = DateTime.now,
  });

  final KitchenPrinterViewModel viewModel;
  final String staffName;
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => _build(context),
  );

  Widget _build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final kitchen = vm.kitchen;
    final busy = vm.busy;
    final muted = theme.typography.body.sm.copyWith(
      color: theme.colors.mutedForeground,
    );
    Widget spinner() =>
        const SizedBox.square(dimension: 16, child: FCircularProgress());

    if (!vm.loaded) {
      return SettingsCard(
        key: const ValueKey('kitchen-printer'),
        title: l10n.kitchenPrinterTitle,
        child: vm.load.error
            ? Text(l10n.receiptSettingsLoadError, style: muted)
            : const Center(child: FCircularProgress()),
      );
    }

    final body = switch (vm.kind) {
      null => Text(
        l10n.kitchenPrinterSameNote,
        key: const ValueKey('kitchen-printer-same-note'),
        style: muted,
      ),
      PrinterKind.bluetooth => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: FButton(
              key: const ValueKey('kitchen-printer-search'),
              variant: .outline,
              mainAxisSize: .min,
              onPress: busy ? null : vm.searchBluetooth.execute,
              prefix: vm.searchBluetooth.running
                  ? spinner()
                  : const Icon(TablerIcons.bluetooth),
              child: Flexible(
                child: Text(
                  l10n.printerSearch,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          for (final (i, p) in vm.bluetoothPrinters.indexed)
            PrinterDeviceRow(
              key: ValueKey('kitchen-printer-bt-$i'),
              title: p.name,
              subtitle: p.address,
              selected: p == kitchen?.printer,
              onChoose: busy ? null : () => vm.choose.execute(p),
            ),
          if (vm.bluetoothSearched && vm.bluetoothPrinters.isEmpty)
            Text(l10n.printerBluetoothEmpty, style: muted),
        ],
      ),
      PrinterKind.network || PrinterKind.system => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          FTextField(
            key: ValueKey('kitchen-printer-address-${vm.revision}'),
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
              key: const ValueKey('kitchen-printer-use-address'),
              variant: .outline,
              mainAxisSize: .min,
              onPress: busy ? null : vm.useNetworkAddress,
              child: Flexible(
                child: Text(
                  l10n.printerUseAddress,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    };

    return SettingsCard(
      key: const ValueKey('kitchen-printer'),
      title: l10n.kitchenPrinterTitle,
      subtitle: l10n.kitchenPrinterSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            key: const ValueKey('kitchen-printer-status'),
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Icon(
                TablerIcons.toolsKitchen2,
                size: 22,
                color: kitchen == null
                    ? theme.colors.mutedForeground
                    : theme.colors.primary,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    Text(
                      kitchen == null
                          ? l10n.kitchenPrinterSame
                          : printerSummary(
                              l10n,
                              kitchen.printer,
                              kitchen.paper,
                            ),
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (kitchen != null)
                      FButton(
                        key: const ValueKey('kitchen-printer-forget'),
                        variant: .outline,
                        size: .sm,
                        mainAxisSize: .min,
                        onPress: busy ? null : vm.forget.execute,
                        child: Flexible(
                          child: Text(
                            l10n.kitchenPrinterForget,
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
              ChoicePill(
                key: const ValueKey('kitchen-printer-kind-same'),
                label: l10n.kitchenPrinterSame,
                selected: vm.kind == null,
                onTap: () => vm.setKind(null),
              ),
              ChoicePill(
                key: const ValueKey('kitchen-printer-kind-network'),
                label: printerKindLabel(l10n, PrinterKind.network),
                selected: vm.kind == PrinterKind.network,
                onTap: () => vm.setKind(PrinterKind.network),
              ),
              if (vm.supportsBluetooth)
                ChoicePill(
                  key: const ValueKey('kitchen-printer-kind-bluetooth'),
                  label: printerKindLabel(l10n, PrinterKind.bluetooth),
                  selected: vm.kind == PrinterKind.bluetooth,
                  onTap: () => vm.setKind(PrinterKind.bluetooth),
                ),
            ],
          ),
          body,
          if (vm.kind != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  l10n.kitchenPaperWidth,
                  style: theme.typography.body.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final paper in ReceiptPaper.values)
                      ChoicePill(
                        key: ValueKey('kitchen-paper-${paper.name}'),
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
          if (kitchen != null) ...[
            const FDivider(),
            Align(
              alignment: Alignment.centerLeft,
              child: FButton(
                key: const ValueKey('kitchen-printer-test'),
                mainAxisSize: .min,
                onPress: vm.canTest
                    ? () => vm.testPrint.execute(
                        sampleKitchenTicketLines(
                          l10n,
                          paper: kitchen.paper,
                          staffName: staffName,
                          now: clock(),
                        ),
                      )
                    : null,
                prefix: vm.testPrint.running
                    ? spinner()
                    : const Icon(TablerIcons.printer),
                child: Flexible(
                  child: Text(
                    l10n.kitchenPrinterTest,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
          if (vm.failure != null)
            FAlert(
              key: const ValueKey('kitchen-printer-error'),
              variant: .destructive,
              title: Text(printerFailureMessage(l10n, vm.failure)),
            )
          else if (vm.choose.error || vm.forget.error)
            FAlert(
              key: const ValueKey('kitchen-printer-save-error'),
              variant: .destructive,
              title: Text(l10n.settingsSaveError),
            )
          else if (vm.testSent)
            FAlert(
              key: const ValueKey('kitchen-printer-test-sent'),
              icon: const Icon(TablerIcons.circleCheck),
              title: Text(l10n.kitchenPrinterTestSent),
            ),
        ],
      ),
    );
  }
}
