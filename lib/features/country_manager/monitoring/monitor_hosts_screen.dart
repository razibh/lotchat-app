import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../Models/country_manager_models.dart';
class MonitorHostsScreen extends StatefulWidget {
  final String managerId;

  const MonitorHostsScreen({required this.managerId, super.key});

  @override
  State<MonitorHostsScreen> createState() => _MonitorHostsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('managerId', managerId));
  }
}

class _MonitorHostsScreenState extends State<MonitorHostsScreen> {
  bool _isLoading = true;
  List<HostPerformance> _hosts = [];
  List<HostPerformance> _filteredHosts = [];
  String _searchQuery = '';
  String _selectedFilter = 'all';
  String _sortBy = 'earnings';

  final List<String> _filters = ['all', 'top', 'rising', 'new'];
  final List<String> _sortOptions = ['earnings', 'followers', 'rating', 'rooms'];

  @override
  void initState() {
    super.initState();
    _loadHosts();
  }

  Future<void> _loadHosts() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _hosts = _generateSampleHosts(50);
      _filterAndSortHosts();
      _isLoading = false;
    });
  }

  List<HostPerformance> _generateSampleHosts(int count) {
    return List.generate(count, (index) {
      return HostPerformance(
        hostId: 'host_${100 + index}',
        name: 'Host ${index + 1}',
        username: 'host_${index + 1}',
        agencyId: 'ag_${100 + (index % 10)}',
        agencyName: 'Agency ${(index % 10) + 1}',
        followers: 1000 + (index * 200),
        followersGrowth: 5 + (index % 20),
        monthlyEarnings: 5000 + (index * 1000),
        totalEarnings: 50000 + (index * 10000),
        totalRooms: 20 + (index % 50),
        totalHours: 100 + (index * 10),
        avgRating: 4.0 + (index % 10) / 10,
        giftsReceived: 500 + (index * 50),
        recentEvents: [],
      );
    });
  }

  void _filterAndSortHosts() {
    setState(() {
      // Apply filter
      if (_selectedFilter == 'all') {
        _filteredHosts = List.from(_hosts);
      } else if (_selectedFilter == 'top') {
        _filteredHosts = _hosts.where((h) => h.monthlyEarnings > 20000).toList();
      } else if (_selectedFilter == 'rising') {
        _filteredHosts = _hosts.where((h) => h.followersGrowth > 15).toList();
      } else if (_selectedFilter == 'new') {
        // For demo, just take first 10
        _filteredHosts = _hosts.take(10).toList();
      }

      // Apply search
      if (_searchQuery.isNotEmpty) {
        _filteredHosts = _filteredHosts.where((h) =>
        h.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            h.username.toLowerCase().contains(_searchQuery.toLowerCase()),
        ).toList();
      }

      // Apply sorting
      if (_sortBy == 'earnings') {
        _filteredHosts.sort((a, b) => b.monthlyEarnings.compareTo(a.monthlyEarnings));
      } else if (_sortBy == 'followers') {
        _filteredHosts.sort((a, b) => b.followers.compareTo(a.followers));
      } else if (_sortBy == 'rating') {
        _filteredHosts.sort((a, b) => b.avgRating.compareTo(a.avgRating));
      } else if (_sortBy == 'rooms') {
        _filteredHosts.sort((a, b) => b.totalRooms.compareTo(a.totalRooms));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              _buildFilterChips(),
              _buildSortBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildHostsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Monitor Hosts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            'Total: ${_filteredHosts.length}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        onChanged: (String value) {
          _searchQuery = value;
          _filterAndSortHosts();
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search hosts...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          border: InputBorder.none,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.white70),
            onPressed: () {
              _searchQuery = '';
              _filterAndSortHosts();
            },
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final bool isSelected = _selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter.toUpperCase()),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  _selectedFilter = filter;
                  _filterAndSortHosts();
                });
              },
              backgroundColor: Colors.white.withOpacity(0.1),
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: _sortOptions.map((String option) {
          final isSelected = _sortBy == option;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _sortBy = option;
                  _filterAndSortHosts();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  option.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHostsList() {
    if (_filteredHosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 60, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No hosts found',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _filteredHosts.length,
      itemBuilder: (context, index) {
        final host = _filteredHosts[index];
        return _buildHostCard(host, index);
      },
    );
  }

  Widget _buildHostCard(HostPerformance host, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: rank < 3
            ? Border.all(
          color: rank == 0
              ? Colors.amber
              : rank == 1
              ? Colors.grey
              : Colors.brown,
          width: 2,
        )
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (rank < 3)
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: rank == 0
                        ? Colors.amber
                        : rank == 1
                        ? Colors.grey
                        : Colors.brown,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#${rank + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue,
                child: Text(
                  host.name[0],
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      host.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '@${host.username}',
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    Text(
                      host.agencyName,
                      style: const TextStyle(color: Colors.blue, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '৳${host.monthlyEarnings}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${host.avgRating.toStringAsFixed(1)} ⭐',
                      style: const TextStyle(color: Colors.purple, fontSize: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHostStat(Icons.people, '${host.followers}', 'Followers'),
              _buildHostStat(Icons.trending_up, '${host.followersGrowth}%', 'Growth'),
              _buildHostStat(Icons.meeting_room, '${host.totalRooms}', 'Rooms'),
              _buildHostStat(Icons.card_giftcard, '${host.giftsReceived}', 'Gifts'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton('View Profile', () {}),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildActionButton('Contact', () {}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHostStat(IconData icon, String value, String label) {
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

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
    );
  }
}