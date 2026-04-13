import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'core/utils/auth_interceptor.dart';
import 'core/config/app_config.dart';

// Auth
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/social_login_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Dashboard
import 'features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import 'features/dashboard/domain/usecases/get_agenda_usecase.dart';
import 'features/dashboard/domain/usecases/get_admin_courts_usecase.dart';
import 'features/dashboard/domain/usecases/add_court_usecase.dart';
import 'features/dashboard/domain/usecases/update_court_usecase.dart';
import 'features/dashboard/domain/usecases/delete_court_usecase.dart';
import 'features/dashboard/domain/usecases/create_internal_booking_usecase.dart';
import 'features/dashboard/domain/usecases/cancel_booking_usecase.dart';
import 'features/dashboard/domain/usecases/update_court_slot_usecase.dart';
import 'features/dashboard/domain/usecases/update_court_schedule_usecase.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/bloc/agenda_bloc.dart';
import 'features/dashboard/presentation/bloc/schedule_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.reservaloya.cl/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(AuthInterceptor(sharedPreferences: sl()));
  sl.registerLazySingleton(() => dio);

  sl.registerLazySingleton(
    () => Auth0(AppConfig.auth0Domain, AppConfig.auth0ClientId),
  );

  //! Features
  // Auth
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        socialLoginUseCase: sl(),
      ));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SocialLoginUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(auth0: sl()),
  );

  // Dashboard
  sl.registerFactory(() => DashboardBloc(getDashboardDataUseCase: sl()));
  sl.registerFactory(() => AgendaBloc(
        getAgendaUseCase: sl(),
        getAdminCourtsUseCase: sl(),
        addCourtUseCase: sl(),
        updateCourtUseCase: sl(),
        deleteCourtUseCase: sl(),
        createInternalBookingUseCase: sl(),
        cancelBookingUseCase: sl(),
      ));
  sl.registerFactory(() => ScheduleBloc(
        getAdminCourtsUseCase: sl(),
        updateCourtSlotUseCase: sl(),
        updateCourtScheduleUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetDashboardDataUseCase(sl()));
  sl.registerLazySingleton(() => GetAgendaUseCase(sl()));
  sl.registerLazySingleton(() => GetAdminCourtsUseCase(sl()));
  sl.registerLazySingleton(() => AddCourtUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCourtUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCourtUseCase(sl()));
  sl.registerLazySingleton(() => CreateInternalBookingUseCase(sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCourtSlotUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCourtScheduleUseCase(sl()));
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dio: sl()),
  );
}
