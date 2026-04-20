import 'package:equatable/equatable.dart';

class RecurringReservation extends Equatable {
  final String id;
  final String seriesId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String courtName;
  final String status;
  final String startDate;
  final String endDate;

  const RecurringReservation({
    required this.id,
    required this.seriesId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.courtName,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        id,
        seriesId,
        dayOfWeek,
        startTime,
        endTime,
        courtName,
        status,
        startDate,
        endDate,
      ];
}
