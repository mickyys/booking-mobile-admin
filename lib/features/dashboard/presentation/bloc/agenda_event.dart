import 'package:equatable/equatable.dart';

abstract class AgendaEvent extends Equatable {
  const AgendaEvent();

  @override
  List<Object> get props => [];
}

class LoadAgendaData extends AgendaEvent {
  final String date;

  const LoadAgendaData({required this.date});

  @override
  List<Object> get props => [date];
}
