import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_admin_courts_usecase.dart';
import '../../domain/usecases/update_court_slot_usecase.dart';
import '../../domain/usecases/update_court_schedule_usecase.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetAdminCourtsUseCase getAdminCourtsUseCase;
  final UpdateCourtSlotUseCase updateCourtSlotUseCase;
  final UpdateCourtScheduleUseCase updateCourtScheduleUseCase;

  ScheduleBloc({
    required this.getAdminCourtsUseCase,
    required this.updateCourtSlotUseCase,
    required this.updateCourtScheduleUseCase,
  }) : super(ScheduleInitial()) {
    on<LoadScheduleData>(_onLoadScheduleData);
    on<UpdateSlot>(_onUpdateSlot);
    on<UpdateSchedule>(_onUpdateSchedule);
  }

  Future<void> _onLoadScheduleData(LoadScheduleData event, Emitter<ScheduleState> emit) async {
    emit(ScheduleLoading());
    final result = await getAdminCourtsUseCase(NoParams());
    result.fold(
      (failure) => emit(ScheduleError(message: failure.message)),
      (data) => emit(ScheduleLoaded(adminSportCenters: data)),
    );
  }

  Future<void> _onUpdateSlot(UpdateSlot event, Emitter<ScheduleState> emit) async {
    final result = await updateCourtSlotUseCase(
      UpdateCourtSlotParams(courtId: event.courtId, slot: event.slot),
    );
    result.fold(
      (failure) => emit(ScheduleError(message: failure.message)),
      (_) => add(LoadScheduleData()),
    );
  }

  Future<void> _onUpdateSchedule(UpdateSchedule event, Emitter<ScheduleState> emit) async {
    final result = await updateCourtScheduleUseCase(
      UpdateCourtScheduleParams(courtId: event.courtId, slots: event.slots),
    );
    result.fold(
      (failure) => emit(ScheduleError(message: failure.message)),
      (_) => add(LoadScheduleData()),
    );
  }
}
