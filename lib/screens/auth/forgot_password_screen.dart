import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'role_selection_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
	static const String routeName = '/forgot-password';
	const ForgotPasswordScreen({super.key});

	@override
	State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	final TextEditingController _emailController = TextEditingController();
	bool _isLoading = false;

	static const String logoPath = 'assets/logo/logo.png';

	@override
	void dispose() {
		_emailController.dispose();
		super.dispose();
	}

	void _goBack() {
		if (Navigator.of(context).canPop()) {
			Navigator.of(context).pop();
		} else {
			Navigator.of(context).pushReplacementNamed(RoleSelectionScreen.routeName);
		}
	}

	Future<void> _submit() async {
		if (!_formKey.currentState!.validate()) return;
		setState(() => _isLoading = true);
		await Future.delayed(const Duration(milliseconds: 700));
		setState(() => _isLoading = false);
		if (mounted) Navigator.of(context).pop();
	}

	@override
	Widget build(BuildContext context) {
		final Color primary = Theme.of(context).colorScheme.primary;
		return Scaffold(
			backgroundColor: const Color(0xFFF0F0F0),
			appBar: AppBar(
				leading: IconButton(onPressed: _goBack, icon: const Icon(Icons.arrow_back)),
				backgroundColor: Colors.transparent,
				foregroundColor: Colors.black87,
				elevation: 0,
				surfaceTintColor: Colors.transparent,
			),
			body: SafeArea(
				child: SingleChildScrollView(
					padding: const EdgeInsets.all(16),
					child: Column(
						children: [
							Container(
								padding: const EdgeInsets.all(16),
								decoration: BoxDecoration(
									color: Colors.white,
									borderRadius: BorderRadius.circular(18),
									boxShadow: [
										BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6)),
									],
								),
								child: Form(
									key: _formKey,
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											SizedBox(
												height: 100,
												child: Center(
													child: Image.asset(
														logoPath,
														fit: BoxFit.contain,
														height: 80,
														errorBuilder: (_, __, ___) => const SizedBox(height: 80),
												),
												),
											),
											Text('Forgot Password', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
											const SizedBox(height: 6),
											Text('Reset your password', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
											const SizedBox(height: 20),

											Text('Email Address', style: Theme.of(context).textTheme.labelLarge),
											TextFormField(
												controller: _emailController,
												keyboardType: TextInputType.emailAddress,
												decoration: const InputDecoration(isDense: true, border: UnderlineInputBorder(), hintText: 'Email Address'),
												validator: (v) => (v == null || v.isEmpty) ? 'Nhập email' : null,
											),
											const SizedBox(height: 16),
											Text('You will receive an email with a link to reset your password.', style: Theme.of(context).textTheme.bodyMedium),
											const SizedBox(height: 16),
											SizedBox(
												width: double.infinity,
												height: 48,
												child: FilledButton(
													style: FilledButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
													onPressed: _isLoading ? null : _submit,
													child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Get My Password'),
												),
											),
										],
									),
								),
							),

							const SizedBox(height: 12),
							Row(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									const Text('Back to '),
									TextButton(onPressed: () => Navigator.of(context).pushReplacementNamed(LoginScreen.routeName), child: Text('Log in', style: TextStyle(color: primary))),
								],
							),
						],
					),
				),
			),
		);
	}
}


