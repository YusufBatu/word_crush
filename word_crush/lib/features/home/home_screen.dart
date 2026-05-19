// ============================================================
// features/home/home_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../game_setup/game_setup_screen.dart';
import '../scoreboard/scoreboard_screen.dart';
import '../market/market_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = '';
  int _gold = 9999;
  bool _editingName = false;
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Oyuncu';
      _gold = prefs.getInt('gold') ?? 9999;
      _nameCtrl.text = _username;
    });
  }

  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    if (name.length < 2) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
    setState(() {
      _username = name;
      _editingName = false;
    });
  }

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
          child: Column(
            children: [
              // ─── AppBar Area ───────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // Username
                    GestureDetector(
                      onTap: () => setState(() => _editingName = !_editingName),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryStart,
                                  AppColors.primaryEnd
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(
                                _username.isNotEmpty
                                    ? _username[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _username,
                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.edit_rounded,
                              size: 14, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Gold
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        border:
                            Border.all(color: AppColors.gold.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('💰', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(
                            '$_gold',
                            style: GoogleFonts.outfit(
                              color: AppColors.textGold,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Name Edit ───────────────────────────────
              if (_editingName)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameCtrl,
                          style:
                              GoogleFonts.outfit(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Yeni isim...',
                            hintStyle: GoogleFonts.outfit(
                                color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                          ),
                          autofocus: true,
                          onSubmitted: (_) => _saveName(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _saveName,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryStart,
                                AppColors.primaryEnd
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // ─── Logo ────────────────────────────────────
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primaryStart, AppColors.primaryEnd],
                ).createShader(bounds),
                child: Text(
                  'WORD CRUSH',
                  style: GoogleFonts.outfit(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Türkçe Kelime Macerası',
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 48),

              // ─── Menu Buttons ────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MenuButton(
                        emoji: '🎮',
                        label: 'YENİ OYUN',
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryStart,
                            AppColors.primaryEnd
                          ],
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const GameSetupScreen()),
                          );
                          _load();
                        },
                      ),
                      const SizedBox(height: 16),
                      _MenuButton(
                        emoji: '🏆',
                        label: 'SKOR TABLOSU',
                        gradient: LinearGradient(
                          colors: [
                            Colors.amber.shade700,
                            Colors.orange.shade400
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ScoreboardScreen()),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _MenuButton(
                        emoji: '🛒',
                        label: 'MARKET',
                        gradient: LinearGradient(
                          colors: [Colors.teal.shade600, Colors.cyan.shade400],
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MarketScreen()),
                          );
                          _load();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String emoji;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _MenuButton({
    required this.emoji,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.reverse(),
        onTapUp: (_) {
          _ctrl.forward();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.forward(),
        child: Container(
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
