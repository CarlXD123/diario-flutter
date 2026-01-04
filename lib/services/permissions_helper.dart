import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'permissions.dart';

class PermissionsHelper {
  static const _key = 'permisos_bluetooth_mostrados';

  static Future<bool> checkAndRequest(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final yaMostrado = prefs.getBool(_key) ?? false;

    if (yaMostrado) {
      return true; // ✅ ya aceptó antes
    }

    final resultado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Permisos necesarios"),
        content: const Text(
          "Para comunicarte con dispositivos cercanos, "
          "esta función necesita acceso a Bluetooth y Wi-Fi.\n\n"

          "🔹 Cómo usar la conexión:\n"
          "• 📡 Esperar conexion: Mantén este dispositivo esperando una conexión\n"
          "• 🔍 Buscar conexion: Busca dispositivos cercanos para conectarte\n\n"

          "🔒 Privacidad:\n"
          "• No usamos Internet\n"
          "• No guardamos tu ubicación\n"
          "• Todo funciona localmente"
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              await requestNearbyPermissions();
              await prefs.setBool(_key, true);
              Navigator.pop(context, true);
            },
            child: const Text("Continuar"),
          ),
        ],
      ),
    );
    return resultado ?? false;
  }
}

