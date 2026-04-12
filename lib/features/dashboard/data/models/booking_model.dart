import '../../domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.customerName,
    required super.customerPhone,
    required super.customerEmail,
    required super.bookingCode,
    required super.date,
    required super.hour,
    required super.courtName,
    required super.status,
    required super.paymentMethod,
    required super.price,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      bookingCode: json['booking_code'] ?? '',
      date: json['date'] ?? '',
      hour: json['hour'] ?? 0,
      courtName: json['court_name'] ?? '',
      status: json['status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    required super.todayBookingsCount,
    required super.todayRevenue,
    required super.todayOnlineRevenue,
    required super.todayVenueRevenue,
    required super.totalRevenue,
    required super.totalOnlineRevenue,
    required super.totalVenueRevenue,
    required super.cancelledCount,
    required super.recentBookings,
    required super.page,
    required super.limit,
    required super.totalPages,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      todayBookingsCount: json['today_bookings_count'] ?? 0,
      todayRevenue: (json['today_revenue'] as num?)?.toDouble() ?? 0.0,
      todayOnlineRevenue: (json['today_online_revenue'] as num?)?.toDouble() ?? 0.0,
      todayVenueRevenue: (json['today_venue_revenue'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalOnlineRevenue: (json['total_online_revenue'] as num?)?.toDouble() ?? 0.0,
      totalVenueRevenue: (json['total_venue_revenue'] as num?)?.toDouble() ?? 0.0,
      cancelledCount: json['cancelled_count'] ?? 0,
      recentBookings: (json['recent_bookings'] as List?)
              ?.map((e) => BookingModel.fromJson(e))
              .toList() ??
          [],
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}
