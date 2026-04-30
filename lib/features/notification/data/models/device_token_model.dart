import 'dart:io';

import 'package:equatable/equatable.dart';

class DeviceTokenModel extends Equatable {
  final String token;
  final String platform;
  final String deviceName;
  final String osVersion;

  const DeviceTokenModel({
    required this.token,
    required this.platform,
    required this.deviceName,
    required this.osVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'platform': platform,
      'device_name': deviceName,
      'os_version': osVersion,
    };
  }

  static String getPlatform() {
    return Platform.isIOS ? 'ios' : 'android';
  }

  static String getDeviceName() {
    if (Platform.isIOS) {
      return 'iPhone/iPad';
    } else {
      return 'Android Device';
    }
  }

  static String getOSVersion() {
    if (Platform.isIOS) {
      return 'iOS';
    } else {
      return 'Android';
    }
  }

  @override
  List<Object?> get props => [token, platform, deviceName, osVersion];
}
