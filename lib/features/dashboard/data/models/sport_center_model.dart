import '../../domain/entities/sport_center.dart';

class SportCenterModel extends SportCenter {
  const SportCenterModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.city,
    required super.address,
  });

  factory SportCenterModel.fromJson(Map<String, dynamic> json) {
    return SportCenterModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
    );
  }
}

class AdminSportCenterCourtsModel extends AdminSportCenterCourts {
  const AdminSportCenterCourtsModel({
    required super.sportCenter,
    required List<AdminCourtModel> super.courts,
  });

  factory AdminSportCenterCourtsModel.fromJson(Map<String, dynamic> json) {
    return AdminSportCenterCourtsModel(
      sportCenter: SportCenterModel.fromJson(json['sport_center'] ?? {}),
      courts: (json['courts'] as List?)
              ?.map((e) => AdminCourtModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AdminCourtModel extends AdminCourt {
  const AdminCourtModel({
    required super.id,
    required super.name,
    required super.description,
  });

  factory AdminCourtModel.fromJson(Map<String, dynamic> json) {
    return AdminCourtModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
