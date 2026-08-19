import 'package:flutter_kit/features/auth/domain/entities/user.dart';
import 'package:flutter_kit/features/auth/domain/repositories/auth_repository.dart';

/// Fake implementation for testing — no network, no storage.
///
/// Andrea's tip #41: Using fake repositories for testing
/// — override the Riverpod provider with this in tests.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    this.loginResult,
    this.currentUser,
    this.shouldThrow = false,
  });

  User? loginResult;
  User? currentUser;
  bool shouldThrow;

  int loginCallCount = 0;
  int logoutCallCount = 0;

  @override
  Future<User> login({required String email, required String password}) async {
    loginCallCount++;
    if (shouldThrow) throw Exception('Login failed');
    return loginResult ??
        User(id: '1', email: email, name: 'Test User');
  }

  @override
  Future<void> logout() async {
    logoutCallCount++;
    currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    if (shouldThrow) throw Exception('Failed to get user');
    return currentUser;
  }

  @override
  Future<bool> isLoggedIn() async {
    return currentUser != null;
  }
}
