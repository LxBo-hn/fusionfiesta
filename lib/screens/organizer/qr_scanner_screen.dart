import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../state/organizer_store.dart';
import '../../models/event.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../widgets/success_notification.dart';

class QRScannerScreen extends StatefulWidget {
  static const String routeName = '/qr-scanner';
  
  final EventModel? event; // Cho phép null để Student có thể quét bất kỳ event nào
  
  const QRScannerScreen({
    super.key,
    this.event,
  });

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? controller;
  bool isScanning = true;
  String? lastScannedCode;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue;
      if (code != null && code != lastScannedCode) {
        lastScannedCode = code;
        // Dừng scanning khi phát hiện QR code
        setState(() {
          isScanning = false;
        });
        _processQRCode(code);
      }
    }
  }

  Future<void> _processQRCode(String code) async {
    // Không cần check isScanning vì đã được set false ở _onDetect

    // Stop camera
    await controller?.stop();

    // Show processing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Đang xử lý mã QR...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final organizerStore = context.read<OrganizerStore>();
      
      // Nếu có event cụ thể, check-in vào event đó
      if (widget.event != null) {
        final success = await organizerStore.checkInAttendance(widget.event!.id.toString(), code);
        
        if (mounted) {
          Navigator.of(context).pop(); // Close loading dialog
          
          if (success) {
            _showSuccessDialog(code, widget.event!.title);
          } else {
            _showErrorDialog(organizerStore.error.value ?? 'Check-in thất bại');
          }
        }
      } else {
        // Student quét QR - sử dụng format EVENT-{event_id}
        final parsedData = _parseQRCode(code);
        if (parsedData != null) {
          final eventId = parsedData['event_id'];
          // Sử dụng format EVENT-{event_id} như backend expect
          final checkinCode = 'EVENT-${eventId}';
          
          print('🔍 Student checkin_code: $checkinCode');
          print('🔍 Event ID: $eventId');
          
          try {
            // Kiểm tra xem user đã đăng ký sự kiện chưa
            print('🔍 Checking registration for event $eventId...');
            final isRegistered = await _checkUserRegistration(eventId);
            print('🔍 Registration check result: $isRegistered');
            
            if (!isRegistered) {
              print('🔍 User not registered, showing warning dialog');
              if (mounted) {
                Navigator.of(context).pop(); // Close loading dialog
                _showNotRegisteredDialog(eventId);
              }
              return;
            }
            
            print('🔍 User is registered, proceeding with check-in...');
            
            final success = await organizerStore.checkInAttendance(
              eventId.toString(), 
              checkinCode
            );
            
            if (mounted) {
              Navigator.of(context).pop(); // Close loading dialog
              
            if (success) {
              // Lấy thông tin sự kiện để hiển thị
              final eventInfo = await _getEventInfo(eventId);
              _showSuccessDialog(code, eventInfo);
            } else {
                // Lấy error message từ organizerStore hoặc fallback
                final errorMessage = organizerStore.error.value ?? 'Check-in thất bại';
                print('🔍 Check-in failed: $errorMessage');
                _showErrorDialog(errorMessage);
              }
            }
          } catch (e) {
            print('🔍 CheckIn Error: $e');
            if (mounted) {
              Navigator.of(context).pop(); // Close loading dialog
              _showErrorDialog(e.toString());
            }
          }
        } else {
          if (mounted) {
            Navigator.of(context).pop(); // Close loading dialog
            _showErrorDialog('Mã QR không hợp lệ');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('Lỗi: $e');
      }
    }
  }

  Future<void> _createRegistrationWithCheckinCode(int eventId, String checkinCode) async {
    try {
      print('🔍 Creating registration for event $eventId with checkin_code $checkinCode');
      
      // Tạo registration qua API với checkin_code từ QR
      final response = await ApiService.instance.post('/registrations', {
        'event_id': eventId,
        'checkin_code': checkinCode,
        'status': 'registered',
        'user_id': AuthService.instance.currentUser?['id'] ?? 0,
      });
      
      print('🔍 Registration created: $response');
    } catch (e) {
      print('🔍 Registration creation failed: $e');
      // Bỏ qua lỗi - có thể registration đã tồn tại
    }
  }

  Map<String, dynamic>? _parseQRCode(String qrCode) {
    print('🔍 Parsing QR code: $qrCode');
    
    try {
      // QR code có thể chứa event ID hoặc JSON với event ID
      // Thử parse JSON trước
      final Map<String, dynamic> data = jsonDecode(qrCode);
      print('🔍 Parsed JSON: $data');
      
      final eventId = data['event_id'];
      final checkinCode = data['checkin_code'] ?? data['code'] ?? qrCode; // Fallback to original QR code
      
      if (eventId != null) {
        return {
          'event_id': eventId is int ? eventId : int.parse(eventId.toString()),
          'checkin_code': checkinCode,
        };
      }
      return null;
    } catch (e) {
      print('🔍 JSON parse failed: $e');
      // Nếu không phải JSON, thử parse số trực tiếp
      try {
        final eventId = int.parse(qrCode);
        print('🔍 Parsed as int: $eventId');
        return {
          'event_id': eventId,
          'checkin_code': qrCode,
        };
      } catch (e) {
        print('🔍 Int parse failed: $e');
        // Thử parse format EVENT-{id}-{timestamp}
        if (qrCode.startsWith('EVENT-')) {
          final parts = qrCode.split('-');
          if (parts.length >= 2) {
            final eventId = int.parse(parts[1]);
            print('🔍 Parsed EVENT format: $eventId');
            return {
              'event_id': eventId,
              'checkin_code': qrCode,
            };
          }
        }
        print('🔍 All parsing methods failed');
        return null;
      }
    }
  }

  void _showSuccessDialog(String code, String eventTitle) {
    final now = DateTime.now();
    final timeString = '${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Check-in thành công!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          eventTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Check-in lúc: $timeString',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bạn đã được check-in vào sự kiện thành công!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resumeScanning();
            },
            child: const Text('Tiếp tục quét'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to dashboard
            },
            child: const Text('Hoàn thành'),
          ),
        ],
      ),
    );
  }

  // Tạo EventModel từ API response
  EventModel _createEventModelFromApiResponse(Map<String, dynamic> eventData) {
    try {
      print('🔍 Creating EventModel from API response...');
      print('🔍 Event data keys: ${eventData.keys.toList()}');
      print('🔍 Event data type: ${eventData.runtimeType}');
      print('🔍 Event data: $eventData');
      
      // Parse department và category từ nested objects
      Map<String, dynamic>? department;
      Map<String, dynamic>? category;
      Map<String, dynamic>? organizer;
      
      try {
        print('🔍 Parsing department...');
        final deptValue = eventData['department'];
        print('🔍 Department value: $deptValue (${deptValue.runtimeType})');
        department = deptValue != null 
            ? deptValue as Map<String, dynamic> 
            : null;
        print('🔍 Department parsed successfully: $department');
      } catch (e) {
        print('🔍 Error parsing department: $e');
        department = null;
      }
      
      try {
        print('🔍 Parsing category...');
        final catValue = eventData['category'];
        print('🔍 Category value: $catValue (${catValue.runtimeType})');
        category = catValue != null 
            ? catValue as Map<String, dynamic> 
            : null;
        print('🔍 Category parsed successfully: $category');
      } catch (e) {
        print('🔍 Error parsing category: $e');
        category = null;
      }
      
      try {
        print('🔍 Parsing organizer...');
        final orgValue = eventData['organizer'];
        print('🔍 Organizer value: $orgValue (${orgValue.runtimeType})');
        organizer = orgValue != null 
            ? orgValue as Map<String, dynamic> 
            : null;
        print('🔍 Organizer parsed successfully: $organizer');
      } catch (e) {
        print('🔍 Error parsing organizer: $e');
        organizer = null;
      }
      
      print('🔍 Department: $department');
      print('🔍 Category: $category');
      print('🔍 Organizer: $organizer');
      
      // Tạo dateText từ startAt
      String dateText = 'Chưa xác định';
      if (eventData['start_at'] != null) {
        try {
          final startAt = DateTime.parse(eventData['start_at']);
          dateText = '${startAt.day}/${startAt.month}/${startAt.year}';
        } catch (e) {
          print('🔍 Error parsing start_at: $e');
        }
      }
      
      // Parse các field một cách an toàn
      final id = eventData['id']?.toString() ?? '0';
      final title = eventData['title']?.toString() ?? 'Sự kiện';
      final description = eventData['description']?.toString() ?? 'Mô tả sự kiện';
      final status = eventData['status']?.toString();
      final organizerId = eventData['organizer_id']?.toString();
      final venue = eventData['venue']?.toString();
      final categoryName = category?['name']?.toString() ?? 'Khác';
      
      // Parse dates
      DateTime? createdAt;
      DateTime? updatedAt;
      DateTime? startAt;
      DateTime? endAt;
      
      if (eventData['created_at'] != null) {
        createdAt = DateTime.tryParse(eventData['created_at'].toString());
      }
      if (eventData['updated_at'] != null) {
        updatedAt = DateTime.tryParse(eventData['updated_at'].toString());
      }
      if (eventData['start_at'] != null) {
        startAt = DateTime.tryParse(eventData['start_at'].toString());
      }
      if (eventData['end_at'] != null) {
        endAt = DateTime.tryParse(eventData['end_at'].toString());
      }
      
      // Parse numbers
      int? maxAttendees;
      int? currentAttendees;
      
      if (eventData['capacity'] != null) {
        maxAttendees = int.tryParse(eventData['capacity'].toString());
      }
      if (eventData['capacity'] != null && eventData['seats_left'] != null) {
        final capacity = int.tryParse(eventData['capacity'].toString()) ?? 0;
        final seatsLeft = int.tryParse(eventData['seats_left'].toString()) ?? 0;
        currentAttendees = capacity - seatsLeft;
      }
      
      print('🔍 Parsed fields: id=$id, title=$title, category=$categoryName');
      
      return EventModel(
        id: id,
        title: title,
        dateText: dateText,
        description: description,
        imageAsset: 'assets/logo/logo.png', // Default image
        status: status,
        organizerId: organizerId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        maxAttendees: maxAttendees,
        currentAttendees: currentAttendees,
        location: venue,
        category: categoryName,
        startAt: startAt,
        endAt: endAt,
      );
    } catch (e) {
      print('🔍 Error creating EventModel from API response: $e');
      // Fallback EventModel
      return EventModel(
        id: eventData['id']?.toString() ?? '0',
        title: eventData['title'] ?? 'Sự kiện',
        dateText: 'Chưa xác định',
        description: eventData['description'] ?? 'Mô tả sự kiện',
        imageAsset: 'assets/logo/logo.png',
      );
    }
  }

  // Lấy thông tin sự kiện
  Future<String> _getEventInfo(int eventId) async {
    try {
      final response = await ApiService.instance.get('/events/$eventId');
      
      // API có thể trả về data trong 'data' hoặc 'event' field
      dynamic eventData;
      if (response.containsKey('event')) {
        eventData = response['event'];
      } else if (response.containsKey('data')) {
        eventData = response['data'];
      } else {
        eventData = response;
      }
      
      return eventData?['title'] ?? 'Sự kiện';
    } catch (e) {
      print('🔍 Error getting event info: $e');
      return 'Sự kiện';
    }
  }

  // Navigate đến event detail để đăng ký
  void _navigateToEventDetail(int eventId) async {
    try {
      print('🔍 Navigating to event detail for event ID: $eventId');
      
      // Lấy thông tin sự kiện từ API
      print('🔍 Making API call to /events/$eventId');
      final response = await ApiService.instance.get('/events/$eventId');
      print('🔍 API Response received: $response');
      print('🔍 API Response type: ${response.runtimeType}');
      
      // API trả về data trong 'event' field
      print('🔍 Checking response structure...');
      print('🔍 Response keys: ${response.keys.toList()}');
      print('🔍 Response contains event: ${response.containsKey('event')}');
      
      // Lấy event data từ response['event']
      final eventData = response['event'];
      print('🔍 Event data: $eventData');
      print('🔍 Event data type: ${eventData.runtimeType}');
      
      if (eventData == null) {
        throw Exception('Event data is null');
      }
      
      // Kiểm tra eventData có phải Map không
      if (eventData is! Map<String, dynamic>) {
        print('🔍 Event data is not a Map: ${eventData.runtimeType}');
        throw Exception('Event data is not in expected format');
      }
      
      // Tạo EventModel từ API response
      print('🔍 About to call _createEventModelFromApiResponse with data: $eventData');
      print('🔍 Event data type before call: ${eventData.runtimeType}');
      final event = _createEventModelFromApiResponse(eventData);
      print('🔍 Created EventModel: ${event.title}');
      
      // Navigate đến event detail
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/event-detail',
          arguments: event,
        );
      }
    } catch (e) {
      print('🔍 Error navigating to event detail: $e');
      
      // Fallback: tạo EventModel đơn giản với thông tin tối thiểu
      try {
        final fallbackEvent = EventModel(
          id: eventId.toString(),
          title: 'Sự kiện #$eventId',
          dateText: 'Hôm nay',
          description: 'Mô tả sự kiện',
          imageAsset: 'assets/logo/logo.png',
          status: 'published',
          organizerId: '0',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          maxAttendees: 100,
          currentAttendees: 0,
          location: 'Địa điểm',
          category: 'Khác',
          startAt: DateTime.now(),
          endAt: DateTime.now().add(const Duration(hours: 2)),
        );
        
        print('🔍 Created fallback EventModel: ${fallbackEvent.title}');
        
        // Navigate với fallback event
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/event-detail',
            arguments: fallbackEvent,
          );
        }
      } catch (fallbackError) {
        print('🔍 Fallback also failed: $fallbackError');
        // Cuối cùng: hiển thị thông báo lỗi
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể mở chi tiết sự kiện. Vui lòng thử lại.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Kiểm tra xem user đã đăng ký sự kiện chưa
  Future<bool> _checkUserRegistration(int eventId) async {
    try {
      // Thử endpoint mới với format đúng
      final response = await ApiService.instance.get('/registrations/my');
      final data = response['data'] as List?;
      
      if (data == null || data.isEmpty) {
        print('🔍 No registrations found for user');
        return false;
      }
      
      // Tìm registration cho event cụ thể
      final hasRegistration = data.any((registration) {
        final event = registration['event'];
        if (event != null && event['id'] == eventId) {
          print('🔍 Found registration for event $eventId: ${registration['status']}');
          return true;
        }
        return false;
      });
      
      print('🔍 User registration status for event $eventId: $hasRegistration');
      return hasRegistration;
    } catch (e) {
      print('🔍 Check registration error: $e');
      // Nếu không kiểm tra được, cho phép check-in và để backend xử lý
      return true;
    }
  }

  // Hiển thị dialog khi user chưa đăng ký
  void _showNotRegisteredDialog(int eventId) {
    SuccessNotification.show(
      context: context,
      title: '⚠️ Chưa đăng ký sự kiện',
      message: 'Bạn cần đăng ký tham gia sự kiện trước khi có thể check-in. Vui lòng đăng ký sự kiện trước.',
      type: NotificationType.warning,
      onDismiss: () {
        Navigator.of(context).pop(); // Go back to scanner
        _resumeScanning();
      },
      onAction: () {
        Navigator.of(context).pop(); // Close notification
        Navigator.of(context).pop(); // Go back to scanner
        _navigateToEventDetail(eventId);
      },
    );
  }

  void _showErrorDialog(String message) {
    // Parse error message để hiển thị thông báo thân thiện
    String friendlyMessage = _parseErrorMessage(message);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 48),
        title: const Text('Check-in thất bại'),
        content: Text(friendlyMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resumeScanning();
            },
            child: const Text('Thử lại'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to dashboard
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // Parse error message thành thông báo thân thiện
  String _parseErrorMessage(String error) {
    if (error.contains('already checked in')) {
      return 'Bạn đã check-in sự kiện này rồi. Không thể check-in nhiều lần.';
    } else if (error.contains('not registered')) {
      return 'Bạn chưa đăng ký tham gia sự kiện này. Vui lòng đăng ký trước khi check-in.';
    } else if (error.contains('event not found')) {
      return 'Không tìm thấy sự kiện. Vui lòng kiểm tra lại mã QR.';
    } else if (error.contains('time window')) {
      return 'Thời gian check-in không hợp lệ. Vui lòng kiểm tra lại thời gian sự kiện.';
    } else if (error.contains('422')) {
      return 'Dữ liệu không hợp lệ. Vui lòng thử lại.';
    } else if (error.contains('404')) {
      return 'Không tìm thấy sự kiện. Vui lòng kiểm tra lại mã QR.';
    } else if (error.contains('500')) {
      return 'Lỗi hệ thống. Vui lòng thử lại sau.';
    } else {
      return 'Có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  void _resumeScanning() {
    setState(() {
      isScanning = true;
      lastScannedCode = null;
    });
    // Start lại camera sau khi đã stop
    controller?.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR Check-in'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              controller?.toggleTorch();
            },
            icon: const Icon(Icons.flash_on),
          ),
          IconButton(
            onPressed: () {
              controller?.switchCamera();
            },
            icon: const Icon(Icons.flip_camera_ios),
          ),
        ],
      ),
      body: Column(
        children: [
          // Event info
          if (widget.event != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              child: Column(
                children: [
                  Text(
                    widget.event!.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.event!.dateText,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              child: const Column(
                children: [
                  Text(
                    'Quét QR Check-in',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Hướng camera về phía mã QR để check-in',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          
          // QR Scanner
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller!,
                  onDetect: _onDetect,
                ),
                
                // Instructions
                Positioned(
                  bottom: 50,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Đặt mã QR trong khung vuông để quét',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
