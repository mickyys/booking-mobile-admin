import 'package:dio/dio.dart';
import '../models/booking_model.dart';
import '../models/schedule_model.dart';
import '../models/sport_center_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardDataModel> getDashboardData();
  Future<List<CourtScheduleModel>> getAgenda(String sportCenterId, String date);
  Future<List<AdminSportCenterCourtsModel>> getAdminCourts();
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
  Future<List<CourtScheduleModel>> getAgenda(String sportCenterId, String date) async {
    try {
      print('DashboardRemoteDataSource: Fetching agenda for SportCenter $sportCenterId on $date...');
      final response = await dio.get('/sport-centers/$sportCenterId/schedules/bookings', queryParameters: {'date': date, 'all': true});
      if (response.statusCode == 200) {
        print('AGENDA RAW DATA: ${response.data}');
        final List rawList = response.data as List;
        // The endpoint returns a list of courts directly according to the docs,
        // but if it's wrapped like the example provided for /admin/courts, handle it.
        if (rawList.isNotEmpty && rawList.first is Map && rawList.first.containsKey('courts')) {
          return (rawList.first['courts'] as List).map((e) => CourtScheduleModel.fromJson(e)).toList();
        }
        return rawList.map((e) => CourtScheduleModel.fromJson(e)).toList();
      } else {
        print('DashboardRemoteDataSource: Failed to load agenda with status ${response.statusCode}');
        throw Exception('Failed to load agenda: ${response.statusCode}');
      }
    } catch (e) {
      print('DashboardRemoteDataSource: Error fetching agenda - $e');
      rethrow;
    }
  }

  @override
  Future<List<AdminSportCenterCourtsModel>> getAdminCourts() async {
    try {
      print('DashboardRemoteDataSource: Fetching admin courts...');
      final response = await dio.get('/admin/courts');
      if (response.statusCode == 200) {
        return (response.data as List).map((e) => AdminSportCenterCourtsModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load admin courts: ${response.statusCode}');
      }
    } catch (e) {
      print('DashboardRemoteDataSource: Error fetching admin courts - $e');
      rethrow;
    }
  }
}
