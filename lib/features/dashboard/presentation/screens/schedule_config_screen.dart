import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_navigation_bar.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/tonal_card.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/sport_center.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';

const dayNames = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
];

class ScheduleConfigScreen extends StatelessWidget {
  const ScheduleConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ScheduleBloc>()..add(LoadScheduleData()),
      child: const ScheduleConfigView(),
    );
  }
}

class ScheduleConfigView extends StatefulWidget {
  const ScheduleConfigView({super.key});

  @override
  State<ScheduleConfigView> createState() => _ScheduleConfigViewState();
}

class _ScheduleConfigViewState extends State<ScheduleConfigView> {
  AdminCourt? selectedCourt;
  int? selectedDay;

  List<TimeSlot> get filteredSlots {
    final court = selectedCourt;
    if (court == null) return [];

    final slots = court.slots;
    if (slots.isEmpty) return [];

    final day = selectedDay;
    if (day == null) {
      return slots.where((s) => s.dayOfWeek == null).toList();
    }
    return slots.where((s) => s.dayOfWeek == day).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: BlocConsumer<ScheduleBloc, ScheduleState>(
          listener: (context, state) {
            if (state is ScheduleError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is ScheduleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ScheduleError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ScheduleBloc>().add(LoadScheduleData());
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is ScheduleLoaded) {
              final courts = state.adminSportCenters
                  .expand((sc) => sc.courts)
                  .toList();

              if (courts.isEmpty) {
                return const Center(
                  child: Text(
                    'No hay canchas disponibles',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final currentCourtId = selectedCourt?.id;
              if (currentCourtId != null) {
                selectedCourt =
                    courts.where((c) => c.id == currentCourtId).firstOrNull ??
                    courts.first;
              } else {
                selectedCourt = courts.first;
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ScheduleBloc>().add(LoadScheduleData());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                  itemCount: filteredSlots.length + 4,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Row(
                        children: [
                          Builder(
                            builder: (ctx) => IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () => Scaffold.of(ctx).openDrawer(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CONFIGURACIÓN',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurfaceVariant,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  'Horarios por Cancha',
                                  style: GoogleFonts.manrope(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    if (index == 1) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _buildCourtSelector(courts),
                      );
                    }
                    if (index == 2) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _buildDaySelector(),
                      );
                    }
                    if (index == 3) {
                      return const SizedBox(height: 24);
                    }
                    final slot = filteredSlots[index - 4];
                    return _buildSlotCard(context, slot);
                  },
                ),
              );
            }

            return const Center(
              child: Text(
                'Error al cargar datos',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(
        currentPath: '/schedule-config',
      ),
    );
  }

  Widget _buildCourtSelector(List<AdminCourt> courts) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.onSurfaceVariant.withOpacity(0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AdminCourt>(
          value: selectedCourt,
          dropdownColor: AppColors.surface,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
          items: courts.map((court) {
            return DropdownMenuItem(
              value: court,
              child: Text(
                court.name,
                style: GoogleFonts.inter(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (AdminCourt? value) {
            setState(() {
              selectedCourt = value;
              selectedDay = null;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildDayChip(null, 'General'),
          for (var i = 0; i < dayNames.length; i++)
            _buildDayChip(i + 1, dayNames[i]),
          _buildDayChip(0, 'Domingo'),
        ],
      ),
    );
  }

  Widget _buildDayChip(int? day, String label) {
    final isSelected = selectedDay == day;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        onSelected: (val) {
          setState(() {
            selectedDay = day;
          });
        },
      ),
    );
  }

  Widget _buildSlotCard(BuildContext context, TimeSlot slot) {
    final timeStr =
        '${slot.hour.toString().padLeft(2, '0')}:${slot.minutes.toString().padLeft(2, '0')}';
    final isClosed = slot.status == 'closed';
    final dayLabel = slot.dayOfWeek != null
        ? ' (${slot.dayOfWeek == 0 ? "Domingo" : dayNames[slot.dayOfWeek! - 1]})'
        : '';

    return Dismissible(
      key: Key('${slot.hour}-${slot.minutes}-${slot.dayOfWeek ?? 'gen'}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmDialog(context, timeStr);
      },
      onDismissed: (direction) => _deleteSlot(slot),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: TonalCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              timeStr,
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (dayLabel.isNotEmpty)
                              Text(
                                dayLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                        Text(
                          '\$${slot.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'Abierto',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Switch(
                        value: !isClosed,
                        onChanged: (val) {
                          _updateSlot(
                            slot.copyWith(status: val ? 'available' : 'closed'),
                          );
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSwitchOption('Pago Req.', slot.paymentRequired, (val) {
                    _updateSlot(
                      slot.copyWith(
                        paymentRequired: val,
                        paymentOptional: val ? false : slot.paymentOptional,
                      ),
                    );
                  }),
                  _buildSwitchOption('Pago Opt.', slot.paymentOptional, (val) {
                    _updateSlot(
                      slot.copyWith(
                        paymentOptional: val,
                        paymentRequired: val ? false : slot.paymentRequired,
                      ),
                    );
                  }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSwitchOption('Abono', slot.partialPaymentEnabled, (
                    val,
                  ) {
                    _updateSlot(slot.copyWith(partialPaymentEnabled: val));
                  }),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () => _showEditPriceDialog(context, slot),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchOption(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Transform.scale(
          scale: 0.8,
          child: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  void _updateSlot(TimeSlot newSlot) {
    context.read<ScheduleBloc>().add(
      UpdateSlot(courtId: selectedCourt!.id, slot: newSlot),
    );
  }

  void _deleteSlot(TimeSlot slotToDelete) {
    final courtId = selectedCourt?.id;
    if (courtId == null) return;

    final newList = selectedCourt!.slots
        .where((s) => s != slotToDelete)
        .toList();

    selectedCourt = null;
    selectedDay = null;

    context.read<ScheduleBloc>().add(
      UpdateSchedule(courtId: courtId, slots: newList),
    );
  }

  Future<bool> _showDeleteConfirmDialog(
    BuildContext context,
    String timeStr,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (diagContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Eliminar Horario',
          style: GoogleFonts.manrope(color: Colors.white),
        ),
        content: Text(
          '¿Eliminar $timeStr?',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(diagContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showEditPriceDialog(BuildContext context, TimeSlot slot) {
    final controller = TextEditingController(
      text: slot.price.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (diagContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Editar Precio',
          style: GoogleFonts.manrope(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Precio',
            labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
            prefixText: '\$',
            prefixStyle: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(diagContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPrice = double.tryParse(controller.text) ?? slot.price;
              _updateSlot(slot.copyWith(price: newPrice));
              Navigator.pop(diagContext);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
