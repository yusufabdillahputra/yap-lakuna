/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'package:http/http.dart' as _i85jenna;
import 'package:lakuna_client/src/protocol/organization/device_platform.dart'
    as _ii07z3jj;
import 'package:lakuna_client/src/protocol/sync/activation_result.dart'
    as _imjtgolx;
import 'package:lakuna_client/src/protocol/sync/pairing_outlet.dart'
    as _i5ptjowb;
import 'package:lakuna_client/src/protocol/sync/sync_pull_page.dart'
    as _izun0ovl;
import 'package:lakuna_client/src/protocol/sync/sync_push_entry.dart'
    as _ipv8demw;
import 'package:lakuna_client/src/protocol/sync/sync_push_reply.dart'
    as _ia4kk4ai;
import 'package:lakuna_client/src/protocol/sync/sync_server_status.dart'
    as _ikbjecyu;
import 'package:lakuna_client/src/protocol/web_access/totp_enrollment.dart'
    as _ib8bg96t;
import 'package:lakuna_client/src/protocol/web_access/web_access_result.dart'
    as _iwkl0izw;
import 'package:lakuna_client/src/protocol/web_access/web_tenant.dart'
    as _ib69tvb5;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_database/serverpod_database.dart' as _isd;
import 'protocol.dart' as _il2as5qe;
import 'package:lakuna_client/migrations/migration_registry.dart';

/// By extending [EmailOtpIdpBaseEndpoint], the email identity provider
/// endpoints, including the passwordless sign-in with one-time passwords, are
/// made available on the server and enable the corresponding sign-in widget on
/// the client.
///
/// Extend [EmailIdpBaseEndpoint] instead for the password based sign-in only.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailOtpIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Starts a passwordless login by sending a one-time password to [email].
  ///
  /// The code is sent whether or not an account is registered for the email.
  /// If none is, verifying the code lets the user create a new account.
  ///
  /// Always returns a login request ID, which must be passed to
  /// [verifyOtpLoginCode] together with the one-time password.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the email is
  ///   not valid.
  /// - [EmailAccountRequestExceptionReason.tooManyAttempts] if too many
  ///   one-time passwords have been requested for the email.
  @override
  _ida.Future<_isc.UuidValue> startOtpLogin({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startOtpLogin',
        {'email': email},
      );

  /// Verifies a one-time password and returns a token to complete the login.
  ///
  /// If [EmailAccountOtpVerificationResult.accountExists] is `true`, pass the
  /// token to [finishOtpLogin] to sign in. Otherwise, have the user accept the
  /// terms (and optionally set a password if
  /// [EmailAccountOtpVerificationResult.allowPassword] is `true`) and pass it
  /// to [finishOtpRegistration] to create the account.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the login request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts to verify the code.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists for
  ///   the given [otpLoginRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<_iaic.EmailAccountOtpVerificationResult> verifyOtpLoginCode({
    required _isc.UuidValue otpLoginRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<_iaic.EmailAccountOtpVerificationResult>(
    'emailIdp',
    'verifyOtpLoginCode',
    {
      'otpLoginRequestId': otpLoginRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a passwordless login for an existing account and returns a new
  /// session.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the login request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [otpLoginToken] is
  ///   invalid or no account exists for the email.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> finishOtpLogin({
    required String otpLoginToken,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishOtpLogin',
    {'otpLoginToken': otpLoginToken},
  );

  /// Completes a passwordless login for an email without an account, by
  /// creating a new auth user with a profile and attaching the verified email
  /// to it.
  ///
  /// Must only be called after the user accepted the terms. The [password] is
  /// optional, and may only be set if
  /// [EmailAccountOtpVerificationResult.allowPassword] was `true`.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the login request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if a password is
  ///   given but not allowed, or it does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [otpLoginToken] is
  ///   invalid or an account already exists for the email.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishOtpRegistration({
    required String otpLoginToken,
    String? password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishOtpRegistration',
    {
      'otpLoginToken': otpLoginToken,
      'password': password,
    },
  );

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// Berkas media di object storage dengan kunci
/// `<tenant_id>/<storage_key>`. Baris `media_files` harus sudah di-push
/// lebih dulu; berkas dengan hash sama di tenant yang sama hanya diunggah
/// sekali.
/// {@category Endpoint}
class EndpointMediaSync extends _isc.EndpointRef {
  EndpointMediaSync(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'mediaSync';

  /// Deskripsi unggah untuk `FileUploader`, atau `null` bila berkasnya
  /// sudah ada di storage.
  _ida.Future<String?> uploadDescription(
    String deviceToken,
    _isc.UuidValue mediaFileId,
  ) => caller.callServerEndpoint<String?>(
    'mediaSync',
    'uploadDescription',
    {
      'deviceToken': deviceToken,
      'mediaFileId': mediaFileId,
    },
  );

  /// Dipanggil setelah unggah selesai; `true` bila berkas ada di storage.
  _ida.Future<bool> markUploaded(
    String deviceToken,
    _isc.UuidValue mediaFileId,
  ) => caller.callServerEndpoint<bool>(
    'mediaSync',
    'markUploaded',
    {
      'deviceToken': deviceToken,
      'mediaFileId': mediaFileId,
    },
  );

  /// URL unduh sementara, atau `null` bila berkas belum diunggah perangkat
  /// asalnya.
  _ida.Future<Uri?> downloadUrl(
    String deviceToken,
    _isc.UuidValue mediaFileId,
  ) => caller.callServerEndpoint<Uri?>(
    'mediaSync',
    'downloadUrl',
    {
      'deviceToken': deviceToken,
      'mediaFileId': mediaFileId,
    },
  );
}

/// Aktivasi versi hosting dan pasang perangkat berikutnya (F2-01 aturan
/// 9–11).
/// {@category Endpoint}
class EndpointActivation extends _isc.EndpointRef {
  EndpointActivation(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'activation';

  /// Perangkat pertama: memakai kode aktivasi dari admin server dan akun
  /// pemilik yang sedang login. Server membuat tenant dengan ID dari
  /// perangkat ([tenantId]) lalu menunggu unggahan data awal.
  _ida.Future<_imjtgolx.ActivationResult> activateFirstDevice(
    String activationCode,
    _isc.UuidValue tenantId,
    _isc.UuidValue deviceId,
    String tenantName,
    String deviceCode,
  ) => caller.callServerEndpoint<_imjtgolx.ActivationResult>(
    'activation',
    'activateFirstDevice',
    {
      'activationCode': activationCode,
      'tenantId': tenantId,
      'deviceId': deviceId,
      'tenantName': tenantName,
      'deviceCode': deviceCode,
    },
  );

  /// Kode pasang 8 huruf, berlaku [pairingCodeLifetime], dibuat dari
  /// perangkat yang sudah aktif.
  _ida.Future<String> createPairingCode(String deviceToken) =>
      caller.callServerEndpoint<String>(
        'activation',
        'createPairingCode',
        {'deviceToken': deviceToken},
      );

  /// Cabang aktif tenant kode pasang, urut kode, untuk dipilih perangkat
  /// baru sebelum [joinWithPairingCode]. Kode tidak dipakai di sini.
  _ida.Future<List<_i5ptjowb.PairingOutlet>> pairingOutlets(
    String pairingCode,
  ) => caller.callServerEndpoint<List<_i5ptjowb.PairingOutlet>>(
    'activation',
    'pairingOutlets',
    {'pairingCode': pairingCode},
  );

  /// Perangkat baru bergabung ke tenant kode pasang. Server membuat ID
  /// perangkat baru (perangkat hasil salinan backup tidak pernah memakai ID
  /// lama) beserta baris `devices` yang ditarik perangkat lain.
  _ida.Future<_imjtgolx.ActivationResult> joinWithPairingCode(
    String pairingCode,
    _isc.UuidValue outletId,
    String deviceCode,
    String deviceName,
    _ii07z3jj.DevicePlatform platform,
  ) => caller.callServerEndpoint<_imjtgolx.ActivationResult>(
    'activation',
    'joinWithPairingCode',
    {
      'pairingCode': pairingCode,
      'outletId': outletId,
      'deviceCode': deviceCode,
      'deviceName': deviceName,
      'platform': platform,
    },
  );
}

/// Push/pull sync perangkat versi hosting (F2-01). Semua panggilan memakai
/// token perangkat, bukan sesi staf.
/// {@category Endpoint}
class EndpointSync extends _isc.EndpointRef {
  EndpointSync(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'sync';

  /// Menerapkan [entries] (urutan outbox) dalam satu transaksi; setiap
  /// entri punya savepoint sendiri. Hasil per entri urut sama.
  _ida.Future<_ia4kk4ai.SyncPushReply> push(
    String deviceToken,
    List<_ipv8demw.SyncPushEntry> entries,
  ) => caller.callServerEndpoint<_ia4kk4ai.SyncPushReply>(
    'sync',
    'push',
    {
      'deviceToken': deviceToken,
      'entries': entries,
    },
  );

  /// Perubahan tenant token dengan `seq > afterSeq`, maks [pullPageSize].
  /// Perubahan asal perangkat ini dilewati, tetapi kursor tetap maju.
  _ida.Future<_izun0ovl.SyncPullPage> pull(
    String deviceToken,
    int afterSeq,
  ) => caller.callServerEndpoint<_izun0ovl.SyncPullPage>(
    'sync',
    'pull',
    {
      'deviceToken': deviceToken,
      'afterSeq': afterSeq,
    },
  );

  /// Versi server dan protokol; `tenantKnown` bila [deviceToken] aktif.
  _ida.Future<_ikbjecyu.SyncServerStatus> status(String? deviceToken) =>
      caller.callServerEndpoint<_ikbjecyu.SyncServerStatus>(
        'sync',
        'status',
        {'deviceToken': deviceToken},
      );
}

/// Verifikasi 2 langkah akun pemilik untuk login web (F2-02 aturan 12–14),
/// diatur dari kartu *Versi hosting* di aplikasi perangkat.
/// {@category Endpoint}
class EndpointTotp extends _isc.EndpointRef {
  EndpointTotp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'totp';

  /// `true` bila TOTP akun ini sudah dikonfirmasi.
  _ida.Future<bool> status() => caller.callServerEndpoint<bool>(
    'totp',
    'status',
    {},
  );

  /// Rahasia baru yang belum berlaku sampai [confirm]. Menimpa rahasia lama
  /// yang belum dikonfirmasi; ditolak bila TOTP sudah aktif.
  ///
  /// [deviceToken] = token perangkat toko milik akun ini: kata sandi saja
  /// tidak cukup untuk mengaktifkan verifikasi 2 langkah, karena siapa pun
  /// yang mengaktifkannya bisa membuka toko di web (review C1).
  _ida.Future<_ib8bg96t.TotpEnrollment> begin(String deviceToken) =>
      caller.callServerEndpoint<_ib8bg96t.TotpEnrollment>(
        'totp',
        'begin',
        {'deviceToken': deviceToken},
      );

  /// Mengonfirmasi rahasia dari [begin] dengan satu kode; membalas 8 kode
  /// cadangan (ditampilkan sekali, server menyimpan hash-nya).
  _ida.Future<List<String>> confirm(
    String deviceToken,
    String code,
  ) => caller.callServerEndpoint<List<String>>(
    'totp',
    'confirm',
    {
      'deviceToken': deviceToken,
      'code': code,
    },
  );

  /// Mematikan TOTP dengan kode authenticator atau kode cadangan (aturan
  /// 14); rahasia dan kode cadangan dihapus.
  _ida.Future<void> disable(
    String deviceToken,
    String code,
  ) => caller.callServerEndpoint<void>(
    'totp',
    'disable',
    {
      'deviceToken': deviceToken,
      'code': code,
    },
  );
}

/// Login web pemilik (F2-02 aturan 11–13a): akun email + kata sandi (JWT
/// Serverpod), lalu kode TOTP atau kode cadangan membuat perangkat web
/// tenant dengan token berumur.
///
/// Tidak memakai `requireLogin` karena [logout] dipanggil dengan token
/// perangkat saja; [tenants] dan [open] memeriksa login sendiri.
/// {@category Endpoint}
class EndpointWebAccess extends _isc.EndpointRef {
  EndpointWebAccess(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'webAccess';

  /// Toko milik akun yang sedang login. Melempar `noTenant` bila tidak ada
  /// dan `totpNotEnabled` bila verifikasi 2 langkah belum aktif.
  _ida.Future<List<_ib69tvb5.WebTenant>> tenants() =>
      caller.callServerEndpoint<List<_ib69tvb5.WebTenant>>(
        'webAccess',
        'tenants',
        {},
      );

  /// Memverifikasi [code] lalu mendaftarkan perangkat web baru tenant
  /// [tenantId] di cabang tertua, kode `W..`, token berlaku
  /// [webTokenRemembered] atau [webTokenSession].
  _ida.Future<_iwkl0izw.WebAccessResult> open(
    String code,
    _isc.UuidValue tenantId,
    bool remember,
  ) => caller.callServerEndpoint<_iwkl0izw.WebAccessResult>(
    'webAccess',
    'open',
    {
      'code': code,
      'tenantId': tenantId,
      'remember': remember,
    },
  );

  /// Mencabut token web [deviceToken] (menu *Keluar*). Token perangkat
  /// biasa (tanpa batas berlaku) tidak bisa dicabut dari sini.
  _ida.Future<void> logout(String deviceToken) =>
      caller.callServerEndpoint<void>(
        'webAccess',
        'logout',
        {'deviceToken': deviceToken},
      );

  /// `true` bila pemilik tenant perangkat [deviceToken] sudah mengaktifkan
  /// verifikasi 2 langkah (baris di kartu *Versi hosting*).
  _ida.Future<bool> twoFactorEnabled(String deviceToken) =>
      caller.callServerEndpoint<bool>(
        'webAccess',
        'twoFactorEnabled',
        {'deviceToken': deviceToken},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    mediaSync = EndpointMediaSync(this);
    activation = EndpointActivation(this);
    sync = EndpointSync(this);
    totp = EndpointTotp(this);
    webAccess = EndpointWebAccess(this);
    modules = Modules(this);
  }

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointMediaSync mediaSync;

  late final EndpointActivation activation;

  late final EndpointSync sync;

  late final EndpointTotp totp;

  late final EndpointWebAccess webAccess;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'mediaSync': mediaSync,
    'activation': activation,
    'sync': sync,
    'totp': totp,
    'webAccess': webAccess,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };

  /// Creates a new client-side database session for the given path.
  ///
  /// The [path] is the file path to the SQLite database file. Since SQLite uses
  /// WAL mode, note that `[path]-shm` and `[path]-wal` files might also exist
  /// transiently for the database while the session is open.
  ///
  /// If [runMigrations] is true, pending migrations will be applied when
  /// opening the database. Be careful when setting this to false, as it might
  /// lead to inconsistencies between the models and the database.
  ///
  /// If [isDebugMode] is true, the database integrity will be verified after
  /// the migrations are applied to provide feedback of possible issues. On a
  /// Flutter application, this should be set to [kDebugMode].
  _ida.Future<_isd.ClientDatabaseSession> createSession(
    String path, {
    bool runMigrations = true,
    bool isDebugMode = false,
  }) async {
    return await _isd.ClientDatabaseSession.open(
      path,
      _il2as5qe.Protocol(),
      clientMigrations: MigrationRegistry.migrations,
      runMigrations: runMigrations,
      isDebugMode: isDebugMode,
    );
  }
}
