import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../state/registration_store.dart';
import 'registration_qr_screen.dart';

class EventDetailScreen extends StatelessWidget {
	static const String routeName = '/event-detail';
	const EventDetailScreen({super.key});

	@override
	Widget build(BuildContext context) {
		final EventModel event = ModalRoute.of(context)!.settings.arguments as EventModel;
		final Color primary = Theme.of(context).colorScheme.primary;
		return Scaffold(
			appBar: AppBar(
				leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
				title: const Text('Event Details'),
				actions: const [
					Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: CircleAvatar(radius: 14, child: Icon(Icons.notifications, size: 16))),
					Padding(padding: EdgeInsets.only(right: 12), child: CircleAvatar(radius: 14, child: Icon(Icons.settings, size: 16))),
				],
			),
			body: Stack(
				children: [
					Positioned.fill(
						child: Image.asset(event.imageAsset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300)),
					),
					Align(
						alignment: Alignment.bottomCenter,
						child: Container(
							margin: const EdgeInsets.all(16),
							padding: const EdgeInsets.all(16),
							decoration: BoxDecoration(
								color: Colors.black.withOpacity(0.55),
								borderRadius: BorderRadius.circular(16),
							),
							child: Column(
								mainAxisSize: MainAxisSize.min,
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(event.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
									const SizedBox(height: 8),
									Text(event.description, style: const TextStyle(color: Colors.white70, height: 1.4)),
									const SizedBox(height: 12),
									Row(
										children: [
											FilledButton(
												style: FilledButton.styleFrom(
													backgroundColor: primary,
													shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
													padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
												),
												onPressed: () {
													_showRegisterSheet(context, event);
												},
												child: const Text('Register'),
											),
											const SizedBox(width: 10),
											OutlinedButton(
												style: OutlinedButton.styleFrom(
													foregroundColor: Colors.white70,
													side: const BorderSide(color: Colors.white38),
													shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
													padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
												),
												onPressed: () {},
												child: const Text('Share'),
											),
										],
									),
								],
							),
						),
					),
				],
			),
		);
	}

	void _showRegisterSheet(BuildContext context, EventModel event) {
		showModalBottomSheet(
			context: context,
			isScrollControlled: true,
			backgroundColor: Colors.white,
			shape: const RoundedRectangleBorder(
				borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
			),
			builder: (ctx) {
				bool agree = false;
				final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
				return Padding(
					padding: EdgeInsets.only(bottom: bottomInset),
					child: StatefulBuilder(
						builder: (ctx, setState) {
							return SingleChildScrollView(
								padding: const EdgeInsets.all(16),
								child: Column(
									mainAxisSize: MainAxisSize.min,
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Center(
											child: Container(
												width: 48,
												height: 4,
												margin: const EdgeInsets.only(bottom: 12),
												decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
											),
										),
										Text(event.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
										const SizedBox(height: 4),
										Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54)),
										const SizedBox(height: 16),
										TextFormField(
											decoration: const InputDecoration(
												labelText: 'Full Name',
												border: UnderlineInputBorder(),
												isDense: true,
											),
										),
										const SizedBox(height: 12),
										TextFormField(
											keyboardType: TextInputType.emailAddress,
											decoration: const InputDecoration(
												labelText: 'Email Address',
												border: UnderlineInputBorder(),
												isDense: true,
											),
										),
										const SizedBox(height: 12),
										Row(
											children: [
												Checkbox(value: agree, onChanged: (v) => setState(() => agree = v ?? false)),
												const Expanded(child: Text('I agree to the Terms and Privacy Policy.')),
											],
										),
										const SizedBox(height: 8),
										SizedBox(
											width: double.infinity,
											height: 48,
											child: FilledButton(
												onPressed: agree
													? () {
														RegistrationStore.instance.register(event);
														Navigator.of(ctx).pop();
														Navigator.of(context).pushNamed(
															RegistrationQRScreen.routeName,
															arguments: {'event': event, 'code': 'REG-${event.id.toUpperCase()}'},
														);
													}
													: null,
												child: const Text('Confirm Registration'),
											),
										),
										const SizedBox(height: 8),
									],
								),
							);
						},
					),
				);
			},
		);
	}
}
