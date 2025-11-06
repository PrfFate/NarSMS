class RegisterRequestModel {
  final String username;
  final String email;
  final String phone;
  final String password;
  final int roleId;

  RegisterRequestModel({
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    required this.roleId,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'phone': phone,
      'password': password,
      'roleId': roleId,
    };
  }
}
