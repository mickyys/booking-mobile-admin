import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';
import '../../domain/usecases/get_agenda_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardDataUseCase getDashboardDataUseCase;
  final GetAgendaUseCase getAgendaUseCase;

  DashboardBloc({
    required this.getDashboardDataUseCase,
    required this.getAgendaUseCase,
  }) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<LoadAgendaData>(_onLoadAgendaData);
  }

  Future<void> _onLoadDashboardData(LoadDashboardData event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    final result = await getDashboardDataUseCase(NoParams());
    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (data) => emit(DashboardLoaded(data: data)),
    );
  }

  Future<void> _onLoadAgendaData(LoadAgendaData event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    final result = await getAgendaUseCase(event.date);
    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (schedules) => emit(AgendaLoaded(schedules: schedules, selectedDate: event.date)),
    );
  }
}
