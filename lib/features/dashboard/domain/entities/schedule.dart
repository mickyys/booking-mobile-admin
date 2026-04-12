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
  final bool isAvailable;
  final bool isBlocked;
  final Booking? booking;

  const TimeSlot({
    required this.hour,
    required this.isAvailable,
    required this.isBlocked,
    this.booking,
  });

  @override
  List<Object?> get props => [hour, isAvailable, isBlocked, booking];
}
