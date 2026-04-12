import 'package:dio/dio.dart';
import '../models/booking_model.dart';
import '../models/schedule_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardDataModel> getDashboardData();
  Future<List<CourtScheduleModel>> getAgenda(String date);
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

  @override
  Future<List<CourtScheduleModel>> getAgenda(String date) async {
    try {
      print('DashboardRemoteDataSource: Fetching agenda for $date...');
      // Note: id is hardcoded as '1' for now, ideally this should come from user profile
      final response = await dio.get('/sport-centers/1/schedules/bookings', queryParameters: {'date': date, 'all': true});
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => CourtScheduleModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load agenda: ${response.statusCode}');
      }
    } catch (e) {
      print('DashboardRemoteDataSource: Error fetching agenda - $e');
      rethrow;
    }
  }
}
