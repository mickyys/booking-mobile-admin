import 'package:equatable/equatable.dart';
import '../../domain/entities/sport_center.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final AdminSportCenter adminSportCenter;
  const SettingsLoaded(this.adminSportCenter);

  @override
  List<Object?> get props => [adminSportCenter];
}

class SettingsError extends SettingsState {
  final String message;
  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class SettingsSuccess extends SettingsState {
  final String message;
  const SettingsSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
