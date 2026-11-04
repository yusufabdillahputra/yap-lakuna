import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';

import '../../l10n/gen/app_localizations.dart';
import '../cashier/payment_view.dart' show tabularFigures;
import '../core/format.dart';
import '../products/product_widgets.dart' show LoadFailedAlert;
import '../receipt/receipt_content.dart' show percentLabel;
import 'fnb_rates_view_model.dart';
import 'settings_card.dart';

final _percentFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

/// Pengaturan › Pajak & service (F1-10): tarif service dan PB1 cabang.
class FnbRatesSection extends StatelessWidget {
  const FnbRatesSection({super.key, required this.viewModel});

  final FnbRatesViewModel viewModel;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final theme = context.theme;
      final vm = viewModel;
      if (!vm.load.completed) {
        if (vm.load.error) {
          return LoadFailedAlert(
            key: const ValueKey('fnb-rates-load-error'),
            message: l10n.fnbRatesLoadFailed,
            onRetry: vm.load.execute,
          );
        }
        return const Center(child: FCircularProgress());
      }
      final decimal = qtyDecimalSeparator(context);
      final rev = vm.revision;
      final preview = vm.preview;

      Widget field(
        String key,
        String label,
        String hint,
        int initial,
        bool invalid,
        String error,
        ValueChanged<String> onChange,
      ) => FTextField(
        key: ValueKey('$key-$rev'),
        label: Text(label),
        description: Text(hint),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          _percentFormatter,
          LengthLimitingTextInputFormatter(6),
        ],
        enabled: !vm.save.running,
        error: invalid ? Text(error) : null,
        control: .managed(
          initial: TextEditingValue(
            text: percentInput(initial, decimal: decimal),
          ),
          onChange: (v) => onChange(v.text),
        ),
      );

      Widget line(
        String label,
        Money amount, {
        bool bold = false,
        bool signed = false,
      }) {
        final style = bold
            ? theme.typography.body.sm.copyWith(fontWeight: FontWeight.w700)
            : theme.typography.body.sm;
        return Row(
          children: [
            Expanded(child: Text(label, style: style)),
            Text(
              signed
                  ? signedMoney(context, amount)
                  : formatMoney(context, amount),
              style: tabularFigures(style),
            ),
          ],
        );
      }

      return SettingsCard(
        title: l10n.fnbRatesTitle,
        subtitle: l10n.fnbRatesSubtitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 14,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 14,
              children: [
                SizedBox(
                  width: 240,
                  child: field(
                    'fnb-rates-service',
                    l10n.fnbRatesService,
                    l10n.fnbRatesServiceHint,
                    vm.service.value,
                    vm.serviceInvalid,
                    l10n.fnbRatesInvalidService,
                    vm.setService,
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: field(
                    'fnb-rates-tax',
                    l10n.fnbRatesTax,
                    l10n.fnbRatesTaxHint,
                    vm.tax.value,
                    vm.taxInvalid,
                    l10n.fnbRatesInvalidTax,
                    vm.setTax,
                  ),
                ),
              ],
            ),
            FSwitch(
              key: const ValueKey('fnb-rates-inclusive'),
              label: Text(l10n.fnbRatesInclusive),
              description: Text(l10n.fnbRatesInclusiveHint),
              enabled: !vm.save.running,
              value: vm.taxInclusive,
              onChange: vm.setTaxInclusive,
            ),
            Text(
              l10n.fnbRatesNote,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            DecoratedBox(
              key: const ValueKey('fnb-rates-preview'),
              decoration: BoxDecoration(
                color: theme.colors.muted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 4,
                  children: [
                    Text(
                      l10n.fnbRatesPreview,
                      style: theme.typography.body.xs.copyWith(
                        color: theme.colors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    line(l10n.diningSubtotal, preview.subtotal),
                    line(
                      l10n.diningService(
                        percentLabel(
                          l10n,
                          vm.serviceInvalid ? 0 : vm.service.value,
                        ),
                      ),
                      preview.service,
                    ),
                    line(
                      (vm.taxInclusive
                          ? l10n.diningTaxIncluded
                          : l10n.diningTax)(
                        percentLabel(l10n, vm.taxInvalid ? 0 : vm.tax.value),
                      ),
                      preview.tax,
                    ),
                    if (preview.rounding != Money.zero)
                      line(
                        l10n.cashierRounding,
                        preview.rounding,
                        signed: true,
                      ),
                    line(l10n.diningTotal, preview.total, bold: true),
                  ],
                ),
              ),
            ),
            if (vm.save.error)
              Text(
                l10n.fnbRatesSaveFailed,
                key: const ValueKey('fnb-rates-save-error'),
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.destructive,
                ),
              )
            else if (vm.saved)
              Text(
                l10n.fnbRatesSaved,
                key: const ValueKey('fnb-rates-saved'),
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: FButton(
                key: const ValueKey('fnb-rates-save'),
                mainAxisSize: .min,
                onPress: vm.canSave ? vm.save.execute : null,
                child: Flexible(child: Text(l10n.fnbRatesSave)),
              ),
            ),
          ],
        ),
      );
    },
  );
}
