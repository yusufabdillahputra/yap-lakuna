import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../data/repositories/payment_settings_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../data/services/image_file_picker.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/breakpoints.dart';
import '../products/product_widgets.dart' show ChoicePill;
import 'app_settings_view_model.dart';
import 'payment_settings_view_model.dart';
import 'qris_settings_section.dart';
import 'settings_view.dart';

/// Bagian layar Pengaturan (1.26). Bagian lain menyusul bersama modulnya.
enum SettingsSection { payments, appearance }

/// Layar Pengaturan: navigasi bagian (kolom kiri di layar lebar, pil di
/// layar sempit) dan isi bagian. *Metode pembayaran* hanya untuk staf
/// dengan `settings:manage`.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.paymentSettings,
    required this.imagePicker,
    required this.session,
    required this.store,
  });

  final AppSettingsViewModel settings;
  final PaymentSettingsRepository paymentSettings;
  final ImageFilePicker imagePicker;
  final SessionRepository session;
  final StoreRepository store;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final bool _canManage =
      widget.session.current?.can(Permission.settingsManage) ?? false;
  late SettingsSection _section = _canManage
      ? SettingsSection.payments
      : SettingsSection.appearance;
  PaymentSettingsViewModel? _payments;

  @override
  void initState() {
    super.initState();
    if (_canManage) {
      _payments = PaymentSettingsViewModel(
        repository: widget.paymentSettings,
        picker: widget.imagePicker,
      )..load.execute();
    }
  }

  @override
  void dispose() {
    _payments?.dispose();
    super.dispose();
  }

  List<SettingsSection> get _sections => [
    if (_canManage) SettingsSection.payments,
    SettingsSection.appearance,
  ];

  String _label(AppLocalizations l10n, SettingsSection s) => switch (s) {
    SettingsSection.payments => l10n.settingsSectionPayments,
    SettingsSection.appearance => l10n.settingsSectionAppearance,
  };

  IconData _icon(SettingsSection s) => switch (s) {
    SettingsSection.payments => TablerIcons.creditCard,
    SettingsSection.appearance => TablerIcons.palette,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final content = switch (_section) {
      SettingsSection.payments => QrisSettingsSection(
        viewModel: _payments!,
        outletName: widget.store.current?.outlet.name ?? '',
      ),
      SettingsSection.appearance => SettingsView(viewModel: widget.settings),
    };
    return LayoutBuilder(
      builder: (context, c) {
        final wide =
            LayoutSize.of(c.maxWidth) != LayoutSize.mobile && c.maxWidth >= 900;
        if (_sections.length == 1) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: content,
          );
        }
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 220,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 4,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: Text(
                          l10n.settingsTitle,
                          style: theme.typography.display.xl2,
                        ),
                      ),
                      for (final s in _sections)
                        FTappable(
                          key: ValueKey('settings-section-${s.name}'),
                          selected: s == _section,
                          semanticsLabel: _label(l10n, s),
                          onPress: () => setState(() => _section = s),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: s == _section
                                  ? theme.colors.secondary
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 9,
                              ),
                              child: Row(
                                spacing: 10,
                                children: [
                                  Icon(_icon(s), size: 18),
                                  Expanded(
                                    child: Text(
                                      _label(l10n, s),
                                      style: theme.typography.body.sm.copyWith(
                                        fontWeight: s == _section
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: content,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in _sections)
                    ChoicePill(
                      key: ValueKey('settings-section-${s.name}'),
                      label: _label(l10n, s),
                      selected: s == _section,
                      onTap: () => setState(() => _section = s),
                    ),
                ],
              ),
              content,
            ],
          ),
        );
      },
    );
  }
}
