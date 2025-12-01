import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.username,
    super.phone,
    required super.roleId,
    super.roleName,
  });

  // Backend'den gelen JSON'u parse et
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      roleId: json['roleId'] as int,
      roleName: json['role']?['name'] as String?, // Role nesnesinden name'i al
    );
  }

  // Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone': phone,
      'roleId': roleId,
    };
  }

  // Entity'den Model'e dönüştür
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      username: entity.username,
      phone: entity.phone,
      roleId: entity.roleId,
      roleName: entity.roleName,
    );
  }
}
