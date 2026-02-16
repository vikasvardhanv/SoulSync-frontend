import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../services/payment_service.dart';
import '../widgets/common_widgets.dart';
import 'quiz_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  final _promoController = TextEditingController();
  bool _applyingPromo = false;
  String? _promoMessage;
  bool _promoSuccess = false;
  double _monthlyPrice = 30.00;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _applyPromo() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    setState(() { _applyingPromo = true; _promoMessage = null; });

    try {
      final response = await _paymentService.applyPromo(code);
      if (mounted) {
        setState(() {
          _applyingPromo = false;
          _promoSuccess = response['success'] == true;
          _promoMessage = response['message'] ?? (_promoSuccess ? 'Promo code applied!' : 'Invalid promo code');
          if (_promoSuccess) _monthlyPrice = 0.00;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _applyingPromo = false;
          _promoSuccess = false;
          _promoMessage = 'Failed to apply promo code. Please try again.';
        });
      }
    }
  }

  void _continue(bool isPremium) {
    // In real app, process payment if _monthlyPrice > 0
    // For now, mocking successful subscription or free tier
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const QuizScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: SoulSyncColors.warm700),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(child: Text('Go Premium', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center)),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Premium banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF9A8B), Color(0xFFFFB3BA), Color(0xFFA8E6CF)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: SoulSyncColors.softCoral.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.workspace_premium, color: Colors.white, size: 36),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'SoulSync Premium',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Unlock the full power of AI-driven matching',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                      const SizedBox(height: 20),

                      // Features
                      FriendlyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Premium Benefits', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 16),
                            _featureRow(Icons.visibility, 'See who likes you', 'Know who swiped right before you do'),
                            _featureRow(Icons.filter_list, 'Advanced Filters', 'Filter by personality traits & compatibility'),
                            _featureRow(Icons.messenger, 'Unlimited Messages', 'Chat without any limits'),
                            _featureRow(Icons.psychology, 'Deep Insights', 'Get detailed personality analysis'),
                            _featureRow(Icons.star, 'Priority Matching', 'Show up first in discovery'),
                            _featureRow(Icons.undo, 'Undo Swipes', 'Take back accidental passes'),
                          ],
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: 20),

                      // Promo Code section (KEY LAUNCH FEATURE)
                      FriendlyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    color: SoulSyncColors.warmGold.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.card_giftcard, color: SoulSyncColors.warmGold, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Text('Have a Promo Code?', style: Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Follow us on Instagram @soulsync and get exclusive promo codes for free premium access!',
                              style: TextStyle(color: SoulSyncColors.warm600, fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: FriendlyInput(
                                    hintText: 'Enter promo code',
                                    controller: _promoController,
                                    prefixIcon: const Icon(Icons.confirmation_number, color: SoulSyncColors.warm600),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _applyingPromo ? null : _applyPromo,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: SoulSyncColors.warmGold,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: _applyingPromo
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                        : const Text('Apply', style: TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ],
                            ),
                            if (_promoMessage != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _promoSuccess ? SoulSyncColors.gentleMint.withValues(alpha: 0.3) : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _promoSuccess ? Icons.check_circle : Icons.error_outline,
                                      color: _promoSuccess ? SoulSyncColors.mint500 : Colors.red.shade400,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _promoMessage!,
                                        style: TextStyle(
                                          color: _promoSuccess ? SoulSyncColors.warm800 : Colors.red.shade700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 24),
                      
                      // Price & Action
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Monthly Subscription', style: TextStyle(color: SoulSyncColors.warm600, fontSize: 16)),
                                Text(
                                  '\$${_monthlyPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: _monthlyPrice == 0 ? SoulSyncColors.mint500 : SoulSyncColors.warm800,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (_monthlyPrice == 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.check_circle, size: 14, color: SoulSyncColors.mint500),
                                    const SizedBox(width: 4),
                                    Text('Free Forever applied', style: TextStyle(color: SoulSyncColors.mint500, fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 24),
                            FriendlyButton(
                              text: _monthlyPrice == 0 ? 'Activate Premium for Free' : 'Subscribe Now',
                              onPressed: () => _continue(true),
                              color: _monthlyPrice == 0 ? SoulSyncColors.mint500 : SoulSyncColors.warmGold,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextButton(
                        onPressed: () => _continue(false),
                        child: Text(
                          'Continue with Free Mode',
                          style: TextStyle(
                            color: SoulSyncColors.warm600,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: SoulSyncColors.coral50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: SoulSyncColors.coral500, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: SoulSyncColors.warm800, fontSize: 15)),
                Text(subtitle, style: TextStyle(color: SoulSyncColors.warm600, fontSize: 13)),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: SoulSyncColors.mint500, size: 20),
        ],
      ),
    );
  }
}
