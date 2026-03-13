import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';

class MutualFriendsScreen extends StatefulWidget {

  const MutualFriendsScreen({
    Key? key,
    required this.userId,
    required this.userName,
    this.userAvatar,
  }) : super(key: key);
  final String userId;
  final String userName;
  final String? userAvatar;

  @override
  State<MutualFriendsScreen> createState() => _MutualFriendsScreenState();
}

class _MutualFriendsScreenState extends State<MutualFriendsScreen> {
  bool _isLoading = true;
  List<MutualFriend> _mutualFriends = <MutualFriend>[];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMutualFriends();
  }

  Future<void> _loadMutualFriends() async {
    // Simulate loading data
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    // Sample mutual friends data
    setState(() {
      _mutualFriends = <MutualFriend>[
        MutualFriend(
          id: '1',
          name: 'Razib Hossain',
          mutualGames: <String>['Chess', 'Carrom', 'Trivia'],
          lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
          isOnline: true,
        ),
        MutualFriend(
          id: '2',
          name: 'Waresh Khan',
          mutualGames: <String>['Pictionary', 'Truth or Dare'],
          lastActive: DateTime.now().subtract(const Duration(hours: 2)),
          isOnline: false,
        ),
        MutualFriend(
          id: '3',
          name: 'Dr Rokib',
          mutualGames: <String>['Chess', 'Werewolf'],
          lastActive: DateTime.now().subtract(const Duration(hours: 5)),
          isOnline: false,
        ),
        MutualFriend(
          id: '4',
          name: 'Rasel Hossain',
          mutualGames: <String>['Carrom', 'Trivia', 'Pictionary'],
          lastActive: DateTime.now().subtract(const Duration(minutes: 15)),
          isOnline: true,
        ),
        MutualFriend(
          id: '5',
          name: 'Siyam Hossain',
          mutualGames: <String>['Chess', 'Werewolf', 'Truth or Dare'],
          lastActive: DateTime.now().subtract(const Duration(days: 1)),
          isOnline: false,
        ),
        MutualFriend(
          id: '6',
          name: 'Tasnim Tanha',
          mutualGames: <String>['Trivia', 'Pictionary'],
          lastActive: DateTime.now().subtract(const Duration(hours: 3)),
          isOnline: false,
        ),
        MutualFriend(
          id: '7',
          name: 'Dola',
          mutualGames: <String>['Chess', 'Carrom'],
          lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
          isOnline: true,
        ),
        MutualFriend(
          id: '8',
          name: 'Ismail Hossain',
          mutualGames: <String>['Werewolf', 'Truth or Dare', 'Trivia'],
          lastActive: DateTime.now().subtract(const Duration(hours: 1)),
          isOnline: false,
        ),
      ];
      _isLoading = false;
    });
  }

  List<MutualFriend> get _filteredFriends {
    if (_searchQuery.isEmpty) return _mutualFriends;
    return _mutualFriends.where((MutualFriend friend) =>
      friend.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <>[
              _buildHeader(),
              _buildSearchBar(),
              _buildStats(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _buildFriendsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <>[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  'Mutual Friends',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'with ${widget.userName}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.accentPurple.withOpacity(0.3),
            backgroundImage: widget.userAvatar != null
                ? NetworkImage(widget.userAvatar!)
                : null,
            child: widget.userAvatar == null
                ? Text(
                    widget.userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
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
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search mutual friends...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          border: InputBorder.none,
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
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

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <>[
            AppColors.accentPurple.withOpacity(0.3),
            AppColors.accentBlue.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <>[
          _buildStatItem(
            'Total',
            '${_mutualFriends.length}',
            Icons.people,
          ),
          _buildStatItem(
            'Online',
            '${_mutualFriends.where((MutualFriend f) => f.isOnline).length}',
            Icons.circle,
            Colors.green,
          ),
          _buildStatItem(
            'Games',
            _getUniqueGamesCount().toString(),
            Icons.sports_esports,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Column(
      children: <>[
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? Colors.white).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color ?? Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  int _getUniqueGamesCount() {
    final Set<String> games = <String>{};
    for (MutualFriend friend in _mutualFriends) {
      games.addAll(friend.mutualGames);
    }
    return games.length;
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <>[
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentPurple),
          ),
          const SizedBox(height: 16),
          Text(
            'Finding mutual friends...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList() {
    final List<MutualFriend> filteredFriends = _filteredFriends;

    if (filteredFriends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No mutual friends found'
                  : 'No matches for "$_searchQuery"',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: filteredFriends.length,
      itemBuilder: (context, index) {
        final MutualFriend friend = filteredFriends[index];
        return _buildFriendTile(friend);
      },
    );
  }

  Widget _buildFriendTile(MutualFriend friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: friend.isOnline ? Colors.green.withOpacity(0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: <>[
          Stack(
            children: <>[
              CircleAvatar(
                radius: 28,
                backgroundColor: _getAvatarColor(friend.id).withOpacity(0.3),
                backgroundImage: friend.avatar != null
                    ? NetworkImage(friend.avatar!)
                    : null,
                child: friend.avatar == null
                    ? Text(
                        friend.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (friend.isOnline)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.backgroundDark,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Row(
                  children: <>[
                    Expanded(
                      child: Text(
                        friend.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _getLastActiveText(friend.lastActive),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${friend.mutualGames.length} mutual games',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                _buildGameChips(friend.mutualGames),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildActionButtons(friend),
        ],
      ),
    );
  }

  Widget _buildGameChips(List<String> games) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: games.take(3).map((String game) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getGameColor(game).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getGameColor(game).withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            game,
            style: TextStyle(
              color: _getGameColor(game),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(MutualFriend friend) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <>[
        Container(
          decoration: BoxDecoration(
            color: AppColors.accentPurple.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.message, color: Colors.white, size: 20),
            onPressed: () {
              // Navigate to chat
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Chat with ${friend.name}')),
              );
            },
          ),
        ),
        const SizedBox(width: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white, size: 20),
            onPressed: () {
              // Add friend
              setState(() {
                friend.isFriend = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Friend request sent to ${friend.name}')),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getAvatarColor(String id) {
    final colors = <>[
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];
    final int index = id.hashCode % colors.length;
    return colors[index];
  }

  Color _getGameColor(String game) {
    switch (game) {
      case 'Chess':
        return Colors.brown;
      case 'Carrom':
        return Colors.amber;
      case 'Pictionary':
        return Colors.purple;
      case 'Trivia':
        return Colors.blue;
      case 'Truth or Dare':
        return Colors.pink;
      case 'Werewolf':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getLastActiveText(DateTime lastActive) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(lastActive);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${difference.inDays ~/ 7}w ago';
    }
  }
}

class MutualFriend {

  MutualFriend({
    required this.id,
    required this.name,
    this.avatar,
    required this.mutualGames,
    required this.lastActive,
    required this.isOnline,
    this.isFriend = false,
  });
  final String id;
  final String name;
  final String? avatar;
  final List<String> mutualGames;
  final DateTime lastActive;
  final bool isOnline;
  bool isFriend;
}

// Extension screen for mutual friends in a specific game
class GameMutualFriendsScreen extends StatelessWidget {

  const GameMutualFriendsScreen({
    Key? key,
    required this.gameName,
    required this.userId,
    required this.userName,
  }) : super(key: key);
  final String gameName;
  final String userId;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: <>[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <>[
                        Text(
                          '$gameName Friends',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'with $userName',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Filtered mutual friends for $gameName\nWill be implemented here',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}