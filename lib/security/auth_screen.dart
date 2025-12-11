import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';


class AuthScreen extends StatefulWidget {
  final String pinCorrecto;

  const AuthScreen({super.key, required this.pinCorrecto});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _pinController = TextEditingController();

  void _validarPin() {
    final input = _pinController.text.trim();
    final hashedInput = sha256.convert(utf8.encode(input)).toString();

    if (hashedInput == widget.pinCorrecto) {
      Navigator.pop(context, true); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ PIN incorrecto")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🔒 Verifica tu PIN")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Ingresa tu PIN para continuar", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "PIN",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validarPin,
              child: const Text("Desbloquear"),
            ),
          ],
        ),
      ),
    );
  }
}
