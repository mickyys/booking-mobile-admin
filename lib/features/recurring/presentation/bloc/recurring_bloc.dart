import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/recurring_series.dart';
import '../../domain/usecases/get_recurring_series_usecase.dart';
import '../../domain/usecases/cancel_recurring_reservation_usecase.dart';
import '../../domain/usecases/delete_series_usecase.dart';
import '../../domain/usecases/create_recurring_reservation_usecase.dart';

// Events
abstract class RecurringEvent {
  const RecurringEvent();
}

class LoadRecurringSeries extends RecurringEvent {
  const LoadRecurringSeries();
}

class CancelReservation extends RecurringEvent {
  final String id;
  const CancelReservation(this.id);
}

class DeleteSeries extends RecurringEvent {
  final String id;
  const DeleteSeries(this.id);
}

// States
abstract class RecurringState {}
class RecurringInitial extends RecurringState {}
class RecurringLoading extends RecurringState {}
class RecurringLoaded extends RecurringState {
  final List<RecurringSeries> series;
  RecurringLoaded(this.series);
}
class RecurringError extends RecurringState { final String message; RecurringError(this.message); }

class RecurringBloc extends Bloc<RecurringEvent, RecurringState> {
  final GetRecurringSeriesUseCase getRecurringSeriesUseCase;
  final CancelRecurringReservationUseCase cancelRecurringReservationUseCase;
  final DeleteSeriesUseCase deleteSeriesUseCase;
  final CreateRecurringReservationUseCase createRecurringReservationUseCase;

  RecurringBloc({
    required this.getRecurringSeriesUseCase,
    required this.cancelRecurringReservationUseCase,
    required this.deleteSeriesUseCase,
    required this.createRecurringReservationUseCase,
  }) : super(RecurringInitial()) {
    on<LoadRecurringSeries>(_onLoad);
    on<CancelReservation>(_onCancel);
    on<DeleteSeries>(_onDelete);
  }

  Future<void> _onLoad(LoadRecurringSeries event, Emitter<RecurringState> emit) async {
    emit(RecurringLoading());
    try {
      final series = await getRecurringSeriesUseCase();
      emit(RecurringLoaded(series));
    } catch (e) {
      emit(RecurringError(e.toString()));
    }
  }

  Future<void> _onCancel(CancelReservation event, Emitter<RecurringState> emit) async {
    await cancelRecurringReservationUseCase(event.id);
    add(LoadRecurringSeries());
  }

  Future<void> _onDelete(DeleteSeries event, Emitter<RecurringState> emit) async {
    await deleteSeriesUseCase(event.id);
    add(LoadRecurringSeries());
  }
}
