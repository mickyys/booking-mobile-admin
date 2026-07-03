import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../dashboard/domain/entities/sport_center.dart';
import '../../../dashboard/domain/usecases/create_internal_booking_usecase.dart';
import '../../../dashboard/domain/usecases/get_admin_courts_usecase.dart';
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

class CreateSimpleBooking extends RecurringEvent {
  final Map<String, dynamic> data;
  const CreateSimpleBooking(this.data);
}

class CreateSeriesBooking extends RecurringEvent {
  final Map<String, dynamic> data;
  const CreateSeriesBooking(this.data);
}

class CreateWeeklyRecurring extends RecurringEvent {
  final Map<String, dynamic> data;
  const CreateWeeklyRecurring(this.data);
}

// States
abstract class RecurringState {}
class RecurringInitial extends RecurringState {}
class RecurringLoading extends RecurringState {}
class RecurringLoaded extends RecurringState {
  final List<RecurringSeries> series;
  final List<AdminCourt> courts;
  RecurringLoaded(this.series, {this.courts = const []});
}
class RecurringError extends RecurringState { final String message; RecurringError(this.message); }
class RecurringActionSuccess extends RecurringState { final String message; RecurringActionSuccess({required this.message}); }

class RecurringBloc extends Bloc<RecurringEvent, RecurringState> {
  final GetRecurringSeriesUseCase getRecurringSeriesUseCase;
  final CancelRecurringReservationUseCase cancelRecurringReservationUseCase;
  final DeleteSeriesUseCase deleteSeriesUseCase;
  final CreateRecurringReservationUseCase createRecurringReservationUseCase;
  final CreateInternalBookingUseCase createInternalBookingUseCase;
  final GetAdminCourtsUseCase getAdminCourtsUseCase;

  RecurringBloc({
    required this.getRecurringSeriesUseCase,
    required this.cancelRecurringReservationUseCase,
    required this.deleteSeriesUseCase,
    required this.createRecurringReservationUseCase,
    required this.createInternalBookingUseCase,
    required this.getAdminCourtsUseCase,
  }) : super(RecurringInitial()) {
    on<LoadRecurringSeries>(_onLoad);
    on<CancelReservation>(_onCancel);
    on<DeleteSeries>(_onDelete);
    on<CreateSimpleBooking>(_onCreateSimpleBooking);
    on<CreateSeriesBooking>(_onCreateSeriesBooking);
    on<CreateWeeklyRecurring>(_onCreateWeeklyRecurring);
  }

  Future<void> _onLoad(LoadRecurringSeries event, Emitter<RecurringState> emit) async {
    emit(RecurringLoading());
    try {
      final series = await getRecurringSeriesUseCase();
      List<AdminCourt> courts = [];
      final courtsResult = await getAdminCourtsUseCase(const NoParams());
      courtsResult.fold(
        (_) {},
        (centers) {
          for (final c in centers) {
            courts.addAll(c.courts);
          }
        },
      );
      emit(RecurringLoaded(series, courts: courts));
    } catch (e) {
      emit(RecurringError(_sanitizeError(e)));
    }
  }

  Future<void> _onCancel(CancelReservation event, Emitter<RecurringState> emit) async {
    try {
      await cancelRecurringReservationUseCase(event.id);
      emit(RecurringActionSuccess(message: 'Reserva cancelada'));
      add(LoadRecurringSeries());
    } catch (e) {
      emit(RecurringError(_sanitizeError(e)));
    }
  }

  Future<void> _onDelete(DeleteSeries event, Emitter<RecurringState> emit) async {
    try {
      await deleteSeriesUseCase(event.id);
      emit(RecurringActionSuccess(message: 'Serie eliminada'));
      add(LoadRecurringSeries());
    } catch (e) {
      emit(RecurringError(_sanitizeError(e)));
    }
  }

  Future<void> _onCreateSimpleBooking(CreateSimpleBooking event, Emitter<RecurringState> emit) async {
    emit(RecurringLoading());
    final result = await createInternalBookingUseCase(event.data);
    result.fold(
      (failure) {
        emit(RecurringError('Error al crear reserva: ${failure.message}'));
        add(LoadRecurringSeries());
      },
      (_) {
        emit(RecurringActionSuccess(message: 'Reserva creada con éxito'));
        add(LoadRecurringSeries());
      },
    );
  }

  Future<void> _onCreateSeriesBooking(CreateSeriesBooking event, Emitter<RecurringState> emit) async {
    emit(RecurringLoading());
    final result = await createInternalBookingUseCase(event.data);
    result.fold(
      (failure) {
        emit(RecurringError('Error al crear reserva: ${failure.message}'));
        add(LoadRecurringSeries());
      },
      (_) {
        emit(RecurringActionSuccess(message: 'Reserva creada con éxito'));
        add(LoadRecurringSeries());
      },
    );
  }

  Future<void> _onCreateWeeklyRecurring(CreateWeeklyRecurring event, Emitter<RecurringState> emit) async {
    emit(RecurringLoading());
    try {
      await createRecurringReservationUseCase(event.data);
      emit(RecurringActionSuccess(message: 'Reserva semanal creada con éxito'));
      add(LoadRecurringSeries());
    } catch (e) {
      emit(RecurringError('Error al crear reserva semanal: ${_sanitizeError(e)}'));
      add(LoadRecurringSeries());
    }
  }

  String _sanitizeError(Object e) {
    String msg = e.toString();
    msg = msg
        .replaceFirst(RegExp(r'^Exception:\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^Exception\s*', caseSensitive: false), '');
    if (msg.isEmpty) return msg;
    return msg[0].toUpperCase() + msg.substring(1);
  }
}
