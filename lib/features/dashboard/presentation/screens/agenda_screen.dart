import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reservaloya_admin/core/theme/app_colors.dart';
import 'package:reservaloya_admin/core/widgets/app_navigation_bar.dart';
import '../bloc/agenda_bloc.dart';
import '../bloc/agenda_event.dart';
import '../bloc/agenda_state.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/sport_center.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedSportCenterId;
  List<AdminSportCenterCourts> _availableCenters = [];

  @override
  void initState() {
    super.initState();
    context.read<AgendaBloc>().add(LoadAdminCourts());
  }

  void _loadAgenda() {
    if (_selectedSportCenterId != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      context.read<AgendaBloc>().add(LoadAgendaData(
            sportCenterId: _selectedSportCenterId!,
            date: dateStr,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<AgendaBloc, AgendaState>(
          listener: (context, state) {
            if (state is AdminCourtsLoaded) {
              setState(() {
                _availableCenters = state.adminCourts;
                if (_availableCenters.isNotEmpty) {
                  _selectedSportCenterId = _availableCenters.first.sportCenter.id;
                  _loadAgenda();
                }
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildDateSelector(),
              _buildViewTypeSelector(),
              Expanded(
                child: BlocBuilder<AgendaBloc, AgendaState>(
                  builder: (context, state) {
                    if (state is AgendaLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    } else if (state is AgendaLoaded) {
                      return _buildAgendaView(state.schedules);
                    } else if (state is AgendaError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(state.message, style: const TextStyle(color: AppColors.error)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadAgenda,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }
                    return const Center(child: Text('Cargando agenda...', style: TextStyle(color: Colors.white)));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(currentPath: '/agenda'),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HORARIO SELECCIONADO',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                DateFormat('MMMM yyyy', 'es').format(_selectedDate).toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.calendar_today, color: AppColors.primary),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14, // Show 2 weeks
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = DateFormat('yyyy-MM-dd').format(date) ==
                             DateFormat('yyyy-MM-dd').format(_selectedDate);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
              _loadAgenda();
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE', 'es').format(date).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.onPrimary : Colors.white,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppColors.onPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildViewTypeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Vista de Horarios',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildToggleButton('Todas', true),
                _buildToggleButton('Interior', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1B2634) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildAgendaView(List<CourtSchedule> schedules) {
    if (schedules.isEmpty) {
      return const Center(child: Text('No hay canchas disponibles.', style: TextStyle(color: Colors.white)));
    }

    // Get all unique hours across all courts
    final hours = <int>{};
    for (var schedule in schedules) {
      for (var slot in schedule.slots) {
        hours.add(slot.hour);
      }
    }
    final sortedHours = hours.toList()..sort();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 80, right: 16, top: 16, bottom: 8),
          child: Row(
            children: schedules.map((court) => Expanded(
              child: Column(
                children: [
                  Text(
                    court.courtName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'PRINCIPAL', // Static for now based on design
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedHours.length,
            itemBuilder: (context, index) {
              final hour = sortedHours[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 64,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${hour.toString().padLeft(2, '0')}:00',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            hour < 12 ? 'AM' : 'PM',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ...schedules.map((court) {
                      final slot = court.slots.firstWhere(
                        (s) => s.hour == hour,
                        orElse: () => TimeSlot(
                          hour: hour,
                          minutes: 0,
                          price: 0,
                          status: 'closed',
                          paymentRequired: false,
                          paymentOptional: false,
                        ),
                      );
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: _buildSlotCard(slot),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSlotCard(TimeSlot slot) {
    switch (slot.status) {
      case 'available':
        return Container(
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary, width: 1.5, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_circle, color: AppColors.primary, size: 20),
              const SizedBox(height: 4),
              Text(
                'DISPONIBLE',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      case 'booked':
      case 'passed_booked':
        final isPassed = slot.status == 'passed_booked';
        return Container(
          height: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF3E4A59),
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: isPassed ? Colors.white : AppColors.primary, width: 4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isPassed ? 'SESIÓN ACTUAL' : 'RESERVADO',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                slot.booking?.customerName ?? 'Cliente',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    isPassed ? Icons.timer_outlined : Icons.check_circle,
                    size: 14,
                    color: Colors.white70,
                  ),
                ],
              ),
            ],
          ),
        );
      case 'passed':
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'PASADO',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white24,
              ),
            ),
          ),
        );
      case 'closed':
      default:
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.build_outlined, color: Colors.white24, size: 20),
              const SizedBox(height: 4),
              Text(
                'MANTENIMIENTO\nCERRADO',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white24,
                ),
              ),
            ],
          ),
        );
    }
  }
}
