import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../core/widgets/neumorphic_text_field.dart';
import '../../country_manager/Models/country_manager_models.dart';


class CountryManagerAgenciesScreen extends StatefulWidget {
  final String managerId;
  final String countryId;
  final String countryName;

  const CountryManagerAgenciesScreen({
    required this.managerId,
    required this.countryId,
    required this.countryName,
    super.key,
  });

  @override
  State<CountryManagerAgenciesScreen> createState() => _CountryManagerAgenciesScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('managerId', managerId));
    properties.add(StringProperty('countryId', countryId));
    properties.add(StringProperty('countryName', countryName));
  }
}

class _CountryManagerAgenciesScreenState extends State<CountryManagerAgenciesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCity = 'All Cities';
  String _selectedCountry = 'All Countries';

  List<ManagerAgency> _agencies = [];
  List<ManagerAgency> _filteredAgencies = [];
  final List<ManagerAgency> _pendingAgencies = [];
  final List<ManagerAgency> _topAgencies = [];
  final List<ManagerAgency> _suspendedAgencies = [];

  // All countries list
  final List<Map<String, String>> _allCountries = [
    {'id': 'all', 'name': 'All Countries', 'flag': '🌍'},
    {'id': 'bd', 'name': 'Bangladesh', 'flag': '🇧🇩'},
    {'id': 'in', 'name': 'India', 'flag': '🇮🇳'},
    {'id': 'pk', 'name': 'Pakistan', 'flag': '🇵🇰'},
    {'id': 'np', 'name': 'Nepal', 'flag': '🇳🇵'},
    {'id': 'lk', 'name': 'Sri Lanka', 'flag': '🇱🇰'},
    {'id': 'mm', 'name': 'Myanmar', 'flag': '🇲🇲'},
    {'id': 'af', 'name': 'Afghanistan', 'flag': '🇦🇫'},
    {'id': 'ir', 'name': 'Iran', 'flag': '🇮🇷'},
    {'id': 'sa', 'name': 'Saudi Arabia', 'flag': '🇸🇦'},
    {'id': 'ae', 'name': 'UAE', 'flag': '🇦🇪'},
    {'id': 'qa', 'name': 'Qatar', 'flag': '🇶🇦'},
    {'id': 'kw', 'name': 'Kuwait', 'flag': '🇰🇼'},
    {'id': 'om', 'name': 'Oman', 'flag': '🇴🇲'},
    {'id': 'bh', 'name': 'Bahrain', 'flag': '🇧🇭'},
    {'id': 'jo', 'name': 'Jordan', 'flag': '🇯🇴'},
    {'id': 'lb', 'name': 'Lebanon', 'flag': '🇱🇧'},
    {'id': 'ps', 'name': 'Palestine', 'flag': '🇵🇸'},
    {'id': 'iq', 'name': 'Iraq', 'flag': '🇮🇶'},
    {'id': 'sy', 'name': 'Syria', 'flag': '🇸🇾'},
    {'id': 'ye', 'name': 'Yemen', 'flag': '🇾🇪'},
    {'id': 'eg', 'name': 'Egypt', 'flag': '🇪🇬'},
    {'id': 'ly', 'name': 'Libya', 'flag': '🇱🇾'},
    {'id': 'sd', 'name': 'Sudan', 'flag': '🇸🇩'},
    {'id': 'ma', 'name': 'Morocco', 'flag': '🇲🇦'},
    {'id': 'dz', 'name': 'Algeria', 'flag': '🇩🇿'},
    {'id': 'tn', 'name': 'Tunisia', 'flag': '🇹🇳'},
  ];

  // Cities for all countries
  final Map<String, List<String>> _countryCities = {
    'bd': ['All Cities', 'Dhaka', 'Chittagong', 'Sylhet', 'Khulna', 'Rajshahi', 'Barisal', 'Rangpur', 'Mymensingh', 'Comilla', 'Narayanganj', 'Gazipur', 'Jessore', 'Bogra', 'Dinajpur'],
    'in': ['All Cities', 'Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Ahmedabad', 'Chennai', 'Kolkata', 'Pune', 'Jaipur', 'Lucknow', 'Kanpur', 'Nagpur', 'Indore', 'Bhopal', 'Patna', 'Varanasi', 'Agra'],
    'pk': ['All Cities', 'Karachi', 'Lahore', 'Faisalabad', 'Rawalpindi', 'Multan', 'Gujranwala', 'Hyderabad', 'Peshawar', 'Quetta', 'Islamabad', 'Sialkot', 'Bahawalpur', 'Sukkur', 'Larkana'],
    'np': ['All Cities', 'Kathmandu', 'Pokhara', 'Lalitpur', 'Bharatpur', 'Biratnagar', 'Birgunj', 'Dharan', 'Nepalgunj', 'Butwal', 'Hetauda', 'Bhaktapur', 'Janakpur'],
    'lk': ['All Cities', 'Colombo', 'Kandy', 'Galle', 'Jaffna', 'Negombo', 'Trincomalee', 'Batticaloa', 'Kurunegala', 'Ratnapura', 'Badulla', 'Anuradhapura', 'Polonnaruwa'],
    'mm': ['All Cities', 'Yangon', 'Mandalay', 'Naypyidaw', 'Bago', 'Mawlamyine', 'Pathein', 'Sittwe', 'Myeik', 'Taunggyi', 'Pyay'],
    'af': ['All Cities', 'Kabul', 'Kandahar', 'Herat', 'Mazar-i-Sharif', 'Jalalabad', 'Kunduz', 'Lashkar Gah', 'Taloqan', 'Puli Khumri'],
    'ir': ['All Cities', 'Tehran', 'Mashhad', 'Isfahan', 'Karaj', 'Shiraz', 'Tabriz', 'Qom', 'Ahvaz', 'Kermanshah', 'Urmia'],
    'sa': ['All Cities', 'Riyadh', 'Jeddah', 'Mecca', 'Medina', 'Dammam', 'Khobar', 'Taif', 'Tabuk', 'Buraidah', 'Khamis Mushait'],
    'ae': ['All Cities', 'Dubai', 'Abu Dhabi', 'Sharjah', 'Ajman', 'Ras Al Khaimah', 'Fujairah', 'Umm Al Quwain', 'Al Ain'],
    'qa': ['All Cities', 'Doha', 'Al Wakrah', 'Al Khor', 'Mesaieed', 'Dukhan', 'Al Rayyan'],
    'kw': ['All Cities', 'Kuwait City', 'Hawalli', 'Salmiya', 'Farwaniya', 'Jahra', 'Mubarak Al-Kabeer'],
    'om': ['All Cities', 'Muscat', 'Salalah', 'Sohar', 'Nizwa', 'Sur', 'Ibri', 'Rustaq'],
    'bh': ['All Cities', 'Manama', 'Riffa', 'Muharraq', 'Hamad Town', 'Isa Town', 'Sitra'],
    'jo': ['All Cities', 'Amman', 'Zarqa', 'Irbid', 'Russeifa', 'Salt', 'Aqaba', 'Madaba'],
    'lb': ['All Cities', 'Beirut', 'Tripoli', 'Sidon', 'Tyre', 'Baalbek', 'Jounieh', 'Zahle'],
    'ps': ['All Cities', 'Gaza', 'Hebron', 'Nablus', 'Rafah', 'Khan Yunis', 'Jenin', 'Ramallah'],
    'iq': ['All Cities', 'Baghdad', 'Basra', 'Mosul', 'Erbil', 'Kirkuk', 'Najaf', 'Karbala', 'Sulaymaniyah'],
    'sy': ['All Cities', 'Damascus', 'Aleppo', 'Homs', 'Latakia', 'Hama', 'Deir ez-Zor', 'Raqqa'],
    'ye': ['All Cities', 'Sanaa', 'Aden', 'Taiz', 'Hodeidah', 'Ibb', 'Mukalla', 'Dhamar'],
    'eg': ['All Cities', 'Cairo', 'Alexandria', 'Giza', 'Shubra El Kheima', 'Port Said', 'Suez', 'Luxor', 'Aswan'],
    'ly': ['All Cities', 'Tripoli', 'Benghazi', 'Misrata', 'Zliten', 'Khoms', 'Zawiya', 'Sabha'],
    'sd': ['All Cities', 'Khartoum', 'Omdurman', 'Khartoum North', 'Nyala', 'Port Sudan', 'Kassala', 'El Obeid'],
    'ma': ['All Cities', 'Casablanca', 'Rabat', 'Fes', 'Marrakech', 'Tangier', 'Agadir', 'Meknes'],
    'dz': ['All Cities', 'Algiers', 'Oran', 'Constantine', 'Annaba', 'Blida', 'Batna', 'Djelfa'],
    'tn': ['All Cities', 'Tunis', 'Sfax', 'Sousse', 'Kairouan', 'Bizerte', 'Gabès', 'Ariana'],
  };

  final List<String> _sortOptions = ['Name', 'Revenue', 'Hosts', 'Growth'];
  String _selectedSort = 'Revenue';
  bool _sortAscending = false;

  // Summary Stats
  int _totalAgencies = 0;
  int _activeAgencies = 0;
  double _totalRevenue = 0;
  int _totalHosts = 0;
  double _averageGrowth = 0;
  int _pendingCount = 0;
  int _issuesCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadAgencies();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _filterAndSortAgencies();
    }
  }

  List<String> _getCurrentCities() {
    if (_selectedCountry == 'All Countries') {
      final allCities = <String>{'All Cities'};
      for (final cities in _countryCities.values) {
        allCities.addAll(cities.where((c) => c != 'All Cities'));
      }
      final result = allCities.toList()..sort();
      return result;
    } else {
      return _countryCities[_selectedCountry] ?? ['All Cities'];
    }
  }

  Future<void> _loadAgencies() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    // Generate agencies for all countries
    _agencies = [];
    for (final country in _allCountries.where((c) => c['id'] != 'all')) {
      _agencies.addAll(_generateSampleAgenciesForCountry(country, 5));
    }

    _calculateStats();
    _filterAndSortAgencies();

    setState(() => _isLoading = false);
  }

  List<ManagerAgency> _generateSampleAgenciesForCountry(Map<String, String> country, int count) {
    final agencies = <ManagerAgency>[];
    final countryId = country['id']!;
    final countryName = country['name']!;
    final cities = _countryCities[countryId]?.where((c) => c != 'All Cities').toList() ?? [];

    if (cities.isEmpty) return agencies;

    for (var i = 0; i < count; i++) {
      String status;
      if (i < 1) {
        status = 'Pending';
      } else if (i < 2) {
        status = 'Suspended';
      } else {
        status = 'Active';
      }

      final city = cities[i % cities.length];
      final monthlyRevenue = 30000 + (i * 8000);
      final totalHosts = 8 + (i * 2);
      final activeHosts = totalHosts - (i % 3);

      agencies.add(ManagerAgency(
        id: '${countryId}_${100 + i}',
        name: '$city Agency ${i + 1}',
        ownerName: 'Owner ${i + 1}',
        email: 'agency$countryId${i + 1}@example.com',
        phone: _getPhoneNumber(countryId, i),
        address: _getAddress(countryId, city),
        city: city,
        countryId: countryId,
        countryName: countryName,
        countryFlag: country['flag']!,
        registrationDate: DateTime.now().subtract(Duration(days: 30 * (i % 12))),
        status: status,
        isVerified: i % 3 == 0,
        totalHosts: totalHosts,
        activeHosts: activeHosts,
        monthlyRevenue: monthlyRevenue.toDouble(),
        totalRevenue: (monthlyRevenue * (i % 8 + 1)).toDouble(),
        commissionRate: 8 + (i % 8),
        lastContact: i % 3 == 0 ? DateTime.now() : DateTime.now().subtract(Duration(days: i % 10)),
        totalIssues: i % 5,
        resolvedIssues: (i % 5) - (i % 3),
        monthlyGrowth: (2 + (i % 25)).toDouble(),
        topHosts: ['Host A$i', 'Host B$i', 'Host C$i'],
        licenseNumber: 'LIC${1000 + i}',
        taxId: 'TAX${1000 + i}',
        website: i % 2 == 0 ? 'www.agency$i.com' : null,
        socialMedia: {
          'facebook': 'fb.com/agency$i',
        },
        notes: i % 4 == 0 ? 'High performing agency' : null,
        lastMeeting: i % 3 == 0 ? DateTime.now().subtract(Duration(days: i % 15)) : null,
        nextMeeting: i % 5 == 0 ? DateTime.now().add(Duration(days: (i % 10) + 1)) : null,
        performanceScore: 60 + (i % 40),
        riskLevel: i % 10 < 2 ? 'High' : (i % 10 < 5 ? 'Medium' : 'Low'),
      ));
    }
    return agencies;
  }

  String _getPhoneNumber(String countryId, int index) {
    switch (countryId) {
      case 'bd': return '0171${100000 + index}';
      case 'in': return '98765${40000 + index}';
      case 'pk': return '0300${500000 + index}';
      case 'np': return '9841${200000 + index}';
      case 'lk': return '0771${300000 + index}';
      default: return '+${1000000 + index}';
    }
  }

  String _getAddress(String countryId, String city) {
    switch (countryId) {
      case 'bd': return '$city, Bangladesh';
      case 'in': return '$city, India';
      case 'pk': return '$city, Pakistan';
      case 'np': return '$city, Nepal';
      case 'lk': return '$city, Sri Lanka';
      default: return city;
    }
  }

  void _calculateStats() {
    _totalAgencies = _agencies.length;
    _activeAgencies = _agencies.where((a) => a.status == 'Active').length;
    _totalRevenue = _agencies.fold(0.0, (sum, a) => sum + a.monthlyRevenue);
    _totalHosts = _agencies.fold(0, (sum, a) => sum + a.totalHosts);
    _averageGrowth = _agencies.fold(0.0, (sum, a) => sum + a.monthlyGrowth) / _agencies.length;
    _pendingCount = _agencies.where((a) => a.status == 'Pending').length;
    _issuesCount = _agencies.fold(0, (sum, a) => sum + a.pendingIssues);
  }

  void _filterAndSortAgencies() {
    setState(() {
      // First filter by status based on tab
      if (_tabController.index == 0) {
        _filteredAgencies = _agencies.where((a) => a.status == 'Active').toList();
      } else if (_tabController.index == 1) {
        _filteredAgencies = _agencies.where((a) => a.status == 'Pending').toList();
      } else if (_tabController.index == 2) {
        _filteredAgencies = _agencies.where((a) => a.monthlyRevenue > 80000).toList();
      } else {
        _filteredAgencies = _agencies.where((a) => a.status == 'Suspended').toList();
      }

      // Apply country filter
      if (_selectedCountry != 'All Countries') {
        _filteredAgencies = _filteredAgencies.where((a) => a.countryId == _selectedCountry).toList();
      }

      // Apply city filter
      if (_selectedCity != 'All Cities') {
        _filteredAgencies = _filteredAgencies.where((a) => a.city == _selectedCity).toList();
      }

      // Apply search query
      if (_searchQuery.isNotEmpty) {
        _filteredAgencies = _filteredAgencies.where((a) =>
        a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            a.ownerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            a.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            a.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            a.countryName.toLowerCase().contains(_searchQuery.toLowerCase()),
        ).toList();
      }

      // Apply sorting
      _filteredAgencies.sort((a, b) {
        int comparison;
        switch (_selectedSort) {
          case 'Name':
            comparison = a.name.compareTo(b.name);
            break;
          case 'Revenue':
            comparison = a.monthlyRevenue.compareTo(b.monthlyRevenue);
            break;
          case 'Hosts':
            comparison = a.totalHosts.compareTo(b.totalHosts);
            break;
          case 'Growth':
            comparison = a.monthlyGrowth.compareTo(b.monthlyGrowth);
            break;
          default:
            comparison = a.monthlyRevenue.compareTo(b.monthlyRevenue);
        }
        return _sortAscending ? comparison : -comparison;
      });
    });
  }

  String _getCurrencySymbol(String countryId) {
    switch (countryId) {
      case 'bd': return '৳';
      case 'in': return '₹';
      case 'pk': return '₨';
      case 'np': return '₨';
      case 'lk': return '₨';
      default: return '\$';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSummaryCards(),
              _buildFilters(),
              _buildTabBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildAgenciesList(),
              ),
              _buildMeetingReminder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final selectedCountryData = _allCountries.firstWhere(
          (c) => c['id'] == widget.countryId,
      orElse: () => {'name': 'Unknown', 'flag': '🌍'},
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage Agencies',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${selectedCountryData['name']} • $_totalAgencies agencies',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              selectedCountryData['flag'] ?? '🌍',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Active',
              '$_activeAgencies',
              Icons.check_circle,
              Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Pending',
              '$_pendingCount',
              Icons.hourglass_empty,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Revenue',
              '৳${(_totalRevenue / 100000).toStringAsFixed(1)}L',
              Icons.trending_up,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSummaryCard(
              'Issues',
              '$_issuesCount',
              Icons.warning,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: TextField(
              onChanged: (String value) {
                _searchQuery = value;
                _filterAndSortAgencies();
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search agencies by name, owner or location...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: InputBorder.none,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchQuery = '';
                    _filterAndSortAgencies();
                  },
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Row
          Row(
            children: [
              // Country Filter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCountry,
                    dropdownColor: AppColors.surfaceDark,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: _allCountries.map((Map<String, String> country) {
                      return DropdownMenuItem(
                        value: country['id'],
                        child: Row(
                          children: [
                            Text('${country['flag']} ', style: const TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                country['name']!,
                                style: const TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedCountry = value!;
                        _selectedCity = 'All Cities';
                        _filterAndSortAgencies();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // City Filter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedCity,
                    dropdownColor: AppColors.surfaceDark,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: _getCurrentCities().map((String city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedCity = value!;
                        _filterAndSortAgencies();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Sort By
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedSort,
                    dropdownColor: AppColors.surfaceDark,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: _sortOptions.map((String option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedSort = value!;
                        _filterAndSortAgencies();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Sort Order
              GestureDetector(
                onTap: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                    _filterAndSortAgencies();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.purple,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const [
          Tab(text: 'Active'),
          Tab(text: 'Pending'),
          Tab(text: 'Top'),
          Tab(text: 'Suspended'),
        ],
      ),
    );
  }

  Widget _buildAgenciesList() {
    if (_filteredAgencies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _tabController.index == 1 ? Icons.hourglass_empty :
              _tabController.index == 3 ? Icons.block :
              Icons.business_center,
              size: 60,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No agencies match "$_searchQuery"'
                  : _tabController.index == 1
                  ? 'No pending agencies'
                  : _tabController.index == 3
                  ? 'No suspended agencies'
                  : 'No agencies found',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredAgencies.length,
      itemBuilder: (BuildContext context, int index) {
        final agency = _filteredAgencies[index];
        return _buildAgencyCard(agency);
      },
    );
  }

  Widget _buildAgencyCard(ManagerAgency agency) {
    Color statusColor;
    switch (agency.status) {
      case 'Active':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Suspended':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    final riskColor = agency.riskLevel == 'High' ? Colors.red :
    agency.riskLevel == 'Medium' ? Colors.orange : Colors.green;

    final needsMeeting = agency.nextMeeting != null &&
        agency.nextMeeting!.difference(DateTime.now()).inDays < 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: agency.status == 'Pending'
            ? Border.all(color: Colors.orange.withOpacity(0.5))
            : agency.status == 'Active'
            ? Border.all(color: Colors.green.withOpacity(0.3))
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.business, color: Colors.purple, size: 24),
                  ),
                  if (agency.lastContact.difference(DateTime.now()).inDays < 7)
                    const Positioned(
                      bottom: 2,
                      right: 2,
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.green,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          agency.countryFlag,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            agency.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (agency.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(Icons.verified, color: Colors.blue, size: 14),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            agency.status,
                            style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${agency.ownerName} • ${agency.city}, ${agency.countryName}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAgencyStat(Icons.people, '${agency.activeHosts}/${agency.totalHosts}', 'Hosts'),
              _buildAgencyStat(Icons.money, '${_getCurrencySymbol(agency.countryId)}${agency.monthlyRevenue}', 'Monthly'),
              _buildAgencyStat(Icons.percent, '${agency.commissionRate}%', 'Comm'),
              _buildAgencyStat(Icons.trending_up, '${agency.monthlyGrowth}%', 'Growth'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: riskColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Risk: ${agency.riskLevel}',
                            style: TextStyle(color: riskColor, fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Score: ${agency.performanceScore}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                if (agency.pendingIssues > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${agency.pendingIssues} issues',
                      style: const TextStyle(color: Colors.red, fontSize: 10),
                    ),
                  ),
                if (needsMeeting)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Meeting soon',
                      style: TextStyle(color: Colors.blue, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton('Details', Colors.blue, () {
                  _showAgencyDetails(agency);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton('Contact', Colors.purple, () {
                  _showContactDialog(agency);
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton('Schedule', Colors.orange, () {
                  _showScheduleDialog(agency);
                }),
              ),
              const SizedBox(width: 8),
              if (agency.status == 'Pending')
                Expanded(
                  child: _buildActionButton('Approve', Colors.green, () {
                    _approveAgency(agency);
                  }),
                )
              else if (agency.status == 'Active')
                Expanded(
                  child: _buildActionButton('Suspend', Colors.red, () {
                    _suspendAgency(agency);
                  }),
                )
              else
                Expanded(
                  child: _buildActionButton('Reactivate', Colors.green, () {
                    _reactivateAgency(agency);
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgencyStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 8),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingReminder() {
    final upcomingMeetings = _agencies.where((a) =>
    a.nextMeeting != null &&
        a.nextMeeting!.difference(DateTime.now()).inDays < 3 &&
        a.nextMeeting!.isAfter(DateTime.now()),
    ).length;

    if (upcomingMeetings == 0) return const SizedBox();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'You have $upcomingMeetings upcoming meeting${upcomingMeetings > 1 ? 's' : ''} this week',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('View', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showAgencyDetails(ManagerAgency agency) {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: AppColors.surfaceDark,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Agency Details',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.business, color: Colors.purple, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                agency.name,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '${agency.countryFlag} ${agency.countryName}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  children: [
                    _buildDetailItem('Email', agency.email),
                    _buildDetailItem('Phone', agency.phone),
                    _buildDetailItem('City', agency.city),
                    _buildDetailItem('Status', agency.status),
                    _buildDetailItem('License', agency.licenseNumber),
                    _buildDetailItem('Tax ID', agency.taxId),
                    _buildDetailItem('Commission', '${agency.commissionRate}%'),
                    _buildDetailItem('Total Hosts', '${agency.totalHosts}'),
                    _buildDetailItem('Active Hosts', '${agency.activeHosts}'),
                    _buildDetailItem('Monthly', '${_getCurrencySymbol(agency.countryId)}${agency.monthlyRevenue}'),
                    _buildDetailItem('Total', '${_getCurrencySymbol(agency.countryId)}${agency.totalRevenue}'),
                    _buildDetailItem('Growth', '${agency.monthlyGrowth}%'),
                    _buildDetailItem('Score', '${agency.performanceScore}'),
                    _buildDetailItem('Risk', agency.riskLevel),
                    _buildDetailItem('Issues', '${agency.pendingIssues} pending'),
                  ],
                ),
              ),
              if (agency.notes != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Notes:', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 4),
                      Text(agency.notes!, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Text('$label:', style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog(ManagerAgency agency) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Contact Agency', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactItem(Icons.email, agency.email),
            _buildContactItem(Icons.phone, agency.phone),
            if (agency.website != null)
              _buildContactItem(Icons.language, agency.website!),
            if (agency.socialMedia.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Social Media:', style: TextStyle(color: Colors.white70)),
              ...agency.socialMedia.entries.map((e) =>
                  _buildContactItem(
                    e.key == 'facebook' ? Icons.facebook : Icons.camera_alt,
                    e.value,
                  ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            Text('Last Contact: ${_formatDate(agency.lastContact)}', style: const TextStyle(color: Colors.white70)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showScheduleDialog(agency);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Schedule Meeting'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(ManagerAgency agency) {
    var selectedDate = DateTime.now().add(const Duration(days: 1));
    var selectedTime = const TimeOfDay(hour: 10, minute: 0);

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Schedule Meeting', style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.white70),
                  title: const Text('Select Date', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.white70),
                  title: const Text('Select Time', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setState(() {
                        selectedTime = picked;
                      });
                    }
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Meeting scheduled with ${agency.name}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _approveAgency(ManagerAgency agency) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Approve Agency', style: TextStyle(color: Colors.white)),
        content: Text(
          'Approve ${agency.name}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final index = _agencies.indexWhere((a) => a.id == agency.id);
                if (index != -1) {
                  _agencies[index].status = 'Active';
                }
                _filterAndSortAgencies();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${agency.name} approved')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _suspendAgency(ManagerAgency agency) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Suspend Agency', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to suspend ${agency.name}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final index = _agencies.indexWhere((a) => a.id == agency.id);
                if (index != -1) {
                  _agencies[index].status = 'Suspended';
                }
                _filterAndSortAgencies();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${agency.name} suspended')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Suspend'),
          ),
        ],
      ),
    );
  }

  void _reactivateAgency(ManagerAgency agency) {
    setState(() {
      final index = _agencies.indexWhere((a) => a.id == agency.id);
      if (index != -1) {
        _agencies[index].status = 'Active';
      }
      _filterAndSortAgencies();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${agency.name} reactivated')),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ManagerAgency {
  final String id;
  final String name;
  final String ownerName;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String countryId;
  final String countryName;
  final String countryFlag;
  final DateTime registrationDate;
  String status;
  final bool isVerified;
  final int totalHosts;
  final int activeHosts;
  final double monthlyRevenue;
  final double totalRevenue;
  final double commissionRate;
  final DateTime lastContact;
  final int totalIssues;
  final int resolvedIssues;
  final double monthlyGrowth;
  final List<String> topHosts;
  final String licenseNumber;
  final String taxId;
  final String? website;
  final Map<String, String> socialMedia;
  final String? notes;
  final DateTime? lastMeeting;
  final DateTime? nextMeeting;
  final int performanceScore;
  final String riskLevel;

  ManagerAgency({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.countryId,
    required this.countryName,
    required this.countryFlag,
    required this.registrationDate,
    required this.status,
    required this.isVerified,
    required this.totalHosts,
    required this.activeHosts,
    required this.monthlyRevenue,
    required this.totalRevenue,
    required this.commissionRate,
    required this.lastContact,
    required this.totalIssues,
    required this.resolvedIssues,
    required this.monthlyGrowth,
    required this.topHosts,
    required this.licenseNumber,
    required this.taxId,
    this.website,
    this.socialMedia = const {},
    this.notes,
    this.lastMeeting,
    this.nextMeeting,
    required this.performanceScore,
    required this.riskLevel,
  });

  int get pendingIssues => totalIssues - resolvedIssues;
}