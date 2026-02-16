import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/socket_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SocketService _socketService = SocketService();
  
  SocketService get socketService => _socketService;

  // ... (existing code variables)


  User? _user;
  bool _loading = true;
  String? _error;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    checkAuth();
  }

  Future<void> checkAuth() async {
    _loading = true;
    notifyListeners();

    final hasTokens = await StorageService.hasTokens();
    if (!hasTokens) {
      _user = null;
      _loading = false;
      _isAuthenticated = false;
      notifyListeners();
      return;
    }

    try {
      final user = await _authService.getMe();
      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        _socketService.connect();
      } else {
        await StorageService.clearTokens();
        _user = null;
        _isAuthenticated = false;
      }
    } catch (_) {
      await StorageService.clearTokens();
      _user = null;
      _isAuthenticated = false;
    }

    _loading = false;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email: email, password: password);
      if (response['success'] == true) {
        _user = User.fromJson(response['data']['user']);
        _isAuthenticated = true;
        _loading = false;
        _error = null;
        _socketService.connect();
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
      }
    } catch (e) {
      _error = _parseError(e);
    }

    _loading = false;
    _isAuthenticated = false;
    notifyListeners();
    return false;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
    required String gender,
    required String lookingFor,
    String? bio,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    List<String>? interests,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        name: name,
        age: age,
        gender: gender,
        lookingFor: lookingFor,
        bio: bio,
        city: city,
        state: state,
        country: country,
        latitude: latitude,
        longitude: longitude,
        interests: interests,
        location: city != null ? '$city, $country' : null,
      );

      if (response['success'] == true) {
        final tokens = response['data']?['tokens'];
        if (tokens != null && tokens['accessToken'] != null) {
          await StorageService.saveTokens(
            accessToken: tokens['accessToken'],
            refreshToken: tokens['refreshToken'] ?? '',
          );
          _isAuthenticated = true;
          _socketService.connect();
        }
        _user = User.fromJson(response['data']['user']);
        _loading = false;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Signup failed';
      }
    } catch (e) {
      _error = _parseError(e);
    }

    _loading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    _loading = true;
    notifyListeners();

    await _authService.logout();
    _socketService.disconnect();

    _user = null;
    _isAuthenticated = false;
    _loading = false;
    _error = null;
    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.updateProfile(updates);
      if (response['success'] == true && response['data']?['user'] != null) {
        _user = User.fromJson(response['data']['user']);
        _loading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = _parseError(e);
    }

    _loading = false;
    notifyListeners();
    return false;
  }

  Future<bool> forgotPassword(String email) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.forgotPassword(email);
      _loading = false;
      notifyListeners();
      return response['success'] == true;
    } catch (e) {
      _error = _parseError(e);
    }

    _loading = false;
    notifyListeners();
    return false;
  }

  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _parseError(dynamic error) {
    if (error is Exception) {
      final msg = error.toString();
      if (msg.contains('DioException')) {
        if (msg.contains('409')) return 'Email already registered. Please try logging in.';
        if (msg.contains('401')) return 'Invalid email or password.';
        if (msg.contains('404')) return 'Account not found.';
        if (msg.contains('connection')) return 'Network error: $msg';
      }
      return 'Error: $msg';
    }
    return 'An unexpected error occurred.';
  }
}
