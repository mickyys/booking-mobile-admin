import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      print('🔐 SAVING TOKEN: ${user.token}');
      await sharedPreferences.setString('jwt_token', user.token);
      print('🔐 TOKEN SAVED: ${user.token}');
      return Right(user);
    } catch (e) {
      return const Left(ServerFailure('Credenciales inválidas o error de conexión.'));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithSocial(String connection) async {
    try {
      final user = await remoteDataSource.loginWithSocial(connection);
      await sharedPreferences.setString('jwt_token', user.token);
      return Right(user);
    } catch (e) {
      return const Left(ServerFailure('Error en la autenticación social.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await sharedPreferences.remove('jwt_token');
      return const Right(null);
    } catch (e) {
      await sharedPreferences.remove('jwt_token');
      return const Left(ServerFailure('Error al cerrar sesión.'));
    }
  }

  @override
  Future<Either<Failure, User>> refreshToken() async {
    try {
      final user = await remoteDataSource.refreshToken();
      await sharedPreferences.setString('jwt_token', user.token);
      return Right(user);
    } catch (e) {
      return const Left(ServerFailure('Sesión expirada. Inicie sesión nuevamente.'));
    }
  }

  @override
  Future<Either<Failure, User>> getSavedUser() async {
    final token = sharedPreferences.getString('jwt_token');
    if (token == null) {
      return const Left(CacheFailure('No hay sesión guardada.'));
    }
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return const Left(CacheFailure('Token inválido.'));
      }
      final payload = json.decode(_decodeBase64(parts[1])) as Map<String, dynamic>;
      return Right(User(
        id: payload['sub'] ?? '',
        name: payload['name'] ?? payload['nickname'] ?? '',
        email: payload['email'] ?? '',
        token: token,
      ));
    } catch (e) {
      return const Left(CacheFailure('Token inválido.'));
    }
  }

  @override
  Future<bool> hasToken() async {
    final token = sharedPreferences.getString('jwt_token');
    return token != null && token.isNotEmpty;
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64 string');
    }
    return String.fromCharCodes(base64Decode(output));
  }
}
