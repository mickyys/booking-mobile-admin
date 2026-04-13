import 'package:equatable/equatable.dart';
import '../../domain/entities/sport_center.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<AdminSportCenterCourts> adminSportCenters;

  const ScheduleLoaded({required this.adminSportCenters});

  @override
  List<Object?> get props => [adminSportCenters];
}

class ScheduleError extends ScheduleState {
  final String message;

  const ScheduleError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ScheduleActionSuccess extends ScheduleState {}
