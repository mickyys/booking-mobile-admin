import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  final String sportCenterId;
  const LoadSettings(this.sportCenterId);

  @override
  List<Object?> get props => [sportCenterId];
}

class UpdateSettings extends SettingsEvent {
  final String id;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? settings;

  const UpdateSettings({required this.id, this.data, this.settings});

  @override
  List<Object?> get props => [id, data, settings];
}
