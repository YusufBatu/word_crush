// ============================================================
// features/scoreboard/scoreboard_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/score_record.dart';
import '../../core/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  List<ScoreRecord> _scores = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'Oyuncu';

    final scores = await StorageService.getAllScores(username);
    final stats = await StorageService.getStats(username);

    setState(() {
      _scores = scores;
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Skor Tablosu',
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryStart))
          : Column(
              children: [
                // ── Stats Summary ─────────────────────────────────
                if (_scores.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryStart, AppColors.primaryEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryStart.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'GENEL İSTATİSTİKLER',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: _StatItem(
                                    'Oyun', '${_stats['total_games']}')),
                            Expanded(
                                child: _StatItem('En Yüksek Puan',
                                    '${_stats['best_score'] ?? 0}')),
                            Expanded(
                                child: _StatItem('Ortalama Puan',
                                    '${(_stats['avg_score'] ?? 0).round()}')),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                                child: _StatItem('Toplam Kelime',
                                    '${_stats['total_words'] ?? 0}')),
                            Expanded(
                                child: _StatItem(
                                    'Toplam Süre',
                                    _formatTotalTime(
                                        _stats['total_duration'] ?? 0))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'En Uzun Kelime: "${_stats['longest_word'] ?? '-'}"',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── History List ──────────────────────────────────
                Expanded(
                  child: _scores.isEmpty
                      ? Center(
                          child: Text(
                            'Henüz oyun oynanmadı.',
                            style: GoogleFonts.outfit(
                                color: AppColors.textSecondary, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _scores.length,
                          itemBuilder: (context, index) {
                            final score = _scores[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: AppColors.glassBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '#${score.gameNumber}',
                                        style: GoogleFonts.outfit(
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${score.gridSize}×${score.gridSize} Grid',
                                              style: GoogleFonts.outfit(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              score.formattedDate,
                                              style: GoogleFonts.outfit(
                                                color: AppColors.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Kelime: ${score.wordCount} • Süre: ${score.formattedDuration}',
                                          style: GoogleFonts.outfit(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          'En Uzun: ${score.longestWord}',
                                          style: GoogleFonts.outfit(
                                            color: AppColors.primaryStart,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    children: [
                                      Text(
                                        'Puan',
                                        style: GoogleFonts.outfit(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '${score.totalScore}',
                                        style: GoogleFonts.outfit(
                                          color: AppColors.textGold,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  String _formatTotalTime(int seconds) {
    if (seconds == 0) return '0sn';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}sa ${m}dk';
    if (m > 0) return '${m}dk ${s}sn';
    return '${s}sn';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
