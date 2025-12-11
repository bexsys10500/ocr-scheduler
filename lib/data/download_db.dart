// lib/data/download_db.dart
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class DownloadDb {
  DownloadDb._internal();
  static final DownloadDb instance = DownloadDb._internal();

  Database? _db;

  Future<Database> _openDb() async {
    if (_db != null) return _db!;

    final dir = await getApplicationSupportDirectory();
    final dbPath = p.join(dir.path, 'downloads.sqlite3');

    await Directory(dir.path).create(recursive: true);

    final db = sqlite3.open(dbPath);

    db.execute('''
      CREATE TABLE IF NOT EXISTS downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_name TEXT NOT NULL,
        local_path TEXT NOT NULL,
        saved_at TEXT NOT NULL
      );
    ''');

    _db = db;
    return db;
  }

  /// log download ใหม่
  Future<void> insertDownload({
    required String fileName,
    required String localPath,
  }) async {
    final db = await _openDb();

    final now = DateTime.now().toUtc().toIso8601String();

    db.execute(
      'INSERT INTO downloads (file_name, local_path, saved_at) VALUES (?, ?, ?);',
      [fileName, localPath, now],
    );
  }

  /// ดึงข้อมูลดิบจาก DB (ใช้ Map แทน model เพื่อไม่ให้ชน type กับหน้าจออื่น)
  Future<List<Map<String, dynamic>>> getDownloadsRaw() async {
    final db = await _openDb();

    final ResultSet rs = db.select(
      'SELECT id, file_name, local_path, saved_at '
      'FROM downloads ORDER BY datetime(saved_at) DESC;',
    );

    return rs.map((row) {
      return {
        'id': row['id'] as int,
        'file_name': row['file_name'] as String,
        'local_path': row['local_path'] as String,
        'saved_at': row['saved_at'] as String,
      };
    }).toList();
  }

  Future<void> clearAll() async {
    final db = await _openDb();
    db.execute('DELETE FROM downloads;');
  }

  void close() {
    _db?.dispose();
    _db = null;
  }
}
