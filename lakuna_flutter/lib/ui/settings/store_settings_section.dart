import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/store_settings_repository.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../utils/command.dart';
import '../../utils/result.dart';
import '../products/product_widgets.dart' show LoadFailedAlert;
import 'settings_card.dart';
import 'store_settings_view_model.dart';

final _phoneFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9+\- ]'));

String _issueLabel(AppLocalizations l10n, ProfileIssue issue) =>
    switch (issue) {
      ProfileIssue.required => l10n.errorRequired,
      ProfileIssue.tooLong => l10n.errorTooLong,
      ProfileIssue.invalidPhone => l10n.storeSettingsPhoneInvalid,
    };

/// Bagian *Profil toko*, *Cabang ini*, atau *Penjualan & stok* (1.26).
enum StoreSettingsPart { business, outlet, rules }

class StoreSettingsSection extends StatelessWidget {
  const StoreSettingsSection({
    super.key,
    required this.viewModel,
    required this.part,
  });

  final StoreSettingsViewModel viewModel;
  final StoreSettingsPart part;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final l10n = AppLocalizations.of(context);
      final vm = viewModel;
      final profile = vm.profile;
      if (vm.load.error && profile == null) {
        return LoadFailedAlert(
          key: const ValueKey('store-settings-load-error'),
          message: l10n.storeSettingsLoadFailed,
          onRetry: vm.load.execute,
        );
      }
      if (profile == null) return const Center(child: FCircularProgress());
      return switch (part) {
        StoreSettingsPart.business => _business(context, l10n, vm, profile),
        StoreSettingsPart.outlet => _outlet(context, l10n, vm, profile),
        StoreSettingsPart.rules => _rules(context, l10n, vm),
      };
    },
  );

  Widget _business(
    BuildContext context,
    AppLocalizations l10n,
    StoreSettingsViewModel vm,
    StoreProfile p,
  ) {
    final timezone = setupTimezones
        .where((z) => z.id == p.timezone)
        .firstOrNull;
    return SettingsCard(
      title: l10n.storeSettingsBusinessTitle,
      subtitle: l10n.storeSettingsBusinessSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          _field(
            key: 'store-business-name',
            label: l10n.storeSettingsBusinessName,
            initial: vm.businessName,
            revision: vm.revision,
            maxLength: ProfileLimits.name,
            issue: vm.businessIssue,
            enabled: !vm.saveBusiness.running,
            onChange: vm.setBusinessName,
            l10n: l10n,
          ),
          _readOnly(
            context,
            l10n.storeSettingsBusinessType,
            switch (p.businessType.name) {
              'fnb' => l10n.businessFnb,
              'mixed' => l10n.businessMixed,
              _ => l10n.businessRetail,
            },
          ),
          _readOnly(
            context,
            l10n.fieldTimezone,
            timezone == null ? p.timezone : '${timezone.label} · ${p.timezone}',
          ),
          _note(context, l10n.storeSettingsBusinessNote),
          _footer(
            context,
            l10n,
            command: vm.saveBusiness,
            keyPrefix: 'store-business',
            saved: l10n.storeSettingsBusinessSaved,
            canSave: vm.businessDirty,
          ),
        ],
      ),
    );
  }

  Widget _outlet(
    BuildContext context,
    AppLocalizations l10n,
    StoreSettingsViewModel vm,
    StoreProfile p,
  ) {
    final issues = vm.outletIssues;
    final busy = vm.saveOutlet.running;
    return SettingsCard(
      title: l10n.storeSettingsOutletTitle,
      subtitle: l10n.storeSettingsOutletSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          _field(
            key: 'store-outlet-name',
            label: l10n.storeSettingsOutletName,
            initial: vm.outletName,
            revision: vm.revision,
            maxLength: ProfileLimits.name,
            issue: issues[OutletProfileField.name],
            enabled: !busy,
            onChange: vm.setOutletName,
            l10n: l10n,
          ),
          _field(
            key: 'store-outlet-address',
            label: l10n.storeSettingsAddress,
            initial: vm.address,
            revision: vm.revision,
            maxLength: ProfileLimits.address,
            maxLines: 3,
            issue: issues[OutletProfileField.address],
            enabled: !busy,
            onChange: vm.setAddress,
            l10n: l10n,
          ),
          _field(
            key: 'store-outlet-phone',
            label: l10n.storeSettingsPhone,
            initial: vm.phone,
            revision: vm.revision,
            maxLength: ProfileLimits.phone,
            keyboardType: TextInputType.phone,
            formatter: _phoneFormatter,
            issue: issues[OutletProfileField.phone],
            enabled: !busy,
            onChange: vm.setPhone,
            l10n: l10n,
          ),
          Wrap(
            spacing: 24,
            runSpacing: 8,
            children: [
              _readOnly(context, l10n.storeSettingsOutletCode, p.outletCode),
              _readOnly(context, l10n.storeSettingsDeviceCode, p.deviceCode),
            ],
          ),
          _note(context, l10n.storeSettingsOutletNote),
          _footer(
            context,
            l10n,
            command: vm.saveOutlet,
            keyPrefix: 'store-outlet',
            saved: l10n.storeSettingsOutletSaved,
            canSave: vm.outletDirty,
          ),
        ],
      ),
    );
  }

  Widget _rules(
    BuildContext context,
    AppLocalizations l10n,
    StoreSettingsViewModel vm,
  ) {
    final busy = vm.saveRules.running;
    return SettingsCard(
      title: l10n.storeSettingsRulesTitle,
      subtitle: l10n.storeSettingsRulesSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          FSwitch(
            key: const ValueKey('store-rules-negative'),
            label: Text(l10n.storeSettingsNegativeStock),
            description: Text(l10n.storeSettingsNegativeStockHint),
            enabled: !busy,
            value: vm.rules.allowNegativeStock,
            onChange: vm.setAllowNegativeStock,
          ),
          FSwitch(
            key: const ValueKey('store-rules-discount-pin'),
            label: Text(l10n.storeSettingsDiscountPin),
            description: Text(l10n.storeSettingsDiscountPinHint),
            enabled: !busy,
            value: vm.rules.discountNeedsPin,
            onChange: vm.setDiscountNeedsPin,
          ),
          FSwitch(
            key: const ValueKey('store-rules-session'),
            label: Text(l10n.storeSettingsRequireSession),
            description: Text(l10n.storeSettingsRequireSessionHint),
            value: true,
            enabled: false,
            onChange: (_) {},
          ),
          FTileGroup(
            label: Text(l10n.storeSettingsRounding),
            description: Text(l10n.storeSettingsRoundingHint),
            children: [
              for (final (r, label) in [
                (TotalRounding.none, l10n.storeSettingsRoundingNone),
                (TotalRounding.nearest100, l10n.storeSettingsRounding100),
                (TotalRounding.nearest500, l10n.storeSettingsRounding500),
              ])
                FTile(
                  key: ValueKey('store-rules-rounding-${r.name}'),
                  title: Text(label),
                  selected: vm.rules.rounding == r,
                  suffix: vm.rules.rounding == r
                      ? const Icon(TablerIcons.check)
                      : null,
                  onPress: busy ? null : () => vm.setRounding(r),
                ),
            ],
          ),
          _footer(
            context,
            l10n,
            command: vm.saveRules,
            keyPrefix: 'store-rules',
            saved: l10n.storeSettingsRulesSaved,
            canSave: vm.rulesDirty,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String key,
    required String label,
    required String initial,
    required int revision,
    required int maxLength,
    required ProfileIssue? issue,
    required bool enabled,
    required ValueChanged<String> onChange,
    required AppLocalizations l10n,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextInputFormatter? formatter,
  }) => FTextField(
    key: ValueKey('$key-$revision'),
    label: Text(label),
    maxLength: maxLength,
    minLines: 1,
    maxLines: maxLines,
    keyboardType: keyboardType,
    inputFormatters: [?formatter],
    enabled: enabled,
    error: issue == null ? null : Text(_issueLabel(l10n, issue)),
    control: .managed(
      initial: TextEditingValue(text: initial),
      onChange: (v) => onChange(v.text),
    ),
  );

  Widget _readOnly(BuildContext context, String label, String value) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          label,
          style: theme.typography.body.xs.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
        Text(
          value,
          style: theme.typography.body.sm.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _note(BuildContext context, String text) => Text(
    text,
    style: context.theme.typography.body.sm.copyWith(
      color: context.theme.colors.mutedForeground,
    ),
  );

  Widget _footer(
    BuildContext context,
    AppLocalizations l10n, {
    required Command<Object?> command,
    required String keyPrefix,
    required String saved,
    required bool canSave,
  }) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        if (command.result case Error(:final error)
            when error is! StoreSettingsFormInvalid)
          Text(
            l10n.storeSettingsSaveFailed,
            key: ValueKey('$keyPrefix-error'),
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.destructive,
            ),
          )
        else if (command.completed)
          Text(
            saved,
            key: ValueKey('$keyPrefix-saved'),
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.mutedForeground,
            ),
          ),
        Align(
          alignment: Alignment.centerRight,
          child: FButton(
            key: ValueKey('$keyPrefix-save'),
            mainAxisSize: .min,
            onPress: canSave && !command.running
                ? (command as Command0).execute
                : null,
            child: Flexible(child: Text(l10n.storeSettingsSave)),
          ),
        ),
      ],
    );
  }
}
