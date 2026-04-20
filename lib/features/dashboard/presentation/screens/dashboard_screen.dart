import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_navigation_bar.dart';
import '../../../../core/widgets/app_drawer.dart';
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
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  DateTime? _selectedDate;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<DashboardBloc>().add(LoadDashboardData(
      customerName: _searchController.text.isNotEmpty ? _searchController.text : null,
      status: _selectedStatus,
      date: _selectedDate != null ? DateFormat('yyyy-MM-dd').format(_selectedDate!) : null,
      page: _currentPage,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'es_AR', symbol: '', decimalDigits: 0);
    String formatCLP(num value) => '\$ ${NumberFormat('#,###', 'es_CL').format(value)}';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
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
                  _loadData();
                },
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 120.0,
                      floating: false,
                      pinned: true,
                      backgroundColor: AppColors.background,
                      elevation: 0,
                      leading: Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
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
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    title: 'Ingresos',
                                    value: formatCLP(data.totalRevenue),
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    title: 'Hoy',
                                    value: data.todayBookingsCount.toString(),
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    title: 'Cancel.',
                                    value: data.cancelledCount.toString(),
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildFiltersCompact(),
                            const SizedBox(height: 16),
                            Text(
                              'Reservas',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.person, color: AppColors.primary, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(booking.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        Text('${_formatDate(booking.date)} ${booking.hour}:00 • ${booking.courtName}', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(formatCLP(booking.price), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14)),
                                      _buildPaymentBadge(booking.paymentMethod),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: data.recentBookings.length,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _buildPagination(data.totalPages),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
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

  Widget _buildFiltersCompact() {
    return Column(
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Buscar por nombre...',
              hintStyle: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
            onSubmitted: (_) {
              setState(() => _currentPage = 1);
              _loadData();
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Material(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
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
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDate == null ? 'Seleccionar fecha' : DateFormat('dd/MM/yyyy', 'es_ES').format(_selectedDate!),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
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
                        ListTile(title: const Text('Todos', style: TextStyle(color: Colors.white)), onTap: () { setState(() => _selectedStatus = null); _loadData(); Navigator.pop(context); }),
                        ListTile(title: const Text('Pendiente', style: TextStyle(color: Colors.white)), onTap: () { setState(() => _selectedStatus = 'pending'); _loadData(); Navigator.pop(context); }),
                        ListTile(title: const Text('Confirmado', style: TextStyle(color: Colors.white)), onTap: () { setState(() => _selectedStatus = 'confirmed'); _loadData(); Navigator.pop(context); }),
                        ListTile(title: const Text('Cancelado', style: TextStyle(color: Colors.white)), onTap: () { setState(() => _selectedStatus = 'cancelled'); _loadData(); Navigator.pop(context); }),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.filter_list, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _selectedStatus == null ? 'Todos los estados' : _getStatusLabel(_selectedStatus!),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty || _selectedStatus != null || _selectedDate != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searchController.clear();
                    _selectedStatus = null;
                    _selectedDate = null;
                    _currentPage = 1;
                  });
                  _loadData();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close, color: AppColors.error, size: 18),
                ),
              ),
          ],
        ),
      ],
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

  Widget _buildFilters() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Buscar por nombre...',
            hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.surfaceHigh,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          onSubmitted: (_) {
            setState(() => _currentPage = 1);
            _loadData();
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(_selectedDate == null ? 'Fecha' : DateFormat('dd/MM').format(_selectedDate!)),
                onPressed: () async {
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
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                dropdownColor: AppColors.surfaceHigh,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  filled: true,
                  fillColor: AppColors.surfaceHigh,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                hint: const Text('Estado', style: TextStyle(color: Colors.white, fontSize: 13)),
                items: ['pending', 'confirmed', 'cancelled'].map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedStatus = val;
                    _currentPage = 1;
                  });
                  _loadData();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.error),
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedStatus = null;
                  _selectedDate = null;
                  _currentPage = 1;
                });
                _loadData();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPagination(int totalPages) {
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

  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return TonalCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
