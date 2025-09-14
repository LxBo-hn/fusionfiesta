import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing All Laravel Endpoints...\n');
  
  final baseUrl = 'http://127.0.0.1:8000/api/v1';
  
  final endpoints = [
    '/events',
    '/public/events', 
    '/health',
    '/auth/login',
    '/auth/register',
    '/organizer/events',
    '/admin/users',
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
      ).timeout(const Duration(seconds: 5));
      
      print('Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('✅ SUCCESS - Public endpoint!');
        try {
          final data = jsonDecode(response.body);
          print('Data: ${data.toString().substring(0, 100)}...');
        } catch (e) {
          print('Response: ${response.body.substring(0, 100)}...');
        }
      } else if (response.statusCode == 401) {
        print('🔒 Requires Authentication');
      } else if (response.statusCode == 404) {
        print('❌ Not Found');
      } else if (response.statusCode == 405) {
        print('⚠️ Method Not Allowed (needs POST)');
      } else {
        print('❌ Error: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Exception: $e');
    }
    
    print('─' * 50);
  }
  
  print('\n🎯 Test completed!');
  print('\n📝 Next steps:');
  print('1. Add public /events endpoint to Laravel routes/api.php');
  print('2. Or create a user and login to get token');
  print('3. Or modify existing /events endpoint to be public');
}
