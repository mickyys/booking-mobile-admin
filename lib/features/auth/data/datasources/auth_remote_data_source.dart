import 'package:dio/dio.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String email, String password) async {
    // Note: Documentation mentions Auth0, but here I'll assume a standard /login
    // or placeholder based on provided API docs structure.
    try {
      // Mocking response for now as I don't have the exact login endpoint details from the md
      // But I will simulate a successful login.
      await Future.delayed(const Duration(seconds: 1));
      return const UserModel(
        id: '1',
        email: 'admin@reservaloya.cl',
        token: 'mock_jwt_token',
      );

      /*
      final response = await dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception();
      }
      */
    } catch (e) {
      throw Exception('Login failed');
    }
  }
}
