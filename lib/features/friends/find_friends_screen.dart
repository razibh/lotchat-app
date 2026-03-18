import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/friend_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../mixins/pagination_mixin.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/animation/fade_animation.dart';
import 'widgets/suggestion_tile.dart';
import '../../features/friends/models/friend_model.dart';

class FindFriendsScreen extends StatefulWidget {
  const FindFriendsScreen({super.key});

  @override
  State<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends State<FindFriendsScreen>
    with LoadingMixin, ToastMixin, DialogMixin, PaginationMixin<FriendSuggestionModel> {

  final FriendService _friendService = ServiceLocator.instance.get<FriendService>();
  final AuthService _authService = ServiceLocator.instance.get<AuthService>();

  List<FriendSuggestionModel> _suggestions = [];
  String _selectedTab = 'Suggestions';
  String _searchQuery = '';
  bool _isLoadingSuggestions = false; // আলাদা loading variable

  final List<String> _tabs = ['Suggestions', 'Search', 'Contacts', 'QR Code'];

  @override
  void initState() {
    super.initState();
    initPagination();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadFirstPage(setState); // setState প্যারামিটার সহ
    });
    _loadSuggestions();
  }

  @override
  void dispose() {
    disposePagination();
    super.dispose();
  }

  @override
  Future<PaginationResult<FriendSuggestionModel>> fetchPage(int page) async {
    await Future.delayed(const Duration(seconds: 1));

    final suggestions = List.generate(10, (index) {
      return FriendSuggestionModel(
        userId: 'user_${page * 10 + index}',
        username: 'user${page * 10 + index}',
        displayName: 'User ${page * 10 + index}',
        avatar: null,
        mutualFriends: index * 2,
        reason: 'Based on your interests',
        score: (100 - index).toDouble(),
        commonInterests: ['music', 'games'],
      );
    });

    return PaginationResult<FriendSuggestionModel>(
      items: suggestions,
      totalPages: 5,
      totalItems: 50,
      currentPage: page,
    );
  }

  Future<void> _loadSuggestions() async {
    setState(() => _isLoadingSuggestions = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      _suggestions = List.generate(10, (index) {
        return FriendSuggestionModel(
          userId: 'suggest_$index',
          username: 'friend$index',
          displayName: 'Friend $index',
          avatar: null,
          mutualFriends: index * 3,
          reason: index % 2 == 0 ? 'Mutual friends' : 'Similar interests',
          score: (100 - index * 5).toDouble(),
          commonInterests: ['music', 'gaming', 'chat'],
        );
      });

      setState(() {
        _isLoadingSuggestions = false;
      });
    } catch (e) {
      setState(() => _isLoadingSuggestions = false);
      showError('Failed to load suggestions: $e');
    }
  }

  Future<void> _searchUsers() async {
    if (_searchQuery.trim().isEmpty) return;

    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));
      showInfo('Search feature coming soon');
    });
  }

  Future<void> _sendRequest(String userId) async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      showSuccess('Friend request sent!');
    });
  }

  void _showSendRequestDialog(String userId, String username) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Add $username'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            hintText: 'Add a message (optional)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _sendRequest(userId);
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Find Friends'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: TabBar(
            onTap: (int index) {
              setState(() {
                _selectedTab = _tabs[index];
              });
            },
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            isScrollable: true,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: _selectedTab == 'Suggestions'
            ? _buildSuggestionsTab()
            : _selectedTab == 'Search'
            ? _buildSearchTab()
            : _selectedTab == 'Contacts'
            ? _buildContactsTab()
            : _buildQRCodeTab(),
      ),
    );
  }

  Widget _buildSuggestionsTab() {
    if (_isLoadingSuggestions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Suggestions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for friend suggestions',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadSuggestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return FadeAnimation(
          delay: Duration(milliseconds: index * 50),
          child: SuggestionTile(
            suggestion: {
              'userId': suggestion.userId,
              'name': suggestion.displayName ?? suggestion.username,
              'username': suggestion.username,
              'avatar': suggestion.avatar,
              'mutualFriends': suggestion.mutualFriends,
              'commonInterests': suggestion.commonInterests,
              'reason': suggestion.reason,
            },
            onAdd: () => _showSendRequestDialog(
              suggestion.userId,
              suggestion.displayName ?? suggestion.username,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onSubmitted: (_) => _searchUsers(),
                  decoration: InputDecoration(
                    hintText: 'Search by username or ID',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _searchUsers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Search for users',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.contact_phone, size: 80, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Connect Contacts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find friends from your phone contacts',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              showInfo('Contacts sync coming soon');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sync Contacts'),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.qr_code, size: 100, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scan QR Code',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Scan a friend's QR code to add them",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  showInfo('QR scanner coming soon');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Scan QR'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  showInfo('Your QR code coming soon');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
                child: const Text('My QR'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}