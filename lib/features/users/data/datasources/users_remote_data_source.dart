import 'package:dio/dio.dart';
import 'package:reservaloya_admin/features/users/data/models/user_model.dart';

abstract class UsersRemoteDataSource {
  Future<List<UserModel>> getUsers();
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final Dio dio;

  UsersRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await dio.get('/api/admin/users');
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> usersData = response.data;
        return usersData.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Error fetching users: $e');
    }
  }
}
