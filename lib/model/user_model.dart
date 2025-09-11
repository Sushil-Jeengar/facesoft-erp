class User {
  final int id;
  final String? email;
  final String? phoneNumber;
  final int roleId;

  User({
    required this.id,
    this.email,
    this.phoneNumber,
    required this.roleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      roleId: json['role_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_number': phoneNumber,
      'role_id': roleId,
    };
  }
}
