import 'package:flutter/material.dart';
import 'login_screen.dart';

enum AppRole { student, organizer, admin }

class RoleSelectionScreen extends StatelessWidget {
	static const String routeName = '/role';
	const RoleSelectionScreen({super.key});

	void _goToLogin(BuildContext context, AppRole role) {
		Navigator.of(context).pushNamed(LoginScreen.routeName, arguments: role);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(title: const Text('Chọn vai trò')),
			body: Padding(
				padding: const EdgeInsets.all(16),
				child: Column(
					children: [
						_OptionCard(
							icon: Icons.school,
							title: 'Sinh viên',
							subtitle: 'Duyệt và đăng ký sự kiện',
							onTap: () => _goToLogin(context, AppRole.student),
						),
						_OptionCard(
							icon: Icons.event_available,
							title: 'Người tổ chức',
							subtitle: 'Tạo và quản lý sự kiện',
							onTap: () => _goToLogin(context, AppRole.organizer),
						),
						_OptionCard(
							icon: Icons.admin_panel_settings,
							title: 'Quản trị viên',
							subtitle: 'Phê duyệt & giám sát',
							onTap: () => _goToLogin(context, AppRole.admin),
						),
					],
				),
			),
		);
	}
}

class _OptionCard extends StatelessWidget {
	final IconData icon;
	final String title;
	final String subtitle;
	final VoidCallback onTap;
	const _OptionCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

	@override
	Widget build(BuildContext context) {
		return Card(
			margin: const EdgeInsets.symmetric(vertical: 8),
			child: ListTile(
				leading: Icon(icon, size: 32),
				title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
				subtitle: Text(subtitle),
				onTap: onTap,
			),
		);
	}
}
