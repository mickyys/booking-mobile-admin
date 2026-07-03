import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:reservaloya_admin/core/error/failures.dart';
import 'package:reservaloya_admin/core/usecases/usecase.dart';
import 'package:reservaloya_admin/features/dashboard/domain/entities/booking.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/create_internal_booking_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/get_admin_courts_usecase.dart';
import 'package:reservaloya_admin/features/recurring/domain/entities/recurring_reservation.dart';
import 'package:reservaloya_admin/features/recurring/domain/usecases/create_recurring_reservation_usecase.dart';
import 'package:reservaloya_admin/features/recurring/domain/usecases/get_recurring_series_usecase.dart';
import 'package:reservaloya_admin/features/recurring/domain/usecases/cancel_recurring_reservation_usecase.dart';
import 'package:reservaloya_admin/features/recurring/domain/usecases/delete_series_usecase.dart';
import 'package:reservaloya_admin/features/recurring/presentation/bloc/recurring_bloc.dart';

// We use real implementations with mocked repositories via mockito
// The use cases are simple wrappers, so we create proper mocks via mockito
import 'recurring_reservation_test.mocks.dart';

@GenerateMocks([GetRecurringSeriesUseCase])
@GenerateMocks([CancelRecurringReservationUseCase])
@GenerateMocks([DeleteSeriesUseCase])
@GenerateMocks([CreateRecurringReservationUseCase])
@GenerateMocks([CreateInternalBookingUseCase])
@GenerateMocks([GetAdminCourtsUseCase])
void main() {
  late RecurringBloc bloc;

  setUp(() {
    bloc = RecurringBloc(
      getRecurringSeriesUseCase: MockGetRecurringSeriesUseCase(),
      cancelRecurringReservationUseCase: MockCancelRecurringReservationUseCase(),
      deleteSeriesUseCase: MockDeleteSeriesUseCase(),
      createRecurringReservationUseCase: MockCreateRecurringReservationUseCase(),
      createInternalBookingUseCase: MockCreateInternalBookingUseCase(),
      getAdminCourtsUseCase: MockGetAdminCourtsUseCase(),
    );

    // Default stubs
    when(bloc.getRecurringSeriesUseCase.call()).thenAnswer((_) async => []);
    when(bloc.getAdminCourtsUseCase.call(NoParams())).thenAnswer((_) async => const Right([]));
  });

  tearDown(() {
    bloc.close();
  });

  group('CreateWeeklyRecurring', () {
    final testData = {
      'court_id': '69c096c8fa49e395fe36d5a4',
      'customer_name': 'Test User',
      'customer_phone': '123456789',
      'hour': 10,
      'minutes': 0,
      'date': '2026-07-21',
    };

    test('debe emitir RecurringActionSuccess cuando se crea correctamente', () async {
      when(bloc.createRecurringReservationUseCase.call(testData)).thenAnswer(
        (_) async => RecurringReservation(
          id: 'new-id',
          seriesId: '',
          dayOfWeek: 2,
          startTime: '10:00',
          endTime: '11:00',
          courtName: 'Cancha 1',
          status: 'active',
          startDate: '2026-07-21',
          endDate: '',
        ),
      );

      bloc.add(CreateWeeklyRecurring(testData));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RecurringLoading>(),
          isA<RecurringActionSuccess>(),
        ]),
      );
    });

    test('debe emitir RecurringError cuando el backend rechaza por conflicto', () async {
      when(bloc.createRecurringReservationUseCase.call(testData))
          .thenThrow(Exception('ya existe una reserva recurrente'));

      bloc.add(CreateWeeklyRecurring(testData));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RecurringLoading>(),
          isA<RecurringError>(),
        ]),
      );
    });
  });

  group('CreateSeriesBooking', () {
    final testData = {
      'court_id': '69c096c8fa49e395fe36d5a4',
      'customer_name': 'Test User',
      'customer_phone': '123456789',
      'hour': 10,
      'minutes': 0,
      'date': '2026-07-21',
      'status': 'confirmed',
      'payment_method': 'internal',
      'series_id': 'SERIE-000001',
    };

    test('debe emitir RecurringActionSuccess cuando se crea correctamente', () async {
      when(bloc.createInternalBookingUseCase.call(testData)).thenAnswer(
        (_) async => Right(Booking(
          id: 'new-id',
          customerName: 'Test User',
          customerPhone: '123456789',
          customerEmail: '',
          bookingCode: 'abc123',
          date: '2026-07-21',
          hour: 10,
          courtName: 'Cancha 1',
          status: 'confirmed',
          paymentMethod: 'internal',
          price: 30000,
        )),
      );

      bloc.add(CreateSeriesBooking(testData));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RecurringLoading>(),
          isA<RecurringActionSuccess>(),
        ]),
      );
    });

    test('debe emitir RecurringError cuando el backend rechaza', () async {
      when(bloc.createInternalBookingUseCase.call(testData)).thenAnswer(
        (_) async => Left(ServerFailure('error del servidor')),
      );

      bloc.add(CreateSeriesBooking(testData));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<RecurringLoading>(),
          isA<RecurringError>(),
        ]),
      );
    });
  });
}
