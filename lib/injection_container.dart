import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:reservaloya_admin/core/config/app_config.dart';
import 'package:reservaloya_admin/core/network/network_info.dart';
import 'package:reservaloya_admin/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:reservaloya_admin/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:reservaloya_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:reservaloya_admin/features/auth/domain/usecases/login_usecase.dart';
import 'package:reservaloya_admin/features/auth/domain/usecases/social_login_usecase.dart';
import 'package:reservaloya_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:reservaloya_admin/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:reservaloya_admin/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/get_dashboard_data_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/cancel_booking_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:reservaloya_admin/features/dashboard/presentation/bloc/agenda_bloc.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/get_agenda_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/get_admin_courts_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/add_court_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/update_court_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/delete_court_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/create_internal_booking_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/get_sport_center_settings_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/domain/usecases/update_sport_center_usecase.dart';
import 'package:reservaloya_admin/features/dashboard/presentation/bloc/settings_bloc.dart';
import 'package:reservaloya_admin/features/recurring/data/datasources/recurring_remote_data_source.dart';
import 'package:reservaloya_admin/features/recurring/data/datasources/recurring_remote_data_source_impl.dart';
import 'package:reservaloya_admin/features/recurring/data/repositories/recurring_repository_impl.dart';
import 'package:reservaloya_admin/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:reservaloya_admin/features/recurring/domain/usecases/get_recurring_series_usecase.dart';
import 'package:reservaloya_admin/features/recurring/domain/usecases/cancel_recurring_reservation_usecase.dart';
import 'package:reservaloya_admin/features/recurring/domain/usecases/delete_series_usecase.dart';
import 'package:reservaloya_admin/features/recurring/domain/usecases/create_recurring_reservation_usecase.dart';
import 'package:reservaloya_admin/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:dio/dio.dart';
import 'package:reservaloya_admin/core/utils/auth_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:reservaloya_admin/core/usecases/usecase.dart';
import 'package:reservaloya_admin/features/users/data/datasources/users_remote_data_source.dart';
import 'package:reservaloya_admin/features/users/data/repositories/users_repository_impl.dart';
import 'package:reservaloya_admin/features/users/domain/repositories/users_repository.dart';
import 'package:reservaloya_admin/features/users/domain/usecases/get_users_usecase.dart';
import 'package:reservaloya_admin/features/users/presentation/bloc/users_bloc.dart';
import 'package:reservaloya_admin/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:reservaloya_admin/features/notification/data/datasources/notification_remote_data_source_impl.dart';
import 'package:reservaloya_admin/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:reservaloya_admin/features/notification/domain/repositories/notification_repository.dart';
import 'package:reservaloya_admin/features/notification/domain/usecases/register_device_usecase.dart';
import 'package:reservaloya_admin/features/notification/presentation/notification_manager.dart';


final sl = GetIt.instance;

Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(connectivity: sl()));
  sl.registerLazySingleton(() => Connectivity());

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(AuthInterceptor(sharedPreferences: sl()));
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (obj) => print('🌐 DIO: $obj'),
  ));
  sl.registerLazySingleton(() => dio);

  sl.registerLazySingleton<Auth0>(() => Auth0(
    AppConfig.auth0Domain,
    AppConfig.auth0ClientId,
  ));

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(auth0: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SocialLoginUseCase(sl()));
  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl(),
    socialLoginUseCase: sl(),
    registerDeviceUseCase: sl(),
    notificationManager: sl(),
  ));

  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetDashboardDataUseCase(sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(sl()));
  sl.registerLazySingleton(() => GetAgendaUseCase(sl()));
  sl.registerLazySingleton(() => GetAdminCourtsUseCase(sl()));
  sl.registerLazySingleton(() => AddCourtUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCourtUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCourtUseCase(sl()));
  sl.registerLazySingleton(() => CreateInternalBookingUseCase(sl()));
  sl.registerFactory(() => DashboardBloc(
    getDashboardDataUseCase: sl(),
    cancelBookingUseCase: sl(),
  ));
  sl.registerFactory(() => AgendaBloc(
    getAgendaUseCase: sl(),
    getAdminCourtsUseCase: sl(),
    addCourtUseCase: sl(),
    updateCourtUseCase: sl(),
    deleteCourtUseCase: sl(),
    createInternalBookingUseCase: sl(),
    cancelBookingUseCase: sl(),
    createRecurringReservationUseCase: sl(),
  ));

  sl.registerLazySingleton(() => GetSportCenterSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSportCenterUseCase(sl()));
  sl.registerFactory(() => SettingsBloc(
    getSportCenterSettingsUseCase: sl(),
    updateSportCenterUseCase: sl(),
  ));

  sl.registerLazySingleton<RecurringRemoteDataSource>(
    () => RecurringRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<RecurringRepository>(
    () => RecurringRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetRecurringSeriesUseCase(sl()));
  sl.registerLazySingleton(() => CancelRecurringReservationUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSeriesUseCase(sl()));
  sl.registerLazySingleton(() => CreateRecurringReservationUseCase(sl()));
  sl.registerFactory(() => RecurringBloc(
    getRecurringSeriesUseCase: sl(),
    cancelRecurringReservationUseCase: sl(),
    deleteSeriesUseCase: sl(),
    createRecurringReservationUseCase: sl(),
  ));

  sl.registerLazySingleton<UsersRemoteDataSource>(
    () => UsersRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<UsersRepository>(
    () => UsersRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetUsersUseCase(repository: sl()));
  sl.registerFactory(() => UsersBloc(getUsersUseCase: sl()));

  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton(() => RegisterDeviceUseCase(sl()));
  sl.registerSingleton<NotificationManager>(NotificationManager());
}