import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.customerName,
    required super.bookingCode,
    required super.date,
    required super.hour,
    required super.courtName,
    required super.status,
    required super.price,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      customerName: json['customer_name'] ?? '',
      bookingCode: json['booking_code'] ?? '',
      date: json['date'] ?? '',
      hour: json['hour'] ?? 0,
      courtName: json['court_name'] ?? '',
      status: json['status'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    required super.todayBookingsCount,
    required super.todayRevenue,
    required super.totalRevenue,
    required super.recentBookings,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      todayBookingsCount: json['today_bookings_count'] ?? 0,
      todayRevenue: (json['today_revenue'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      recentBookings: (json['recent_bookings'] as List?)
              ?.map((e) => BookingModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
