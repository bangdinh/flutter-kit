import 'package:flutter_kit/flutter_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

part 'auth_repository_impl.g.dart';

/// Override this provider with a fake in tests — see
/// `test/features/auth/data/fake_auth_repository.dart`.
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStore,
  });

  final AuthRemoteDataSource remoteDataSource;

  /// The kit's credential contract — the app never touches secure storage
  /// directly, so swapping the storage strategy stays a one-line override.
  final TokenStore tokenStore;

  @override
  Future<User> login({required String email, required String password}) async {
    final result = await remoteDataSource.login(
      email: email,
      password: password,
    );
    await tokenStore.saveTokens(accessToken: result.accessToken);
    return result.user.toEntity();
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await tokenStore.clear();
  }

  @override
  Future<User?> getCurrentUser() async {
    if (!await isLoggedIn()) return null;
    final userModel = await remoteDataSource.getProfile();
    return userModel.toEntity();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await tokenStore.readAccessToken();
    return token != null && token.isNotEmpty;
  }
}
