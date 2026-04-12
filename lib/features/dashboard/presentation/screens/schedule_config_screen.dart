import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_navigation_bar.dart';
import '../../../../core/widgets/tonal_card.dart';

class ScheduleConfigScreen extends StatelessWidget {
  const ScheduleConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
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
                      'Horarios de Atención',
                      style: GoogleFonts.manrope(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildDaySchedule(context, 'Lunes', '08:00 - 23:00', true),
                  _buildDaySchedule(context, 'Martes', '08:00 - 23:00', true),
                  _buildDaySchedule(context, 'Miércoles', '08:00 - 23:00', true),
                  _buildDaySchedule(context, 'Jueves', '08:00 - 23:00', true),
                  _buildDaySchedule(context, 'Viernes', '08:00 - 00:00', true),
                  _buildDaySchedule(context, 'Sábado', '07:00 - 00:00', true),
                  _buildDaySchedule(context, 'Domingo', '07:00 - 22:00', true),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(currentPath: '/schedule-config'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.save_outlined, color: AppColors.onPrimary),
        label: Text('Guardar Cambios', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.onPrimary)),
      ),
    );
  }

  Widget _buildDaySchedule(BuildContext context, String day, String hours, bool isOpen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TonalCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOpen ? hours : 'Cerrado',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isOpen ? AppColors.primary : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isOpen,
              onChanged: (val) {},
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.onSurfaceVariant, size: 20),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
