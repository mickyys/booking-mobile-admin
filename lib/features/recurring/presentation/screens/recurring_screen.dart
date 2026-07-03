import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_navigation_bar.dart';
import '../../../../core/widgets/modal_badge.dart';
import '../../../../core/widgets/modal_detail_row.dart';
import '../../../../core/widgets/modal_section.dart';
import '../../../../core/widgets/modal_text_field.dart';
import '../../../dashboard/domain/entities/sport_center.dart';
import '../../../dashboard/domain/entities/schedule.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateBookingDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Reserva'),
      ),
      body: BlocConsumer<RecurringBloc, RecurringState>(
        listener: (context, state) {
          if (state is RecurringActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is RecurringError) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surfaceHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                title: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 28),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Error',
                        style: GoogleFonts.manrope(
                          color: AppColors.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Text(
                  state.message,
                  style: GoogleFonts.inter(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Entendido',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }
        },
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
                        const SizedBox(height: 16),
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
            color: AppColors.recurringWeekly,
            onTap: () => setState(() => _activeTab = 'weekly'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Series ($series)',
            isSelected: _activeTab == 'series',
            color: AppColors.recurringSeries,
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
    final isSeries = item.type == RecurringType.series;
    final accentColor =
        isWeekly ? AppColors.recurringWeekly : AppColors.recurringSeries;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    isWeekly ? Icons.repeat : Icons.date_range,
                    color: accentColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWeekly ? 'Reserva Semanal' : 'Serie Recurrente',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ModalBadge(
                        label: isWeekly ? 'Indefinido' : 'Serie',
                        color: accentColor,
                        icon: isWeekly ? Icons.repeat : Icons.date_range,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceHighest.withOpacity(0.4),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  ModalDetailRow(
                    label: 'Cliente',
                    value: item.customerName,
                    icon: Icons.person_outline,
                  ),
                  ModalDetailRow(
                    label: 'Teléfono',
                    value: item.customerPhone,
                    icon: Icons.phone_outlined,
                  ),
                  ModalDetailRow(
                    label: 'Cancha',
                    value: item.courtName,
                    icon: Icons.sports,
                  ),
                  ModalDetailRow(
                    label: 'Día',
                    value: item.dayOfWeek,
                    icon: Icons.calendar_today,
                  ),
                  ModalDetailRow(
                    label: 'Hora',
                    value: item.time,
                    icon: Icons.access_time,
                  ),
                  if (isSeries) ...[
                    ModalDetailRow(
                      label: 'Inicio',
                      value: item.startDate.isNotEmpty
                          ? DateFormat('dd/MM/yyyy').format(
                              DateTime.parse(item.startDate))
                          : '-',
                      icon: Icons.play_arrow_outlined,
                    ),
                    ModalDetailRow(
                      label: 'Fin',
                      value: item.endDate.isNotEmpty
                          ? DateFormat('dd/MM/yyyy').format(
                              DateTime.parse(item.endDate))
                          : '-',
                      icon: Icons.stop_outlined,
                    ),
                    ModalDetailRow(
                      label: 'Progreso',
                      value:
                          '${item.confirmedBookings}/${item.totalBookings} reservas',
                      icon: Icons.task_alt,
                    ),
                  ],
                  if (isWeekly) ...[
                    ModalDetailRow(
                      label: 'Activa desde',
                      value: item.createdAt.isNotEmpty
                          ? DateFormat('dd/MM/yyyy').format(
                              DateTime.parse(item.createdAt))
                          : '-',
                      icon: Icons.event_available,
                    ),
                  ],
                  ModalDetailRow(
                    label: 'Precio',
                    value: formatPrice(item.price),
                    icon: Icons.attach_money,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showCancelDelete(context, item);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 20),
                label: Text(
                  'Cancelar Reserva',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _showCancelDelete(BuildContext context, RecurringSeries item) async {
    final isWeekly = item.type == RecurringType.weekly;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          '¿Cancelar ${isWeekly ? 'reserva semanal' : 'serie recurrente'}?',
          style: GoogleFonts.manrope(
            color: AppColors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          isWeekly
              ? 'Se cancelará la reserva semanal indefinida de ${item.customerName}. No se podrá revertir.'
              : 'Se cancelarán todas las reservas futuras de la serie de ${item.customerName} (${item.totalBookings - item.confirmedBookings} pendientes). No se podrá revertir.',
          style: GoogleFonts.inter(
            color: AppColors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Mantener',
              style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
    if (result == true && context.mounted) {
      if (item.type == RecurringType.weekly) {
        context.read<RecurringBloc>().add(CancelReservation(item.id));
      } else {
        context.read<RecurringBloc>().add(DeleteSeries(item.id));
      }
    }
  }

  void _showCreateBookingDialog(BuildContext context) {
    final state = context.read<RecurringBloc>().state;
    final courts = state is RecurringLoaded ? state.courts : <AdminCourt>[];

    String? selectedCourtId;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay(
      hour: DateTime.now().hour,
      minute: 0,
    );
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String bookingType = 'simple';
    int weeksCount = 4;
    bool creating = false;
    String? nameError;
    String? courtError;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final isWeekly = bookingType == 'weekly';
          final isSeries = bookingType == 'series';
          final actionColor = isWeekly
              ? AppColors.recurringWeekly
              : isSeries
                  ? AppColors.primary
                  : AppColors.primary;
          final actionFgColor = isWeekly
              ? Colors.black
              : isSeries || bookingType == 'simple'
                  ? AppColors.onPrimary
                  : Colors.black;

          double estimatedPrice = 0;
          if (selectedCourtId != null && courts.isNotEmpty) {
            final court = courts.firstWhere(
              (c) => c.id == selectedCourtId,
              orElse: () => AdminCourt(
                id: '',
                name: '',
                description: '',
                slots: [],
              ),
            );
            final matchingSlot = court.slots.cast<TimeSlot?>().firstWhere(
              (s) =>
                  s != null &&
                  s.hour == selectedTime.hour &&
                  s.minutes == selectedTime.minute,
              orElse: () => null,
            );
            if (matchingSlot != null) {
              estimatedPrice = matchingSlot.price;
            }
          }

          return AlertDialog(
            backgroundColor: AppColors.surfaceHigh,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.lg,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            title: Text(
              'Nueva Reserva',
              style: GoogleFonts.manrope(
                color: AppColors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ModalSection(
                      title: 'CANCHA',
                      icon: Icons.sports,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHighest,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedCourtId,
                          dropdownColor: AppColors.surfaceHighest,
                          decoration: InputDecoration(
                            labelText: 'Selecciona una cancha *',
                            labelStyle: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.sports,
                              color: AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              borderSide: const BorderSide(
                                  color: Colors.white10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              borderSide: const BorderSide(
                                  color: AppColors.error),
                            ),
                            errorText: courtError,
                            errorStyle: const TextStyle(
                              color: AppColors.error,
                              fontSize: 11,
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceHighest,
                          ),
                          style: const TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 14,
                          ),
                          hint: const Text(
                            'Selecciona una cancha',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          items: courts
                              .map((court) => DropdownMenuItem(
                                    value: court.id,
                                    child: Text(court.name),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedCourtId = value),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ModalSection(
                      title: 'FECHA Y HORA',
                      icon: Icons.calendar_today,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: dialogContext,
                                initialDate: selectedDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2101),
                                builder: (context, child) => Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme:
                                        const ColorScheme.dark(
                                      primary: AppColors.primary,
                                      onPrimary: AppColors.onPrimary,
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setState(() => selectedDate = picked);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.base,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHighest,
                                borderRadius: BorderRadius.circular(
                                    AppRadius.md),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: AppColors.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  const SizedBox(
                                      width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      DateFormat(
                                        "EEEE d 'de' MMMM",
                                        'es',
                                      ).format(selectedDate),
                                      style: const TextStyle(
                                        color: AppColors.onSurface,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: dialogContext,
                                initialTime: selectedTime,
                                builder: (context, child) => Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme:
                                        const ColorScheme.dark(
                                      primary: AppColors.primary,
                                      onPrimary: AppColors.onPrimary,
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setState(() => selectedTime = picked);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.base,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHighest,
                                borderRadius: BorderRadius.circular(
                                    AppRadius.md),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: AppColors.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  const SizedBox(
                                      width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      selectedTime.format(
                                          dialogContext),
                                      style: const TextStyle(
                                        color: AppColors.onSurface,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ModalSection(
                      title: 'CLIENTE',
                      icon: Icons.person_outline,
                      child: Column(
                        children: [
                          ModalTextField(
                            label: 'Nombre del Cliente',
                            icon: Icons.person_outline,
                            controller: nameController,
                            required: true,
                            errorText: nameError,
                          ),
                          const SizedBox(height: AppSpacing.base),
                          ModalTextField(
                            label: 'Teléfono',
                            icon: Icons.phone_outlined,
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ModalSection(
                      title: 'TIPO DE RESERVA',
                      icon: Icons.layers_outlined,
                      child: Column(
                        children: [
                          _BookingTypeOption(
                            icon: Icons.event,
                            title: 'Reserva Simple',
                            subtitle: 'Solo para esta fecha',
                            selected: bookingType == 'simple',
                            accentColor: AppColors.primary,
                            onTap: () => setState(
                                () => bookingType = 'simple'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _BookingTypeOption(
                            icon: Icons.repeat,
                            title: 'Reserva Recurrente',
                            subtitle: 'Se repite por varias semanas',
                            selected: bookingType == 'series',
                            accentColor: AppColors.recurringSeries,
                            badge: weeksCount >= 2
                                ? '$weeksCount semanas'
                                : null,
                            onTap: () => setState(
                                () => bookingType = 'series'),
                          ),
                          if (isSeries) ...[
                            const SizedBox(height: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.all(
                                  AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.recurringSeries
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                    AppRadius.md),
                                border: Border.all(
                                  color: AppColors.recurringSeries
                                      .withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Text(
                                        'Cantidad de semanas',
                                        style: GoogleFonts.inter(
                                          color: AppColors
                                              .recurringSeries,
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            const EdgeInsets
                                                .symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration:
                                            BoxDecoration(
                                          color: AppColors
                                              .recurringSeries,
                                          borderRadius:
                                              BorderRadius
                                                  .circular(8),
                                        ),
                                        child: Text(
                                          '$weeksCount',
                                          style: GoogleFonts
                                              .manrope(
                                            color: Colors.white,
                                            fontWeight:
                                                FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SliderTheme(
                                    data: SliderThemeData(
                                      activeTrackColor:
                                          AppColors
                                              .recurringSeries,
                                      inactiveTrackColor: AppColors
                                          .recurringSeries
                                          .withOpacity(0.2),
                                      thumbColor:
                                          AppColors
                                              .recurringSeries,
                                      overlayColor: AppColors
                                          .recurringSeries
                                          .withOpacity(0.15),
                                      trackHeight: 6,
                                      thumbShape:
                                          const RoundSliderThumbShape(
                                        enabledThumbRadius: 8,
                                      ),
                                    ),
                                    child: Slider(
                                      value:
                                          weeksCount.toDouble(),
                                      min: 2,
                                      max: 52,
                                      divisions: 50,
                                      onChanged: (v) => setState(
                                          () => weeksCount =
                                              v.round()),
                                    ),
                                  ),
                                  Text(
                                    'Hasta el ${DateFormat("d 'de' MMMM", 'es').format(selectedDate.add(Duration(days: (weeksCount - 1) * 7)))}',
                                    style: GoogleFonts.inter(
                                      color: AppColors
                                          .recurringSeries,
                                      fontSize: 12,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.sm),
                          _BookingTypeOption(
                            icon: Icons.loop,
                            title: 'Reserva Semanal',
                            subtitle:
                                'Se repite cada semana de forma indefinida',
                            selected: bookingType == 'weekly',
                            accentColor: AppColors.recurringWeekly,
                            onTap: () => setState(
                                () => bookingType = 'weekly'),
                          ),
                        ],
                      ),
                    ),
                    if (estimatedPrice > 0) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Precio por sesión',
                                  style: GoogleFonts.inter(
                                    color: AppColors.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  formatPrice(estimatedPrice),
                                  style: GoogleFonts.manrope(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            if (isSeries) ...[
                              const SizedBox(
                                  height: AppSpacing.xs),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total estimado ($weeksCount semanas)',
                                    style: GoogleFonts.inter(
                                      color:
                                          AppColors.onSurfaceVariant,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    formatPrice(estimatedPrice *
                                        weeksCount),
                                    style: GoogleFonts.manrope(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actionsPadding:
                const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed:
                    creating ? null : () => Navigator.pop(ctx),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(
                    color: creating
                        ? AppColors.onSurfaceVariant
                            .withOpacity(0.4)
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  foregroundColor: actionFgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.md),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                ),
                onPressed: creating
                    ? null
                    : () async {
                        bool valid = true;
                        setState(() {
                          nameError = null;
                          courtError = null;
                        });
                        if (selectedCourtId == null) {
                          setState(() =>
                              courtError = 'Selecciona una cancha');
                          valid = false;
                        }
                        if (nameController.text.trim().isEmpty) {
                          setState(() =>
                              nameError = 'Nombre es requerido');
                          valid = false;
                        }
                        if (!valid) return;

                        setState(() => creating = true);

                        final bloc =
                            context.read<RecurringBloc>();
                        final dateStr = DateFormat('yyyy-MM-dd')
                            .format(selectedDate);

                        if (bookingType == 'weekly') {
                          bloc.add(CreateWeeklyRecurring({
                            'court_id': selectedCourtId,
                            'customer_name':
                                nameController.text.trim(),
                            'customer_phone':
                                phoneController.text.trim(),
                            'hour': selectedTime.hour,
                            'minutes': selectedTime.minute,
                            'date': dateStr,
                          }));
                        } else if (bookingType == 'series') {
                          final seriesId =
                              'SERIE-${Random().nextInt(999999).toString().padLeft(6, '0')}';
                          for (int i = 0; i < weeksCount; i++) {
                            final currentDate = selectedDate.add(
                                Duration(days: i * 7));
                            final currentDateStr =
                                DateFormat('yyyy-MM-dd')
                                    .format(currentDate);
                            bloc.add(CreateSeriesBooking({
                              'court_id': selectedCourtId,
                              'date': currentDateStr,
                              'hour': selectedTime.hour,
                              'minutes': selectedTime.minute,
                              'customer_name':
                                  nameController.text.trim(),
                              'customer_phone':
                                  phoneController.text.trim(),
                              'guest_details': {
                                'name':
                                    nameController.text.trim(),
                                'phone':
                                    phoneController.text.trim(),
                                'email': 'admin@internal.com',
                              },
                              'status': 'confirmed',
                              'payment_method': 'internal',
                              'series_id': seriesId,
                            }));
                          }
                        } else {
                          bloc.add(CreateSimpleBooking({
                            'court_id': selectedCourtId,
                            'customer_name':
                                nameController.text.trim(),
                            'customer_phone':
                                phoneController.text.trim(),
                            'date': dateStr,
                            'hour': selectedTime.hour,
                            'minutes': selectedTime.minute,
                            'guest_details': {
                              'name':
                                  nameController.text.trim(),
                              'phone':
                                  phoneController.text.trim(),
                              'email': 'admin@internal.com',
                            },
                            'status': 'confirmed',
                            'payment_method': 'internal',
                          }));
                        }

                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                child: creating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Text(
                        isWeekly
                            ? 'Crear Semanal'
                            : isSeries
                                ? '$weeksCount Semanas'
                                : 'Confirmar',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BookingTypeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;
  final Color accentColor;

  const _BookingTypeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.badge,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = selected
        ? accentColor.withOpacity(0.12)
        : AppColors.surfaceHighest.withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? accentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? accentColor : AppColors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null && selected)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge!,
                  style: GoogleFonts.inter(
                    color: accentColor == AppColors.recurringWeekly
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
    final badgeColor = isWeekly ? AppColors.recurringWeekly : AppColors.recurringSeries;

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
            if (item.type == RecurringType.weekly) {
              context.read<RecurringBloc>().add(CancelReservation(item.id));
            } else {
              context.read<RecurringBloc>().add(DeleteSeries(item.id));
            }
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