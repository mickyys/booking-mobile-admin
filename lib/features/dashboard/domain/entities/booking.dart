import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String id;
  final String customerName;
  final String customerPhone;
  final String bookingCode;
  final String date;
  final int hour;
  final String courtName;
  final String status;
  final String paymentMethod;
  final double price;

  const Booking({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.bookingCode,
    required this.date,
    required this.hour,
    required this.courtName,
    required this.status,
    required this.paymentMethod,
    required this.price,
  });

  @override
  List<Object?> get props => [
        id,
        customerName,
        customerPhone,
        bookingCode,
        date,
        hour,
        courtName,
        status,
        paymentMethod,
        price,
      ];
}

class DashboardData extends Equatable {
  final int todayBookingsCount;
  final double todayRevenue;
  final double todayOnlineRevenue;
  final double todayVenueRevenue;
  final double totalRevenue;
  final double totalOnlineRevenue;
  final double totalVenueRevenue;
  final int cancelledCount;
  final List<Booking> recentBookings;
  final int page;
  final int limit;
  final int totalPages;

  const DashboardData({
    required this.todayBookingsCount,
    required this.todayRevenue,
    required this.todayOnlineRevenue,
    required this.todayVenueRevenue,
    required this.totalRevenue,
    required this.totalOnlineRevenue,
    required this.totalVenueRevenue,
    required this.cancelledCount,
    required this.recentBookings,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [
        todayBookingsCount,
        todayRevenue,
        todayOnlineRevenue,
        todayVenueRevenue,
        totalRevenue,
        totalOnlineRevenue,
        totalVenueRevenue,
        cancelledCount,
        recentBookings,
        page,
        limit,
        totalPages,
      ];
}
