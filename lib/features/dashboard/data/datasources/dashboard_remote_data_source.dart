import 'package:dio/dio.dart';
import '../models/booking_model.dart';
import '../models/schedule_model.dart';
import '../models/sport_center_model.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardDataModel> getDashboardData({DashboardParams? params});
  Future<List<CourtScheduleModel>> getAgenda(String sportCenterId, String date);
  Future<List<AdminSportCenterCourtsModel>> getAdminCourts();
  Future<AdminCourtModel> addCourt(String sportCenterId, String name, String description);
  Future<void> updateCourt(String courtId, String name, String description);
  Future<void> deleteCourt(String courtId);
  Future<BookingModel> createInternalBooking(Map<String, dynamic> bookingData);
  Future<void> cancelBooking(String bookingId);
  Future<void> updateCourtSlot(String courtId, Map<String, dynamic> slotData);
  Future<void> updateCourtSchedule(String courtId, List<Map<String, dynamic>> scheduleData);
  Future<AdminSportCenterModel> getSportCenterSettings(String id);
  Future<void> updateSportCenter(String id, Map<String, dynamic> data);
  Future<void> updateSportCenterSettings(String id, Map<String, dynamic> settings);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<DashboardDataModel> getDashboardData({DashboardParams? params}) async {
    try {
      final queryParams = {
        'date': params?.date,
        'customer_name': params?.customerName,
        'booking_code': params?.bookingCode,
        'status': params?.status,
        'page': params?.page,
      };
      queryParams.removeWhere((key, value) => value == null);

      print('📡 DIO REQUEST: GET /admin/dashboard?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}');
      final response = await dio.get('/admin/dashboard', queryParameters: queryParams);
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
      print('📅 REQUEST: GET /sport-centers/$sportCenterId/schedules/bookings?date=$date&all=true');
      final response = await dio.get(
        '/sport-centers/$sportCenterId/schedules/bookings',
        queryParameters: {'date': date, 'all': true},
      );
      if (response.statusCode == 200) {
        final dynamic data = response.data;
        List<dynamic> rawList = [];
        
        if (data is List) {
          rawList = data;
        } else if (data is Map && data.containsKey('courts')) {
          rawList = data['courts'] as List;
        } else if (data is Map && data.containsKey('data')) {
          rawList = data['data'] as List;
        }

        print('📅 Agenda API response: $rawList');
          for (var court in (rawList.first['courts'] ?? rawList)) {
            if (court is Map && court['slots'] != null) {
              print('🎾 Court: ${court['name']} - Slots: ${court['slots']}');
            }
          }
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
        final dynamic data = response.data;
        List<dynamic> list = [];
        
        if (data is List) {
          list = data;
        } else if (data is Map) {
          list = data['data'] ?? data['courts'] ?? [];
        }
        
        return list
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
      print('🚀 POST /admin/bookings/internal body: $bookingData');
      final response = await dio.post('/admin/bookings/internal', data: bookingData);
      print('📬 Create booking response: ${response.statusCode} - ${response.data}');
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

  @override
  Future<void> updateCourtSlot(String courtId, Map<String, dynamic> slotData) async {
    try {
      final response = await dio.patch('/admin/courts/$courtId/schedule/slot', data: slotData);
      if (response.statusCode != 200) {
        throw Exception('Failed to update slot: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateCourtSchedule(String courtId, List<Map<String, dynamic>> scheduleData) async {
    try {
      final response = await dio.put('/admin/courts/$courtId/schedule', data: scheduleData);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update schedule: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AdminSportCenterModel> getSportCenterSettings(String id) async {
    try {
      final response = await dio.get('/admin/sport-centers/$id');
      if (response.statusCode == 200) {
        return AdminSportCenterModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load sport center settings: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateSportCenter(String id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put('/admin/sport-centers/$id', data: data);
      if (response.statusCode != 200) {
        throw Exception('Failed to update sport center: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateSportCenterSettings(String id, Map<String, dynamic> settings) async {
    try {
      final response = await dio.patch('/admin/sport-centers/$id/settings', data: settings);
      if (response.statusCode != 200) {
        throw Exception('Failed to update settings: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
