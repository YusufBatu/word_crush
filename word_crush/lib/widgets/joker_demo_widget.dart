import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/app_colors.dart';
import '../features/game/game_provider.dart';
import 'package:provider/provider.dart';

class JokerDemoWidget extends StatelessWidget {
  final JokerType type;
  final bool showEmoji;

  const JokerDemoWidget({
    super.key,
    required this.type,
    this.showEmoji = true,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GameProvider>();
    final emoji = provider.jokers.firstWhere((j) => j.type == type).emoji;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (r) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (c) => _MiniCell(row: r, col: c, jokerType: type)),
                  )),
                ),
              ],
            ),
          ),
        ),
        if (showEmoji) ...[
          const SizedBox(height: 16),
          Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ],
      ],
    );
  }
}

class _MiniCell extends StatelessWidget {
  final int row, col;
  final JokerType jokerType;
  const _MiniCell({required this.row, required this.col, required this.jokerType});

  @override
  Widget build(BuildContext context) {
    bool isAffected = false;
    switch (jokerType) {
      case JokerType.fish: isAffected = (row + col) % 2 == 0; break;
      case JokerType.wheel: isAffected = row == 1 || col == 1; break;
      case JokerType.lollipop: isAffected = row == 1 && col == 1; break;
      case JokerType.swap: isAffected = row == 1 && (col == 0 || col == 1); break;
      case JokerType.shuffle: isAffected = true; break;
      case JokerType.party: isAffected = true; break;
    }

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(4),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .then(delay: 500.ms)
     .custom(
       duration: 1000.ms,
       builder: (context, value, child) {
         if (!isAffected) return child!;
         return Container(
           width: 18, height: 18,
           decoration: BoxDecoration(
             color: AppColors.primaryStart.withOpacity(value),
             borderRadius: BorderRadius.circular(4),
             border: Border.all(color: AppColors.primaryStart, width: value * 2),
           ),
         );
       }
     );
  }
}
