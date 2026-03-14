import 'package:flutter/material.dart';
import '../core/models/country_model.dart';

class CountrySelector extends StatefulWidget {

  const CountrySelector({
    required this.selectedCountry, required this.onCountryChanged, super.key,
  });
  final String selectedCountry;
  final Function(String) onCountryChanged;

  @override
  State<CountrySelector> createState() => _CountrySelectorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('selectedCountry', selectedCountry));
    properties.add(ObjectFlagProperty<Function(String)>.has('onCountryChanged', onCountryChanged));
  }
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
          ),),
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
        onSelected: (bool selected) {
          widget.onCountryChanged(countryName);
        },
        backgroundColor: Colors.white.withValues(alpha: 0.2),
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
    required this.onCountrySelected, super.key,
  });
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
                itemBuilder: (BuildContext context, int index) {
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<Function(CountryModel)>.has('onCountrySelected', onCountrySelected));
  }
}

class RegionSelector extends StatefulWidget {

  const RegionSelector({
    required this.countryCode, required this.selectedRegion, required this.onRegionChanged, super.key,
  });
  final String countryCode;
  final String selectedRegion;
  final Function(String) onRegionChanged;

  @override
  State<RegionSelector> createState() => _RegionSelectorState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('countryCode', countryCode));
    properties.add(StringProperty('selectedRegion', selectedRegion));
    properties.add(ObjectFlagProperty<Function(String)>.has('onRegionChanged', onRegionChanged));
  }
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
              onSelected: (bool selected) {
                widget.onRegionChanged(region);
              },
              backgroundColor: Colors.white.withValues(alpha: 0.2),
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