import 'package:lakuna_client/lakuna_client.dart' show ServerpodClientException;

import '../../data/repositories/hosting_repository.dart';
import '../../data/repositories/repository_errors.dart';
import '../../l10n/gen/app_localizations.dart';

/// Pesan galat versi hosting untuk pengguna.
String hostingErrorText(AppLocalizations l10n, Object error) => switch (error) {
  InvalidServerUrl() => l10n.hostingErrorInvalidUrl,
  SyncOfflineException() => l10n.hostingErrorOffline,
  HostingServerTooOld(:final serverVersion) => l10n.hostingErrorServerTooOld(
    serverVersion,
  ),
  HostingAppTooOld(:final minAppVersion) => l10n.hostingErrorAppTooOld(
    minAppVersion,
  ),
  HostingNotPermitted() || NotPermitted() => l10n.hostingErrorNotPermitted,
  HostingJoinIncomplete() => l10n.joinIncomplete,
  HostingNotActive() => l10n.hostingErrorNotActive,
  HostingAlreadyActive() => l10n.hostingErrorAlreadyActive,
  ActivationException(:final reason) => switch (reason) {
    ActivationFailure.codeInvalid => l10n.hostingFailCodeInvalid,
    ActivationFailure.codeUsed => l10n.hostingFailCodeUsed,
    ActivationFailure.codeExpired => l10n.hostingFailCodeExpired,
    ActivationFailure.tenantActive => l10n.hostingFailTenantActive,
    ActivationFailure.copiedDevice => l10n.hostingFailCopiedDevice,
    ActivationFailure.notOwner => l10n.hostingFailNotOwner,
    ActivationFailure.outletUnknown => l10n.hostingFailOutletUnknown,
    ActivationFailure.deviceCodeTaken => l10n.hostingFailDeviceCodeTaken,
  },
  ServerpodClientException(:final message) => l10n.hostingErrorGeneric(
    message,
  ),
  _ => l10n.hostingErrorGeneric('$error'),
};

/// Pesan galat siklus sync terakhir di kartu *Versi hosting*.
String syncErrorText(AppLocalizations l10n, String code) => switch (code) {
  'clock' => l10n.hostingErrorClock,
  'invalidToken' || 'revoked' || 'unknownTenant' => l10n.hostingErrorToken,
  'network' => l10n.hostingErrorNetwork,
  _ => l10n.hostingErrorOther(code),
};

String uploadGroupLabel(AppLocalizations l10n, UploadGroup group) =>
    switch (group) {
      UploadGroup.store => l10n.hostingGroupStore,
      UploadGroup.catalog => l10n.hostingGroupCatalog,
      UploadGroup.partners => l10n.hostingGroupPartners,
      UploadGroup.sales => l10n.hostingGroupSales,
      UploadGroup.purchases => l10n.hostingGroupPurchases,
      UploadGroup.stock => l10n.hostingGroupStock,
      UploadGroup.media => l10n.hostingGroupMedia,
    };

/// Angka dengan pemisah ribuan titik (`15.002`).
String formatCount(int value) {
  final digits = value.abs().toString();
  final out = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write('.');
    out.write(digits[i]);
  }
  return out.toString();
}

/// Nama host untuk ditampilkan (`sync.tokocontoh.id`).
String serverHost(String serverUrl) =>
    Uri.tryParse(serverUrl)?.host.isNotEmpty ?? false
    ? Uri.parse(serverUrl).authority
    : serverUrl;
