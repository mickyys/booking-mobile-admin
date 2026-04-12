import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String id;
  final String customerName;
  final String bookingCode;
  final String date;
  final int hour;
  final String courtName;
  final String status;
  final double price;

  const Booking({
    required this.id,
    required this.customerName,
    required this.bookingCode,
    required this.date,
    required this.hour,
    required this.courtName,
    required this.status,
    required this.price,
  });

  @override
  List<Object?> get props => [id, customerName, bookingCode, date, hour, courtName, status, price];
}

class DashboardData extends Equatable {
  final int todayBookingsCount;
  final double todayRevenue;
  final double totalRevenue;
  final List<Booking> recentBookings;

  const DashboardData({
    required this.todayBookingsCount,
    required this.todayRevenue,
    required this.totalRevenue,
    required this.recentBookings,
  });

  @override
  List<Object?> get props => [todayBookingsCount, todayRevenue, totalRevenue, recentBookings];
}
