import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String userId;
  final String name;
  final String email;
  final String picture;
  final DateTime lastLogin;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.picture,
    required this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      name: json['name'],
      email: json['email'],
      picture: json['picture'],
      lastLogin: DateTime.parse(json['last_login']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'picture': picture,
      'last_login': lastLogin.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [userId, name, email, picture, lastLogin];
}
