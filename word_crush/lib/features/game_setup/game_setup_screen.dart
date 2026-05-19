// ============================================================
// features/game_setup/game_setup_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../game/game_provider.dart';
import '../game/game_screen.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});
  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int _currentStep = 1; // 1: Grid Size, 2: Move Count
  int _selectedSize = 8;
  int _selectedMoves = 20;

  final List<Map<String, dynamic>> _sizeOptions = [
    {'size': 6, 'label': '6×6', 'diff': 'Zor Seviye', 'color': const Color(0xFFFF5252)},
    {'size': 8, 'label': '8×8', 'diff': 'Orta Seviye', 'color': const Color(0xFFFFB300)},
    {'size': 10, 'label': '10×10', 'diff': 'Kolay Seviye', 'color': const Color(0xFF4CAF50)},
  ];

  final List<Map<String, dynamic>> _moveOptions = [
    {'moves': 15, 'label': 'Zor', 'desc': '15 Hamle', 'color': const Color(0xFFFF5252)},
    {'moves': 20, 'label': 'Orta', 'desc': '20 Hamle', 'color': const Color(0xFFFFB300)},
    {'moves': 25, 'label': 'Kolay', 'desc': '25 Hamle', 'color': const Color(0xFF4CAF50)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () {
            if (_currentStep == 2) {
              setState(() => _currentStep = 1);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Oyun Kurulumu',
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentStep == 1 ? 'Grid Boyutu Seç' : 'Hamle Sayısı Seç',
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentStep == 1 ? 'Oyun alanının büyüklüğünü belirle' : 'Zorluk seviyesini ve hamle miktarını seç',
              style: GoogleFonts.outfit(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            if (_currentStep == 1)
              ...(_sizeOptions.map((opt) {
                final size = opt['size'] as int;
                final isSelected = _selectedSize == size;
                return _SelectionCard(
                  label: opt['label'],
                  title: opt['diff'],
                  subtitle: 'Grid Yapısı',
                  color: opt['color'],
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedSize = size),
                );
              }))
            else
              ...(_moveOptions.map((opt) {
                final moves = opt['moves'] as int;
                final isSelected = _selectedMoves == moves;
                return _SelectionCard(
                  label: '${opt['moves']}',
                  title: opt['label'],
                  subtitle: opt['desc'],
                  color: opt['color'],
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedMoves = moves),
                );
              })),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (_currentStep == 1) {
                    setState(() => _currentStep = 2);
                  } else {
                    final provider = context.read<GameProvider>();
                    await provider.startGame(_selectedSize, _selectedMoves);
                    if (!context.mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryStart, AppColors.primaryEnd],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      _currentStep == 1 ? 'İLERİ ➔' : 'OYUNU BAŞLAT 🎮',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String label;
  final String title;
  final String subtitle;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionCard({
    required this.label,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.glassWhite,
          border: Border.all(
            color: isSelected ? color : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: color,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
