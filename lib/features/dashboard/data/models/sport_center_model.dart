import '../../domain/entities/sport_center.dart';
import 'schedule_model.dart';

class SportCenterModel extends SportCenter {
  const SportCenterModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.city,
    required super.address,
    super.imageUrl,
  });

  factory SportCenterModel.fromJson(Map<String, dynamic> json) {
    return SportCenterModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}

class SportCenterSettingsModel extends SportCenterSettings {
  const SportCenterSettingsModel({
    required super.cancellationHours,
    required super.cancellationRetention,
    required super.partialPaymentEnabled,
    required super.partialPaymentPercentage,
  });

  factory SportCenterSettingsModel.fromJson(Map<String, dynamic> json) {
    return SportCenterSettingsModel(
      cancellationHours: json['cancellation_hours'] ?? 0,
      cancellationRetention: (json['cancellation_retention'] as num?)?.toDouble() ?? 0.0,
      partialPaymentEnabled: json['partial_payment_enabled'] ?? false,
      partialPaymentPercentage: (json['partial_payment_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AdminSportCenterModel extends AdminSportCenter {
  const AdminSportCenterModel({
    required super.sportCenter,
    required super.settings,
  });

  factory AdminSportCenterModel.fromJson(Map<String, dynamic> json) {
    return AdminSportCenterModel(
      sportCenter: SportCenterModel.fromJson(json['sport_center'] ?? json),
      settings: SportCenterSettingsModel.fromJson(json['settings'] ?? {}),
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
    required super.slots,
  });

  factory AdminCourtModel.fromJson(Map<String, dynamic> json) {
    return AdminCourtModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      slots: (json['schedule'] as List?)
              ?.map((e) => TimeSlotModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
