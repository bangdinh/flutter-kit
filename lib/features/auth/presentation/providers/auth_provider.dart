import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';

part 'auth_provider.g.dart';

/// Represents the authentication state.
class AuthState {
  const AuthState({this.user, this.isLoggedIn = false});

  final User? user;
  final bool isLoggedIn;

  AuthState copyWith({User? user, bool? isLoggedIn}) {
    return AuthState(
      user: user ?? this.user,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

/// Manages auth state reactively.
///
/// Andrea's tip #46: ref.watch vs ref.read vs ref.listen
/// — Widgets use ref.watch(authStateProvider) to rebuild on changes.
/// — One-shot actions use ref.read(authStateProvider.notifier).login(...)
@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  FutureOr<AuthState> build() async {
    final repo = ref.watch(authRepositoryProvider);
    final user = await repo.getCurrentUser();
    return AuthState(
      user: user,
      isLoggedIn: user != null,
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.login(email: email, password: password);
      return AuthState(user: user, isLoggedIn: true);
    });
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(AuthState());
  }
}
