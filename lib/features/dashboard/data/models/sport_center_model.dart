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
      id: json['id'] ?? json['_id'] ?? '',
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
    required super.retentionPercent,
    required super.partialPaymentEnabled,
    required super.partialPaymentPercent,
  });

  factory SportCenterSettingsModel.fromJson(Map<String, dynamic> json) {
    return SportCenterSettingsModel(
      cancellationHours: json['cancellation_hours'] ?? 0,
      retentionPercent: json['retention_percent'] ?? 0,
      partialPaymentEnabled: json['partial_payment_enabled'] ?? false,
      partialPaymentPercent: json['partial_payment_percent'] ?? 0,
    );
  }
}

class AdminSportCenterModel extends AdminSportCenter {
  const AdminSportCenterModel({
    required super.sportCenter,
    required super.settings,
  });

  factory AdminSportCenterModel.fromJson(Map<String, dynamic> json) {
    // La API devuelve {"center": {...}}
    final centerData = json['center'] ?? json;
    return AdminSportCenterModel(
      sportCenter: SportCenterModel.fromJson(centerData),
      // Los settings están dentro del mismo objeto center en esta API
      settings: SportCenterSettingsModel.fromJson(centerData),
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
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      slots: (json['schedule'] as List?)
              ?.map((e) => TimeSlotModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
