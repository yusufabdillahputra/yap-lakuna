import 'web_session_store.dart';

/// Aplikasi perangkat tidak memakai sesi web.
WebSessionStore platformWebSessionStore() => MemoryWebSessionStore();
