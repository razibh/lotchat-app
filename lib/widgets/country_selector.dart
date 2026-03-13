import 'package:flutter/material.dart';
import '../core/models/country_model.dart';

class CountrySelector extends StatefulWidget {

  const CountrySelector({
    Key? key,
    required this.selectedCountry,
    required this.onCountryChanged,
  }) : super(key: key);
  final String selectedCountry;
  final Function(String) onCountryChanged;

  @override
  State<CountrySelector> createState() => _CountrySelectorState();
}

class _CountrySelectorState extends State<CountrySelector> {
  final List<CountryModel> _countries = CountryModel.getCountries();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <>[
          _buildCountryChip('All', '🌍'),
          ..._countries.map((CountryModel country) => _buildCountryChip(
            country.name,
            country.flag,
          )),
        ],
      ),
    );
  }

  Widget _buildCountryChip(String countryName, String flag) {
    final bool isSelected = widget.selectedCountry == countryName;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Text(flag, style: const TextStyle(fontSize: 16)),
        label: Text(countryName),
        selected: isSelected,
        onSelected: (selected) {
          widget.onCountryChanged(countryName);
        },
        backgroundColor: Colors.white.withOpacity(0.2),
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class CountryPickerDialog extends StatelessWidget {

  const CountryPickerDialog({
    Key? key,
    required this.onCountrySelected,
  }) : super(key: key);
  final Function(CountryModel) onCountrySelected;

  @override
  Widget build(BuildContext context) {
    final List<CountryModel> countries = CountryModel.getCountries();

    return Dialog(
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <>[
            const Text(
              'Select Country',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  final CountryModel country = countries[index];
                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(country.name),
                    subtitle: Text(country.nativeName),
                    trailing: Text(country.phoneCode),
                    onTap: () {
                      Navigator.pop(context);
                      onCountrySelected(country);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegionSelector extends StatefulWidget {

  const RegionSelector({
    Key? key,
    required this.countryCode,
    required this.selectedRegion,
    required this.onRegionChanged,
  }) : super(key: key);
  final String countryCode;
  final String selectedRegion;
  final Function(String) onRegionChanged;

  @override
  State<RegionSelector> createState() => _RegionSelectorState();
}

class _RegionSelectorState extends State<RegionSelector> {
  final List<String> _regions = <String>[
    'All',
    'California',
    'Texas',
    'New York',
    'Florida',
    'Illinois',
    'Pennsylvania',
    'Ohio',
    'Georgia',
    'Michigan',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _regions.map((String region) {
          final bool isSelected = widget.selectedRegion == region;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(region),
              selected: isSelected,
              onSelected: (selected) {
                widget.onRegionChanged(region);
              },
              backgroundColor: Colors.white.withOpacity(0.2),
              selectedColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue : Colors.white,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}