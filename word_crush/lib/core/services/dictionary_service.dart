// ============================================================
// core/services/dictionary_service.dart
// ============================================================
import 'package:flutter/services.dart';

class DictionaryService {
  static final Set<String> _words = {};
  static final Set<String> _prefixes = {};
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    final data = await rootBundle.loadString('assets/words.txt');
    for (final line in data.split('\n')) {
      final w = line.trim().toUpperCase();
      if (w.length >= 3) {
        _words.add(w);
        for (int i = 1; i <= w.length; i++) {
          _prefixes.add(w.substring(0, i));
        }
      }
    }
    _loaded = true;
  }

  static bool isValid(String word) {
    if (word.length < 3) return false;
    return _words.contains(word.toUpperCase());
  }

  static bool isValidPrefix(String prefix) {
    if (prefix.isEmpty) return true;
    return _prefixes.contains(prefix.toUpperCase());
  }

  static int wordCount() => _words.length;

  static Set<String> get allWords => Set.unmodifiable(_words);
  static Set<String> get allPrefixes => Set.unmodifiable(_prefixes);

  static void inject(Set<String> words, Set<String> prefixes) {
    _words.clear();
    _words.addAll(words);
    _prefixes.clear();
    _prefixes.addAll(prefixes);
    _loaded = true;
  }
}
