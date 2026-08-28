import 'package:flutter_kit_example/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_kit_example/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/fake_auth_repository.dart';

/// Provider test — demonstrates Riverpod testing pattern.
///
/// Key pattern: override authRepositoryProvider with FakeAuthRepository
/// so the test runs without network or storage.
void main() {
  late ProviderContainer container;
  late FakeAuthRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeAuthRepository();
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(fakeRepo)],
    );
    addTearDown(container.dispose);
  });

  group('AuthStateNotifier', () {
    test('initial state — no current user → not logged in', () async {
      // Wait for the async build to complete
      final sub = container.listen(authStateProvider, (_, __) {});
      // Allow the Future to resolve
      await container.read(authStateProvider.future);

      final state = sub.read();
      expect(state.value?.isLoggedIn, isFalse);
      expect(state.value?.user, isNull);
    });

    test('login success → logged in with user', () async {
      // Wait for initial build
      await container.read(authStateProvider.future);

      // Act
      await container
          .read(authStateProvider.notifier)
          .login(email: 'test@example.com', password: '123456');

      // Assert
      final state = await container.read(authStateProvider.future);
      expect(state.isLoggedIn, isTrue);
      expect(state.user?.email, 'test@example.com');
      expect(fakeRepo.loginCallCount, 1);
    });

    test('login failure → error state', () async {
      // Wait for initial build to succeed first
      await container.read(authStateProvider.future);

      // Now make subsequent calls throw
      fakeRepo.shouldThrow = true;

      // Act
      await container
          .read(authStateProvider.notifier)
          .login(email: 'test@example.com', password: 'wrong');

      // Assert
      final state = container.read(authStateProvider);
      expect(state.hasError, isTrue);
    });

    test('logout → not logged in', () async {
      // Setup: login first
      await container.read(authStateProvider.future);
      await container
          .read(authStateProvider.notifier)
          .login(email: 'test@example.com', password: '123456');

      // Act
      await container.read(authStateProvider.notifier).logout();

      // Assert
      final state = await container.read(authStateProvider.future);
      expect(state.isLoggedIn, isFalse);
      expect(state.user, isNull);
      expect(fakeRepo.logoutCallCount, 1);
    });
  });
}
