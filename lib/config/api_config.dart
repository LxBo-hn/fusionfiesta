import 'dart:io';

class ApiConfig {
  // Tự động phát hiện platform và cấu hình URL phù hợp
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Android emulator sử dụng 10.0.2.2 để truy cập localhost
      return 'http://10.0.2.2:8000/api/v1';
    } else if (Platform.isIOS) {
      // iOS simulator sử dụng localhost
      return 'http://127.0.0.1:8000/api/v1';
    } else {
      // Desktop/Web sử dụng localhost
      return 'http://127.0.0.1:8000/api/v1';
    }
  }
  
  // Fallback URLs nếu cần
  static const String localhostUrl = 'http://127.0.0.1:8000/api/v1';
  static const String androidEmulatorUrl = 'http://10.0.2.2:8000/api/v1';
  static const String productionUrl = 'https://your-domain.com/api/v1';
  
  // Timeout cho các request
  static const Duration timeout = Duration(seconds: 30);
  
  // Headers mặc định
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Debug mode
  static const bool debugMode = true;
  
  // Log requests
  static void logRequest(String method, String url, Map<String, dynamic>? data) {
    if (debugMode) {
      print('🌐 API Request: $method $url');
      if (data != null) {
        print('📤 Data: $data');
      }
    }
  }
  
  // Log response
  static void logResponse(String method, String url, int statusCode, String response) {
    if (debugMode) {
      print('📥 API Response: $method $url -> $statusCode');
      print('📥 Response: $response');
    }
  }
}