import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_client/lakuna_client.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/suppliers_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import '../products/product_widgets.dart' show LoadFailedAlert;
import '../purchases/purchase_labels.dart' show formatCalendarDate;
import 'supplier_labels.dart';
import 'supplier_purchases_view_model.dart';

const _tabular = [FontFeature.tabularFigures()];

/// Dialog *Riwayat pembelian* (1.21). Hasil = pembelian yang dipilih untuk
/// dibuka, `null` bila ditutup.
Future<UuidValue?> showSupplierPurchases(
  BuildContext context,
  SuppliersRepository repository,
  Supplier supplier,
) => showFDialog<UuidValue>(
  context: context,
  builder: (context, style, animation) => FDialog(
    animation: animation,
    constraints: const BoxConstraints(minWidth: 280, maxWidth: 560),
    builder: (context, style) =>
        _SupplierPurchases(repository: repository, supplier: supplier),
  ),
);

class _SupplierPurchases extends StatefulWidget {
  const _SupplierPurchases({required this.repository, required this.supplier});

  final SuppliersRepository repository;
  final Supplier supplier;

  @override
  State<_SupplierPurchases> createState() => _SupplierPurchasesState();
}

class _SupplierPurchasesState extends State<_SupplierPurchases> {
  late final _vm = SupplierPurchasesViewModel(
    repository: widget.repository,
    supplierId: widget.supplier.id,
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
      final theme = context.theme;
      final rows = _vm.rows;
      final body = theme.typography.body.sm.copyWith(fontFeatures: _tabular);
      final muted = theme.typography.body.xs.copyWith(
        color: theme.colors.mutedForeground,
      );
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('supplier-history'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                l10n.supplierHistoryTitle(widget.supplier.name),
                style: theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_vm.error case final error?)
                LoadFailedAlert(
                  message: supplierErrorMessage(l10n, error),
                  onRetry: _vm.load.execute,
                )
              else if (rows == null)
                const Center(child: FCircularProgress())
              else if (rows.isEmpty)
                Text(l10n.supplierHistoryEmpty, style: muted)
              else
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final r in rows)
                          FTappable(
                            key: ValueKey(
                              'supplier-history-${r.purchase.id.uuid}',
                            ),
                            onPress: () =>
                                Navigator.of(context).pop(r.purchase.id),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: theme.colors.border),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Row(
                                  spacing: 8,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              r.purchase.number,
                                              maxLines: 1,
                                              style: body.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            formatCalendarDate(
                                              r.purchase.purchasedOn,
                                            ),
                                            style: muted,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          formatMoney(
                                            context,
                                            Money(r.purchase.total),
                                          ),
                                          style: body,
                                        ),
                                        if (r.debt > Money.zero)
                                          Text(
                                            '${l10n.supplierColRest} '
                                            '${formatMoney(context, r.debt)}',
                                            style: muted.copyWith(
                                              color: theme.colors.destructive,
                                            ),
                                          )
                                        else
                                          Text(
                                            l10n.supplierHistoryPaid,
                                            style: muted,
                                          ),
                                      ],
                                    ),
                                    Icon(
                                      TablerIcons.chevronRight,
                                      size: 16,
                                      color: theme.colors.mutedForeground,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: FButton(
                  key: const ValueKey('supplier-history-close'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(context).pop(),
                  child: Text(l10n.supplierClose),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
