import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reservaloya_admin/core/theme/app_colors.dart';
import 'package:reservaloya_admin/core/widgets/tonal_card.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../domain/entities/schedule.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAgenda();
  }

  void _loadAgenda() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    context.read<DashboardBloc>().add(LoadAgendaData(date: dateStr));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda de Reservas'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2101),
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
                _loadAgenda();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateHeader(),
          Expanded(
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AgendaLoaded) {
                  return _buildAgendaList(state.schedules);
                } else if (state is DashboardError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: AppColors.surfaceLow,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
              _loadAgenda();
            },
          ),
          Text(
            DateFormat('EEEE, d MMMM', 'es').format(_selectedDate),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
              _loadAgenda();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaList(List<CourtSchedule> schedules) {
    if (schedules.isEmpty) {
      return const Center(child: Text('No hay canchas configuradas.'));
    }

    return ListView.builder(
      itemCount: schedules.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final court = schedules[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                court.courtName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.onSurface,
                    ),
              ),
            ),
            ...court.slots.map((slot) => _buildSlotCard(slot)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildSlotCard(TimeSlot slot) {
    final bool isOccupied = slot.booking != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TonalCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${slot.hour}:00',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: isOccupied
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot.booking!.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          slot.booking!.customerPhone,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    )
                  : Text(
                      slot.isBlocked ? 'BLOQUEADO' : 'DISPONIBLE',
                      style: TextStyle(
                        color: slot.isBlocked ? AppColors.error : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            if (isOccupied)
              _buildSmallPaymentBadge(slot.booking!.paymentMethod),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallPaymentBadge(String method) {
    Color color;
    switch (method.toLowerCase()) {
      case 'mercadopago':
        color = Colors.blue;
        break;
      case 'presential':
      case 'presencial':
        color = Colors.orange;
        break;
      case 'internal':
      case 'interno':
        color = AppColors.primary;
        break;
      default:
        color = AppColors.onSurfaceVariant;
    }

    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
