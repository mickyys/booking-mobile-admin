import 'package:equatable/equatable.dart';
import 'booking.dart';

class CourtSchedule extends Equatable {
  final String courtId;
  final String courtName;
  final List<TimeSlot> slots;

  const CourtSchedule({
    required this.courtId,
    required this.courtName,
    required this.slots,
  });

  @override
  List<Object?> get props => [courtId, courtName, slots];
}

class TimeSlot extends Equatable {
  final int hour;
  final int minutes;
  final double price;
  final String status;
  final bool paymentRequired;
  final bool paymentOptional;
  final Booking? booking;

  const TimeSlot({
    required this.hour,
    required this.minutes,
    required this.price,
    required this.status,
    required this.paymentRequired,
    required this.paymentOptional,
    this.booking,
  });

  @override
  List<Object?> get props => [
        hour,
        minutes,
        price,
        status,
        paymentRequired,
        paymentOptional,
        booking,
      ];

  bool get isAvailable => status == 'available';
  bool get isBlocked => status == 'closed' || status == 'blocked';
}
