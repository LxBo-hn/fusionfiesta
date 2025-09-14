import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../state/organizer_store.dart';
import '../../models/event.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

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
            final success = await organizerStore.checkInAttendance(
              eventId.toString(), 
              checkinCode
            );
            
            if (mounted) {
              Navigator.of(context).pop(); // Close loading dialog
              
              if (success) {
                _showSuccessDialog(code, 'Sự kiện');
              } else {
                _showErrorDialog(organizerStore.error.value ?? 'Check-in thất bại');
              }
            }
          } catch (e) {
            print('🔍 CheckIn Error: $e');
            if (mounted) {
              Navigator.of(context).pop(); // Close loading dialog
              _showErrorDialog('Lỗi API: $e');
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Check-in thành công!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sự kiện: $eventTitle'),
            const SizedBox(height: 8),
            Text('Mã QR: $code'),
            const SizedBox(height: 8),
            const Text('Bạn đã được check-in vào sự kiện.'),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error, color: Colors.red, size: 48),
        title: const Text('Check-in thất bại'),
        content: Text(message),
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
