import 'package:flutter/material.dart';
import '../../screens/auth/role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
	static const String routeName = '/';
	const SplashScreen({super.key});

	@override
	State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
	// Assets and content per page
	static const List<String> imagePaths = [
		'assets/splash/onboarding_1.png',
		'assets/splash/onboarding_2.png',
		'assets/splash/onboarding_3.png',
		'assets/splash/onboarding_4.png',
	];

	static const List<String> titles = [
		'Sign Up For A Free\nAccount',
		'Discover Events\nAround Campus',
		'Register & Get\nInstant Updates',
		'Earn Certificates\nFor Participation',
	];

	static const List<String> descriptions = [
		'In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document.',
		'Browse, filter, and search hundreds of events from clubs and departments with ease.',
		'Receive role-based notifications and reminders so you never miss a session.',
		'Download digital certificates and share your achievements instantly.',
	];

	final PageController _controller = PageController();
	int _current = 0;

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	void _onPageChanged(int index) {
		setState(() => _current = index);
	}

	void _nextOrStart() {
		if (_current < imagePaths.length - 1) {
			_controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
			return;
		}
		Navigator.of(context).pushReplacementNamed(RoleSelectionScreen.routeName);
	}

	@override
	Widget build(BuildContext context) {
		final Color primary = Theme.of(context).colorScheme.primary;
		return Scaffold(
			body: Stack(
				children: [
					// Swipeable pages with images
					Positioned.fill(
						child: PageView.builder(
							controller: _controller,
							onPageChanged: _onPageChanged,
							itemCount: imagePaths.length,
							itemBuilder: (_, index) {
								final String path = imagePaths[index];
								return Stack(
									fit: StackFit.expand,
									children: [
										Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300)),
										// Subtle top-to-bottom fade to ensure text legibility
										Container(
											decoration: const BoxDecoration(
												gradient: LinearGradient(
													begin: Alignment.topCenter,
													end: Alignment.bottomCenter,
													colors: [Color(0x00000000), Color(0xA6000000)],
												),
											),
										),
									],
								);
							},
						),
					),
					// Bottom content overlay
					Positioned(
						left: 0,
						right: 0,
						bottom: 0,
						child: Container(
							padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
							child: SafeArea(
								top: false,
								child: Column(
									mainAxisSize: MainAxisSize.min,
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											titles[_current],
											style: Theme.of(context).textTheme.headlineSmall?.copyWith(
												color: Colors.white,
												fontWeight: FontWeight.w700,
											),
										),
										const SizedBox(height: 12),
										Text(
											descriptions[_current],
											style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70, height: 1.4),
										),
										const SizedBox(height: 16),
										Row(
											mainAxisAlignment: MainAxisAlignment.center,
											children: List.generate(imagePaths.length, (i) => _containerDot(i == _current ? Colors.white : Colors.white38)),
										),
										const SizedBox(height: 16),
										Row(
											children: [
												TextButton(
													onPressed: () => Navigator.of(context).pushReplacementNamed(RoleSelectionScreen.routeName),
													child: const Text('Skip', style: TextStyle(color: Colors.white70)),
												),
												const Spacer(),
												SizedBox(
													height: 48,
													child: FilledButton(
														style: FilledButton.styleFrom(
															backgroundColor: primary,
															shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
														),
														onPressed: _nextOrStart,
														child: Text(_current == imagePaths.length - 1 ? 'Get Started' : 'Next'),
													),
												),
											],
										),
									],
								),
							),
						),
					),
				],
			),
			backgroundColor: Colors.black,
		);
	}

	Widget _containerDot(Color color) {
		return Container(
			margin: const EdgeInsets.symmetric(horizontal: 6),
			width: 10,
			height: 10,
			decoration: BoxDecoration(color: color, shape: BoxShape.circle),
		);
	}
}
