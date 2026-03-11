import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/user_model.dart';
import '../../widgets/badge_widget.dart';
import '../../widgets/frame_widget.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;
  
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  UserModel? user;
  final ImagePicker _picker = ImagePicker();
  
  @override
  void initState() {
    super.initState();
    _loadUser();
  }
  
  Future<void> _loadUser() async {
    // Load user from service
    setState(() {
      user = UserModel(
        uid: widget.userId,
        username: 'JohnDoe',
        email: 'john@example.com',
        phone: '+1234567890',
        photoURL: null,
        bio: 'Live life to the fullest!',
        interests: ['Music', 'Travel', 'Gaming'],
        country: 'USA',
        region: 'New York',
        coins: 15000,
        diamonds: 500,
        tier: UserTier.vip5,
        lastActive: DateTime.now(),
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Image
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.purple, Colors.pink],
                      ),
                    ),
                  ),
                  
                  // Profile Info Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                      child: Row(
                        children: [
                          // Profile Picture with Frame
                          Stack(
                            children: [
                              FrameWidget(
                                tier: user!.tier,
                                size: 80,
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundImage: user!.photoURL != null
                                      ? NetworkImage(user!.photoURL!)
                                      : null,
                                  child: user!.photoURL == null
                                      ? Text(
                                          user!.username[0].toUpperCase(),
                                          style: TextStyle(fontSize: 30),
                                        )
                                      : null,
                                ),
                              ),
                              if (isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _changeProfilePicture,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.purple,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user!.username,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    BadgeWidget(tier: user!.tier),
                                    SizedBox(width: 8),
                                    Text(
                                      'ID: ${user!.uid.substring(0, 8)}',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!isEditing)
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  isEditing = true;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  _buildStatsRow(),
                  SizedBox(height: 24),
                  
                  // Bio Section
                  _buildBioSection(),
                  SizedBox(height: 24),
                  
                  // Interests Section
                  _buildInterestsSection(),
                  SizedBox(height: 24),
                  
                  // Badges Collection
                  _buildBadgesCollection(),
                  SizedBox(height: 24),
                  
                  // Friend Requests
                  _buildFriendRequests(),
                  SizedBox(height: 24),
                  
                  // Recent Activity
                  _buildRecentActivity(),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Buttons
      bottomNavigationBar: _buildBottomBar(),
    );
  }
  
  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem('Coins', '${user!.coins}', Icons.monetization_on),
        _buildStatItem('Diamonds', '${user!.diamonds}', Icons.diamond),
        _buildStatItem('Followers', '12.5K', Icons.people),
        _buildStatItem('Following', '850', Icons.person_add),
      ],
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.purple),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
  
  Widget _buildBioSection() {
    if (isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: user!.bio),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write something about yourself...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              user!.bio = value;
            },
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text(
          user!.bio ?? 'No bio yet',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
  
  Widget _buildInterestsSection() {
    if (isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Interests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Music', 'Travel', 'Gaming', 'Sports', 'Art', 'Food'].map((interest) {
              final isSelected = user!.interests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      user!.interests.add(interest);
                    } else {
                      user!.interests.remove(interest);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Interests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: user!.interests.map((interest) {
            return Chip(
              label: Text(interest),
              backgroundColor: Colors.purple.withOpacity(0.1),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildBadgesCollection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (context, index) {
              return Container(
                width: 80,
                margin: EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.purple,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('Badge ${index + 1}'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildFriendRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Friend Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: Text('See All'),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      child: Text('U${index + 1}'),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('User ${index + 1}'),
                          Text('@user${index + 1}'),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red),
                      onPressed: () {},
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.card_giftcard),
              ),
              title: Text('Received a gift'),
              subtitle: Text('2 hours ago'),
              trailing: Text('+100'),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildBottomBar() {
    if (isEditing) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEditing = false;
                    // Save changes
                  });
                },
                child: Text('Save Changes'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    isEditing = false;
                    // Reload original data
                  });
                },
                child: Text('Cancel'),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Send friend request
              },
              child: Text('Add Friend'),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Send message
                Navigator.pushNamed(context, '/chat', arguments: user);
              },
              child: Text('Message'),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _changeProfilePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Upload image and update user
      setState(() {
        // Update profile picture
      });
    }
  }
}