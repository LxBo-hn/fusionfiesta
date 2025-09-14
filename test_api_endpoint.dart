import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Test các URL khác nhau
  final urls = [
    'http://127.0.0.1:8000/api/health',
    'http://127.0.0.1:8000/api/v1/events',
    'http://127.0.0.1:8000/api/events',
    'http://localhost:8000/api/health',
    'http://localhost:8000/api/v1/events',
    'http://localhost:8000/api/events',
  ];
  
  for (final url in urls) {
    print('Testing: $url');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));
      
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('---');
    } catch (e) {
      print('Error: $e');
      print('---');
    }
  }
}
