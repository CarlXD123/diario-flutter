import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothChatScreen extends StatefulWidget {
  @override
  _BluetoothChatScreenState createState() => _BluetoothChatScreenState();
}

class _BluetoothChatScreenState extends State<BluetoothChatScreen> {
  List<BluetoothDevice> dispositivos = [];
  BluetoothConnection? _connection;
  BluetoothDevice? _selectedDevice;
  bool isConnected = false;

  TextEditingController _messageController = TextEditingController();
  List<String> mensajes = [];

  @override
  void initState() {
    super.initState();
    verificarPermisosYObtenerDispositivos();
  }

  Future<void> verificarPermisosYObtenerDispositivos() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse,
    ].request();

    var pairedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();

    setState(() {
      dispositivos = pairedDevices;
    });
  }

  void conectar(BluetoothDevice device) async {
    try {
      final connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        _connection = connection;
        _selectedDevice = device;
        isConnected = true;
      });

      _connection!.input!.listen((data) {
        final msg = utf8.decode(data);
        setState(() {
          mensajes.add("📥 ${device.name}: $msg");
        });
      });
    } catch (e) {
      print("❌ Error al conectar: $e");
    }
  }

  void enviarMensaje() {
    if (_connection != null && _messageController.text.trim().isNotEmpty) {
      final mensaje = _messageController.text.trim();
      _connection!.output.add(utf8.encode(mensaje + "\n"));
      setState(() {
        mensajes.add("📤 Yo: $mensaje");
        _messageController.clear();
      });
    }
  }

  @override
  void dispose() {
    _connection?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🟦 Chat Bluetooth"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: verificarPermisosYObtenerDispositivos,
          ),
        ],
      ),
      body: isConnected
          ? Column(
              children: [
                Container(
                  color: Colors.grey[300],
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  child: Text(
                    "Conectado a: ${_selectedDevice?.name ?? "Desconocido"}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: mensajes.length,
                    itemBuilder: (context, index) {
                      return ListTile(title: Text(mensajes[index]));
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Escribe un mensaje...",
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: enviarMensaje,
                    )
                  ],
                )
              ],
            )
          : ListView.builder(
              itemCount: dispositivos.length,
              itemBuilder: (context, index) {
                final d = dispositivos[index];
                return ListTile(
                  leading: Icon(Icons.bluetooth),
                  title: Text(d.name ?? "Dispositivo"),
                  subtitle: Text(d.address),
                  onTap: () => conectar(d),
                );
              },
            ),
    );
  }
}
