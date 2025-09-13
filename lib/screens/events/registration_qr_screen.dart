import 'package:flutter/material.dart';
import '../../models/event.dart';

class RegistrationQRScreen extends StatelessWidget {
	static const String routeName = '/registration-qr';
	const RegistrationQRScreen({super.key});

	@override
	Widget build(BuildContext context) {
		final Map args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? <String, dynamic>{};
		final EventModel event = args['event'] as EventModel;
		final String code = args['code'] as String? ?? 'REG-${DateTime.now().millisecondsSinceEpoch}';
		return Scaffold(
			appBar: AppBar(title: const Text('Check-in QR')),
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.center,
						children: [
							Text(event.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
							const SizedBox(height: 16),
							Expanded(
								child: Center(
									child: Container(
										width: 260,
										height: 260,
										decoration: BoxDecoration(
											borderRadius: BorderRadius.circular(16),
											border: Border.all(color: Colors.black12),
											color: Colors.white,
											boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 6))],
										),
										child: const Text('QR', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
									),
								),
							),
							const SizedBox(height: 12),
							Text('Code: $code', style: Theme.of(context).textTheme.titleMedium),
							const SizedBox(height: 12),
							Row(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									FilledButton(onPressed: () {}, child: const Text('Save')),
									const SizedBox(width: 8),
									OutlinedButton(onPressed: () {}, child: const Text('Share')),
								],
							),
						],
					),
				),
			),
		);
	}
}
