import 'package:dio/dio.dart';
import 'package:flutter_kit/flutter_kit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/user_model.dart';

part 'auth_remote_data_source.g.dart';

/// Raw HTTP calls for the auth endpoints — URLs and JSON, nothing else.
/// Error mapping and token persistence belong to the repository.
@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSource(dio: ref.watch(apiClientProvider));
}

/// Payload of a successful `POST /auth/login`.
typedef LoginResult = ({UserModel user, String accessToken});

class AuthRemoteDataSource {
  AuthRemoteDataSource({required this.dio});

  final Dio dio;

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/auth/login',
      // App rule: the login endpoint must not carry a stale token.
      options: Options(extra: {'skip_auth': true}),
      data: {'email': email, 'password': password},
    );
    final data = response.data!['data']! as Map<String, dynamic>;
    return (
      user: UserModel.fromJson(data['user']! as Map<String, dynamic>),
      accessToken: data['accessToken']! as String,
    );
  }

  Future<void> logout() => dio.post('/auth/logout');

  Future<UserModel> getProfile() async {
    final response = await dio.get<Map<String, dynamic>>('/auth/profile');
    return UserModel.fromJson(response.data!['data']! as Map<String, dynamic>);
  }
}
