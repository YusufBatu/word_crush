// ============================================================
// core/utils/word_finder.dart
// ============================================================
import '../models/cell.dart';
import '../services/dictionary_service.dart';

class WordFinder {
  /// Finds all valid words (3+ letters) reachable by adjacent dragging in the grid.
  /// Returns word → list of cells paths.
  static Map<String, List<Cell>> findAvailableWords(List<List<Cell>> grid) {
    final size = grid.length;
    final Map<String, List<Cell>> results = {};

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        _dfs(grid, r, c, [], {}, results, size);
      }
    }

    return results;
  }

  /// Returns just the count of available words (faster, avoids storing paths).
  static int countAvailableWords(List<List<Cell>> grid) {
    return findAvailableWords(grid).length;
  }

  static void _dfs(
    List<List<Cell>> grid,
    int row,
    int col,
    List<Cell> path,
    Set<String> visited,
    Map<String, List<Cell>> results,
    int size,
  ) {
    if (row < 0 || row >= size || col < 0 || col >= size) return;
    final key = '$row,$col';
    if (visited.contains(key)) return;

    final cell = grid[row][col];
    path.add(cell);
    visited.add(key);

    final word = path.map((c) => c.letter).join();

    if (word.length >= 3 && DictionaryService.isValid(word)) {
      results.putIfAbsent(word, () => List.from(path));
    }

    // Limit depth to 10 for performance
    if (word.length < 10) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          _dfs(grid, row + dr, col + dc, path, visited, results, size);
        }
      }
    }

    path.removeLast();
    visited.remove(key);
  }
}
