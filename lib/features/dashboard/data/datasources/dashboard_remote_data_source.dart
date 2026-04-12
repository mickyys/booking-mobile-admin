import 'package:dio/dio.dart';
import '../models/booking_model.dart';
import '../models/schedule_model.dart';
import '../models/sport_center_model.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardDataModel> getDashboardData();
  Future<List<CourtScheduleModel>> getAgenda(String sportCenterId, String date);
  Future<List<AdminSportCenterCourtsModel>> getAdminCourts();
  Future<AdminCourtModel> addCourt(String sportCenterId, String name, String description);
  Future<void> updateCourt(String courtId, String name, String description);
  Future<void> deleteCourt(String courtId);
  Future<BookingModel> createInternalBooking(Map<String, dynamic> bookingData);
  Future<void> cancelBooking(String bookingId);
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
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CourtScheduleModel>> getAgenda(String sportCenterId, String date) async {
    try {
      final response = await dio.get(
        '/sport-centers/$sportCenterId/schedules/bookings',
        queryParameters: {'date': date, 'all': true},
      );
      if (response.statusCode == 200) {
        final List rawList = response.data as List;
        if (rawList.isNotEmpty &&
            rawList.first is Map &&
            rawList.first.containsKey('courts')) {
          return (rawList.first['courts'] as List)
              .map((e) => CourtScheduleModel.fromJson(e))
              .toList();
        }
        return rawList.map((e) => CourtScheduleModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load agenda: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AdminSportCenterCourtsModel>> getAdminCourts() async {
    try {
      final response = await dio.get('/admin/courts');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => AdminSportCenterCourtsModel.fromJson(e))
            .toList();
      } else {
        throw Exception('Failed to load admin courts: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AdminCourtModel> addCourt(String sportCenterId, String name, String description) async {
    try {
      final response = await dio.post('/admin/courts', data: {
        'sport_center_id': sportCenterId,
        'name': name,
        'description': description,
      });
      if (response.statusCode == 201 || response.statusCode == 200) {
        return AdminCourtModel.fromJson(response.data);
      } else {
        throw Exception('Failed to add court: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateCourt(String courtId, String name, String description) async {
    try {
      final response = await dio.put('/admin/courts/$courtId', data: {
        'name': name,
        'description': description,
      });
      if (response.statusCode != 200) {
        throw Exception('Failed to update court: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteCourt(String courtId) async {
    try {
      final response = await dio.delete('/admin/courts/$courtId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete court: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BookingModel> createInternalBooking(Map<String, dynamic> bookingData) async {
    try {
      final response = await dio.post('/admin/bookings/internal', data: bookingData);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return BookingModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      final response = await dio.post('/bookings/$bookingId/cancel');
      if (response.statusCode != 200) {
        throw Exception('Failed to cancel booking: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
