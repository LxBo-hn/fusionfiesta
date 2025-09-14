import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_routes.dart';
import 'screens/splash/splash_screen.dart';
import 'state/organizer_store.dart';
import 'state/admin_store.dart';
import 'state/certificates_store.dart';
import 'services/auth_service.dart';
import 'services/email_verification_service.dart';
import 'services/feedback_service.dart';
import 'services/media_service.dart';
import 'services/notification_service.dart';
import 'services/password_reset_service.dart';
import 'services/profile_service.dart';
import 'services/registration_service.dart';

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

		return MultiProvider(
			providers: [
				ChangeNotifierProvider(create: (_) => AuthService.instance),
				ChangeNotifierProvider(create: (_) => OrganizerStore.instance),
				ChangeNotifierProvider(create: (_) => AdminStore.instance),
				ChangeNotifierProvider(create: (_) => CertificatesStore.instance),
				ChangeNotifierProvider(create: (_) => EmailVerificationService.instance),
				ChangeNotifierProvider(create: (_) => FeedbackService.instance),
				ChangeNotifierProvider(create: (_) => MediaService.instance),
				ChangeNotifierProvider(create: (_) => NotificationService.instance),
				ChangeNotifierProvider(create: (_) => PasswordResetService.instance),
				ChangeNotifierProvider(create: (_) => ProfileService.instance),
				ChangeNotifierProvider(create: (_) => RegistrationService.instance),
			],
			child: MaterialApp(
				title: 'FusionFiesta',
				debugShowCheckedModeBanner: false,
				theme: theme,
				initialRoute: SplashScreen.routeName,
				routes: AppRoutes.routes,
			),
		);
	}
}
