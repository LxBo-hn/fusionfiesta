import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../models/registration.dart';
import '../../services/registration_service.dart';
import '../../widgets/success_notification.dart';
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
									const SizedBox(height: 10),
									_builderCapacityRow(event),
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
												onPressed: () {
													Navigator.of(context).pushNamed(
														'/event-feedback',
														arguments: event,
													);
												},
												child: const Text('Đánh giá'),
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
				bool submitting = false;
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
										Row(
											children: [
												Checkbox(value: agree, onChanged: (v) => setState(() => agree = v ?? false)),
												const Expanded(child: Text('Tôi đồng ý với Điều khoản và Chính sách.')),
											],
										),
										const SizedBox(height: 8),
										SizedBox(
											width: double.infinity,
											height: 48,
											child: FilledButton(
												onPressed: agree && !submitting
													? () async {
														final eventId = int.tryParse(event.id);
														if (eventId == null) {
															ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID sự kiện không hợp lệ')));
															return;
														}
														setState(() => submitting = true);
														final res = await RegistrationService.instance.registerForEvent(eventId);
														setState(() => submitting = false);
														if (res['success'] == true) {
															final RegistrationModel reg = res['registration'] as RegistrationModel;
															if (context.mounted) Navigator.of(ctx).pop();
															
															// Show success notification
															if (context.mounted) {
																SuccessNotification.show(
																	context: context,
																	title: '🎉 Đăng ký thành công!',
																	message: 'Bạn đã đăng ký tham gia sự kiện "${event.title}" thành công. Mã QR của bạn đã được tạo.',
																	onDismiss: () {
																		// Navigate to QR screen after notification
																		Navigator.of(context).pushNamed(
																			RegistrationQRScreen.routeName,
																			arguments: {
																				'event': event,
																				'code': reg.checkinCode ?? reg.qrCode ?? 'REG-${reg.id}',
																			},
																		);
																	},
																);
															}
														} else {
															final String message = res['message'] ?? 'Đăng ký thất bại';
															final String type = res['error_type'] ?? 'unknown';
															if (context.mounted) {
																showDialog(
																	context: context,
																	builder: (_) {
																		final content = _friendlyRegistrationError(type, message);
																		final actions = <Widget>[
																			TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
																		];
																		if (type == 'profile_incomplete') {
																			actions.add(
																				FilledButton(
																					onPressed: () {
																						Navigator.pop(context);
																						Navigator.of(context).pushNamed('/profile');
																				},
																					child: const Text('Cập nhật hồ sơ'),
																				),
																			);
																		}
																		if (type == 'email_unverified') {
																			actions.add(
																				FilledButton(
																					onPressed: () {
																						Navigator.pop(context);
																						Navigator.of(context).pushNamed('/email-verification');
																				},
																					child: const Text('Xác thực email'),
																				),
																			);
																		}
																		return AlertDialog(
																			title: const Text('Không thể đăng ký'),
																			content: Text(content),
																			actions: actions,
																		);
																	},
																);
															}
														}
													}
													: null,
											child: submitting
												? const SizedBox(
													width: 20,
													height: 20,
													child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
												)
												: const Text('Xác nhận đăng ký'),
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

	String _friendlyRegistrationError(String type, String message) {
		switch (type) {
			case 'email_unverified':
				return 'Email của bạn chưa xác thực. Vui lòng xác thực email rồi thử lại.';
			case 'profile_incomplete':
				return 'Hồ sơ chưa đầy đủ (cần student_code và department_id). Vui lòng cập nhật hồ sơ.';
			case 'event_full':
				return 'Sự kiện đã hết chỗ.';
			case 'already_registered':
				return 'Bạn đã đăng ký sự kiện này.';
			default:
				return message;
		}
	}
}

Widget _builderCapacityRow(EventModel event) {
	final int capacity = event.maxAttendees ?? 0;
	final int taken = event.currentAttendees ?? 0;
	final int left = (capacity - taken) < 0 ? 0 : (capacity - taken);
	return Row(
		children: [
			const Icon(Icons.people, color: Colors.white70, size: 16),
			const SizedBox(width: 6),
			Text('Capacity: $capacity', style: const TextStyle(color: Colors.white70)),
			const SizedBox(width: 12),
			const Icon(Icons.event_seat, color: Colors.white70, size: 16),
			const SizedBox(width: 6),
			Text('Seats left: $left', style: const TextStyle(color: Colors.white70)),
		],
	);
}
