import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../injection_container.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsScreen extends StatefulWidget {
  final String sportCenterId;
  const SettingsScreen({super.key, required this.sportCenterId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _slugController;
  late TextEditingController _cancelHoursController;
  late TextEditingController _cancelRetentionController;
  late TextEditingController _partialPaymentController;
  bool _partialPaymentEnabled = false;

  @override
  void initState() {
    super.initState();
    _slugController = TextEditingController();
    _cancelHoursController = TextEditingController();
    _cancelRetentionController = TextEditingController();
    _partialPaymentController = TextEditingController();
  }

  @override
  void dispose() {
    _slugController.dispose();
    _cancelHoursController.dispose();
    _cancelRetentionController.dispose();
    _partialPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SettingsBloc>()..add(LoadSettings(widget.sportCenterId)),
      child: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsLoaded) {
            final s = state.adminSportCenter.settings;
            final sc = state.adminSportCenter.sportCenter;
            _slugController.text = sc.slug;
            _cancelHoursController.text = s.cancellationHours.toString();
            _cancelRetentionController.text = s.cancellationRetention.toString();
            _partialPaymentController.text = s.partialPaymentPercentage.toString();
            setState(() {
              _partialPaymentEnabled = s.partialPaymentEnabled;
            });
          } else if (state is SettingsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            drawer: const AppDrawer(),
            appBar: AppBar(
              title: Text('Configuración', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            body: state is SettingsLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Información General'),
                          const SizedBox(height: 16),
                          _buildTextField('Slug / Subdominio', _slugController, prefix: 'reservaloya.cl/'),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              onPressed: () => context.push('/qr', extra: _slugController.text),
                              icon: const Icon(Icons.qr_code, color: AppColors.primary),
                              label: Text('VER CÓDIGO QR', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Políticas de Cancelación'),
                          const SizedBox(height: 16),
                          _buildTextField('Horas de anticipación', _cancelHoursController, keyboardType: TextInputType.number),
                          const SizedBox(height: 16),
                          _buildTextField('% Retención por cancelación', _cancelRetentionController, keyboardType: TextInputType.number),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Pagos Parciales'),
                          const SizedBox(height: 8),
                          SwitchListTile(
                            title: Text('Habilitar pagos parciales', style: GoogleFonts.inter(color: Colors.white)),
                            value: _partialPaymentEnabled,
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => _partialPaymentEnabled = val),
                            contentPadding: EdgeInsets.zero,
                          ),
                          if (_partialPaymentEnabled)
                            _buildTextField('% Pago requerido para reservar', _partialPaymentController, keyboardType: TextInputType.number),
                          const SizedBox(height: 48),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<SettingsBloc>().add(UpdateSettings(
                                        id: widget.sportCenterId,
                                        data: {'slug': _slugController.text},
                                        settings: {
                                          'cancellation_hours': int.tryParse(_cancelHoursController.text) ?? 0,
                                          'cancellation_retention': double.tryParse(_cancelRetentionController.text) ?? 0.0,
                                          'partial_payment_enabled': _partialPaymentEnabled,
                                          'partial_payment_percentage': double.tryParse(_partialPaymentController.text) ?? 0.0,
                                        },
                                      ));
                                }
                              },
                              child: Text('GUARDAR CAMBIOS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 1.2),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {String? prefix, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            prefixText: prefix,
            prefixStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: AppColors.surfaceHigh,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
