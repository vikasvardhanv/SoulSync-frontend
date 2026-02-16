import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../services/match_service.dart';
import '../services/location_service.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final MatchService _matchService = MatchService();
  List<dynamic> _potentialMatches = [];
  int _currentMatchIndex = 0;
  bool _loadingMatches = true;

  @override
  void initState() {
    super.initState();
    _loadPotentialMatches();
    
    // Initialize Location Service
    LocationService().init();
    
    // Refresh user data (scores, etc.) whenever Dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkAuth();
    });
    
    // Connect socket if not connected (failsafe)
    final socketService = context.read<AuthProvider>().socketService;
    if (!socketService.isConnected) {
      socketService.connect();
    }
    
    // Listen for new matches/messages
    socketService.onMessageReceived((data) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('New message from ${data['senderName'] ?? 'someone'}!'),
            action: SnackBarAction(label: 'View', onPressed: () => setState(() => _currentIndex = 2)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: SoulSyncColors.coral500,
          ),
        );
      }
    });
  }

  Future<void> _loadPotentialMatches() async {
    try {
      final matches = await _matchService.getPotentialMatches(limit: 20);
      if (mounted) setState(() { _potentialMatches = matches; _loadingMatches = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingMatches = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _buildDiscoverTab(),
              _buildMatchesTab(),
              _buildMessagesTab(),
              _buildProfileTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Matches'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverTab() {
    final user = context.watch<AuthProvider>().user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: SoulSyncColors.coralGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hi, ${user?.name ?? 'there'} 👋', style: Theme.of(context).textTheme.headlineMedium),
                    Text("Let's find your soul match", style: TextStyle(color: SoulSyncColors.warm600, fontSize: 14)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: SoulSyncColors.warm700),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: SoulSyncColors.warm700),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 20),

          // Quick Stats
          Row(
            children: [
              _statCard('🧠', 'Personality', '${user?.personalityScore ?? 0}%', SoulSyncColors.softLavender),
              const SizedBox(width: 10),
              _statCard('📝', 'Questions', '${user?.questionsAnswered ?? 0}', SoulSyncColors.gentleMint),
              const SizedBox(width: 10),
              _statCard('💎', 'Status', user?.hasPremium == true ? 'Premium' : 'Free', SoulSyncColors.warmGold),
            ],
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _actionButton(Icons.quiz, 'Take Quiz', SoulSyncColors.gentleMint, () {
                  Navigator.pushNamed(context, '/quiz').then((_) => _loadPotentialMatches());
                }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _actionButton(Icons.workspace_premium, 'Go Premium', SoulSyncColors.warmGold, () => Navigator.pushNamed(context, '/payment')),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 24),

          // Discover section
          Text('Discover Matches', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),

          if (_loadingMatches)
            const Center(child: LoadingWidget(message: 'Finding matches...'))
          else if (_potentialMatches.isEmpty)
            FriendlyCard(
              child: Column(
                children: [
                  const Icon(Icons.people, size: 48, color: SoulSyncColors.coral400),
                  const SizedBox(height: 12),
                  Text('No matches yet', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Complete your profile and take the quiz to discover compatible matches!',
                    style: TextStyle(color: SoulSyncColors.warm600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FriendlyButton(
                    text: 'Take Personality Quiz',
                    onPressed: () => Navigator.pushNamed(context, '/quiz'),
                    fullWidth: false,
                  ),
                ],
              ),
            )
          else
            _buildMatchCard(),
        ],
      ),
    );
  }

  Widget _buildMatchCard() {
    if (_currentMatchIndex >= _potentialMatches.length) {
      return FriendlyCard(
        child: Column(
          children: [
            const Icon(Icons.check_circle, size: 48, color: SoulSyncColors.mint500),
            const SizedBox(height: 12),
            Text("You've seen everyone!", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Check back later for new matches', style: TextStyle(color: SoulSyncColors.warm600)),
            const SizedBox(height: 16),
            FriendlyButton(
              text: 'Refresh',
              onPressed: () {
                setState(() { _currentMatchIndex = 0; _loadingMatches = true; });
                _loadPotentialMatches();
              },
              fullWidth: false,
            ),
          ],
        ),
      );
    }

    final match = _potentialMatches[_currentMatchIndex];
    final name = match['name'] ?? 'Someone';
    final age = match['age']?.toString() ?? '';
    final bio = match['bio'] ?? '';
    final location = match['location'] ?? '';
    final photos = List<String>.from(match['photos'] ?? []);
    final interests = List<String>.from(match['interests'] ?? []);
    final score = match['compatibilityScore'];

    return FriendlyCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: photos.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photos.first,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 300,
                      color: SoulSyncColors.warmBeige,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  )
                : Container(
                    height: 300,
                    color: SoulSyncColors.warmBeige,
                    child: const Center(child: Icon(Icons.person, size: 80, color: SoulSyncColors.warm600)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$name${age.isNotEmpty ? ', $age' : ''}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    if (score != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: SoulSyncColors.coralGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('$score%', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: SoulSyncColors.coral400),
                    const SizedBox(width: 4),
                    Text(location, style: TextStyle(color: SoulSyncColors.warm600, fontSize: 14)),
                  ]),
                ],
                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(bio, style: TextStyle(color: SoulSyncColors.textSecondary, fontSize: 14), maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
                if (interests.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: interests.take(5).map((i) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: SoulSyncColors.coral50, borderRadius: BorderRadius.circular(12)),
                      child: Text(i, style: TextStyle(color: SoulSyncColors.coral700, fontSize: 12)),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _roundButton(Icons.close, Colors.red.shade300, () {
                      setState(() => _currentMatchIndex++);
                    }),
                    const SizedBox(width: 24),
                    _roundButton(Icons.favorite, SoulSyncColors.coral500, () async {
                      final id = match['id'];
                      if (id != null) {
                        try {
                          await _matchService.createMatch(matchedUserId: id, compatibilityScore: (score ?? 50).toDouble());
                        } catch (_) {}
                      }
                      setState(() => _currentMatchIndex++);
                    }, large: true),
                    const SizedBox(width: 24),
                    _roundButton(Icons.star, SoulSyncColors.warmGold, () {
                      Navigator.pushNamed(context, '/payment');
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05, duration: 300.ms);
  }

  Widget _roundButton(IconData icon, Color color, VoidCallback onTap, {bool large = false}) {
    final size = large ? 64.0 : 48.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Icon(icon, color: color, size: large ? 32 : 24),
      ),
    );
  }

  Widget _buildMatchesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Matches', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 8),
          Text('People who like you back', style: TextStyle(color: SoulSyncColors.warm600)),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List>(
              future: _matchService.getAcceptedMatches(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Loading matches...');
                }
                final matches = snapshot.data ?? [];
                if (matches.isEmpty) {
                  return Center(
                    child: FriendlyCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite_border, size: 48, color: SoulSyncColors.peach400),
                          const SizedBox(height: 12),
                          Text('No matches yet', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text('Start swiping to find your match!', style: TextStyle(color: SoulSyncColors.warm600)),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final m = matches[index];
                    final otherUser = m.userReceiver ?? m.userInitiator;
                    return FriendlyCard(
                      padding: const EdgeInsets.all(12),
                      onTap: () {
                        if (otherUser != null) {
                          Navigator.pushNamed(context, '/chat', arguments: {'userId': otherUser.id, 'name': otherUser.name});
                        }
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: SoulSyncColors.coral200,
                            child: otherUser?.photos.isNotEmpty == true
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: CachedNetworkImage(imageUrl: otherUser!.photos.first, width: 56, height: 56, fit: BoxFit.cover),
                                  )
                                : Text(otherUser?.name[0].toUpperCase() ?? '?', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(otherUser?.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                if (m.compatibilityScore != null)
                                  Text('${m.compatibilityScore}% compatible', style: TextStyle(color: SoulSyncColors.coral500, fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chat_bubble_outline, color: SoulSyncColors.coral400),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Messages', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 8),
          Text('Chat with your matches', style: TextStyle(color: SoulSyncColors.warm600)),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List>(
              future: _loadConversations(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Loading conversations...');
                }
                final convos = snapshot.data ?? [];
                if (convos.isEmpty) {
                  return Center(
                    child: FriendlyCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 48, color: SoulSyncColors.softSky),
                          const SizedBox(height: 12),
                          Text('No messages yet', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text('Match with someone to start chatting!', style: TextStyle(color: SoulSyncColors.warm600)),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: convos.length,
                  itemBuilder: (context, index) {
                    final convo = convos[index];
                    return _conversationTile(convo);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List> _loadConversations() async {
    try {
      // final service = MessageService();
      // For now we return empty as backend might not have data
      // In real app: return await service.getConversations();
      return [];
    } catch (_) {
      return [];
    }
  }

  Widget _conversationTile(dynamic convo) {
    return FriendlyCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundColor: SoulSyncColors.softSky, child: const Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chat', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('Tap to chat', style: TextStyle(color: SoulSyncColors.warm600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final user = context.watch<AuthProvider>().user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile header
          FriendlyCard(
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: SoulSyncColors.coralGradient,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: SoulSyncColors.softCoral.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: user?.photos.isNotEmpty == true
                      ? ClipRRect(borderRadius: BorderRadius.circular(48), child: CachedNetworkImage(imageUrl: user!.photos.first, fit: BoxFit.cover))
                      : Center(child: Text(user?.name[0].toUpperCase() ?? '?', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? '', style: Theme.of(context).textTheme.headlineLarge),
                if (user?.age != null) Text('${user!.age} years old', style: TextStyle(color: SoulSyncColors.warm600)),
                if (user?.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16, color: SoulSyncColors.coral400),
                      Text(user!.location!, style: TextStyle(color: SoulSyncColors.warm600, fontSize: 14)),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _profileStat('🧠', '${user?.personalityScore ?? 0}%', 'Personality'),
                    _profileStat('📝', '${user?.questionsAnswered ?? 0}', 'Answers'),
                    _profileStat('💎', user?.hasPremium == true ? 'Yes' : 'No', 'Premium'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action buttons
          FriendlyCard(
            child: Column(
              children: [
                _profileAction(Icons.edit, 'Edit Profile', () => Navigator.pushNamed(context, '/profile')),
                const Divider(),
                _profileAction(Icons.quiz, 'Personality Quiz', () => Navigator.pushNamed(context, '/quiz')),
                const Divider(),
                _profileAction(Icons.workspace_premium, 'Premium', () => Navigator.pushNamed(context, '/payment')),
                const Divider(),
                _profileAction(Icons.settings, 'Settings', () => Navigator.pushNamed(context, '/settings')),
                const Divider(),
                _profileAction(Icons.logout, 'Sign Out', () async {
                  await context.read<AuthProvider>().signOut();
                  if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
                }, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: SoulSyncColors.warm800)),
        Text(label, style: TextStyle(color: SoulSyncColors.warm600, fontSize: 12)),
      ],
    );
  }

  Widget _profileAction(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? SoulSyncColors.coral500),
      title: Text(title, style: TextStyle(color: color ?? SoulSyncColors.warm800, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right, color: color ?? SoulSyncColors.warm600),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _statCard(String emoji, String label, String value, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: bgColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: SoulSyncColors.warm800, fontSize: 14)),
            Text(label, style: TextStyle(color: SoulSyncColors.warm600, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: SoulSyncColors.warm800, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
