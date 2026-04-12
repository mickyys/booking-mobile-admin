import 'package:auth0_flutter/auth0_flutter.dart';
import '../models/user_model.dart';
import '../../../../core/config/app_config.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Auth0 auth0;

  AuthRemoteDataSourceImpl({required this.auth0});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final credentials = await auth0.api.login(
        usernameOrEmail: email,
        password: password,
        connectionOrRealm: 'Username-Password-Authentication',
        audience: AppConfig.auth0Audience,
        scopes: {'openid', 'profile', 'email'},
      );

      return UserModel(
        id: credentials.user.sub,
        email: credentials.user.email ?? email,
        token: credentials.accessToken,
      );
    } catch (e) {
      throw Exception('Login with credentials failed: $e');
    }
  }

  @override
  Future<void> logout() async {}
}
