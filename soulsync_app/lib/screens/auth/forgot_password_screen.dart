import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: SoulSyncColors.warm700),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text('Reset Password', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: FriendlyCard(
                      child: _sent ? _buildSuccess() : _buildForm(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Column(
          children: [
            const Icon(Icons.lock_reset, size: 48, color: SoulSyncColors.coral500),
            const SizedBox(height: 16),
            Text('Forgot your password?', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              "Enter your email and we'll send you a reset link.",
              style: TextStyle(color: SoulSyncColors.warm600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FriendlyInput(
              hintText: 'Email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined, color: SoulSyncColors.warm600),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Text(auth.error!, style: TextStyle(color: Colors.red.shade600, fontSize: 13)),
            ],
            const SizedBox(height: 20),
            FriendlyButton(
              text: 'Send Reset Link',
              isLoading: auth.loading,
              onPressed: () async {
                final success = await auth.forgotPassword(_emailController.text.trim());
                if (success && mounted) setState(() => _sent = true);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: SoulSyncColors.gentleMint.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: SoulSyncColors.mint500, size: 32),
        ),
        const SizedBox(height: 16),
        Text('Email Sent!', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Check your email for a password reset link.',
          style: TextStyle(color: SoulSyncColors.warm600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        FriendlyButton(
          text: 'Back to Login',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
