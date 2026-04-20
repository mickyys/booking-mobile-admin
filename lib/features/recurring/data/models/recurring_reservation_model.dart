import '../../domain/entities/recurring_reservation.dart';

class RecurringReservationModel extends RecurringReservation {
  const RecurringReservationModel({
    required super.id,
    required super.seriesId,
    required super.dayOfWeek,
    required super.startTime,
    required super.endTime,
    required super.courtName,
    required super.status,
    required super.startDate,
    required super.endDate,
  });

  factory RecurringReservationModel.fromJson(Map<String, dynamic> json) {
    return RecurringReservationModel(
      id: (json['id'] ?? '').toString(),
      seriesId: (json['series_id'] ?? '').toString(),
      dayOfWeek: json['day_of_week'] ?? 1,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      courtName: json['court_name'] ?? '',
      status: json['status'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
    );
  }
}
