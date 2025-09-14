import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/email_verification_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  static const String routeName = '/email-verification';
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Check verification status when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final svc = context.read<EmailVerificationService>();
      svc.checkVerificationStatus();
      // Auto-send OTP on screen open (new default flow)
      svc.sendOtp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Email Verification',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
      ),
      body: Consumer<EmailVerificationService>(
        builder: (context, verificationService, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: verificationService.isEmailVerified 
                        ? Colors.green.withOpacity(0.1)
                        : const Color(0xFF6C63FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    verificationService.isEmailVerified 
                        ? Icons.verified
                        : Icons.email_outlined,
                    size: 60,
                    color: verificationService.isEmailVerified 
                        ? Colors.green
                        : const Color(0xFF6C63FF),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  verificationService.isEmailVerified 
                      ? 'Email Verified!'
                      : 'Enter OTP from Email',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  verificationService.isEmailVerified
                      ? 'Your email has been successfully verified. You can now access all features of the app.'
                      : 'A 6-digit OTP has been sent to your email. Enter it below to verify.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Status message
                if (verificationService.verificationStatus != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: verificationService.isEmailVerified 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: verificationService.isEmailVerified 
                            ? Colors.green
                            : Colors.orange,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          verificationService.isEmailVerified 
                              ? Icons.check_circle
                              : Icons.info,
                          color: verificationService.isEmailVerified 
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            verificationService.verificationStatus!,
                            style: TextStyle(
                              color: verificationService.isEmailVerified 
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
                
                // Action: OTP flow (recommended for mobile)
                if (!verificationService.isEmailVerified) ...[
                  // OTP input
                  TextField(
                    controller: _otpController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter 6-digit OTP',
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: verificationService.isLoading
                              ? null
                              : () async {
                                  final res = await verificationService.sendOtp();
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(res['message'] ?? ''),
                                      backgroundColor: res['success'] ? Colors.green : Colors.red,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                          ),
                          child: verificationService.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Send OTP'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: verificationService.isLoading
                              ? null
                              : () async {
                                  final code = _otpController.text.trim();
                                  if (code.length != 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please enter a 6-digit code')),
                                    );
                                    return;
                                  }
                                  final res = await verificationService.verifyOtp(code);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(res['message'] ?? ''),
                                      backgroundColor: res['success'] ? Colors.green : Colors.red,
                                    ),
                                  );
                                },
                          child: verificationService.isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Verify OTP'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Resend verification link (optional)
                  // Resend verification email button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: verificationService.isVerificationEmailSent
                          ? null
                          : () async {
                              final result = await verificationService.sendVerificationEmail();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message']),
                                    backgroundColor: result['success'] ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: verificationService.isVerificationEmailSent
                          ? const Text('Verification Email Sent')
                          : const Text('Send Verification Email'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Open email app button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        // This would open the default email app
                        // You might want to implement this based on your needs
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please check your email app'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6C63FF),
                        side: const BorderSide(color: Color(0xFF6C63FF)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Open Email App'),
                    ),
                  ),
                ] else ...[
                  // Continue button when verified
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Help text
                Text(
                  'If you don\'t see the email, please check your spam folder.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
