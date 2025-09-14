import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'http://127.0.0.1:8000/api/v1';
  
  try {
    print('🔍 Testing registrations API...');
    
    final response = await http.get(
      Uri.parse('$baseUrl/registrations/my?page=1'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    print('📊 Status Code: ${response.statusCode}');
    print('📥 Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('\n🔍 Parsed Data:');
      print('Data type: ${data.runtimeType}');
      
      if (data is Map) {
        print('Keys: ${data.keys.toList()}');
        
        if (data['data'] != null) {
          final registrations = data['data'];
          print('Registrations type: ${registrations.runtimeType}');
          print('Registrations length: ${registrations.length}');
          
          if (registrations is List && registrations.isNotEmpty) {
            print('\n🔍 First Registration:');
            print(json.encode(registrations[0]));
            
            final firstReg = registrations[0];
            if (firstReg is Map) {
              print('\n🔍 Event data:');
              print('Event: ${firstReg['event']}');
              print('Event type: ${firstReg['event'].runtimeType}');
              
              if (firstReg['event'] is Map) {
                final event = firstReg['event'] as Map;
                print('Event keys: ${event.keys.toList()}');
                print('Event title: ${event['title']}');
              }
            }
          }
        }
      }
    } else {
      print('❌ API Error: ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('💥 Error: $e');
  }
}
