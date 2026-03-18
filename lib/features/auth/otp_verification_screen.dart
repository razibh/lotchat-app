import 'dart:async'; // Timer এর জন্য
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final String? email;
  final bool isEmailVerification;

  const OtpVerificationScreen({
    required this.verificationId,
    required this.phoneNumber,
    this.email,
    this.isEmailVerification = false,
    super.key,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('verificationId', verificationId));
    properties.add(StringProperty('phoneNumber', phoneNumber));
    properties.add(StringProperty('email', email));
    properties.add(DiagnosticsProperty<bool>('isEmailVerification', isEmailVerification));
  }
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 30;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _onChanged(String value, int index) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getOtp() {
    return _controllers.map((c) => c.text).join();
  }

  Future<void> _verifyOtp() async {
    String otp = _getOtp();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verification successful!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
      _resendCountdown = 30;
    });

    _startCountdown();

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isResending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isEmailVerification
              ? 'OTP has been resent to your email'
              : 'OTP has been resent to your phone',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editPhoneNumber() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEmailVerification ? 'Verify Email' : 'Verify Phone'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.deepPurple, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    widget.isEmailVerification
                        ? Icons.email_outlined
                        : Icons.phone_android,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.isEmailVerification
                        ? 'Email Verification'
                        : 'Phone Verification',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isEmailVerification
                        ? 'Enter the OTP sent to ${widget.email}'
                        : 'Enter the OTP sent to ${widget.phoneNumber}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // OTP Input
            const Text(
              'Enter OTP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  height: 50,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                      ),
                    ),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    onChanged: (value) => _onChanged(value, index),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Resend Option
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive the code? "),
                  if (_resendCountdown > 0)
                    Text(
                      'Resend in $_resendCountdown s',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _isResending ? null : _resendOtp,
                      child: _isResending
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Text('Resend'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'Verify',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Edit Phone/Email Button
            Center(
              child: TextButton(
                onPressed: _editPhoneNumber,
                child: Text(
                  widget.isEmailVerification
                      ? 'Use a different email'
                      : 'Use a different phone number',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Help Text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Having trouble?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isEmailVerification
                        ? 'Check your spam folder or request a new OTP'
                        : 'Make sure you have network connection and your phone number is correct',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simplified version for error fixing
class OtpVerificationScreenSimple extends StatelessWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationScreenSimple({
    required this.verificationId,
    required this.phoneNumber,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Verification ID: $verificationId'),
            Text('Phone: $phoneNumber'),
          ],
        ),
      ),
    );
  }
}