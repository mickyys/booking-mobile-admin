import 'package:equatable/equatable.dart';

class SportCenter extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String city;
  final String address;

  const SportCenter({
    required this.id,
    required this.name,
    required this.slug,
    required this.city,
    required this.address,
  });

  @override
  List<Object?> get props => [id, name, slug, city, address];
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

  const AdminCourt({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}
