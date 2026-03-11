import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animations/animations.dart';
import '../../widgets/room_card.dart';
import '../../widgets/country_selector.dart';
import '../../core/models/room_model.dart';
import '../../core/services/room_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedCountry = 'All';
  String selectedRegion = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              expandedHeight: 180,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.purple, Colors.pink],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Top Bar with Search
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search by ID...',
                                      hintStyle:
                                          TextStyle(color: Colors.white70),
                                      prefixIcon: Icon(Icons.search,
                                          color: Colors.white),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.filter_list,
                                      color: Colors.white),
                                  onPressed: () {
                                    _showFilterDialog();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Country Selector
                        CountrySelector(
                          selectedCountry: selectedCountry,
                          onCountryChanged: (country) {
                            setState(() {
                              selectedCountry = country;
                            });
                          },
                        ),

                        // Hot Right Now Strip
                        _buildHotStrip(),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                tabs: [
                  Tab(text: 'For You'),
                  Tab(text: 'Following'),
                  Tab(text: 'Nearby'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildRoomList(),
            _buildFollowingList(),
            _buildNearbyList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHotStrip() {
    return Container(
      height: 60,
      margin: EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange, Colors.red],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 5,
                  top: 5,
                  child: Icon(Icons.whatshot, color: Colors.white, size: 16),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🔥 HOT',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        'Room ${index + 1}',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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

  Widget _buildRoomList() {
    return StreamBuilder<List<RoomModel>>(
      stream: RoomService().getRooms(selectedCountry),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return _buildShimmerLoading();
        }

        final rooms = snapshot.data!;

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return RoomCard(
              room: room,
              onTap: () {
                Navigator.pushNamed(context, '/room', arguments: room);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 200,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFollowingList() {
    return Center(child: Text('Following Rooms'));
  }

  Widget _buildNearbyList() {
    return Center(child: Text('Nearby Users'));
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Discover'),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Filter by Region',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: ['All', 'Asia', 'Europe', 'America', 'Africa']
                    .map((region) {
                  return FilterChip(
                    label: Text(region),
                    selected: selectedRegion == region,
                    onSelected: (selected) {
                      setState(() {
                        selectedRegion = region;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
