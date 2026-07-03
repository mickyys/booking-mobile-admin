import 'package:dio/dio.dart';
import '../../data/models/recurring_reservation_model.dart';
import '../../data/models/recurring_series_model.dart';
import 'recurring_remote_data_source.dart';

class RecurringRemoteDataSourceImpl implements RecurringRemoteDataSource {
  final Dio dio;

  RecurringRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<RecurringSeriesModel>> getRecurringSeries() async {
    final results = <RecurringSeriesModel>[];

    try {
      final responseRecurring = await dio.get('/admin/recurring');
      if (responseRecurring.statusCode == 200) {
        dynamic data = responseRecurring.data;
        List<dynamic> list;

        if (data is Map) {
          list = data['data'] ?? data['series'] ?? [];
        } else if (data is List) {
          list = data;
        } else {
          list = [];
        }

        for (var e in list) {
          if (e is Map) {
            e['type'] = 'weekly';
            results.add(RecurringSeriesModel.fromJson(Map<String, dynamic>.from(e)));
          }
        }
      }
    } catch (e) {
      // Ignore error for recurring endpoint
    }

    try {
      final responseSeries = await dio.get('/admin/bookings/series');
      if (responseSeries.statusCode == 200) {
        dynamic data = responseSeries.data;
        List<dynamic> list;

        if (data is Map) {
          list = data['data'] ?? data['series'] ?? [];
        } else if (data is List) {
          list = data;
        } else {
          list = [];
        }

        for (var e in list) {
          if (e is Map) {
            e['type'] = 'series';
            results.add(RecurringSeriesModel.fromJson(Map<String, dynamic>.from(e)));
          }
        }
      }
    } catch (e) {
      // Ignore error for series endpoint
    }

    return results;
  }

  @override
  Future<RecurringReservationModel> createRecurringReservation(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/admin/recurring', data: data);
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.data is Map && (response.data as Map).containsKey('error')) {
          final errorMsg = (response.data as Map)['error'] ?? 'Error desconocido';
          throw Exception(errorMsg.toString());
        }
        return RecurringReservationModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create recurring reservation: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map && errorData.containsKey('error')) {
        throw Exception(errorData['error'].toString());
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteSeries(String id) async {
    try {
      final response = await dio.delete('/admin/bookings/series/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete series: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> cancelRecurringReservation(String id) async {
    try {
      final response = await dio.delete('/admin/recurring/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to cancel recurring reservation: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
