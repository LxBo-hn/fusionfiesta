import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/role_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/events/events_list_screen.dart';
import '../screens/events/event_detail_screen.dart';
import '../screens/events/registration_qr_screen.dart';
import '../screens/dashboards/student/student_dashboard.dart';
import '../screens/dashboards/organizer/organizer_dashboard.dart';
import '../screens/dashboards/admin/admin_dashboard.dart';

class AppRoutes {
	static Map<String, WidgetBuilder> get routes => {
		SplashScreen.routeName: (_) => const SplashScreen(),
		RoleSelectionScreen.routeName: (_) => const RoleSelectionScreen(),
		LoginScreen.routeName: (_) => const LoginScreen(),
		SignUpScreen.routeName: (_) => const SignUpScreen(),
		ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),
		HomeScreen.routeName: (_) => const HomeScreen(),
		EventsListScreen.routeName: (_) => const EventsListScreen(),
		EventDetailScreen.routeName: (_) => const EventDetailScreen(),
		RegistrationQRScreen.routeName: (_) => const RegistrationQRScreen(),
		StudentDashboard.routeName: (_) => const StudentDashboard(),
		OrganizerDashboard.routeName: (_) => const OrganizerDashboard(),
		AdminDashboard.routeName: (_) => const AdminDashboard(),
	};
}