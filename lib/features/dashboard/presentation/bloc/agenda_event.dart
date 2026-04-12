import 'package:equatable/equatable.dart';

abstract class AgendaEvent extends Equatable {
  const AgendaEvent();

  @override
  List<Object> get props => [];
}

class LoadAdminCourts extends AgendaEvent {}

class LoadAgendaData extends AgendaEvent {
  final String sportCenterId;
  final String date;

  const LoadAgendaData({required this.sportCenterId, required this.date});

  @override
  List<Object> get props => [sportCenterId, date];
}

class AddCourt extends AgendaEvent {
  final String sportCenterId;
  final String name;
  final String description;

  const AddCourt({
    required this.sportCenterId,
    required this.name,
    required this.description,
  });

  @override
  List<Object> get props => [sportCenterId, name, description];
}

class UpdateCourtEvent extends AgendaEvent {
  final String courtId;
  final String name;
  final String description;

  const UpdateCourtEvent({
    required this.courtId,
    required this.name,
    required this.description,
  });

  @override
  List<Object> get props => [courtId, name, description];
}

class DeleteCourtEvent extends AgendaEvent {
  final String courtId;

  const DeleteCourtEvent({required this.courtId});

  @override
  List<Object> get props => [courtId];
}
