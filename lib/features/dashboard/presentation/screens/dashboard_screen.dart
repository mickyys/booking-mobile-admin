import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_navigation_bar.dart';
import '../../../../core/widgets/tonal_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

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
    final currencyFormat = NumberFormat.currency(locale: 'es_CL', symbol: '\$', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
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
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 120.0,
                      floating: false,
                      pinned: true,
                      backgroundColor: AppColors.background,
                      elevation: 0,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.logout, color: AppColors.error),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Cerrar Sesión'),
                                content: const Text('¿Estás seguro de que deseas salir?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      context.read<AuthBloc>().add(LogoutRequested());
                                    },
                                    child: const Text('Salir', style: TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: false,
                        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        title: Text(
                          'Dashboard',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    title: 'Ingresos Totales',
                                    value: currencyFormat.format(data.totalRevenue),
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _StatCard(
                                    title: 'Reservas Hoy',
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
                                        child: const Icon(
                                          Icons.person,
                                          color: AppColors.primary,
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
      bottomNavigationBar: const AppNavigationBar(currentPath: '/dashboard'),
    );
  }

  Widget _buildPaymentBadge(String method) {
    Color color;
    String text;

    switch (method.toLowerCase()) {
      case 'mercadopago':
        color = Colors.blue;
        text = 'Mercado Pago';
        break;
      case 'presential':
      case 'presencial':
        color = Colors.orange;
        text = 'Presencial';
        break;
      case 'internal':
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
