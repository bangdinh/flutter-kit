import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// Domain entity — pure business object, no JSON, no framework.
///
/// Andrea's tip #28: DDD — The Domain Model
/// — entities belong to the domain layer and have no dependency on data/infra.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    String? avatarUrl,
  }) = _User;
}
