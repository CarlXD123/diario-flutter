import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../screens/reminders_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/database_service.dart';
import '../services/permissions_helper.dart';
import '../components/home_screen/color_picker_section.dart';
import '../components/home_screen/image_preview_section.dart';
import '../components/home_screen/buttons_section.dart';
import '../components/home_screen/ad_banner_widget.dart';
import '../screens/paint.dart';
import '../screens/nearby_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? imagenSeleccionada;
  final TextEditingController _notaController = TextEditingController();
  final picker = ImagePicker();
  BannerAd? _bannerAd;

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
        const SnackBar(
          content: Text("✍️ Escribe algo para guardar tu recuerdo"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    await DatabaseService.insertEntrada(
      imagenSeleccionada?.path,
      _notaController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.bookmark_added, color: Colors.white),
            SizedBox(width: 10),
            Text("💾 Recuerdo guardado"),
          ],
        ),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
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
      // ☰ MENU HAMBURGUESA
      drawer: Drawer(
        child: Column(
          children: [
            // 🔝 HEADER DEL DRAWER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.book_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Diario',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 📋 OPCIONES
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // 🎨 ZONA DE DIBUJO
                  ListTile(
                    leading: Icon(
                      Icons.brush_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Zona de dibujo'),
                    subtitle: const Text('Expresa ideas visualmente'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PaintScreen()),
                      );
                    },
                  ),

                  const Divider(height: 16),

                  // 📡 CHAT BLUETOOTH
                  ListTile(
                    leading: Icon(
                      Icons.bluetooth_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Chat por Bluetooth'),
                    subtitle: const Text('Conecta sin internet'),
                    onTap: () async {
                      Navigator.pop(context);

                      final permitido =
                          await PermissionsHelper.checkAndRequest(context);

                      if (!permitido || !context.mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NearbyChatScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 🔚 FOOTER SUTIL
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Versión 1.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
              ),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        title: const Text("¿Cómo te sientes hoy?"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Ver recordatorios',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => RemindersScreen()),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ColorPickerSection(),
            const SizedBox(height: 30),

            ButtonsSection(
              onSeleccionarImagen: seleccionarImagen,
              onGuardar: guardarEntrada,
            ),

            const SizedBox(height: 10),
            ImagePreviewSection(imagen: imagenSeleccionada),

            const SizedBox(height: 24),

            TextField(
              controller: _notaController,
              maxLines: 6,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                labelText: 'Tu pensamiento',
                hintText: 'Escribe lo que pasó hoy...',
                contentPadding: const EdgeInsets.all(18),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: guardarEntrada,
                icon: const Icon(Icons.save),
                label: const Text(
                  "Guardar en diario",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
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
