import 'package:permission_handler/permission_handler.dart';

Future<void> requestNearbyPermissions() async {
  await [
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.bluetoothAdvertise,
    Permission.nearbyWifiDevices,
    Permission.locationWhenInUse,
  ].request();
}
