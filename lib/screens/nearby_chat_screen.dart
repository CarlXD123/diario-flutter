import 'package:flutter/material.dart';
import '../services/nearby_service.dart';

class NearbyChatScreen extends StatefulWidget {
  const NearbyChatScreen({Key? key}) : super(key: key);

  @override
  State<NearbyChatScreen> createState() => _NearbyChatScreenState();
}

class _NearbyChatScreenState extends State<NearbyChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();

    NearbyService.onMessage((msg) {
      setState(() {
        _messages.add("📥 $msg");
      });
    });
  }

  void _startAdvertising() async {
    await NearbyService.advertise();
    _addSystem("📡 Preparando conexión...");
  }

  void _startDiscovery() async {
    await NearbyService.discover();
    _addSystem("🔍 Preparando búsqueda...");
  }

  void _send() async {
    if (_controller.text.trim().isEmpty) return;
    final msg = _controller.text.trim();
    await NearbyService.send(msg);
    setState(() {
      _messages.add("📤 Yo: $msg");
      _controller.clear();
    });
  }

  void _addSystem(String text) {
    setState(() {
      _messages.add("⚙️ $text");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.wifi_tethering),
            onPressed: _startAdvertising,
            tooltip: "Advertise",
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startDiscovery,
            tooltip: "Discover",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(_messages[i]),
              ),
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Escribe un mensaje...",
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _send,
              )
            ],
          ),
        ],
      ),
    );
  }
}
