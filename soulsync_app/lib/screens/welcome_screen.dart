import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../widgets/common_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: SoulSyncColors.coralGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: SoulSyncColors.softCoral.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 48),
                  )
                      .animate()
                      .scale(begin: const Offset(0, 0), duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 24),

                  // Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [SoulSyncColors.coral500, SoulSyncColors.peach500],
                    ).createShader(bounds),
                    child: Text(
                      'SoulSync',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 48,
                          ),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                  const SizedBox(height: 8),

                  // Tagline
                  Text(
                    'Where Hearts Align with AI',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: SoulSyncColors.warm700,
                          fontWeight: FontWeight.w500,
                        ),
                  ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                  const SizedBox(height: 8),

                  // Subtitle with icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology, size: 16, color: SoulSyncColors.mint500),
                      const SizedBox(width: 6),
                      Text(
                        'Powered by Emotion. Perfected by AI.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SoulSyncColors.warm600,
                            ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.auto_awesome, size: 16, color: SoulSyncColors.warmGold),
                    ],
                  ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
                  const SizedBox(height: 16),

                  // Trust indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _trustBadge(Icons.star, '4.9/5 Rating', SoulSyncColors.warmGold),
                      const SizedBox(width: 16),
                      _trustBadge(Icons.people, '10K+ Matches', SoulSyncColors.softSky),
                      const SizedBox(width: 16),
                      _trustBadge(Icons.coffee, 'Human Touch', SoulSyncColors.gentleSage),
                    ],
                  ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
                  const SizedBox(height: 40),

                  // CTA Card
                  FriendlyCard(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        FriendlyButton(
                          text: 'Start Your Journey',
                          icon: Icons.chevron_right,
                          onPressed: () => Navigator.pushNamed(context, '/signup'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(color: SoulSyncColors.warm600),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/login'),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: SoulSyncColors.coral500,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.1, duration: 500.ms),
                  const SizedBox(height: 24),

                  // Footer
                  Text(
                    'By continuing, you agree to our Terms & Privacy Policy',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SoulSyncColors.textMuted,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 1200.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _trustBadge(IconData icon, String text, Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: SoulSyncColors.textMuted)),
      ],
    );
  }
}
