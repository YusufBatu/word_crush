// ============================================================
// features/game/game_provider.dart
// ============================================================
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/cell.dart';
import '../../core/models/game_session.dart';
import '../../core/models/score_record.dart';
import '../../core/services/dictionary_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils/grid_generator.dart';
import '../../core/utils/score_calculator.dart';

enum GameStatus { idle, playing, wordValid, wordInvalid, gameOver }

enum JokerType { fish, wheel, lollipop, swap, shuffle, party }

class JokerItem {
  final JokerType type;
  final String name;
  final String emoji;
  final int cost;
  final String description;
  int count;

  JokerItem({
    required this.type,
    required this.name,
    required this.emoji,
    required this.cost,
    required this.description,
    this.count = 0,
  });
}

class GameProvider extends ChangeNotifier {
  final Random _rng = Random();

  GameSession? _session;
  List<Cell> _selectedCells = [];
  GameStatus _status = GameStatus.idle;
  int _availableWordCount = 0;
  List<String> _availableWords = [];
  String _lastWord = '';
  int _lastScore = 0;
  bool _isProcessing = false;
  JokerType? _activeJoker;
  Cell? _jokerFirstCell;
  List<String> _currentComboWords = [];

  final List<JokerItem> jokers = [
    JokerItem(type: JokerType.fish,     name: 'Balık',              emoji: '🐟', cost: 100,  description: 'Rastgele 5 harf patlat'),
    JokerItem(type: JokerType.wheel,    name: 'Tekerlek',           emoji: '🎡', cost: 200,  description: 'Hücrenin satır+sütununu temizle'),
    JokerItem(type: JokerType.lollipop, name: 'Lolipop Kırıcı',    emoji: '🍭', cost: 75,   description: 'Tek hücreyi sil'),
    JokerItem(type: JokerType.swap,     name: 'Serbest Değiştirme', emoji: '🔄', cost: 125,  description: 'İki komşu harfi yer değiştir'),
    JokerItem(type: JokerType.shuffle,  name: 'Harf Karıştırma',    emoji: '🃏', cost: 300,  description: "Grid'deki harfleri karıştır"),
    JokerItem(type: JokerType.party,    name: 'Parti Güçlendiricisi',emoji: '🎉', cost: 400, description: 'Tüm grid sıfırla'),
  ];

  GameProvider() {
    _initJokers();
  }

  Future<void> _initJokers() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'Oyuncu';
    for (final j in jokers) {
      j.count = prefs.getInt('joker_${j.type.name}_$username') ?? 0;
    }
    notifyListeners();
  }

  Future<void> _saveJokerCount(JokerItem joker) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'Oyuncu';
    await prefs.setInt('joker_${joker.type.name}_$username', joker.count);
  }

  // ── Getters ────────────────────────────────────────────────
  GameSession? get session => _session;
  List<Cell> get selectedCells => _selectedCells;
  GameStatus get status => _status;
  int get availableWordCount => _availableWordCount;
  List<String> get availableWords => _availableWords;
  String get lastWord => _lastWord;
  int get lastScore => _lastScore;
  bool get isProcessing => _isProcessing;
  JokerType? get activeJoker => _activeJoker;
  Cell? get jokerFirstCell => _jokerFirstCell;
  List<String> get currentComboWords => _currentComboWords;

  String get selectedWord => _selectedCells.map((c) => c.letter).join();

  bool get isWordValid =>
      selectedWord.length >= 3 && DictionaryService.isValid(selectedWord);

  // ── Game Init ──────────────────────────────────────────────
  Future<void> startGame(int gridSize, int moves) async {
    _isProcessing = true;
    notifyListeners();

    final payload = {
      'size': gridSize,
      'words': DictionaryService.allWords,
      'prefixes': DictionaryService.allPrefixes,
    };
    final grid = await compute(_generateGridIsolated, payload);

    _session = GameSession(
      gridSize: gridSize,
      remainingMoves: moves,
      grid: grid,
    );
    _selectedCells = [];
    _status = GameStatus.playing;
    _activeJoker = null;
    _jokerFirstCell = null;
    _currentComboWords = [];

    _updateWordCount();

    _isProcessing = false;
    notifyListeners();
  }

  static List<List<Cell>> _generateGridIsolated(Map<String, dynamic> payload) {
    final size = payload['size'] as int;
    final words = payload['words'] as Set<String>;
    final prefixes = payload['prefixes'] as Set<String>;
    DictionaryService.inject(words, prefixes);
    return GridGenerator.generate(size);
  }

  // ── Selection ──────────────────────────────────────────────
  void startSelection(Cell cell) {
    if (_session == null || _status == GameStatus.gameOver) return;
    if (_activeJoker != null) {
      _handleJokerTap(cell);
      return;
    }
    _selectedCells = [cell];
    _currentComboWords = [];
    notifyListeners();
  }

  void updateSelection(Cell cell) {
    if (_session == null || _status == GameStatus.gameOver) return;
    if (_activeJoker != null) return;
    if (_selectedCells.contains(cell)) return;
    if (_selectedCells.isEmpty) {
      _selectedCells = [cell];
    } else if (_isNeighbor(cell, _selectedCells.last)) {
      _selectedCells.add(cell);
    }
    notifyListeners();
  }

  Future<void> submitWord() async {
    if (_session == null || _isProcessing) return;
    if (_activeJoker != null) return;

    final session = _session!;
    session.remainingMoves--;

    final word = selectedWord;

    if (word.length >= 3 && DictionaryService.isValid(word)) {
      final comboData = ScoreCalculator.calculateCombo(word);
      final score = comboData['score'] as int;
      final count = comboData['count'] as int;
      final subWords = comboData['subWords'] as List<String>;

      final gold = ScoreCalculator.goldForWord(word);
      session.currentScore += score;
      session.goldEarned += gold;
      session.foundWords.add(word);
      session.comboCount = count;
      _currentComboWords = subWords;
      _lastWord = word;
      _lastScore = score;
      _status = GameStatus.wordValid;

      print('--- COMBO AKTİF! ($count x Combo) ---');
      print('Alt Kelimeler: $subWords');
      print('Kazanılan Puan: $score');
      print('------------------------------------');

      // ─── POWER CELL ACTIVATION ─────────────────────────────
      // Collect all cells to remove (Selected + Power Effects)
      final Set<Cell> totalToRemove = Set.from(_selectedCells);
      for (final cell in _selectedCells) {
        if (cell.isPower) {
          totalToRemove.addAll(getPowerEffectCells(cell));
        }
      }
      // ────────────────────────────────────────────────────────

      final powerCell = _createPowerCell(word.length, _selectedCells.last);
      
      _selectedCells = [];
      notifyListeners();

      await _removeCellsAndDrop(totalToRemove.toList(), powerCell);
      _updateWordCount();
    } else {
      _status = GameStatus.wordInvalid;
      _selectedCells = [];
      notifyListeners();
    }

    if (session.remainingMoves <= 0) {
      _status = GameStatus.gameOver;
      notifyListeners();
    }
  }

  bool _isNeighbor(Cell a, Cell b) {
    return (a.row - b.row).abs() <= 1 &&
        (a.col - b.col).abs() <= 1 &&
        !(a.row == b.row && a.col == b.col);
  }

  // ── Power Cells ────────────────────────────────────────────
  Cell? _createPowerCell(int wordLength, Cell lastCell) {
    CellType? type;
    if (wordLength == 4)      type = CellType.rowClear;
    else if (wordLength == 5) type = CellType.areaClear;
    else if (wordLength == 6) type = CellType.colClear;
    else if (wordLength >= 7) type = CellType.mega;
    if (type == null) return null;
    return Cell(
      letter: GridGenerator.generateLetter(),
      row: lastCell.row,
      col: lastCell.col,
      type: type,
    );
  }

  List<Cell> getPowerEffectCells(Cell cell) {
    if (!cell.isPower) return [];
    final session = _session!;
    final grid = session.grid;
    final size = session.gridSize;
    final List<Cell> toRemove = [];

    switch (cell.type) {
      case CellType.rowClear:
        for (int c = 0; c < size; c++) toRemove.add(grid[cell.row][c]);
        break;
      case CellType.colClear:
        for (int r = 0; r < size; r++) toRemove.add(grid[r][cell.col]);
        break;
      case CellType.areaClear:
        for (int dr = -1; dr <= 1; dr++) {
          for (int dc = -1; dc <= 1; dc++) {
            final nr = cell.row + dr; final nc = cell.col + dc;
            if (nr >= 0 && nr < size && nc >= 0 && nc < size) toRemove.add(grid[nr][nc]);
          }
        }
        break;
      case CellType.mega:
        for (int dr = -2; dr <= 2; dr++) {
          for (int dc = -2; dc <= 2; dc++) {
            final nr = cell.row + dr; final nc = cell.col + dc;
            if (nr >= 0 && nr < size && nc >= 0 && nc < size) toRemove.add(grid[nr][nc]);
          }
        }
        break;
      case CellType.normal:
        break;
    }
    return toRemove;
  }

  // ── Drop Mechanic ──────────────────────────────────────────
  Future<void> _removeCellsAndDrop(List<Cell> removed, Cell? powerReplacement) async {
    final session = _session!;
    final grid = session.grid;
    final size = session.gridSize;

    // 1. Show Explosion Effect
    for (final c in removed) {
      grid[c.row][c.col].isExploding = true;
    }
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));

    // 2. Perform actual removal
    final removedPositions = <String>{
      for (final c in removed) '${c.row},${c.col}'
    };

    for (int col = 0; col < size; col++) {
      final List<Cell> colRemaining = [];
      for (int row = size - 1; row >= 0; row--) {
        if (!removedPositions.contains('$row,$col')) {
          colRemaining.add(grid[row][col]);
        }
      }

      // Normal column drop logic (Standard Gravity)
      int writeRow = size - 1;
      for (final cell in colRemaining) {
        grid[writeRow][col] = cell.copyWith(row: writeRow, col: col, isExploding: false);
        writeRow--;
      }
      while (writeRow >= 0) {
        grid[writeRow][col] = Cell(
          letter: GridGenerator.generateLetter(),
          row: writeRow,
          col: col,
          isNew: true,
        );
        writeRow--;
      }
    }

    // 3. Post-Drop Power Application
    // Whatever cell landed at the last-letter's position becomes the special power
    if (powerReplacement != null) {
      final r = powerReplacement.row;
      final c = powerReplacement.col;
      grid[r][c] = grid[r][c].copyWith(type: powerReplacement.type);
    }

    notifyListeners();
  }

  // ── Word Count ─────────────────────────────────────────────
  Future<void> _updateWordCount() async {
    if (_session == null) return;
    final grid = _session!.grid;
    final payload = {
      'grid': grid,
      'words': DictionaryService.allWords,
      'prefixes': DictionaryService.allPrefixes,
    };
    final result = await compute(_countWordsIsolated, payload);
    _availableWordCount = result.length;
    _availableWords = result.toList();
    
    print('--- Izgaradaki Kelimeler (${result.length}) ---');
    print(_availableWords..sort());
    print('-------------------------------------------');
    notifyListeners();

    if (_availableWordCount == 0 && _status == GameStatus.playing) {
      _shuffleGrid();
    }
  }

  static Set<String> _countWordsIsolated(Map<String, dynamic> payload) {
    final grid = payload['grid'] as List<List<Cell>>;
    final words = payload['words'] as Set<String>;
    final prefixes = payload['prefixes'] as Set<String>;
    DictionaryService.inject(words, prefixes);
    return _countWords(grid);
  }

  static Set<String> _countWords(List<List<Cell>> grid) {
    final size = grid.length;
    final usedInGrid = <String>{};
    final resultWords = <String>{};

    void findWordsGreedily() {
      for (int r = 0; r < size; r++) {
        for (int c = 0; c < size; c++) {
          if (usedInGrid.contains('$r,$c')) continue;

          bool found = false;
          List<String> path = [];
          String tempWord = '';

          void dfs(int currR, int currC, String currentWord, List<String> currentPath) {
            if (currR < 0 || currR >= size || currC < 0 || currC >= size) return;
            
            final key = '$currR,$currC';
            if (usedInGrid.contains(key) || currentPath.contains(key)) return;

            final w = currentWord + grid[currR][currC].letter;
            if (!DictionaryService.isValidPrefix(w)) return;

            currentPath.add(key);

            // If it's a valid word and longer than what we found for this starting point so far
            if (w.length >= 3 && DictionaryService.isValid(w)) {
              if (w.length > path.length) {
                found = true;
                path = List.from(currentPath);
                tempWord = w;
              }
            }

            if (w.length < 8) {
              for (int dr = -1; dr <= 1; dr++) {
                for (int dc = -1; dc <= 1; dc++) {
                  if (dr == 0 && dc == 0) continue;
                  dfs(currR + dr, currC + dc, w, currentPath);
                }
              }
            }
            currentPath.removeLast();
          }

          dfs(r, c, '', []);
          if (found) {
            usedInGrid.addAll(path);
            resultWords.add(tempWord);
          }
        }
      }
    }

    findWordsGreedily();
    return resultWords;
  }

  // ── Joker System ───────────────────────────────────────────
  void activateJoker(JokerType type) {
    if (_session == null) return;
    final joker = jokers.firstWhere((j) => j.type == type);
    if (joker.count <= 0) return;

    if (type == JokerType.shuffle) {
      joker.count--;
      _saveJokerCount(joker);
      _shuffleGrid();
      notifyListeners();
    } else if (type == JokerType.party) {
      joker.count--;
      _saveJokerCount(joker);
      _resetGrid();
      notifyListeners();
    } else if (type == JokerType.fish) {
      joker.count--;
      _saveJokerCount(joker);
      _triggerFishEffect();
    } else {
      _activeJoker = type;
      _jokerFirstCell = null;
      notifyListeners();
    }
  }

  void cancelJoker() {
    _activeJoker = null;
    _jokerFirstCell = null;
    notifyListeners();
  }

  Future<void> _handleJokerTap(Cell cell) async {
    final session = _session!;
    final grid = session.grid;
    final size = session.gridSize;

    switch (_activeJoker) {


      case JokerType.wheel:
        final List<Cell> toRemove = [];
        for (int c = 0; c < size; c++) toRemove.add(grid[cell.row][c]);
        for (int r = 0; r < size; r++) {
          if (r != cell.row) toRemove.add(grid[r][cell.col]);
        }
        _finishJoker();
        await _removeCellsAndDrop(toRemove, null);
        break;

      case JokerType.lollipop:
        _finishJoker();
        await _removeCellsAndDrop([cell], null);
        break;

      case JokerType.swap:
        if (_jokerFirstCell == null) {
          _jokerFirstCell = cell;
          notifyListeners();
          return;
        } else {
          if (_isNeighbor(cell, _jokerFirstCell!)) {
            final a = _jokerFirstCell!;
            final aLetter = grid[a.row][a.col].letter;
            final aType = grid[a.row][a.col].type;
            grid[a.row][a.col] = grid[a.row][a.col].copyWith(
              letter: grid[cell.row][cell.col].letter,
              type: grid[cell.row][cell.col].type,
            );
            grid[cell.row][cell.col] = grid[cell.row][cell.col].copyWith(
              letter: aLetter,
              type: aType,
            );
          }
          _finishJoker();
        }
        break;

      default:
        _activeJoker = null;
    }

    notifyListeners();
  }

  Future<void> _triggerFishEffect() async {
    final session = _session!;
    final grid = session.grid;
    final size = session.gridSize;
    final positions = <Cell>[];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) positions.add(grid[r][c]);
    }
    positions.shuffle(_rng);
    final toRemove = positions.take(5).toList();
    await _removeCellsAndDrop(toRemove, null);
    _updateWordCount();
  }

  void _finishJoker() {
    final j = jokers.firstWhere((j) => j.type == _activeJoker);
    j.count--;
    _saveJokerCount(j);
    _activeJoker = null;
    _jokerFirstCell = null;
    _updateWordCount();
  }

  void _shuffleGrid() {
    final session = _session!;
    final size = session.gridSize;
    final letters = <String>[];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) letters.add(session.grid[r][c].letter);
    }
    letters.shuffle(_rng);
    int idx = 0;
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        session.grid[r][c] = session.grid[r][c].copyWith(letter: letters[idx++]);
      }
    }
    _updateWordCount();
  }

  void _resetGrid() {
    final session = _session!;
    session.grid = GridGenerator.generate(session.gridSize);
    _updateWordCount();
  }

  // ── Market ────────────────────────────────────────────────
  Future<bool> buyJoker(JokerType type) async {
    final joker = jokers.firstWhere((j) => j.type == type);
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'Oyuncu';
    final goldKey = 'gold_$username';
    final currentGold = prefs.getInt(goldKey) ?? 9999;
    
    if (currentGold < joker.cost) return false;
    await prefs.setInt(goldKey, currentGold - joker.cost);
    joker.count++;
    await _saveJokerCount(joker);
    notifyListeners();
    return true;
  }

  // ── Save Score ────────────────────────────────────────────
  Future<void> saveScore() async {
    final session = _session;
    if (session == null) return;
    
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'Oyuncu';
    
    final gameNum = await StorageService.getNextGameNumber(username);
    final record = ScoreRecord(
      gameNumber: gameNum,
      date: DateTime.now(),
      gridSize: session.gridSize,
      totalScore: session.currentScore,
      wordCount: session.foundWords.length,
      longestWord: session.longestWord,
      durationSeconds: session.durationSeconds,
      username: username,
    );
    await StorageService.saveScore(record);

    final goldKey = 'gold_$username';
    final existingGold = prefs.getInt(goldKey) ?? 9999;
    await prefs.setInt(goldKey, existingGold + session.goldEarned);
  }

  void resetStatus() {
    if (_status != GameStatus.gameOver) {
      _status = GameStatus.playing;
      notifyListeners();
    }
  }
}
