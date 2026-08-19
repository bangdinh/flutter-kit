import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

part 'auth_remote_data_source.g.dart';

/// Handles raw HTTP calls for auth endpoints.
///
/// This layer knows about URLs and JSON — nothing else.
/// The repository composes this with storage and error handling.
@riverpod
AuthRemoteDataSource authRemoteDataSource(Ref ref) {
  return AuthRemoteDataSource(dio: ref.watch(apiClientProvider));
}

class AuthRemoteDataSource {
  AuthRemoteDataSource({required this.dio});

  final Dio dio;

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await dio.post('/auth/logout');
  }

  Future<UserModel> getProfile() async {
    final response = await dio.get('/auth/profile');
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
