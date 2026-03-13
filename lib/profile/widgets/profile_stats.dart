import 'package:flutter/material.dart';
import '../models/profile_model.dart';

class ProfileStats extends StatelessWidget {

  const ProfileStats({Key? key, required this.profile}) : super(key: key);
  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <>[
          _buildStatItem(
            'Posts',
            '${profile.postsCount}',
            Icons.post_add,
            Colors.blue,
            onTap: () {
              // Navigate to posts
            },
          ),
          _buildStatItem(
            'Followers',
            '${profile.followersCount}',
            Icons.people,
            Colors.green,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/followers',
                arguments: profile.userId,
              );
            },
          ),
          _buildStatItem(
            'Following',
            '${profile.followingCount}',
            Icons.person_add,
            Colors.orange,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/following',
                arguments: profile.userId,
              );
            },
          ),
          _buildStatItem(
            'Friends',
            '${profile.friendsCount}',
            Icons.people_outline,
            Colors.purple,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/friends',
                arguments: profile.userId,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <>[
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}