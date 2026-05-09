import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  static const String _defaultVersion = '1.0.0';

  static Future<String> getVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return _defaultVersion;
    }
  }
}
