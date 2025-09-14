import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import 'api_service.dart';

class ProfileService extends ChangeNotifier {
  static ProfileService? _instance;
  static ProfileService get instance => _instance ??= ProfileService._();
  
  ProfileService._();
  
  final ApiService _apiService = ApiService.instance;
  
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);
  final ValueNotifier<UserProfileModel?> _currentProfile = ValueNotifier<UserProfileModel?>(null);
  
  UserProfileModel? get currentProfile => _currentProfile.value;
  
  // Load current user profile
  Future<void> loadProfile() async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final response = await _apiService.getProfile();
      
      if (response['id'] != null) {
        _currentProfile.value = UserProfileModel.fromJson(response);
        notifyListeners();
      } else {
        error.value = response['message'] ?? 'Failed to load profile';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  // Update profile
  Future<bool> updateProfile({
    String? name,
    int? departmentId,
    String? studentCode,
    String? phone,
    DateTime? dob,
    String? gender,
    String? avatarUrl,
  }) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      final profileData = <String, dynamic>{};
      
      if (name != null) profileData['name'] = name;
      if (departmentId != null) profileData['department_id'] = departmentId;
      if (studentCode != null) profileData['student_code'] = studentCode;
      if (phone != null) profileData['phone'] = phone;
      if (dob != null) profileData['dob'] = dob.toIso8601String().split('T')[0];
      if (gender != null) profileData['gender'] = gender;
      if (avatarUrl != null) profileData['avatar_url'] = avatarUrl;
      
      final response = await _apiService.updateProfile(profileData);
      
      if (response['id'] != null) {
        _currentProfile.value = UserProfileModel.fromJson(response);
        notifyListeners();
        return true;
      } else {
        error.value = response['message'] ?? 'Failed to update profile';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      // Validate passwords match
      if (newPassword != newPasswordConfirmation) {
        error.value = 'Passwords do not match';
        return false;
      }
      
      // Validate password strength
      if (newPassword.length < 8) {
        error.value = 'Password must be at least 8 characters long';
        return false;
      }
      
      final response = await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      
      if (response['message'] == 'password_changed') {
        return true;
      } else {
        error.value = response['message'] ?? 'Failed to change password';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
  
  // Validate phone format
  bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }
  
  // Validate password strength
  String? validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
    }
    
    return null;
  }
  
  // Get user initials
  String getUserInitials() {
    if (_currentProfile.value?.name.isNotEmpty == true) {
      return _currentProfile.value!.name
          .split(' ')
          .map((n) => n.isNotEmpty ? n[0] : '')
          .take(2)
          .join()
          .toUpperCase();
    }
    return 'U';
  }
  
  // Get user display name
  String getUserDisplayName() {
    return _currentProfile.value?.name ?? 'User';
  }
  
  // Get user email
  String getUserEmail() {
    return _currentProfile.value?.email ?? '';
  }
  
  // Get user role
  String getUserRole() {
    return _currentProfile.value?.role ?? 'student';
  }
  
  // Check if user has specific role
  bool hasRole(String role) {
    return _currentProfile.value?.role == role;
  }
  
  // Check if user is admin
  bool isAdmin() {
    final role = _currentProfile.value?.role ?? '';
    return role == 'admin' || role == 'super_admin' || role == 'staff_admin';
  }
  
  // Check if user is organizer
  bool isOrganizer() {
    return _currentProfile.value?.role == 'organizer';
  }
  
  // Check if user is student
  bool isStudent() {
    return _currentProfile.value?.role == 'student';
  }
  
  // Clear error
  void clearError() {
    error.value = null;
  }
  
  // Clear profile data
  void clearProfile() {
    _currentProfile.value = null;
    error.value = null;
    notifyListeners();
  }
}
