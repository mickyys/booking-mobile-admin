import '../../domain/entities/schedule.dart';
import 'booking_model.dart';

class CourtScheduleModel extends CourtSchedule {
  const CourtScheduleModel({
    required super.courtId,
    required super.courtName,
    required List<TimeSlotModel> super.slots,
  });

  factory CourtScheduleModel.fromJson(Map<String, dynamic> json) {
    // Backend may return 'slots' or 'schedule'
    final rawSlots = (json['slots'] ?? json['schedule']) as List?;
    return CourtScheduleModel(
      courtId: (json['id'] ?? json['court_id'] ?? json['courtId'] ?? '').toString(),
      courtName: json['name'] ?? json['court_name'] ?? json['courtName'] ?? '',
      slots: rawSlots?.map((e) => TimeSlotModel.fromJson(e)).toList() ?? [],
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
    final status = json['status']?.toString().toLowerCase();
    return TimeSlotModel(
      hour: json['hour'] ?? 0,
      isAvailable: status == 'available',
      isBlocked: status == 'closed' || status == 'blocked',
      booking: json['booking'] != null ? BookingModel.fromJson(json['booking']) : null,
    );
  }
}
