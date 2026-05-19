// ============================================================
// core/models/score_record.dart
// ============================================================
class ScoreRecord {
  final int? id;
  final int gameNumber;
  final DateTime date;
  final int gridSize;
  final int totalScore;
  final int wordCount;
  final String longestWord;
  final int durationSeconds;
  final String username;

  ScoreRecord({
    this.id,
    required this.gameNumber,
    required this.date,
    required this.gridSize,
    required this.totalScore,
    required this.wordCount,
    required this.longestWord,
    required this.durationSeconds,
    required this.username,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'game_number': gameNumber,
        'date': date.toIso8601String(),
        'grid_size': gridSize,
        'score': totalScore,
        'word_count': wordCount,
        'longest_word': longestWord,
        'duration_secs': durationSeconds,
        'username': username,
      };

  factory ScoreRecord.fromMap(Map<String, dynamic> map) => ScoreRecord(
        id: map['id'] as int?,
        gameNumber: map['game_number'] as int,
        date: DateTime.parse(map['date'] as String),
        gridSize: map['grid_size'] as int,
        totalScore: map['score'] as int,
        wordCount: map['word_count'] as int,
        longestWord: map['longest_word'] as String,
        durationSeconds: map['duration_secs'] as int,
        username: map['username'] as String? ?? 'Bilinmeyen',
      );

  String get formattedDate {
    final d = date;
    return '${d.day.toString().padLeft(2,'0')}.'
        '${d.month.toString().padLeft(2,'0')}.'
        '${d.year}';
  }

  String get formattedDuration {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    if (m == 0) return '${s}sn';
    return '${m}dk ${s}sn';
  }
}
