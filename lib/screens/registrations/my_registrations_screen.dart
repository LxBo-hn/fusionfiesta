import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/registration_service.dart';
import '../../models/registration.dart';

class MyRegistrationsScreen extends StatefulWidget {
  static const String routeName = '/my-registrations';

  const MyRegistrationsScreen({super.key});

  @override
  State<MyRegistrationsScreen> createState() => _MyRegistrationsScreenState();
}

class _MyRegistrationsScreenState extends State<MyRegistrationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // Load registrations on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegistrationService>().loadMyRegistrations(refresh: true);
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<RegistrationService>().loadMoreRegistrations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'My Registrations',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Pending'),
            Tab(text: 'Waitlist'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<RegistrationService>().refresh(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRegistrationsList('all'),
          _buildRegistrationsList('confirmed'),
          _buildRegistrationsList('pending'),
          _buildRegistrationsList('waitlist'),
        ],
      ),
    );
  }
  
  Widget _buildRegistrationsList(String filter) {
    return Consumer<RegistrationService>(
      builder: (context, registrationService, child) {
        if (registrationService.isLoading.value && registrationService.myRegistrations.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
          );
        }
        
        if (registrationService.error.value != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error loading registrations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  registrationService.error.value!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => registrationService.refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        // Filter registrations
        List<RegistrationModel> filteredRegistrations = registrationService.myRegistrations;
        
        switch (filter) {
          case 'confirmed':
            filteredRegistrations = registrationService.getConfirmedRegistrations();
            break;
          case 'pending':
            filteredRegistrations = registrationService.getPendingRegistrations();
            break;
          case 'waitlist':
            filteredRegistrations = registrationService.getWaitlistRegistrations();
            break;
        }
        
        if (filteredRegistrations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEmptyIcon(filter),
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage(filter),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getEmptySubtitle(filter),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () => registrationService.refresh(),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: filteredRegistrations.length + 
                       (registrationService.hasMorePages ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= filteredRegistrations.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                    ),
                  ),
                );
              }
              
              final registration = filteredRegistrations[index];
              return _buildRegistrationCard(registration, registrationService);
            },
          ),
        );
      },
    );
  }
  
  Widget _buildRegistrationCard(RegistrationModel registration, RegistrationService registrationService) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showRegistrationDetails(registration),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with event title and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      registration.eventTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(int.parse('FF${registration.statusColor}', radix: 16)).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      registration.statusDisplayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(int.parse('FF${registration.statusColor}', radix: 16)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Event details
              if (registration.event != null) ...[
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      _formatEventDate(registration.event!['date']),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      _formatEventTime(registration.event!['start_time'], registration.event!['end_time']),
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                if (registration.event!['location'] != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          registration.event!['location'],
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              const SizedBox(height: 12),
              
              // Registration details
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Registered: ${registration.formattedRegisteredDate}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              
              // Waitlist info
              if (registration.onWaitlist) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hourglass_empty, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'You are on the waitlist. You will be notified if a spot becomes available.',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Check-in code
              if (registration.checkinCode != null && registration.isConfirmed) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code, size: 16, color: Color(0xFF6C63FF)),
                      const SizedBox(width: 8),
                      const Text(
                        'Check-in Code: ',
                        style: TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        registration.checkinCode!,
                        style: const TextStyle(
                          color: Color(0xFF6C63FF),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Action buttons
              const SizedBox(height: 16),
              Row(
                children: [
                  if (registration.isConfirmed && !registration.onWaitlist) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showQRCode(registration),
                        icon: const Icon(Icons.qr_code, size: 16),
                        label: const Text('View QR Code'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6C63FF),
                          side: const BorderSide(color: Color(0xFF6C63FF)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _unregisterFromEvent(registration, registrationService),
                      icon: const Icon(Icons.cancel, size: 16),
                      label: const Text('Unregister'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
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
  
  String _formatEventDate(String? date) {
    if (date == null) return 'Date TBD';
    try {
      final parsedDate = DateTime.parse(date);
      return '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
    } catch (e) {
      return date;
    }
  }
  
  String _formatEventTime(String? startTime, String? endTime) {
    if (startTime == null) return 'Time TBD';
    if (endTime == null) return startTime;
    return '$startTime - $endTime';
  }
  
  IconData _getEmptyIcon(String filter) {
    switch (filter) {
      case 'confirmed': return Icons.check_circle_outline;
      case 'pending': return Icons.pending_actions;
      case 'waitlist': return Icons.hourglass_empty;
      default: return Icons.event_note;
    }
  }
  
  String _getEmptyMessage(String filter) {
    switch (filter) {
      case 'confirmed': return 'No confirmed registrations';
      case 'pending': return 'No pending registrations';
      case 'waitlist': return 'No waitlist registrations';
      default: return 'No registrations found';
    }
  }
  
  String _getEmptySubtitle(String filter) {
    switch (filter) {
      case 'confirmed': return 'You haven\'t confirmed any registrations yet';
      case 'pending': return 'You don\'t have any pending registrations';
      case 'waitlist': return 'You\'re not on any waitlists';
      default: return 'You haven\'t registered for any events yet';
    }
  }
  
  void _showRegistrationDetails(RegistrationModel registration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registration Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Event', registration.eventTitle),
              _buildDetailRow('Status', registration.statusDisplayName),
              if (registration.onWaitlist)
                _buildDetailRow('Waitlist', 'Yes'),
              _buildDetailRow('Registered', registration.formattedRegisteredDate),
              if (registration.checkinCode != null)
                _buildDetailRow('Check-in Code', registration.checkinCode!),
              if (registration.feePaid)
                _buildDetailRow('Fee Status', 'Paid'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF2D3748)),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showQRCode(RegistrationModel registration) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: const Icon(
                Icons.qr_code,
                size: 200,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Check-in Code: ${registration.checkinCode ?? 'N/A'}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _unregisterFromEvent(RegistrationModel registration, RegistrationService registrationService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unregister from Event'),
        content: Text(
          'Are you sure you want to unregister from "${registration.eventTitle}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await registrationService.unregisterFromEvent(registration.eventId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Successfully unregistered from event'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(registrationService.error.value ?? 'Failed to unregister'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Unregister'),
          ),
        ],
      ),
    );
  }
}
