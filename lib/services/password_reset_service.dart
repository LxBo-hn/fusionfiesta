import 'package:flutter/foundation.dart';
import 'api_service.dart';

class PasswordResetService extends ChangeNotifier {
  static PasswordResetService? _instance;
  static PasswordResetService get instance => _instance ??= PasswordResetService._();
  
  PasswordResetService._();
  
  final ApiService _apiService = ApiService.instance;
  
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> error = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isEmailSent = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPasswordReset = ValueNotifier<bool>(false);
  
  // Send password reset email
  Future<bool> sendResetEmail(String email) async {
    try {
      isLoading.value = true;
      error.value = null;
      isEmailSent.value = false;
      
      final response = await _apiService.forgotPassword(email);
      
      if (response['message'] != null) {
        final message = response['message'] as String;
        
        // Check if it's a success message (Laravel returns different messages)
        if (message.contains('reset link') || 
            message.contains('sent') || 
            message.contains('success')) {
          isEmailSent.value = true;
          return true;
        } else {
          error.value = message;
          return false;
        }
      } else {
        error.value = 'Failed to send reset email';
        return false;
      }
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }
  
  // Reset password with token
  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      isLoading.value = true;
      error.value = null;
      isPasswordReset.value = false;
      
      // Validate passwords match
      if (password != passwordConfirmation) {
        error.value = 'Passwords do not match';
        return false;
      }
      
      // Validate password strength
      if (password.length < 8) {
        error.value = 'Password must be at least 8 characters long';
        return false;
      }
      
      final response = await _apiService.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      
      if (response['message'] != null) {
        final message = response['message'] as String;
        
        // Check if it's a success message
        if (message.contains('reset') || 
            message.contains('success') || 
            message.contains('updated')) {
          isPasswordReset.value = true;
          return true;
        } else {
          error.value = message;
          return false;
        }
      } else {
        error.value = 'Failed to reset password';
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
  
  // Clear error
  void clearError() {
    error.value = null;
  }
  
  // Reset all state
  void reset() {
    isEmailSent.value = false;
    isPasswordReset.value = false;
    error.value = null;
    isLoading.value = false;
    notifyListeners();
  }
}
