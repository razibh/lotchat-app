import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../core/models/country_model.dart';

class CountrySelector extends StatefulWidget {
  final String selectedCountry;
  final Function(String) onCountryChanged;

  const CountrySelector({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

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
        children: [
          _buildCountryChip('All', '🌍'),
          ..._countries.map((CountryModel country) => _buildCountryChip(
            country.name,
            country.flag,
          )).toList(),
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
        backgroundColor: Colors.white.withOpacity(0.2),
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: Colors.blue,
      ),
    );
  }
}

class CountryPickerDialog extends StatelessWidget {
  final Function(CountryModel) onCountrySelected;

  const CountryPickerDialog({
    super.key,
    required this.onCountrySelected,
  });

  @override
  Widget build(BuildContext context) {
    final List<CountryModel> countries = CountryModel.getCountries();

    return Dialog(
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
  final String countryCode;
  final String selectedRegion;
  final Function(String) onRegionChanged;

  const RegionSelector({
    super.key,
    required this.countryCode,
    required this.selectedRegion,
    required this.onRegionChanged,
  });

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
  // Mock regions - in real app, these would come from a service based on countryCode
  List<String> _getRegionsForCountry(String countryCode) {
    // Mock data based on country
    if (countryCode == 'US') {
      return [
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
    } else if (countryCode == 'BD') {
      return [
        'All',
        'Dhaka',
        'Chittagong',
        'Rajshahi',
        'Khulna',
        'Barisal',
        'Sylhet',
        'Rangpur',
        'Mymensingh',
      ];
    } else if (countryCode == 'IN') {
      return [
        'All',
        'Maharashtra',
        'Delhi',
        'Karnataka',
        'Tamil Nadu',
        'Uttar Pradesh',
        'West Bengal',
        'Gujarat',
        'Rajasthan',
      ];
    } else {
      return [
        'All',
        'Region 1',
        'Region 2',
        'Region 3',
        'Region 4',
        'Region 5',
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> regions = _getRegionsForCountry(widget.countryCode);

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: regions.map((String region) {
          final bool isSelected = widget.selectedRegion == region;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(region),
              selected: isSelected,
              onSelected: (bool selected) {
                widget.onRegionChanged(region);
              },
              backgroundColor: Colors.white.withOpacity(0.2),
              selectedColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              checkmarkColor: Colors.blue,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Advanced country search with search functionality
class CountrySearchDialog extends StatefulWidget {
  final Function(CountryModel) onCountrySelected;

  const CountrySearchDialog({
    super.key,
    required this.onCountrySelected,
  });

  @override
  State<CountrySearchDialog> createState() => _CountrySearchDialogState();
}

class _CountrySearchDialogState extends State<CountrySearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final List<CountryModel> _allCountries = CountryModel.getCountries();
  List<CountryModel> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _filteredCountries = _allCountries;
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCountries);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = _allCountries;
      } else {
        _filteredCountries = _allCountries.where((country) {
          return country.name.toLowerCase().contains(query) ||
              country.nativeName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 600,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Select Country',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search country...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredCountries.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No countries found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _filteredCountries.length,
                itemBuilder: (BuildContext context, int index) {
                  final CountryModel country = _filteredCountries[index];
                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(country.name),
                    subtitle: Text(country.nativeName),
                    trailing: Text(
                      country.phoneCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onCountrySelected(country);
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
    properties.add(ObjectFlagProperty<Function(CountryModel)>.has('onCountrySelected', widget.onCountrySelected));
  }
}