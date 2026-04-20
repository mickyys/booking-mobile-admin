import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_sport_center_settings_usecase.dart';
import '../../domain/usecases/update_sport_center_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSportCenterSettingsUseCase getSportCenterSettingsUseCase;
  final UpdateSportCenterUseCase updateSportCenterUseCase;

  SettingsBloc({
    required this.getSportCenterSettingsUseCase,
    required this.updateSportCenterUseCase,
  }) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateSettings>(_onUpdateSettings);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await getSportCenterSettingsUseCase(event.sportCenterId);
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (data) => emit(SettingsLoaded(data)),
    );
  }

  Future<void> _onUpdateSettings(UpdateSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    final result = await updateSportCenterUseCase(UpdateSportCenterParams(
      id: event.id,
      data: event.data,
      settings: event.settings,
    ));
    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (_) {
        emit(const SettingsSuccess('Configuración actualizada con éxito'));
        add(LoadSettings(event.id));
      },
    );
  }
}
