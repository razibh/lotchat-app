import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/providers/country_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/role_based_drawer.dart';
import '../../widgets/country_selector.dart';
import '../../core/models/room_model.dart';
// Remove NavigationService import
// import '../../core/services/navigation_service.dart';
import '../games/games_screen.dart';
import '../wallet/wallet_screen.dart';
import '../profile/profile_screen.dart';
import '../room/room_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
  List<RoomModel> _rooms = [];
  List<RoomModel> _followingRooms = [];
  List<RoomModel> _nearbyRooms = [];
  List<Map<String, dynamic>> _hotRooms = [];

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
      await Future.wait([
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
    await Future.delayed(const Duration(seconds: 1));

    _rooms = List.generate(10, (index) {
      return RoomModel(
        id: 'room_${100 + index}',
        name: '${_selectedCountry == 'All' ? 'International' : _selectedCountry} Room ${index + 1}',
        hostId: 'host_${index + 1}',
        hostName: 'Host ${index + 1}',
        hostAvatar: null,
        category: index % 3 == 0 ? 'music' : (index % 3 == 1 ? 'gaming' : 'chat'),
        description: 'This is a sample room description',
        viewerCount: 150 + (index * 50),
        maxSeats: 9,
        seats: [],
        isPKActive: false,
        isPrivate: false,
        createdAt: DateTime.now().subtract(Duration(hours: index)),
        moderators: [],
        giftsReceived: {},
        country: _selectedCountry == 'All' ? 'International' : _selectedCountry,
        status: index % 3 == 0 ? RoomStatus.active : RoomStatus.active,
        tags: ['music', 'chat', 'fun'],
        totalGifts: 5 + index,
        totalMessages: 20 + index,
        totalParticipants: 150 + (index * 50),
      );
    });

    _followingRooms = _rooms.where((room) => room.viewerCount > 300).toList();
    _nearbyRooms = _rooms.where((room) => room.country == _selectedCountry).toList();
  }

  Future<void> _loadHotRooms() async {
    _hotRooms = [
      {'title': 'Music Night', 'viewers': 1250, 'color': Colors.purple},
      {'title': 'Gaming Zone', 'viewers': 980, 'color': Colors.blue},
      {'title': 'Talk Show', 'viewers': 750, 'color': Colors.green},
      {'title': 'Singing Battle', 'viewers': 620, 'color': Colors.orange},
      {'title': 'Comedy Club', 'viewers': 540, 'color': Colors.red},
    ];
  }

  Future<void> _loadRoomsForTab() async {
    setState(() => _isLoading = true);
    await _loadRooms();
    setState(() => _isLoading = false);
  }

  List<RoomModel> get _filteredRooms {
    if (_searchQuery.isEmpty) return _rooms;

    return _rooms.where((room) {
      final name = room.name.toLowerCase();
      final host = room.hostName.toLowerCase();
      final query = _searchQuery.toLowerCase();

      if (name.contains(query) || host.contains(query)) {
        return true;
      }

      return room.tags?.any((tag) => tag.toLowerCase().contains(query)) ?? false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider?>(context);
    final countryProvider = Provider.of<CountryProvider?>(context);
    final notificationProvider = Provider.of<NotificationProvider?>(context);

    if (authProvider == null || countryProvider == null || notificationProvider == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
                return [
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    snap: true,
                    expandedHeight: 220,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.accentPurple,
                              AppColors.accentBlue,
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Column(
                            children: [
                              _buildTopBar(context, authProvider, countryProvider, notificationProvider),
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
                      tabs: const [
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
                children: [
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

  Widget _buildTopBar(BuildContext context, AuthProvider auth, CountryProvider country, NotificationProvider notification) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    children: [
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
          Expanded(
            flex: 3,
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
          if (auth.isLoggedIn) ...[
            const SizedBox(width: 8),
            Stack(
              children: [
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
                      // ✅ Use Navigator directly
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                ),
                if (notification.unreadCount > 0)
                  const Positioned(
                    top: 5,
                    right: 5,
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: Colors.red,
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
          final room = _hotRooms[index];
          final color = room['color'] as Color;
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.8),
                  color.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
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
                      children: [
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
                    children: [
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
          children: [
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
        final room = rooms[index];
        return GestureDetector(
          onTap: () {
            // ✅ Use Navigator directly
            Navigator.pushNamed(context, '/room', arguments: room);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  room.viewerCount > 300 ? Colors.purple : Colors.blue,
                  room.viewerCount > 300 ? Colors.pink : Colors.cyan,
                ].map((c) => c.withOpacity(0.3)).toList(),
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: room.status == RoomStatus.active ? Colors.red : Colors.white24,
                width: room.status == RoomStatus.active ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
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
                      children: [
                        Text(
                          room.name,
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
                          children: [
                            const Icon(Icons.visibility, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${room.viewerCount} viewers',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.public, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              room.country ?? 'International',
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNearbyList() {
    if (_selectedCountry == 'All') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.public, size: 80, color: Colors.white30),
            const SizedBox(height: 16),
            const Text(
              'Select a country to see nearby rooms',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _showCountrySelector,
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
      items: const [
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

  // ✅ FIXED: Use Navigator directly
  void _handleNavigation(int index) {
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/explore');
        break;
      case 2:
        Navigator.pushNamed(context, '/games');
        break;
      case 3:
        Navigator.pushNamed(context, '/wallet');
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  Widget _buildGuestDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surfaceDark,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentPurple,
                  AppColors.accentBlue,
                ],
              ),
            ),
            child: const SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 30, color: Colors.purple),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Guest User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
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
              children: [
                _buildDrawerItem(Icons.home, 'Home', () {
                  Navigator.pop(context);
                }),
                _buildDrawerItem(Icons.login, 'Login', () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                }),
                _buildDrawerItem(Icons.app_registration, 'Register', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/register');
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
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
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
                children: [
                  const Text(
                    'Region',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All', 'Asia', 'Europe', 'America', 'Africa', 'Oceania']
                        .map((region) => FilterChip(
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
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
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
    final countryProvider = Provider.of<CountryProvider?>(context, listen: false);
    if (countryProvider == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Country',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...countryProvider.supportedCountries.map((country) {
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
    final authProvider = Provider.of<AuthProvider?>(context, listen: false);
    if (authProvider == null) return;

    await authProvider.logout();
    if (mounted) {
      // ✅ Use Navigator directly
      Navigator.pushReplacementNamed(context, '/login');
    }
  }
}