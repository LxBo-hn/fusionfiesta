import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state/organizer_store.dart';
import '../../../models/event.dart';
import '../../../services/auth_service.dart';
import '../../events/event_detail_screen.dart';
import '../../events/registration_qr_screen.dart';
import '../../organizer/registrants_screen.dart';
import '../../organizer/create_event_screen.dart';
import '../../organizer/edit_event_screen.dart';
import '../../organizer/qr_scanner_screen.dart';
import '../../organizer/qr_generator_screen.dart';
import '../../auth/role_selection_screen.dart';
import '../../../main.dart';

class OrganizerDashboard extends StatefulWidget {
  static const String routeName = '/organizer';
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load data từ API khi khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrganizerStore>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Người tổ chức',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Handle notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
            onPressed: () {
              // Handle profile
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildEventsTab(),
          _buildAttendanceTab(),
          _buildMediaTab(),
          _buildAnalyticsTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Sự kiện',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Tham dự',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Media',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(
                context,
                CreateEventScreen.routeName,
              ),
              backgroundColor: const Color(0xFF6C63FF),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEventsTab() {
    return Consumer<OrganizerStore>(
      builder: (context, organizerStore, child) {
        if (organizerStore.isLoading.value && organizerStore.events.value.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
          );
        }

        if (organizerStore.error.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${organizerStore.error.value}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => organizerStore.loadEvents(),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (organizerStore.events.value.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: organizerStore.events.value.length,
          itemBuilder: (context, index) {
            final event = organizerStore.events.value[index];
            return _buildEventCard(event, organizerStore);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Chưa có sự kiện nào',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Tạo sự kiện đầu tiên để bắt đầu',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(EventModel event, OrganizerStore store) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          EventDetailScreen.routeName,
          arguments: event,
        ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      event.imageAsset,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.dateText,
                          style: const TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (action) => _handleEventAction(action, event),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'qr',
                        child: Row(
                          children: [
                            Icon(Icons.qr_code, size: 20),
                            SizedBox(width: 8),
                            Text('Mã QR'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'registrants',
                        child: Row(
                          children: [
                            Icon(Icons.people, size: 20),
                            SizedBox(width: 8),
                            Text('Người đăng ký'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        RegistrantsScreen.routeName,
                        arguments: {'event': event},
                      ),
                      icon: const Icon(Icons.people, size: 16),
                      label: const Text('Xem đăng ký'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6C63FF),
                        side: const BorderSide(color: Color(0xFF6C63FF)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        QRScannerScreen.routeName,
                        arguments: {'event': event},
                      ),
                      icon: const Icon(Icons.qr_code_scanner, size: 16),
                      label: const Text('Quét QR'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6C63FF),
                        side: const BorderSide(color: Color(0xFF6C63FF)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return Consumer<OrganizerStore>(
      builder: (context, store, child) {
        return ValueListenableBuilder<List<String>>(
          valueListenable: store.attendance,
          builder: (context, attendance, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: store.isLoading,
              builder: (context, isLoading, child) {
                return ValueListenableBuilder<String?>(
                  valueListenable: store.error,
                  builder: (context, error, child) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Quản lý tham dự',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Load attendance for all events
                                      for (final event in store.events.value) {
                                        store.loadAttendance(event.id);
                                      }
                                    },
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text('Làm mới'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[600],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Show QR Generator
                                      Navigator.pushNamed(
                                        context,
                                        QRGeneratorScreen.routeName,
                                        arguments: {'event': store.events.value.isNotEmpty 
                                          ? store.events.value.first 
                                          : null},
                                      );
                                    },
                                    icon: const Icon(Icons.qr_code, size: 18),
                                    label: const Text('Tạo QR'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6C63FF),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Error display
                          if (error != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red[700]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      error,
                                      style: TextStyle(color: Colors.red[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          
                          if (error != null) const SizedBox(height: 16),
                          
                          // Loading indicator
                          if (isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else
                            // Events list with attendance
                            Expanded(
                              child: store.events.value.isEmpty
                                  ? const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
                                          Icon(Icons.event_note, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
                                            'Chưa có sự kiện nào',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: store.events.value.length,
                                      itemBuilder: (context, index) {
                                        final event = store.events.value[index];
                                        return _buildEventAttendanceCard(event, store);
                                      },
                                    ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEventAttendanceCard(EventModel event, OrganizerStore store) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.dateText,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'scan':
                        Navigator.pushNamed(
                          context,
                          QRScannerScreen.routeName,
                          arguments: {'event': event},
                        );
                        break;
                      case 'generate':
                        Navigator.pushNamed(
                          context,
                          QRGeneratorScreen.routeName,
                          arguments: {'event': event},
                        );
                        break;
                      case 'load':
                        store.loadAttendance(event.id);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'scan',
                      child: Row(
                        children: [
                          Icon(Icons.qr_code_scanner, size: 18),
                          SizedBox(width: 8),
                          Text('Quét QR'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'generate',
                      child: Row(
                        children: [
                          Icon(Icons.qr_code, size: 18),
                          SizedBox(width: 8),
                          Text('Tạo QR'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'load',
                      child: Row(
                        children: [
                          Icon(Icons.refresh, size: 18),
                          SizedBox(width: 8),
                          Text('Tải lại'),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(Icons.more_vert),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Attendance stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Đã check-in',
                    '${store.attendance.value.length}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Tổng đăng ký',
                    '${event.currentAttendees ?? 0}',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Còn lại',
                    '${(event.maxAttendees ?? 0) - (event.currentAttendees ?? 0)}',
                    Icons.event_available,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        QRScannerScreen.routeName,
                        arguments: {'event': event},
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner, size: 16),
                    label: const Text('Quét QR'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6C63FF),
                      side: const BorderSide(color: Color(0xFF6C63FF)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        QRGeneratorScreen.routeName,
                        arguments: {'event': event},
                      );
                    },
                    icon: const Icon(Icons.qr_code, size: 16),
                    label: const Text('Tạo QR'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Thư viện Media',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Quản lý media sự kiện tại đây',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Thống kê',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Xem thống kê sự kiện tại đây',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF6C63FF),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Người tổ chức',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Quản lý sự kiện của bạn',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Profile Options
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Color(0xFF6C63FF)),
                  title: const Text('Chỉnh sửa hồ sơ'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Handle edit profile
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.lock, color: Color(0xFF6C63FF)),
                  title: const Text('Đổi mật khẩu'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Handle change password
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleEventAction(String action, EventModel event) {
    switch (action) {
      case 'edit':
        Navigator.pushNamed(
          context,
          EditEventScreen.routeName,
          arguments: {'event': event},
        );
        break;
      case 'qr':
        Navigator.pushNamed(context, RegistrationQRScreen.routeName);
        break;
      case 'registrants':
        Navigator.pushNamed(
          context,
          RegistrantsScreen.routeName,
          arguments: {'event': event},
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, event);
        break;
    }
  }



  void _showDeleteConfirmation(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sự kiện'),
        content: Text('Bạn có chắc chắn muốn xóa "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<OrganizerStore>().deleteEvent(event.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              print('🔄 Starting logout process...');
              await AuthService.instance.logout();
              print('✅ Logout completed, navigating to role selection...');
              
              // Use global navigator key to ensure navigation works
              FusionFiestaApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
                RoleSelectionScreen.routeName,
                  (route) => false,
                );
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}