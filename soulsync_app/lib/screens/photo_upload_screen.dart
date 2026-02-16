import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../services/match_service.dart';
import '../widgets/common_widgets.dart';
import 'package:provider/provider.dart';
import '../services/image_service.dart';
import '../providers/auth_provider.dart';
import 'payment_screen.dart';

class PhotoUploadScreen extends StatefulWidget {
  const PhotoUploadScreen({super.key});

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final List<File?> _photos = List.generate(6, (_) => null);
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  int get _photoCount => _photos.where((p) => p != null).length;

  Future<void> _pickImage(int index) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _photos[index] = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _photos[index] = null;
    });
  }

  Future<void> _continue() async {
    if (_photoCount < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload at least 2 photos to continue'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // Upload photos
      final filePaths = _photos.where((p) => p != null).map((p) => p!.path).toList();
      if (filePaths.isNotEmpty) {
        await ImageService().uploadMultipleImages(filePaths);
        // Refresh user data to get new photos
        if (mounted) {
           await context.read<AuthProvider>().checkAuth();
        }
      }
      
      if (!mounted) return;
      
      // Navigate to Payment
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PaymentScreen()),
      );
    } catch (e) {
      debugPrint('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photos. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _showResultDialog() async {
    // Check for matches (Pretend we did this during the animation)
    bool hasMatches = false;
    try {
      final matches = await MatchService().getPotentialMatches(limit: 1);
      if (matches.isNotEmpty) hasMatches = true;
    } catch (_) {}

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildResultDialog(hasMatches),
    );
  }

  Widget _buildResultDialog(bool hasMatches) {
     return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      backgroundColor: const Color(0xFFFFFBF5), // Warm background
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          constraints: const BoxConstraints(maxWidth: 400),
          child: hasMatches ? _buildMatchFoundContent() : _buildNoMatchContent(),
        ),
      ),
    );
  }
  
  Widget _buildMatchFoundContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96, height: 96,
          decoration: const BoxDecoration(
            color: SoulSyncColors.coral100,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 48, height: 48,
              decoration: const BoxDecoration(
                color: SoulSyncColors.coral500,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 28),
            ),
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(
          "It's a Match!",
          style: GoogleFonts.quicksand(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: SoulSyncColors.warm800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          "We found people who match your vibe based on your answers.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: SoulSyncColors.warm600,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        FriendlyButton(
          text: 'See My Soulmates',
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }

  Widget _buildNoMatchContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9A8B).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFF9A8B), // Soft coral
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.explore, color: Colors.white, size: 32),
          ),
        ).animate().fadeIn().slideY(begin: 0.2, end: 0),
        const SizedBox(height: 20),
        
        Text(
          "Oops! 😅",
          style: GoogleFonts.quicksand(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF5D4037),
          ),
        ),
        const SizedBox(height: 16),
         Text(
          "No potential matches found right now. Don't worry! We'll notify you when we find compatible matches based on your personality score.",
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: const Color(0xFF8D6E63),
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        
         // Tips Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFFCCBC).withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5D4037).withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Try these to boost your chances:",
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 12),
              _buildTipItem("Increase your personality score by answering a few more questions."),
              const SizedBox(height: 8),
              _buildTipItem("Update your profile with interests and a short bio."),
              const SizedBox(height: 8),
              _buildTipItem("Check back later as new users join throughout the day."),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        FriendlyButton(
          text: 'Answer more questions',
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
             // Note: In real app, we might want to navigate explicitly to quiz
             // For now popUntil root handles it if Quiz is root or accessible
          },
        ),
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              "Back to Dashboard",
               style: GoogleFonts.inter(
                color: const Color(0xFF5D4037),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 6, color: Color(0xFFA1887F)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: const Color(0xFF795548),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: SoulSyncColors.warm800),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Show us your best self",
                    style: GoogleFonts.quicksand(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: SoulSyncColors.warm800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Upload at least 2 photos to continue. Matches love to see who they're syncing with!",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF8D6E63),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Photo Grid
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
                children: List.generate(6, (index) {
                  final photo = _photos[index];
                  return GestureDetector(
                    onTap: () => photo == null ? _pickImage(index) : null,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: photo != null ? SoulSyncColors.coral500 : const Color(0xFFFFCCBC),
                          width: photo != null ? 2 : 1,
                        ),
                        boxShadow: [
                           BoxShadow(
                             color: const Color(0xFF5D4037).withOpacity(0.05),
                             blurRadius: 8,
                             offset: const Offset(0, 4),
                           )
                        ],
                      ),
                      child: photo != null
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(photo, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, size: 16, color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFF0EC),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add, color: SoulSyncColors.coral500),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Add Photo",
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: SoulSyncColors.coral400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                    ).animate().fadeIn(delay: (index * 100).ms).scale(duration: 300.ms),
                  );
                }),
              ),
            ),
            
            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: FriendlyButton(
                text: _isUploading ? 'Uploading...' : 'Continue to Quiz',
                onPressed: _isUploading ? null : _continue,
                color: _photoCount >= 2 ? SoulSyncColors.coral500 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Temporary Copy of AnalyzingOverlay for independence
// Ideally this should be a shared widget
class AnalyzingOverlay extends StatefulWidget {
  const AnalyzingOverlay({super.key});

  @override
  State<AnalyzingOverlay> createState() => _AnalyzingOverlayState();
}

class _AnalyzingOverlayState extends State<AnalyzingOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _step = 0;
  final List<String> _steps = [
    "Analyzing your personality profile...",
    "Processing emotional compatibility vectors...",
    "Scanning potential matches...",
    "Calculating relationship chemistry...",
  ];
  final List<IconData> _stepIcons = [Icons.psychology, Icons.favorite, Icons.people, Icons.bolt];
  final List<Color> _stepColors = [Color(0xFFF48FB1), Color(0xFFEF5350), Color(0xFFFFB74D), Color(0xFFFFF176)];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _controller.repeat();
    _startSequence();
  }
  
  void _startSequence() async {
    for (int i = 0; i < 4; i++) {
      if (!mounted) return;
      setState(() => _step = i);
      await Future.delayed(const Duration(milliseconds: 1200));
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5).withOpacity(0.95), // Translucent cream
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main Pulse Icon
              Container(
                width: 120, height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF81C784), Color(0xFFFF8A80)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))
                  ]
                ),
                child: Center(
                   child: const Icon(Icons.favorite, color: Colors.white, size: 50)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(1,1), end: const Offset(1.2,1.2), duration: 800.ms),
                ),
              ),
              const SizedBox(height: 40),
              
              Text(
                "SoulSyncing You Now...",
                style: GoogleFonts.quicksand(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3E2723), // Deep brown
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Your answers are being analyzed by our AI compatibility engine. We're finding someone who gets you. 💫",
                textAlign: TextAlign.center,
                 style: GoogleFonts.inter(color: const Color(0xFF795548), fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 48),

              // Steps List
              ...List.generate(_steps.length, (index) {
                final isActive = index == _step;
                final isPast = index < _step;
                
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (isActive) 
                        BoxShadow(color: _stepColors[index].withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isActive || isPast) ? _stepColors[index].withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _stepIcons[index],
                          color: (isActive || isPast) ? _stepColors[index] : Colors.grey.withOpacity(0.4),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _steps[index],
                          style: GoogleFonts.inter(
                            color: const Color(0xFF5D4037),
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isPast)
                        const Icon(Icons.check_circle, color: Colors.green, size: 20)
                      else if (isActive)
                        SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(_stepColors[index])),
                        )
                    ],
                  ),
                ).animate().fadeIn(delay: (index * 200).ms).slideX();
              }),

              const Spacer(),
              
              // Bottom Progress
              LinearProgressIndicator(
                value: (_step + 1) / 5, // Approximate progress
                backgroundColor: const Color(0xFFFFEBE8),
                valueColor: const AlwaysStoppedAnimation(Color(0xFFFF8A80)),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              Text(
                "${((_step + 1) / 5 * 100).toInt()}% Complete",
                style: GoogleFonts.inter(color: const Color(0xFFA1887F), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
