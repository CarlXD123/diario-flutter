import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../services/database_service.dart';

class PinDialogs {
  static void protegerEntrada(BuildContext context, Map<String, dynamic> entrada) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Asignar PIN de Seguridad"),
        content: TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "PIN (4 dígitos)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final pin = pinController.text.trim();
              if (pin.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🔐 El PIN debe tener 4 dígitos")),
                );
                return;
              }
              await DatabaseService.protegerEntrada(entrada['id'], pin);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Entrada protegida con PIN")),
              );
              Navigator.pop(context, true);
            },
            child: const Text("Guardar PIN"),
          ),
        ],
      ),
    );
  }

  static void quitarProteccion(BuildContext context, Map<String, dynamic> entrada) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quitar Protección"),
        content: TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "PIN actual"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final pin = pinController.text.trim();
              final hashedInput = sha256.convert(utf8.encode(pin)).toString();
              if (hashedInput != entrada['pin']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("❌ PIN incorrecto")),
                );
                return;
              }
              await DatabaseService.quitarPin(entrada['id']);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("🔓 Protección eliminada")),
              );
              Navigator.pop(context, true);
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }
}
