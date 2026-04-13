import 'package:flutter_test/flutter_test.dart';
import 'package:reservaloya_admin/features/dashboard/domain/entities/schedule.dart';

void main() {
  group('TimeSlot Logic', () {
    test('copyWith should update fields correctly', () {
      const slot = TimeSlot(
        hour: 8,
        minutes: 0,
        price: 20000,
        status: 'available',
        paymentRequired: true,
        paymentOptional: false,
      );

      final updated = slot.copyWith(paymentRequired: false, paymentOptional: true);

      expect(updated.paymentRequired, false);
      expect(updated.paymentOptional, true);
      expect(updated.hour, 8);
    });

    test('payment_required and payment_optional exclusivity should be handled by copyWith logic in UI', () {
        const slot = TimeSlot(
          hour: 8,
          minutes: 0,
          price: 20000,
          status: 'available',
          paymentRequired: false,
          paymentOptional: false,
        );

        final reqTrue = slot.copyWith(paymentRequired: true, paymentOptional: false);
        expect(reqTrue.paymentRequired, true);
        expect(reqTrue.paymentOptional, false);

        final optTrue = slot.copyWith(paymentRequired: false, paymentOptional: true);
        expect(optTrue.paymentRequired, false);
        expect(optTrue.paymentOptional, true);
    });
  });
}
