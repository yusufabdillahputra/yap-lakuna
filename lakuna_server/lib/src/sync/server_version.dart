/// Versi server = versi aplikasi Lakuna (dijaga tes `server_version_test`).
const serverVersion = '0.167.0';

/// Versi protokol `sync.push`/`sync.pull`. Naik bila bentuk pesan atau
/// aturan penerapan berubah tidak cocok-mundur; aplikasi menolak server
/// dengan protokol lebih lama (*Server perlu diperbarui*).
const syncProtocolVersion = 1;
