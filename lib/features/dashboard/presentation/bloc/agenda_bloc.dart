import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_agenda_usecase.dart';
import 'agenda_event.dart';
import 'agenda_state.dart';

class AgendaBloc extends Bloc<AgendaEvent, AgendaState> {
  final GetAgendaUseCase getAgendaUseCase;

  AgendaBloc({required this.getAgendaUseCase}) : super(AgendaInitial()) {
    on<LoadAgendaData>(_onLoadAgendaData);
  }

  Future<void> _onLoadAgendaData(LoadAgendaData event, Emitter<AgendaState> emit) async {
    emit(AgendaLoading());
    final result = await getAgendaUseCase(event.date);
    result.fold(
      (failure) => emit(AgendaError(message: failure.message)),
      (schedules) => emit(AgendaLoaded(schedules: schedules, selectedDate: event.date)),
    );
  }
}
