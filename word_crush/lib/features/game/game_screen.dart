// ============================================================
// features/game/game_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/cell.dart';
import '../../widgets/cell_widget.dart';
import '../../widgets/joker_demo_widget.dart';
import '../../core/utils/score_calculator.dart';
import 'game_provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey _gridKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.surfaceLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, provider, child) {
              if (provider.isProcessing || provider.session == null) {
                return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.primaryStart),
                );
              }

              final session = provider.session!;
              final size = session.gridSize;

              // Handle game over overlay
              if (provider.status == GameStatus.gameOver) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _showGameOverDialog(context, provider);
                });
              }

              return Column(
                children: [
                  // ── AppBar ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: AppColors.textPrimary),
                          onPressed: () => _onWillPop(provider),
                        ),
                        _InfoChip(
                          icon: '🔄',
                          label: 'Hamle: ${session.remainingMoves}',
                          color: session.remainingMoves <= 5
                              ? AppColors.danger
                              : AppColors.primaryStart,
                        ),
                      ],
                    ),
                  ),

                  // ── Anlık Bilgi ────────────────────────────────
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Puan',
                              style: GoogleFonts.outfit(
                                  color: AppColors.textSecondary, fontSize: 14),
                            ),
                            Text(
                              '${session.currentScore}',
                              style: GoogleFonts.outfit(
                                color: AppColors.textGold,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () =>
                              _showAvailableWordsModal(context, provider),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Oluşturulabilir',
                                style: GoogleFonts.outfit(
                                    color: AppColors.textSecondary,
                                    fontSize: 14),
                              ),
                              Text(
                                '${provider.availableWordCount} kelime',
                                style: GoogleFonts.outfit(
                                  color: AppColors.success,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Seçili Kelime ──────────────────────────────
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Text(
                      provider.selectedWord.isEmpty
                          ? (provider.activeJoker != null
                              ? 'Joker için hedef seç...'
                              : '')
                          : provider.selectedWord,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                        color: provider.selectedWord.isEmpty
                            ? AppColors.textSecondary.withOpacity(0.5)
                            : provider.isWordValid
                                ? AppColors.success
                                : AppColors.danger,
                      ),
                    )
                        .animate(
                            target: provider.selectedWord.isNotEmpty ? 1 : 0)
                        .scale(duration: 150.ms),
                  ),

                  // Combo Indicator
                  Container(
                    constraints: const BoxConstraints(minHeight: 30),
                    child: provider.currentComboWords.length > 1
                        ? Column(
                            children: [
                              Text(
                                '${provider.currentComboWords.length}x COMBO! 🔥',
                                style: GoogleFonts.outfit(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ).animate().shimmer().shake(),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                alignment: WrapAlignment.center,
                                children: provider.currentComboWords.map((sub) {
                                  final score = ScoreCalculator.wordScore(sub);
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color:
                                              AppColors.gold.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      '$sub (+$score)',
                                      style: GoogleFonts.outfit(
                                        color: AppColors.textGold,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              )
                                  .animate()
                                  .fadeIn(duration: 300.ms)
                                  .slideY(begin: 0.2, end: 0),
                            ],
                          )
                        : null,
                  ),

                  const SizedBox(height: 8),

                  // ── Grid ───────────────────────────────────────
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double maxGridSize =
                              constraints.maxWidth < constraints.maxHeight
                                  ? constraints.maxWidth - 32
                                  : constraints.maxHeight - 32;
                          final double cellSize = maxGridSize / size;

                          return GestureDetector(
                            onPanStart: (details) =>
                                _handlePanStart(details, provider, cellSize),
                            onPanUpdate: (details) =>
                                _handlePanUpdate(details, provider, cellSize),
                            onPanEnd: (_) => provider.submitWord(),
                            child: Container(
                              key: _gridKey,
                              width: maxGridSize,
                              height: maxGridSize,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: AppColors.glassBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  for (int r = 0; r < size; r++)
                                    for (int c = 0; c < size; c++)
                                      AnimatedPositioned(
                                        key: ValueKey(
                                            '${session.grid[r][c].letter}_${r}_$c'),
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.bounceOut,
                                        left: c * cellSize,
                                        top: r * cellSize,
                                        child: GestureDetector(
                                          onTap: () {
                                            if (provider.activeJoker != null) {
                                              provider.startSelection(
                                                  session.grid[r][c]);
                                            }
                                          },
                                          child: CellWidget(
                                            cell: session.grid[r][c],
                                            isSelected: provider.selectedCells
                                                .contains(session.grid[r][c]),
                                            size: cellSize,
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // ── Joker Bar ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (provider.activeJoker != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Joker Aktif!',
                                  style: GoogleFonts.outfit(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.bold),
                                )
                                    .animate(
                                        onPlay: (c) => c.repeat(reverse: true))
                                    .fadeOut(duration: 500.ms),
                                GestureDetector(
                                  onTap: provider.cancelJoker,
                                  child: const Text('İptal Et',
                                      style:
                                          TextStyle(color: AppColors.danger)),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          height: 64,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: provider.jokers.length,
                            itemBuilder: (context, index) {
                              final joker = provider.jokers[index];
                              final isActive =
                                  provider.activeJoker == joker.type;
                              return GestureDetector(
                                onTap: () {
                                  if (joker.count > 0) {
                                    _showJokerConfirmDialog(
                                        context, provider, joker);
                                  } else {
                                    // Optionally open market
                                  }
                                },
                                child: Container(
                                  width: 64,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.warning.withOpacity(0.2)
                                        : AppColors.surface,
                                    border: Border.all(
                                      color: isActive
                                          ? AppColors.warning
                                          : AppColors.glassBorder,
                                      width: isActive ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Text(joker.emoji,
                                          style: const TextStyle(fontSize: 28)),
                                      if (joker.count > 0)
                                        Positioned(
                                          right: 4,
                                          top: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: AppColors.primaryStart,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '${joker.count}',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      if (joker.count == 0)
                                        Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                                Icons.add_shopping_cart_rounded,
                                                color: Colors.white,
                                                size: 20),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Pan Handlers ───────────────────────────────────────────
  void _handlePanStart(
      DragStartDetails details, GameProvider provider, double cellSize) {
    final cell = _getCellFromOffset(details.localPosition, provider, cellSize);
    if (cell != null) {
      provider.startSelection(cell);
    }
  }

  void _handlePanUpdate(
      DragUpdateDetails details, GameProvider provider, double cellSize) {
    final cell = _getCellFromOffset(details.localPosition, provider, cellSize);
    if (cell != null) {
      provider.updateSelection(cell);
    }
  }

  Cell? _getCellFromOffset(
      Offset localPos, GameProvider provider, double cellSize) {
    final session = provider.session;
    if (session == null) return null;

    // Current grid coordinates
    final col = (localPos.dx / cellSize).floor();
    final row = (localPos.dy / cellSize).floor();

    if (row >= 0 &&
        row < session.gridSize &&
        col >= 0 &&
        col < session.gridSize) {
      // Calculate center of this cell
      final centerX = (col * cellSize) + (cellSize / 2);
      final centerY = (row * cellSize) + (cellSize / 2);

      // Distance from touch point to center
      final dx = localPos.dx - centerX;
      final dy = localPos.dy - centerY;
      final distance = (dx * dx + dy * dy); // squared distance for performance

      // Only select if within 40% of cell radius (0.4 * cellSize / 2)^2
      final threshold = (cellSize * 0.5) * (cellSize * 0.5);

      if (distance < threshold) {
        return session.grid[row][col];
      }
    }
    return null;
  }

  // ── Dialogs ────────────────────────────────────────────────
  Future<bool> _onWillPop(GameProvider provider) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Çıkış?', style: GoogleFonts.outfit(color: Colors.white)),
        content: Text(
            'Oyundan çıkmak istiyor musunuz? İlerlemeniz kaydedilecek.',
            style: GoogleFonts.outfit(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hayır',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Evet, Çık'),
          ),
        ],
      ),
    );

    if (result == true) {
      await provider.saveScore();
      if (!mounted) return true;
      Navigator.pop(context);
    }
    return false;
  }

  bool _isShowingGameOver = false;

  void _showGameOverDialog(BuildContext context, GameProvider provider) async {
    if (_isShowingGameOver) return;
    _isShowingGameOver = true;
    await provider.saveScore();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Center(
            child: Text('🎮 OYUN BİTTİ',
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StatRow('Puan:', '${provider.session!.currentScore}',
                  AppColors.textGold),
              const SizedBox(height: 8),
              _StatRow('Kelime:', '${provider.session!.foundWords.length}',
                  Colors.white),
              const SizedBox(height: 8),
              _StatRow('Kazanılan Altın:', '+${provider.session!.goldEarned}',
                  AppColors.gold),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceLight,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ana Ekran'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _isShowingGameOver = false;
                provider.startGame(
                  provider.session!.gridSize,
                  provider.session!.initialMoves,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryStart,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tekrar Oyna'),
            ),
          ],
        );
      },
    );
  }

  void _showAvailableWordsModal(BuildContext context, GameProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final words = provider.availableWords..sort();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Oluşturulabilir Kelimeler',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            words[index],
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '${ScoreCalculator.wordScore(words[index])} Puan',
                            style: GoogleFonts.outfit(
                              color: AppColors.success,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showJokerConfirmDialog(
      BuildContext context, GameProvider provider, dynamic joker) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              JokerDemoWidget(type: joker.type, showEmoji: false),
              const SizedBox(height: 20),
              Text(
                joker.name,
                style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                joker.description,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                    color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primaryStart.withOpacity(0.3)),
                ),
                child: Text(
                  _getJokerUsage(joker.type),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                      color: AppColors.primaryStart,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('İptal Et',
                  style: GoogleFonts.outfit(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                provider.activateJoker(joker.type);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryStart,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Kullan',
                  style: GoogleFonts.outfit(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  String _getJokerUsage(JokerType type) {
    switch (type) {
      case JokerType.shuffle:
      case JokerType.party:
        return 'Kullan butonuna bastığınız an aktif olur.';
      case JokerType.fish:
        return 'Kullan dedikten sonra rastgele çalışır.';
      case JokerType.swap:
        return 'Kullan dedikten sonra yer değiştirecek iki komşu harfe sırayla dokunun.';
      default:
        return 'Kullan dedikten sonra hedef harfe dokunun.';
    }
  }

  String _getJokerInstruction(JokerType type) {
    switch (type) {
      case JokerType.fish:
        return 'Rastgele 5 harf patlatılıyor...';
      case JokerType.wheel:
        return 'Hedef harfe dokun, satır ve sütunu temizle.';
      case JokerType.lollipop:
        return 'Silmek istediğin harfe dokun.';
      case JokerType.swap:
        return 'Yer değiştirecek iki komşu harfe sırayla dokun.';
      case JokerType.shuffle:
        return 'Harfler karıştırılıyor...';
      case JokerType.party:
        return 'Tüm tahta sıfırlanıyor...';
    }
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.outfit(
                color: AppColors.textSecondary, fontSize: 16)),
        Text(value,
            style: GoogleFonts.outfit(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
