import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/theme.dart';
import '../services/question_service.dart';
import '../services/match_service.dart';
import '../models/question.dart';
import '../widgets/common_widgets.dart';


class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuestionService _questionService = QuestionService();
  List<Question> _questions = [];
  int _currentIndex = 0;
  bool _loading = true;
  String? _error;
  dynamic _selectedAnswer;

  /* final List<String> _categories = ['personality', 'compatibility', 'lifestyle', 'values', 'communication', 'relationship']; */
  final Map<String, String> _categoryEmojis = {
    'personality': '🧠', 'compatibility': '💕', 'lifestyle': '🌟',
    'values': '💎', 'communication': '💬', 'relationship': '❤️',
  };

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() { _loading = true; _error = null; });
    try {
      final questions = await _questionService.getRandomQuestions(10);
      setState(() { _questions = questions; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Failed to load questions'; _loading = false; });
    }
  }

  Future<void> _submitAnswer() async {
    if (_selectedAnswer == null || _currentIndex >= _questions.length) return;

    try {
      await _questionService.submitAnswer(
        questionId: _questions[_currentIndex].id,
        answer: _selectedAnswer,
      );
      bool isComplete = false;
      setState(() {
        _selectedAnswer = null;
        if (_currentIndex < _questions.length - 1) {
          _currentIndex++;
        } else {
          isComplete = true;
        }
      });
      
      if (isComplete) {
        if (!mounted) return;
        _showCompletionDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit answer'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showCompletionDialog() async {
    // 1. Show Analyzing Screen (Full Screen Overlay)
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) => const _AnalyzingOverlay(),
      ),
    );

    // Check for matches (Pretend we did this during the animation)
    bool hasMatches = false;
    try {
      final matches = await MatchService().getPotentialMatches(limit: 1);
      if (matches.isNotEmpty) hasMatches = true;
    } catch (_) {}

    if (!mounted) return;

    // 2. Show Result Dialog
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
            Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
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
            color: const Color(0xFFFF9A8B).withValues(alpha: 0.2),
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
            border: Border.all(color: const Color(0xFFFFCCBC).withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5D4037).withValues(alpha: 0.05),
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
            Navigator.pop(context); // Close dialog
            setState(() { _currentIndex = 0; });
            _loadQuestions();
          },
        ),
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
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
      backgroundColor: const Color(0xFFFFFBF5), // Warm beige
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with Nav and Progress
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: SoulSyncColors.warm800, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        _questions.isEmpty 
                            ? "Preparing Quiz..." 
                            : "Question ${_currentIndex + 1} of ${_questions.length}",
                        style: GoogleFonts.inter(
                          color: const Color(0xFFAA8F85),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 40), // Balance
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length,
                      backgroundColor: const Color(0xFFFFEBE8),
                      valueColor: const AlwaysStoppedAnimation(SoulSyncColors.coral400),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            if (_loading)
               const Expanded(child: Center(child: LoadingWidget(message: 'Curating questions...')))
            else if (_error != null)
               Expanded(child: Center(child: Text(_error!)))
            else if (_questions.isEmpty)
               const Expanded(child: Center(child: Text("All matched up!")))
            else
              Expanded(child: _buildQuestionContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    final question = _questions[_currentIndex];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Reduced outer padding
      child: Column(
        children: [
          // Main Question Card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20), // Reduced card padding
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24), // Slightly smaller radius
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5A3A3A).withValues(alpha: 0.05),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 56, height: 56, // Smaller icon container
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        _categoryEmojis[question.category] ?? '✨',
                        style: const TextStyle(fontSize: 28), // Smaller emoji
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Reduced spacing
                  
                  // Question Text
                  Text(
                    question.question,
                    style: GoogleFonts.quicksand(
                      fontSize: 18, // Slightly smaller font
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3E2723),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20), // Reduced spacing

                  // Answer Content (Expanded to take remaining space)
                  Expanded(
                    child: question.type == 'scale'
                        ? _buildScaleAnswer(question)
                        : question.type == 'multiple'
                            ? _buildMultipleChoice(question)
                            : _buildTextAnswer(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16), // Reduced spacing

          // Bottom Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentIndex > 0)
                TextButton(
                  onPressed: _previousQuestion,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    foregroundColor: SoulSyncColors.warm600,
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back, size: 18),
                      SizedBox(width: 8),
                      Text("Previous", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              else
                const SizedBox(width: 100), // Placeholder to keep Next button aligned

              ElevatedButton(
                onPressed: _selectedAnswer != null ? _submitAnswer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SoulSyncColors.coral200,
                  foregroundColor: const Color(0xFF8F4B41),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  children: [
                    Text(
                      _currentIndex == _questions.length - 1 ? "Finish" : "Next",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      if (mounted) {
         setState(() {
          _currentIndex--;
          _selectedAnswer = null; // Reset selection for re-answering or handle state persistence if needed
        });
      }
    }
  }

  Widget _buildScaleAnswer(Question question) {
    final min = question.minValue ?? 1;
    final max = question.maxValue ?? 10;
    final double value = (_selectedAnswer as num?)?.toDouble() ?? 5.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.toInt().toString(),
          style: GoogleFonts.quicksand(
            fontSize: 42, // Reduced from 48
            fontWeight: FontWeight.bold,
            color: SoulSyncColors.coral500,
          ),
        ),
        const SizedBox(height: 16), // Reduced from 24
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 10, // Reduced from 12
            activeTrackColor: SoulSyncColors.coral200,
            inactiveTrackColor: const Color(0xFFFFEBE8),
            thumbColor: SoulSyncColors.coral500,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12), // Reduced from 14
            overlayColor: SoulSyncColors.coral500.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: (max - min) > 0 ? (max - min) : 1,
            onChanged: (v) => setState(() => _selectedAnswer = v.round()),
          ),
        ),
        const SizedBox(height: 8), // Reduced from 12
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Low", style: GoogleFonts.inter(fontSize: 13, color: SoulSyncColors.warm600)), // Smaller font
            Text("High", style: GoogleFonts.inter(fontSize: 13, color: SoulSyncColors.warm600)),
          ],
        ),
      ],
    );
  }

  Widget _buildMultipleChoice(Question question) {
    // Check if we need scrolling strictly for the options list
    // We use ListView but with shrinkWrap if needed, but since it's in Expanded parent,
    // we can just let ListView fill the space.
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: (question.options as List).length,
      separatorBuilder: (_, __) => const SizedBox(height: 10), // Reduced separator height
      itemBuilder: (context, index) {
         final opt = (question.options as List)[index];
         Map optionMap = {};
         if (opt is Map) {
           optionMap = opt;
         } else {
           optionMap = {'label': opt.toString(), 'value': opt.toString()};
         }
         
         final displayText = optionMap['label'] ?? '';
         final answerValue = optionMap['value'];
         final isSelected = _selectedAnswer.toString() == answerValue.toString();
         
         // Auto-assign emoji based on index just for visual variety if none exists
         final List<String> defaultEmojis = ['🌟', '💡', '🔥', '💎', '🚀'];
         String emoji = defaultEmojis[index % defaultEmojis.length];

        return InkWell(
          onTap: () => setState(() => _selectedAnswer = answerValue),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Reduced internal padding
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF0EC) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? SoulSyncColors.coral500 : const Color(0xFFFFE0D5),
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.5) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 16)), // Slightly smaller emoji
                ),
                const SizedBox(width: 12), // Reduced spacing
                Expanded(
                  child: Text(
                    displayText,
                    style: GoogleFonts.inter(
                      color: isSelected ? const Color(0xFF5D4037) : const Color(0xFF795548),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14, // Slightly smaller font
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: SoulSyncColors.coral500, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextAnswer() {
    return Column(
      children: [
        FriendlyInput(
          hintText: 'Type your answer here...',
          maxLines: 5,
          onChanged: (v) => setState(() => _selectedAnswer = v.isNotEmpty ? v : null),
        ),
      ],
    );
  }
}

class _AnalyzingOverlay extends StatefulWidget {
  const _AnalyzingOverlay();

  @override
  State<_AnalyzingOverlay> createState() => _AnalyzingOverlayState();
}

class _AnalyzingOverlayState extends State<_AnalyzingOverlay> with SingleTickerProviderStateMixin {
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
      backgroundColor: const Color(0xFFFFFBF5).withValues(alpha: 0.95), // Translucent cream
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
                        BoxShadow(color: _stepColors[index].withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (isActive || isPast) ? _stepColors[index].withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _stepIcons[index],
                          color: (isActive || isPast) ? _stepColors[index] : Colors.grey.withValues(alpha: 0.4),
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
