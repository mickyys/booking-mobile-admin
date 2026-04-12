import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_agenda_usecase.dart';
import '../../domain/usecases/get_admin_courts_usecase.dart';
import '../../domain/usecases/add_court_usecase.dart';
import '../../domain/usecases/update_court_usecase.dart';
import '../../domain/usecases/delete_court_usecase.dart';
import 'agenda_event.dart';
import 'agenda_state.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  final GetAgendaUseCase getAgendaUseCase;
  final GetAdminCourtsUseCase getAdminCourtsUseCase;
  final AddCourtUseCase addCourtUseCase;
  final UpdateCourtUseCase updateCourtUseCase;
  final DeleteCourtUseCase deleteCourtUseCase;

  AgendaBloc({
    required this.getAgendaUseCase,
    required this.getAdminCourtsUseCase,
    required this.addCourtUseCase,
    required this.updateCourtUseCase,
    required this.deleteCourtUseCase,
  }) : super(AgendaInitial()) {
    on<LoadAdminCourts>(_onLoadAdminCourts);
    on<LoadAgendaData>(_onLoadAgendaData);
    on<AddCourt>(_onAddCourt);
    on<UpdateCourtEvent>(_onUpdateCourt);
    on<DeleteCourtEvent>(_onDeleteCourt);
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
}
