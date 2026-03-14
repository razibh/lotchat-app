import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../core/widgets/neumorphic_text_field.dart';
import '../../../core/models/country_models.dart';

class SellerRegistrationScreen extends StatefulWidget {
  const SellerRegistrationScreen({super.key});

  @override
  State<SellerRegistrationScreen> createState() => _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nidController = TextEditingController();
  
  String? _selectedCountry;
  final List<String> _documents = <String>[];
  bool _agreeToTerms = false;
  int _currentStep = 0;

  final List<Country> _countries = Country.getSupportedCountries();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <>[
              _buildHeader(),
              Expanded(
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  onStepContinue: _nextStep,
                  onStepCancel: _previousStep,
                  steps: _getSteps(),
                  controlsBuilder: (BuildContext context, ControlsDetails details) {
                    return Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: <>[
                          if (_currentStep > 0)
                            Expanded(
                              child: NeumorphicButton(
                                onPressed: details.onStepCancel,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: const Center(
                                    child: Text(
                                      'Back',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_currentStep > 0) const SizedBox(width: 12),
                          Expanded(
                            child: NeumorphicButton(
                              onPressed: details.onStepContinue,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: <>[
                                      Colors.orange,
                                      Colors.deepOrange,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    _currentStep == 2 ? 'Submit' : 'Next',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <>[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Become a Coin Seller',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Step> _getSteps() {
    return <>[
      Step(
        title: const Text('Basic Info'),
        content: _buildBasicInfoStep(),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text('Documents'),
        content: _buildDocumentsStep(),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text('Agreement'),
        content: _buildAgreementStep(),
        isActive: _currentStep >= 2,
      ),
    ];
  }

  Widget _buildBasicInfoStep() {
    return Column(
      children: <>[
        NeumorphicTextField(
          controller: _businessNameController,
          hintText: 'Business Name',
          prefixIcon: Icons.business,
        ),
        const SizedBox(height: 12),
        NeumorphicTextField(
          controller: _ownerNameController,
          hintText: 'Owner Name',
          prefixIcon: Icons.person,
        ),
        const SizedBox(height: 12),
        NeumorphicTextField(
          controller: _emailController,
          hintText: 'Email Address',
          prefixIcon: Icons.email,
        ),
        const SizedBox(height: 12),
        NeumorphicTextField(
          controller: _phoneController,
          hintText: 'Phone Number',
          prefixIcon: Icons.phone,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: _selectedCountry,
            hint: const Text('Select Country', style: TextStyle(color: Colors.white70)),
            dropdownColor: AppColors.surfaceDark,
            isExpanded: true,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: _countries.map((Country country) {
              return DropdownMenuItem(
                value: country.id,
                child: Text(
                  '${country.flag} ${country.name}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedCountry = value;
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        NeumorphicTextField(
          controller: _addressController,
          hintText: 'Business Address',
          prefixIcon: Icons.location_on,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildDocumentsStep() {
    return Column(
      children: <>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: <>[
              _buildDocumentUpload('NID / Passport', Icons.badge),
              const SizedBox(height: 12),
              _buildDocumentUpload('Trade License', Icons.description),
              const SizedBox(height: 12),
              _buildDocumentUpload('Bank Statement', Icons.account_balance),
            ],
          ),
        ),
        const SizedBox(height: 12),
        NeumorphicTextField(
          controller: _nidController,
          hintText: 'NID Number',
          prefixIcon: Icons.credit_card,
        ),
      ],
    );
  }

  Widget _buildDocumentUpload(String title, IconData icon) {
    return Row(
      children: <>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.orange),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        NeumorphicButton(
          onPressed: () {},
          child: const Text(
            'Upload',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementStep() {
    return Column(
      children: <>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <>[
              Text(
                'Terms & Conditions',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                '• You must be at least 18 years old\n'
                '• You must provide valid documents\n'
                '• 15% minimum discount on all coins\n'
                '• Platform commission: 5% on each sale\n'
                '• Immediate coin transfer after payment\n'
                '• No refund after coin transfer\n'
                '• Violation may lead to account suspension',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: <>[
            Checkbox(
              value: _agreeToTerms,
              onChanged: (bool? value) {
                setState(() {
                  _agreeToTerms = value!;
                });
              },
              checkColor: Colors.white,
              activeColor: Colors.orange,
            ),
            const Expanded(
              child: Text(
                'I agree to the terms and conditions',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      _submitRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _submitRegistration() {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to terms and conditions')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Icon(Icons.hourglass_empty, color: Colors.orange, size: 60),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            Text(
              'Application Submitted!',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Your application is under review.\nWe will notify you within 24-48 hours.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: <>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}