import 'package:flutter/material.dart';
import '../../models/event.dart';
import 'event_detail_screen.dart';

class EventsListScreen extends StatelessWidget {
	static const String routeName = '/events';
	const EventsListScreen({super.key});

	@override
	Widget build(BuildContext context) {
		final Color primary = Theme.of(context).colorScheme.primary;
		return Scaffold(
			appBar: AppBar(
				leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
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
						child: ListView.separated(
							padding: const EdgeInsets.all(16),
							itemCount: 10,
							separatorBuilder: (_, __) => const SizedBox(height: 12),
							itemBuilder: (_, i) => GestureDetector(
								onTap: () {
									final event = EventModel(
										id: 'e$i',
										title: 'Event title #${i + 1}',
										dateText: '15-03-2024',
										description: 'We\'re “Thinking Out Loud” here, but picture yourself at LIVE concert! The global sensation is bringing the tour for the first time ever...',
										imageAsset: 'assets/splash/onboarding_${(i % 4) + 1}.png',
									);
									Navigator.of(context).pushNamed(EventDetailScreen.routeName, arguments: event);
								},
								child: _EventCard(index: i),
							),
						),
					),
				],
			),
		);
	}
}

class _EventCard extends StatelessWidget {
	final int index;
	const _EventCard({required this.index});

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
						child: Container(width: 96, height: double.infinity, color: Colors.grey.shade300, child: const Icon(Icons.image, size: 32)),
					),
					Expanded(
						child: Padding(
							padding: const EdgeInsets.all(12),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text('15-03-2024', style: Theme.of(context).textTheme.labelSmall),
									const SizedBox(height: 4),
									Text('Event title #${index + 1}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
									const SizedBox(height: 4),
									Text(
										'Join us for an electrifying musical evening as FusionFiesta presents awesome events...',
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
