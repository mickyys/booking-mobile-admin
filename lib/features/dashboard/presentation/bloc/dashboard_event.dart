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

  const LoadDashboardData({
    this.date,
    this.customerName,
    this.bookingCode,
    this.status,
    this.page = 1,
  });

  @override
  List<Object?> get props => [date, customerName, bookingCode, status, page];
}

class CancelDashboardBooking extends DashboardEvent {
  final String bookingId;
  final String? date;
  final String? customerName;
  final String? bookingCode;
  final String? status;
  final int page;

  const CancelDashboardBooking({
    required this.bookingId,
    this.date,
    this.customerName,
    this.bookingCode,
    this.status,
    this.page = 1,
  });

  @override
  List<Object?> get props => [bookingId, date, customerName, bookingCode, status, page];
}
