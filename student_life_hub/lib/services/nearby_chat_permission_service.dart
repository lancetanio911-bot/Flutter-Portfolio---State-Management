import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class NearbyChatPermissionService {
  static const fallbackDeviceName = 'Student Life Hub';

  Future<String> requestAndGetDeviceName() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;
    final permissionResults = await _requiredPermissions(sdkInt).request();

    if (permissionResults.values.any((status) => !status.isGranted)) {
      throw StateError(
        'Allow Nearby devices and Bluetooth permissions to discover nearby devices. '
        'If you denied a permission permanently, enable it in Android Settings.',
      );
    }

    if (sdkInt <= 30 && !await Permission.location.serviceStatus.isEnabled) {
      throw StateError('Turn on Location services to discover nearby devices.');
    }

    final deviceName = androidInfo.model.trim();
    return deviceName.isEmpty ? fallbackDeviceName : deviceName;
  }

  List<Permission> _requiredPermissions(int sdkInt) => [
    if (sdkInt <= 30) Permission.location,
    if (sdkInt >= 31) ...[
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
    ],
    if (sdkInt >= 33) Permission.nearbyWifiDevices,
  ];
}
