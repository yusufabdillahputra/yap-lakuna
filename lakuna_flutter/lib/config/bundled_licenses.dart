import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Aset bundel yang lisensinya wajib ikut didistribusikan: font (SIL OFL
/// 1.1) dan Bootstrap Icons (MIT, mark Etalase pada logo).
const bundledLicenseAssets = {
  'Montserrat': 'assets/fonts/Montserrat/LICENSE.txt',
  'DM Sans': 'assets/fonts/DM_Sans/LICENSE.txt',
  'DM Mono': 'assets/fonts/DM_Mono/LICENSE.txt',
  'Bootstrap Icons': 'assets/licenses/bootstrap-icons.txt',
};

/// Mendaftarkan lisensi aset bundel ke [LicenseRegistry] agar tampil di
/// Pengaturan › Tentang Lakuna bersama lisensi paket. Teks dibaca dari aset
/// saat daftar lisensi pertama kali diminta.
void registerBundledLicenses({AssetBundle? bundle}) {
  LicenseRegistry.addLicense(() async* {
    final source = bundle ?? rootBundle;
    for (final MapEntry(key: name, value: asset)
        in bundledLicenseAssets.entries) {
      yield LicenseEntryWithLineBreaks([name], await source.loadString(asset));
    }
  });
}
