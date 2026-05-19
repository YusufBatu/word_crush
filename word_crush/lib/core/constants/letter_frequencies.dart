// ============================================================
// core/constants/letter_frequencies.dart
// ============================================================
const Map<String, int> letterWeights = {
  'A': 12, 'E': 11, 'İ': 10, 'L': 10, 'R': 9, 'N': 9,
  'K': 7,  'M': 7,  'T': 7,  'S': 7,  'Y': 6, 'D': 6,
  'B': 4,  'C': 4,  'Ç': 4,  'G': 4,  'H': 4, 'I': 4,
  'O': 4,  'Ö': 3,  'P': 3,  'Ş': 3,  'U': 3, 'Ü': 3,
  'Z': 2,  'F': 2,  'V': 2,  'Ğ': 1,  'J': 1,
};

/// Generates a weighted random letter based on Turkish letter frequencies.
String weightedRandomLetter() {
  final total = letterWeights.values.fold(0, (a, b) => a + b);
  // ignore: avoid_dynamic_calls
  var rand = (DateTime.now().microsecondsSinceEpoch % total);
  for (final entry in letterWeights.entries) {
    rand -= entry.value;
    if (rand < 0) return entry.key;
  }
  return 'A';
}
