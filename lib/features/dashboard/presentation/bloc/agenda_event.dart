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
