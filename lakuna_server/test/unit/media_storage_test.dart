import 'package:lakuna_server/src/media/media_storage.dart';
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_cloud_storage_s3_compat/serverpod_cloud_storage_s3_compat.dart';
import 'package:test/test.dart';

void main() {
  test('tanpa pengaturan S3: berkas di database', () {
    expect(S3Settings.fromPasswords(const {}), isNull);
    expect(
      S3Settings.fromPasswords(const {'s3Endpoint': 'http://minio:9000'}),
      isNull,
    );
    final storages = mediaStorages(null);
    expect(storages.map((s) => s.storageId), ['private', 'public']);
    expect(storages.every((s) => s is DatabaseCloudStorage), isTrue);
  });

  test('pengaturan S3 lengkap: berkas privat ke MinIO/S3', () {
    final s = S3Settings.fromPasswords(const {
      's3Endpoint': 'http://minio:9000/',
      's3AccessKey': 'lakuna',
      's3SecretKey': 'rahasia-panjang',
      's3Bucket': 'lakuna-media',
    })!;
    expect(s.endpoint, Uri.parse('http://minio:9000/'));
    expect(s.region, 'us-east-1');
    final storages = mediaStorages(s);
    final private = storages.firstWhere((x) => x.storageId == 'private');
    expect(private, isA<S3CompatCloudStorage>());
    expect((private as S3CompatCloudStorage).bucket, 'lakuna-media');
    expect(private.public, isFalse);
    expect(
      storages.firstWhere((x) => x.storageId == 'public'),
      isA<DatabaseCloudStorage>(),
    );
  });

  test('alamat S3 bukan http(s) ditolak', () {
    expect(
      () => S3Settings.fromPasswords(const {
        's3Endpoint': 'minio:9000',
        's3AccessKey': 'a',
        's3SecretKey': 'b',
        's3Bucket': 'c',
      }),
      throwsFormatException,
    );
  });
}
