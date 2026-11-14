import 'package:flutter/foundation.dart' show LicenseEntry;
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../app_root.dart';
import '../../data/repositories/backup_repository.dart';
import '../../data/repositories/dining_admin_repository.dart';
import '../../data/repositories/payment_settings_repository.dart';
import '../../data/repositories/receipt_settings_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/store_repository.dart';
import '../../data/repositories/store_settings_repository.dart';
import '../../data/services/backup_files.dart';
import '../../data/services/image_file_picker.dart';
import '../../data/services/receipt_printer.dart';
import '../../l10n/gen/app_localizations.dart';
import '../core/breakpoints.dart';
import '../products/product_widgets.dart' show ChoicePill;
import 'about_section.dart';
import 'about_view_model.dart';
import 'app_settings_view_model.dart';
import 'backup_section.dart';
import 'backup_view_model.dart';
import 'fnb_rates_section.dart';
import 'fnb_rates_view_model.dart';
import 'payment_settings_view_model.dart';
import 'qris_settings_section.dart';
import 'receipt_settings_section.dart';
import 'kitchen_printer_view_model.dart';
import 'receipt_settings_view_model.dart';
import 'settings_view.dart';
import 'store_settings_section.dart';
import 'store_settings_view_model.dart';

/// Bagian layar Pengaturan (1.26). Bagian lain menyusul bersama modulnya.
enum SettingsSection {
  business,
  outlet,
  payments,
  receipt,
  taxes,
  rules,
  backup,
  appearance,
  about;

  /// Bagian dari parameter rute `?bagian=` (mis. `backup` dari pengingat
  /// Beranda); `null` bila tidak dikenal.
  static SettingsSection? fromQuery(String? value) {
    for (final s in values) {
      if (s.name == value) return s;
    }
    return null;
  }
}

/// Layar Pengaturan: navigasi bagian (kolom kiri di layar lebar, pil di
/// layar sempit) dan isi bagian. *Metode pembayaran* dan *Struk & printer*
/// hanya untuk staf dengan `settings:manage`.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.paymentSettings,
    required this.receiptSettings,
    required this.receiptPrinter,
    required this.imagePicker,
    required this.session,
    required this.store,
    required this.storeSettings,
    this.diningAdmin,
    this.backup,
    this.backupFiles = const PlatformBackupFiles(),
    this.initialSection,
    this.licenses,
  });

  /// Sumber lisensi untuk Tentang Lakuna; bawaan [LicenseRegistry].
  final Stream<LicenseEntry> Function()? licenses;

  /// Data & backup (F1-19); hanya untuk staf dengan `backup:manage`.
  final BackupRepository? backup;
  final BackupFiles backupFiles;

  /// Bagian yang dibuka pertama (bila boleh diakses staf).
  final SettingsSection? initialSection;

  /// Tarif service & PB1 (F1-10).
  final DiningAdminRepository? diningAdmin;

  final AppSettingsViewModel settings;
  final PaymentSettingsRepository paymentSettings;
  final ReceiptSettingsRepository receiptSettings;
  final ReceiptPrinter receiptPrinter;
  final ImageFilePicker imagePicker;
  final SessionRepository session;
  final StoreRepository store;

  /// Profil toko, cabang, penjualan & stok (F1-18).
  final StoreSettingsRepository storeSettings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final bool _canManage =
      widget.session.current?.can(Permission.settingsManage) ?? false;
  late final bool _canBackup =
      widget.backup != null &&
      (widget.session.current?.can(Permission.backupManage) ?? false);
  late SettingsSection _section = switch (widget.initialSection) {
    final s? when _sections.contains(s) => s,
    _ => _canManage ? SettingsSection.business : SettingsSection.appearance,
  };
  StoreSettingsViewModel? _store;
  PaymentSettingsViewModel? _payments;
  ReceiptSettingsViewModel? _receipt;

  /// Printer dapur (F1-10e), bersama modul meja.
  KitchenPrinterViewModel? _kitchen;

  /// Printer bar per kategori (F1-10j), bersama modul meja.
  KitchenPrinterViewModel? _bar;
  FnbRatesViewModel? _rates;
  BackupViewModel? _backup;
  late final _about = AboutViewModel(licenses: widget.licenses);

  @override
  void initState() {
    super.initState();
    if (_canManage) {
      _store = StoreSettingsViewModel(repository: widget.storeSettings)
        ..load.execute();
      _payments = PaymentSettingsViewModel(
        repository: widget.paymentSettings,
        picker: widget.imagePicker,
      )..load.execute();
      _receipt = ReceiptSettingsViewModel(
        repository: widget.receiptSettings,
        printer: widget.receiptPrinter,
        picker: widget.imagePicker,
      )..load.execute();
      if (widget.diningAdmin case final admin?) {
        _rates = FnbRatesViewModel(repository: admin)..load.execute();
        _kitchen = KitchenPrinterViewModel(
          repository: widget.receiptSettings,
          printer: widget.receiptPrinter,
        )..load.execute();
        _bar = KitchenPrinterViewModel(
          repository: widget.receiptSettings,
          printer: widget.receiptPrinter,
          station: PrinterStation.bar,
        )..load.execute();
      }
    }
    if (_canBackup) {
      _backup = BackupViewModel(
        repository: widget.backup!,
        files: widget.backupFiles,
        restart: () async => _restart?.call(),
      )..load.execute();
    }
  }

  /// Dibaca saat dipakai: [AppRestart] belum bisa dicari di [initState].
  Future<void> Function()? _restart;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restart = AppRestart.maybeOf(context)?.restart;
  }

  @override
  void dispose() {
    _store?.dispose();
    _payments?.dispose();
    _receipt?.dispose();
    _kitchen?.dispose();
    _bar?.dispose();
    _rates?.dispose();
    _backup?.dispose();
    _about.dispose();
    super.dispose();
  }

  List<SettingsSection> get _sections => [
    if (_canManage) SettingsSection.business,
    if (_canManage) SettingsSection.outlet,
    if (_canManage) SettingsSection.payments,
    if (_canManage) SettingsSection.receipt,
    if (_rates != null) SettingsSection.taxes,
    if (_canManage) SettingsSection.rules,
    if (_canBackup) SettingsSection.backup,
    SettingsSection.appearance,
    SettingsSection.about,
  ];

  String _label(AppLocalizations l10n, SettingsSection s) => switch (s) {
    SettingsSection.business => l10n.storeSettingsBusinessTitle,
    SettingsSection.outlet => l10n.storeSettingsOutletTitle,
    SettingsSection.rules => l10n.storeSettingsRulesTitle,
    SettingsSection.payments => l10n.settingsSectionPayments,
    SettingsSection.receipt => l10n.settingsSectionReceipt,
    SettingsSection.taxes => l10n.settingsSectionTaxes,
    SettingsSection.backup => l10n.settingsSectionBackup,
    SettingsSection.appearance => l10n.settingsSectionAppearance,
    SettingsSection.about => l10n.settingsSectionAbout,
  };

  IconData _icon(SettingsSection s) => switch (s) {
    SettingsSection.business => TablerIcons.buildingStore,
    SettingsSection.outlet => TablerIcons.mapPin,
    SettingsSection.rules => TablerIcons.adjustmentsHorizontal,
    SettingsSection.payments => TablerIcons.creditCard,
    SettingsSection.receipt => TablerIcons.receipt,
    SettingsSection.taxes => TablerIcons.percentage,
    SettingsSection.backup => TablerIcons.databaseExport,
    SettingsSection.appearance => TablerIcons.palette,
    SettingsSection.about => TablerIcons.infoCircle,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final content = switch (_section) {
      SettingsSection.business => StoreSettingsSection(
        viewModel: _store!,
        part: StoreSettingsPart.business,
      ),
      SettingsSection.outlet => StoreSettingsSection(
        viewModel: _store!,
        part: StoreSettingsPart.outlet,
      ),
      SettingsSection.rules => StoreSettingsSection(
        viewModel: _store!,
        part: StoreSettingsPart.rules,
      ),
      SettingsSection.payments => QrisSettingsSection(
        viewModel: _payments!,
        outletName: widget.store.current?.outlet.name ?? '',
      ),
      SettingsSection.receipt => ReceiptSettingsSection(
        viewModel: _receipt!,
        kitchen: _kitchen,
        bar: _bar,
        businessName: widget.store.current?.tenant.name ?? '',
        outletName: widget.store.current?.outlet.name ?? '',
        staffName: widget.session.current?.name ?? '',
      ),
      SettingsSection.taxes => FnbRatesSection(viewModel: _rates!),
      SettingsSection.backup => BackupSection(
        viewModel: _backup!,
        timezone: widget.store.current?.outlet.timezone,
      ),
      SettingsSection.appearance => SettingsView(viewModel: widget.settings),
      SettingsSection.about => AboutSection(viewModel: _about),
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
                child: SingleChildScrollView(
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
