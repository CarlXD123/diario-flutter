import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = FlutterSecureStorage();
  final _keyName = 'db_key';

  Future<void> saveKey(String key) async {
    await _storage.write(key: _keyName, value: key);
  }

  Future<String?> getKey() async {
    return await _storage.read(key: _keyName);
  }

  Future<bool> hasKey() async {
    return (await getKey()) != null;
  }

   // ✅ Agregar este método
  Future<void> deleteKey() async {
    await _storage.delete(key: _keyName);
  }
}
