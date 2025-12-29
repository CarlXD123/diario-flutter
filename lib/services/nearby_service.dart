import 'package:flutter/services.dart';

class NearbyService {
  static const _channel = MethodChannel('nearby');

  static Future<void> advertise() =>
      _channel.invokeMethod('startAdvertising');

  static Future<void> discover() =>
      _channel.invokeMethod('startDiscovery');

  static Future<void> send(String msg) =>
      _channel.invokeMethod('sendMessage', {'msg': msg});

  static void onMessage(void Function(String) cb) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onMessage') {
        cb(call.arguments as String);
      }
    });
  }
}
