import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

part 'auth_repository_impl.g.dart';

/// Provides the [AuthRepository] implementation via Riverpod.
///
/// Andrea's tip #41: Using fake repositories for testing
/// — override this provider with a FakeAuthRepository in tests.
@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  final AuthRemoteDataSource remoteDataSource;
  final SecureStorage secureStorage;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final userModel = await remoteDataSource.login(
      email: email,
      password: password,
    );

    // TODO: Save token from response
    // await secureStorage.setAccessToken(response.token);

    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await secureStorage.clearAll();
  }

  @override
  Future<User?> getCurrentUser() async {
    final hasToken = await secureStorage.hasToken();
    if (!hasToken) return null;

    final userModel = await remoteDataSource.getProfile();
    return userModel.toEntity();
  }

  @override
  Future<bool> isLoggedIn() async {
    return secureStorage.hasToken();
  }
}
