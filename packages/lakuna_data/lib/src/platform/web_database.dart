/// Menghapus database sesi web (F2-02 aturan 6).
library;

export 'web_database_io.dart'
    if (dart.library.js_interop) 'web_database_web.dart';
