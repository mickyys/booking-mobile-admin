import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_dashboard_data_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardDataUseCase getDashboardDataUseCase;

  DashboardBloc({required this.getDashboardDataUseCase}) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
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
}
