import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔐 Testing Login + Events API...\n');
  
  final baseUrl = 'http://127.0.0.1:8000/api/v1';
  String? token;
  
  // Step 1: Login
  print('🔑 Step 1: Login');
  try {
    final loginResponse = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': 'admin@example.com',
        'password': 'admin123',
      }),
    ).timeout(const Duration(seconds: 10));
    
    print('Login Status: ${loginResponse.statusCode}');
    print('Login Response: ${loginResponse.body}');
    
    if (loginResponse.statusCode == 200) {
      final loginData = jsonDecode(loginResponse.body);
      token = loginData['token'] ?? loginData['data']['token'];
      print('✅ Token: ${token?.substring(0, 20)}...');
    }
  } catch (e) {
    print('💥 Login Error: $e');
  }
  
  // Step 2: Get Events with token
  if (token != null) {
    print('\n📅 Step 2: Get Events with token');
    try {
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
        final data = jsonDecode(eventsResponse.body);
        print('\n✅ SUCCESS!');
        print('Data structure: ${data.keys}');
        if (data['data'] != null) {
          print('Events count: ${data['data'].length}');
          if (data['data'].isNotEmpty) {
            print('First event: ${data['data'][0]}');
          }
        }
      }
    } catch (e) {
      print('💥 Events Error: $e');
    }
  }
  
  print('\n🎯 Test completed!');
}
