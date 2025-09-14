import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../state/organizer_store.dart';
import 'event_detail_screen.dart';

enum EventStatusFilter {
	all,
	upcoming,
	ongoing,
	completed,
}

class EventsListScreen extends StatefulWidget {
	static const String routeName = '/events';
	const EventsListScreen({super.key});

	@override
	State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> with TickerProviderStateMixin {
	late TabController _tabController;
	String _searchQuery = '';

	@override
	void initState() {
		super.initState();
		_tabController = TabController(length: 4, vsync: this);
		// Load events when screen initializes
		WidgetsBinding.instance.addPostFrameCallback((_) {
			Provider.of<OrganizerStore>(context, listen: false).loadEvents();
		});
	}

	@override
	void dispose() {
		_tabController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final Color primary = Theme.of(context).colorScheme.primary;
		return Scaffold(
			appBar: AppBar(
				automaticallyImplyLeading: false,
				title: const Text('Sự kiện'),
				actions: const [
					Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: CircleAvatar(radius: 14, child: Icon(Icons.notifications, size: 16))),
					Padding(padding: EdgeInsets.only(right: 12), child: CircleAvatar(radius: 14, child: Icon(Icons.settings, size: 16))),
				],
				bottom: TabBar(
					controller: _tabController,
					tabs: const [
						Tab(text: 'Tất cả', icon: Icon(Icons.list)),
						Tab(text: 'Sắp diễn ra', icon: Icon(Icons.schedule)),
						Tab(text: 'Đang diễn ra', icon: Icon(Icons.play_circle)),
						Tab(text: 'Đã diễn ra', icon: Icon(Icons.check_circle)),
					],
				),
			),
			body: Column(
				children: [
					// Search bar
					Padding(
						padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
						child: Row(
							children: [
								Expanded(
									child: TextField(
										onChanged: (value) => setState(() => _searchQuery = value),
										decoration: InputDecoration(
											prefixIcon: const Icon(Icons.search),
											hintText: 'Tìm kiếm sự kiện...',
											filled: true,
											fillColor: Colors.grey.shade200,
											border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
										),
									),
								),
								const SizedBox(width: 8),
								CircleAvatar(
									backgroundColor: primary,
									child: const Icon(Icons.filter_list, color: Colors.white),
								),
							],
						),
					),
					// Tab content
					Expanded(
						child: TabBarView(
							controller: _tabController,
							children: [
								_EventsTab(filter: EventStatusFilter.all, searchQuery: _searchQuery),
								_EventsTab(filter: EventStatusFilter.upcoming, searchQuery: _searchQuery),
								_EventsTab(filter: EventStatusFilter.ongoing, searchQuery: _searchQuery),
								_EventsTab(filter: EventStatusFilter.completed, searchQuery: _searchQuery),
							],
						),
					),
				],
			),
		);
	}

}

class _EventsTab extends StatelessWidget {
	final EventStatusFilter filter;
	final String searchQuery;
	
	const _EventsTab({required this.filter, required this.searchQuery});

	@override
	Widget build(BuildContext context) {
		return Consumer<OrganizerStore>(
			builder: (context, organizerStore, child) {
				if (organizerStore.isLoading.value) {
					return const Center(child: CircularProgressIndicator());
				}
				
				if (organizerStore.error.value != null) {
					return Center(
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Icon(Icons.error, size: 64, color: Colors.red.shade300),
								const SizedBox(height: 16),
								Text(
									organizerStore.error.value!,
									style: const TextStyle(fontSize: 16),
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
				
				List<EventModel> events = organizerStore.events.value;
				
				// Filter by status
				switch (filter) {
					case EventStatusFilter.upcoming:
						events = events.where((e) => e.eventStatus == EventStatus.upcoming).toList();
						break;
					case EventStatusFilter.ongoing:
						events = events.where((e) => e.eventStatus == EventStatus.ongoing).toList();
						break;
					case EventStatusFilter.completed:
						events = events.where((e) => e.eventStatus == EventStatus.completed).toList();
						break;
					case EventStatusFilter.all:
					default:
						// No additional filtering
						break;
				}
				
				// Filter by search query
				if (searchQuery.isNotEmpty) {
					events = events.where((e) => 
						e.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
						e.description.toLowerCase().contains(searchQuery.toLowerCase())
					).toList();
				}
				
				if (events.isEmpty) {
					return const Center(
						child: Column(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Icon(Icons.event_note, size: 64, color: Colors.grey),
								SizedBox(height: 16),
								Text(
									'Không có sự kiện nào',
									style: TextStyle(fontSize: 18, color: Colors.grey),
								),
							],
						),
					);
				}
				
				return ListView.separated(
					padding: const EdgeInsets.all(16),
					itemCount: events.length,
					separatorBuilder: (_, __) => const SizedBox(height: 12),
					itemBuilder: (context, index) => GestureDetector(
						onTap: () {
							Navigator.of(context).pushNamed(EventDetailScreen.routeName, arguments: events[index]);
						},
						child: _EventCard(event: events[index]),
					),
				);
			},
		);
	}
}

class _EventCard extends StatelessWidget {
	final EventModel event;
	const _EventCard({required this.event});

	@override
	Widget build(BuildContext context) {
		return Container(
			height: 130,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(16),
				gradient: const LinearGradient(colors: [Color(0xFFE3F2FD), Color(0xFFFFF3E0)]),
				boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4))],
			),
			child: Row(
				children: [
					ClipRRect(
						borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
						child: Container(
							width: 96, 
							height: double.infinity, 
							child: event.imageAsset.startsWith('http') 
								? Image.network(event.imageAsset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 32))
								: Image.asset(event.imageAsset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 32))
						),
					),
					Expanded(
						child: Padding(
							padding: const EdgeInsets.all(12),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								mainAxisSize: MainAxisSize.min,
								children: [
									// Status badge
									Container(
										padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
										decoration: BoxDecoration(
											color: event.statusColor.withOpacity(0.2),
											borderRadius: BorderRadius.circular(12),
											border: Border.all(color: event.statusColor, width: 1),
										),
										child: Text(
											event.statusDisplayText,
											style: TextStyle(
												color: event.statusColor,
												fontSize: 12,
												fontWeight: FontWeight.w600,
											),
										),
									),
									const SizedBox(height: 6),
									Text(event.dateText, style: Theme.of(context).textTheme.labelSmall),
									const SizedBox(height: 4),
									Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
									const SizedBox(height: 4),
									Expanded(
										child: Text(
											event.description,
											maxLines: 2,
											overflow: TextOverflow.ellipsis,
											style: const TextStyle(fontSize: 13),
										),
									),
								],
							),
						),
					),
				],
			),
		);
	}
}
