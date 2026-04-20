import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardDataUseCase getDashboardDataUseCase;
  final CancelBookingUseCase cancelBookingUseCase;

  DashboardBloc({
    required this.getDashboardDataUseCase,
    required this.cancelBookingUseCase,
  }) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<CancelDashboardBooking>(_onCancelDashboardBooking);
  }

  Future<void> _onLoadDashboardData(LoadDashboardData event, Emitter<DashboardState> emit) async {
    print('📊 Dashboard - date: ${event.date}, customerName: ${event.customerName}, status: ${event.status}');
    emit(DashboardLoading());
    final result = await getDashboardDataUseCase(DashboardParams(
      date: event.date,
      customerName: event.customerName,
      bookingCode: event.bookingCode,
      status: event.status,
      page: event.page,
    ));
    result.fold(
      (failure) => emit(DashboardError(message: failure.message)),
      (data) => emit(DashboardLoaded(data: data)),
    );
  }

  Future<void> _onCancelDashboardBooking(CancelDashboardBooking event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    final result = await cancelBookingUseCase(event.bookingId);
    await result.fold(
      (failure) async => emit(DashboardError(message: failure.message)),
      (_) async {
        final refreshResult = await getDashboardDataUseCase(DashboardParams(
          date: event.date,
          customerName: event.customerName,
          bookingCode: event.bookingCode,
          status: event.status,
          page: event.page,
        ));
        refreshResult.fold(
          (failure) => emit(DashboardError(message: failure.message)),
          (data) => emit(DashboardLoaded(data: data)),
        );
      },
    );
  }
}
