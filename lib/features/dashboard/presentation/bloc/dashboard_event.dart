import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  final String? date;
  final String? customerName;
  final String? bookingCode;
  final String? status;
  final int page;
  final String? startDate;
  final String? endDate;

  const LoadDashboardData({
    this.date,
    this.customerName,
    this.bookingCode,
    this.status,
    this.page = 1,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [date, customerName, bookingCode, status, page, startDate, endDate];
}

class CancelDashboardBooking extends DashboardEvent {
  final String bookingId;
  final String? date;
  final String? customerName;
  final String? bookingCode;
  final String? status;
  final int page;
  final String? startDate;
  final String? endDate;

  const CancelDashboardBooking({
    required this.bookingId,
    this.date,
    this.customerName,
    this.bookingCode,
    this.status,
    this.page = 1,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [bookingId, date, customerName, bookingCode, status, page, startDate, endDate];
}
