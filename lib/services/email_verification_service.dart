import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';

class EmailVerificationService extends ChangeNotifier {
  static EmailVerificationService? _instance;
  static EmailVerificationService get instance => _instance ??= EmailVerificationService._();
  
  EmailVerificationService._();
  
  final ApiService _apiService = ApiService.instance;
  
  bool _isEmailVerified = false;
  bool _isVerificationEmailSent = false;
  String? _verificationStatus;
  
  bool get isEmailVerified => _isEmailVerified;
  bool get isVerificationEmailSent => _isVerificationEmailSent;
  String? get verificationStatus => _verificationStatus;
  
  // Send verification email
  Future<Map<String, dynamic>> sendVerificationEmail() async {
    try {
      final response = await _apiService.sendEmailVerification();
      
      if (response['message'] == 'verification_link_sent') {
        _isVerificationEmailSent = true;
        _verificationStatus = 'Email verification link sent to your email address.';
        notifyListeners();
        return {'success': true, 'message': _verificationStatus};
      } else if (response['message'] == 'already_verified') {
        _isEmailVerified = true;
        _verificationStatus = 'Email is already verified.';
        notifyListeners();
        return {'success': true, 'message': _verificationStatus};
      } else {
        _verificationStatus = 'Failed to send verification email.';
        notifyListeners();
        return {'success': false, 'message': _verificationStatus};
      }
    } catch (e) {
      _verificationStatus = 'Error: ${e.toString()}';
      notifyListeners();
      return {'success': false, 'message': _verificationStatus};
    }
  }
  
  // Handle verification link (when user clicks email link)
  Future<Map<String, dynamic>> handleVerificationLink(String verificationUrl) async {
    try {
      // Extract the verification parameters from the URL
      Uri.parse(verificationUrl);
      
      // Call the verification endpoint
      final response = await _apiService.verifyEmail(verificationUrl);
      
      if (response['message'] == 'verified') {
        _isEmailVerified = true;
        _verificationStatus = 'Email verified successfully!';
        notifyListeners();
        return {'success': true, 'message': _verificationStatus};
      } else if (response['message'] == 'already_verified') {
        _isEmailVerified = true;
        _verificationStatus = 'Email is already verified.';
        notifyListeners();
        return {'success': true, 'message': _verificationStatus};
      } else {
        _verificationStatus = 'Email verification failed.';
        notifyListeners();
        return {'success': false, 'message': _verificationStatus};
      }
    } catch (e) {
      _verificationStatus = 'Error: ${e.toString()}';
      notifyListeners();
      return {'success': false, 'message': _verificationStatus};
    }
  }
  
  // Open verification link in browser
  Future<bool> openVerificationLink(String verificationUrl) async {
    try {
      final uri = Uri.parse(verificationUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Check if user needs email verification
  Future<void> checkVerificationStatus() async {
    try {
      // This would typically be called when user logs in
      // You might want to add an endpoint to check verification status
      // For now, we'll assume it's handled by the auth service
    } catch (e) {
      _verificationStatus = 'Error checking verification status: ${e.toString()}';
      notifyListeners();
    }
  }
  
  // Reset verification state
  void reset() {
    _isEmailVerified = false;
    _isVerificationEmailSent = false;
    _verificationStatus = null;
    notifyListeners();
  }
  
  // Set verification status (called by auth service)
  void setEmailVerified(bool verified) {
    _isEmailVerified = verified;
    notifyListeners();
  }
}
