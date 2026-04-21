import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../../../core/config/app_config.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> loginWithSocial(String connection);
  Future<String> getAccessTokenSilently();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Auth0 auth0;

  AuthRemoteDataSourceImpl({required this.auth0});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      debugPrint('AUTH0: Attempting login for: $email');
      debugPrint('AUTH0: Domain: ${AppConfig.auth0Domain}');
      debugPrint('AUTH0: Audience: ${AppConfig.auth0Audience}');

      final credentials = await auth0.api.login(
        usernameOrEmail: email,
        password: password,
        connectionOrRealm: 'Username-Password-Authentication',
        audience: AppConfig.auth0Audience,
        scopes: {'openid', 'profile', 'email'},
      );

      debugPrint('AUTH0: Login success - User: ${credentials.user.sub}');
      return UserModel(
        id: credentials.user.sub,
        name: credentials.user.name ?? email,
        email: credentials.user.email ?? email,
        token: credentials.accessToken,
      );
    } catch (e, stack) {
      debugPrint('AUTH0: Login failed - Error: $e');
      debugPrint('AUTH0: Stack trace: $stack');
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<UserModel> loginWithSocial(String connection) async {
    try {
      debugPrint('AUTH0: Attempting social login - Connection: $connection');
      debugPrint('AUTH0: Domain: ${AppConfig.auth0Domain}');
      debugPrint('AUTH0: Audience: ${AppConfig.auth0Audience}');

      final credentials = await auth0.webAuthentication(scheme: 'reservaloya').login(
            audience: AppConfig.auth0Audience,
            scopes: {'openid', 'profile', 'email'},
            parameters: {'connection': connection},
          );

      debugPrint('AUTH0: Social login success - User: ${credentials.user.sub}');
      return UserModel(
        id: credentials.user.sub,
        name: credentials.user.name ?? '',
        email: credentials.user.email ?? '',
        token: credentials.accessToken,
      );
    } catch (e, stack) {
      debugPrint('AUTH0: Social login failed - Error: $e');
      debugPrint('AUTH0: Stack trace: $stack');
      throw Exception('Social login failed: $e');
    }
  }

  @override
  Future<String> getAccessTokenSilently() async {
    try {
      debugPrint('AUTH0: Getting access token silently');
      debugPrint('AUTH0: Audience: ${AppConfig.auth0Audience}');
      
      final credentials = await auth0.credentialsManager.credentials(
        scopes: {'openid', 'profile', 'email'},
      );
      
      debugPrint('AUTH0: Token obtained: ${credentials.accessToken.substring(0, 20)}...');
      return credentials.accessToken;
    } catch (e, stack) {
      debugPrint('AUTH0: getAccessTokenSilently failed - Error: $e');
      debugPrint('AUTH0: Stack trace: $stack');
      throw Exception('Failed to get token: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      debugPrint('AUTH0: Attempting logout');
      await auth0.webAuthentication(scheme: 'reservaloya').logout();
      debugPrint('AUTH0: Logout success');
    } catch (e, stack) {
      debugPrint('AUTH0: Logout failed - Error: $e');
      debugPrint('AUTH0: Stack trace: $stack');
      throw Exception('Logout failed: $e');
    }
  }
}
