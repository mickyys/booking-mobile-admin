import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_navigation_bar.dart';
import '../../domain/entities/recurring_series.dart';
import '../../presentation/bloc/recurring_bloc.dart';

String formatPrice(double price) {
  final formatter = NumberFormat('#,###', 'es_CL');
  return '\$${formatter.format(price)}';
}

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  String _activeTab = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Reservas'),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: BlocBuilder<RecurringBloc, RecurringState>(
        builder: (context, state) {
          if (state is RecurringLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RecurringError) {
            return Center(child: Text(state.message));
          } else if (state is RecurringLoaded) {
            final items = state.series.where((i) => i.status != 'cancelled').toList();
            final weeklyItems = items.where((i) => i.type == RecurringType.weekly).toList();
            final seriesItems = items.where((i) => i.type == RecurringType.series).toList();

            final filteredItems = _activeTab == 'all'
                ? items
                : _activeTab == 'weekly'
                    ? weeklyItems
                    : seriesItems;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<RecurringBloc>().add(LoadRecurringSeries());
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildFilterTabs(items.length, weeklyItems.length, seriesItems.length),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  if (filteredItems.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _ReservationCard(
                            item: filteredItems[index],
                            onTap: () => _showDetailDialog(context, filteredItems[index]),
                          ),
                          childCount: filteredItems.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }
          return _buildEmptyState();
        },
      ),
      bottomNavigationBar: const AppNavigationBar(currentPath: '/recurring'),
    );
  }

  Widget _buildFilterTabs(int total, int weekly, int series) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterChip(
            label: 'Todos ($total)',
            isSelected: _activeTab == 'all',
            onTap: () => setState(() => _activeTab = 'all'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Indefinidos ($weekly)',
            isSelected: _activeTab == 'weekly',
            color: const Color(0xFFFBBF24),
            onTap: () => setState(() => _activeTab = 'weekly'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Series ($series)',
            isSelected: _activeTab == 'series',
            color: const Color(0xFF10B981),
            onTap: () => setState(() => _activeTab = 'series'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.repeat, size: 64, color: AppColors.surfaceHighest),
          const SizedBox(height: 16),
          const Text(
            'No hay reservas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Las reservas recurrentes aparecerán aquí',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, RecurringSeries item) {
    final isWeekly = item.type == RecurringType.weekly;
    final badgeColor = isWeekly ? const Color(0xFFFBBF24) : const Color(0xFF10B981);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isWeekly ? Icons.repeat : Icons.date_range,
                    color: badgeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWeekly ? 'Reserva Semanal' : 'Serie Recurrente',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isWeekly ? 'Indefinido' : 'Serie',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _DetailRow('Cliente', item.customerName),
                  _DetailRow('Teléfono', item.customerPhone),
                  _DetailRow('Cancha', item.courtName),
                  _DetailRow('Día', item.dayOfWeek),
                  _DetailRow('Hora', item.time),
                  if (!isWeekly) _DetailRow('Reservas', '${item.confirmedBookings}/${item.totalBookings}'),
                  _DetailRow('Precio', formatPrice(item.price)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showCancelDelete(context, item);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancelar Reserva'),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showCancelDelete(BuildContext context, RecurringSeries item) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('¿Cancelar ${item.type == RecurringType.weekly ? 'reserva semanal' : 'serie'}?'),
        content: Text('Se cancelará la reserva de ${item.customerName}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Mantener'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (result == true && context.mounted) {
      context.read<RecurringBloc>().add(DeleteSeries(item.id));
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color = AppColors.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : AppColors.surfaceHighest),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final RecurringSeries item;
  final VoidCallback onTap;

  const _ReservationCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWeekly = item.type == RecurringType.weekly;
    final badgeColor = isWeekly ? const Color(0xFFFBBF24) : const Color(0xFF10B981);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Dismissible(
        key: Key(item.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          final result = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('¿Cancelar ${item.type == RecurringType.weekly ? 'reserva semanal' : 'serie'}?'),
              content: Text('Se cancelará la reserva de ${item.customerName}.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Mantener'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
          if (result == true && context.mounted) {
            context.read<RecurringBloc>().add(DeleteSeries(item.id));
          }
          return result ?? false;
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete, color: Colors.white, size: 28),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceHighest),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 14, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              item.customerPhone,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isWeekly ? Icons.repeat : Icons.date_range,
                          size: 12,
                          color: badgeColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isWeekly ? 'Indefinido' : 'Serie',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoItem(
                      icon: Icons.sports,
                      value: item.courtName,
                      label: 'Cancha',
                    ),
                    _InfoItem(
                      icon: Icons.calendar_today,
                      value: item.dayOfWeek,
                      label: 'Día',
                    ),
                    _InfoItem(
                      icon: Icons.access_time,
                      value: item.time,
                      label: 'Hora',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isWeekly)
                    Text(
                      '${item.confirmedBookings}/${item.totalBookings} reservas',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  Text(
                    formatPrice(item.price),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface)),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _InfoItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}