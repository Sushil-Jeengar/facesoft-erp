import 'user_model.dart';

class AuthData {
  final String message;
  final String token;
  final User user;

  AuthData({
    required this.message,
    required this.token,
    required this.user,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      message: json['message'],
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'token': token,
      'user': user.toJson(),
    };
  }
}
