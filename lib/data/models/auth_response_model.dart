import 'user_model.dart';

class AuthResponseModel {
  final bool success;
  final String message;
  final String? token;
  final UserModel? user;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    
    return AuthResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: data != null ? data['token'] : null,
      user: data != null && data['user'] != null 
          ? UserModel.fromJson(data['user']) 
          : null,
    );
  }
}