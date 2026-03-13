class CountryModel {

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
      code: json['code'],
      name: json['name'],
      nativeName: json['nativeName'],
      phoneCode: json['phoneCode'],
      flag: json['flag'],
      flagSvg: json['flagSvg'],
      continent: json['continent'],
      currency: json['currency'],
      currencySymbol: json['currencySymbol'],
      timezone: json['timezone'],
      languages: List<String>.from(json['languages']),
      population: json['population'],
      area: json['area'],
      isActive: json['isActive'] ?? true,
    );
  }
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

  Map<String, dynamic> toJson() => <String, dynamic>{
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

  static List<CountryModel> getCountries() {
    return <CountryModel>[
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
        languages: <String>['en'],
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
        languages: <String>['en'],
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
        languages: <String>['bn'],
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
        languages: <String>['hi', 'en'],
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
        languages: <String>['ur', 'en'],
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
        languages: <String>['ar'],
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
        languages: <String>['ar'],
        population: 34810000,
        area: 2149690,
      ),
      CountryModel(
        code: 'CA',
        name: 'Canada',
        nativeName: 'Canada',
        phoneCode: '+1',
        flag: '🇨🇦',
        flagSvg: 'assets/svgs/flags/ca.svg',
        continent: 'North America',
        currency: 'CAD',
        currencySymbol: r'$',
        timezone: 'America/Toronto',
        languages: <String>['en', 'fr'],
        population: 38000000,
        area: 9984670,
      ),
      CountryModel(
        code: 'AU',
        name: 'Australia',
        nativeName: 'Australia',
        phoneCode: '+61',
        flag: '🇦🇺',
        flagSvg: 'assets/svgs/flags/au.svg',
        continent: 'Oceania',
        currency: 'AUD',
        currencySymbol: r'$',
        timezone: 'Australia/Sydney',
        languages: <String>['en'],
        population: 25700000,
        area: 7692024,
      ),
      CountryModel(
        code: 'DE',
        name: 'Germany',
        nativeName: 'Deutschland',
        phoneCode: '+49',
        flag: '🇩🇪',
        flagSvg: 'assets/svgs/flags/de.svg',
        continent: 'Europe',
        currency: 'EUR',
        currencySymbol: '€',
        timezone: 'Europe/Berlin',
        languages: <String>['de'],
        population: 83100000,
        area: 357114,
      ),
      CountryModel(
        code: 'FR',
        name: 'France',
        nativeName: 'France',
        phoneCode: '+33',
        flag: '🇫🇷',
        flagSvg: 'assets/svgs/flags/fr.svg',
        continent: 'Europe',
        currency: 'EUR',
        currencySymbol: '€',
        timezone: 'Europe/Paris',
        languages: <String>['fr'],
        population: 67390000,
        area: 551695,
      ),
      CountryModel(
        code: 'JP',
        name: 'Japan',
        nativeName: '日本',
        phoneCode: '+81',
        flag: '🇯🇵',
        flagSvg: 'assets/svgs/flags/jp.svg',
        continent: 'Asia',
        currency: 'JPY',
        currencySymbol: '¥',
        timezone: 'Asia/Tokyo',
        languages: <String>['ja'],
        population: 125800000,
        area: 377975,
      ),
      CountryModel(
        code: 'CN',
        name: 'China',
        nativeName: '中国',
        phoneCode: '+86',
        flag: '🇨🇳',
        flagSvg: 'assets/svgs/flags/cn.svg',
        continent: 'Asia',
        currency: 'CNY',
        currencySymbol: '¥',
        timezone: 'Asia/Shanghai',
        languages: <String>['zh'],
        population: 1402000000,
        area: 9596961,
      ),
      CountryModel(
        code: 'BR',
        name: 'Brazil',
        nativeName: 'Brasil',
        phoneCode: '+55',
        flag: '🇧🇷',
        flagSvg: 'assets/svgs/flags/br.svg',
        continent: 'South America',
        currency: 'BRL',
        currencySymbol: r'R$',
        timezone: 'America/Sao_Paulo',
        languages: <String>['pt'],
        population: 213000000,
        area: 8515767,
      ),
      CountryModel(
        code: 'ZA',
        name: 'South Africa',
        nativeName: 'South Africa',
        phoneCode: '+27',
        flag: '🇿🇦',
        flagSvg: 'assets/svgs/flags/za.svg',
        continent: 'Africa',
        currency: 'ZAR',
        currencySymbol: 'R',
        timezone: 'Africa/Johannesburg',
        languages: <String>['en', 'af', 'zu', 'xh'],
        population: 59300000,
        area: 1221037,
      ),
    ];
  }

  static CountryModel? getCountryByCode(String code) {
    try {
      return getCountries().firstWhere((CountryModel c) => c.code == code);
    } catch (e) {
      return null;
    }
  }

  static List<CountryModel> getCountriesByContinent(String continent) {
    return getCountries().where((CountryModel c) => c.continent == continent).toList();
  }

  static List<CountryModel> searchCountries(String query) {
    final String lowerQuery = query.toLowerCase();
    return getCountries().where((CountryModel c) {
      return c.name.toLowerCase().contains(lowerQuery) ||
             c.nativeName.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

class RegionModel {

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
      id: json['id'],
      name: json['name'],
      countryCode: json['countryCode'],
      stateCode: json['stateCode'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      population: json['population'],
    );
  }
  final String id;
  final String name;
  final String countryCode;
  final String? stateCode;
  final double latitude;
  final double longitude;
  final int population;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'countryCode': countryCode,
    'stateCode': stateCode,
    'latitude': latitude,
    'longitude': longitude,
    'population': population,
  };
}