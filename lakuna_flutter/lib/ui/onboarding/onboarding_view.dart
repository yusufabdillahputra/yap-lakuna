import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_data/lakuna_data.dart' show SetupAlreadyDone;
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../app_root.dart';
import '../../data/repositories/backup_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../data/services/backup_files.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/breakpoints.dart';
import '../settings/app_settings_view_model.dart';
import '../settings/appearance_tiles.dart';
import '../../utils/result.dart';
import 'onboarding_view_model.dart';
import 'setup_restore_dialog.dart';

/// Layar 1.1 Setup toko pertama. Memiliki [OnboardingViewModel] sendiri
/// agar isian tidak hilang saat router membangun ulang rute.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.repository,
    required this.session,
    required this.settings,
    this.backup,
    this.backupFiles = const PlatformBackupFiles(),
  });

  final StoreRepository repository;
  final SessionRepository session;
  final AppSettingsViewModel settings;

  /// Pulihkan dari backup di langkah 1 (F1-19b); `null` = tombol disembunyikan.
  final BackupRepository? backup;
  final BackupFiles backupFiles;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final _viewModel = OnboardingViewModel(
    repository: widget.repository,
    session: widget.session,
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OnboardingView(
    viewModel: _viewModel,
    settings: widget.settings,
    onRestore: switch (widget.backup) {
      final backup? => () => showSetupRestore(
        context,
        repository: backup,
        files: widget.backupFiles,
        restart: AppRestart.maybeOf(context)?.restart,
      ),
      null => null,
    },
  );
}

/// Wizard 4 langkah. Tablet/desktop: panel Sky di kiri; mobile: progress
/// bar di atas.
class OnboardingView extends StatelessWidget {
  const OnboardingView({
    super.key,
    required this.viewModel,
    required this.settings,
    this.onRestore,
  });

  final OnboardingViewModel viewModel;
  final AppSettingsViewModel settings;

  /// Membuka *Pulihkan dari backup* (F1-19b).
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return ColoredBox(
      color: theme.colors.background,
      child: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([viewModel, viewModel.finish, settings]),
          builder: (context, _) => LayoutBuilder(
            builder: (context, constraints) {
              final mobile =
                  LayoutSize.of(constraints.maxWidth) == LayoutSize.mobile;
              final main = _MainArea(
                viewModel: viewModel,
                settings: settings,
                mobile: mobile,
                onRestore: onRestore,
              );
              if (mobile) return main;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SidePanel(viewModel: viewModel),
                  Expanded(child: main),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

String _stepLabel(AppLocalizations l10n, OnboardingStep step) => switch (step) {
  OnboardingStep.languageTheme => l10n.onboardingStepLanguage,
  OnboardingStep.business => l10n.onboardingStepBusiness,
  OnboardingStep.owner => l10n.onboardingStepOwner,
  OnboardingStep.summary => l10n.onboardingStepSummary,
};

String _stepTitle(AppLocalizations l10n, OnboardingStep step) => switch (step) {
  OnboardingStep.languageTheme => l10n.onboardingTitleLanguage,
  OnboardingStep.business => l10n.onboardingTitleBusiness,
  OnboardingStep.owner => l10n.onboardingTitleOwner,
  OnboardingStep.summary => l10n.onboardingTitleSummary,
};

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.viewModel});

  final OnboardingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final fg = theme.colors.primaryForeground;
    final bg = theme.colors.primary;
    return SizedBox(
      key: const ValueKey('onboarding-side-panel'),
      width: 340,
      child: ColoredBox(
        color: bg,
        // Bisa digulir bila layar pendek; catatan tetap di bawah bila muat.
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.onboardingWelcome,
                      style: theme.typography.body.sm.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.onboardingHeadline,
                      style: theme.typography.display.xl2.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 32),
                    for (final step in OnboardingStep.values)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _StepRow(
                          number: step.index + 1,
                          label: _stepLabel(l10n, step),
                          done: step.index < viewModel.step.index,
                          active: step == viewModel.step,
                          foreground: fg,
                          background: bg,
                        ),
                      ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    Text(
                      l10n.onboardingOfflineNote,
                      style: theme.typography.body.sm.copyWith(color: fg),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.label,
    required this.done,
    required this.active,
    required this.foreground,
    required this.background,
  });

  final int number;
  final String label;
  final bool done;
  final bool active;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final filled = done || active;
    return Row(
      spacing: 12,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? foreground : null,
            border: Border.all(color: foreground, width: 1.5),
          ),
          child: done
              ? Icon(TablerIcons.check, size: 16, color: background)
              : Text(
                  '$number',
                  style: theme.typography.body.sm.copyWith(
                    color: active ? background : foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        Expanded(
          child: Text(
            label,
            style: theme.typography.body.md.copyWith(
              color: foreground,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

class _MainArea extends StatelessWidget {
  const _MainArea({
    required this.viewModel,
    required this.settings,
    required this.mobile,
    this.onRestore,
  });

  final VoidCallback? onRestore;

  final OnboardingViewModel viewModel;
  final AppSettingsViewModel settings;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final padding = mobile ? 16.0 : 40.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.onboardingStepOf(
                        viewModel.stepNumber,
                        viewModel.stepCount,
                      ),
                      style: theme.typography.body.sm.copyWith(
                        color: theme.colors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _LanguageToggle(settings: settings),
                ],
              ),
              if (mobile)
                FDeterminateProgress(
                  value: viewModel.stepNumber / viewModel.stepCount,
                ),
              Text(
                _stepTitle(l10n, viewModel.step),
                style:
                    (mobile
                            ? theme.typography.display.xl
                            : theme.typography.display.xl3)
                        .copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: switch (viewModel.step) {
                  OnboardingStep.languageTheme => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 24,
                    children: [
                      AppearanceTiles(viewModel: settings),
                      if (onRestore case final restore?)
                        _RestoreCard(onPress: restore),
                    ],
                  ),
                  OnboardingStep.business => _BusinessStep(
                    viewModel: viewModel,
                  ),
                  OnboardingStep.owner => _OwnerStep(viewModel: viewModel),
                  OnboardingStep.summary => _SummaryStep(viewModel: viewModel),
                },
              ),
            ),
          ),
        ),
        _Footer(viewModel: viewModel, padding: padding, mobile: mobile),
      ],
    );
  }
}

/// Pindah perangkat: pasang backup, bukan membuat toko baru (F1-19b).
class _RestoreCard extends StatelessWidget {
  const _RestoreCard({required this.onPress});

  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return DecoratedBox(
      key: const ValueKey('onboarding-restore-card'),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.border),
        borderRadius: theme.style.borderRadius.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(
              l10n.onboardingRestoreHint,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
            FButton(
              key: const ValueKey('onboarding-restore'),
              variant: .outline,
              mainAxisSize: .min,
              onPress: onPress,
              prefix: const Icon(TablerIcons.restore),
              child: Flexible(child: Text(l10n.onboardingRestoreAction)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.settings});

  final AppSettingsViewModel settings;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 4,
    children: [
      for (final (code, label) in [('id', 'ID'), ('en', 'EN')])
        FButton(
          key: ValueKey('onboarding-lang-$code'),
          size: .sm,
          mainAxisSize: .min,
          variant: settings.locale.languageCode == code ? .primary : .ghost,
          onPress: () => settings.setLocale.execute(Locale(code)),
          child: Text(label),
        ),
    ],
  );
}

/// Galat validasi dalam bahasa pengguna.
String setupErrorText(AppLocalizations l10n, SetupError error) =>
    switch (error) {
      SetupError.required => l10n.errorRequired,
      SetupError.tooLong => l10n.errorTooLong,
      SetupError.invalidCode => l10n.errorInvalidCode,
      SetupError.invalidEmail => l10n.errorInvalidEmail,
      SetupError.passwordTooShort => l10n.errorPasswordTooShort,
      SetupError.passwordMismatch => l10n.errorPasswordMismatch,
      SetupError.invalidPin => l10n.errorInvalidPin,
      SetupError.pinMismatch => l10n.errorPinMismatch,
      SetupError.invalidTimezone => l10n.errorInvalidTimezone,
    };

class _Field extends StatelessWidget {
  const _Field({
    required this.viewModel,
    required this.field,
    required this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.maxLength,
    this.digitsOnly = false,
    this.code = false,
  });

  final OnboardingViewModel viewModel;
  final SetupField field;
  final String label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool digitsOnly;

  /// Kode cabang/perangkat: hanya huruf/angka, langsung huruf besar.
  final bool code;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = viewModel.errorFor(field);
    return FTextField(
      key: ValueKey('field-${field.name}'),
      label: Text(label),
      hint: hint,
      obscureText: obscure,
      keyboardType: keyboardType,
      maxLength: maxLength,
      textCapitalization: code ? .characters : .none,
      inputFormatters: [
        if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
        if (code) ...[
          FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
          const _UpperCaseFormatter(),
        ],
      ],
      error: error == null ? null : Text(setupErrorText(l10n, error)),
      control: .managed(
        initial: TextEditingValue(text: viewModel.value(field)),
        onChange: (value) => viewModel.setField(field, value.text),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  const _UpperCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}

/// Dua field per baris bila cukup lebar, satu per baris di layar sempit.
class _FieldGrid extends StatelessWidget {
  const _FieldGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 560) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: children,
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          for (var i = 0; i < children.length; i += 2)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
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
    },
  );
}

class _BusinessStep extends StatelessWidget {
  const _BusinessStep({required this.viewModel});

  final OnboardingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        FSelectTileGroup<BusinessKind>(
          key: const ValueKey('business-type'),
          label: Text(l10n.businessTypeLabel),
          control: .managedRadio(
            initial: viewModel.businessType,
            onChange: (selected) {
              if (selected.isNotEmpty) {
                viewModel.setBusinessType(selected.first);
              }
            },
          ),
          children: [
            for (final (kind, title, subtitle) in [
              (
                BusinessKind.retail,
                l10n.businessRetail,
                l10n.businessRetailDesc,
              ),
              (BusinessKind.fnb, l10n.businessFnb, l10n.businessFnbDesc),
              (BusinessKind.mixed, l10n.businessMixed, l10n.businessMixedDesc),
            ])
              FSelectTile<BusinessKind>(
                key: ValueKey('business-${kind.name}'),
                title: Text(title),
                subtitle: Text(subtitle),
                value: kind,
              ),
          ],
        ),
        _FieldGrid(
          children: [
            _Field(
              viewModel: viewModel,
              field: SetupField.businessName,
              label: l10n.fieldBusinessName,
              hint: 'Warung Contoh',
              maxLength: setupNameMaxLength,
            ),
            _Field(
              viewModel: viewModel,
              field: SetupField.outletName,
              label: l10n.fieldOutletName,
              hint: 'Cabang Pusat',
              maxLength: setupNameMaxLength,
            ),
            _Field(
              viewModel: viewModel,
              field: SetupField.outletCode,
              label: l10n.fieldOutletCode,
              hint: 'PST',
              maxLength: 6,
              code: true,
            ),
            _Field(
              viewModel: viewModel,
              field: SetupField.deviceCode,
              label: l10n.fieldDeviceCode,
              hint: 'K01',
              maxLength: 6,
              code: true,
            ),
            FSelect<String>(
              key: const ValueKey('field-timezone'),
              label: Text(l10n.fieldTimezone),
              items: {
                for (final z in setupTimezones)
                  '${z.label} (UTC+${z.utcOffsetHours})': z.id,
              },
              control: .managed(
                initial: viewModel.value(SetupField.timezone),
                onChange: (id) {
                  if (id != null) viewModel.setField(SetupField.timezone, id);
                },
              ),
            ),
          ],
        ),
        DecoratedBox(
          key: const ValueKey('receipt-preview'),
          decoration: BoxDecoration(
            color: theme.colors.secondary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  l10n.receiptPreviewLabel,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.secondaryForeground,
                  ),
                ),
                Text(
                  viewModel.receiptPreview,
                  style: theme.typography.body.lg.copyWith(
                    color: theme.colors.secondaryForeground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.receiptPreviewNote,
                  style: theme.typography.body.sm.copyWith(
                    color: theme.colors.secondaryForeground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OwnerStep extends StatelessWidget {
  const _OwnerStep({required this.viewModel});

  final OnboardingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        _FieldGrid(
          children: [
            _Field(
              viewModel: viewModel,
              field: SetupField.ownerName,
              label: l10n.fieldOwnerName,
              maxLength: setupNameMaxLength,
            ),
            _Field(
              viewModel: viewModel,
              field: SetupField.email,
              label: l10n.fieldEmail,
              hint: 'nama@contoh.id',
              keyboardType: TextInputType.emailAddress,
            ),
            _Field(
              viewModel: viewModel,
              field: SetupField.password,
              label: l10n.fieldPassword,
              obscure: true,
            ),
            _Field(
              viewModel: viewModel,
              field: SetupField.passwordConfirm,
              label: l10n.fieldPasswordConfirm,
              obscure: true,
            ),
            _Field(
              viewModel: viewModel,
              field: SetupField.pin,
              label: l10n.fieldPin,
              obscure: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              digitsOnly: true,
            ),
            _Field(
              viewModel: viewModel,
              field: SetupField.pinConfirm,
              label: l10n.fieldPinConfirm,
              obscure: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              digitsOnly: true,
            ),
          ],
        ),
        Text(
          l10n.ownerNote,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({required this.viewModel});

  final OnboardingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final input = viewModel.input;
    final business = switch (input.businessType) {
      BusinessKind.retail => l10n.businessRetail,
      BusinessKind.fnb => l10n.businessFnb,
      BusinessKind.mixed => l10n.businessMixed,
    };
    final timezone = setupTimezones.firstWhere((z) => z.id == input.timezone);
    final rows = [
      (l10n.summaryBusiness, '${input.businessName} · $business'),
      (l10n.summaryOutlet, '${input.outletName} (${input.outletCode})'),
      (l10n.summaryDevice, input.deviceCode),
      (l10n.fieldTimezone, timezone.label),
      (l10n.summaryOwner, '${input.ownerName} · ${input.email}'),
      (l10n.receiptPreviewLabel, viewModel.receiptPreview),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        if (viewModel.finish.error)
          FAlert(
            key: const ValueKey('setup-error'),
            variant: .destructive,
            title: Text(
              switch (viewModel.finish.result) {
                Error(error: SetupAlreadyDone()) => l10n.setupAlreadyDone,
                _ => l10n.setupFailed,
              },
            ),
          ),
        FCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                for (final (label, value) in rows)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.typography.body.sm.copyWith(
                          color: theme.colors.mutedForeground,
                        ),
                      ),
                      Text(value, style: theme.typography.body.md),
                    ],
                  ),
              ],
            ),
          ),
        ),
        Text(
          l10n.summaryNote,
          style: theme.typography.body.sm.copyWith(
            color: theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.viewModel,
    required this.padding,
    required this.mobile,
  });

  final OnboardingViewModel viewModel;
  final double padding;

  /// Di ponsel tombol ditumpuk selebar layar agar label tidak terpotong.
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final step = viewModel.step;
    final running = viewModel.finish.running;
    final nextLabel = switch (step) {
      OnboardingStep.languageTheme => l10n.buttonNextBusiness,
      OnboardingStep.business => l10n.buttonNextOwner,
      OnboardingStep.owner => l10n.buttonNextSummary,
      OnboardingStep.summary => l10n.buttonStartSelling,
    };
    final back = step == OnboardingStep.languageTheme
        ? null
        : FButton(
            key: const ValueKey('onboarding-back'),
            variant: .outline,
            onPress: running ? null : viewModel.back,
            child: Text(l10n.buttonBack),
          );
    final next = FButton(
      key: const ValueKey('onboarding-next'),
      onPress: running
          ? null
          : step == OnboardingStep.summary
          ? viewModel.finish.execute
          : viewModel.next,
      prefix: running ? const FCircularProgress() : null,
      child: Text(nextLabel),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colors.border)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
        child: mobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 8,
                children: [next, ?back],
              )
            : Row(
                spacing: 12,
                children: [
                  if (back != null) Expanded(child: back) else const Spacer(),
                  Expanded(flex: 2, child: next),
                ],
              ),
      ),
    );
  }
}
