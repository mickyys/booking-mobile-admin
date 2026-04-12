import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/schedule.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardData data;

  const DashboardLoaded({required this.data});

  @override
  List<Object?> get props => [data];
}

class AgendaLoaded extends DashboardState {
  final List<CourtSchedule> schedules;
  final String selectedDate;

  const AgendaLoaded({required this.schedules, required this.selectedDate});

  @override
  List<Object?> get props => [schedules, selectedDate];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}
