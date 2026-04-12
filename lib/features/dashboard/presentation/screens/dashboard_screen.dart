import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:reservaloya_admin/core/theme/app_colors.dart';
import 'package:reservaloya_admin/core/widgets/tonal_card.dart';
import 'package:reservaloya_admin/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:reservaloya_admin/features/auth/presentation/bloc/auth_state.dart';
import 'package:reservaloya_admin/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:reservaloya_admin/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:reservaloya_admin/features/dashboard/presentation/bloc/dashboard_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 0);

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardLoaded) {
              final data = state.data;
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(LoadDashboardData());
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(24.0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, authState) {
                                String userIdentifier = 'Administrador';
                                if (authState is AuthAuthenticated) {
                                  userIdentifier = authState.user.email;
                                }
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Bienvenido,',
                                            style: Theme.of(context).textTheme.labelMedium,
                                          ),
                                          Text(
                                            userIdentifier,
                                            style: Theme.of(context).textTheme.headlineSmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const CircleAvatar(
                                      backgroundColor: AppColors.surfaceHighest,
                                      child: Icon(Icons.person, color: AppColors.primary),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Resumen de Hoy',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    title: 'Ventas Hoy',
                                    value: currencyFormat.format(data.todayRevenue),
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _StatCard(
                                    title: 'Reservas',
                                    value: data.todayBookingsCount.toString(),
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Text(
                              'Reservas Recientes',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final booking = data.recentBookings[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                            child: TonalCard(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceHighest,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          color: booking.status == 'confirmed'
                                              ? AppColors.primary
                                              : AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              booking.customerName,
                                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            GestureDetector(
                                              onTap: () async {
                                                final Uri launchUri = Uri(
                                                  scheme: 'tel',
                                                  path: booking.customerPhone,
                                                );
                                                if (await canLaunchUrl(launchUri)) {
                                                  await launchUrl(launchUri);
                                                }
                                              },
                                              child: Text(
                                                booking.customerPhone,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: AppColors.primary,
                                                      decoration: TextDecoration.underline,
                                                    ),
                                              ),
                                            ),
                                            if (booking.customerEmail.isNotEmpty)
                                              Text(
                                                booking.customerEmail,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: AppColors.onSurfaceVariant,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            currencyFormat.format(booking.price),
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                          ),
                                          Text(
                                            booking.bookingCode,
                                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                  fontSize: 10,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(color: AppColors.surfaceHighest, height: 1),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today, size: 14, color: AppColors.onSurfaceVariant),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${booking.date} • ${booking.hour}:00',
                                            style: Theme.of(context).textTheme.labelMedium,
                                          ),
                                        ],
                                      ),
                                      _buildPaymentBadge(booking.paymentMethod),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Cancha: ${booking.courtName}',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          color: AppColors.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: data.recentBookings.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              );
            } else if (state is DashboardError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: _CustomNavBar(),
    );
  }

  Widget _buildPaymentBadge(String method) {
    Color color;
    String text;

    switch (method.toLowerCase()) {
      case 'mercadopago':
        color = Colors.blue;
        text = 'MercadoPago';
        break;
      case 'presencial':
        color = Colors.orange;
        text = 'Presencial';
        break;
      case 'interno':
        color = AppColors.primary;
        text = 'Interno';
        break;
      default:
        color = AppColors.onSurfaceVariant;
        text = method;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return TonalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _CustomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceHighest.withAlpha(204), // 80% opacity
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(icon: Icons.dashboard_outlined, label: 'Inicio', isActive: true, path: '/dashboard'),
          _NavBarItem(icon: Icons.calendar_today_outlined, label: 'Agenda', path: '/agenda'),
          _NavBarItem(icon: Icons.sports_tennis_outlined, label: 'Canchas'),
          _NavBarItem(icon: Icons.settings_outlined, label: 'Ajustes'),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final String? path;

  const _NavBarItem({required this.icon, required this.label, this.isActive = false, this.path});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: path != null ? () => context.go(path!) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
