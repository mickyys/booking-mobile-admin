import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clipboard/clipboard.dart' as FlutterClipboard;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_navigation_bar.dart';
import '../../../../core/widgets/app_drawer.dart';

class QRScreen extends StatefulWidget {
  final String slug;
  const QRScreen({super.key, required this.slug});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  late String _qrUrl;
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _qrUrl = 'https://reservaloya.cl/${widget.slug}/reservar';
  }

  Future<Uint8List> _captureQRBytes() async {
    final boundary =
        _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw Exception('No se pudo capturar el QR');

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw Exception('No se pudo generar la imagen');

    return byteData.buffer.asUint8List();
  }

  Future<File> _captureQRFile() async {
    final bytes = await _captureQRBytes();
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/qr_code.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _shareQRImage() async {
    try {
      final file = await _captureQRFile();
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Reserva en mi club aquí: $_qrUrl');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al compartir QR: $e')));
      }
    }
  }

  Future<void> _copyQR() async {
    try {
      final bytes = await _captureQRBytes();
      await FlutterClipboard.copyImage(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR copiado al portapapeles')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al copiar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Generador QR',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: RepaintBoundary(
                key: _qrKey,
                child: QrImageView(
                  data: _qrUrl,
                  version: QrVersions.auto,
                  size: 250.0,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Tu código QR está listo',
              style: GoogleFonts.manrope(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los clientes pueden escanear este código para ir directamente a tu página de reservas.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _qrUrl,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.share_outlined,
                    label: 'Compartir',
                    onPressed: _shareQRImage,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.copy_outlined,
                    label: 'Copiar',
                    onPressed: _copyQR,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(currentPath: '/qr'),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surfaceHigh,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.primary, size: 20),
      label: Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
    );
  }
}
