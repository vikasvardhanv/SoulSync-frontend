
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';
import 'storage_service.dart';
import 'auth_service.dart';

class SocketService extends ChangeNotifier {
  IO.Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnected) return;

    final token = await StorageService.getAccessToken();
    if (token == null) return;

    // Get base URL without /api suffix
    String baseUrl = ApiConfig.baseUrl;
    if (baseUrl.endsWith('/api')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 4);
    }
    
    print('🔌 Connecting to socket at $baseUrl');

    _socket = IO.io(baseUrl, IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .setExtraHeaders({'Authorization': token})
        .build());

    _socket!.onConnect((_) async {
      print('✅ Connected to Socket.IO');
      _isConnected = true;
      notifyListeners();
      
      // Get current user ID to join room
      final user = await AuthService().getMe();
      if (user != null) {
        print('👤 Joining room: user_${user.id}');
        _socket!.emit('join_user_room', user.id);
      }
    });

    _socket!.onDisconnect((_) {
      print('❌ Disconnected from Socket.IO');
      _isConnected = false;
      notifyListeners();
    });
    
    _socket!.on('receive_message', (data) {
      print('📨 Received message: $data');
      notifyListeners(); // Notify listeners (like ChatScreen) to refresh or append
    });

    _socket!.connect();
  }
  
  // Method to manually join chat room if needed (for group chats or specific match rooms)
  void joinChat(String matchId) {
    if (_isConnected && _socket != null) {
      _socket!.emit('join_chat', matchId);
    }
  }

  // Bind a callback to 'receive_message'
  void onMessageReceived(Function(dynamic) callback) {
    _socket?.on('receive_message', callback);
  }
  
  void offMessageReceived(Function(dynamic) callback) {
    _socket?.off('receive_message', callback); // Not standard in dart client? check
    // The dart client uses .off(event, [handler])
    _socket?.off('receive_message'); 
  }

  void disconnect() {
    _socket?.disconnect();
  }
}

