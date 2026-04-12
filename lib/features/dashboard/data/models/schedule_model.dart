import '../../domain/entities/schedule.dart';
import 'booking_model.dart';

class CourtScheduleModel extends CourtSchedule {
  const CourtScheduleModel({
    required super.courtId,
    required super.courtName,
    required List<TimeSlotModel> super.slots,
  });

  factory CourtScheduleModel.fromJson(Map<String, dynamic> json) {
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
    required super.minutes,
    required super.price,
    required super.status,
    required super.paymentRequired,
    required super.paymentOptional,
    super.booking,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] ?? 'available').toString();
    final hasBooking = json['booking_id'] != null;

    return TimeSlotModel(
      hour: json['hour'] ?? 0,
      minutes: json['minutes'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: status,
      paymentRequired: json['payment_required'] ?? false,
      paymentOptional: json['payment_optional'] ?? false,
      booking: hasBooking ? BookingModel.fromJson(json) : null,
    );
  }
}
