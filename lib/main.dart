import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/bloc/agenda_bloc.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/dashboard/presentation/screens/agenda_screen.dart';
import 'features/dashboard/presentation/screens/courts_screen.dart';
import 'features/dashboard/presentation/screens/schedule_config_screen.dart';
import 'features/dashboard/presentation/screens/settings_screen.dart';
import 'features/qr/presentation/screens/qr_screen.dart';
import 'features/recurring/presentation/bloc/recurring_bloc.dart';
import 'features/recurring/presentation/screens/recurring_screen.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  await initializeDateFormatting('es', null);
  runApp(const MyApp());
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/agenda',
      builder: (context, state) => const AgendaScreen(),
    ),
    GoRoute(
      path: '/courts',
      builder: (context, state) => const CourtsScreen(),
    ),
    GoRoute(
      path: '/schedule-config',
      builder: (context, state) => const ScheduleConfigScreen(),
    ),
    GoRoute(
      path: '/recurring',
      builder: (context, state) => const RecurringScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) {
        final id = state.extra as String? ?? '';
        return SettingsScreen(sportCenterId: id);
      },
    ),
    GoRoute(
      path: '/qr',
      builder: (context, state) {
        final slug = state.extra as String? ?? '';
        return QRScreen(slug: slug);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<DashboardBloc>()),
        BlocProvider(create: (_) => di.sl<AgendaBloc>()),
        BlocProvider(create: (_) => di.sl<RecurringBloc>()..add(LoadRecurringSeries())),
      ],
      child: MaterialApp.router(
        title: 'ReservaloYA Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: _router,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],
        locale: const Locale('es', 'ES'),
      ),
    );
  }
}
