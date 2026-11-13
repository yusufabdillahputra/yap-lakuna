import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/customers_repository.dart';
import '../../data/services/kuitansi_pdf.dart';
import '../../data/services/receipt_printer.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/result.dart';
import '../core/format.dart';
import '../products/product_widgets.dart';
import '../receipt/printer_labels.dart';
import '../receipt/receipt_paper_view.dart';
import 'customer_labels.dart';
import 'kuitansi_content.dart';
import 'kuitansi_view_model.dart';

/// Lebar minimum untuk pratinjau A5, struk, dan panel berdampingan.
const kuitansiWideWidth = 1100.0;

TextStyle _muted(BuildContext context) => context.theme.typography.body.xs
    .copyWith(color: context.theme.colors.mutedForeground);

/// Halaman kuitansi pembayaran piutang (1.20b).
class KuitansiScreen extends StatefulWidget {
  const KuitansiScreen({
    super.key,
    required this.repository,
    required this.printer,
    required this.paymentId,
    required this.onBack,
    this.copy = false,
  });

  final CustomersRepository repository;
  final ReceiptPrinter printer;
  final UuidValue paymentId;
  final bool copy;
  final VoidCallback onBack;

  @override
  State<KuitansiScreen> createState() => _KuitansiScreenState();
}

class _KuitansiScreenState extends State<KuitansiScreen> {
  late final _vm = KuitansiViewModel(
    repository: widget.repository,
    printer: widget.printer,
    paymentId: widget.paymentId,
    copy: widget.copy,
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
      final vm = _vm;
      final receipt = vm.receipt;
      final setup = vm.setup;
      if (receipt == null || setup == null) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              if (vm.error case final error?)
                LoadFailedAlert(
                  key: const ValueKey('kuitansi-error'),
                  message: customerErrorMessage(l10n, error),
                  onRetry: vm.load.execute,
                )
              else
                const Center(child: FCircularProgress()),
              Align(
                alignment: Alignment.centerLeft,
                child: FButton(
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: widget.onBack,
                  child: Text(l10n.kuitansiBack),
                ),
              ),
            ],
          ),
        );
      }
      final doc = kuitansiDocument(
        l10n,
        receipt: receipt,
        setup: setup,
        copy: vm.copy,
        showDetails: vm.showDetails,
        showBalance: vm.showBalance,
        city: vm.city,
      );
      final lines = layoutReceipt(
        kuitansiReceiptContent(
          l10n,
          receipt: receipt,
          setup: setup,
          copy: vm.copy,
          showDetails: vm.showDetails,
          showBalance: vm.showBalance,
        ),
        vm.paper,
      );
      final paperLabel = vm.paper == ReceiptPaper.mm58 ? '58 mm' : '80 mm';
      return LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= kuitansiWideWidth;
          final a5 = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              Text(l10n.kuitansiPreviewA5, style: _muted(context)),
              _A5Preview(doc: doc),
            ],
          );
          final thermal = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              Text(
                l10n.kuitansiPreviewThermal(paperLabel),
                style: _muted(context),
              ),
              ReceiptPaperView(
                lines: lines,
                paper: vm.paper,
                logo: vm.receiptLogo,
              ),
            ],
          );
          final panel = _Panel(
            viewModel: vm,
            paperLabel: paperLabel,
            onPrint: () => vm.format == KuitansiFormat.a5
                ? vm.printA5.execute(doc)
                : vm.printThermal.execute(lines),
            onShare: () => vm.format == KuitansiFormat.a5
                ? vm.shareA5.execute(doc)
                : vm.shareThermal.execute(lines),
          );
          final p = receipt.payment;
          return SingleChildScrollView(
            key: const ValueKey('kuitansi-scroll'),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                PageHeader(
                  leading: Text(
                    '${l10n.customersTitle} › ${receipt.customer.name} › '
                    '${l10n.kuitansiCrumb(p.number)}',
                    style: _muted(context),
                  ),
                  title: vm.copy
                      ? l10n.kuitansiCrumb(p.number)
                      : l10n.kuitansiSavedTitle,
                  subtitle: l10n.kuitansiSubtitle(
                    formatMoney(context, receipt.amount),
                    receipt.customer.name,
                    receipt.lines.length,
                  ),
                  action: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (!vm.copy)
                        FBadge(
                          key: const ValueKey('kuitansi-saved'),
                          variant: .secondary,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
                            children: [
                              const Icon(TablerIcons.check, size: 14),
                              Text(l10n.kuitansiSaved),
                            ],
                          ),
                        ),
                      FButton(
                        key: const ValueKey('kuitansi-back'),
                        variant: .outline,
                        mainAxisSize: .min,
                        onPress: widget.onBack,
                        prefix: const Icon(TablerIcons.chevronLeft),
                        child: Flexible(child: Text(l10n.kuitansiBack)),
                      ),
                    ],
                  ),
                ),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 16,
                    children: [
                      Expanded(flex: 44, child: a5),
                      Expanded(flex: 24, child: thermal),
                      Expanded(flex: 32, child: panel),
                    ],
                  )
                else ...[
                  panel,
                  if (vm.format == KuitansiFormat.a5) a5 else thermal,
                ],
              ],
            ),
          );
        },
      );
    },
  );
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.viewModel,
    required this.paperLabel,
    required this.onPrint,
    required this.onShare,
  });

  final KuitansiViewModel viewModel;
  final String paperLabel;
  final VoidCallback onPrint;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final failed = [
      vm.printA5.result,
      vm.shareA5.result,
      vm.printThermal.result,
      vm.shareThermal.result,
    ].whereType<Error<Object?>>().firstOrNull;
    final printed =
        vm.printThermal.completed && (vm.setup?.printer?.isDirect ?? false);
    return FCard(
      key: const ValueKey('kuitansi-panel'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  l10n.kuitansiPanelTitle,
                  style: theme.typography.display.lg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(l10n.kuitansiPanelSub, style: _muted(context)),
              ],
            ),
            FSelectTileGroup<KuitansiFormat>(
              key: const ValueKey('kuitansi-format'),
              label: Text(l10n.kuitansiFormat),
              control: .managedRadio(
                initial: vm.format,
                onChange: (s) {
                  if (s.isNotEmpty) vm.setFormat(s.first);
                },
              ),
              children: [
                FSelectTile<KuitansiFormat>(
                  key: const ValueKey('kuitansi-format-a5'),
                  title: Text(l10n.kuitansiFormatA5),
                  subtitle: Text(l10n.kuitansiFormatA5Hint),
                  value: KuitansiFormat.a5,
                ),
                FSelectTile<KuitansiFormat>(
                  key: const ValueKey('kuitansi-format-thermal'),
                  title: Text(l10n.kuitansiFormatThermal(paperLabel)),
                  subtitle: Text(l10n.kuitansiFormatThermalHint),
                  value: KuitansiFormat.thermal,
                ),
              ],
            ),
            FSwitch(
              key: const ValueKey('kuitansi-details'),
              label: Text(l10n.kuitansiShowDetails),
              value: vm.showDetails,
              onChange: vm.setShowDetails,
            ),
            FSwitch(
              key: const ValueKey('kuitansi-balance'),
              label: Text(l10n.kuitansiShowBalance),
              value: vm.showBalance,
              onChange: vm.setShowBalance,
            ),
            if (vm.format == KuitansiFormat.a5)
              FTextField(
                key: const ValueKey('kuitansi-city'),
                label: Text(l10n.kuitansiCity),
                description: Text(l10n.kuitansiCityHint),
                control: .managed(
                  initial: TextEditingValue(text: vm.city),
                  onChange: (v) => vm.setCity(v.text),
                ),
              ),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: FButton(
                    key: const ValueKey('kuitansi-print'),
                    onPress: vm.busy ? null : onPrint,
                    prefix: const Icon(TablerIcons.printer),
                    child: Flexible(
                      child: Text(
                        l10n.kuitansiPrint,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: FButton(
                    key: const ValueKey('kuitansi-share'),
                    variant: .outline,
                    onPress: vm.busy ? null : onShare,
                    prefix: const Icon(TablerIcons.share),
                    child: Flexible(
                      child: Text(
                        l10n.kuitansiShare,
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
                key: const ValueKey('kuitansi-failed'),
                variant: .destructive,
                title: Text(printerFailureMessage(l10n, vm.printFailure)),
              )
            else if (vm.savedPath case final path?)
              Text(
                l10n.kuitansiSavedPdf(path),
                key: const ValueKey('kuitansi-saved-path'),
                style: _muted(context),
              )
            else if (printed)
              Text(
                l10n.kuitansiPrinted,
                key: const ValueKey('kuitansi-printed'),
                style: _muted(context),
              ),
            Text(l10n.kuitansiReprintNote, style: _muted(context)),
          ],
        ),
      ),
    );
  }
}

/// Pratinjau kuitansi A5 di layar, sama tata letaknya dengan PDF.
class _A5Preview extends StatelessWidget {
  const _A5Preview({required this.doc});

  final KuitansiDocument doc;

  static const _ink = Color(0xFF18181B);
  static const _muted = Color(0xFF52525B);
  static const _rule = Color(0xFFD4D4D8);

  @override
  Widget build(BuildContext context) {
    TextStyle sans({
      double size = 12,
      FontWeight weight = FontWeight.w400,
      Color color = _ink,
      bool italic = false,
    }) => TextStyle(
      fontFamily: 'DM Sans',
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      decoration: TextDecoration.none,
    );
    TextStyle heading(double size) => TextStyle(
      fontFamily: 'Montserrat',
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: _ink,
      decoration: TextDecoration.none,
    );
    // Lebar kertas tetap; di layar sempit pratinjau diperkecil seperti
    // kertas, bukan ditata ulang.
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= _paperWidth
          ? _paper(sans, heading)
          : FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: _paperWidth,
                child: _paper(sans, heading),
              ),
            ),
    );
  }

  static const _paperWidth = 560.0;

  Widget _paper(
    TextStyle Function({
      double size,
      FontWeight weight,
      Color color,
      bool italic,
    })
    sans,
    TextStyle Function(double size) heading,
  ) {
    return DecoratedBox(
      key: const ValueKey('kuitansi-a5'),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFFE4E4E7)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(doc.storeName, style: heading(16)),
                      Text(doc.storeLine, style: sans(size: 10, color: _muted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 2,
                  children: [
                    Text(doc.title, style: heading(18)),
                    Text(doc.number, style: sans(size: 10, color: _muted)),
                    if (doc.banner case final b?)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: _ink),
                        ),
                        child: Text(
                          b,
                          style: sans(size: 10, weight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 2, color: _ink),
            const SizedBox(height: 14),
            for (final f in doc.fields)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 140,
                      child: Text(f.label, style: sans(color: _muted)),
                    ),
                    Expanded(
                      child: Text(
                        f.value,
                        style: sans(
                          weight: f.italic ? FontWeight.w500 : FontWeight.w600,
                          italic: f.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (doc.tableHead.length == 3) ...[
              const SizedBox(height: 10),
              for (final (i, row) in [doc.tableHead, ...doc.tableRows].indexed)
                DecoratedBox(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: _rule)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        for (final (c, cell) in row.indexed)
                          Expanded(
                            flex: c == 0 ? 5 : 3,
                            child: Text(
                              cell,
                              textAlign: c == 0
                                  ? TextAlign.start
                                  : TextAlign.end,
                              style: sans(
                                size: 11,
                                color: i == 0 ? _muted : _ink,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(doc.placeDate, style: sans(size: 11, color: _muted)),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: _ink, width: 1.6),
                  ),
                  child: Text(doc.amount, style: heading(18)),
                ),
                const Spacer(),
                SizedBox(
                  width: 140,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      Text(
                        doc.signName,
                        style: sans(weight: FontWeight.w600),
                      ),
                      Text(doc.signRole, style: sans(size: 11, color: _muted)),
                    ],
                  ),
                ),
              ],
            ),
            if (doc.footnote case final n?) ...[
              const SizedBox(height: 14),
              Text(n, style: sans(size: 11, color: _muted)),
            ],
          ],
        ),
      ),
    );
  }
}
