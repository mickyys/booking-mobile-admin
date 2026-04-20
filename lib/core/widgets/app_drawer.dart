import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;

    return Drawer(
      backgroundColor: AppColors.surfaceHigh,
      child: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state is AuthAuthenticated ? state.user : null;
            final userName = user?.name ?? user?.email ?? 'Usuario';
            final userEmail = user?.email ?? '';

            return Column(
              children: [
                _buildHeader(userName, userEmail),
                const Divider(color: Colors.white10, height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildMenuItem(
                        context,
                        icon: Icons.calendar_today_outlined,
                        title: 'Agenda Semanal',
                        path: '/agenda',
                        currentPath: currentPath,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.dashboard_outlined,
                        title: 'Dashboard',
                        path: '/dashboard',
                        currentPath: currentPath,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.repeat_outlined,
                        title: 'Reservas Recurrentes',
                        path: '/recurring',
                        currentPath: currentPath,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.emoji_events_outlined,
                        title: 'Mis Canchas',
                        path: '/courts',
                        currentPath: currentPath,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.access_time_outlined,
                        title: 'Horarios y Tarifas',
                        path: '/schedule-config',
                        currentPath: currentPath,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.qr_code_outlined,
                        title: 'Código QR',
                        path: '/qr',
                        currentPath: currentPath,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.settings_outlined,
                        title: 'Configuración',
                        path: '/settings',
                        currentPath: currentPath,
                      ),
                      _buildMenuItem(
                        context,
                        icon: Icons.people_outline,
                        title: 'Usuarios',
                        path: '/users',
                        currentPath: currentPath,
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, height: 1),
                _buildLogoutItem(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primary,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            email,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String path,
    required String currentPath,
  }) {
    final isSelected = currentPath.startsWith(path);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
          size: 22,
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          Navigator.pop(context); // Cerrar drawer
          if (!isSelected) {
            context.go(path);
          }
        },
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: AppColors.error, size: 22),
      title: Text(
        'Cerrar Sesión',
        style: GoogleFonts.inter(
          color: AppColors.error,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        context.read<AuthBloc>().add(LogoutRequested());
        context.go('/login');
      },
    );
  }
}
