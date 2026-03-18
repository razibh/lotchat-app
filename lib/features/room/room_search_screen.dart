import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class RoomSearchScreen extends StatefulWidget {
  const RoomSearchScreen({super.key});

  @override
  State<RoomSearchScreen> createState() => _RoomSearchScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class _RoomSearchScreenState extends State<RoomSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';
  List<RoomSearchResult> _searchResults = [];
  List<RoomSearchResult> _recentSearches = [];
  List<String> _popularTags = [];

  final List<String> _categories = [
    'All',
    'Music',
    'Chat',
    'Games',
    'Study',
    'Party',
    'Chill',
    'Debate',
    'Podcast',
    'Learning',
  ];

  String _selectedCategory = 'All';
  String _selectedSort = 'Relevance';
  int _selectedParticipants = 0;
  RangeValues _participantRange = const RangeValues(0, 50);

  final List<String> _sortOptions = ['Relevance', 'Newest', 'Popular', 'Name'];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadPopularTags();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    _recentSearches = [
      RoomSearchResult(
        id: 'recent_1',
        name: 'Music Lovers',
        hostName: 'DJ Alex',
        category: 'Music',
        participants: 45,
        maxParticipants: 50,
        thumbnail: null,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      RoomSearchResult(
        id: 'recent_2',
        name: 'Game Zone',
        hostName: 'GamerPro',
        category: 'Games',
        participants: 32,
        maxParticipants: 50,
        thumbnail: null,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      RoomSearchResult(
        id: 'recent_3',
        name: 'Study Group',
        hostName: 'Professor',
        category: 'Study',
        participants: 18,
        maxParticipants: 30,
        thumbnail: null,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  void _loadPopularTags() {
    _popularTags = [
      'Music',
      'Gaming',
      'Study',
      'Party',
      'Chill',
      'Debate',
      'Karaoke',
      'Podcast',
      'Learning',
      'Friends',
    ];
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchQuery = _searchController.text;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock search results - FIXED: Added createdAt parameter
    final results = List.generate(15, (index) {
      return RoomSearchResult(
        id: 'room_${index + 1000}',
        name: '${_searchQuery} Room ${index + 1}',
        hostName: 'Host ${index + 1}',
        category: _categories[(index + 1) % _categories.length],
        participants: 10 + (index * 3),
        maxParticipants: 50,
        thumbnail: null,
        isLive: index % 3 == 0,
        hasPassword: index % 5 == 0,
        tags: ['music', 'chat', 'fun'],
        createdAt: DateTime.now().subtract(Duration(hours: index * 2)),
      );
    });

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _searchResults.clear();
    });
  }

  void _applyFilters() {
    Navigator.pop(context);
    _performSearch();
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Category Filter
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _categories.map((category) {
                  return FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Sort By
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: _sortOptions.map((option) {
                  return ButtonSegment(
                    value: option,
                    label: Text(option),
                  );
                }).toList(),
                selected: {_selectedSort},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _selectedSort = selection.first;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Participants Range
              const Text(
                'Participants',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              RangeSlider(
                values: _participantRange,
                min: 0,
                max: 50,
                divisions: 10,
                labels: RangeLabels(
                  '${_participantRange.start.round()}',
                  '${_participantRange.end.round()}',
                ),
                onChanged: (values) {
                  setState(() {
                    _participantRange = values;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Min: ${_participantRange.start.round()}'),
                  Text('Max: ${_participantRange.end.round()}'),
                ],
              ),
              const SizedBox(height: 20),

              // Apply Button
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'All';
                          _selectedSort = 'Relevance';
                          _participantRange = const RangeValues(0, 50);
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Rooms'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search rooms...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),

          // Search Results or Recent Searches
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchQuery.isEmpty
                ? _buildRecentAndPopular()
                : _searchResults.isEmpty
                ? _buildEmptyResults()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAndPopular() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Recent Searches
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _recentSearches.clear();
                  });
                },
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._recentSearches.map((search) => ListTile(
            leading: const Icon(Icons.history, color: Colors.grey),
            title: Text(search.name),
            subtitle: Text(search.hostName),
            trailing: const Icon(Icons.arrow_upward, size: 16),
            onTap: () {
              _searchController.text = search.name;
              _performSearch();
            },
          )),
          const SizedBox(height: 20),
        ],

        // Popular Tags
        const Text(
          'Popular Tags',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: _popularTags.map((tag) {
            return ActionChip(
              label: Text('#$tag'),
              onPressed: () {
                _searchController.text = tag;
                _performSearch();
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Popular Rooms (mock) - FIXED: Added createdAt parameter
        const Text(
          'Popular Rooms',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(3, (index) => _buildPopularRoomCard(index)),
      ],
    );
  }

  Widget _buildPopularRoomCard(int index) {
    final roomNames = ['Music Lounge', 'Game Arena', 'Study Hub'];
    final participants = [45, 32, 28];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.shade300,
                Colors.purple.shade300,
              ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              roomNames[index][0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(roomNames[index]),
        subtitle: Text('${participants[index]} participants'),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
          ),
          child: const Text('Join'),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: [
        // Results count
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${_searchResults.length} rooms found',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _selectedSort,
                items: _sortOptions.map((option) {
                  return DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value!;
                  });
                },
              ),
            ],
          ),
        ),

        // Results list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final room = _searchResults[index];
              return _buildSearchResultCard(room);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultCard(RoomSearchResult room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to room
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade300,
                      Colors.purple.shade300,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        room.category[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (room.isLive)
                      const Positioned(
                        top: 4,
                        right: 4,
                        child: _LiveBadge(),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Room info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (room.hasPassword)
                          const Icon(
                            Icons.lock,
                            size: 14,
                            color: Colors.grey,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${room.hostName} • ${room.category}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${room.participants}/${room.maxParticipants}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...room.tags.take(2).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.deepPurple,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),

              // Join button
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Join room
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(60, 30),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Join',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatNumber(room.participants),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No rooms found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords or filters',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _clearSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
            ),
            child: const Text('Clear Search'),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'LIVE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class RoomSearchResult {
  final String id;
  final String name;
  final String hostName;
  final String category;
  final int participants;
  final int maxParticipants;
  final String? thumbnail;
  final bool isLive;
  final bool hasPassword;
  final List<String> tags;
  final DateTime createdAt;

  RoomSearchResult({
    required this.id,
    required this.name,
    required this.hostName,
    required this.category,
    required this.participants,
    required this.maxParticipants,
    this.thumbnail,
    this.isLive = false,
    this.hasPassword = false,
    this.tags = const [],
    required this.createdAt,
  });
}

// Simplified version for error fixing
class RoomSearchScreenSimple extends StatelessWidget {
  const RoomSearchScreenSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Room Search Screen'),
      ),
    );
  }
}