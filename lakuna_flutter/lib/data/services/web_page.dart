import 'web_page_io.dart'
    if (dart.library.js_interop) 'web_page_web.dart'
    as impl;

/// Memuat ulang halaman browser (web saja; di perangkat tidak melakukan
/// apa pun).
Future<void> reloadPage() => impl.reloadPage();

/// Alamat server bawaan di layar masuk web: asal halaman, karena paket VPS
/// menyajikan web dan server dari domain yang sama. Kosong di perangkat.
String defaultWebServerUrl() => impl.defaultWebServerUrl();
