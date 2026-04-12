import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reservaloya_admin/core/theme/app_colors.dart';
import 'package:reservaloya_admin/core/widgets/app_navigation_bar.dart';
import '../bloc/agenda_bloc.dart';
import '../bloc/agenda_event.dart';
import '../bloc/agenda_state.dart';
import '../../domain/entities/sport_center.dart';

class CourtsScreen extends StatefulWidget {
  const CourtsScreen({super.key});

  @override
  State<CourtsScreen> createState() => _CourtsScreenState();
}

class _CourtsScreenState extends State<CourtsScreen> {
  String? _currentSportCenterId;

  @override
  void initState() {
    super.initState();
    context.read<AgendaBloc>().add(LoadAdminCourts());
  }

  void _showAddCourtDialog() {
    if (_currentSportCenterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se ha seleccionado un centro deportivo')),
      );
      return;
    }

    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text('Nueva Cancha', style: GoogleFonts.manrope(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Nombre', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Descripción', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<AgendaBloc>().add(AddCourt(
                    sportCenterId: _currentSportCenterId!,
                    name: nameController.text,
                    description: descController.text,
                  ));
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditCourtDialog(AdminCourt court) {
    final nameController = TextEditingController(text: court.name);
    final descController = TextEditingController(text: court.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text('Editar Cancha', style: GoogleFonts.manrope(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Nombre', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Descripción', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              context.read<AgendaBloc>().add(UpdateCourtEvent(
                    courtId: court.id,
                    name: nameController.text,
                    description: descController.text,
                  ));
              Navigator.pop(context);
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(AdminCourt court) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text('Eliminar Cancha', style: GoogleFonts.manrope(color: Colors.white)),
        content: Text('¿Estás seguro de que deseas eliminar la cancha "${court.name}"?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<AgendaBloc>().add(DeleteCourtEvent(courtId: court.id));
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AgendaBloc, AgendaState>(
      listener: (context, state) {
        if (state is CourtActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating),
          );
        } else if (state is AgendaError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<AgendaBloc, AgendaState>(
            builder: (context, state) {
              if (state is AdminCourtsLoaded && state.adminCourts.isNotEmpty) {
                _currentSportCenterId = state.adminCourts.first.sportCenter.id;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  Expanded(
                    child: _buildBody(state),
                  ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddCourtDialog,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: AppColors.onPrimary),
        ),
        bottomNavigationBar: const AppNavigationBar(currentPath: '/courts'),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
            'Gestión de Canchas',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            icon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
            hintText: 'Buscar cancha...',
            hintStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AgendaState state) {
    if (state is AgendaLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    } else if (state is AdminCourtsLoaded) {
      final courts = state.adminCourts.isNotEmpty ? state.adminCourts.first.courts : <AdminCourt>[];
      return _buildCourtList(courts);
    } else if (state is AgendaLoaded || state is CourtActionSuccess) {
       // If data was already loaded or action was success, we stay in this state but
       // AdminCourtsLoaded is re-emitted by the bloc after CRUD actions.
       // Let's ensure we show a loader if nothing is ready.
       return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    } else if (state is AgendaError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.message, style: const TextStyle(color: AppColors.error)),
            ElevatedButton(onPressed: () => context.read<AgendaBloc>().add(LoadAdminCourts()), child: const Text('Reintentar')),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
  }

  Widget _buildCourtList(List<AdminCourt> courts) {
    if (courts.isEmpty) {
      return const Center(child: Text('No hay canchas configuradas.', style: TextStyle(color: Colors.white)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: courts.length,
      itemBuilder: (context, index) {
        final court = courts[index];
        return _buildCourtCard(court);
      },
    );
  }

  Widget _buildCourtCard(AdminCourt court) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.stadium, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      court.name,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      court.description.isNotEmpty ? court.description : 'Cancha de Padel',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                onPressed: () => _showDeleteConfirmDialog(court),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildFeatureIcon(Icons.wb_sunny_outlined),
                  _buildFeatureIcon(Icons.roofing),
                  _buildFeatureIcon(Icons.lightbulb_outline),
                ],
              ),
              TextButton.icon(
                onPressed: () => _showEditCourtDialog(court),
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                label: Text(
                  'Editar',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
    );
  }
}
