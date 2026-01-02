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
    final path = join(await getDatabasesPath(), _dbName);
    final storage = SecureStorageService();

    final dbExists = await databaseExists(path);
    String? key = await storage.getKey();

    // 🚨 CASO CRÍTICO: hay clave pero no hay DB → CLAVE HUÉRFANA
    if (key != null && !dbExists) {
      if (kDebugMode) {
        print('⚠️ Clave huérfana detectada. Reset seguro.');
      }
      await storage.deleteKey();
      key = null;
    }

    // Crear clave si no existe
    if (key == null) {
      key = _generateSecureKey(32);
      await storage.saveKey(key);
    }

    // Abrir o crear DB
    return await openDatabase(
      path,
      password: key,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Separar onCreate y onUpgrade para limpieza
  static Future<void> _onCreate(Database db, int version) async {
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

    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        scheduled_at INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_reminder_date ON reminders(scheduled_at)');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    final columnas = await db.rawQuery('PRAGMA table_info(entradas)');
    final existePin = columnas.any((col) => col['name'] == 'pin');
    if (!existePin) await db.execute('ALTER TABLE entradas ADD COLUMN pin TEXT');

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='reminders'"
    );
    if (tables.isEmpty) {
      await db.execute('''
        CREATE TABLE reminders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          text TEXT NOT NULL,
          scheduled_at INTEGER NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX idx_reminder_date ON reminders(scheduled_at)');
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

  static Future<void> insertEntrada(String? emoji, String nota) async {
    if (nota.trim().isEmpty) return;
    
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

  // ======================
  // RECORDATORIOS
  // ======================

  static Future<int> insertReminder(
    String text,
    DateTime dateTime,
  ) async {
    final database = await db();
    return await database.insert(
      'reminders',
      {
        'text': text,
        'scheduled_at': dateTime.millisecondsSinceEpoch,
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getReminders() async {
    final database = await db();
    return await database.query(
      'reminders',
      orderBy: 'scheduled_at ASC',
    );
  }

  static Future<void> deleteReminder(int id) async {
    final database = await db();
    await database.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
