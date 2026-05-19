// ============================================================
// features/market/market_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../game/game_provider.dart';
import '../../widgets/joker_demo_widget.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  int _gold = 0;

  @override
  void initState() {
    super.initState();
    _loadGold();
  }

  Future<void> _loadGold() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? 'Oyuncu';
    setState(() {
      _gold = prefs.getInt('gold_$username') ?? 9999;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GameProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Joker Market',
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              border: Border.all(color: AppColors.gold.withOpacity(0.5)),
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
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.jokers.length,
        itemBuilder: (context, index) {
          final joker = provider.jokers[index];
          final canAfford = _gold >= joker.cost;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                children: [
                  // Top Section: Info & Buy
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Animated Demo
                        JokerDemoWidget(type: joker.type),
                        const SizedBox(width: 20),
                        // Middle: Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                joker.name,
                                style: GoogleFonts.outfit(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _TagBadge(
                                label: 'Maliyet: ${joker.cost} Altın',
                                color: AppColors.gold,
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(icon: '🎯', title: 'Özellik:', desc: joker.description),
                              _InfoRow(icon: '💡', title: 'Amaç:', desc: _getJokerPurpose(joker.type)),
                              _InfoRow(icon: '👆', title: 'Kullanım:', desc: _getJokerUsage(joker.type)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom Section: Possession & Action
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    color: AppColors.surfaceLight.withOpacity(0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Envanter: ${joker.count}',
                          style: GoogleFonts.outfit(
                            color: AppColors.primaryStart,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: canAfford
                              ? () async {
                                  final success = await provider.buyJoker(joker.type);
                                  if (success) {
                                    await _loadGold();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${joker.name} satın alındı!'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryStart,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SATIN AL',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('💰', style: TextStyle(fontSize: 10)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${joker.cost}',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.textGold,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getJokerPurpose(JokerType type) {
    switch (type) {
      case JokerType.fish: return 'Kilitlenmiş bölgeleri açmak için rastgele temizlik yapar.';
      case JokerType.wheel: return 'Dikey ve yatay hatları tek seferde boşaltır.';
      case JokerType.lollipop: return 'Tek bir engelleyici harfi ortadan kaldırmak içindir.';
      case JokerType.swap: return 'İstediğiniz kelimeyi kurmak için harflerin yerini değiştirir.';
      case JokerType.shuffle: return 'Tahtada hiç kelime kalmadığında tüm harfleri karıştırır.';
      case JokerType.party: return 'Tüm tahtayı sıfırlayarak yepyeni bir şans verir.';
    }
  }

  String _getJokerUsage(JokerType type) {
    switch (type) {
      case JokerType.shuffle:
      case JokerType.party: return 'Butona basıldığı an aktif olur.';
      case JokerType.fish: return 'Butona bastıktan sonra rastgele çalışır.';
      case JokerType.swap: return 'Sırayla yer değiştirecek iki komşu harfe dokunun.';
      default: return 'Jokeri seçtikten sonra hedef harfe dokunun.';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String icon, title, desc;
  const _InfoRow({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$icon $title ', style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
            TextSpan(text: desc, style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _TagBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(label, style: GoogleFonts.outfit(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}


