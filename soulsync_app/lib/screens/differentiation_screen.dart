import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/common_widgets.dart';

class DifferentiationScreen extends StatelessWidget {
  const DifferentiationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Why SoulSync Is Different')),
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FriendlyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Not another swipe app',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SoulSync runs intentional matching: boundaries first, evidence second, decisions third.',
                      style: TextStyle(color: SoulSyncColors.warm600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _pillarCard(
                context,
                icon: Icons.psychology_outlined,
                title: 'Question-Based Core Algorithm',
                points: const [
                  'Hard filters first: dealbreakers, distance, intent, age, language.',
                  'Weighted compatibility score: values, lifestyle, communication, intent, reliability.',
                  'Mutual-fit ranking: both sides must score high, not one-way matching.',
                ],
              ),
              const SizedBox(height: 12),
              _pillarCard(
                context,
                icon: Icons.shield_outlined,
                title: 'Boundary-First Experience',
                points: const [
                  'Users set non-negotiables before discovery is unlocked.',
                  'Every match includes a clear "why we matched" explanation.',
                  'High-risk profiles are down-ranked or blocked before exposure.',
                ],
              ),
              const SizedBox(height: 12),
              _pillarCard(
                context,
                icon: Icons.security_outlined,
                title: 'Anti-Spam By Design',
                points: const [
                  'Face check after photo upload to reduce fake identity abuse.',
                  'Risk-tier limits for new users: capped outreach, velocity limits, strict moderation.',
                  'Behavior reliability signals feed ranking to suppress low-quality actors.',
                ],
              ),
              const SizedBox(height: 12),
              _pillarCard(
                context,
                icon: Icons.tune,
                title: 'Preferences Stay In User Control',
                points: const [
                  'User preferences are explicit and adjustable at any time.',
                  'The model learns from outcomes, but never overrides hard user boundaries.',
                  'Matching quality is optimized for long-term compatibility, not addictive swiping.',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pillarCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<String> points,
  }) {
    return FriendlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: SoulSyncColors.coral500),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: SoulSyncColors.coral400,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        color: SoulSyncColors.warm700,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
