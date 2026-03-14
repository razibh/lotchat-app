import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../core/widgets/neumorphic_text_field.dart';
import '../../../core/models/country_models.dart';

class AgencyRegistrationScreen extends StatefulWidget {
  const AgencyRegistrationScreen({super.key});

  @override
  State<AgencyRegistrationScreen> createState() => _AgencyRegistrationScreenState();
}

class _AgencyRegistrationScreenState extends State<AgencyRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Step 1: Basic Info
  final TextEditingController _agencyNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedCountry;

  // Step 2: Business Details
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _licenseNumberController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  // Step 3: Commission & Plan
  double _commissionRate = 10;
  int _proposedHosts = 20;
  final TextEditingController _businessPlanController = TextEditingController();

  // Step 4: Documents
  bool _nidUploaded = false;
  bool _licenseUploaded = false;
  bool _taxDocUploaded = false;
  bool _agreeToTerms = false;

  final List<Country> _countries = Country.getSupportedCountries();

  @override
  void dispose() {
    _agencyNameController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _licenseNumberController.dispose();
    _taxIdController.dispose();
    _websiteController.dispose();
    _businessPlanController.dispose();
    super.dispose();
  }

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
                                  gradient: LinearGradient(
                                    colors: <>[
                                      Colors.purple,
                                      Colors.purple.shade700,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    _currentStep == 3 ? 'Submit' : 'Next',
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
            'Register Agency',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            'Step ${_currentStep + 1}/4',
            style: const TextStyle(color: Colors.white70),
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
        title: const Text('Business'),
        content: _buildBusinessStep(),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text('Commission'),
        content: _buildCommissionStep(),
        isActive: _currentStep >= 2,
      ),
      Step(
        title: const Text('Documents'),
        content: _buildDocumentsStep(),
        isActive: _currentStep >= 3,
      ),
    ];
  }

  Widget _buildBasicInfoStep() {
    return Column(
      children: <>[
        NeumorphicTextField(
          controller: _agencyNameController,
          hintText: 'Agency Name',
          prefixIcon: Icons.business,
        ),
        const SizedBox(height: 12),
        NeumorphicTextField(
          controller: _ownerNameController,
          hintText: 'Owner Full Name',
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
      ],
    );
  }

  Widget _buildBusinessStep() {
    return Column(
      children: <>[
        NeumorphicTextField(
          controller: _addressController,
          hintText: 'Business Address',
          prefixIcon: Icons.location_on,
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        NeumorphicTextField(
          controller: _licenseNumberController,
          hintText: 'Trade License Number',
          prefixIcon: Icons.badge,
        ),
        const SizedBox(height: 12),
        NeumorphicTextField(
          controller: _taxIdController,
          hintText: 'Tax ID / VAT Number',
          prefixIcon: Icons.receipt,
        ),
        const SizedBox(height: 12),
        NeumorphicTextField(
          controller: _websiteController,
          hintText: 'Website (Optional)',
          prefixIcon: Icons.language,
        ),
      ],
    );
  }

  Widget _buildCommissionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        const Text(
          'Commission Rate',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: <>[
            Expanded(
              child: Slider(
                value: _commissionRate,
                min: 5,
                max: 20,
                divisions: 15,
                onChanged: (double value) {
                  setState(() {
                    _commissionRate = value;
                  });
                },
                activeColor: Colors.purple,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_commissionRate.toInt()}%',
                style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Proposed Number of Hosts',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: <>[
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.white70),
              onPressed: () {
                if (_proposedHosts > 5) {
                  setState(() {
                    _proposedHosts -= 5;
                  });
                }
              },
            ),
            Expanded(
              child: Center(
                child: Text(
                  '$_proposedHosts',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.white70),
              onPressed: () {
                if (_proposedHosts < 200) {
                  setState(() {
                    _proposedHosts += 5;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        NeumorphicTextField(
          controller: _businessPlanController,
          hintText: 'Business Plan / Strategy',
          prefixIcon: Icons.description,
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildDocumentsStep() {
    return Column(
      children: <>[
        _buildDocumentTile(
          'Owner NID/Passport',
          Icons.badge,
          _nidUploaded,
          () {
            setState(() {
              _nidUploaded = true;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildDocumentTile(
          'Trade License',
          Icons.description,
          _licenseUploaded,
          () {
            setState(() {
              _licenseUploaded = true;
            });
          },
        ),
        const SizedBox(height: 12),
        _buildDocumentTile(
          'Tax Document',
          Icons.receipt,
          _taxDocUploaded,
          () {
            setState(() {
              _taxDocUploaded = true;
            });
          },
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            children: <>[
              Text(
                'Terms & Conditions',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Agency must maintain minimum 10 active hosts\n'
                '• Commission will be deducted from host earnings\n'
                '• Monthly reports must be submitted\n'
                '• Violation may lead to termination',
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
              activeColor: Colors.purple,
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

  Widget _buildDocumentTile(String title, IconData icon, bool isUploaded, VoidCallback onUpload) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUploaded ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isUploaded ? Colors.green : Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (isUploaded)
            const Icon(Icons.check_circle, color: Colors.green)
          else
            NeumorphicButton(
              onPressed: onUpload,
              child: const Text(
                'Upload',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 3) {
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

    if (!_nidUploaded || !_licenseUploaded || !_taxDocUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Icon(Icons.hourglass_empty, color: Colors.purple, size: 60),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            Text(
              'Application Submitted!',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Your agency registration is under review.\nWe will notify you within 48 hours.',
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