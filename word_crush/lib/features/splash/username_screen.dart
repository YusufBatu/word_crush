// ============================================================
// features/splash/username_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({super.key});
  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final username = _controller.text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    
    // Initialize gold for this user if it doesn't exist
    final goldKey = 'gold_$username';
    if (prefs.getInt(goldKey) == null) {
      await prefs.setInt(goldKey, 9999);
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.background, AppColors.surfaceLight, AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppColors.primaryStart, AppColors.primaryEnd],
                        ).createShader(bounds),
                        child: Text(
                          'WORD\nCRUSH',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.0,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Türkçe Kelime Oyunu',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 64),
                      // Card
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.glassWhite,
                          border: Border.all(color: AppColors.glassBorder),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kullanıcı Adın Nedir?',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _controller,
                                style: GoogleFonts.outfit(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Adını gir...',
                                  hintStyle: GoogleFonts.outfit(
                                    color: AppColors.textSecondary,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: AppColors.primaryStart,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.person_rounded,
                                    color: AppColors.primaryStart,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Lütfen bir ad gir';
                                  }
                                  if (val.trim().length < 2) {
                                    return 'En az 2 karakter olmalı';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (_) => _save(),
                                autofocus: true,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _save,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.primaryStart, AppColors.primaryEnd],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Başla 🚀',
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
