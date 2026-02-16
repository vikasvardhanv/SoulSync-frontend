import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';
import 'legal_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

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
                    Expanded(child: Text('Settings', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center)),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Account section
                      FriendlyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Account', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            _settingsTile(Icons.email_outlined, 'Email', user?.email ?? 'Not set'),
                            const Divider(),
                            _settingsTile(Icons.lock_outline, 'Change Password', 'Update your password', onTap: _showChangePasswordDialog),
                            const Divider(),
                            _settingsTile(Icons.workspace_premium, 'Subscription', user?.hasPremium == true ? 'Premium' : 'Free', onTap: () => Navigator.pushNamed(context, '/payment')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Preferences
                      FriendlyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            _settingsTile(Icons.notifications_outlined, 'Notifications', 'Push notifications'),
                            const Divider(),
                            _settingsTile(Icons.location_on_outlined, 'Location', user?.location ?? 'Not set'),
                            const Divider(),
                            _settingsTile(Icons.visibility_outlined, 'Profile Visibility', 'Visible to matches'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // About
                      FriendlyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('About', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            _settingsTile(Icons.info_outline, 'Version', '1.0.0'),
                            const Divider(),
                            _settingsTile(
                              Icons.description_outlined, 
                              'Terms of Service', 
                              '',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LegalScreen(
                                    title: 'Terms of Service',
                                    content: '''
**Terms of Service**

Welcome to SoulSync via Soul Sync UI ("Application"). By using our Application and website, you agree to these terms.

**1. Acceptance of Terms**
By accessing or using SoulSync, you agree to be bound by these Terms of Use and our Privacy Policy.

**2. User Accounts**
You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account.

**3. User Content**
You retain ownership of the photos and profile information you upload. By uploading content, you grant SoulSync a license to use, display, and distribute your content within the service.

**4. Location Services**
SoulSync requires location services to function effectively. By using the Application, you consent to the collection and use of your location data as described in our Privacy Policy.

**5. Prohibited Conduct**
You agree not to use the Application for any unlawful purpose or to harass, abuse, or harm another person.

**6. Disclaimer**
The Application is provided "as is" without warranties of any kind. 

**7. Contact**
If you have any questions about these Terms, please contact us.
                                    ''',
                                  ),
                                ),
                              ),
                            ),
                            const Divider(),
                            _settingsTile(
                              Icons.privacy_tip_outlined, 
                              'Privacy Policy', 
                              '',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LegalScreen(
                                    title: 'Privacy Policy',
                                    content: '''
**Privacy Policy**

Your privacy is important to us. This policy explains how we collect, use, and protect your information.

**1. Information We Collect**
- **Personal Information:** Name, email, age, gender, and interests.
- **Photos:** Images you upload to your profile.
- **Location Data:** We collect your precise location data to match you with users nearby.

**2. Location Tracking & Background Checks**
**IMPORTANT:** SoulSync tracks your location based on the permissions you have enabled. We perform background checks of your location to ensure you are matched with relevant users in your area even when you are not actively using the app. By using SoulSync, you explicitly consent to:
- Continuous background location tracking.
- Storage of your location history for matching purposes.
- Sharing your approximate distance with other users.
You can control location permissions through your device settings, but disabling them may limit the functionality of the Application.

**3. Image Usage**
Images uploaded to SoulSync are stored securely and used solely for the purpose of displaying your profile to other users.

**4. Data Security**
We implement appropriate technical measures to protect your personal data.

**5. Third-Party Services**
We may use third-party services for payments and analytics. These services have their own privacy policies.

**6. Changes to This Policy**
We may update this policy from time to time. We will notify you of any changes by posting the new policy on this page.
                                    ''',
                                  ),
                                ),
                              ),
                            ),
                            const Divider(),
                            _settingsTile(Icons.help_outline, 'Help & Support', ''),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Danger zone
                      FriendlyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Danger Zone', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red)),
                            const SizedBox(height: 8),
                            _settingsTile(
                              Icons.logout,
                              'Sign Out',
                              'Sign out of your account',
                              color: Colors.orange,
                              onTap: () async {
                                final navigator = Navigator.of(context);
                                final auth = context.read<AuthProvider>();
                                await auth.signOut();
                                navigator.pushReplacementNamed('/welcome');
                              },
                            ),
                            const Divider(),
                            _settingsTile(
                              Icons.delete_forever,
                              'Delete Account',
                              'Permanently delete your account',
                              color: Colors.red,
                              onTap: _showDeleteAccountDialog,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
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

  Widget _settingsTile(IconData icon, String title, String subtitle, {Color? color, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? SoulSyncColors.coral500),
      title: Text(title, style: TextStyle(color: color ?? SoulSyncColors.warm800, fontWeight: FontWeight.w500)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(color: SoulSyncColors.warm600, fontSize: 13)) : null,
      trailing: onTap != null ? Icon(Icons.chevron_right, color: color ?? SoulSyncColors.warm600) : null,
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog() {
    final currentPwd = TextEditingController();
    final newPwd = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FriendlyInput(hintText: 'Current password', controller: currentPwd, obscureText: true),
              const SizedBox(height: 12),
              FriendlyInput(hintText: 'New password', controller: newPwd, obscureText: true),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      setDialogState(() => loading = true);
                      try {
                        await AuthService().changePassword(
                          currentPassword: currentPwd.text,
                          newPassword: newPwd.text,
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password changed!'), backgroundColor: SoulSyncColors.mint500),
                            );
                          }
                        }
                      } catch (_) {
                        setDialogState(() => loading = false);
                      }
                    },
              child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final pwdController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This action is permanent and cannot be undone. All your data will be deleted.'),
            const SizedBox(height: 16),
            FriendlyInput(hintText: 'Enter your password', controller: pwdController, obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await AuthService().deleteAccount(password: pwdController.text, confirmation: 'DELETE');
                if (mounted) {
                  await context.read<AuthProvider>().signOut();
                  if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
                }
              } catch (_) {
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }
}
