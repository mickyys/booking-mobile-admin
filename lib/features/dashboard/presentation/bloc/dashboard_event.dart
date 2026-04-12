import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardData extends DashboardEvent {}

class LoadAgendaData extends DashboardEvent {
  final String date;

  const LoadAgendaData({required this.date});

  @override
  List<Object> get props => [date];
}
