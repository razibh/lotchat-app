import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/models/country_models.dart';
import '../../core/utils/country_helper.dart';
import '../home/recommended_rooms_screen.dart';

class CountrySelectionScreen extends StatefulWidget {
  const CountrySelectionScreen({super.key});

  @override
  State<CountrySelectionScreen> createState() => _CountrySelectionScreenState();
}

class _CountrySelectionScreenState extends State<CountrySelectionScreen> {
  String? _selectedCountryId;
  List<Country> _countries = <Country>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  void _loadCountries() {
    setState(() {
      _countries = Country.getSupportedCountries();
      _isLoading = false;
    });
  }

  void _saveCountryAndContinue() {
    if (_selectedCountryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your country')),
      );
      return;
    }

    // Save selected country (you can save to SharedPreferences or user profile)
    CountryHelper.setSelectedCountry(_selectedCountryId!);
    
    // Navigate to home with country-specific recommendations
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RecommendedRoomsScreen(countryId: _selectedCountryId!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <>[
                _buildHeader(),
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 40),
                if (_isLoading) const Center(child: CircularProgressIndicator()) else _buildCountryGrid(),
                const Spacer(),
                _buildContinueButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <>[
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: <>[
        const Icon(
          Icons.public,
          size: 80,
          color: Colors.white,
        ),
        const SizedBox(height: 20),
        const Text(
          'Select Your Country',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Choose your country to see local rooms\nand connect with people near you',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCountryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _countries.length,
      itemBuilder: (BuildContext context, int index) {
        final Country country = _countries[index];
        final bool isSelected = _selectedCountryId == country.id;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCountryId = country.id;
            });
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: <>[
                        AppColors.accentPurple,
                        AppColors.accentBlue,
                      ],
                    )
                  : null,
              color: isSelected ? null : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <>[
                Text(
                  country.flag,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 12),
                Text(
                  country.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Icon(Icons.check_circle, color: Colors.white, size: 20),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      child: ElevatedButton(
        onPressed: _saveCountryAndContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentPurple,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}