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

class FollowersScreen extends StatefulWidget {

  const FollowersScreen({required this.userId, super.key});
  final String userId;

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
  }
}

class _FollowersScreenState extends State<FollowersScreen> {
  final FriendService _friendService = ServiceLocator().get<FriendService>();
  List<UserModel> _followers = <>[];
  List<UserModel> _filteredFollowers = <>[];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowers();
  }

  Future<void> _loadFollowers() async {
    setState(() => _isLoading = true);
    // In real app, load from service
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    _followers = List.generate(20, (int index) {
      return UserModel(
        uid: 'user_$index',
        username: 'user${index + 1}',
        email: 'user${index + 1}@example.com',
        phone: '+1234567890',
        country: 'US',
        region: 'New York',
        coins: 1000,
        diamonds: 100,
        lastActive: DateTime.now(),
        isOnline: index % 3 == 0,
      );
    });
    
    _filteredFollowers = _followers;
    setState(() => _isLoading = false);
  }

  void _filterFollowers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredFollowers = _followers;
      } else {
        _filteredFollowers = _followers.where((UserModel f) {
          return f.username.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
        backgroundColor: Colors.blue,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SearchBar(
              hintText: 'Search followers...',
              onChanged: _filterFollowers,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredFollowers.isEmpty
              ? EmptyStateWidget(
                  title: 'No Followers',
                  message: _searchQuery.isEmpty
                      ? 'This user has no followers yet'
                      : 'No followers match your search',
                  icon: Icons.people_outline,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredFollowers.length,
                  itemBuilder: (BuildContext context, int index) {
                    final UserModel follower = _filteredFollowers[index];
                    return ProfileFriendTile(
                      user: follower,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => ProfileScreen(userId: follower.uid),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}