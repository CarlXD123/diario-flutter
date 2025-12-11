import 'package:flutter/material.dart';
import '../components/edit_screen/edit_screen_body.dart';

class EditScreen extends StatelessWidget {
  final Map<String, dynamic> entrada;

  const EditScreen({super.key, required this.entrada});

  @override
  Widget build(BuildContext context) {
    return EditScreenBody(entrada: entrada);
  }
}
