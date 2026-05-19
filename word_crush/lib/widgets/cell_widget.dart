// ============================================================
// widgets/cell_widget.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/models/cell.dart';
import '../core/constants/letter_scores.dart';

class CellWidget extends StatelessWidget {
  final Cell cell;
  final bool isSelected;
  final double size;

  const CellWidget({
    super.key,
    required this.cell,
    required this.isSelected,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isPower = cell.isPower;
    final Color baseColor = isPower ? cell.powerColor : AppColors.cellDefault;
    final Color borderColor = isSelected
        ? AppColors.cellGlow
        : isPower
            ? cell.powerColor.withOpacity(0.7)
            : AppColors.glassBorder;

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      width: size,
      height: size,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.cellSelected.withOpacity(0.3)
            : baseColor.withOpacity(0.85),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.cellGlow.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : isPower
                ? [
                    BoxShadow(
                      color: cell.powerColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main letter
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isPower)
                Text(
                  cell.powerSymbol,
                  style: TextStyle(
                    fontSize: size * 0.22,
                    color: Colors.black,
                    height: 1.0,
                  ),
                ),
              Text(
                cell.letter,
                style: GoogleFonts.outfit(
                  fontSize: size * (isPower ? 0.30 : 0.38),
                  fontWeight: FontWeight.w800,
                  color: isSelected ? AppColors.textGold : AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
            ],
          ),
          // Score badge (bottom-right)
          Positioned(
            right: 3,
            bottom: 2,
            child: Text(
              '${letterScores[cell.letter] ?? 1}',
              style: GoogleFonts.outfit(
                fontSize: size * 0.18,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.textGold.withOpacity(0.8)
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );

    Widget result = content;

    if (cell.isExploding) {
      result = result.animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 200.ms)
          .tint(color: AppColors.danger.withOpacity(0.5), duration: 200.ms)
          .shake(hz: 8, curve: Curves.easeInOut);
    } else if (cell.isNew) {
      result = result.animate().slideY(
        begin: -1.5,
        end: 0,
        duration: 400.ms,
        curve: Curves.bounceOut,
      );
    }
    
    return result;
  }
}
