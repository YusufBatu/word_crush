// ============================================================
// core/services/storage_service.dart
// ============================================================
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/score_record.dart';

class StorageService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dbPath, 'word_crush.db'),
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE score_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            game_number INTEGER NOT NULL,
            date TEXT NOT NULL,
            grid_size INTEGER NOT NULL,
            score INTEGER NOT NULL,
            word_count INTEGER NOT NULL,
            longest_word TEXT NOT NULL,
            duration_secs INTEGER NOT NULL,
            username TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE score_records ADD COLUMN username TEXT NOT NULL DEFAULT "Bilinmeyen"');
        }
      },
    );
    return _db!;
  }

  static Future<void> saveScore(ScoreRecord record) async {
    final db = await database;
    await db.insert('score_records', record.toMap());
  }

  static Future<List<ScoreRecord>> getAllScores(String username) async {
    final db = await database;
    final maps = await db.query(
      'score_records',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'date DESC',
    );
    return maps.map(ScoreRecord.fromMap).toList();
  }

  static Future<int> getNextGameNumber(String username) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT MAX(game_number) as max_gn FROM score_records WHERE username = ?', [username]);
    final max = result.first['max_gn'];
    return (max == null ? 0 : max as int) + 1;
  }

  static Future<Map<String, dynamic>> getStats(String username) async {
    final db = await database;
    
    // Get basic stats
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as total_games,
        MAX(score) as best_score,
        AVG(score) as avg_score,
        SUM(word_count) as total_words,
        SUM(duration_secs) as total_duration
      FROM score_records
      WHERE username = ?
    ''', [username]);

    // Get true longest word (by length)
    final longestResult = await db.rawQuery('''
      SELECT longest_word 
      FROM score_records 
      WHERE username = ? 
      ORDER BY LENGTH(longest_word) DESC 
      LIMIT 1
    ''', [username]);

    final stats = Map<String, dynamic>.from(result.first);
    stats['longest_word'] = longestResult.isNotEmpty ? longestResult.first['longest_word'] : '-';
    
    return stats;
  }
}
