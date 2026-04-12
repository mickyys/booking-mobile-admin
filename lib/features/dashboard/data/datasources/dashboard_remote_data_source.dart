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
      print('DashboardRemoteDataSource: Fetching dashboard data...');
      final response = await dio.get('/admin/dashboard');
      if (response.statusCode == 200) {
        print('DashboardRemoteDataSource: Data fetched successfully');
        return DashboardDataModel.fromJson(response.data);
      } else {
        print('DashboardRemoteDataSource: Failed with status ${response.statusCode}');
        throw Exception('Failed to load dashboard data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DashboardRemoteDataSource: DioException - ${e.message}');
      rethrow;
    } catch (e) {
      print('DashboardRemoteDataSource: Unexpected error - $e');
      rethrow;
    }
  }
}
