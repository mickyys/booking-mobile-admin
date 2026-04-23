import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_navigation_bar.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/tonal_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../domain/entities/booking.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String? _selectedStatus;
  DateTime? _selectedDate;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<DashboardBloc>().add(LoadDashboardData(
      customerName: _nameController.text.isNotEmpty ? _nameController.text : null,
      bookingCode: _codeController.text.isNotEmpty ? _codeController.text : null,
      status: _selectedStatus,
      date: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
      page: _currentPage,
    ));
  }

  String formatCLP(num value) => '\$ ${NumberFormat('#,###', 'es_CL').format(value)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            } else if (state is DashboardLoaded) {
              final data = state.data;
              return RefreshIndicator(
                onRefresh: () async {
                  _loadData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsRow(data),
                      const SizedBox(height: 24),
                      _buildFilters(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reservas Recientes',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Total: ${data.recentBookings.length}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (data.recentBookings.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Column(
                              children: [
                                Icon(Icons.search_off, size: 48, color: AppColors.onSurfaceVariant.withOpacity(0.5)),
                                const SizedBox(height: 16),
                                Text('No se encontraron reservas', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.recentBookings.length,
                          itemBuilder: (context, index) {
                            return _buildBookingCard(data.recentBookings[index]);
                          },
                        ),
                      _buildPagination(data.totalPages),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            } else if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, style: const TextStyle(color: AppColors.error)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadData, child: const Text('Reintentar')),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(currentPath: '/dashboard'),
    );
  }

  Widget _buildStatsRow(dynamic data) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'INGRESOS',
            value: formatCLP(data.totalRevenue),
            color: AppColors.primary,
            icon: Icons.attach_money,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'HOY',
            value: data.todayBookingsCount.toString(),
            color: Colors.white,
            icon: Icons.today,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'CANCEL.',
            value: data.cancelledCount.toString(),
            color: AppColors.error,
            icon: Icons.cancel_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(_nameController, 'Nombre cliente...', Icons.person_outline),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTextField(_codeController, 'Código...', Icons.qr_code_scanner),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDropdownFilter(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDateFilter(),
            ),
            if (_nameController.text.isNotEmpty || _codeController.text.isNotEmpty || _selectedStatus != null || _selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _nameController.clear();
                      _codeController.clear();
                      _selectedStatus = null;
                      _selectedDate = null;
                      _currentPage = 1;
                    });
                    _loadData();
                  },
                  icon: const Icon(Icons.refresh, color: AppColors.error),
                  style: IconButton.styleFrom(backgroundColor: AppColors.error.withOpacity(0.1)),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onSubmitted: (_) {
          setState(() => _currentPage = 1);
          _loadData();
        },
      ),
    );
  }

  Widget _buildDropdownFilter() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.surfaceHigh,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Filtrar por estado', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              _statusTile('Todos', null),
              _statusTile('Pendiente', 'pending'),
              _statusTile('Confirmado', 'confirmed'),
              _statusTile('Cancelado', 'cancelled'),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedStatus == null ? 'Estado' : _getStatusLabel(_selectedStatus!),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _statusTile(String label, String? status) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: _selectedStatus == status ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        setState(() {
          _selectedStatus = status;
          _currentPage = 1;
        });
        _loadData();
        Navigator.pop(context);
      },
    );
  }

  Widget _buildDateFilter() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2023),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
            _currentPage = 1;
          });
          _loadData();
        }
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDate == null ? 'Fecha' : DateFormat('dd/MM/yy').format(_selectedDate!),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    final isCancelled = booking.status.toLowerCase() == 'cancelled';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking.customerName.toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusBadge(booking.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoIcon(Icons.qr_code, booking.bookingCode),
                      const SizedBox(width: 16),
                      _buildInfoIcon(Icons.stadium_outlined, booking.courtName),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoIcon(Icons.calendar_today, _formatDate(booking.date)),
                      const SizedBox(width: 16),
                      _buildInfoIcon(Icons.access_time, '${booking.hour}:00 hrs'),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MÉTODO DE PAGO', style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          _buildPaymentBadge(booking.paymentMethod),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('TOTAL', style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(formatCLP(booking.price), style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isCancelled)
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: TextButton.icon(
                  onPressed: () => _confirmCancellation(booking),
                  icon: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.error),
                  label: Text('CANCELAR RESERVA', style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'confirmed':
        color = AppColors.primary;
        text = 'CONFIRMADO';
        break;
      case 'cancelled':
        color = AppColors.error;
        text = 'CANCELADO';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'PENDIENTE';
        break;
      default:
        color = AppColors.onSurfaceVariant;
        text = status.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  void _confirmCancellation(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('¿Cancelar Reserva?', style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro que deseas cancelar la reserva de ${booking.customerName} para el ${_formatDate(booking.date)} a las ${booking.hour}:00 hrs?',
          style: GoogleFonts.inter(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('NO, VOLVER', style: GoogleFonts.inter(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<DashboardBloc>().add(CancelDashboardBooking(
                bookingId: booking.id,
                customerName: _nameController.text.isNotEmpty ? _nameController.text : null,
                bookingCode: _codeController.text.isNotEmpty ? _codeController.text : null,
                status: _selectedStatus,
                date: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
                page: _currentPage,
              ));
            },
            child: const Text('SÍ, CANCELAR'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pendiente';
      case 'confirmed':
        return 'Confirmado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String _getPaymentMethodLabel(String method) {
    switch (method.toLowerCase()) {
      case 'mercadopago':
        return 'MercadoPago';
      case 'fintoc':
        return 'Fintoc';
      case 'flow':
        return 'Flow';
      case 'presential':
      case 'presencial':
      case 'venue':
        return 'Presencial';
      case 'internal':
      case 'interno':
      case 'internal_block':
      case 'internal_reservation':
        return 'Interno';
      default:
        return method;
    }
  }

  Widget _buildPaymentBadge(String method) {
    Color color;
    String text;

    switch (method.toLowerCase()) {
      case 'mercadopago':
        color = Colors.blue;
        text = 'MERCADO PAGO';
        break;
      case 'fintoc':
        color = Colors.indigo;
        text = 'FINTOC';
        break;
      case 'flow':
        color = Colors.purple;
        text = 'FLOW';
        break;
      case 'presential':
      case 'presencial':
      case 'venue':
        color = Colors.orange;
        text = 'PRESENCIAL';
        break;
      case 'internal':
      case 'interno':
      case 'internal_block':
      case 'internal_reservation':
        color = AppColors.primary;
        text = 'INTERNO';
        break;
      default:
        color = AppColors.onSurfaceVariant;
        text = method.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPagination(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 16, color: Colors.white),
            onPressed: _currentPage > 1 ? () {
              setState(() => _currentPage--);
              _loadData();
            } : null,
          ),
          const SizedBox(width: 16),
          Text('$_currentPage / $totalPages', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
            onPressed: _currentPage < totalPages ? () {
              setState(() => _currentPage++);
              _loadData();
            } : null,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return TonalCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
              Icon(icon, size: 14, color: color.withOpacity(0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
