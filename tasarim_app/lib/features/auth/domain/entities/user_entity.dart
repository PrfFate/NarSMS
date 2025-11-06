class UserEntity {
  final int id;
  final String? username;
  final String email;
  final String? phone;
  final int roleId;
  final String? roleName;

  const UserEntity({
    required this.id,
    required this.email,
    this.username,
    this.phone,
    required this.roleId,
    this.roleName,
  });
}
