import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../screens/reminders_screen.dart';
import '../screens/add_reminder_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/database_service.dart';
import '../components/home_screen/color_picker_section.dart';
import '../components/home_screen/image_preview_section.dart';
import '../components/home_screen/buttons_section.dart';
import '../components/home_screen/ad_banner_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? imagenSeleccionada;
  final TextEditingController _notaController = TextEditingController();
  final picker = ImagePicker();
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
  }

  Future<void> seleccionarImagen() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  void guardarEntrada() async {
    if (_notaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✍️ Escribe algo para guardar tu recuerdo"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    await DatabaseService.insertEntrada(
      imagenSeleccionada?.path, // 👈 ahora puede ser null
      _notaController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.bookmark_added, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "💾 Recuerdo guardado",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 10,
      ),
    );

    setState(() {
      imagenSeleccionada = null;
      _notaController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("¿Cómo te sientes hoy?")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.alarm),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddReminderScreen(),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ColorPickerSection(),
            const SizedBox(height: 10),
            ButtonsSection(
              onSeleccionarImagen: seleccionarImagen,
              onGuardar: guardarEntrada,
            ),
            const SizedBox(height: 10),
            ImagePreviewSection(imagen: imagenSeleccionada),
            const SizedBox(height: 30),
            TextField(
              controller: _notaController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                labelText: 'Tu pensamiento',
                hintText: '¿Qué pasó hoy?',
              )

            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: guardarEntrada,
              icon: Icon(Icons.save),
              label: Text("Guardar en diario"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),

            const SizedBox(height: 16), // 👈 salto de línea / espacio
            
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RemindersScreen()),
                );
              },
              icon: const Icon(Icons.alarm),
              label: const Text("Recordatorios"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.deepPurple,
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: _bannerAd != null
          ? AdBannerWidget(bannerAd: _bannerAd!)
          : null,
    );
  }
}
