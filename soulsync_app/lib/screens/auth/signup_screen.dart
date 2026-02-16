import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/location_service.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import '../photo_upload_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  int _step = 0;
  bool _obscurePassword = true;
  bool _loadingLocation = false;
  final LocationService _locationService = LocationService();

  Future<void> _fetchLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final position = await _locationService.getCurrentPosition();
      if (position != null && mounted) {
        final placemark = await _locationService.getPlacemarkFromPosition(position);
        if (placemark != null && mounted) {
          setState(() {
            _cityController.text = placemark.locality ?? placemark.subAdministrativeArea ?? '';
            _countryController.text = placemark.country ?? '';
          });
        } else if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Could not determine address.')));
        }
      } else if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Location permission denied or service disabled.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get location.')));
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }


  // Step 1: Basic info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();

  // Step 2: Gender & preferences
  String _gender = 'male';
  String _lookingFor = 'female';

  // Step 3: Location & bio
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _bioController = TextEditingController();

  // Step 4: Interests
  final List<String> _selectedInterests = [];
  final List<String> _availableInterests = [
    'Travel', 'Music', 'Movies', 'Reading', 'Cooking',
    'Fitness', 'Art', 'Photography', 'Gaming', 'Nature',
    'Dancing', 'Yoga', 'Sports', 'Technology', 'Fashion',
    'Food', 'Pets', 'Volunteering', 'Meditation', 'Writing',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text) ?? 18,
      gender: _gender,
      lookingFor: _lookingFor,
      bio: _bioController.text.isNotEmpty ? _bioController.text : null,
      city: _cityController.text.isNotEmpty ? _cityController.text : null,
      country: _countryController.text.isNotEmpty ? _countryController.text : null,
      interests: _selectedInterests.isNotEmpty ? _selectedInterests : null,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PhotoUploadScreen()),
      );
    }
  }

  void _nextStep() {
    if (_step == 0 && !_formKey.currentState!.validate()) return;
    
    if (_step == 2) {
       if (_cityController.text.trim().isEmpty || _countryController.text.trim().isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your city and country')));
         return;
       }
       if (_bioController.text.trim().length < 50) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bio must be at least 50 characters')));
         return;
       }
    }

    if (_step < 3) {
      setState(() => _step++);
    } else {
      _handleSignup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    if (_step > 0)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: SoulSyncColors.warm700),
                        onPressed: () => setState(() => _step--),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.close, color: SoulSyncColors.warm700),
                        onPressed: () => Navigator.pop(context),
                      ),
                    Expanded(
                      child: Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: List.generate(4, (i) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i <= _step ? SoulSyncColors.coral500 : SoulSyncColors.coral200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Step ${_step + 1} of 4',
                style: TextStyle(color: SoulSyncColors.warm600, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return Column(
                        children: [
                          if (_step == 0) _buildStep1(),
                          if (_step == 1) _buildStep2(),
                          if (_step == 2) _buildStep3(),
                          if (_step == 3) _buildStep4(),

                          if (auth.error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade400, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(auth.error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),
                          FriendlyButton(
                            text: _step < 3 ? 'Continue' : 'Create Account',
                            icon: _step < 3 ? Icons.arrow_forward : Icons.check,
                            isLoading: auth.loading,
                            onPressed: _nextStep,
                          ),

                          if (_step == 0) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Already have an account? ', style: TextStyle(color: SoulSyncColors.warm600)),
                                GestureDetector(
                                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                                  child: Text('Sign In', style: TextStyle(color: SoulSyncColors.coral500, fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return FriendlyCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Basic Information', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Tell us about yourself', style: TextStyle(color: SoulSyncColors.warm600)),
            const SizedBox(height: 20),
            FriendlyInput(
              hintText: 'Full Name',
              controller: _nameController,
              prefixIcon: const Icon(Icons.person_outline, color: SoulSyncColors.warm600),
              validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            FriendlyInput(
              hintText: 'Email address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined, color: SoulSyncColors.warm600),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 12),
            FriendlyInput(
              hintText: 'Password (min 8 characters)',
              controller: _passwordController,
              obscureText: _obscurePassword,
              prefixIcon: const Icon(Icons.lock_outline, color: SoulSyncColors.warm600),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: SoulSyncColors.warm600),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8) return 'Password must be at least 8 characters';
                return null;
              },
            ),
            const SizedBox(height: 12),
            FriendlyInput(
              hintText: 'Age',
              controller: _ageController,
              keyboardType: TextInputType.number,
              prefixIcon: const Icon(Icons.cake_outlined, color: SoulSyncColors.warm600),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Age is required';
                final age = int.tryParse(v);
                if (age == null || age < 18 || age > 99) return 'Age must be 18-99';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return FriendlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About You', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Help us find your perfect match', style: TextStyle(color: SoulSyncColors.warm600)),
          const SizedBox(height: 20),
          Text('I am...', style: TextStyle(fontWeight: FontWeight.w600, color: SoulSyncColors.warm800)),
          const SizedBox(height: 8),
          _buildGenderSelector(_gender, (v) => setState(() => _gender = v)),
          const SizedBox(height: 20),
          Text('Looking for...', style: TextStyle(fontWeight: FontWeight.w600, color: SoulSyncColors.warm800)),
          const SizedBox(height: 8),
          _buildGenderSelector(_lookingFor, (v) => setState(() => _lookingFor = v), includeEveryone: true),
        ],
      ),
    );
  }

  Widget _buildGenderSelector(String selected, ValueChanged<String> onChanged, {bool includeEveryone = false}) {
    final options = ['male', 'female', 'non-binary'];
    if (includeEveryone) options.add('everyone');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected == opt;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: isSelected ? SoulSyncColors.coralGradient : null,
              color: isSelected ? null : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: isSelected ? Colors.transparent : SoulSyncColors.coral200),
              boxShadow: isSelected
                  ? [BoxShadow(color: SoulSyncColors.softCoral.withValues(alpha: 0.3), blurRadius: 8)]
                  : null,
            ),
            child: Text(
              opt[0].toUpperCase() + opt.substring(1),
              style: TextStyle(
                color: isSelected ? Colors.white : SoulSyncColors.warm700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStep3() {
    return FriendlyCard(
      child: Form( // Wrap in Form validation if needed, but we do manual checks in _nextStep or here
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Location & Bio', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Where are you located?', style: TextStyle(color: SoulSyncColors.warm600)),
            const SizedBox(height: 20),
            
            // Location Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loadingLocation ? null : _fetchLocation,
                icon: _loadingLocation
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.my_location, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SoulSyncColors.coral500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                label: Text(_loadingLocation ? 'Locating...' : 'Use Current Location'),
              ),
            ),
            const SizedBox(height: 16),
            
            FriendlyInput(
              hintText: 'City (Use location button)',
              controller: _cityController,
              readOnly: true, // Force user to use location button
              prefixIcon: const Icon(Icons.location_city, color: SoulSyncColors.warm600),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please use "Use Current Location"' : null,
            ),
            const SizedBox(height: 12),
            FriendlyInput(
              hintText: 'Country (Use location button)',
              controller: _countryController,
              readOnly: true, // Force user to use location button
              prefixIcon: const Icon(Icons.public, color: SoulSyncColors.warm600),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please use "Use Current Location"' : null,
            ),
            const SizedBox(height: 20),
            
            Text('About You *', style: TextStyle(fontWeight: FontWeight.w600, color: SoulSyncColors.warm800)),
            const SizedBox(height: 8),
            FriendlyInput(
              hintText: 'Tell us about yourself (min 50 characters)...',
              controller: _bioController,
              maxLines: 4,
              prefixIcon: const Icon(Icons.edit_note, color: SoulSyncColors.warm600),
              validator: (v) {
                if (v == null || v.trim().length < 50) return 'Please write at least 50 characters';
                return null;
              },
            ),
            // Character count helper
            ValueListenableBuilder(
              valueListenable: _bioController,
              builder: (context, value, child) {
                final len = value.text.trim().length;
                return Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    '$len / 50 characters minimum',
                    style: TextStyle(
                      color: len >= 50 ? Colors.green : Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4() {
    return FriendlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Interests', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Select at least 3 interests', style: TextStyle(color: SoulSyncColors.warm600)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: _availableInterests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedInterests.remove(interest);
                    } else {
                      _selectedInterests.add(interest);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? SoulSyncColors.coralGradient : null,
                    color: isSelected ? null : SoulSyncColors.coral50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : SoulSyncColors.coral200,
                    ),
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      color: isSelected ? Colors.white : SoulSyncColors.coral700,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            '${_selectedInterests.length} selected',
            style: TextStyle(color: SoulSyncColors.warm600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
