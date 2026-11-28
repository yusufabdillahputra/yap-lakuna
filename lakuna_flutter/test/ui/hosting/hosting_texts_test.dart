import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lakuna_data/lakuna_data.dart'
    show HostingAlreadyActive, HostingNotActive;
import 'package:lakuna_flutter/data/repositories/hosting_repository.dart'
    show WebAccessException, WebAccessFailure;
import 'package:lakuna_flutter/l10n/gen/app_localizations.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    show EmailAccountLoginException, EmailAccountLoginExceptionReason;
import 'package:lakuna_flutter/ui/hosting/hosting_texts.dart';

void main() {
  for (final locale in const [Locale('id'), Locale('en')]) {
    test('galat aktif/belum aktif punya teks sendiri ($locale)', () {
      final l10n = lookupAppLocalizations(locale);
      for (final e in const [HostingNotActive(), HostingAlreadyActive()]) {
        final text = hostingErrorText(l10n, e);
        expect(text, isNot(contains('Instance of')));
        expect(text, isNot(l10n.hostingErrorGeneric('$e')));
      }
    });
  }

  test('setiap alasan login web punya teks sendiri', () {
    final l10n = lookupAppLocalizations(const Locale('id'));
    final texts = {
      for (final f in WebAccessFailure.values)
        hostingErrorText(
          l10n,
          WebAccessException(
            failure: f,
            lockedUntil: DateTime.utc(2026, 11, 28, 9, 15),
          ),
        ),
    };
    expect(texts, hasLength(WebAccessFailure.values.length));
    expect(texts.any((t) => t.contains('Instance of')), isFalse);
  });

  test('login akun: kata sandi salah dan terlalu sering', () {
    final l10n = lookupAppLocalizations(const Locale('id'));
    expect(
      hostingErrorText(
        l10n,
        EmailAccountLoginException(
          reason: EmailAccountLoginExceptionReason.invalidCredentials,
        ),
      ),
      l10n.hostingWrongCredentials,
    );
    expect(
      hostingErrorText(
        l10n,
        EmailAccountLoginException(
          reason: EmailAccountLoginExceptionReason.tooManyAttempts,
        ),
      ),
      l10n.hostingTooManyAttempts,
    );
  });
}
