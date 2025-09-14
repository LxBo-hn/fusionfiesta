import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing Public Events API...\n');
  
  final baseUrl = 'http://127.0.0.1:8000/api/v1';
  
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/public/events'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');
    
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        print('\n✅ SUCCESS!');
        print('Data structure: ${data.keys}');
        if (data['data'] != null) {
          print('Events count: ${data['data'].length}');
          if (data['data'].isNotEmpty) {
            print('First event: ${data['data'][0]}');
          }
        }
      } catch (e) {
        print('❌ JSON Parse Error: $e');
      }
    } else {
      print('❌ API Error: ${response.statusCode}');
    }
  } catch (e) {
    print('💥 Exception: $e');
  }
  
  print('\n🎯 Test completed!');
}
