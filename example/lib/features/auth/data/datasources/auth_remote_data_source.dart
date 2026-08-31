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
    // ApiData unwraps the gokit `{"data": ...}` envelope — never index into
    // response.data['data'] by hand.
    final payload =
        ApiData<Map<String, dynamic>>.fromJson(
          response.data!,
          (json) => json! as Map<String, dynamic>,
        ).data;
    return (
      user: UserModel.fromJson(payload['user']! as Map<String, dynamic>),
      accessToken: payload['accessToken']! as String,
    );
  }

  Future<void> logout() => dio.post('/auth/logout');

  Future<UserModel> getProfile() async {
    final response = await dio.get<Map<String, dynamic>>('/auth/profile');
    return ApiData<UserModel>.fromJson(
      response.data!,
      (json) => UserModel.fromJson(json! as Map<String, dynamic>),
    ).data;
  }
}
