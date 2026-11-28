/// Penyimpanan berkas media server (F2-01 aturan 19): object storage
/// S3-compatible (SeaweedFS di paket VPS, atau S3 penyedia) bila diatur, atau
/// database Postgres bila tidak (pengembangan, tes, server kecil).
library;

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_cloud_storage_s3_compat/serverpod_cloud_storage_s3_compat.dart';

import 'media_sync_endpoint.dart' show mediaStorageId;

/// Kunci `passwords.yaml` / `SERVERPOD_PASSWORD_<kunci>` untuk S3.
const s3PasswordKeys = [
  's3Endpoint',
  's3AccessKey',
  's3SecretKey',
  's3Bucket',
  's3Region',
];

class S3Settings {
  const S3Settings({
    required this.endpoint,
    required this.accessKey,
    required this.secretKey,
    required this.bucket,
    required this.region,
  });

  /// `null` bila salah satu dari alamat, kunci, rahasia, atau bucket
  /// kosong. Alamat harus `http://` atau `https://`.
  static S3Settings? fromPasswords(Map<String, String?> passwords) {
    String value(String key) => passwords[key]?.trim() ?? '';
    final endpoint = value('s3Endpoint');
    final accessKey = value('s3AccessKey');
    final secretKey = value('s3SecretKey');
    final bucket = value('s3Bucket');
    if ([endpoint, accessKey, secretKey, bucket].any((v) => v.isEmpty)) {
      return null;
    }
    final uri = Uri.tryParse(endpoint);
    if (uri == null ||
        !(uri.isScheme('http') || uri.isScheme('https')) ||
        uri.host.isEmpty) {
      throw FormatException('s3Endpoint harus http(s)://host', endpoint);
    }
    final region = value('s3Region');
    return S3Settings(
      endpoint: uri,
      accessKey: accessKey,
      secretKey: secretKey,
      bucket: bucket,
      region: region.isEmpty ? 'us-east-1' : region,
    );
  }

  final Uri endpoint;
  final String accessKey;
  final String secretKey;
  final String bucket;
  final String region;
}

/// Storage `private` (media toko) dan `public` untuk server.
List<CloudStorage> mediaStorages(S3Settings? s3) => [
  if (s3 == null)
    DatabaseCloudStorage(mediaStorageId)
  else
    S3CompatCloudStorage(
      storageId: mediaStorageId,
      accessKey: s3.accessKey,
      secretKey: s3.secretKey,
      bucket: s3.bucket,
      region: s3.region,
      public: false,
      endpoints: CustomEndpointConfig(
        baseUri: s3.endpoint,
        serviceName: 'S3-compatible',
      ),
      uploadStrategy: PresignedPutUploadStrategy(),
    ),
  DatabaseCloudStorage('public'),
];
