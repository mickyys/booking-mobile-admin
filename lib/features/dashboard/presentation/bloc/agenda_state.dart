import 'package:equatable/equatable.dart';
import '../../domain/entities/schedule.dart';

abstract class AgendaState extends Equatable {
  const AgendaState();

  @override
  List<Object?> get props => [];
}

class AgendaInitial extends AgendaState {}

class AgendaLoading extends AgendaState {}

class AgendaLoaded extends AgendaState {
  final List<CourtSchedule> schedules;
  final String selectedDate;

  const AgendaLoaded({required this.schedules, required this.selectedDate});

  @override
  List<Object?> get props => [schedules, selectedDate];
}

class AgendaError extends AgendaState {
  final String message;

  const AgendaError({required this.message});

  @override
  List<Object?> get props => [message];
}
