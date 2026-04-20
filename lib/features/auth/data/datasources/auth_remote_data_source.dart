import 'package:auth0_flutter/auth0_flutter.dart';
import '../models/user_model.dart';
import '../../../../core/config/app_config.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> loginWithSocial(String connection);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Auth0 auth0;

  AuthRemoteDataSourceImpl({required this.auth0});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      print('AUTH REMOTE: Attempting login for: $email');

      final credentials = await auth0.api.login(
        usernameOrEmail: email,
        password: password,
        connectionOrRealm: 'Username-Password-Authentication',
        audience: AppConfig.auth0Audience,
        scopes: {'openid', 'profile', 'email'},
      );

      return UserModel(
        id: credentials.user.sub,
        name: credentials.user.name ?? email,
        email: credentials.user.email ?? email,
        token: credentials.accessToken,
      );
    } catch (e) {
      print('AUTH REMOTE: Login failed: $e');
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<UserModel> loginWithSocial(String connection) async {
    try {
      print('AUTH REMOTE: Attempting social login with: $connection');

      // Using parameters map as a safer way if 'connection' named param is causing issues in this environment
      final credentials = await auth0.webAuthentication(scheme: 'reservaloya').login(
            audience: AppConfig.auth0Audience,
            scopes: {'openid', 'profile', 'email'},
            parameters: {'connection': connection},
          );

      return UserModel(
        id: credentials.user.sub,
        name: credentials.user.name ?? '',
        email: credentials.user.email ?? '',
        token: credentials.accessToken,
      );
    } catch (e) {
      print('AUTH REMOTE: Social login failed: $e');
      throw Exception('Social login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await auth0.webAuthentication(scheme: 'reservaloya').logout();
    } catch (e) {
      print('AUTH REMOTE: Logout failed: $e');
      throw Exception('Logout failed: $e');
    }
  }
}
