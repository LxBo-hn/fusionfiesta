import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/organizer_store.dart';

class HomeScreen extends StatelessWidget {
	static const String routeName = '/home';
	const HomeScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('FusionFiesta Home')),
			body: Consumer<OrganizerStore>(
				builder: (context, store, _) {
					if (store.isLoading.value) {
						return const Center(child: CircularProgressIndicator());
					}
					if (store.error.value != null) {
						return Center(child: Text(store.error.value!));
					}
					final items = store.events.value;
					if (items.isEmpty) {
						store.loadEvents();
						return const Center(child: CircularProgressIndicator());
					}
					return ListView.separated(
						padding: const EdgeInsets.all(16),
						itemCount: items.length,
						separatorBuilder: (_, __) => const SizedBox(height: 12),
						itemBuilder: (_, i) {
							final e = items[i];
							return Card(
								child: ListTile(
									title: Text(e.title),
									subtitle: Text(e.description, maxLines: 1, overflow: TextOverflow.ellipsis),
									trailing: FilledButton.tonal(onPressed: () {}, child: const Text('Chi tiết')),
								),
							);
						},
					);
				},
			),
		);
	}
}


