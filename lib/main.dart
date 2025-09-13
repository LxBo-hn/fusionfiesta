import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'screens/splash/splash_screen.dart';

void main() {
	runApp(const FusionFiestaApp());
}

class FusionFiestaApp extends StatelessWidget {
	const FusionFiestaApp({super.key});

	@override
	Widget build(BuildContext context) {
		final theme = ThemeData(
			colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
			useMaterial3: true,
			fontFamily: 'Roboto',
		);

		return MaterialApp(
			title: 'FusionFiesta',
			debugShowCheckedModeBanner: false,
			theme: theme,
			initialRoute: SplashScreen.routeName,
			routes: AppRoutes.routes,
		);
	}
}
