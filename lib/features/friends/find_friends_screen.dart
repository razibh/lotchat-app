import 'package:flutter/material.dart';
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

class FindFriendsScreen extends StatefulWidget {
  const FindFriendsScreen({super.key});

  @override
  State<FindFriendsScreen> createState() => _FindFriendsScreenState();
}

class _FindFriendsScreenState extends State<FindFriendsScreen> 
    with LoadingMixin, ToastMixin, DialogMixin, PaginationMixin<FriendSuggestionModel> {
  
  final FriendService _friendService = ServiceLocator().get<FriendService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();
  
  List<FriendSuggestionModel> _suggestions = <>[];
  String _selectedTab = 'Suggestions';
  String _searchQuery = '';

  final List<String> _tabs = <String>['Suggestions', 'Search', 'Contacts', 'QR Code'];

  @override
  void initState() {
    super.initState();
    initPagination();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    await runWithLoading(() async {
      _suggestions = await _friendService.getSuggestions();
      setState(() {});
    });
  }

  Future<void> _searchUsers() async {
    if (_searchQuery.trim().isEmpty) return;

    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));
      // Implement search
    });
  }

  Future<void> _sendRequest(String userId) async {
    await runWithLoading(() async {
      final bool success = await _friendService.sendFriendRequest(userId);
      if (success) {
        showSuccess('Friend request sent!');
      } else {
        showError('Could not send request');
      }
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
        actions: <>[
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Friends'),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          onTap: (int index) {
            setState(() {
              _selectedTab = _tabs[index];
            });
          },
          tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
          isScrollable: true,
          indicatorColor: Colors.white,
        ),
      ),
      body: _selectedTab == 'Suggestions'
          ? _buildSuggestionsTab()
          : _selectedTab == 'Search'
              ? _buildSearchTab()
              : _selectedTab == 'Contacts'
                  ? _buildContactsTab()
                  : _buildQRCodeTab(),
    );
  }

  Widget _buildSuggestionsTab() {
    if (_suggestions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <>[
            Icon(Icons.people_outline, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Suggestions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later for friend suggestions',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        final suggestion = _suggestions[index];
        return FadeAnimation(
          delay: Duration(milliseconds: index * 50),
          child: SuggestionTile(
            suggestion: suggestion,
            onAdd: () => _showSendRequestDialog(
              suggestion.userId,
              suggestion.displayNameOrUsername,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: <>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <>[
              Expanded(
                child: TextField(
                  onChanged: (String value) {
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
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _searchUsers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(60, 56),
                ),
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ),
        // Search results would go here
      ],
    );
  }

  Widget _buildContactsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <>[
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
              // Request contacts permission
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(200, 48),
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
        children: <>[
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.qr_code, size: 100),
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
            children: <>[
              ElevatedButton(
                onPressed: () {
                  // Open scanner
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Scan QR'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  // Show my QR
                },
                child: const Text('My QR'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}