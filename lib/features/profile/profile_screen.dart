import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/models/user_model.dart';
import '../../widgets/badge_widget.dart';
import '../../widgets/frame_widget.dart';

class ProfileScreen extends StatefulWidget {
  
  const ProfileScreen({required this.userId, super.key});
  final String userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
  }
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
        bio: 'Live life to the fullest!',
        interests: <String>['Music', 'Travel', 'Gaming'],
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      body: CustomScrollView(
        slivers: <>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <>[
                  // Cover Image
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <>[Colors.purple, Colors.pink],
                      ),
                    ),
                  ),
                  
                  // Profile Info Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <>[Colors.transparent, Colors.black54],
                        ),
                      ),
                      child: Row(
                        children: <>[
                          // Profile Picture with Frame
                          Stack(
                            children: <>[
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
                                          style: const TextStyle(fontSize: 30),
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
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.purple,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 16,
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
                                Text(
                                  user!.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: <>[
                                    BadgeWidget(tier: user!.tier),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ID: ${user!.uid.substring(0, 8)}',
                                      style: const TextStyle(
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
                              icon: const Icon(Icons.edit, color: Colors.white),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <>[
                  // Stats Row
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  
                  // Bio Section
                  _buildBioSection(),
                  const SizedBox(height: 24),
                  
                  // Interests Section
                  _buildInterestsSection(),
                  const SizedBox(height: 24),
                  
                  // Badges Collection
                  _buildBadgesCollection(),
                  const SizedBox(height: 24),
                  
                  // Friend Requests
                  _buildFriendRequests(),
                  const SizedBox(height: 24),
                  
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
      children: <>[
        _buildStatItem('Coins', '${user!.coins}', Icons.monetization_on),
        _buildStatItem('Diamonds', '${user!.diamonds}', Icons.diamond),
        _buildStatItem('Followers', '12.5K', Icons.people),
        _buildStatItem('Following', '850', Icons.person_add),
      ],
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: <>[
        Icon(icon, color: Colors.purple),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
  
  Widget _buildBioSection() {
    if (isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          const Text('Bio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: user!.bio),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write something about yourself...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (String value) {
              user!.bio = value;
            },
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        const Text('Bio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          user!.bio ?? 'No bio yet',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
  
  Widget _buildInterestsSection() {
    if (isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          const Text('Interests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: <String>['Music', 'Travel', 'Gaming', 'Sports', 'Art', 'Food'].map((String interest) {
              final bool isSelected = user!.interests.contains(interest);
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (bool selected) {
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
      children: <>[
        const Text('Interests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: user!.interests.map((String interest) {
            return Chip(
              label: Text(interest),
              backgroundColor: Colors.purple.withValues(alpha: 0.1),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildBadgesCollection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <>[
        const Text('Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 8,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: <>[
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(height: 4),
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
      children: <>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <>[
            const Text(
              'Friend Requests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                child: Row(
                  children: <>[
                    CircleAvatar(
                      radius: 25,
                      child: Text('U${index + 1}'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <>[
                          Text('User ${index + 1}'),
                          Text('@user${index + 1}'),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
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
      children: <>[
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (BuildContext context, int index) {
            return const ListTile(
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <>[
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isEditing = false;
                    // Save changes
                  });
                },
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    isEditing = false;
                    // Reload original data
                  });
                },
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <>[
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Send friend request
              },
              child: const Text('Add Friend'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // Send message
                Navigator.pushNamed(context, '/chat', arguments: user);
              },
              child: const Text('Message'),
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('isEditing', isEditing));
    properties.add(DiagnosticsProperty<UserModel?>('user', user));
  }
}