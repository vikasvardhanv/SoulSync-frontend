import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/message.dart';
import '../services/message_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessageService _messageService = MessageService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _userId;
  String? _userName;

  @override
  void initState() {
    super.initState();
    // Listen for new messages via socket
    final socketService = context.read<AuthProvider>().socketService;
    socketService.onMessageReceived(_handleNewMessage);
  }

  void _handleNewMessage(dynamic data) {
    // Check if message belongs to this conversation
    final senderId = data['senderId'];
    final receiverId = data['receiverId'];
    
    // Refresh only if message is related to current chat user
    if (senderId == _userId || (senderId == context.read<AuthProvider>().user?.id && receiverId == _userId)) {
       // Ideally append to list to avoid full refresh, but loadMessages is safer for sync
       _loadMessages(); 
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _userId == null) {
      _userId = args['userId'] as String;
      _userName = args['name'] as String?;
      _loadMessages();
      
      // Join chat room if applicable (optional, depends on backend logic)
      final socketService = context.read<AuthProvider>().socketService;
      // socketService.joinChat(matchId); // If we had matchId
    }
  }
  
  @override
  void dispose() {
    final socketService = context.read<AuthProvider>().socketService;
    socketService.offMessageReceived(_handleNewMessage);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (_userId == null) return;
    try {
      final messages = await _messageService.getConversation(_userId!, limit: 50);
      if (mounted) {
        setState(() { _messages = messages.reversed.toList(); _loading = false; });
        _scrollToBottom();
        _messageService.markAsRead(_userId!);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _userId == null || _sending) return;

    setState(() => _sending = true);
    _messageController.clear();

    try {
      final message = await _messageService.sendMessage(receiverId: _userId!, content: text);
      if (message != null && mounted) {
        setState(() { _messages.add(message); _sending = false; });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().user?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: SoulSyncColors.warm700),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(gradient: SoulSyncColors.coralGradient, shape: BoxShape.circle),
              child: Center(child: Text(_userName?[0].toUpperCase() ?? '?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 10),
            Text(_userName ?? 'Chat', style: TextStyle(color: SoulSyncColors.warm800, fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: GradientBackground(
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: _loading
                  ? const LoadingWidget(message: 'Loading messages...')
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chat_bubble_outline, size: 48, color: SoulSyncColors.coral200),
                              const SizedBox(height: 12),
                              Text('Say hello to ${_userName ?? 'your match'}! 👋',
                                style: TextStyle(color: SoulSyncColors.warm600, fontSize: 16)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final msg = _messages[index];
                            final isMe = msg.senderId == currentUserId;
                            return _buildMessageBubble(msg, isMe);
                          },
                        ),
            ),

            // Input area
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: SoulSyncColors.warmCream,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            hintStyle: TextStyle(color: SoulSyncColors.textMuted),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(gradient: SoulSyncColors.coralGradient, shape: BoxShape.circle),
                        child: Icon(_sending ? Icons.hourglass_empty : Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message msg, bool isMe) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 8,
        left: isMe ? 48 : 0,
        right: isMe ? 0 : 48,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: isMe ? SoulSyncColors.coralGradient : null,
            color: isMe ? null : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
              bottomRight: isMe ? Radius.zero : const Radius.circular(16),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: Text(
            msg.content,
            style: TextStyle(
              color: isMe ? Colors.white : SoulSyncColors.warm800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
