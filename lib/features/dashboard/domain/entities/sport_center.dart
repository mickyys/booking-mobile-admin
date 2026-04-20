import 'package:equatable/equatable.dart';
import 'schedule.dart';

class SportCenter extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String city;
  final String address;
  final String? imageUrl;

  const SportCenter({
    required this.id,
    required this.name,
    required this.slug,
    required this.city,
    required this.address,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, name, slug, city, address, imageUrl];
}

class SportCenterSettings extends Equatable {
  final int cancellationHours;
  final double cancellationRetention;
  final bool partialPaymentEnabled;
  final double partialPaymentPercentage;

  const SportCenterSettings({
    required this.cancellationHours,
    required this.cancellationRetention,
    required this.partialPaymentEnabled,
    required this.partialPaymentPercentage,
  });

  @override
  List<Object?> get props => [
        cancellationHours,
        cancellationRetention,
        partialPaymentEnabled,
        partialPaymentPercentage,
      ];
}

class AdminSportCenter extends Equatable {
  final SportCenter sportCenter;
  final SportCenterSettings settings;

  const AdminSportCenter({
    required this.sportCenter,
    required this.settings,
  });

  @override
  List<Object?> get props => [sportCenter, settings];
}

class AdminSportCenterCourts extends Equatable {
  final SportCenter sportCenter;
  final List<AdminCourt> courts;

  const AdminSportCenterCourts({
    required this.sportCenter,
    required this.courts,
  });

  @override
  List<Object?> get props => [sportCenter, courts];
}

class AdminCourt extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<TimeSlot> slots;

  const AdminCourt({
    required this.id,
    required this.name,
    required this.description,
    this.slots = const [],
  });

  @override
  List<Object?> get props => [id, name, description, slots];
}
