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
  final bool partialPaymentEnabled;
  final int? dayOfWeek;
  final Booking? booking;

  const TimeSlot({
    required this.hour,
    required this.minutes,
    required this.price,
    required this.status,
    required this.paymentRequired,
    required this.paymentOptional,
    this.partialPaymentEnabled = false,
    this.dayOfWeek,
    this.booking,
  });

  TimeSlot copyWith({
    int? hour,
    int? minutes,
    double? price,
    String? status,
    bool? paymentRequired,
    bool? paymentOptional,
    bool? partialPaymentEnabled,
    int? dayOfWeek,
    Booking? booking,
  }) {
    return TimeSlot(
      hour: hour ?? this.hour,
      minutes: minutes ?? this.minutes,
      price: price ?? this.price,
      status: status ?? this.status,
      paymentRequired: paymentRequired ?? this.paymentRequired,
      paymentOptional: paymentOptional ?? this.paymentOptional,
      partialPaymentEnabled: partialPaymentEnabled ?? this.partialPaymentEnabled,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      booking: booking ?? this.booking,
    );
  }

  @override
  List<Object?> get props => [
        hour,
        minutes,
        price,
        status,
        paymentRequired,
        paymentOptional,
        partialPaymentEnabled,
        dayOfWeek,
        booking,
      ];

  bool get isAvailable => status == 'available';
  bool get isBlocked => status == 'closed' || status == 'blocked';
  bool get isGeneral => dayOfWeek == null;
}
