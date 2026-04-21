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

  (String startDate, String endDate) _getCurrentWeekRange() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    
    final start = '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
    final end = '${sunday.year}-${sunday.month.toString().padLeft(2, '0')}-${sunday.day.toString().padLeft(2, '0')}';
    
    return (start, end);
  }

  Future<void> _onLoadDashboardData(LoadDashboardData event, Emitter<DashboardState> emit) async {
    String? startDate = event.startDate;
    String? endDate = event.endDate;
    
    if (startDate == null && endDate == null && event.date == null) {
      final (start, end) = _getCurrentWeekRange();
      startDate = start;
      endDate = end;
      print('📊 Dashboard - Using current week: $start|$end');
    }
    
    print('📊 Dashboard - date: ${event.date}, startDate: $startDate, endDate: $endDate, customerName: ${event.customerName}, status: ${event.status}');
    emit(DashboardLoading());
    final result = await getDashboardDataUseCase(DashboardParams(
      date: event.date,
      customerName: event.customerName,
      bookingCode: event.bookingCode,
      status: event.status,
      page: event.page,
      startDate: startDate,
      endDate: endDate,
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
        String? startDate = event.startDate;
        String? endDate = event.endDate;
        
        if (startDate == null && endDate == null && event.date == null) {
          final (start, end) = _getCurrentWeekRange();
          startDate = start;
          endDate = end;
        }
        
        final refreshResult = await getDashboardDataUseCase(DashboardParams(
          date: event.date,
          customerName: event.customerName,
          bookingCode: event.bookingCode,
          status: event.status,
          page: event.page,
          startDate: startDate,
          endDate: endDate,
        ));
        refreshResult.fold(
          (failure) => emit(DashboardError(message: failure.message)),
          (data) => emit(DashboardLoaded(data: data)),
        );
      },
    );
  }
}
