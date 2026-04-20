import 'dart:io';
import 'package:dio/dio.dart';

class CloudinaryUtils {
  static const String cloudName = 'dm1syhrrr';
  static const String uploadPreset = 'reservaloya';

  static Future<String> uploadImage(File file) async {
    final dio = Dio();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'upload_preset': uploadPreset,
      'folder': 'reservaloya/courts',
    });

    try {
      final response = await dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        String secureUrl = data['secure_url'];
        // Optimization: apply transformations
        return secureUrl.replaceFirst('/upload/', '/upload/c_fill,w_800,h_600,q_auto:low,f_auto/');
      } else {
        throw Exception('Error al subir imagen a Cloudinary');
      }
    } catch (e) {
      throw Exception('Error de conexión con Cloudinary: $e');
    }
  }
}
