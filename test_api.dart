import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing API endpoints...\n');
  
  // Test các URL khác nhau
  final testUrls = [
    {
      'name': 'Health Check (127.0.0.1)',
      'url': 'http://127.0.0.1:8000/api/health',
    },
    {
      'name': 'Events v1 (127.0.0.1)',
      'url': 'http://127.0.0.1:8000/api/v1/events',
    },
    {
      'name': 'Events (127.0.0.1)',
      'url': 'http://127.0.0.1:8000/api/events',
    },
    {
      'name': 'Health Check (localhost)',
      'url': 'http://localhost:8000/api/health',
    },
    {
      'name': 'Events v1 (localhost)',
      'url': 'http://localhost:8000/api/v1/events',
    },
    {
      'name': 'Events (localhost)',
      'url': 'http://localhost:8000/api/events',
    },
  ];
  
  for (final test in testUrls) {
    print('🔍 Testing: ${test['name']}');
    print('URL: ${test['url']}');
    
    try {
      final response = await http.get(
        Uri.parse(test['url']!),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('Status: ${response.statusCode}');
      print('Headers: ${response.headers}');
      
      if (response.body.isNotEmpty) {
        try {
          final jsonData = jsonDecode(response.body);
          print('Response: ${jsonData}');
        } catch (e) {
          print('Response (raw): ${response.body}');
        }
      } else {
        print('Response: Empty body');
      }
      
      if (response.statusCode == 200) {
        print('✅ SUCCESS\n');
      } else {
        print('❌ FAILED\n');
      }
    } catch (e) {
      print('💥 ERROR: $e\n');
    }
    
    print('─' * 50);
  }
  
  print('\n🎯 Test completed!');
}
