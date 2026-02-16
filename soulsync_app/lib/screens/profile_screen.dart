import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';
import 'manage_photos_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _ageController = TextEditingController();

  final List<String> _allInterests = [
    'Travel', 'Music', 'Movies', 'Reading', 'Cooking',
    'Fitness', 'Art', 'Photography', 'Gaming', 'Nature',
    'Dancing', 'Yoga', 'Sports', 'Technology', 'Fashion',
    'Food', 'Pets', 'Volunteering', 'Meditation', 'Writing',
  ];
  List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio ?? '';
      _cityController.text = user.city ?? '';
      _countryController.text = user.country ?? '';
      _ageController.text = user.age?.toString() ?? '';
      _interests = List.from(user.interests);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    final updates = <String, dynamic>{
      'name': _nameController.text.trim(),
      'bio': _bioController.text.trim(),
      'city': _cityController.text.trim(),
      'country': _countryController.text.trim(),
      'interests': _interests,
    };
    final age = int.tryParse(_ageController.text);
    if (age != null) updates['age'] = age;

    // Construct location string
    if (_cityController.text.isNotEmpty || _countryController.text.isNotEmpty) {
      updates['location'] = [_cityController.text.trim(), _countryController.text.trim()]
          .where((s) => s.isNotEmpty)
          .join(', ');
    }

    final success = await auth.updateProfile(updates);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Profile updated!' : 'Failed to update profile'),
          backgroundColor: success ? SoulSyncColors.mint500 : Colors.red,
        ),
      );
      if (success) Navigator.pop(context);
    }
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
                    Expanded(child: Text('Edit Profile', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center)),
                    TextButton(
                      onPressed: _saveProfile,
                      child: Consumer<AuthProvider>(
                        builder: (context, auth, _) => auth.loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text('Save', style: TextStyle(color: SoulSyncColors.coral500, fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Photo section
                      FriendlyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Photos', style: Theme.of(context).textTheme.titleLarge),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ManagePhotosScreen()),
                                  ),
                                  child: const Text('Manage', style: TextStyle(color: SoulSyncColors.coral500)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Consumer<AuthProvider>(
                              builder: (context, auth, _) {
                                final photos = auth.user?.photos ?? [];
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ...photos.map((url) => GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const ManagePhotosScreen()),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                                      ),
                                    )),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const ManagePhotosScreen()),
                                      ),
                                      child: Container(
                                        width: 80, height: 80,
                                        decoration: BoxDecoration(
                                          color: SoulSyncColors.coral50,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: SoulSyncColors.coral200, style: BorderStyle.solid),
                                        ),
                                        child: const Icon(Icons.add_photo_alternate, color: SoulSyncColors.coral400, size: 28),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Basic info
                      FriendlyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Basic Info', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 12),
                            FriendlyInput(hintText: 'Full Name', controller: _nameController, prefixIcon: const Icon(Icons.person_outline, color: SoulSyncColors.warm600)),
                            const SizedBox(height: 12),
                            FriendlyInput(hintText: 'Age', controller: _ageController, keyboardType: TextInputType.number, prefixIcon: const Icon(Icons.cake_outlined, color: SoulSyncColors.warm600)),
                            const SizedBox(height: 12),
                            FriendlyInput(hintText: 'About you', controller: _bioController, maxLines: 3, prefixIcon: const Icon(Icons.edit_note, color: SoulSyncColors.warm600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Location
                      FriendlyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Location', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 12),
                            FriendlyInput(hintText: 'City', controller: _cityController, prefixIcon: const Icon(Icons.location_city, color: SoulSyncColors.warm600)),
                            const SizedBox(height: 12),
                            FriendlyInput(hintText: 'Country', controller: _countryController, prefixIcon: const Icon(Icons.public, color: SoulSyncColors.warm600)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Interests
                      FriendlyCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Interests', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _allInterests.map((interest) {
                                final isSelected = _interests.contains(interest);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelected ? _interests.remove(interest) : _interests.add(interest);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: isSelected ? SoulSyncColors.coralGradient : null,
                                      color: isSelected ? null : SoulSyncColors.coral50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: isSelected ? Colors.transparent : SoulSyncColors.coral200),
                                    ),
                                    child: Text(interest, style: TextStyle(
                                      color: isSelected ? Colors.white : SoulSyncColors.coral700,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      fontSize: 13,
                                    )),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
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
}
