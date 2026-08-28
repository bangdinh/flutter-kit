import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/secure_storage.dart';

part 'token_store.g.dart';

/// Contract the kit's [AuthInterceptor] reads credentials through.
///
/// The kit ships [SecureTokenStore] (flutter_secure_storage). An app with
/// different rules — cookie session, OAuth library, tokens held in memory —
/// implements this and overrides [tokenStoreProvider].
abstract interface class TokenStore {
  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> saveTokens({required String accessToken, String? refreshToken});

  Future<void> clear();
}

/// Default [TokenStore] backed by [SecureStorage].
class SecureTokenStore implements TokenStore {
  const SecureTokenStore(this._storage);

  final SecureStorage _storage;

  @override
  Future<String?> readAccessToken() => _storage.getAccessToken();

  @override
  Future<String?> readRefreshToken() => _storage.getRefreshToken();

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.setAccessToken(accessToken);
    if (refreshToken != null) {
      await _storage.setRefreshToken(refreshToken);
    }
  }

  @override
  Future<void> clear() => _storage.clearAll();
}

@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) =>
    SecureTokenStore(ref.watch(secureStorageProvider));

/// Refreshes the access token after a `401`.
///
/// Return `true` if a fresh token was stored (the failed request is replayed),
/// `false` to give up (the caller sees [UnauthorizedException]).
typedef TokenRefresher = Future<bool> Function();

/// App rule: how to refresh an expired token. `null` = no refresh, a `401`
/// surfaces immediately.
@Riverpod(keepAlive: true)
TokenRefresher? tokenRefresher(Ref ref) => null;

/// App rule: what to do when auth is definitively lost (clear session,
/// navigate to login, show a dialog…). Runs after refresh failed or was absent.
@Riverpod(keepAlive: true)
void Function()? unauthorizedHandler(Ref ref) => null;
