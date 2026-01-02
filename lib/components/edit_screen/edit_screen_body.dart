import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/database_service.dart';
import 'ad_helper.dart';
import 'pdf_generator.dart';
import 'pin_dialogs.dart';
import 'emoji_preview.dart';

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

  void _generarPDF() async {
    final file = await PDFGenerator.generate(
      widget.entrada,
      _contenidoController.text,
    );

    if (!mounted) return;

    await OpenFilex.open(file.path);
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
                                  AdHelper.loadRewardedAd(onAdLoaded: (ad) {
                                    _rewardedAd = ad;
                                    _isAdReady = true;
                                    setState(() {});
                                  }, onAdFailed: () {
                                    _isAdReady = false;
                                    setState(() {});
                                  });
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
