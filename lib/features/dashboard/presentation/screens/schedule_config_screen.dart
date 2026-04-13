import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_navigation_bar.dart';
import '../../../../core/widgets/tonal_card.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/sport_center.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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

              if (selectedCourt == null) {
                selectedCourt = courts.first;
              } else {
                // Update selectedCourt with latest data from state
                selectedCourt = courts.firstWhere(
                  (c) => c.id == selectedCourt!.id,
                  orElse: () => courts.first,
                );
              }

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
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
                          const SizedBox(height: 16),
                          _buildCourtSelector(courts),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final slot = selectedCourt!.slots[index];
                        return _buildSlotCard(context, slot);
                      }, childCount: selectedCourt!.slots.length),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
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
            });
          },
        ),
      ),
    );
  }

  Widget _buildSlotCard(BuildContext context, TimeSlot slot) {
    final timeStr =
        '${slot.hour.toString().padLeft(2, '0')}:${slot.minutes.toString().padLeft(2, '0')}';
    final isClosed = slot.status == 'closed';

    return Container(
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
                      Text(
                        timeStr,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${slot.price.toInt()}',
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
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  onPressed: () => _deleteSlot(slot),
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
    final newList = selectedCourt!.slots
        .where((s) => s != slotToDelete)
        .toList();
    context.read<ScheduleBloc>().add(
      UpdateSchedule(courtId: selectedCourt!.id, slots: newList),
    );
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
