import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import 'bill_print_job.dart';
import 'printer_labels.dart';
import 'receipt_paper_view.dart';

/// Judul dan isi tagihan pada waktu cetak tertentu. Lebih dari satu
/// tagihan (semua tamu, F1-10r) ditampilkan berurutan dan dicetak sebagai
/// job terpisah.
typedef BillPrintPreview = ({
  String title,
  List<ReceiptContent> Function(DateTime now) bills,
});

/// Dialog pratinjau tagihan yang belum dibayar (F1-10k Meja, F1-10m tamu
/// split, F1-10r semua tamu): pratinjau kertas, **Tutup**, **Bagikan PDF**, **Cetak
/// tagihan**. [preview] dibaca ulang tiap [listenable] berubah; `null`
/// berarti tagihan tidak lagi berlaku dan dialog menutup sendiri. Pemanggil
/// mereset [job] sebelum membuka dialog. Kunci widget berawalan
/// [keyPrefix] (`dining-bill`, `split-bill`).
Future<void> showBillPrintDialog(
  BuildContext context, {
  required Listenable listenable,
  required BillPrintJob job,
  required String keyPrefix,
  required ReceiptPaper Function() paper,
  required Uint8List? Function() logo,
  required BillPrintPreview? Function(AppLocalizations l10n) preview,
}) => showFDialog<void>(
  context: context,
  builder: (context, style, animation) => FDialog(
    animation: animation,
    constraints: const BoxConstraints(minWidth: 280, maxWidth: 460),
    builder: (context, style) => ListenableBuilder(
      listenable: Listenable.merge([listenable, job]),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final current = preview(l10n);
        if (current == null) {
          // Tagihan tidak lagi berlaku: tutup dialog, jangan kosong.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            final route = ModalRoute.of(context);
            if (route == null || !route.isActive) return;
            // Bukan rute teratas (mis. dialog lain di atasnya): lepas rute
            // dialog ini saja, jangan pop rute lain.
            // `pop` sinkron: callback berikutnya di frame yang sama melihat
            // rute ini sudah tidak aktif, jadi tidak ada pop ganda.
            if (route.isCurrent) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).removeRoute(route);
            }
          });
          return const SizedBox.shrink();
        }
        // Waktu cetak diambil saat tombol ditekan, bukan saat dialog dibuka.
        List<List<ReceiptLine>> build() => [
          for (final bill in current.bills(DateTime.now()))
            layoutReceipt(bill, paper()),
        ];
        final bills = build();
        void startPrint() {
          final all = build();
          all.length == 1
              ? job.printBill.execute(all.single)
              : job.printBills.execute(all);
        }

        void startShare() {
          final all = build();
          all.length == 1
              ? job.shareBill.execute(all.single)
              : job.shareBills.execute(all);
        }

        final busy = job.running;
        ValueKey<String> key(String name) => ValueKey('$keyPrefix-$name');
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: key('dialog'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                current.title,
                style: context.theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 16,
                    children: [
                      for (final lines in bills)
                        Center(
                          child: ReceiptPaperView(
                            lines: lines,
                            paper: paper(),
                            logo: logo(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (job.printError)
                FAlert(
                  key: key('print-error'),
                  variant: .destructive,
                  title: Text(printerFailureMessage(l10n, job.printFailure)),
                )
              else if (job.printed)
                FAlert(key: key('printed'), title: Text(l10n.receiptPrinted)),
              if (job.shareError)
                FAlert(
                  key: key('share-error'),
                  variant: .destructive,
                  title: Text(l10n.diningBillShareFailed),
                )
              else if (job.pdfPath case final path?)
                FAlert(
                  key: key('pdf-saved'),
                  title: Text(l10n.receiptPdfSaved(path)),
                ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  FButton(
                    key: key('close'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: () => Navigator.of(context).pop(),
                    child: Flexible(child: Text(l10n.historyClose)),
                  ),
                  FButton(
                    key: key('share'),
                    variant: .outline,
                    mainAxisSize: .min,
                    onPress: busy ? null : startShare,
                    prefix: const Icon(TablerIcons.share),
                    child: Flexible(child: Text(l10n.receiptShare)),
                  ),
                  FButton(
                    key: key('print'),
                    mainAxisSize: .min,
                    onPress: busy ? null : startPrint,
                    prefix: const Icon(TablerIcons.printer),
                    child: Flexible(child: Text(l10n.diningPrintBill)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  ),
);
