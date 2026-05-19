// ============================================================
// core/models/game_session.dart
// ============================================================
import 'cell.dart';

class GameSession {
  final int gridSize;        // 6, 8, or 10
  final int initialMoves;    // Store for restarts
  int remainingMoves;
  int currentScore;
  List<String> foundWords;
  final DateTime startTime;
  List<List<Cell>> grid;
  int comboCount;            // consecutive valid words
  int goldEarned;

  GameSession({
    required this.gridSize,
    required this.remainingMoves,
    required this.grid,
    this.currentScore = 0,
    List<String>? foundWords,
    DateTime? startTime,
    this.comboCount = 0,
    this.goldEarned = 0,
  })  : initialMoves = remainingMoves,
        foundWords = foundWords ?? [],
        startTime = startTime ?? DateTime.now();

  int get durationSeconds =>
      DateTime.now().difference(startTime).inSeconds;

  String get longestWord =>
      foundWords.isEmpty
          ? '-'
          : foundWords.reduce((a, b) => a.length >= b.length ? a : b);

  bool get isOver => remainingMoves <= 0;

  static int defaultMoves(int size) {
    if (size == 6) return 15;
    if (size == 8) return 20;
    return 25; // 10x10
  }
}
