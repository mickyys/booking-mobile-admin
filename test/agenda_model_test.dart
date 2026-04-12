import 'package:flutter_test/flutter_test.dart';
import 'package:reservaloya_admin/features/dashboard/data/models/schedule_model.dart';

void main() {
  group('CourtScheduleModel', () {
    test('should parse flat JSON schedule correctly', () {
      final json = {
        "id": "69c095fd28c02626758a5b62",
        "name": "Cancha 1",
        "schedule": [
          {
            "hour": 10,
            "minutes": 0,
            "price": 20000,
            "status": "passed_booked",
            "payment_required": false,
            "payment_optional": false,
            "booking_id": "69dae1f36c3efc49ebf8f4cc",
            "customer_name": "Bastian Romero",
            "customer_email": "basty8crack@gmail.com",
            "customer_phone": "+56920663782",
            "booking_code": "7fc32a03",
            "payment_method": "presential"
          }
        ]
      };

      final model = CourtScheduleModel.fromJson(json);

      expect(model.courtName, "Cancha 1");
      expect(model.slots.length, 1);
      expect(model.slots.first.status, "passed_booked");
      expect(model.slots.first.booking?.customerName, "Bastian Romero");
      expect(model.slots.first.booking?.id, "69dae1f36c3efc49ebf8f4cc");
    });
  });

  group('TimeSlotModel', () {
    test('should parse available slot correctly', () {
      final jsonSlot = {
        "hour": 12,
        "minutes": 0,
        "price": 20000,
        "status": "available",
        "payment_required": false,
        "payment_optional": false
      };

      final model = TimeSlotModel.fromJson(jsonSlot);

      expect(model.hour, 12);
      expect(model.status, "available");
      expect(model.booking, isNull);
      expect(model.isAvailable, isTrue);
    });
  });
}
