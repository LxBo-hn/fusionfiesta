import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

class SignUpScreen extends StatefulWidget {
	static const String routeName = '/signup';
	const SignUpScreen({super.key});

	@override
	State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
	final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
	final TextEditingController _firstNameController = TextEditingController();
	final TextEditingController _lastNameController = TextEditingController();
	final TextEditingController _emailController = TextEditingController();
	final TextEditingController _passwordController = TextEditingController();
	final TextEditingController _confirmPasswordController = TextEditingController();
	bool _agree = false;
	bool _isLoading = false;

	static const String logoPath = 'assets/logo/logo.png';

	@override
	void dispose() {
		_firstNameController.dispose();
		_lastNameController.dispose();
		_emailController.dispose();
		_passwordController.dispose();
		_confirmPasswordController.dispose();
		super.dispose();
	}

	void _goBack() {
		if (Navigator.of(context).canPop()) {
			Navigator.of(context).pop();
		} else {
			Navigator.of(context).pushReplacementNamed(RoleSelectionScreen.routeName);
		}
	}

	void _submit() async {
		if (!_formKey.currentState!.validate() || !_agree) return;
		setState(() => _isLoading = true);
		await Future.delayed(const Duration(milliseconds: 600));
		setState(() => _isLoading = false);
		Navigator.of(context).pop();
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
												height: 120,
												child: Center(
													child: Padding(
														padding: const EdgeInsets.symmetric(horizontal: 12),
														child: Image.asset(
															logoPath,
															fit: BoxFit.contain,
															width: double.infinity,
															height: 100,
															errorBuilder: (_, __, ___) {
															return Container(
																width: 200,
																height: 80,
																decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(8)),
																child: const Center(child: Text('Your Logo', style: TextStyle(color: Colors.black54))),
															);
														},
													),
												),
											),
											),
											const SizedBox(height: 4),
											Text('Sign Up', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
											const SizedBox(height: 6),
											Text('Create your account', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
											const SizedBox(height: 20),

											Row(
												children: [
													Expanded(
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																Text('First Name', style: Theme.of(context).textTheme.labelLarge),
																TextFormField(
																	controller: _firstNameController,
																	decoration: const InputDecoration(isDense: true, border: UnderlineInputBorder(), hintText: 'First name'),
																),
															],
														),
													),
													const SizedBox(width: 16),
													Expanded(
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																Text('Last Name', style: Theme.of(context).textTheme.labelLarge),
																TextFormField(
																	controller: _lastNameController,
																	decoration: const InputDecoration(isDense: true, border: UnderlineInputBorder(), hintText: 'Last name'),
																),
															],
														),
													),
												],
											),

											const SizedBox(height: 16),
											Text('Email Address', style: Theme.of(context).textTheme.labelLarge),
											TextFormField(
												controller: _emailController,
												keyboardType: TextInputType.emailAddress,
												decoration: const InputDecoration(isDense: true, border: UnderlineInputBorder(), hintText: 'Enter your email address'),
												validator: (v) => (v == null || v.isEmpty) ? 'Nhập email' : null,
											),

											const SizedBox(height: 16),
											Text('Password', style: Theme.of(context).textTheme.labelLarge),
											TextFormField(
												controller: _passwordController,
												obscureText: true,
												decoration: const InputDecoration(isDense: true, border: UnderlineInputBorder(), hintText: 'Enter your password'),
												validator: (v) => (v == null || v.isEmpty) ? 'Nhập mật khẩu' : null,
											),

											const SizedBox(height: 16),
											Text('Confirm Password', style: Theme.of(context).textTheme.labelLarge),
											TextFormField(
												controller: _confirmPasswordController,
												obscureText: true,
												decoration: const InputDecoration(isDense: true, border: UnderlineInputBorder(), hintText: 'Reenter your password'),
												validator: (v) => (v != _passwordController.text) ? 'Mật khẩu không khớp' : null,
											),

											const SizedBox(height: 16),
											Row(
												children: [
													Checkbox(value: _agree, onChanged: (v) => setState(() => _agree = v ?? false)),
													const Expanded(
														child: Text('By Signing Up, I Agree To The Privacy Policy And The Terms Of Services.', maxLines: 3),
													),
												],
											),
											const SizedBox(height: 8),
											SizedBox(
												width: double.infinity,
												height: 48,
												child: FilledButton(
													style: FilledButton.styleFrom(backgroundColor: primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
													onPressed: !_agree || _isLoading ? null : _submit,
													child: _isLoading
														? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
														: const Text('Sign Up'),
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
									const Text('Already have an account? '),
									TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Log in', style: TextStyle(color: primary))),
								],
							),
						],
					),
				),
			),
		);
	}
}
