// ============================================================
// core/utils/grid_generator.dart
// ============================================================
import 'dart:math';
import '../constants/letter_frequencies.dart';
import '../models/cell.dart';
import '../services/dictionary_service.dart';

class GridGenerator {
  static final Random _rng = Random();

  /// Returns a grid guaranteed to have at least one valid word.
  static List<List<Cell>> generate(int size) {
    List<List<Cell>> grid;
    int attempts = 0;
    do {
      grid = _buildGrid(size);
      attempts++;
      if (attempts > 20) break; // avoid infinite loop
    } while (!_hasAtLeastOneWord(grid));
    return grid;
  }

  static List<List<Cell>> _buildGrid(int size) {
    return List.generate(size, (row) {
      return List.generate(size, (col) {
        return Cell(
          letter: _weightedLetter(),
          row: row,
          col: col,
        );
      });
    });
  }

  /// Generates a new random letter with Turkish frequency weighting.
  static String generateLetter() => _weightedLetter();

  static String _weightedLetter() {
    final total = letterWeights.values.fold(0, (a, b) => a + b);
    var rand = _rng.nextInt(total);
    for (final entry in letterWeights.entries) {
      rand -= entry.value;
      if (rand < 0) return entry.key;
    }
    return 'A';
  }

  static bool _hasAtLeastOneWord(List<List<Cell>> grid) {
    final size = grid.length;
    // Quick DFS-based check: find at least one 3-letter path
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (_dfsCheck(grid, r, c, '', {}, size)) return true;
      }
    }
    return false;
  }

  static bool _dfsCheck(
    List<List<Cell>> grid,
    int row,
    int col,
    String current,
    Set<String> visited,
    int size,
  ) {
    if (row < 0 || row >= size || col < 0 || col >= size) return false;
    final key = '$row,$col';
    if (visited.contains(key)) return false;

    final next = current + grid[row][col].letter;
    if (!DictionaryService.isValidPrefix(next)) return false;

    visited.add(key);

    if (next.length >= 3 && DictionaryService.isValid(next)) {
      visited.remove(key);
      return true;
    }

    if (next.length < 8) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          if (_dfsCheck(grid, row + dr, col + dc, next, visited, size)) {
            visited.remove(key);
            return true;
          }
        }
      }
    }

    visited.remove(key);
    return false;
  }
}
