import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/boundary_service.dart';
import '../widgets/common_widgets.dart';

class BoundariesScreen extends StatefulWidget {
  const BoundariesScreen({super.key});

  @override
  State<BoundariesScreen> createState() => _BoundariesScreenState();
}

class _BoundariesScreenState extends State<BoundariesScreen> {
  final BoundaryService _boundaryService = BoundaryService();
  final TextEditingController _dealBreakerController = TextEditingController();
  final TextEditingController _mustHaveController = TextEditingController();
  final TextEditingController _minAgeController = TextEditingController();
  final TextEditingController _maxAgeController = TextEditingController();
  final TextEditingController _maxDistanceController = TextEditingController();

  List<String> _dealBreakers = [];
  List<String> _mustHaves = [];
  String _preferredGender = 'everyone';
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBoundaries();
  }

  @override
  void dispose() {
    _dealBreakerController.dispose();
    _mustHaveController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _maxDistanceController.dispose();
    super.dispose();
  }

  Future<void> _loadBoundaries() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _boundaryService.getBoundaries();
      final boundaries = _extractBoundaries(response);

      setState(() {
        _dealBreakers = _normalizeStringList(boundaries['dealBreakers']);
        _mustHaves = _normalizeStringList(boundaries['mustHaves']);
        _preferredGender = _normalizePreferredGender(
          boundaries['preferredGender'],
        );
        _minAgeController.text = _intToText(boundaries['minAge']);
        _maxAgeController.text = _intToText(boundaries['maxAge']);
        _maxDistanceController.text = _intToText(boundaries['maxDistance']);
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load boundaries. Please try again.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _saveBoundaries() async {
    final minAgeText = _minAgeController.text.trim();
    final maxAgeText = _maxAgeController.text.trim();
    final maxDistanceText = _maxDistanceController.text.trim();

    final minAge = minAgeText.isEmpty ? null : int.tryParse(minAgeText);
    final maxAge = maxAgeText.isEmpty ? null : int.tryParse(maxAgeText);
    final maxDistance =
        maxDistanceText.isEmpty ? null : int.tryParse(maxDistanceText);

    if ((minAgeText.isNotEmpty && minAge == null) ||
        (maxAgeText.isNotEmpty && maxAge == null) ||
        (maxDistanceText.isNotEmpty && maxDistance == null)) {
      _showErrorSnack('Use valid numeric values for age and distance.');
      return;
    }

    if (minAge != null && minAge < 18) {
      _showErrorSnack('Minimum age must be at least 18.');
      return;
    }

    if (maxAge != null && maxAge > 100) {
      _showErrorSnack('Maximum age cannot be greater than 100.');
      return;
    }

    if (minAge != null && maxAge != null && minAge > maxAge) {
      _showErrorSnack('Minimum age cannot be greater than maximum age.');
      return;
    }

    if (maxDistance != null && maxDistance < 1) {
      _showErrorSnack('Distance must be at least 1 km.');
      return;
    }

    setState(() => _saving = true);
    try {
      await _boundaryService.updateBoundaries(
        dealBreakers: _dealBreakers,
        mustHaves: _mustHaves,
        minAge: minAge,
        maxAge: maxAge,
        maxDistance: maxDistance,
        preferredGender: _preferredGender,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Boundary preferences updated'),
            backgroundColor: SoulSyncColors.mint500,
          ),
        );
      }
    } catch (_) {
      _showErrorSnack('Failed to save boundaries. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _addBoundary(TextEditingController controller, List<String> target) {
    final value = controller.text.trim();
    if (value.isEmpty) return;

    if (target.length >= 25) {
      _showErrorSnack('You can add up to 25 items in each list.');
      return;
    }

    final normalized = value.toLowerCase();
    final exists = target.any((item) => item.toLowerCase() == normalized);
    if (exists) {
      _showErrorSnack('This item is already added.');
      return;
    }

    setState(() {
      target.add(value);
      controller.clear();
    });
  }

  void _removeBoundary(List<String> target, int index) {
    setState(() => target.removeAt(index));
  }

  void _showErrorSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Map<String, dynamic> _extractBoundaries(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      final boundaries = data['boundaries'];
      if (boundaries is Map<String, dynamic>) return boundaries;
      if (boundaries is Map) return Map<String, dynamic>.from(boundaries);
    }

    final boundaries = response['boundaries'];
    if (boundaries is Map<String, dynamic>) return boundaries;
    if (boundaries is Map) return Map<String, dynamic>.from(boundaries);

    return {};
  }

  List<String> _normalizeStringList(dynamic value) {
    if (value is List) {
      return value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [];
  }

  String _normalizePreferredGender(dynamic value) {
    if (value is String) {
      const allowed = {'male', 'female', 'non-binary', 'everyone'};
      return allowed.contains(value) ? value : 'everyone';
    }
    return 'everyone';
  }

  String _intToText(dynamic value) {
    if (value is int) return value.toString();
    if (value is num) return value.toInt().toString();
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: SoulSyncColors.warm700,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Boundaries',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: SoulSyncColors.warm700,
                      ),
                      onPressed: _loading ? null : _loadBoundaries,
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    _loading
                        ? const LoadingWidget(
                          message: 'Loading your boundaries...',
                        )
                        : SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              if (_error != null) ...[
                                FriendlyCard(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _error!,
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              FriendlyCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Match Filters',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'These values are stored as structured profile preferences for matching.',
                                      style: TextStyle(
                                        color: SoulSyncColors.warm600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: FriendlyInput(
                                            hintText: 'Min age',
                                            controller: _minAgeController,
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: FriendlyInput(
                                            hintText: 'Max age',
                                            controller: _maxAgeController,
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    FriendlyInput(
                                      hintText: 'Max distance (km)',
                                      controller: _maxDistanceController,
                                      keyboardType: TextInputType.number,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Preferred gender',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        _genderChip('everyone', 'Everyone'),
                                        _genderChip('male', 'Men'),
                                        _genderChip('female', 'Women'),
                                        _genderChip('non-binary', 'Non-binary'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildBoundaryCard(
                                title: 'Deal Breakers',
                                subtitle:
                                    'Hard boundaries that should strongly filter potential matches.',
                                controller: _dealBreakerController,
                                items: _dealBreakers,
                                addAction:
                                    () => _addBoundary(
                                      _dealBreakerController,
                                      _dealBreakers,
                                    ),
                                removeAction:
                                    (index) =>
                                        _removeBoundary(_dealBreakers, index),
                                color: Colors.red,
                              ),
                              const SizedBox(height: 12),
                              _buildBoundaryCard(
                                title: 'Must-Haves',
                                subtitle:
                                    'Positive requirements that increase compatibility and fit.',
                                controller: _mustHaveController,
                                items: _mustHaves,
                                addAction:
                                    () => _addBoundary(
                                      _mustHaveController,
                                      _mustHaves,
                                    ),
                                removeAction:
                                    (index) =>
                                        _removeBoundary(_mustHaves, index),
                                color: SoulSyncColors.mint500,
                              ),
                              const SizedBox(height: 16),
                              FriendlyButton(
                                text: 'Save Boundaries',
                                onPressed: _saving ? null : _saveBoundaries,
                                isLoading: _saving,
                              ),
                              const SizedBox(height: 24),
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

  Widget _genderChip(String value, String label) {
    final selected = _preferredGender == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: SoulSyncColors.coral200,
      onSelected: (_) => setState(() => _preferredGender = value),
      labelStyle: TextStyle(
        color: selected ? SoulSyncColors.coral700 : SoulSyncColors.warm700,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildBoundaryCard({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required List<String> items,
    required VoidCallback addAction,
    required void Function(int index) removeAction,
    required Color color,
  }) {
    return FriendlyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: SoulSyncColors.warm600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FriendlyInput(
                  hintText: 'Add item',
                  controller: controller,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: addAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Text(
              'No items added yet.',
              style: TextStyle(color: SoulSyncColors.warm600),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  items.asMap().entries.map((entry) {
                    return InputChip(
                      label: Text(entry.value),
                      backgroundColor: color.withValues(alpha: 0.12),
                      deleteIconColor: color,
                      onDeleted: () => removeAction(entry.key),
                    );
                  }).toList(),
            ),
          const SizedBox(height: 6),
          Text(
            '${items.length}/25',
            style: TextStyle(color: SoulSyncColors.warm600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
