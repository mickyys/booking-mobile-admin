import '../../domain/entities/schedule.dart';
import 'booking_model.dart';

class CourtScheduleModel extends CourtSchedule {
  const CourtScheduleModel({
    required super.courtId,
    required super.courtName,
    required List<TimeSlotModel> super.slots,
  });

  factory CourtScheduleModel.fromJson(Map<String, dynamic> json) {
    return CourtScheduleModel(
      courtId: json['court_id'] ?? '',
      courtName: json['court_name'] ?? '',
      slots: (json['slots'] as List?)
              ?.map((e) => TimeSlotModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TimeSlotModel extends TimeSlot {
  const TimeSlotModel({
    required super.hour,
    required super.isAvailable,
    required super.isBlocked,
    super.booking,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      hour: json['hour'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      isBlocked: json['is_blocked'] ?? false,
      booking: json['booking'] != null ? BookingModel.fromJson(json['booking']) : null,
    );
  }
}
