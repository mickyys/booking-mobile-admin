import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/usecases/get_agenda_usecase.dart';
import '../../domain/usecases/get_admin_courts_usecase.dart';
import '../../domain/usecases/add_court_usecase.dart';
import '../../domain/usecases/update_court_usecase.dart';
import '../../domain/usecases/delete_court_usecase.dart';
import '../../domain/usecases/create_internal_booking_usecase.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import '../../../recurring/domain/usecases/create_recurring_reservation_usecase.dart';
import 'agenda_event.dart';
import 'agenda_state.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  final GetAgendaUseCase getAgendaUseCase;
  final GetAdminCourtsUseCase getAdminCourtsUseCase;
  final AddCourtUseCase addCourtUseCase;
  final UpdateCourtUseCase updateCourtUseCase;
  final DeleteCourtUseCase deleteCourtUseCase;
  final CreateInternalBookingUseCase createInternalBookingUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final CreateRecurringReservationUseCase createRecurringReservationUseCase;

  AgendaBloc({
    required this.getAgendaUseCase,
    required this.getAdminCourtsUseCase,
    required this.addCourtUseCase,
    required this.updateCourtUseCase,
    required this.deleteCourtUseCase,
    required this.createInternalBookingUseCase,
    required this.cancelBookingUseCase,
    required this.createRecurringReservationUseCase,
  }) : super(AgendaInitial()) {
    on<LoadAdminCourts>(_onLoadAdminCourts);
    on<LoadAgendaData>(_onLoadAgendaData);
    on<LoadWeekAgendaData>(_onLoadWeekAgendaData);
    on<AddCourt>(_onAddCourt);
    on<UpdateCourtEvent>(_onUpdateCourt);
    on<DeleteCourtEvent>(_onDeleteCourt);
    on<CreateInternalBookingEvent>(_onCreateInternalBooking);
    on<CancelBookingEvent>(_onCancelBooking);
    on<CreateRecurringReservationEvent>(_onCreateRecurringReservation);
  }

  Future<void> _onLoadAdminCourts(LoadAdminCourts event, Emitter<AgendaState> emit) async {
    emit(AgendaLoading());
    final result = await getAdminCourtsUseCase(NoParams());
    result.fold(
      (failure) => emit(AgendaError(message: failure.message)),
      (adminCourts) => emit(AdminCourtsLoaded(adminCourts: adminCourts)),
    );
  }

  Future<void> _onLoadAgendaData(LoadAgendaData event, Emitter<AgendaState> emit) async {
    emit(AgendaLoading());
    final result = await getAgendaUseCase(AgendaParams(
      sportCenterId: event.sportCenterId,
      date: event.date,
    ));
    result.fold(
      (failure) => emit(AgendaError(message: failure.message)),
      (schedules) => emit(AgendaLoaded(
        schedules: schedules,
        selectedDate: event.date,
        selectedSportCenterId: event.sportCenterId,
      )),
    );
  }

  Future<void> _onLoadWeekAgendaData(LoadWeekAgendaData event, Emitter<AgendaState> emit) async {
    emit(AgendaLoading());
    final startDate = DateTime.parse(event.startDate);
    final Map<String, List<CourtSchedule>> weeklySchedules = {};
    bool hasError = false;
    String errorMessage = '';

    final futures = List.generate(7, (index) {
      final date = startDate.add(Duration(days: index));
      final dateStr = date.toString().split(' ')[0];
      return getAgendaUseCase(AgendaParams(
        sportCenterId: event.sportCenterId,
        date: dateStr,
      )).then((result) => MapEntry(dateStr, result));
    });

    final results = await Future.wait(futures);

    for (final entry in results) {
      entry.value.fold(
        (failure) {
          hasError = true;
          errorMessage = failure.message;
        },
        (schedules) => weeklySchedules[entry.key] = schedules,
      );
    }

    if (hasError) {
      emit(AgendaError(message: errorMessage));
    } else {
      emit(WeekAgendaLoaded(
        weeklySchedules: weeklySchedules,
        startDate: event.startDate,
        selectedSportCenterId: event.sportCenterId,
      ));
    }
  }

  Future<void> _onAddCourt(AddCourt event, Emitter<AgendaState> emit) async {
    emit(AgendaLoading());
    final result = await addCourtUseCase(AddCourtParams(
      sportCenterId: event.sportCenterId,
      name: event.name,
      description: event.description,
    ));
    result.fold(
      (failure) => emit(AgendaError(message: failure.message)),
      (_) {
        emit(const CourtActionSuccess(message: 'Cancha agregada con éxito'));
        add(LoadAdminCourts());
      },
    );
  }

  Future<void> _onUpdateCourt(UpdateCourtEvent event, Emitter<AgendaState> emit) async {
    emit(AgendaLoading());
    final result = await updateCourtUseCase(UpdateCourtParams(
      courtId: event.courtId,
      name: event.name,
      description: event.description,
    ));
    result.fold(
      (failure) => emit(AgendaError(message: failure.message)),
      (_) {
        emit(const CourtActionSuccess(message: 'Cancha actualizada con éxito'));
        add(LoadAdminCourts());
      },
    );
  }

  Future<void> _onDeleteCourt(DeleteCourtEvent event, Emitter<AgendaState> emit) async {
    emit(AgendaLoading());
    final result = await deleteCourtUseCase(event.courtId);
    result.fold(
      (failure) => emit(AgendaError(message: failure.message)),
      (_) {
        emit(const CourtActionSuccess(message: 'Cancha eliminada con éxito'));
        add(LoadAdminCourts());
      },
    );
  }

  Future<void> _onCreateInternalBooking(CreateInternalBookingEvent event, Emitter<AgendaState> emit) async {
    print('📝 Creating booking: ${event.bookingData}');
    emit(AgendaLoading());
    final result = await createInternalBookingUseCase(event.bookingData);
    result.fold(
      (failure) {
        print('❌ Booking error: ${failure.message}');
        emit(AgendaError(message: failure.message));
      },
      (_) {
        print('✅ Booking created successfully');
        final dateStr = event.bookingData['date'].toString().split('T')[0];
        print('🔄 Reloading agenda for date: $dateStr');
        emit(const CourtActionSuccess(message: 'Reserva creada con éxito'));
        add(LoadAgendaData(
          sportCenterId: event.bookingData['sport_center_id'],
          date: dateStr,
        ));
      },
    );
  }

  Future<void> _onCancelBooking(CancelBookingEvent event, Emitter<AgendaState> emit) async {
    emit(AgendaLoading());
    final result = await cancelBookingUseCase(event.bookingId);
    result.fold(
      (failure) => emit(AgendaError(message: failure.message)),
      (_) {
        emit(const CourtActionSuccess(message: 'Reserva cancelada con éxito'));
        add(LoadAgendaData(sportCenterId: event.sportCenterId, date: event.date));
      },
    );
  }

  Future<void> _onCreateRecurringReservation(CreateRecurringReservationEvent event, Emitter<AgendaState> emit) async {
    print('📅 Creating recurring reservation: ${event.bookingData}');
    emit(AgendaLoading());
    try {
      await createRecurringReservationUseCase(event.bookingData);
      print('✅ Recurring reservation created successfully');
      final dateStr = event.bookingData['date'].toString();
      emit(const CourtActionSuccess(message: 'Reserva semanal creada con éxito'));
      add(LoadAgendaData(
        sportCenterId: event.bookingData['sport_center_id'],
        date: dateStr,
      ));
    } catch (e) {
      print('❌ Recurring reservation error: $e');
      emit(AgendaError(message: e.toString()));
    }
  }
}
