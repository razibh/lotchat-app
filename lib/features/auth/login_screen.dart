import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/country_provider.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/neumorphic_button.dart';
import '../../core/widgets/neumorphic_text_field.dart';
import '../../core/services/navigation_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _selectedRole;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _demoAccounts = <Map<String, dynamic>>[
    <String, dynamic>{
      'role': 'Admin',
      'email': 'admin@test.com',
      'password': 'admin123',
      'color': Colors.red,
      'icon': Icons.admin_panel_settings,
    },
    <String, dynamic>{
      'role': 'Country Manager',
      'email': 'manager@test.com',
      'password': 'manager123',
      'color': Colors.purple,
      'icon': Icons.public,
    },
    <String, dynamic>{
      'role': 'Agency Owner',
      'email': 'agency@test.com',
      'password': 'agency123',
      'color': Colors.blue,
      'icon': Icons.business,
    },
    <String, dynamic>{
      'role': 'Coin Seller',
      'email': 'seller@test.com',
      'password': 'seller123',
      'color': Colors.orange,
      'icon': Icons.store,
    },
    <String, dynamic>{
      'role': 'Host',
      'email': 'host@test.com',
      'password': 'host123',
      'color': Colors.pink,
      'icon': Icons.mic,
    },
    <String, dynamic>{
      'role': 'Regular User',
      'email': 'user@test.com',
      'password': 'user123',
      'color': Colors.green,
      'icon': Icons.person,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Check if country is selected
        final countryProvider = Provider.of<CountryProvider>(context, listen: false);
        
        if (countryProvider.selectedCountry == null) {
          NavigationService.navigateToReplacement('/country-select');
        } else {
          NavigationService.navigateToReplacement(authProvider.getHomeRoute());
        }
      } else if (mounted) {
        _showErrorSnackBar(authProvider.error ?? 'Login failed');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _fillDemoAccount(Map<String, dynamic> account) {
    setState(() {
      _emailController.text = account['email'];
      _passwordController.text = account['password'];
      _selectedRole = account['role'];
    });
    
    // Optional: Auto login after a short delay
    // Future.delayed(const Duration(milliseconds: 500), _handleLogin);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <>[
                        // Logo and Title
                        _buildLogo(),
                        const SizedBox(height: 40),
                        
                        // Demo Accounts Section
                        _buildDemoAccounts(),
                        const SizedBox(height: 30),
                        
                        // Login Form
                        _buildLoginForm(),
                        const SizedBox(height: 20),
                        
                        // Forgot Password
                        _buildForgotPassword(),
                        const SizedBox(height: 30),
                        
                        // Login Button
                        _buildLoginButton(authProvider.isLoading),
                        const SizedBox(height: 20),
                        
                        // Register Link
                        _buildRegisterLink(),
                        const SizedBox(height: 20),
                        
                        // Guest Login
                        _buildGuestLogin(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: <>[
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <>[
                AppColors.accentPurple,
                AppColors.accentBlue,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: <>[
              BoxShadow(
                color: AppColors.accentPurple.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.sports_esports,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          AppConstants.appName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Play Games • Live Stream • Earn Coins',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDemoAccounts() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          const Row(
            children: <>[
              Icon(
                Icons.science,
                color: AppColors.accentPurple,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Demo Accounts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _demoAccounts.map((Map<String, dynamic> account) {
              final bool isSelected = _selectedRole == account['role'];
              return GestureDetector(
                onTap: () => _fillDemoAccount(account),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (account['color'] as Color).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? account['color']
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <>[
                      Icon(
                        account['icon'],
                        color: isSelected
                            ? account['color']
                            : Colors.white70,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        account['role'],
                        style: TextStyle(
                          color: isSelected
                              ? account['color']
                              : Colors.white70,
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: <>[
          // Email Field
          NeumorphicTextField(
            controller: _emailController,
            hintText: 'Email Address',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Password Field
          NeumorphicTextField(
            controller: _passwordController,
            hintText: 'Password',
            prefixIcon: Icons.lock,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < AppConstants.minPasswordLength) {
                return 'Password must be at least ${AppConstants.minPasswordLength} characters';
              }
              return null;
            },
          ),
          
          // Remember Me & Forgot Password Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <>[
              Row(
                children: <>[
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (bool? value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    checkColor: Colors.white,
                    activeColor: AppColors.accentPurple,
                  ),
                  const Text(
                    'Remember me',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  NavigationService.navigateTo('/forgot-password');
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.accentPurple,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          NavigationService.navigateTo('/forgot-password');
        },
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPurple,
        ),
        child: const Text('Forgot Password?'),
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return NeumorphicButton(
      onPressed: isLoading ? null : _handleLogin,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <>[
              AppColors.accentPurple,
              AppColors.accentBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'LOGIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <>[
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.white70),
        ),
        GestureDetector(
          onTap: () {
            NavigationService.navigateTo('/register');
          },
          child: const Text(
            'Register',
            style: TextStyle(
              color: AppColors.accentPurple,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestLogin() {
    return TextButton.icon(
      onPressed: () {
        // Navigate to home as guest
        NavigationService.navigateToReplacement('/home');
      },
      icon: const Icon(Icons.person_outline, color: Colors.white70, size: 16),
      label: const Text(
        'Continue as Guest',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}

// Forgot Password Screen (if needed)
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _emailSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Forgot Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter your email address and we'll send you a link to reset your password.",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 40),
                if (_emailSent)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Column(
                      children: <>[
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 50,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Email Sent!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We've sent a password reset link to ${_emailController.text}",
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentPurple,
                          ),
                          child: const Text('Back to Login'),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    children: <>[
                      NeumorphicTextField(
                        controller: _emailController,
                        hintText: 'Email Address',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 30),
                      NeumorphicButton(
                        onPressed: _isLoading ? null : _handleForgotPassword,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  )
                                : const Text(
                                    'SEND RESET LINK',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}