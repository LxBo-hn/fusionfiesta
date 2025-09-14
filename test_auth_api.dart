import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔐 Testing Laravel API with Authentication...\n');
  
  final baseUrl = 'http://127.0.0.1:8000/api/v1';
  
  // Test 1: Login để lấy token
  print('🔑 Step 1: Login to get token');
  try {
    final loginResponse = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': 'testuser@example.com',
        'password': 'password123',
      }),
    ).timeout(const Duration(seconds: 10));
    
    print('Login Status: ${loginResponse.statusCode}');
    print('Login Response: ${loginResponse.body}');
    
    if (loginResponse.statusCode == 200) {
      final loginData = jsonDecode(loginResponse.body);
      final token = loginData['token'] ?? loginData['data']['token'];
      
      if (token != null) {
        print('✅ Token received: ${token.substring(0, 20)}...');
        
        // Test 2: Get events với token
        print('\n📅 Step 2: Get events with token');
        final eventsResponse = await http.get(
          Uri.parse('$baseUrl/events'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));
        
        print('Events Status: ${eventsResponse.statusCode}');
        print('Events Response: ${eventsResponse.body}');
        
        if (eventsResponse.statusCode == 200) {
          print('✅ SUCCESS: API is working with authentication!');
        } else {
          print('❌ Events API failed');
        }
      } else {
        print('❌ No token in login response');
      }
    } else {
      print('❌ Login failed');
    }
  } catch (e) {
    print('💥 Error: $e');
  }
  
  print('\n🎯 Test completed!');
}