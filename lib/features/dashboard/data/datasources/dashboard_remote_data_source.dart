import 'package:dio/dio.dart';
import '../models/booking_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardDataModel> getDashboardData();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<DashboardDataModel> getDashboardData() async {
    try {
      final response = await dio.get('/admin/dashboard');
      if (response.statusCode == 200) {
        return DashboardDataModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load dashboard data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error while fetching dashboard data: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while fetching dashboard data: $e');
    }
  }
}
