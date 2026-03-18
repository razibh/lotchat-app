class CountryModel {
  final String code; // ISO 3166-1 alpha-2
  final String name;
  final String nativeName;
  final String phoneCode;
  final String flag; // emoji or asset path
  final String? flagSvg; // SVG asset path
  final String continent;
  final String currency;
  final String currencySymbol;
  final String timezone;
  final List<String> languages;
  final int population;
  final double area;
  final bool isActive;

  CountryModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.phoneCode,
    required this.flag,
    this.flagSvg,
    required this.continent,
    required this.currency,
    required this.currencySymbol,
    required this.timezone,
    required this.languages,
    required this.population,
    required this.area,
    this.isActive = true,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      nativeName: json['nativeName'] ?? '',
      phoneCode: json['phoneCode'] ?? '',
      flag: json['flag'] ?? '',
      flagSvg: json['flagSvg'],
      continent: json['continent'] ?? '',
      currency: json['currency'] ?? '',
      currencySymbol: json['currencySymbol'] ?? '',
      timezone: json['timezone'] ?? '',
      languages: List<String>.from(json['languages'] ?? []),
      population: json['population'] ?? 0,
      area: (json['area'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'nativeName': nativeName,
    'phoneCode': phoneCode,
    'flag': flag,
    'flagSvg': flagSvg,
    'continent': continent,
    'currency': currency,
    'currencySymbol': currencySymbol,
    'timezone': timezone,
    'languages': languages,
    'population': population,
    'area': area,
    'isActive': isActive,
  };

  // স্ট্যাটিক মেথড - সব দেশের তালিকা
  static List<CountryModel> getCountries() {
    return [
      CountryModel(
        code: 'US',
        name: 'United States',
        nativeName: 'United States',
        phoneCode: '+1',
        flag: '🇺🇸',
        flagSvg: 'assets/svgs/flags/us.svg',
        continent: 'North America',
        currency: 'USD',
        currencySymbol: r'$',
        timezone: 'America/New_York',
        languages: ['en'],
        population: 331000000,
        area: 9833517,
      ),
      CountryModel(
        code: 'GB',
        name: 'United Kingdom',
        nativeName: 'United Kingdom',
        phoneCode: '+44',
        flag: '🇬🇧',
        flagSvg: 'assets/svgs/flags/gb.svg',
        continent: 'Europe',
        currency: 'GBP',
        currencySymbol: '£',
        timezone: 'Europe/London',
        languages: ['en'],
        population: 67800000,
        area: 242495,
      ),
      CountryModel(
        code: 'BD',
        name: 'Bangladesh',
        nativeName: 'বাংলাদেশ',
        phoneCode: '+880',
        flag: '🇧🇩',
        flagSvg: 'assets/svgs/flags/bd.svg',
        continent: 'Asia',
        currency: 'BDT',
        currencySymbol: '৳',
        timezone: 'Asia/Dhaka',
        languages: ['bn'],
        population: 165000000,
        area: 147570,
      ),
      CountryModel(
        code: 'IN',
        name: 'India',
        nativeName: 'भारत',
        phoneCode: '+91',
        flag: '🇮🇳',
        flagSvg: 'assets/svgs/flags/in.svg',
        continent: 'Asia',
        currency: 'INR',
        currencySymbol: '₹',
        timezone: 'Asia/Kolkata',
        languages: ['hi', 'en'],
        population: 1380000000,
        area: 3287263,
      ),
      CountryModel(
        code: 'PK',
        name: 'Pakistan',
        nativeName: 'پاکستان',
        phoneCode: '+92',
        flag: '🇵🇰',
        flagSvg: 'assets/svgs/flags/pk.svg',
        continent: 'Asia',
        currency: 'PKR',
        currencySymbol: '₨',
        timezone: 'Asia/Karachi',
        languages: ['ur', 'en'],
        population: 220000000,
        area: 881913,
      ),
      CountryModel(
        code: 'AE',
        name: 'United Arab Emirates',
        nativeName: 'الإمارات العربية المتحدة',
        phoneCode: '+971',
        flag: '🇦🇪',
        flagSvg: 'assets/svgs/flags/ae.svg',
        continent: 'Asia',
        currency: 'AED',
        currencySymbol: 'د.إ',
        timezone: 'Asia/Dubai',
        languages: ['ar'],
        population: 9890000,
        area: 83600,
      ),
      CountryModel(
        code: 'SA',
        name: 'Saudi Arabia',
        nativeName: 'المملكة العربية السعودية',
        phoneCode: '+966',
        flag: '🇸🇦',
        flagSvg: 'assets/svgs/flags/sa.svg',
        continent: 'Asia',
        currency: 'SAR',
        currencySymbol: '﷼',
        timezone: 'Asia/Riyadh',
        languages: ['ar'],
        population: 34810000,
        area: 2149690,
      ),
    ];
  }

  // কোড দ্বারা দেশ খুঁজুন
  static CountryModel? getCountryByCode(String code) {
    try {
      return getCountries().firstWhere((c) => c.code == code);
    } catch (e) {
      return null;
    }
  }

  // নাম দ্বারা দেশ খুঁজুন
  static CountryModel? getCountryByName(String name) {
    try {
      return getCountries().firstWhere(
            (c) => c.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // ID দ্বারা দেশ খুঁজুন (getCountryById মেথড - recommended_rooms_screen এর জন্য)
  static CountryModel? getCountryById(String id) {
    return getCountryByCode(id);
  }

  // মহাদেশ অনুযায়ী দেশের তালিকা
  static List<CountryModel> getCountriesByContinent(String continent) {
    return getCountries().where((c) => c.continent == continent).toList();
  }

  // সার্চ করুন
  static List<CountryModel> searchCountries(String query) {
    final lowerQuery = query.toLowerCase();
    return getCountries().where((c) {
      return c.name.toLowerCase().contains(lowerQuery) ||
          c.nativeName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // সব সাপোর্টেড দেশ
  static List<CountryModel> getSupportedCountries() {
    return getCountries();
  }
}

class RegionModel {
  final String id;
  final String name;
  final String countryCode;
  final String? stateCode;
  final double latitude;
  final double longitude;
  final int population;

  RegionModel({
    required this.id,
    required this.name,
    required this.countryCode,
    this.stateCode,
    required this.latitude,
    required this.longitude,
    required this.population,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      countryCode: json['countryCode'] ?? '',
      stateCode: json['stateCode'],
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      population: json['population'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'countryCode': countryCode,
    'stateCode': stateCode,
    'latitude': latitude,
    'longitude': longitude,
    'population': population,
  };
}