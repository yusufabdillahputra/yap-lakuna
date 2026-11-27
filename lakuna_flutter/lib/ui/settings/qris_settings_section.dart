import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:lakuna_domain/lakuna_domain.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../utils/command.dart';
import '../cashier/qris_panel.dart' show QrisSticker;
import 'payment_settings_view_model.dart';
import 'settings_card.dart';

/// Ukuran berkas ringkas: `412 KB`, `1,4 MB`.
String formatFileSize(int bytes, {String decimal = ','}) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes + 512) ~/ 1024} KB';
  final tenths = (bytes * 10 + 512 * 1024) ~/ (1024 * 1024);
  return '${tenths ~/ 10}$decimal${tenths % 10} MB';
}

/// Pengaturan › Metode pembayaran › QRIS statis (1.26b).
class QrisSettingsSection extends StatelessWidget {
  const QrisSettingsSection({
    super.key,
    required this.viewModel,
    required this.outletName,
  });

  final PaymentSettingsViewModel viewModel;
  final String outletName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) {
        if (!vm.loaded) {
          return vm.load.error
              ? FAlert(
                  key: const ValueKey('qris-settings-load-error'),
                  variant: .destructive,
                  title: Text(l10n.qrisSettingsLoadError),
                )
              : const Center(child: FCircularProgress());
        }
        return LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 720;
            final actions = _Actions(viewModel: vm);
            return Column(
              key: const ValueKey('qris-settings'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 12,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            l10n.qrisSettingsBreadcrumb,
                            style: theme.typography.body.xs.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                          Text(
                            l10n.settingsSectionPayments,
                            style: theme.typography.display.xl2,
                          ),
                          Text(
                            l10n.settingsBranchScope(outletName),
                            style: theme.typography.body.sm.copyWith(
                              color: theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (wide) SizedBox(width: 240, child: actions),
                  ],
                ),
                if (vm.saved)
                  FAlert(
                    key: const ValueKey('qris-settings-saved'),
                    icon: const Icon(TablerIcons.circleCheck),
                    title: Text(l10n.qrisSettingsSaved),
                  ),
                if (vm.save.error && vm.errors.isEmpty)
                  FAlert(
                    key: const ValueKey('qris-settings-error'),
                    variant: .destructive,
                    title: Text(l10n.settingsSaveError),
                  ),
                _ImageCard(viewModel: vm, wide: wide),
                _MerchantCard(viewModel: vm, wide: wide),
                if (!wide) actions,
              ],
            );
          },
        );
      },
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.viewModel});

  final PaymentSettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: FButton(
            key: const ValueKey('qris-settings-cancel'),
            variant: .outline,
            onPress: vm.save.running || vm.picking ? null : vm.cancel,
            child: Flexible(
              child: Text(
                l10n.qrisSettingsCancel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        Expanded(
          child: FButton(
            key: const ValueKey('qris-settings-save'),
            onPress: vm.canSave ? vm.save.execute : null,
            prefix: vm.save.running
                ? const SizedBox.square(
                    dimension: 16,
                    child: FCircularProgress(),
                  )
                : null,
            child: Flexible(
              child: Text(
                l10n.qrisSettingsSave,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.viewModel, required this.wide});

  final PaymentSettingsViewModel viewModel;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    final vm = viewModel;
    final bytes = vm.previewBytes;
    final decimal = Localizations.localeOf(context).languageCode == 'en'
        ? '.'
        : ',';
    final muted = theme.typography.body.xs.copyWith(
      color: theme.colors.mutedForeground,
    );

    final preview = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        if (bytes != null)
          QrisSticker(
            key: const ValueKey('qris-settings-preview'),
            image: bytes,
            maxHeight: 380,
            semanticsLabel: l10n.qrisImageLabel,
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.muted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Icon(
                      TablerIcons.qrcode,
                      size: 36,
                      color: theme.colors.mutedForeground,
                    ),
                    Text(l10n.qrisSettingsNoImage, style: muted),
                  ],
                ),
              ),
            ),
          ),
        if (vm.previewName case final name?)
          Text(
            l10n.qrisSettingsFileInfo(
              name,
              formatFileSize(vm.previewSize ?? 0, decimal: decimal),
            ),
            key: const ValueKey('qris-settings-file'),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: muted,
          ),
      ],
    );

    Widget pickButton({
      required String key,
      required Command0<void> command,
      required IconData icon,
      required String label,
    }) => FButton(
      key: ValueKey(key),
      variant: .outline,
      mainAxisSize: .min,
      prefix: command.running
          ? const SizedBox.square(dimension: 16, child: FCircularProgress())
          : Icon(icon),
      onPress: vm.picking || vm.save.running ? null : command.execute,
      child: Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
    );

    final upload = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border.all(color: theme.colors.border, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 8,
          children: [
            Icon(TablerIcons.upload, size: 24, color: theme.colors.primary),
            Text(
              bytes == null
                  ? l10n.qrisSettingsUpload
                  : l10n.qrisSettingsReplace,
              style: theme.typography.body.sm.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              vm.canTakePhoto
                  ? l10n.qrisSettingsUploadHintCamera
                  : l10n.qrisSettingsUploadHint,
              textAlign: TextAlign.center,
              style: muted,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                pickButton(
                  key: 'qris-settings-pick',
                  command: vm.pickImage,
                  icon: TablerIcons.photo,
                  label: l10n.qrisSettingsPick,
                ),
                // *Foto stiker* (F1-18f): hanya di perangkat berkamera.
                if (vm.canTakePhoto)
                  pickButton(
                    key: 'qris-settings-camera',
                    command: vm.takePhoto,
                    icon: TablerIcons.camera,
                    label: l10n.qrisSettingsCamera,
                  ),
              ],
            ),
            if (vm.pickFailed case final source?)
              Text(
                switch (source) {
                  QrisPickSource.file => l10n.qrisSettingsFileFailed,
                  QrisPickSource.camera => l10n.qrisSettingsCameraFailed,
                },
                key: const ValueKey('qris-settings-pick-failed'),
                textAlign: TextAlign.center,
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.destructive,
                ),
              ),
          ],
        ),
      ),
    );

    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        upload,
        if (vm.check case final check?) _CheckResults(check: check, vm: vm),
        if (vm.errors.contains(QrisSettingsError.imageMissing))
          Text(
            l10n.qrisSettingsImageMissing,
            key: const ValueKey('qris-settings-image-missing'),
            style: theme.typography.body.sm.copyWith(
              color: theme.colors.destructive,
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Icon(
                  TablerIcons.infoCircle,
                  size: 18,
                  color: theme.colors.primary,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        l10n.qrisSettingsWholeTitle,
                        style: theme.typography.body.sm.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        l10n.qrisSettingsWholeBody,
                        style: theme.typography.body.xs,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return SettingsCard(
      title: l10n.qrisSettingsImageTitle,
      subtitle: l10n.qrisSettingsImageSubtitle,
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                SizedBox(width: 260, child: preview),
                Expanded(child: right),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 14,
              children: [preview, right],
            ),
    );
  }
}

/// Daftar hasil pemeriksaan gambar: ok (hijau), peringatan (kuning), galat
/// (merah).
class _CheckResults extends StatelessWidget {
  const _CheckResults({required this.check, required this.vm});

  final QrisImageCheck check;
  final PaymentSettingsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = context.theme;
    const ok = Color(0xFF016630);
    const warn = Color(0xFF973C00);
    Widget line(IconData icon, Color color, String text, String key) => Row(
      key: ValueKey(key),
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Icon(icon, size: 18, color: color),
        Expanded(child: Text(text, style: theme.typography.body.sm)),
      ],
    );

    final header = check.header;
    final lines = <Widget>[
      if (check.error case final error?)
        line(
          TablerIcons.circleX,
          theme.colors.destructive,
          switch (error) {
            QrisImageError.unsupported => l10n.qrisSettingsUnsupported,
            QrisImageError.tooLarge => l10n.qrisSettingsTooLarge,
          },
          'qris-check-error',
        )
      else if (header != null) ...[
        if (check.warnings.contains(QrisImageWarning.notPortrait))
          line(
            TablerIcons.alertTriangle,
            warn,
            l10n.qrisSettingsNotPortrait(check.ratioLabel!),
            'qris-check-ratio',
          )
        else
          line(
            TablerIcons.circleCheck,
            ok,
            l10n.qrisSettingsPortrait(check.ratioLabel!),
            'qris-check-ratio',
          ),
        if (check.warnings.contains(QrisImageWarning.lowResolution))
          line(
            TablerIcons.alertTriangle,
            warn,
            l10n.qrisSettingsLowResolution(header.width, header.height),
            'qris-check-resolution',
          )
        else
          line(
            TablerIcons.circleCheck,
            ok,
            l10n.qrisSettingsResolution(header.width, header.height),
            'qris-check-resolution',
          ),
        // *QR terbaca* (F1-18g): tidak memblokir Simpan.
        if (vm.qrReading)
          line(
            TablerIcons.scan,
            theme.colors.mutedForeground,
            l10n.qrisSettingsQrReading,
            'qris-check-qr',
          )
        else if (vm.qr case final read?)
          switch (read.status) {
            QrisQrStatus.notFound => line(
              TablerIcons.alertTriangle,
              warn,
              l10n.qrisSettingsQrNotFound,
              'qris-check-qr',
            ),
            QrisQrStatus.notQris => line(
              TablerIcons.alertTriangle,
              warn,
              l10n.qrisSettingsQrNotQris,
              'qris-check-qr',
            ),
            QrisQrStatus.qris when !read.payload!.isStatic => line(
              TablerIcons.alertTriangle,
              warn,
              l10n.qrisSettingsQrDynamic,
              'qris-check-qr',
            ),
            QrisQrStatus.qris => line(
              TablerIcons.circleCheck,
              ok,
              l10n.qrisSettingsQrRead(
                read.payload!.nmid,
                read.payload!.merchantName,
              ),
              'qris-check-qr',
            ),
          },
        if (!vm.qrReading && vm.qrNmidMismatch != null)
          line(
            TablerIcons.alertTriangle,
            warn,
            l10n.qrisSettingsQrNmidMismatch(
              normalizeNmid(vm.draft.nmid),
              vm.qrNmidMismatch!,
            ),
            'qris-check-qr-nmid',
          ),
      ],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(
          l10n.qrisSettingsCheckTitle,
          style: theme.typography.body.sm.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        ...lines,
      ],
    );
  }
}

class _MerchantCard extends StatelessWidget {
  const _MerchantCard({required this.viewModel, required this.wide});

  final PaymentSettingsViewModel viewModel;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final d = vm.draft;
    final errors = vm.errors;
    Widget? tooLong(QrisSettingsError e, int max) =>
        errors.contains(e) ? Text(l10n.qrisSettingsTooLong(max)) : null;

    // Kunci memuat [revision] agar *Batal*/simpan mengisi ulang field.
    final r = vm.revision;
    final name = FTextField(
      key: ValueKey('qris-merchant-$r-${vm.fillRevision(.merchantName)}'),
      label: Text(l10n.qrisSettingsMerchantName),
      error: tooLong(
        QrisSettingsError.merchantNameTooLong,
        maxQrisMerchantNameLength,
      ),
      control: .managed(
        initial: TextEditingValue(text: d.merchantName),
        onChange: (v) => vm.setMerchantName(v.text),
      ),
    );
    final nmid = FTextField(
      key: ValueKey('qris-nmid-$r-${vm.fillRevision(.nmid)}'),
      label: Text(l10n.qrisSettingsNmid),
      description: Text(l10n.qrisSettingsNmidHint),
      error: errors.contains(QrisSettingsError.nmidInvalid)
          ? Text(l10n.qrisSettingsNmidInvalid)
          : null,
      control: .managed(
        initial: TextEditingValue(text: d.nmid),
        onChange: (v) => vm.setNmid(v.text),
      ),
    );
    final terminal = FTextField(
      key: ValueKey('qris-terminal-$r-${vm.fillRevision(.terminalCode)}'),
      label: Text(l10n.qrisSettingsTerminal),
      error: tooLong(
        QrisSettingsError.terminalCodeTooLong,
        maxQrisTerminalCodeLength,
      ),
      control: .managed(
        initial: TextEditingValue(text: d.terminalCode),
        onChange: (v) => vm.setTerminalCode(v.text),
      ),
    );
    final settlement = FTextField(
      key: ValueKey('qris-settlement-$r'),
      label: Text(l10n.qrisSettingsSettlement),
      description: Text(l10n.qrisSettingsSettlementHint),
      error: tooLong(
        QrisSettingsError.settlementNoteTooLong,
        maxQrisSettlementNoteLength,
      ),
      control: .managed(
        initial: TextEditingValue(text: d.settlementNote),
        onChange: (v) => vm.setSettlementNote(v.text),
      ),
    );
    Widget pair(Widget a, Widget b) => wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Expanded(child: a),
              Expanded(child: b),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [a, b],
          );

    return SettingsCard(
      title: l10n.qrisSettingsMerchantTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          pair(name, nmid),
          pair(terminal, settlement),
          const FDivider(),
          FSwitch(
            key: const ValueKey('qris-enabled'),
            label: Text(l10n.qrisSettingsEnabled),
            value: d.enabled,
            onChange: vm.setEnabled,
          ),
          FSwitch(
            key: const ValueKey('qris-require-paid'),
            label: Text(l10n.qrisSettingsRequirePaid),
            description: Text(l10n.qrisSettingsRequirePaidHint),
            value: true,
            enabled: false,
            onChange: (_) {},
          ),
          FSwitch(
            key: const ValueKey('qris-without-pin'),
            label: Text(l10n.qrisSettingsWithoutPin),
            description: Text(l10n.qrisSettingsWithoutPinHint),
            value: d.cashierConfirmWithoutPin,
            onChange: vm.setCashierWithoutPin,
          ),
          FSwitch(
            key: const ValueKey('qris-show-on-phone'),
            label: Text(l10n.qrisSettingsShowOnPhone),
            description: Text(l10n.qrisSettingsShowOnPhoneHint),
            value: d.showOnPhone,
            onChange: vm.setShowOnPhone,
          ),
        ],
      ),
    );
  }
}
