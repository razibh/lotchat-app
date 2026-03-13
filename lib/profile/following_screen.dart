import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_friend_tile.dart';
import '../../../core/models/user_model.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/friend_service.dart';
import '../../../widgets/common/empty_state_widget.dart';
import '../../../widgets/common/search_bar.dart';
import '../../profile/profile_screen.dart';

class FollowingScreen extends StatefulWidget {

  const FollowingScreen({Key? key, required this.userId}) : super(key: key);
  final String userId;

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final FriendService _friendService = ServiceLocator().get<FriendService>();
  List<UserModel> _following = <>[];
  List<UserModel> _filteredFollowing = <>[];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    setState(() => _isLoading = true);
    // In real app, load from service
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    _following = List.generate(15, (int index) {
      return UserModel(
        uid: 'user_$index',
        username: 'user${index + 1}',
        email: 'user${index + 1}@example.com',
        phone: '+1234567890',
        country: 'US',
        region: 'New York',
        coins: 1000,
        diamonds: 100,
        tier: UserTier.normal,
        role: UserRole.user,
        lastActive: DateTime.now(),
        isOnline: index % 2 == 0,
      );
    });
    
    _filteredFollowing = _following;
    setState(() => _isLoading = false);
  }

  void _filterFollowing(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredFollowing = _following;
      } else {
        _filteredFollowing = _following.where((Object? f) {
          return f.username.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
        backgroundColor: Colors.green,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              hintText: 'Search following...',
              onChanged: _filterFollowing,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredFollowing.isEmpty
              ? EmptyStateWidget(
                  title: 'Not Following Anyone',
                  message: _searchQuery.isEmpty
                      ? 'This user is not following anyone yet'
                      : 'No results match your search',
                  icon: Icons.person_outline,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredFollowing.length,
                  itemBuilder: (context, index) {
                    final user = _filteredFollowing[index];
                    return ProfileFriendTile(
                      user: user,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(userId: user.uid),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}