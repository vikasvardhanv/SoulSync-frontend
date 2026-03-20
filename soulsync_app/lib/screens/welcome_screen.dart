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
                          color: SoulSyncColors.softCoral.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 48,
                    ),
                  ).animate().scale(
                    begin: const Offset(0, 0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  ),
                  const SizedBox(height: 24),

                  // Title
                  ShaderMask(
                    shaderCallback:
                        (bounds) => const LinearGradient(
                          colors: [
                            SoulSyncColors.coral500,
                            SoulSyncColors.peach500,
                          ],
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
                      Icon(
                        Icons.psychology,
                        size: 16,
                        color: SoulSyncColors.mint500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Boundary-First Compatibility Lab',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: SoulSyncColors.warm600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: SoulSyncColors.warmGold,
                      ),
                    ],
                  ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
                  const SizedBox(height: 16),

                  // Trust indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _trustBadge(
                        Icons.shield_outlined,
                        'Boundary-First',
                        SoulSyncColors.warmGold,
                      ),
                      const SizedBox(width: 16),
                      _trustBadge(
                        Icons.science_outlined,
                        '7-Day Sprint',
                        SoulSyncColors.softSky,
                      ),
                      const SizedBox(width: 16),
                      _trustBadge(
                        Icons.psychology_outlined,
                        'AI Debrief',
                        SoulSyncColors.gentleSage,
                      ),
                    ],
                  ).animate().fadeIn(delay: 800.ms, duration: 500.ms),
                  const SizedBox(height: 20),

                  FriendlyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.insights_outlined,
                              color: SoulSyncColors.coral500,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'How We Differentiate',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _diffRow(
                          icon: Icons.swipe,
                          title: 'Regular dating apps',
                          subtitle: 'Swipe-first and chat-first discovery.',
                          color: SoulSyncColors.warm600,
                        ),
                        const SizedBox(height: 10),
                        _diffRow(
                          icon: Icons.smart_toy_outlined,
                          title: 'AI dating apps',
                          subtitle: 'Mostly AI icebreakers and profile writing.',
                          color: SoulSyncColors.softSky,
                        ),
                        const SizedBox(height: 10),
                        _diffRow(
                          icon: Icons.psychology_alt_outlined,
                          title: 'SoulSync Lab',
                          subtitle:
                              'Boundary-first matching + 7-day behavior sprint + risk-based AI debrief.',
                          color: SoulSyncColors.coral500,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
                  const SizedBox(height: 40),

                  // CTA Card
                  FriendlyCard(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            FriendlyButton(
                              text: 'Start Compatibility Sprint',
                              icon: Icons.chevron_right,
                              onPressed:
                                  () => Navigator.pushNamed(context, '/signup'),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    color: SoulSyncColors.warm600,
                                  ),
                                ),
                                GestureDetector(
                                  onTap:
                                      () => Navigator.pushNamed(
                                        context,
                                        '/login',
                                      ),
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
                      )
                      .animate()
                      .fadeIn(delay: 1000.ms)
                      .slideY(begin: 0.1, duration: 500.ms),
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
        Text(
          text,
          style: TextStyle(fontSize: 11, color: SoulSyncColors.textMuted),
        ),
      ],
    );
  }

  Widget _diffRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: SoulSyncColors.warm800,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: SoulSyncColors.warm700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
