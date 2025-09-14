import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  
  AuthService._();
  
  final ApiService _apiService = ApiService.instance;
  
  bool _isLoggedIn = false;
  Map<String, dynamic>? _currentUser;
  String? _token;
  
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get currentUser => _currentUser;
  String? get token => _token;
  
  // Initialize auth state on app start
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token != null) {
      _token = token;
      await _loadUserProfile();
    }
  }
  
  // Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      
      if (response['success']) {
        _isLoggedIn = true;
        _token = response['token'];
        await _loadUserProfile();
        notifyListeners();
        return {'success': true, 'message': 'Login successful'};
      } else {
        return {'success': false, 'message': response['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  
  // Register new user
  Future<Map<String, dynamic>> register(String name, String email, String password, {String? roleHint}) async {
    try {
      final response = await _apiService.register(name, email, password, roleHint: roleHint);
      
      if (response['success']) {
        return {'success': true, 'message': response['message']};
      } else {
        return {'success': false, 'message': response['message']};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  
  // Load user profile
  Future<void> _loadUserProfile() async {
    try {
      final response = await _apiService.getMe();
      _currentUser = response;
    } catch (e) {
      // If profile load fails, logout user
      await logout();
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }
    
    _isLoggedIn = false;
    _currentUser = null;
    _token = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    
    notifyListeners();
  }
  
  // Check if user has specific role
  bool hasRole(String role) {
    if (_currentUser == null) return false;
    
    final roles = _currentUser!['roles'] as List<dynamic>? ?? [];
    return roles.any((r) => r['name'] == role);
  }
  
  // Check if user is staff (pending approval)
  bool get isStaffPending {
    if (_currentUser == null) return false;
    return _currentUser!['status'] == 'staff_pending';
  }
  
  // Get user role hint
  String? get roleHint {
    if (_currentUser == null) return null;
    return _currentUser!['role_hint'];
  }
}
