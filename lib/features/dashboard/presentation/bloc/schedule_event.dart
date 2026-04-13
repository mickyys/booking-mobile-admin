import 'package:equatable/equatable.dart';
import '../../domain/entities/schedule.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class LoadScheduleData extends ScheduleEvent {}

class UpdateSlot extends ScheduleEvent {
  final String courtId;
  final TimeSlot slot;

  const UpdateSlot({required this.courtId, required this.slot});

  @override
  List<Object?> get props => [courtId, slot];
}

class UpdateSchedule extends ScheduleEvent {
  final String courtId;
  final List<TimeSlot> slots;

  const UpdateSchedule({required this.courtId, required this.slots});

  @override
  List<Object?> get props => [courtId, slots];
}
