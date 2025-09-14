import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🎯 Final Test - Events API...\n');
  
  final baseUrl = 'http://127.0.0.1:8000/api/v1';
  
  print('🔍 Testing: /events');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/events'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');
    
    if (response.statusCode == 200) {
      print('\n✅ SUCCESS! API is working!');
      try {
        final data = jsonDecode(response.body);
        print('Data structure: ${data.keys}');
        if (data['data'] != null) {
          print('Events count: ${data['data'].length}');
        }
      } catch (e) {
        print('JSON Parse Error: $e');
      }
    } else if (response.statusCode == 401) {
      print('\n❌ Still requires authentication!');
      print('📝 You need to add public route to Laravel:');
      print('   Add this to routes/api.php:');
      print('   Route::get(\'/events\', function () { ... });');
    } else {
      print('\n❌ API Error: ${response.statusCode}');
    }
  } catch (e) {
    print('💥 Exception: $e');
  }
  
  print('\n🎯 Test completed!');
  print('\n📋 Summary:');
  print('- Flutter app is ready to use API');
  print('- Laravel needs public /events endpoint');
  print('- Follow ADD_LARAVEL_ROUTE.md instructions');
}
