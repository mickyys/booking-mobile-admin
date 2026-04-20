import 'package:equatable/equatable.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/sport_center.dart';

abstract class AgendaState extends Equatable {
  const AgendaState();

  @override
  List<Object?> get props => [];
}

class AgendaInitial extends AgendaState {}

class AgendaLoading extends AgendaState {}

class AdminCourtsLoaded extends AgendaState {
  final List<AdminSportCenterCourts> adminCourts;

  const AdminCourtsLoaded({required this.adminCourts});

  @override
  List<Object?> get props => [adminCourts];
}

class AgendaLoaded extends AgendaState {
  final List<CourtSchedule> schedules;
  final String selectedDate;
  final String selectedSportCenterId;

  const AgendaLoaded({
    required this.schedules,
    required this.selectedDate,
    required this.selectedSportCenterId,
  });

  @override
  List<Object?> get props => [schedules, selectedDate, selectedSportCenterId];
}

class WeekAgendaLoaded extends AgendaState {
  final Map<String, List<CourtSchedule>> weeklySchedules;
  final String startDate;
  final String selectedSportCenterId;

  const WeekAgendaLoaded({
    required this.weeklySchedules,
    required this.startDate,
    required this.selectedSportCenterId,
  });

  @override
  List<Object?> get props => [weeklySchedules, startDate, selectedSportCenterId];
}

class AgendaError extends AgendaState {
  final String message;

  const AgendaError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CourtActionSuccess extends AgendaState {
  final String message;

  const CourtActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
