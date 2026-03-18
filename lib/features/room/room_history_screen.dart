import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class RoomHistoryScreen extends StatefulWidget {
  const RoomHistoryScreen({super.key});

  @override
  State<RoomHistoryScreen> createState() => _RoomHistoryScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
  }
}

class _RoomHistoryScreenState extends State<RoomHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _searchQuery = '';

  List<RoomHistory> _recentRooms = [];
  List<RoomHistory> _joinedRooms = [];
  List<RoomHistory> _createdRooms = [];
  List<RoomHistory> _favoriteRooms = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    // Generate recent rooms
    _recentRooms = List.generate(20, (index) {
      return RoomHistory(
        id: 'room_${index + 100}',
        name: 'Room ${index + 1}',
        hostName: 'Host ${index + 1}',
        category: _getCategory(index),
        participants: 10 + (index % 20),
        maxParticipants: 50,
        joinedAt: DateTime.now().subtract(Duration(hours: index * 2)),
        leftAt: DateTime.now().subtract(Duration(hours: index * 2 - 1)),
        duration: Duration(minutes: 30 + index),
        isFavorite: index % 5 == 0,
        thumbnail: null,
      );
    });

    // Generate joined rooms
    _joinedRooms = List.generate(15, (index) {
      return RoomHistory(
        id: 'room_${index + 200}',
        name: 'Joined Room ${index + 1}',
        hostName: 'Host ${index + 10}',
        category: _getCategory(index + 3),
        participants: 15 + (index % 15),
        maxParticipants: 50,
        joinedAt: DateTime.now().subtract(Duration(days: index)),
        leftAt: null,
        duration: Duration(minutes: 45 + index),
        isFavorite: index % 3 == 0,
        thumbnail: null,
      );
    });

    // Generate created rooms
    _createdRooms = List.generate(8, (index) {
      return RoomHistory(
        id: 'room_${index + 300}',
        name: 'My Room ${index + 1}',
        hostName: 'You',
        category: _getCategory(index + 5),
        participants: 20 + (index * 2),
        maxParticipants: 50,
        joinedAt: DateTime.now().subtract(Duration(days: index * 2)),
        leftAt: null,
        duration: Duration(hours: 1 + index),
        isFavorite: index % 2 == 0,
        thumbnail: null,
      );
    });

    // Generate favorite rooms
    _favoriteRooms = List.generate(6, (index) {
      return RoomHistory(
        id: 'room_${index + 400}',
        name: 'Favorite Room ${index + 1}',
        hostName: 'Host ${index + 20}',
        category: _getCategory(index + 7),
        participants: 25 + index,
        maxParticipants: 50,
        joinedAt: DateTime.now().subtract(Duration(days: index * 3)),
        leftAt: null,
        duration: Duration(minutes: 60 + index * 10),
        isFavorite: true,
        thumbnail: null,
      );
    });

    setState(() => _isLoading = false);
  }

  String _getCategory(int index) {
    const categories = ['Music', 'Chat', 'Games', 'Study', 'Party', 'Chill', 'Debate', 'Podcast'];
    return categories[index % categories.length];
  }

  List<RoomHistory> get _filteredRecentRooms {
    if (_searchQuery.isEmpty) return _recentRooms;
    return _recentRooms.where((room) {
      return room.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          room.hostName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          room.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<RoomHistory> get _filteredJoinedRooms {
    if (_searchQuery.isEmpty) return _joinedRooms;
    return _joinedRooms.where((room) {
      return room.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          room.hostName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          room.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<RoomHistory> get _filteredCreatedRooms {
    if (_searchQuery.isEmpty) return _createdRooms;
    return _createdRooms.where((room) {
      return room.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          room.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<RoomHistory> get _filteredFavoriteRooms {
    if (_searchQuery.isEmpty) return _favoriteRooms;
    return _favoriteRooms.where((room) {
      return room.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          room.hostName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          room.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Room History'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Recent'),
            Tab(text: 'Joined'),
            Tab(text: 'Created'),
            Tab(text: 'Favorites'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
              controller: _tabController,
              children: [
                _buildRoomList(_filteredRecentRooms),
                _buildRoomList(_filteredJoinedRooms),
                _buildRoomList(_filteredCreatedRooms),
                _buildRoomList(_filteredFavoriteRooms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search rooms...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
            },
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildRoomList(List<RoomHistory> rooms) {
    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _tabController.index == 0 ? Icons.history :
              _tabController.index == 1 ? Icons.people :
              _tabController.index == 2 ? Icons.create :
              Icons.favorite,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No rooms match "$_searchQuery"'
                  : _tabController.index == 0
                  ? 'No recent rooms'
                  : _tabController.index == 1
                  ? 'No joined rooms'
                  : _tabController.index == 2
                  ? 'No created rooms'
                  : 'No favorite rooms',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
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
        return _buildRoomCard(room);
      },
    );
  }

  Widget _buildRoomCard(RoomHistory room) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to room details
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
                child: Center(
                  child: Text(
                    room.category[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                        if (room.isFavorite)
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Host: ${room.hostName} • ${room.category}',
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
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatDuration(room.duration),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Joined: ${_formatDate(room.joinedAt)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
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
                  TextButton(
                    onPressed: () {
                      _showRoomDetails(room);
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(60, 30),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'Details',
                      style: TextStyle(fontSize: 10),
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

  void _showRoomDetails(RoomHistory room) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
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
            Row(
              children: [
                Container(
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
                      room.category[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'by ${room.hostName}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Category', room.category),
            _buildDetailRow('Participants', '${room.participants}/${room.maxParticipants}'),
            _buildDetailRow('Duration', _formatDuration(room.duration)),
            _buildDetailRow('Joined', _formatDate(room.joinedAt)),
            if (room.leftAt != null)
              _buildDetailRow('Left', _formatDate(room.leftAt!)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Join room
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: const Text('Join Room'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class RoomHistory {
  final String id;
  final String name;
  final String hostName;
  final String category;
  final int participants;
  final int maxParticipants;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final Duration duration;
  final bool isFavorite;
  final String? thumbnail;

  RoomHistory({
    required this.id,
    required this.name,
    required this.hostName,
    required this.category,
    required this.participants,
    required this.maxParticipants,
    required this.joinedAt,
    this.leftAt,
    required this.duration,
    required this.isFavorite,
    this.thumbnail,
  });
}

// Simplified version for error fixing
class RoomHistoryScreenSimple extends StatelessWidget {
  const RoomHistoryScreenSimple({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Room History Screen'),
      ),
    );
  }
}