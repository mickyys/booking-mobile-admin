import 'package:auth0_flutter/auth0_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Auth0 auth0;

  AuthRemoteDataSourceImpl({required this.auth0});

  @override
  Future<UserModel> login() async {
    try {
      final credentials = await auth0.webAuthentication(scheme: 'demo').login();

      return UserModel(
        id: credentials.user.sub,
        email: credentials.user.email ?? '',
        token: credentials.accessToken,
      );
    } catch (e) {
      throw Exception('Login with Auth0 failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await auth0.webAuthentication(scheme: 'demo').logout();
    } catch (e) {
      throw Exception('Logout with Auth0 failed: $e');
    }
  }
}
