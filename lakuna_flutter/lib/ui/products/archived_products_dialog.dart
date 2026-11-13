import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_data/lakuna_data.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/catalog_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/format.dart';
import 'archived_products_view_model.dart';
import 'product_widgets.dart';
import 'product_form_view.dart' show productErrorMessage;

/// Dialog *Produk diarsipkan* (1.15, F1-07d). Hasil `true` bila ada produk
/// yang dipulihkan.
Future<bool> showArchivedProducts(
  BuildContext context,
  CatalogRepository repository,
) async =>
    await showFDialog<bool>(
      context: context,
      builder: (context, style, animation) => FDialog(
        animation: animation,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 520),
        builder: (context, style) =>
            ArchivedProductsDialog(repository: repository),
      ),
    ) ??
    false;

/// Pesan galat pemulihan: kode kembar menyebut produk pemakainya.
String archivedRestoreError(AppLocalizations l10n, Exception error) =>
    switch (error) {
      ProductCodesTaken(:final conflicts) when conflicts.isNotEmpty =>
        l10n.productsRestoreTaken(conflicts.first.takenBy),
      _ => productErrorMessage(l10n, error),
    };

class ArchivedProductsDialog extends StatefulWidget {
  const ArchivedProductsDialog({super.key, required this.repository});

  final CatalogRepository repository;

  @override
  State<ArchivedProductsDialog> createState() => _ArchivedProductsDialogState();
}

class _ArchivedProductsDialogState extends State<ArchivedProductsDialog> {
  late final _vm = ArchivedProductsViewModel(repository: widget.repository);

  @override
  void initState() {
    super.initState();
    _vm.load.execute();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final muted = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final products = _vm.products;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            key: const ValueKey('archived-products'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text(
                l10n.productsArchivedTitle,
                style: theme.typography.display.lg.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_vm.restoredName case final name?)
                FAlert(
                  key: const ValueKey('archived-restored'),
                  title: Text(l10n.productsRestored(name)),
                ),
              if (products == null)
                _vm.load.error
                    ? LoadFailedAlert(
                        message: l10n.productsLoadFailed,
                        onRetry: _vm.load.execute,
                      )
                    : const Center(child: FCircularProgress())
              else if (products.isEmpty)
                Text(
                  l10n.productsArchivedEmpty,
                  key: const ValueKey('archived-empty'),
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.mutedForeground,
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 420),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 10,
                      children: [
                        for (final p in products)
                          _Row(
                            product: p,
                            busy: _vm.restore.running,
                            error: _vm.errorFor(p.id),
                            onRestore: () => _vm.restore.execute(p.id),
                            muted: muted,
                          ),
                      ],
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.centerRight,
                child: FButton(
                  key: const ValueKey('archived-close'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(context).pop(_vm.changed),
                  child: Flexible(child: Text(l10n.productsArchivedClose)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.product,
    required this.busy,
    required this.error,
    required this.onRestore,
    required this.muted,
  });

  final CatalogProduct product;
  final bool busy;
  final Exception? error;
  final VoidCallback onRestore;
  final TextStyle muted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final details = [
      ?product.categoryName,
      if (product.tracksStock)
        l10n.productsArchivedStock(
          formatQty(context, product.totalStock),
          product.baseUnit,
        ),
    ];
    return Column(
      key: ValueKey('archived-${product.id.uuid}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4,
      children: [
        Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.body.sm.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (details.isNotEmpty)
                    Text(details.join(' · '), style: muted),
                ],
              ),
            ),
            FButton(
              key: ValueKey('archived-restore-${product.id.uuid}'),
              variant: .outline,
              size: .sm,
              mainAxisSize: .min,
              onPress: busy ? null : onRestore,
              prefix: const Icon(TablerIcons.restore),
              child: Flexible(child: Text(l10n.productsRestore)),
            ),
          ],
        ),
        if (error case final e?)
          Text(
            archivedRestoreError(l10n, e),
            key: ValueKey('archived-error-${product.id.uuid}'),
            style: theme.typography.body.xs.copyWith(
              color: theme.colors.destructive,
            ),
          ),
      ],
    );
  }
}
