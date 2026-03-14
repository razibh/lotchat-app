class Country {

  Country({
    required this.id,
    required this.name,
    required this.code,
    required this.flag,
    required this.currency,
    required this.phoneCode,
    this.isActive = true,
    this.countryManagerId,
  });
  final String id;
  final String name;
  final String code;
  final String flag;
  final String currency;
  final String phoneCode;
  final bool isActive;
  final String? countryManagerId;

  static List<Country> getSupportedCountries() {
    return <Country>[
      Country(
        id: 'bd',
        name: 'Bangladesh',
        code: 'BD',
        flag: '🇧🇩',
        currency: 'BDT',
        phoneCode: '+880',
      ),
      Country(
        id: 'in',
        name: 'India',
        code: 'IN',
        flag: '🇮🇳',
        currency: 'INR',
        phoneCode: '+91',
      ),
      Country(
        id: 'pk',
        name: 'Pakistan',
        code: 'PK',
        flag: '🇵🇰',
        currency: 'PKR',
        phoneCode: '+92',
      ),
      Country(
        id: 'np',
        name: 'Nepal',
        code: 'NP',
        flag: '🇳🇵',
        currency: 'NPR',
        phoneCode: '+977',
      ),
      Country(
        id: 'lk',
        name: 'Sri Lanka',
        code: 'LK',
        flag: '🇱🇰',
        currency: 'LKR',
        phoneCode: '+94',
      ),
    ];
  }

  static Country? getCountryById(String id) {
    return getSupportedCountries().firstWhere(
      (Country c) => c.id == id,
      orElse: () => getSupportedCountries().first,
    );
  }
}

class UserCountryPreference {

  UserCountryPreference({
    required this.userId,
    required this.selectedCountryId,
    required this.lastUpdated,
    this.preferredCountries = const <String>[],
  });
  final String userId;
  final String selectedCountryId;
  final DateTime lastUpdated;
  final List<String> preferredCountries;
}