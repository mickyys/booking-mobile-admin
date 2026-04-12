import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_agenda_usecase.dart';
import '../../domain/usecases/get_admin_courts_usecase.dart';
import 'agenda_event.dart';
import 'agenda_state.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  final GetAgendaUseCase getAgendaUseCase;
  final GetAdminCourtsUseCase getAdminCourtsUseCase;

  AgendaBloc({
    required this.getAgendaUseCase,
    required this.getAdminCourtsUseCase,
  }) : super(AgendaInitial()) {
    on<LoadAdminCourts>(_onLoadAdminCourts);
    on<LoadAgendaData>(_onLoadAgendaData);
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
}
