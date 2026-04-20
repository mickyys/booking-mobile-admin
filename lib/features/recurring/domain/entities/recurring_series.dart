import 'package:equatable/equatable.dart';

enum RecurringType { weekly, series }

class RecurringSeries extends Equatable {
  final String id;
  final String customerName;
  final String customerPhone;
  final String courtName;
  final String dayOfWeek;
  final String time;
  final int totalBookings;
  final int confirmedBookings;
  final String status;
  final RecurringType type;
  final double price;
  final String startDate;
  final String endDate;
  final String createdAt;

  const RecurringSeries({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.courtName,
    required this.dayOfWeek,
    required this.time,
    required this.totalBookings,
    required this.confirmedBookings,
    required this.status,
    required this.type,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        customerName,
        customerPhone,
        courtName,
        dayOfWeek,
        time,
        totalBookings,
        confirmedBookings,
        status,
        type,
        price,
        startDate,
        endDate,
        createdAt,
      ];
}
