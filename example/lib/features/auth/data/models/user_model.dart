import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Data transfer object — knows how to serialize/deserialize JSON.
///
/// Separated from [User] entity so the domain layer stays pure.
/// The [toEntity] method bridges data -> domain.
@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String email,
    required String name,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Converts this DTO to a domain [User] entity.
  User toEntity() =>
      User(id: id, email: email, name: name, avatarUrl: avatarUrl);
}
