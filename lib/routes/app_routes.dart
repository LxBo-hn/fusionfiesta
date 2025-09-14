import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../models/event.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/email_verification_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/events/events_list_screen.dart';
import '../screens/events/event_detail_screen.dart';
import '../screens/events/registration_qr_screen.dart';
import '../screens/events/feedback_screen.dart';
import '../screens/media/media_gallery_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/organizer/registrants_screen.dart';
import '../screens/organizer/create_event_screen.dart';
import '../screens/organizer/edit_event_screen.dart';
import '../screens/organizer/qr_scanner_screen.dart';
import '../screens/organizer/qr_generator_screen.dart';
import '../models/api_event.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/registrations/my_registrations_screen.dart';
import '../screens/dashboards/student/student_dashboard.dart';
import '../screens/dashboards/organizer/organizer_dashboard.dart';

class AppRoutes {
	static Map<String, WidgetBuilder> get routes => {
		SplashScreen.routeName: (_) => const SplashScreen(),
		RoleSelectionScreen.routeName: (_) => const RoleSelectionScreen(),
		LoginScreen.routeName: (_) => const LoginScreen(),
		SignUpScreen.routeName: (_) => const SignUpScreen(),
		ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
		ResetPasswordScreen.routeName: (context) {
			final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
			final email = args?['email'] as String?;
			final token = args?['token'] as String?;
			if (email == null || token == null) {
				return const Scaffold(
					body: Center(child: Text('Invalid reset link')),
				);
			}
			return ResetPasswordScreen(email: email, token: token);
		},
		EmailVerificationScreen.routeName: (_) => const EmailVerificationScreen(),
		HomeScreen.routeName: (_) => const HomeScreen(),
		EventsListScreen.routeName: (_) => const EventsListScreen(),
		EventDetailScreen.routeName: (_) => const EventDetailScreen(),
		RegistrationQRScreen.routeName: (_) => const RegistrationQRScreen(),
		FeedbackScreen.routeName: (context) {
			final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
			final event = args?['event'] as EventModel?;
			if (event == null) {
				return const Scaffold(
					body: Center(child: Text('Event not found')),
				);
			}
			return FeedbackScreen(event: event);
		},
		MediaGalleryScreen.routeName: (context) {
			final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
			return MediaGalleryScreen(
				eventId: args?['eventId'] as int?,
				type: args?['type'] as String?,
				status: args?['status'] as String?,
			);
		},
		NotificationsScreen.routeName: (_) => const NotificationsScreen(),
		RegistrantsScreen.routeName: (context) {
			final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
			final event = args?['event'] as EventModel?;
			if (event == null) {
				return const Scaffold(
					body: Center(child: Text('Event not found')),
				);
			}
			return RegistrantsScreen(event: event);
		},
		ProfileScreen.routeName: (_) => const ProfileScreen(),
		MyRegistrationsScreen.routeName: (_) => const MyRegistrationsScreen(),
		StudentDashboard.routeName: (_) => const StudentDashboard(),
		OrganizerDashboard.routeName: (_) => const OrganizerDashboard(),
		CreateEventScreen.routeName: (_) => const CreateEventScreen(),
		EditEventScreen.routeName: (context) {
			final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
			final event = args?['event'] as ApiEventModel?;
			if (event == null) {
				return const Scaffold(
					body: Center(child: Text('Event not found')),
				);
			}
			return EditEventScreen(event: event);
		},
		QRScannerScreen.routeName: (context) {
			final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
			final event = args?['event'] as EventModel?;
			if (event == null) {
				return const Scaffold(
					body: Center(child: Text('Event not found')),
				);
			}
			return QRScannerScreen(event: event);
		},
		QRGeneratorScreen.routeName: (context) {
			final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
			final event = args?['event'] as EventModel?;
			if (event == null) {
				return const Scaffold(
					body: Center(child: Text('Event not found')),
				);
			}
			return QRGeneratorScreen(event: event);
		},
	};
}