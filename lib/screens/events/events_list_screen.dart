import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../state/organizer_store.dart';
import 'event_detail_screen.dart';

class EventsListScreen extends StatefulWidget {
	static const String routeName = '/events';
	const EventsListScreen({super.key});

	@override
	State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
	@override
	void initState() {
		super.initState();
		// Load events when screen initializes
		WidgetsBinding.instance.addPostFrameCallback((_) {
			Provider.of<OrganizerStore>(context, listen: false).loadEvents();
		});
	}

	@override
	Widget build(BuildContext context) {
		final Color primary = Theme.of(context).colorScheme.primary;
		return Scaffold(
			appBar: AppBar(
				automaticallyImplyLeading: false,
				title: const Text('All Events'),
				actions: const [
					Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: CircleAvatar(radius: 14, child: Icon(Icons.notifications, size: 16))),
					Padding(padding: EdgeInsets.only(right: 12), child: CircleAvatar(radius: 14, child: Icon(Icons.settings, size: 16))),
				],
			),
			body: Column(
				children: [
					Padding(
						padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
						child: Row(
							children: [
								Expanded(
									child: TextField(
										decoration: InputDecoration(
											prefixIcon: const Icon(Icons.search),
											hintText: 'Search Event',
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
					Expanded(
						child: Consumer<OrganizerStore>(
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
													child: const Text('Retry'),
												),
											],
										),
									);
								}
								
								final events = organizerStore.events.value;
								if (events.isEmpty) {
									return const Center(
										child: Text('No events available'),
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
						),
					),
				],
			),
		);
	}
}

class _EventCard extends StatelessWidget {
	final EventModel event;
	const _EventCard({required this.event});

	@override
	Widget build(BuildContext context) {
		return Container(
			height: 110,
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
								children: [
									Text(event.dateText, style: Theme.of(context).textTheme.labelSmall),
									const SizedBox(height: 4),
									Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
									const SizedBox(height: 4),
									Text(
										event.description,
										maxLines: 2,
										overflow: TextOverflow.ellipsis,
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
