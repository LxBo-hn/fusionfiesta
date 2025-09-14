import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;
  static const Duration timeout = ApiConfig.timeout;
  
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  
  ApiService._();
  
  // Headers cho API calls
  Map<String, String> get _headers => Map<String, String>.from(ApiConfig.defaultHeaders);
  
  // Lấy token từ SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Headers với authentication
  Future<Map<String, String>> get _authHeaders async {
    final token = await _getToken();
    final headers = Map<String, String>.from(_headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
  
  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = '$baseUrl$endpoint';
      ApiConfig.logRequest('GET', url, null);
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders,
      ).timeout(timeout);
      
      ApiConfig.logResponse('GET', url, response.statusCode, response.body);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('GET request failed: $e');
    }
  }
  
  // Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('POST request failed: $e');
    }
  }
  
  // Generic PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _authHeaders,
        body: jsonEncode(data),
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('PUT request failed: $e');
    }
  }
  
  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _authHeaders,
      ).timeout(timeout);
      
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('DELETE request failed: $e');
    }
  }
  
  // Xử lý response từ API
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return jsonDecode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty 
          ? jsonDecode(response.body) 
          : {'message': 'Unknown error'};
      throw ApiException(
        'API Error: ${response.statusCode} - ${errorBody['message'] ?? 'Unknown error'}',
        statusCode: response.statusCode,
      );
    }
  }
  
  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('/auth/login', {
      'email': email,
      'password': password,
    });
    
    if (response['token'] != null) {
      // Lưu token vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response['token']);
      return {'success': true, 'token': response['token']};
    } else {
      return {'success': false, 'message': response['message'] ?? 'Login failed'};
    }
  }
  
  Future<Map<String, dynamic>> register(String name, String email, String password, {String? roleHint}) async {
    final response = await post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
      if (roleHint != null) 'role_hint': roleHint,
    });
    
    if (response['message'] == 'registered') {
      return {'success': true, 'message': 'Registration successful'};
    } else {
      return {'success': false, 'message': response['message'] ?? 'Registration failed'};
    }
  }
  
  Future<Map<String, dynamic>> getMe() async {
    return await get('/auth/me');
  }
  
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await post('/auth/logout', {});
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      return response;
    } catch (e) {
      // Clear token locally even if API call fails
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      return {'success': true, 'message': 'Logged out locally'};
    }
  }
  
  // Event endpoints (public - không cần auth)
  Future<Map<String, dynamic>> getEvents() async {
    try {
      final url = '$baseUrl/events';
      ApiConfig.logRequest('GET', url, null);
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers, // Dùng headers thường, không có auth
      ).timeout(timeout);
      
      ApiConfig.logResponse('GET', url, response.statusCode, response.body);
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('GET request failed: $e');
    }
  }
  
  Future<Map<String, dynamic>> getEvent(String eventId) async {
    return await get('/events/$eventId');
  }
  
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> eventData) async {
    return await post('/events', eventData);
  }
  
  Future<Map<String, dynamic>> updateEvent(String eventId, Map<String, dynamic> eventData) async {
    return await put('/events/$eventId', eventData);
  }
  
  Future<Map<String, dynamic>> deleteEvent(String eventId) async {
    return await delete('/events/$eventId');
  }
  
  // Registration endpoints
  Future<Map<String, dynamic>> getRegistrations(String eventId) async {
    return await get('/registrations?event_id=$eventId');
  }
  
  Future<Map<String, dynamic>> createRegistration(Map<String, dynamic> registrationData) async {
    return await post('/registrations', registrationData);
  }
  
  // User endpoints
  Future<Map<String, dynamic>> getUsers() async {
    return await get('/users');
  }
  
  Future<Map<String, dynamic>> getUser(String userId) async {
    return await get('/users/$userId');
  }
  
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> userData) async {
    return await post('/users', userData);
  }
  
  Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData) async {
    return await put('/users/$userId', userData);
  }
  
  Future<Map<String, dynamic>> deleteUser(String userId) async {
    return await delete('/users/$userId');
  }
  
  // Attendance endpoints
  Future<Map<String, dynamic>> getAttendance(String eventId) async {
    return await get('/attendance?event_id=$eventId');
  }
  
  Future<Map<String, dynamic>> checkIn(String eventId, String checkinCode) async {
    print('🔍 CheckIn API Call: event_id=$eventId, checkin_code=$checkinCode');
    try {
      final result = await post('/attendance/checkin', {
        'event_id': int.parse(eventId),
        'checkin_code': checkinCode,
      });
      print('🔍 CheckIn API Response: $result');
      return result;
    } catch (e) {
      print('🔍 CheckIn API Error: $e');
      rethrow;
    }
  }
  
  // Approval endpoints
  Future<Map<String, dynamic>> getApprovals() async {
    return await get('/approvals');
  }
  
  Future<Map<String, dynamic>> updateApproval(String approvalId, String status) async {
    return await put('/approvals/$approvalId', {'status': status});
  }
  
  // Media endpoints
  Future<Map<String, dynamic>> uploadMedia(String eventId, String filePath) async {
    // Implement file upload logic here
    // This is a placeholder - you'll need to implement multipart upload
    return await post('/events/$eventId/media', {'filePath': filePath});
  }
  
    Future<Map<String, dynamic>> getMedia(String eventId) async {
    return await get('/events/$eventId/media');
  }
  
  // Certificate endpoints
  Future<Map<String, dynamic>> getMyCertificates({int page = 1}) async {
    return await get('/certificates/mine?page=$page');
  }
  
  Future<Map<String, dynamic>> issueCertificate(int registrationId, String certificateId, String pdfUrl) async {
    return await post('/certificates/issue', {
      'registration_id': registrationId,
      'certificate_id': certificateId,
      'pdf_url': pdfUrl,
    });
  }
  
  // Email verification endpoints
  Future<Map<String, dynamic>> sendEmailVerification() async {
    // Deprecated: link-based by default. Backend now sends OTP when hitting notification endpoint.
    return await post('/email/verification/send', {});
  }
  
  Future<Map<String, dynamic>> verifyEmail(String verificationUrl) async {
    // For email verification, we typically handle this via web view or deep link
    // This endpoint would be called when user clicks verification link
    return await get(verificationUrl.replaceFirst(baseUrl, ''));
  }

  // Email verification via OTP (recommended for mobile)
  Future<Map<String, dynamic>> sendEmailVerificationNotification() async {
    // New default: server will send OTP instead of link
    return await post('/auth/email/verification-notification', {});
  }

  Future<Map<String, dynamic>> sendEmailOtp() async {
    return await post('/auth/email/otp', {});
  }

  Future<Map<String, dynamic>> verifyEmailOtp(String code) async {
    return await post('/auth/email/verify-otp', {
      'code': code,
    });
  }
  
  // Feedback endpoints
  Future<Map<String, dynamic>> submitFeedback(
    int eventId, 
    int rating, {
    String? comment,
    int? organizationRating,
    int? relevanceRating,
    int? coordinationRating,
    int? overallExperienceRating,
  }) async {
    final data = <String, dynamic>{
      'rating': rating,
    };
    
    if (comment != null && comment.isNotEmpty) {
      data['comment'] = comment;
    }
    if (organizationRating != null) {
      data['organization_rating'] = organizationRating;
    }
    if (relevanceRating != null) {
      data['relevance_rating'] = relevanceRating;
    }
    if (coordinationRating != null) {
      data['coordination_rating'] = coordinationRating;
    }
    if (overallExperienceRating != null) {
      data['overall_experience_rating'] = overallExperienceRating;
    }
    
    return await post('/events/$eventId/feedback', data);
  }
  
  Future<Map<String, dynamic>> getEventFeedback(int eventId) async {
    return await get('/events/$eventId/feedback');
  }
  
  // Media endpoints
  Future<Map<String, dynamic>> getMediaList({
    int? eventId,
    String? type,
    String? status,
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
    };
    
    if (eventId != null) queryParams['event_id'] = eventId.toString();
    if (type != null) queryParams['type'] = type;
    if (status != null) queryParams['status'] = status;
    
    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return await get('/media?$queryString');
  }
  
  Future<Map<String, dynamic>> toggleMediaFavorite(int mediaId) async {
    return await post('/media/$mediaId/favorite', {});
  }
  
  // Notification endpoints
  Future<Map<String, dynamic>> getNotifications({int page = 1}) async {
    return await get('/notifications?page=$page');
  }
  
  Future<Map<String, dynamic>> markNotificationRead(int notificationId) async {
    return await post('/notifications/$notificationId/read', {});
  }
  
  // Organizer endpoints
  Future<Map<String, dynamic>> getEventRegistrants(int eventId, {int page = 1}) async {
    return await get('/organizer/events/$eventId/registrants?page=$page');
  }
  
  // Password reset endpoints
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await post('/password/forgot', {'email': email});
  }
  
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    return await post('/password/reset', {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }
  
  // Profile endpoints
  Future<Map<String, dynamic>> getProfile() async {
    return await get('/profile/me');
  }
  
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    return await put('/profile/update', profileData);
  }
  
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    return await post('/profile/change-password', {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    });
  }
  
  // Registration endpoints
  Future<Map<String, dynamic>> getMyRegistrations({int page = 1}) async {
    final response = await get('/registrations/my?page=$page');
    print('🔍 Registrations API Response: $response');
    return response;
  }
  
  Future<Map<String, dynamic>> registerForEvent(int eventId) async {
    return await post('/events/$eventId/register', {});
  }
  
  Future<Map<String, dynamic>> unregisterFromEvent(int eventId) async {
    return await delete('/events/$eventId/unregister');
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
  
  @override
  String toString() => 'ApiException: $message';
}
