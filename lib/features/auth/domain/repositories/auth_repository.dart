import '../entities/user.dart';

/// Abstract contract for auth operations.
///
/// Andrea's tip #21: Repositories as abstract classes
/// — domain defines the contract, data provides the implementation.
/// This enables easy swapping for tests (tip #41: Fake repositories).
abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isLoggedIn();
}
