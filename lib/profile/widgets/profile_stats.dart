import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';

class ProfileStats extends StatelessWidget {
  final ProfileModel profile;
  final bool showLabels;
  final double iconSize;
  final double fontSize;

  const ProfileStats({
    super.key,
    required this.profile,
    this.showLabels = true,
    this.iconSize = 24,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Posts',
            _formatCount(profile.postsCount),
            Icons.post_add,
            Colors.blue,
            onTap: () {
              // Navigate to posts
            },
          ),
          _buildStatItem(
            'Followers',
            _formatCount(profile.followersCount),
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
            _formatCount(profile.followingCount),
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
            _formatCount(profile.friendsCount),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showLabels) ...[
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ProfileModel>('profile', profile));
    properties.add(DiagnosticsProperty<bool>('showLabels', showLabels));
    properties.add(DoubleProperty('iconSize', iconSize));
    properties.add(DoubleProperty('fontSize', fontSize));
  }
}

// Horizontal stats bar
class ProfileStatsHorizontal extends StatelessWidget {
  final ProfileModel profile;

  const ProfileStatsHorizontal({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn('Posts', profile.postsCount),
        _buildStatColumn('Followers', profile.followersCount),
        _buildStatColumn('Following', profile.followingCount),
        _buildStatColumn('Friends', profile.friendsCount),
      ],
    );
  }

  Widget _buildStatColumn(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// Stats with progress
class ProfileStatsWithProgress extends StatelessWidget {
  final ProfileModel profile;

  const ProfileStatsWithProgress({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildProgressStat(
          'Posts',
          profile.postsCount,
          1000,
          Icons.post_add,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildProgressStat(
          'Followers',
          profile.followersCount,
          10000,
          Icons.people,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildProgressStat(
          'Following',
          profile.followingCount,
          1000,
          Icons.person_add,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildProgressStat(
      String label,
      int current,
      int target,
      IconData icon,
      Color color,
      ) {
    final progress = current / target;
    final percentage = (progress * 100).clamp(0, 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '$current / $target',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}

// Compact stats for cards
class ProfileStatsCompact extends StatelessWidget {
  final ProfileModel profile;

  const ProfileStatsCompact({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildChip(Icons.post_add, '${profile.postsCount} posts'),
        _buildChip(Icons.people, '${profile.followersCount} followers'),
        _buildChip(Icons.person_add, '${profile.followingCount} following'),
        _buildChip(Icons.people_outline, '${profile.friendsCount} friends'),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}