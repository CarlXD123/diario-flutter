import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

import '../components/paint/drawn_line.dart';
import '../components/paint/drawn_text.dart';
import '../components/paint/paint_canvas.dart';
import '../components/paint/dock_button.dart';
import '../components/paint/color_selector.dart';

import '../services/ad_service.dart';
import '../utils/permission_utils.dart';

class PaintScreen extends StatefulWidget {
  @override
  _PaintScreenState createState() => _PaintScreenState();
}

class _PaintScreenState extends State<PaintScreen> {
  final GlobalKey _paintKey = GlobalKey();
  final ImagePicker _picker = ImagePicker();
  final AdService _adService = AdService();

  bool _canAddText = false;
  bool _canAddImage = false;
  bool _isPremiumUnlocked = false;

  bool _isAddingText = false;
  int? _selectedTextIndex;

  List<DrawnLine> _lines = [];
  List<DrawnText> _texts = [];

  Color _selectedColor = Colors.deepPurple;
  double _strokeWidth = 4.0;

  File? _backgroundImage;

  @override
  void initState() {
    super.initState();
    _adService.loadAd(() {}, () {});
    _checkIfPremiumUnlocked();
  }

  Future<void> _checkIfPremiumUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final textUnlocked = prefs.getBool('premium_text_unlocked') ?? false;
    final imageUnlocked = prefs.getBool('premium_image_unlocked') ?? false;

    setState(() {
      _canAddText = textUnlocked;
      _canAddImage = imageUnlocked;
    });
  }



  Future<void> _pickBackgroundImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _backgroundImage = File(pickedFile.path);
      });
    }
  }

  int? _getTappedTextIndex(Offset tapPosition) {
    for (int i = _texts.length - 1; i >= 0; i--) {
      final text = _texts[i];
      final textPainter = TextPainter(
        text: TextSpan(text: text.text, style: TextStyle(fontSize: text.fontSize)),
        textDirection: TextDirection.ltr,
      )..layout();

      final rect = Rect.fromLTWH(
        text.position.dx,
        text.position.dy,
        textPainter.width,
        textPainter.height,
      );

      if (rect.contains(tapPosition)) return i;
    }
    return null;
  }

  Future<void> _saveToGallery(Uint8List imageBytes) async {
    bool hasPermission = await requestStoragePermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Permiso denegado para guardar en la galería")),
      );
      return;
    }

    final result = await ImageGallerySaverPlus.saveImage(
      imageBytes,
      quality: 100,
      name: "dibujo_${DateTime.now().millisecondsSinceEpoch}",
    );

    final message = result['isSuccess'] == true
        ? "✅ Dibujo guardado en la galería"
        : "❌ Error al guardar la imagen";

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<Uint8List> _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
          _paintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      throw Exception("Error capturando imagen: $e");
    }
  }

  void _onPanStart(DragStartDetails details) {
    final box = _paintKey.currentContext!.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    final tappedIndex = _getTappedTextIndex(point);

    if (tappedIndex != null) {
      setState(() => _selectedTextIndex = tappedIndex);
      return;
    }

    if (_isAddingText) return;

    setState(() {
      _lines.add(DrawnLine(points: [point], color: _selectedColor, strokeWidth: _strokeWidth));
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final box = _paintKey.currentContext!.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);

    if (_selectedTextIndex != null) {
      setState(() {
        _texts[_selectedTextIndex!] = DrawnText(
          text: _texts[_selectedTextIndex!].text,
          position: point,
          color: _texts[_selectedTextIndex!].color,
          fontSize: _texts[_selectedTextIndex!].fontSize,
        );
      });
      return;
    }

    if (_isAddingText) return;

    setState(() {
      _lines.last.points!.add(point);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _selectedTextIndex = null;
  }

  void _onTapDown(TapDownDetails details) {
    if (!_isAddingText) return;
    final box = _paintKey.currentContext!.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    _showTextInputDialog(point);
  }

  void _showTextInputDialog(Offset position) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Agregar texto o emoji"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Escribe aquí..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _texts.add(DrawnText(
                    text: text,
                    position: position,
                    color: _selectedColor,
                    fontSize: 28,
                  ));
                });
              }
              _isAddingText = false;
              Navigator.pop(context);
            },
            child: Text("Agregar"),
          ),
        ],
      ),
    );
  }

  void _clearCanvas() => setState(() {
        _lines.clear();
        _texts.clear();
        _backgroundImage = null;
      });

  void _undoLast() => setState(() {
        if (_lines.isNotEmpty) {
          _lines.removeLast();
        } else if (_texts.isNotEmpty) {
          _texts.removeLast();
        }
      });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return Scaffold(
      backgroundColor: Color(0xFFF4F4F7),
      appBar: AppBar(
        title: Text("🖌️ Zona de pintar", style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: Column(
        children: [
          SizedBox(height: 12),
          ColorSelector(
            colors: colors,
            selectedColor: _selectedColor,
            onColorSelected: (color) => setState(() => _selectedColor = color),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.brush, color: Colors.grey[700]),
                Expanded(
                  child: Slider(
                    value: _strokeWidth,
                    min: 1.0,
                    max: 20.0,
                    divisions: 19,
                    label: _strokeWidth.toStringAsFixed(0),
                    onChanged: (value) => setState(() => _strokeWidth = value),
                    activeColor: _selectedColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RepaintBoundary(
              key: _paintKey,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8)],
                ),
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  onTapDown: _onTapDown,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_backgroundImage != null)
                          Image.file(_backgroundImage!, fit: BoxFit.cover),
                        CustomPaint(
                          painter: PaintCanvas(lines: _lines, texts: _texts),
                          size: Size.infinite,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            DockButton(icon: Icons.undo, label: "Deshacer", onTap: _undoLast),
            DockButton(icon: Icons.clear, label: "Limpiar", onTap: _clearCanvas),
            DockButton(
              icon: Icons.text_fields_rounded,
              label: _canAddText ? "Texto" : "Texto 🎁",
              onTap: () {
                if (_canAddText) {
                  setState(() => _isAddingText = true);
                } else {
                  _adService.showRewardedAd(
                    context: context,
                    featureKey: 'premium_text_unlocked',
                    onRewarded: () => setState(() {
                      _canAddText = true;
                      _isAddingText = true;
                    }),
                  );
                }
              },
              isActive: _isAddingText,
            ),

            DockButton( 
              icon: Icons.image,
              label: _canAddImage ? "Imagen" : "Imagen 🎁",
              onTap: () {
                if (_canAddImage) {
                  _pickBackgroundImage();
                } else {
                  _adService.showRewardedAd(
                    context: context,
                    featureKey: 'premium_image_unlocked',
                    onRewarded: () => setState(() {
                      _canAddImage = true;
                      _pickBackgroundImage();
                    }),
                  );
                }
              },
            ),

            DockButton(
              icon: Icons.save_alt_rounded,
              label: "Guardar",
              onTap: () async {
                try {
                  Uint8List imageBytes = await _capturePng();
                  await _saveToGallery(imageBytes);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ Error al guardar: $e")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
