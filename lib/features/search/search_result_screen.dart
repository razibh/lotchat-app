import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;  // ✅ Supabase User hide

import '../../core/di/service_locator.dart';
import '../../core/services/search_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/analytics_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/custom_button.dart';
import '../../core/models/user_models.dart';
import '../../core/models/room_model.dart';
import '../profile/profile_screen.dart';

class SearchResultScreen extends StatefulWidget {
  final String query;
  final SearchType initialType;

  const SearchResultScreen({
    super.key,
    required this.query,
    this.initialType = SearchType.all,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('query', query));
    properties.add(EnumProperty<SearchType>('initialType', initialType));
  }
}

enum SearchType { all, users, rooms, games, gifts }

class _SearchResultScreenState extends State<SearchResultScreen>
    with LoadingMixin, ToastMixin, TickerProviderStateMixin {

  final SearchService _searchService = ServiceLocator.instance.get<SearchService>();
  final AuthService _authService = ServiceLocator.instance.get<AuthService>();
  final AnalyticsService _analyticsService = ServiceLocator.instance.get<AnalyticsService>();

  late TabController _tabController;

  List<Map<String, dynamic>> _users = []; // User → Map
  List<Map<String, dynamic>> _rooms = []; // RoomModel → Map
  List<Map<String, dynamic>> _games = [];
  List<Map<String, dynamic>> _gifts = [];

  String? _currentUserId;

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _currentPage = 1;
  bool _hasMore = true;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: SearchType.values.length,
      vsync: this,
      initialIndex: widget.initialType.index,
    );
    _tabController.addListener(_onTabChanged);
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _getCurrentUser();
      await _performSearch(refresh: true);

      _analyticsService.trackScreen(
        'SearchResult',
        screenClass: 'SearchResultScreen',
        parameters: {
          'query': widget.query,
          'type': _getCurrentType().toString(),
        },
      );

    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      _analyticsService.trackError(
        errorMessage: e.toString(),
        screen: 'SearchResultScreen',
        stackTrace: stackTrace,
      );
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _analyticsService.trackEvent(
        'search_tab_changed',
        parameters: {
          'query': widget.query,
          'type': _getCurrentType().toString(),
        },
      );
      _performSearch(refresh: true);
    }
  }

  SearchType _getCurrentType() {
    return SearchType.values[_tabController.index];
  }

  Future<void> _getCurrentUser() async {
    // ✅ Firebase Auth → Supabase Auth
    final session = Supabase.instance.client.auth.currentSession;
    _currentUserId = session?.user.id;
  }

  Future<void> _performSearch({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _clearResults();
    }

    if (!_hasMore || _isLoadingMore) return;

    setState(() {
      if (refresh) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final type = _getCurrentType();

      switch (type) {
        case SearchType.all:
          await _searchAll();
          break;
        case SearchType.users:
          await _searchUsers();
          break;
        case SearchType.rooms:
          await _searchRooms();
          break;
        case SearchType.games:
          await _searchGames();
          break;
        case SearchType.gifts:
          await _searchGifts();
          break;
      }

      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      showError('Search failed: $e');
    }
  }

  Future<void> _searchAll() async {
    final results = await _searchService.searchAll(
      widget.query,
      limit: _limit,
    );

    setState(() {
      if (_currentPage == 1) {
        _users = results['users'] ?? [];
        _rooms = results['rooms'] ?? [];
        _gifts = results['gifts'] ?? [];
        _games = []; // No games in searchAll
      } else {
        _users.addAll(results['users'] ?? []);
        _rooms.addAll(results['rooms'] ?? []);
        _gifts.addAll(results['gifts'] ?? []);
      }

      _hasMore = _hasMoreResults(results);
      if (_hasMore) _currentPage++;
    });
  }

  Future<void> _searchUsers() async {
    final users = await _searchService.searchUsers(
      widget.query,
      limit: _limit,
    );

    setState(() {
      if (_currentPage == 1) {
        _users = users;
      } else {
        _users.addAll(users);
      }
      _hasMore = users.length == _limit;
      if (_hasMore) _currentPage++;
    });
  }

  Future<void> _searchRooms() async {
    final rooms = await _searchService.searchRooms(
      widget.query,
      limit: _limit,
    );

    setState(() {
      if (_currentPage == 1) {
        _rooms = rooms;
      } else {
        _rooms.addAll(rooms);
      }
      _hasMore = rooms.length == _limit;
      if (_hasMore) _currentPage++;
    });
  }

  Future<void> _searchGames() async {
    // If searchGames doesn't exist, use empty list
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _games = [];
      _hasMore = false;
    });
  }

  Future<void> _searchGifts() async {
    final gifts = await _searchService.searchGifts(
      widget.query,
      limit: _limit,
    );

    setState(() {
      if (_currentPage == 1) {
        _gifts = gifts;
      } else {
        _gifts.addAll(gifts);
      }
      _hasMore = gifts.length == _limit;
      if (_hasMore) _currentPage++;
    });
  }

  bool _hasMoreResults(Map<String, dynamic> results) {
    return (results['users']?.length == _limit ||
        results['rooms']?.length == _limit ||
        results['gifts']?.length == _limit);
  }

  void _clearResults() {
    _users = [];
    _rooms = [];
    _games = [];
    _gifts = [];
  }

  void _onUserTap(Map<String, dynamic> user) {
    _analyticsService.trackEvent(
      'view_profile_from_search',
      parameters: {
        'user_id': _currentUserId,
        'viewed_user_id': user['id'],
      },
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(userId: user['id']),
      ),
    );
  }

  void _onRoomTap(Map<String, dynamic> room) {
    _analyticsService.trackEvent(
      'view_room_from_search',
      parameters: {
        'user_id': _currentUserId,
        'room_id': room['id'],
      },
    );

    // Navigate to room
    // Navigator.pushNamed(
    //   context,
    //   '/room',
    //   arguments: room,
    // );
  }

  void _onGameTap(Map<String, dynamic> game) {
    _analyticsService.trackEvent(
      'view_game_from_search',
      parameters: {
        'user_id': _currentUserId,
        'game_id': game['id'],
      },
    );

    // Navigate to game
  }

  void _onGiftTap(Map<String, dynamic> gift) {
    // Show gift details or send gift
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Results',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            '"${widget.query}"',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.purple,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Users'),
          Tab(text: 'Rooms'),
          Tab(text: 'Games'),
          Tab(text: 'Gifts'),
        ],
        indicatorColor: Colors.white,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initialize,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildAllTab(),
        _buildUsersTab(),
        _buildRoomsTab(),
        _buildGamesTab(),
        _buildGiftsTab(),
      ],
    );
  }

  Widget _buildAllTab() {
    if (_users.isEmpty && _rooms.isEmpty && _games.isEmpty && _gifts.isEmpty) {
      return EmptyStateWidget(
        title: 'No Results Found',
        message: 'Try searching with different keywords',
        icon: Icons.search_off,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _performSearch(refresh: true),
      color: Colors.purple,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_users.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Users',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._users.take(3).map((user) => _buildUserTile(user)),
            if (_users.length > 3)
              TextButton(
                onPressed: () {
                  _tabController.animateTo(1); // Go to Users tab
                },
                child: const Text('See all users →'),
              ),
          ],

          if (_rooms.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Rooms',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._rooms.take(3).map((room) => _buildRoomTile(room)),
            if (_rooms.length > 3)
              TextButton(
                onPressed: () {
                  _tabController.animateTo(2); // Go to Rooms tab
                },
                child: const Text('See all rooms →'),
              ),
          ],

          if (_games.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Games',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._games.take(3).map((game) => _buildGameTile(game)),
            if (_games.length > 3)
              TextButton(
                onPressed: () {
                  _tabController.animateTo(3); // Go to Games tab
                },
                child: const Text('See all games →'),
              ),
          ],

          if (_gifts.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Gifts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ..._gifts.take(3).map((gift) => _buildGiftTile(gift)),
            if (_gifts.length > 3)
              TextButton(
                onPressed: () {
                  _tabController.animateTo(4); // Go to Gifts tab
                },
                child: const Text('See all gifts →'),
              ),
          ],

          if (_hasMore) _buildLoadMoreButton(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    if (_users.isEmpty) {
      return EmptyStateWidget(
        title: 'No Users Found',
        message: 'No users match your search',
        icon: Icons.person_off,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _performSearch(refresh: true),
      color: Colors.purple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _users.length) {
            return _buildLoadMoreIndicator();
          }

          final user = _users[index];
          return FadeAnimation(
            delay: Duration(milliseconds: index * 50),
            child: _buildUserTile(user),
          );
        },
      ),
    );
  }

  Widget _buildRoomsTab() {
    if (_rooms.isEmpty) {
      return EmptyStateWidget(
        title: 'No Rooms Found',
        message: 'No rooms match your search',
        icon: Icons.meeting_room,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _performSearch(refresh: true),
      color: Colors.purple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _rooms.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _rooms.length) {
            return _buildLoadMoreIndicator();
          }

          final room = _rooms[index];
          return FadeAnimation(
            delay: Duration(milliseconds: index * 50),
            child: _buildRoomTile(room),
          );
        },
      ),
    );
  }

  Widget _buildGamesTab() {
    if (_games.isEmpty) {
      return EmptyStateWidget(
        title: 'No Games Found',
        message: 'No games match your search',
        icon: Icons.sports_esports,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _performSearch(refresh: true),
      color: Colors.purple,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _games.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _games.length) {
            return _buildLoadMoreGridIndicator();
          }

          final game = _games[index];
          return FadeAnimation(
            delay: Duration(milliseconds: index * 50),
            child: _buildGameTile(game),
          );
        },
      ),
    );
  }

  Widget _buildGiftsTab() {
    if (_gifts.isEmpty) {
      return EmptyStateWidget(
        title: 'No Gifts Found',
        message: 'No gifts match your search',
        icon: Icons.card_giftcard,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _performSearch(refresh: true),
      color: Colors.purple,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.9,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _gifts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _gifts.length) {
            return _buildLoadMoreGridIndicator();
          }

          final gift = _gifts[index];
          return FadeAnimation(
            delay: Duration(milliseconds: index * 50),
            child: _buildGiftTile(gift),
          );
        },
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildLoadMoreGridIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomButton(
          text: 'Load More',
          onPressed: _performSearch,
          color: Colors.purple,
          height: 40,
          isFullWidth: false,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    final userData = user['data'] ?? {};
    final userName = userData['name'] ?? userData['username'] ?? 'Unknown';
    final userUsername = userData['username'] ?? '';
    final userAvatar = userData['avatar'] ?? userData['photoURL'];
    final isVerified = userData['isVerified'] ?? false;
    final isOnline = userData['isOnline'] ?? false;

    return GestureDetector(
      onTap: () => _onUserTap(user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // User Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: userAvatar != null
                      ? NetworkImage(userAvatar)
                      : null,
                  child: userAvatar == null
                      ? Text(
                    userName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userUsername.isNotEmpty ? '@$userUsername' : '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isVerified)
              const Icon(
                Icons.verified,
                color: Colors.blue,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTile(Map<String, dynamic> room) {
    final roomData = room['data'] ?? {};
    final roomName = roomData['name'] ?? 'Unknown Room';
    final roomDescription = roomData['description'] ?? '';
    final isPrivate = roomData['isPrivate'] ?? false;
    final participantCount = roomData['participantCount'] ?? roomData['currentViewers'] ?? 0;
    final maxParticipants = roomData['maxParticipants'] ?? roomData['maxViewers'] ?? 0;
    final isActive = roomData['status'] == 'active' || roomData['isActive'] == true;

    return GestureDetector(
      onTap: () => _onRoomTap(room),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPrivate ? Colors.purple.shade100 : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isPrivate ? Icons.lock : Icons.meeting_room,
                color: isPrivate ? Colors.purple : Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    roomName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (roomDescription.isNotEmpty) ...[
                    Text(
                      roomDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.people, size: 14, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text(
                        '$participantCount/$maxParticipants',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        isActive ? 'Live' : 'Offline',
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTile(Map<String, dynamic> game) {
    final gameData = game['data'] ?? game;
    final gameName = gameData['name'] ?? 'Unknown Game';
    final gameCategory = gameData['category'] ?? 'Game';

    return GestureDetector(
      onTap: () => _onGameTap(game),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade300,
                    Colors.purple.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getGameIcon(gameCategory),
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              gameName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              gameCategory,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftTile(Map<String, dynamic> gift) {
    final giftData = gift['data'] ?? gift;
    final giftName = giftData['name'] ?? 'Gift';
    final giftPrice = giftData['price'] ?? 0;

    return GestureDetector(
      onTap: () => _onGiftTap(gift),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              color: Colors.pink.shade400,
              size: 30,
            ),
            const SizedBox(height: 4),
            Text(
              giftName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '$giftPrice coins',
              style: TextStyle(
                fontSize: 10,
                color: Colors.amber.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGameIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'board':
        return Icons.extension;
      case 'card':
        return Icons.style;
      case 'action':
        return Icons.sports_esports;
      case 'quiz':
        return Icons.quiz;
      case 'party':
        return Icons.celebration;
      default:
        return Icons.games;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }
}