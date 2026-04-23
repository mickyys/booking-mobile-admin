import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reservaloya_admin/core/theme/app_colors.dart';
import 'package:reservaloya_admin/core/widgets/app_navigation_bar.dart';
import 'package:reservaloya_admin/core/widgets/app_drawer.dart';
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
  final ScrollController _horizontalHeaderController = ScrollController();
  final ScrollController _horizontalBodyController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AgendaBloc>().add(LoadAdminCourts());

    _horizontalBodyController.addListener(() {
      if (_horizontalHeaderController.hasClients &&
          _horizontalHeaderController.offset !=
              _horizontalBodyController.offset) {
        _horizontalHeaderController.jumpTo(_horizontalBodyController.offset);
      }
    });

    _horizontalHeaderController.addListener(() {
      if (_horizontalBodyController.hasClients &&
          _horizontalBodyController.offset !=
              _horizontalHeaderController.offset) {
        _horizontalBodyController.jumpTo(_horizontalHeaderController.offset);
      }
    });
  }

  @override
  void dispose() {
    _horizontalHeaderController.dispose();
    _horizontalBodyController.dispose();
    super.dispose();
  }

  void _loadAgenda() {
    if (_selectedSportCenterId != null) {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      context.read<AgendaBloc>().add(
        LoadAgendaData(sportCenterId: _selectedSportCenterId!, date: dateStr),
      );
    }
  }

  void _showInternalBookingDialog(
    TimeSlot slot,
    String courtId,
    String courtName,
  ) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final priceController = TextEditingController(
      text: slot.price.toInt().toString(),
    );
    bool isBlocked = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceHigh,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isBlocked ? 'Bloquear Horario' : 'Reserva Manual',
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: isBlocked,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      isBlocked = value;
                    });
                  },
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.stadium_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                courtName,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Hora: ${slot.hour}:00',
                                style: GoogleFonts.inter(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (!isBlocked) ...[
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nombre Cliente',
                        labelStyle: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: AppColors.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        labelStyle: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                        ),
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          color: AppColors.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Precio',
                        labelStyle: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                        ),
                        prefixIcon: const Icon(
                          Icons.attach_money,
                          color: AppColors.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white10),
                        ),
                      ),
                    ),
                  ] else ...[
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.block,
                              color: AppColors.error,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Este horario quedará marcado como bloqueado y no estará disponible para reservas externas.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancelar',
                  style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBlocked
                      ? AppColors.error
                      : AppColors.primary,
                  foregroundColor: isBlocked
                      ? Colors.white
                      : AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  final now = DateTime.now().toUtc();
                  final dateStr = DateFormat(
                    'yyyy-MM-dd',
                  ).format(_selectedDate);
                  final hourStr = now.hour.toString().padLeft(2, '0');
                  final minStr = now.minute.toString().padLeft(2, '0');
                  final Map<String, dynamic> bookingData = {
                    'court_id': courtId,
                    'sport_center_id': _selectedSportCenterId,
                    'date': '${dateStr}T${hourStr}:${minStr}:00.000+00:00',
                    'hour': slot.hour,
                    'minutes': slot.minutes,
                    'price': isBlocked
                        ? 0.0
                        : (double.tryParse(priceController.text) ?? slot.price),
                    'payment_method': 'internal',
                  };

                  if (isBlocked) {
                    bookingData['customer_name'] = 'BLOQUEADO';
                  } else {
                    bookingData['customer_name'] = nameController.text;
                    bookingData['customer_phone'] = phoneController.text;
                  }

                  context.read<AgendaBloc>().add(
                    CreateInternalBookingEvent(bookingData: bookingData),
                  );
                  Navigator.pop(context);
                },
                child: Text(isBlocked ? 'Bloquear' : 'Reservar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBookingDetailsDialog(TimeSlot slot) {
    final booking = slot.booking;
    if (booking == null) return;

    final phone = booking.customerPhone;
    final formattedPhone = _formatPhoneForWhatsApp(phone);
    
    final sportCenterName = _availableCenters.isNotEmpty
        ? (_availableCenters.first.sportCenter.slug.isNotEmpty
            ? _availableCenters.first.sportCenter.slug
            : _availableCenters.first.sportCenter.name)
        : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text(
          'Detalle de Reserva',
          style: GoogleFonts.manrope(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Cliente:', _capitalizeName(booking.customerName)),
            _detailRow('Teléfono:', phone.isEmpty ? 'No informado' : phone),
            _detailRow('Código:', booking.bookingCode),
            _detailRow('Método:', _getPaymentMethodLabel(booking.paymentMethod)),
            _detailRow('Precio:', _formatPrice(booking.price)),
            if (formattedPhone != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _openWhatsApp(
                        formattedPhone,
                        booking.customerName,
                        _selectedDate,
                        slot.hour,
                        slot.minutes,
                        sportCenterName,
                      ),
                      child: FaIcon(FontAwesomeIcons.whatsapp, size: 22),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _makePhoneCall(formattedPhone),
                      child: FaIcon(FontAwesomeIcons.phone, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onPrimary,
            ),
            onPressed: () {
              context.read<AgendaBloc>().add(
                CancelBookingEvent(
                  bookingId: booking.id,
                  sportCenterId: _selectedSportCenterId!,
                  date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Cancelar Reserva'),
          ),
        ],
      ),
    );
  }

  String? _formatPhoneForWhatsApp(String phone) {
    if (phone.isEmpty) return null;

    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length == 8) {
      return '+569$digits';
    } else if (digits.length == 9 && digits.startsWith('9')) {
      return '+56$digits';
    } else if (digits.length == 10 && digits.startsWith('56')) {
      return '+$digits';
    } else if (digits.length == 11 && digits.startsWith('569')) {
      return '+$digits';
    } else if (phone.startsWith('+56') && digits.length == 11) {
      return phone;
    } else if (phone.startsWith('+56') && digits.length == 10) {
      return '+$digits';
    }
    
    return null;
  }

  Future<void> _openWhatsApp(
    String phone,
    String customerName,
    DateTime date,
    int hour,
    int minutes,
    String sportCenterName,
  ) async {
    final formattedDate = DateFormat('dd/MM/yyyy').format(date);
    final hourStr = hour.toString().padLeft(2, '0');
    final minStr = minutes.toString().padLeft(2, '0');
    final sportCenterCapitalized = _capitalizeName(sportCenterName);
    
    final message = Uri.encodeComponent(
      'Hola $customerName te contactamos desde $sportCenterCapitalized por tu reserva para el dia $formattedDate a la hora $hourStr:$minStr',
    );
    final uri = Uri.parse('https://wa.me/$phone?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _capitalizeName(String name) {
    if (name.isEmpty) return name;
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat.currency(
      locale: 'es_CL',
      symbol: '\$',
      decimalDigits: 0,
    );
    return formatter.format(price);
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
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
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AgendaError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: const AppDrawer(),
        body: SafeArea(
          child: BlocListener<AgendaBloc, AgendaState>(
            listener: (context, state) {
              if (state is AdminCourtsLoaded) {
                setState(() {
                  _availableCenters = state.adminCourts;
                  if (_availableCenters.isNotEmpty &&
                      _selectedSportCenterId == null) {
                    _selectedSportCenterId =
                        _availableCenters.first.sportCenter.id;
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
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      } else if (state is AgendaLoaded) {
                        return _buildAgendaView(state.schedules);
                      } else if (state is AgendaError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                state.message,
                                style: const TextStyle(color: AppColors.error),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadAgenda,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        );
                      }
                      return const Center(
                        child: Text(
                          'Cargando agenda...',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const AppNavigationBar(currentPath: '/agenda'),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 8),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HORARIO SELECCIONADO',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                DateFormat(
                  'MMMM yyyy',
                  'es',
                ).format(_selectedDate).toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const Spacer(),
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
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected =
              DateFormat('yyyy-MM-dd').format(date) ==
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
                      color: isSelected
                          ? AppColors.onPrimary
                          : AppColors.onSurfaceVariant,
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
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.surfaceLow : Colors.transparent,
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
      return const Center(
        child: Text(
          'No hay canchas disponibles.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final allSlots = <String>{};
    for (var schedule in schedules) {
      for (var slot in schedule.slots) {
        allSlots.add('${slot.hour}:${slot.minutes}');
      }
    }
    final sortedSlotKeys = allSlots.toList()..sort();

    const double hourColWidth = 80.0;
    const double columnWidth = 140.0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              SizedBox(
                width: hourColWidth,
                child: Center(
                  child: Text(
                    'Hora',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _horizontalHeaderController,
                  child: Row(
                    children: schedules
                        .map(
                          (court) => Container(
                            width: columnWidth,
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Text(
                                  court.courtName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'PRINCIPAL',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Body (Scrollable vertically)
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fixed Hours Column
                SizedBox(
                  width: hourColWidth,
                  child: Column(
                    children: sortedSlotKeys.map((slotKey) {
                      final parts = slotKey.split(':');
                      final hour = int.parse(parts[0]);
                      final minutes = int.parse(parts[1]);
                      return SizedBox(
                        height: 100,
                        child: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
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
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Scrollable Court Slots Grid
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _horizontalBodyController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sortedSlotKeys.map((slotKey) {
                        final parts = slotKey.split(':');
                        final hour = int.parse(parts[0]);
                        final minutes = int.parse(parts[1]);
                        return SizedBox(
                          height: 100,
                          child: Row(
                            children: schedules.map((court) {
                              TimeSlot? foundSlot;
                              for (final s in court.slots) {
                                if (s.hour == hour && s.minutes == minutes) {
                                  foundSlot = s;
                                  break;
                                }
                              }
                              final slot =
                                  foundSlot ??
                                  TimeSlot(
                                    hour: hour,
                                    minutes: minutes,
                                    price: 0.0,
                                    status: 'closed',
                                    paymentRequired: false,
                                    paymentOptional: false,
                                  );
                              return Container(
                                width: columnWidth,
                                padding: const EdgeInsets.all(4),
                                child: _buildSlotCard(
                                  slot,
                                  court.courtId,
                                  court.courtName,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotCard(TimeSlot slot, String courtId, String courtName) {
    switch (slot.status) {
      case 'available':
        return GestureDetector(
          onTap: () => _showInternalBookingDialog(slot, courtId, courtName),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primary,
                width: 1.5,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_circle,
                  color: AppColors.primary,
                  size: 20,
                ),
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
          ),
        );
      case 'booked':
      case 'passed_booked':
        final isPassed = slot.status == 'passed_booked';
        return GestureDetector(
          onTap: () => _showBookingDetailsDialog(slot),
          child: Container(
            height: 80,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(
                  color: isPassed ? Colors.white : AppColors.primary,
                  width: 4,
                ),
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
