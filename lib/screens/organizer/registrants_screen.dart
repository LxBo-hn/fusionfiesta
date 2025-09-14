import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/organizer_store.dart';
import '../../models/registration.dart';
import '../../models/event.dart';

class RegistrantsScreen extends StatefulWidget {
  static const String routeName = '/registrants';
  final EventModel event;
  
  const RegistrantsScreen({super.key, required this.event});

  @override
  State<RegistrantsScreen> createState() => _RegistrantsScreenState();
}

class _RegistrantsScreenState extends State<RegistrantsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load registrants on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrganizerStore>().loadEventRegistrants(int.parse(widget.event.id));
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Registrants - ${widget.event.title}',
          style: const TextStyle(
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
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => context.read<OrganizerStore>().loadEventRegistrants(int.parse(widget.event.id)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search registrants...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          
          // Registrants list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRegistrantsList('all'),
                _buildRegistrantsList('pending'),
                _buildRegistrantsList('approved'),
                _buildRegistrantsList('rejected'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRegistrantsList(String filter) {
    return Consumer<OrganizerStore>(
      builder: (context, organizerStore, child) {
        final registrants = organizerStore.getRegistrantsForEvent(int.parse(widget.event.id));
        
        if (organizerStore.isLoading.value && registrants.isEmpty) {
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
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error loading registrants',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  organizerStore.error.value!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => organizerStore.loadEventRegistrants(int.parse(widget.event.id)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        // Filter registrants
        List<RegistrationModel> filteredRegistrants = registrants;
        
        switch (filter) {
          case 'pending':
            filteredRegistrants = registrants.where((r) => r.isPending).toList();
            break;
          case 'approved':
            filteredRegistrants = registrants.where((r) => r.isApproved).toList();
            break;
          case 'rejected':
            filteredRegistrants = registrants.where((r) => r.isRejected).toList();
            break;
        }
        
        // Apply search filter
        if (_searchQuery.isNotEmpty) {
          filteredRegistrants = filteredRegistrants.where((r) {
            return r.userName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   r.userEmail.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();
        }
        
        if (filteredRegistrants.isEmpty) {
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
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredRegistrants.length,
          itemBuilder: (context, index) {
            final registrant = filteredRegistrants[index];
            return _buildRegistrantCard(registrant);
          },
        );
      },
    );
  }
  
  Widget _buildRegistrantCard(RegistrationModel registrant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: _getStatusColor(registrant.status).withOpacity(0.1),
              child: Text(
                registrant.userName.isNotEmpty ? registrant.userName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: _getStatusColor(registrant.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    registrant.userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    registrant.userEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(registrant.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          registrant.statusDisplayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(registrant.status),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Registered: ${registrant.formattedRegisteredDate}',
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
            
            // Actions
            PopupMenuButton<String>(
              onSelected: (value) => _handleAction(value, registrant),
              itemBuilder: (context) => [
                if (registrant.isPending) ...[
                  const PopupMenuItem(
                    value: 'approve',
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('Approve'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reject',
                    child: Row(
                      children: [
                        Icon(Icons.close, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Reject'),
                      ],
                    ),
                  ),
                ],
                const PopupMenuItem(
                  value: 'view_details',
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
              ],
              child: const Icon(
                Icons.more_vert,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFFF9800); // Orange
      case 'approved': return const Color(0xFF4CAF50); // Green
      case 'rejected': return const Color(0xFFF44336); // Red
      case 'cancelled': return const Color(0xFF9E9E9E); // Gray
      default: return const Color(0xFF6C63FF); // Purple
    }
  }
  
  IconData _getEmptyIcon(String filter) {
    switch (filter) {
      case 'pending': return Icons.pending_actions;
      case 'approved': return Icons.check_circle_outline;
      case 'rejected': return Icons.cancel_outlined;
      default: return Icons.people_outline;
    }
  }
  
  String _getEmptyMessage(String filter) {
    switch (filter) {
      case 'pending': return 'No pending registrations';
      case 'approved': return 'No approved registrations';
      case 'rejected': return 'No rejected registrations';
      default: return 'No registrants found';
    }
  }
  
  String _getEmptySubtitle(String filter) {
    switch (filter) {
      case 'pending': return 'All registrations have been processed';
      case 'approved': return 'No registrations have been approved yet';
      case 'rejected': return 'No registrations have been rejected';
      default: return 'No one has registered for this event yet';
    }
  }
  
  void _handleAction(String action, RegistrationModel registrant) {
    switch (action) {
      case 'approve':
        _showApprovalDialog(registrant, 'approve');
        break;
      case 'reject':
        _showApprovalDialog(registrant, 'reject');
        break;
      case 'view_details':
        _showRegistrantDetails(registrant);
        break;
    }
  }
  
  void _showApprovalDialog(RegistrationModel registrant, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action == 'approve' ? 'Approve' : 'Reject'} Registration'),
        content: Text(
          'Are you sure you want to ${action} ${registrant.userName}\'s registration?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement approval/rejection logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Registration ${action}d successfully'),
                  backgroundColor: action == 'approve' ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'approve' ? Colors.green : Colors.red,
            ),
            child: Text(action == 'approve' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }
  
  void _showRegistrantDetails(RegistrationModel registrant) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registration Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name', registrant.userName),
            _buildDetailRow('Email', registrant.userEmail),
            _buildDetailRow('Status', registrant.statusDisplayName),
            _buildDetailRow('Registered', registrant.formattedRegisteredDate),
            if (registrant.approvedAt != null)
              _buildDetailRow('Approved', registrant.formattedApprovedDate),
            if (registrant.notes != null && registrant.notes!.isNotEmpty)
              _buildDetailRow('Notes', registrant.notes!),
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
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
}
