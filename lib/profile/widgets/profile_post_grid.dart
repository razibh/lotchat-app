import 'package:flutter/material.dart';
import '../../../core/models/post_model.dart';
import '../../../widgets/animation/fade_animation.dart';

class ProfilePostGrid extends StatelessWidget {

  const ProfilePostGrid({
    required this.posts, super.key,
    this.onRefresh,
  });
  final List<PostModel> posts;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          final PostModel post = posts[index];
          return FadeAnimation(
            delay: Duration(milliseconds: index * 50),
            child: _buildPostThumbnail(post),
          );
        },
      ),
    );
  }

  Widget _buildPostThumbnail(PostModel post) {
    return GestureDetector(
      onTap: () {
        // Navigate to post detail
      },
      child: Stack(
        fit: StackFit.expand,
        children: <>[
          // Post Media
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              image: post.mediaUrl != null
                  ? DecorationImage(
                      image: NetworkImage(post.mediaUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: post.mediaUrl == null
                ? ColoredBox(
                    color: Colors.primaries[post.content.hashCode % Colors.primaries.length],
                    child: Center(
                      child: Text(
                        post.content.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : null,
          ),

          // Type Indicator
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                post.type == 'video' ? Icons.videocam : Icons.photo,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),

          // Multiple Images Indicator
          if (post.imagesCount != null && post.imagesCount! > 1)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: <>[
                    const Icon(
                      Icons.collections,
                      color: Colors.white,
                      size: 10,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${post.imagesCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Stats Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <>[
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <>[
                  Row(
                    children: <>[
                      const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _formatCount(post.likes),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <>[
                      const Icon(
                        Icons.comment,
                        color: Colors.white,
                        size: 10,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _formatCount(post.comments),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<PostModel>('posts', posts));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onRefresh', onRefresh));
  }
}

// Post Model (for reference)
class PostModel {

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.content, required this.type, required this.likes, required this.comments, required this.shares, required this.timestamp, this.userAvatar,
    this.mediaUrl,
    this.imagesCount,
  });
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String content;
  final String? mediaUrl;
  final String type;
  final int? imagesCount;
  final int likes;
  final int comments;
  final int shares;
  final DateTime timestamp;
}