import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int? id;
  final String? username;
  final String email;
  final String? phone;
  final int? roleId;
  final String? roleName;

  const UserEntity({
    this.id,
    required this.email,
    this.username,
    this.phone,
    this.roleId,
    this.roleName,
  });

  @override
  List<Object?> get props => [id, username, email, phone, roleId, roleName];

  UserEntity copyWith({
    int? id,
    String? username,
    String? email,
    String? phone,
    int? roleId,
    String? roleName,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
    );
  }
}
