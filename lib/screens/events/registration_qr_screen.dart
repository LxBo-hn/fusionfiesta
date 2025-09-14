import 'package:flutter/material.dart';
import '../../models/event.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RegistrationQRScreen extends StatelessWidget {
	static const String routeName = '/registration-qr';
	const RegistrationQRScreen({super.key});

	@override
	Widget build(BuildContext context) {
		final Object? rawArgs = ModalRoute.of(context)?.settings.arguments;
		final Map<String, dynamic> args = rawArgs is Map<String, dynamic> ? rawArgs : <String, dynamic>{};
		final EventModel? event = args['event'] is EventModel ? args['event'] as EventModel : null;
		final String code = args['code'] is String && (args['code'] as String).isNotEmpty
			? args['code'] as String
			: 'REG-${DateTime.now().millisecondsSinceEpoch}';
		return Scaffold(
			appBar: AppBar(title: const Text('Check-in QR')),
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.all(16),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.center,
						children: [
							Text(event?.title ?? 'Event', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
							const SizedBox(height: 16),
							Expanded(
								child: Center(
									child: QrImageView(
										data: code,
										version: QrVersions.auto,
										size: 260,
										backgroundColor: Colors.white,
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
