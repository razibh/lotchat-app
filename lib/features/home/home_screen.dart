import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/country_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/role_based_drawer.dart';
import '../../core/widgets/country_selector.dart';
import '../../core/models/room_model.dart';
import '../../core/services/room_service.dart';
import '../../core/services/navigation_service.dart';
import '../games/games_screen.dart';
import '../wallet/wallet_screen.dart';
import '../profile/profile_screen.dart';
import '../room/room_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCountry = 'All';
  String _selectedRegion = 'All';
  String _searchQuery = '';
  int _selectedNavIndex = 0;
  bool _isLoading = true;
  List<RoomModel> _rooms = <RoomModel>[];
  List<RoomModel> _followingRooms = <RoomModel>[];
  List<RoomModel> _nearbyRooms = <RoomModel>[];
  List<Map<String, dynamic>> _hotRooms = <Map<String, dynamic>>[];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadInitialData();
    _setupSearchListener();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      _loadRoomsForTab();
    }
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    
    try {
      await Future.wait(<Future<void>>[
        _loadRooms(),
        _loadHotRooms(),
      ]);
    } catch (e) {
      debugPrint('Error loading home data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRooms() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Sample data
    _rooms = List.generate(10, (int index) {
      return RoomModel(
        id: 'room_${100 + index}',
        title: '${_selectedCountry == 'All' ? 'International' : _selectedCountry} Room ${index + 1}',
        hostName: 'Host ${index + 1}',
        hostAvatar: null,
        viewers: 150 + (index * 50),
        tags: <String>['music', 'chat', 'fun'],
        country: _selectedCountry == 'All' ? 'International' : _selectedCountry,
        isLive: index % 3 == 0,
        isTrending: index < 3,
      );
    });

    _followingRooms = _rooms.where((RoomModel r) => r.isTrending).toList();
    _nearbyRooms = _rooms.where((RoomModel r) => r.country == _selectedCountry).toList();
  }

  Future<void> _loadHotRooms() async {
    _hotRooms = <Map<String, dynamic>>[
      <String, dynamic>{'title': 'Music Night', 'viewers': 1250, 'color': Colors.purple},
      <String, dynamic>{'title': 'Gaming Zone', 'viewers': 980, 'color': Colors.blue},
      <String, dynamic>{'title': 'Talk Show', 'viewers': 750, 'color': Colors.green},
      <String, dynamic>{'title': 'Singing Battle', 'viewers': 620, 'color': Colors.orange},
      <String, dynamic>{'title': 'Comedy Club', 'viewers': 540, 'color': Colors.red},
    ];
  }

  Future<void> _loadRoomsForTab() async {
    setState(() => _isLoading = true);
    await _loadRooms();
    setState(() => _isLoading = false);
  }

  List<RoomModel> get _filteredRooms {
    if (_searchQuery.isEmpty) return _rooms;
    
    return _rooms.where((RoomModel room) =>
      room.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      room.hostName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      room.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final countryProvider = Provider.of<CountryProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        if (_searchQuery.isNotEmpty) {
          setState(() => _searchQuery = '');
          _searchController.clear();
          return false;
        }
        return true;
      },
      child: Scaffold(
        drawer: authProvider.isLoggedIn 
            ? RoleBasedDrawer(
                user: authProvider.currentUser,
                onLogout: () => _handleLogout(context),
              )
            : _buildGuestDrawer(context),
        body: GradientBackground(
          child: SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return <>[
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    snap: true,
                    expandedHeight: 220,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: <>[
                              AppColors.accentPurple,
                              AppColors.accentBlue,
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Column(
                            children: <>[
                              _buildTopBar(context, authProvider, countryProvider),
                              _buildCountrySelector(countryProvider),
                              _buildHotStrip(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    bottom: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      tabs: const <>[
                        Tab(text: 'For You'),
                        Tab(text: 'Following'),
                        Tab(text: 'Nearby'),
                      ],
                    ),
                  ),
                ];
              },
              body: _isLoading
                  ? _buildShimmerLoading()
                  : TabBarView(
                      controller: _tabController,
                      children: <>[
                        _buildRoomList(_filteredRooms),
                        _buildRoomList(_followingRooms),
                        _buildNearbyList(),
                      ],
                    ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AuthProvider auth, CountryProvider country) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <>[
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  auth.isLoggedIn 
                      ? 'Welcome, ${auth.currentUser?.name ?? 'User'}!'
                      : 'Welcome, Guest!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (country.selectedCountry != null)
                  Row(
                    children: <>[
                      Text(
                        country.selectedCountry!.flag,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        country.selectedCountry!.name,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Search Bar
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search rooms...',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Filter Button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.tune, color: Colors.white, size: 20),
              onPressed: _showFilterDialog,
            ),
          ),
          // Notification Button
          if (auth.isLoggedIn) ...<>[
            const SizedBox(width: 8),
            Stack(
              children: <>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white, size: 20),
                    onPressed: () {
                      NavigationService.navigateTo('/notifications');
                    },
                  ),
                ),
                if (Provider.of<NotificationProvider>(context).hasUnread)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCountrySelector(CountryProvider countryProvider) {
    return CountrySelector(
      selectedCountry: _selectedCountry,
      onCountryChanged: (country) {
        setState(() {
          _selectedCountry = country;
        });
        _loadRoomsForTab();
      },
    );
  }

  Widget _buildHotStrip() {
    return Container(
      height: 70,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _hotRooms.length,
        itemBuilder: (context, index) {
          final Map<String, dynamic> room = _hotRooms[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <>[
                  (room['color'] as Color).withOpacity(0.8),
                  (room['color'] as Color).withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: <>[
                BoxShadow(
                  color: (room['color'] as Color).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: <>[
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: <>[
                        const Icon(Icons.visibility, color: Colors.white, size: 10),
                        const SizedBox(width: 2),
                        Text(
                          '${room['viewers']}',
                          style: const TextStyle(color: Colors.white, fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <>[
                      const Icon(Icons.whatshot, color: Colors.white, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        room['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomList(List<RoomModel> rooms) {
    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            Icon(
              Icons.room_preferences,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No rooms match "$_searchQuery"'
                  : _tabController.index == 1
                      ? 'No followed rooms yet'
                      : 'No rooms available',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            if (_tabController.index == 1)
              TextButton(
                onPressed: () {
                  _tabController.animateTo(0);
                },
                child: const Text('Explore Rooms'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final RoomModel room = rooms[index];
        return RoomCard(
          room: room,
          onTap: () {
            NavigationService.navigateTo('/room', arguments: room);
          },
        );
      },
    );
  }

  Widget _buildNearbyList() {
    if (_selectedCountry == 'All') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            const Icon(Icons.public, size: 80, color: Colors.white30),
            const SizedBox(height: 16),
            const Text(
              'Select a country to see nearby rooms',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                _showCountrySelector();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPurple,
              ),
              child: const Text('Select Country'),
            ),
          ],
        ),
      );
    }

    return _buildRoomList(_nearbyRooms);
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[600]!,
          child: Container(
            height: 200,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: (index) {
        setState(() => _selectedNavIndex = index);
        _handleNavigation(index);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.accentPurple,
      unselectedItemColor: Colors.white54,
      items: const <>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_esports),
          label: 'Games',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Wallet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  void _handleNavigation(int index) {
    switch (index) {
      case 1:
        NavigationService.navigateTo('/explore');
      case 2:
        NavigationService.navigateTo('/games');
      case 3:
        NavigationService.navigateTo('/wallet');
      case 4:
        NavigationService.navigateTo('/profile');
    }
  }

  Widget _buildGuestDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceDark,
      child: Column(
        children: <>[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <>[
                  AppColors.accentPurple,
                  AppColors.accentBlue,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <>[
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: Colors.purple),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Guest User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'guest@example.com',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <>[
                _buildDrawerItem(Icons.home, 'Home', () {
                  Navigator.pop(context);
                }),
                _buildDrawerItem(Icons.login, 'Login', () {
                  Navigator.pop(context);
                  NavigationService.navigateTo('/login');
                }),
                _buildDrawerItem(Icons.app_registration, 'Register', () {
                  Navigator.pop(context);
                  NavigationService.navigateTo('/register');
                }),
                const Divider(color: Colors.white24),
                _buildDrawerItem(Icons.help, 'Help', () {}),
                _buildDrawerItem(Icons.info, 'About', () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: <>[
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Filter Rooms',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <>[
                  const Text(
                    'Region',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <String>['All', 'Asia', 'Europe', 'America', 'Africa', 'Oceania']
                        .map((String region) => FilterChip(
                              label: Text(region),
                              selected: _selectedRegion == region,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedRegion = region;
                                });
                                Navigator.pop(context);
                              },
                              backgroundColor: Colors.white.withOpacity(0.1),
                              selectedColor: AppColors.accentPurple,
                              labelStyle: TextStyle(
                                color: _selectedRegion == region ? Colors.white : Colors.white70,
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Room Type',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <String>['All', 'Voice', 'Video', 'Games', 'Music']
                        .map((String type) => FilterChip(
                              label: Text(type),
                              selected: false,
                              onSelected: (selected) {},
                              backgroundColor: Colors.white.withOpacity(0.1),
                              labelStyle: const TextStyle(color: Colors.white70),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sort By',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <String>['Trending', 'Newest', 'Most Viewers', 'Nearby']
                        .map((String sort) => FilterChip(
                              label: Text(sort),
                              selected: false,
                              onSelected: (selected) {},
                              backgroundColor: Colors.white.withOpacity(0.1),
                              labelStyle: const TextStyle(color: Colors.white70),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentPurple,
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCountrySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            const Text(
              'Select Country',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...Provider.of<CountryProvider>(context).supportedCountries.map((country) {
              return ListTile(
                leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
                title: Text(country.name, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    _selectedCountry = country.name;
                  });
                  Navigator.pop(context);
                  _loadRoomsForTab();
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (mounted) {
      NavigationService.navigateToAndRemoveUntil('/login');
    }
  }
}

// Room Card Widget (if not exists in separate file)
class RoomCard extends StatelessWidget {

  const RoomCard({
    Key? key,
    required this.room,
    required this.onTap,
  }) : super(key: key);
  final RoomModel room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <>[
              if (room.isTrending) Colors.purple else Colors.blue,
              if (room.isTrending) Colors.pink else Colors.cyan,
            ].map((Object? c) => c.withOpacity(0.3)).toList(),
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: room.isLive ? Colors.red : Colors.white24,
            width: room.isLive ? 2 : 1,
          ),
        ),
        child: Stack(
          children: <>[
            if (room.isLive)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <>[
                      Icon(Icons.fiber_manual_record, color: Colors.white, size: 8),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ),
            if (room.isTrending)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <>[
                      Icon(Icons.whatshot, color: Colors.white, size: 8),
                      SizedBox(width: 4),
                      Text(
                        'TRENDING',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: <>[
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.purple,
                    child: Text(
                      room.hostName[0],
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <>[
                        Text(
                          room.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          room.hostName,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <>[
                            const Icon(Icons.visibility, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${room.viewers} viewers',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.public, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              room.country,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: room.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#$tag',
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}