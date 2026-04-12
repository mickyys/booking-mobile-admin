import 'package:auth0_flutter/auth0_flutter.dart';
import '../models/user_model.dart';

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
      // Corrected parameters for auth0.api.login based on analyzer errors
      final credentials = await auth0.api.login(
        usernameOrEmail: email,
        password: password,
        connectionOrRealm: 'Username-Password-Authentication',
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
