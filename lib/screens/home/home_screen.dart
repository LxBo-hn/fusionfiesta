import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
	static const String routeName = '/home';
	const HomeScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('FusionFiesta Home')),
			body: ListView.separated(
				padding: const EdgeInsets.all(16),
				itemCount: 8,
				separatorBuilder: (_, __) => const SizedBox(height: 12),
				itemBuilder: (_, i) => Card(
					child: ListTile(
						title: Text('Sự kiện demo #${i + 1}'),
						subtitle: const Text('Mô tả ngắn sự kiện... (mock)'),
						trailing: FilledButton.tonal(onPressed: () {}, child: const Text('Chi tiết')),
					),
				),
			),
		);
	}
}


