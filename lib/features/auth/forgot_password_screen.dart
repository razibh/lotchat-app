import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/validators.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/form_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> 
    with LoadingMixin, ToastMixin, FormMixin {
  
  final AuthService _authService = ServiceLocator().get<AuthService>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!validateForm()) return;
    
    await runWithLoading(() async {
      try {
        await _authService.resetPassword(_emailController.text.trim());
        setState(() {
          _emailSent = true;
        });
        showSuccess('Reset email sent! Check your inbox.');
      } catch (e) {
        showError(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <>[
                const SizedBox(height: 40),
                
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 50,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                // Description
                const Text(
                  "Enter your email address and we'll send you a link to reset your password.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Email Field
                if (!_emailSent) ...<>[
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 24),
                  
                  // Send Button
                  CustomButton(
                    text: 'Send Reset Link',
                    onPressed: _sendResetEmail,
                    isLoading: isButtonLoading,
                  ),
                ] else ...<>[
                  // Success Message
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: <>[
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Email Sent!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We've sent a password reset link to\n${_emailController.text}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                          ),
                          child: const Text('Back to Login'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}