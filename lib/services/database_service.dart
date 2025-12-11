import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';

import 'secure_storage_service.dart';

class DatabaseService {
  static Database? _database;
  static final _dbName = 'diario_emociones.db';

  // Inicializar o abrir la base de datos
  static Future<Database> initDB() async {
    try {
      final path = join(await getDatabasesPath(), _dbName);
      final storage = SecureStorageService();

      String? key = await storage.getKey();
      if (key == null) {
        key = _generateSecureKey(32);
        await storage.saveKey(key);
      }

      _database = await openDatabase(
        path,
        password: key,
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE entradas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              fecha TEXT,
              emoji TEXT,
              nota TEXT,
              pin TEXT
            )
          ''');

          await db.execute('CREATE INDEX idx_fecha ON entradas(fecha)');
          await db.execute('CREATE INDEX idx_pin ON entradas(pin)');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (kDebugMode) {
            print('🛠 Migrando de $oldVersion a $newVersion');
          }

          final columnas = await db.rawQuery('PRAGMA table_info(entradas)');
          final existePin = columnas.any((col) => col['name'] == 'pin');
          if (!existePin) {
            await db.execute('ALTER TABLE entradas ADD COLUMN pin TEXT');
          }
        },
      );

      return _database!;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inicializando base de datos: $e');
      }
      rethrow;
    }
  }

  static Future<Database> db() async {
    if (_database != null) return _database!;
    return await initDB();
  }

  static Future<void> closeDB() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  static String _generateSecureKey(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()';
    final rand = Random.secure();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  static String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  static Future<void> insertEntrada(String emoji, String nota) async {
    if (emoji.isEmpty || nota.isEmpty) return;

    try {
      final database = await db();
      await database.insert(
        'entradas',
        {
          'emoji': emoji,
          'nota': nota,
          'fecha': DateTime.now().toIso8601String(),
          'pin': null,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al insertar entrada: $e');
      }
    }
  }

  static Future<List<Map<String, dynamic>>> getEntradas() async {
    try {
      final database = await db();
      return await database.query('entradas', orderBy: 'fecha DESC');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener entradas: $e');
      }
      return [];
    }
  }

  static Future<void> deleteEntrada(int id) async {
    try {
      final db = await DatabaseService.db();
      await db.delete('entradas', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al eliminar entrada: $e');
      }
    }
  }

  static Future<void> updateEntrada(int id, String contenido) async {
    if (contenido.isEmpty) return;

    try {
      final db = await DatabaseService.db();
      await db.update(
        'entradas',
        {'nota': contenido},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al actualizar entrada: $e');
      }
    }
  }

  static Future<void> protegerEntrada(int id, String pin) async {
    if (pin.isEmpty) return;

    try {
      final db = await DatabaseService.db();
      final hashedPin = _hashPin(pin);
      await db.update(
        'entradas',
        {'pin': hashedPin},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al proteger entrada: $e');
      }
    }
  }

  static Future<void> quitarPin(int id) async {
    try {
      final db = await DatabaseService.db();
      await db.update(
        'entradas',
        {'pin': null},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al quitar PIN: $e');
      }
    }
  }

  static Future<Map<String, dynamic>?> getEntradaPorId(int id) async {
    try {
      final db = await DatabaseService.db();
      final result = await db.query('entradas', where: 'id = ?', whereArgs: [id]);
      if (result.isNotEmpty) {
        return result.first;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error al obtener entrada por ID: $e');
      }
    }
    return null;
  }
}
