// ============================================================
// core/utils/score_calculator.dart
// ============================================================
import '../constants/letter_scores.dart';
import '../services/dictionary_service.dart';

class ScoreCalculator {
  static int letterScore(String letter) =>
      letterScores[letter.toUpperCase()] ?? 1;

  static int wordScore(String word) {
    return word
        .toUpperCase()
        .split('')
        .fold(0, (sum, ch) => sum + letterScore(ch));
  }

  /// Calculates total score and count including combo (unique valid sub-words).
  static Map<String, dynamic> calculateCombo(String word) {
    final upper = word.toUpperCase();
    final uniqueValidSubWords = <String>{upper}; // Include main word
    
    // Contiguous substrings of length 3..word.length-1
    for (int len = 3; len < upper.length; len++) {
      for (int i = 0; i <= upper.length - len; i++) {
        final sub = upper.substring(i, i + len);
        if (DictionaryService.isValid(sub)) {
          uniqueValidSubWords.add(sub);
        }
      }
    }

    int totalScore = 0;
    for (final sub in uniqueValidSubWords) {
      totalScore += wordScore(sub);
    }

    return {
      'score': totalScore,
      'count': uniqueValidSubWords.length,
      'subWords': uniqueValidSubWords.toList(),
    };
  }

  /// Gold earned for a word (1 per letter, bonus for long words)
  static int goldForWord(String word) {
    int gold = word.length;
    if (word.length >= 5) gold += 5;
    if (word.length >= 7) gold += 10;
    return gold;
  }
}
