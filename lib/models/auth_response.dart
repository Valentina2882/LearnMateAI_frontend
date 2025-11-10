import 'user.dart';

class AuthResponse {
  final bool success;
  final String? token;
  final User? user;
  final String? message;
  final String? error;

  AuthResponse({
    required this.success,
    this.token,
    this.user,
    this.message,
    this.error,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      message: json['message'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'token': token,
      'user': user?.toJson(),
      'message': message,
      'error': error,
    };
  }
}
