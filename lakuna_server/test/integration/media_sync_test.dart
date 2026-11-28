import 'dart:typed_data';

import 'package:lakuna_domain/lakuna_domain.dart' show secretHash;
import 'package:lakuna_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

final tenantId = UuidValue.fromString('01900000-0000-7000-8000-000000000001');
final otherTenantId = UuidValue.fromString(
  '01900000-0000-7000-8000-000000000002',
);
final deviceA = UuidValue.fromString('01900000-0000-7000-8000-0000000000a1');
final deviceC = UuidValue.fromString('01900000-0000-7000-8000-0000000000c1');
final mediaId = UuidValue.fromString('01900000-0000-7000-8000-00000000e001');
final twinId = UuidValue.fromString('01900000-0000-7000-8000-00000000e002');
final otherMediaId = UuidValue.fromString(
  '01900000-0000-7000-8000-00000000e003',
);

const tokenA = 'token-a-0123456789';
const tokenC = 'token-c-0123456789';
const seedHlc = '0000000000000-0000-seed';
const sha = 'aa11';

MediaFile media(UuidValue id, UuidValue tenant) => MediaFile(
  id: id,
  tenantId: tenant,
  kind: MediaKind.productPhoto,
  fileName: 'teh.jpg',
  mimeType: 'image/jpeg',
  sizeBytes: 3,
  sha256: sha,
  width: 1,
  height: 1,
  storageKey: '$sha.jpg',
  hlc: seedHlc,
);

Future<void> seed(Session session) async {
  for (final (id, token, tenant) in [
    (deviceA, tokenA, tenantId),
    (deviceC, tokenC, otherTenantId),
  ]) {
    await Tenant.db.insertRow(
      session,
      Tenant(id: tenant, name: 'Toko', hlc: seedHlc),
    );
    await DeviceCredential.db.insertRow(
      session,
      DeviceCredential(
        tenantId: tenant,
        deviceId: id,
        tokenHash: secretHash(token),
      ),
    );
  }
  await MediaFile.db.insert(session, [
    media(mediaId, tenantId),
    // Berkas sama (hash sama) di baris lain tenant yang sama.
    media(twinId, tenantId),
    media(otherMediaId, otherTenantId),
  ]);
}

Matcher failsWith(String reason) => throwsA(
  isA<SyncRequestException>().having((e) => e.reason, 'reason', reason),
);

void main() {
  withServerpod('Media ke object storage (F2-01 aturan 19-20)', (
    sessionBuilder,
    endpoints,
  ) {
    setUp(() => seed(sessionBuilder.build()));

    Future<void> storeUploaded(UuidValue tenant) =>
        sessionBuilder.build().storage.storeFile(
          storageId: 'private',
          path: '${tenant.uuid}/$sha.jpg',
          byteData: ByteData.sublistView(Uint8List.fromList([1, 2, 3])),
        );

    test(
      'berkas belum ada: deskripsi unggah ke <tenant>/<storage_key>',
      () async {
        final description = await endpoints.mediaSync.uploadDescription(
          sessionBuilder,
          tokenA,
          mediaId,
        );
        expect(description, isNotNull);
        expect(
          description,
          contains(Uri.encodeQueryComponent('${tenantId.uuid}/$sha.jpg')),
        );
        // Belum diunggah: belum terverifikasi dan belum bisa diunduh.
        expect(
          await endpoints.mediaSync.markUploaded(
            sessionBuilder,
            tokenA,
            mediaId,
          ),
          isFalse,
        );
        expect(
          await endpoints.mediaSync.downloadUrl(
            sessionBuilder,
            tokenA,
            mediaId,
          ),
          isNull,
        );
      },
    );

    test('hash sama tidak diunggah dua kali', () async {
      await storeUploaded(tenantId);
      expect(
        await endpoints.mediaSync.markUploaded(sessionBuilder, tokenA, mediaId),
        isTrue,
      );
      expect(
        await endpoints.mediaSync.uploadDescription(
          sessionBuilder,
          tokenA,
          twinId,
        ),
        isNull,
      );
      expect(
        await endpoints.mediaSync.downloadUrl(sessionBuilder, tokenA, twinId),
        isNotNull,
      );
    });

    test('media tenant lain ditolak', () async {
      await storeUploaded(otherTenantId);
      await expectLater(
        endpoints.mediaSync.uploadDescription(
          sessionBuilder,
          tokenA,
          otherMediaId,
        ),
        failsWith('mediaUnknown'),
      );
      await expectLater(
        endpoints.mediaSync.downloadUrl(sessionBuilder, tokenA, otherMediaId),
        failsWith('mediaUnknown'),
      );
    });

    test('baris media belum di-push: belum dikenal', () async {
      await expectLater(
        endpoints.mediaSync.uploadDescription(
          sessionBuilder,
          tokenA,
          UuidValue.fromString('01900000-0000-7000-8000-00000000e0ff'),
        ),
        failsWith('mediaUnknown'),
      );
    });

    test(
      'kunci berkas tidak aman ditolak (tidak keluar folder tenant)',
      () async {
        final bad = UuidValue.fromString(
          '01900000-0000-7000-8000-00000000e0aa',
        );
        await MediaFile.db.insertRow(
          sessionBuilder.build(),
          media(bad, tenantId).copyWith(
            storageKey: '../${otherTenantId.uuid}/$sha.jpg',
          ),
        );
        await expectLater(
          endpoints.mediaSync.downloadUrl(sessionBuilder, tokenA, bad),
          failsWith('mediaInvalid'),
        );
      },
    );

    test('token salah ditolak', () async {
      await expectLater(
        endpoints.mediaSync.downloadUrl(sessionBuilder, 'salah', mediaId),
        throwsA(isA<SyncAuthException>()),
      );
    });
  });
}
