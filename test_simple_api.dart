import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing Simple API endpoints...\n');
  
  final baseUrl = 'http://127.0.0.1:8000/api/v1';
  
  // Test các endpoint khác nhau
  final endpoints = [
    '/events',
    '/auth/login',
    '/auth/register', 
    '/organizer/events',
    '/admin/users',
    '/profile',
  ];
  
  for (final endpoint in endpoints) {
    print('🔍 Testing: $endpoint');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ SUCCESS');
        try {
          final data = jsonDecode(response.body);
          print('Data: ${data.toString().substring(0, 200)}...');
        } catch (e) {
          print('Response: ${response.body.substring(0, 200)}...');
        }
      } else if (response.statusCode == 401) {
        print('🔒 Requires Authentication');
      } else if (response.statusCode == 404) {
        print('❌ Not Found');
      } else {
        print('❌ Error: ${response.body.substring(0, 200)}...');
      }
    } catch (e) {
      print('💥 Exception: $e');
    }
    
    print('─' * 50);
  }
  
  // Test POST login với data khác
  print('\n🔑 Testing POST /auth/login with different data');
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
  } catch (e) {
    print('💥 Login Error: $e');
  }
  
  print('\n🎯 Test completed!');
}
