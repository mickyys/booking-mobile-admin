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

class LoadWeekAgendaData extends AgendaEvent {
  final String sportCenterId;
  final String startDate;

  const LoadWeekAgendaData({required this.sportCenterId, required this.startDate});

  @override
  List<Object> get props => [sportCenterId, startDate];
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

class CreateInternalBookingEvent extends AgendaEvent {
  final Map<String, dynamic> bookingData;

  const CreateInternalBookingEvent({required this.bookingData});

  @override
  List<Object> get props => [bookingData];
}

class CancelBookingEvent extends AgendaEvent {
  final String bookingId;
  final String sportCenterId;
  final String date;

  const CancelBookingEvent({
    required this.bookingId,
    required this.sportCenterId,
    required this.date,
  });

  @override
  List<Object> get props => [bookingId, sportCenterId, date];
}

class CreateRecurringReservationEvent extends AgendaEvent {
  final Map<String, dynamic> bookingData;

  const CreateRecurringReservationEvent({required this.bookingData});

  @override
  List<Object> get props => [bookingData];
}
