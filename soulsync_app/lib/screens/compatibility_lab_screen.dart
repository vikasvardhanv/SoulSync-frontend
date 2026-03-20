import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/common_widgets.dart';
import '../services/compatibility_service.dart';

class CompatibilityLabScreen extends StatefulWidget {
  const CompatibilityLabScreen({super.key});

  @override
  State<CompatibilityLabScreen> createState() => _CompatibilityLabScreenState();
}

class _CompatibilityLabScreenState extends State<CompatibilityLabScreen> {
  final Map<String, String> _nonNegotiables = {
    'Respectful communication only': 'dealbreaker',
    'Honest long-term intentions': 'dealbreaker',
    'No smoking': 'preference',
    'Emotionally available': 'dealbreaker',
    'Wants children': 'preference',
    'No drug use': 'dealbreaker',
    'Financially stable': 'preference',
    'Similar life goals': 'dealbreaker',
  };

  final List<String> _selectedBoundaries = [];
  final Map<String, bool> _boundaryConflicts = {};
  int _partnerSimulatedBoundaries = 3;

  final List<_SprintTask> _sprintTasks = [
    _SprintTask(
      day: 'Day 1',
      title: 'Values Check-in',
      prompt: 'Share 3 life priorities and why they matter now.',
    ),
    _SprintTask(
      day: 'Day 2',
      title: 'Conflict Simulation',
      prompt: 'Discuss a small disagreement and how you resolve it.',
    ),
    _SprintTask(
      day: 'Day 3',
      title: 'Planning Style',
      prompt: 'Plan a weekend together with budget and priorities.',
    ),
    _SprintTask(
      day: 'Day 4',
      title: 'Pace Alignment',
      prompt: 'Align expectations for communication frequency.',
    ),
    _SprintTask(
      day: 'Day 5',
      title: 'Support Mapping',
      prompt: 'How do you each want support during stressful weeks?',
    ),
    _SprintTask(
      day: 'Day 6',
      title: 'Lifestyle Reality',
      prompt: 'Compare routines: sleep, food, social life, finances.',
    ),
    _SprintTask(
      day: 'Day 7',
      title: 'Decision Debrief',
      prompt: 'Summarize fit, friction points, and next-step decision.',
    ),
  ];

  int get _completedTasks => _sprintTasks.where((task) => task.completed).length;

  double _safeRatio(num numerator, num denominator) {
    if (denominator == 0) return 0.0;
    final value = (numerator / denominator).toDouble();
    if (!value.isFinite || value.isNaN) return 0.0;
    return value.clamp(0.0, 1.0).toDouble();
  }

  @override
  void initState() {
    super.initState();
    _selectedBoundaries.addAll(_nonNegotiables.keys.take(2));
    _simulatePartnerBoundaries();
  }

  void _simulatePartnerBoundaries() {
    // Simulate realistic boundary conflicts
    final myDealbreakers = _selectedBoundaries.where((b) => _nonNegotiables[b] == 'dealbreaker').toList();
    if (myDealbreakers.length >= 2) {
      _boundaryConflicts[myDealbreakers.first] = true; // conflict
    }
  }

  double _calculateBoundaryAlignment() {
    if (_selectedBoundaries.isEmpty) return 0;
    final conflicts = _boundaryConflicts.values.where((c) => c).length;
    final dealbreakers = _selectedBoundaries.where((b) => _nonNegotiables[b] == 'dealbreaker').length;
    return ((dealbreakers - conflicts) / dealbreakers.clamp(1, 100) * 100).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Compatibility Lab', style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 4),
              Text(
                'Before moving forward, run a 7-day compatibility sprint.',
                style: TextStyle(color: SoulSyncColors.warm600, fontSize: 14),
              ),
              const SizedBox(height: 20),
              
              // Step indicator
              _buildStepIndicator(context),
              const SizedBox(height: 20),
              
              _buildBoundaryCard(context),
              const SizedBox(height: 12),
              _buildSprintCard(context),
              const SizedBox(height: 12),
              _buildDebriefCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoundaryCard(BuildContext context) {
    return FriendlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: SoulSyncColors.coral500),
              const SizedBox(width: 8),
              Text('Step 1: Select Your Boundaries', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Pick what you need in a partner before doing the 7-day sprint.',
            style: TextStyle(color: SoulSyncColors.warm600, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _nonNegotiables.entries.take(6).map((entry) {
              final item = entry.key;
              final type = entry.value;
              final isSelected = _selectedBoundaries.contains(item);
              final hasConflict = _boundaryConflicts[item] == true;
              return FilterChip(
                label: Text(item, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                selectedColor: hasConflict ? Colors.red.shade100 : SoulSyncColors.coral200,
                checkmarkColor: hasConflict ? Colors.red : SoulSyncColors.coral700,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedBoundaries.add(item);
                      if (type == 'dealbreaker' && _selectedBoundaries.length > 3) {
                        _boundaryConflicts[item] = DateTime.now().second % 2 == 0;
                      }
                    } else {
                      _selectedBoundaries.remove(item);
                      _boundaryConflicts.remove(item);
                    }
                    _simulatePartnerBoundaries();
                  });
                },
              );
            }).toList(),
          ),
          if (_selectedBoundaries.isEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Start by selecting at least 2 boundaries.',
                      style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final step1Done = _selectedBoundaries.isNotEmpty;
    final step2Done = _completedTasks >= 3;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _step('1', 'Boundaries', step1Done),
        Container(
          height: 2,
          width: 30,
          color: step1Done ? SoulSyncColors.coral500 : Colors.grey.shade300,
        ),
        _step('2', '7-Day Sprint', step2Done),
        Container(
          height: 2,
          width: 30,
          color: step2Done ? SoulSyncColors.coral500 : Colors.grey.shade300,
        ),
        _step('3', 'AI Analysis', false),
      ],
    );
  }

  Widget _step(String number, String label, bool completed) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed ? SoulSyncColors.coral500 : Colors.grey.shade300,
          ),
          child: Center(
            child: Text(
              completed ? '✓' : number,
              style: TextStyle(
                color: completed ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    maxLines: 1, overflow: TextOverflow.ellipsis)
      ],
    );
  }

  List<Map<String, String>> _generateActionItems(String riskLevel, List<String> boundaries, int tasksCompleted) {
    final items = <Map<String, String>>[];

    if (riskLevel == 'High') {
      items.add({
        'icon': '⚠️',
        'text': 'Have a direct conversation about these ${_boundaryConflicts.values.where((c) => c).length} conflicts before proceeding.'
      });
      items.add({
        'icon': '🤔',
        'text': 'Ask: "Can you help me understand your position on [conflict area]?" Listen without judgment.'
      });
      items.add({
        'icon': '✋',
        'text': 'If conflicts are unchangeable (e.g., wanting kids), consider ending things now before deeper investment.'
      });
    } else if (riskLevel == 'Medium') {
      items.add({
        'icon': '📋',
        'text': 'Complete the remaining sprint tasks to gather more behavioral data.'
      });
      items.add({
        'icon': '💬',
        'text': 'Bring up your ${boundaries.length} dealbreakers explicitly in conversation.'
      });
      items.add({
        'icon': '⏰',
        'text': 'Give it 2 more days of interaction before making a big decision.'
      });
    } else {
      // Low risk
      items.add({
        'icon': '✅',
        'text': 'Strong compatibility signals. Consider scheduling a video or in-person meeting.'
      });
      items.add({
        'icon': '🎯',
        'text': 'Share your findings with your match and see if they\'re equally interested.'
      });
      items.add({
        'icon': '🚀',
        'text': 'Take the next step: extended conversation, exchange contact, or plan a date.'
      });
    }

    return items;
  }

  Widget _buildSprintCard(BuildContext context) {
    final progress = _safeRatio(_completedTasks, _sprintTasks.length);

    return FriendlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, color: SoulSyncColors.mint500),
              const SizedBox(width: 8),
              Text('Step 2: Daily Check-ins', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Over 7 days, discuss how you handle key situations together.',
            style: TextStyle(color: SoulSyncColors.warm600, fontSize: 13),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: SoulSyncColors.coral100,
            valueColor: const AlwaysStoppedAnimation<Color>(SoulSyncColors.coral500),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text('$_completedTasks of 7 days', style: TextStyle(color: SoulSyncColors.warm700, fontSize: 12)),
          ),
          const SizedBox(height: 12),
          ..._sprintTasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            final canDo = index <= _completedTasks;
            return Opacity(
              opacity: canDo ? 1.0 : 0.5,
              child: CheckboxListTile(
                value: task.completed,
                activeColor: SoulSyncColors.coral500,
                contentPadding: EdgeInsets.zero,
                enabled: canDo,
                title: Text(
                  task.title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                subtitle: Text(
                  task.prompt,
                  style: TextStyle(color: SoulSyncColors.warm600, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onChanged: canDo ? (value) {
                  setState(() => task.completed = value ?? false);
                } : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDebriefCard(BuildContext context) {
    final boundaryAlignment = _calculateBoundaryAlignment();
    final sprintProgress = _safeRatio(_completedTasks, _sprintTasks.length);
    final boundaryWeight = _safeRatio(_selectedBoundaries.length, _nonNegotiables.length);
    final readinessScore = (
      (boundaryAlignment * 0.4) + 
      (sprintProgress * 100 * 0.5) + 
      (boundaryWeight * 100 * 0.1)
    ).round().clamp(0, 99);

    return FriendlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: SoulSyncColors.warmGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Step 3: AI Analysis', style: Theme.of(context).textTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'After 3+ days, get a personalized fit report.',
            style: TextStyle(color: SoulSyncColors.warm600, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SoulSyncColors.coral50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SoulSyncColors.coral100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your readiness score', style: TextStyle(color: SoulSyncColors.warm600, fontSize: 12)),
                const SizedBox(height: 4),
                Text('$readinessScore%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: SoulSyncColors.coral500)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FriendlyButton(
              text: _completedTasks >= 3 ? 'Get AI Analysis' : 'Complete ${3 - _completedTasks} More',
              icon: _completedTasks >= 3 ? Icons.auto_awesome : Icons.lock_outline,
              onPressed: _completedTasks >= 3 ? () {
                final analysis = CompatibilityService.analyzeCompatibility(
                  sprintTasksCompleted: _completedTasks,
                  boundaries: _selectedBoundaries,
                  conflicts: _boundaryConflicts,
                );
                
                showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(
                          analysis['riskLevel'] == 'High' ? Icons.warning_amber : Icons.psychology,
                          color: analysis['riskLevel'] == 'High' ? Colors.orange : SoulSyncColors.coral500,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'AI Analysis',
                            style: const TextStyle(fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Risk indicator
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: analysis['riskLevel'] == 'High'
                                ? Colors.red.shade50
                                : analysis['riskLevel'] == 'Medium'
                                ? Colors.orange.shade50
                                : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: analysis['riskLevel'] == 'High'
                                  ? Colors.red.shade200
                                  : analysis['riskLevel'] == 'Medium'
                                  ? Colors.orange.shade200
                                  : Colors.green.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  analysis['riskLevel'] == 'Low' ? Icons.check_circle : Icons.info,
                                  color: analysis['riskLevel'] == 'High'
                                    ? Colors.red.shade700
                                    : analysis['riskLevel'] == 'Medium'
                                    ? Colors.orange.shade700
                                    : Colors.green.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Risk: ${analysis['riskLevel']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: analysis['riskLevel'] == 'High'
                                        ? Colors.red.shade700
                                        : analysis['riskLevel'] == 'Medium'
                                        ? Colors.orange.shade700
                                        : Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Main recommendation
                          Text(
                            'Summary',
                            style: TextStyle(fontWeight: FontWeight.bold, color: SoulSyncColors.warm800, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            analysis['recommendation'],
                            style: TextStyle(color: SoulSyncColors.warm700, height: 1.5, fontSize: 12),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Action items / Next steps
                          Text(
                            'Your Next Steps',
                            style: TextStyle(fontWeight: FontWeight.bold, color: SoulSyncColors.warm800, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          ..._generateActionItems(analysis['riskLevel'] as String, _selectedBoundaries, _completedTasks).map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['icon'] ?? '',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      item['text'] ?? '',
                                      style: TextStyle(color: SoulSyncColors.warm700, fontSize: 12, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Key insights
                          if ((analysis['insights'] as List<String>?)?.isNotEmpty ?? false) ...[
                            Text(
                              'Key Insights',
                              style: TextStyle(fontWeight: FontWeight.bold, color: SoulSyncColors.warm800, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            ...(analysis['insights'] as List<String>).map(
                              (insight) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  insight,
                                  style: TextStyle(color: SoulSyncColors.warm700, fontSize: 12, height: 1.4),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              } : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _SprintTask {
  _SprintTask({required this.day, required this.title, required this.prompt});

  final String day;
  final String title;
  final String prompt;
  bool completed = false;
}
