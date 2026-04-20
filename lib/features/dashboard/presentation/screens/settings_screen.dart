import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../injection_container.dart';
import '../../../../core/widgets/app_navigation_bar.dart';
import '../../../../core/utils/cloudinary_utils.dart';
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
  String? _imageUrl;
  File? _localImageFile;
  bool _isUploading = false;

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _localImageFile = File(pickedFile.path);
      });
    }
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
            _imageUrl = sc.imageUrl;
            _cancelHoursController.text = s.cancellationHours.toString();
            _cancelRetentionController.text = s.retentionPercent.toString();
            _partialPaymentController.text = s.partialPaymentPercent.toString();
            setState(() {
              _partialPaymentEnabled = s.partialPaymentEnabled;
            });
          } else if (state is SettingsSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
            );
            setState(() {
              _localImageFile = null;
              _isUploading = false;
            });
          } else if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
            setState(() {
              _isUploading = false;
            });
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            drawer: const AppDrawer(),
            appBar: AppBar(
              title: Text('Configuración del Club', style: GoogleFonts.manrope(fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ),
            body: state is SettingsLoading && _slugController.text.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCard(
                            title: 'Imagen del Club',
                            icon: Icons.image_outlined,
                            child: _buildImageSection(),
                          ),
                          const SizedBox(height: 24),
                          _buildCard(
                            title: 'Información General',
                            icon: Icons.settings_outlined,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  'Subdominio (Slug)', 
                                  _slugController, 
                                  prefix: 'reservaloya.cl/',
                                  hint: 'ej: orellana',
                                  icon: Icons.public,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Esto se usará para acceder directamente via ${_slugController.text.isEmpty ? 'tu-club' : _slugController.text}.reservaloya.cl',
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                                ),
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
                                    icon: const Icon(Icons.qr_code, color: AppColors.primary, size: 20),
                                    label: Text('VER CÓDIGO QR', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildCard(
                            title: 'Políticas de Cancelación',
                            icon: Icons.error_outline,
                            child: Column(
                              children: [
                                _buildTextField(
                                  'Horas límite devolución 100%', 
                                  _cancelHoursController, 
                                  keyboardType: TextInputType.number,
                                  icon: Icons.access_time,
                                  suffix: 'horas',
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  '% Retención cancelación tardía', 
                                  _cancelRetentionController, 
                                  keyboardType: TextInputType.number,
                                  icon: Icons.percent,
                                  suffix: '%',
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Si cancela con menos de ${_cancelHoursController.text} horas, se retiene el ${_cancelRetentionController.text}% del pago.',
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildCard(
                            title: 'Pagos Parciales (Abonos)',
                            icon: Icons.credit_card_outlined,
                            child: Column(
                              children: [
                                SwitchListTile(
                                  title: Text('Activar pagos parciales', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text('Permitir a los usuarios pagar solo un abono al reservar.', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                                  value: _partialPaymentEnabled,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) => setState(() => _partialPaymentEnabled = val),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  'Porcentaje de abono requerido', 
                                  _partialPaymentController, 
                                  keyboardType: TextInputType.number,
                                  icon: Icons.payments_outlined,
                                  suffix: '%',
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'El usuario pagará el ${_partialPaymentController.text}% al reservar y el resto en el club.',
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildSaveButton(context),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: const AppNavigationBar(currentPath: '/settings'),
          );
        },
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _isUploading ? null : _pickImage,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10, style: BorderStyle.solid),
              image: _localImageFile != null
                  ? DecorationImage(image: FileImage(_localImageFile!), fit: BoxFit.cover)
                  : (_imageUrl != null
                      ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
                      : null),
            ),
            child: _localImageFile == null && _imageUrl == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_upload_outlined, color: AppColors.onSurfaceVariant, size: 40),
                      const SizedBox(height: 8),
                      Text('Sube una imagen del club', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 13)),
                      Text('JPG, PNG hasta 5MB', style: GoogleFonts.inter(color: AppColors.onSurfaceVariant.withOpacity(0.5), fontSize: 11)),
                    ],
                  )
                : Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 16,
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        if (_localImageFile != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text('Imagen seleccionada - se subirá al guardar', style: GoogleFonts.inter(color: AppColors.primary, fontSize: 12)),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _localImageFile = null),
                child: Text('Eliminar', style: GoogleFonts.inter(color: AppColors.error, fontSize: 12)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTextField(
    String label, 
    TextEditingController controller, {
    String? prefix, 
    String? hint,
    String? suffix,
    TextInputType? keyboardType,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
          onChanged: (v) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, color: AppColors.onSurfaceVariant, size: 20) : null,
            prefixText: prefix,
            prefixStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
            suffixText: suffix,
            suffixStyle: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold),
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.white24),
            filled: true,
            fillColor: Colors.black12,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        onPressed: _isUploading ? null : () async {
          if (_formKey.currentState!.validate()) {
            setState(() => _isUploading = true);
            
            try {
              String? finalImageUrl = _imageUrl;
              if (_localImageFile != null) {
                finalImageUrl = await CloudinaryUtils.uploadImage(_localImageFile!);
              }

              if (!mounted) return;
              context.read<SettingsBloc>().add(UpdateSettings(
                id: widget.sportCenterId,
                settings: {
                  'slug': _slugController.text,
                  'image_url': finalImageUrl,
                  'cancellation_hours': int.tryParse(_cancelHoursController.text) ?? 0,
                  'retention_percent': int.tryParse(_cancelRetentionController.text) ?? 0,
                  'partial_payment_enabled': _partialPaymentEnabled,
                  'partial_payment_percent': int.tryParse(_partialPaymentController.text) ?? 0,
                },
              ));
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al subir imagen: $e'), backgroundColor: AppColors.error),
              );
              setState(() => _isUploading = false);
            }
          }
        },
        child: _isUploading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
              )
            : Text(
                'GUARDAR CAMBIOS',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
              ),
      ),
    );
  }
}
