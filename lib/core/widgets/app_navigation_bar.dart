import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_state.dart';
import '../theme/app_colors.dart';

class AppNavigationBar extends StatelessWidget {
  final String currentPath;

  const AppNavigationBar({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _getSelectedIndex(currentPath),
      onDestinationSelected: (index) => _onItemTapped(context, index),
      backgroundColor: AppColors.surfaceHigh,
      indicatorColor: AppColors.primary.withOpacity(0.2),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
          label: 'Inicio',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today, color: AppColors.primary),
          label: 'Agenda',
        ),
        NavigationDestination(
          icon: Icon(Icons.stadium_outlined),
          selectedIcon: Icon(Icons.stadium, color: AppColors.primary),
          label: 'Canchas',
        ),
        NavigationDestination(
          icon: Icon(Icons.access_time_outlined),
          selectedIcon: Icon(Icons.access_time, color: AppColors.primary),
          label: 'Horarios',
        ),
        NavigationDestination(
          icon: Icon(Icons.repeat_outlined),
          selectedIcon: Icon(Icons.repeat, color: AppColors.primary),
          label: 'Reservas',
        ),
      ],
    );
  }

  int _getSelectedIndex(String path) {
    if (path.startsWith('/dashboard')) return 0;
    if (path.startsWith('/agenda')) return 1;
    if (path.startsWith('/courts')) return 2;
    if (path.startsWith('/schedule-config')) return 3;
    if (path.startsWith('/recurring')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/agenda');
        break;
      case 2:
        context.go('/courts');
        break;
      case 3:
        context.go('/schedule-config');
        break;
      case 4:
        context.go('/recurring');
        break;
    }
  }
}
