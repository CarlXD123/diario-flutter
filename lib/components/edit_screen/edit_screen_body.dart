import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../../services/database_service.dart';
import 'ad_helper.dart';
import 'pdf_generator.dart';
import 'pin_dialogs.dart';
import 'emoji_preview.dart';

/// 🔹 Función top-level para generar PDF en isolate
Future<String> generatePdfInBackground(Map<String, dynamic> params) async {
  final entrada = Map<String, dynamic>.from(params['entrada']); // asegurar serializable
  final contenido = params['contenido'] as String;

  // Aquí podrías optimizar imágenes si quieres
  // ej: entrada['emoji'] = await resizeImage(File(entrada['emoji']).readAsBytes(), 128, 128);

  final file = await PDFGenerator.generate(entrada, contenido);
  return file.path;
}

class EditScreenBody extends StatefulWidget {
  final Map<String, dynamic> entrada;
  const EditScreenBody({super.key, required this.entrada});

  @override
  State<EditScreenBody> createState() => _EditScreenBodyState();
}

class _EditScreenBodyState extends State<EditScreenBody> {
  late TextEditingController _contenidoController;
  RewardedAd? _rewardedAd;
  bool _isAdReady = false;

  @override
  void initState() {
    super.initState();
    _contenidoController = TextEditingController(text: widget.entrada['nota']);
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    AdHelper.loadRewardedAd(onAdLoaded: (ad) {
      _rewardedAd = ad;
      _isAdReady = true;
      setState(() {});
    }, onAdFailed: () {
      _isAdReady = false;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _contenidoController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    final nuevoContenido = _contenidoController.text.trim();
    if (nuevoContenido.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✍️ El contenido no puede estar vacío")),
      );
      return;
    }
    await DatabaseService.updateEntrada(widget.entrada['id'], nuevoContenido);
    Navigator.pop(context, true);
  }

  Future<void> _generarPDF() async {
    // Mostrar loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Llamada directa, SIN compute
      final file = await PDFGenerator.generate(widget.entrada, _contenidoController.text);

      if (!mounted) return;

      // Pequeño delay para Android
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pop(context); // cerrar loader
      await OpenFilex.open(file.path);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al generar PDF: $e")),
      );
    }
  }

  void _protegerEntrada() {
    PinDialogs.protegerEntrada(context, widget.entrada);
  }

  void _quitarProteccion() {
    PinDialogs.quitarProteccion(context, widget.entrada);
  }

  @override
  Widget build(BuildContext context) {
    final imagenPath = widget.entrada['emoji'];
    final tienePin = widget.entrada['pin'] != null;
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Recuerdo"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    EmojiPreview(path: imagenPath),
                    TextField(
                      controller: _contenidoController,
                      decoration: const InputDecoration(
                        labelText: "Contenido",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _boton("Guardar Cambios", Icons.save, _guardarCambios, Colors.teal, isWide),
                        _boton("Proteger", Icons.lock, _protegerEntrada, Colors.redAccent, isWide),
                        if (tienePin)
                          _boton("Quitar Protección", Icons.lock_open, _quitarProteccion, Colors.grey.shade700, isWide),
                        _boton(
                          _isAdReady ? "Exportar como PDF (ver anuncio)" : "Cargando anuncio...",
                          Icons.picture_as_pdf,
                          _isAdReady
                              ? () {
                                  _rewardedAd?.show(
                                    onUserEarnedReward: (ad, reward) => _generarPDF(),
                                  );
                                  _loadRewardedAd();
                                }
                              : null,
                          Colors.deepPurple,
                          isWide,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _boton(String text, IconData icon, VoidCallback? onPressed, Color color, bool isWide) {
    return SizedBox(
      width: isWide ? 270 : double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
