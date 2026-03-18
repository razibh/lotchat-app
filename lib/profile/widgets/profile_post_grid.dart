import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/models/post_model.dart';
import '../../../widgets/animation/fade_animation.dart';

class ProfilePostGrid extends StatelessWidget {
  final List<PostModel> posts;
  final Future<void> Function()? onRefresh;
  final Function(PostModel)? onPostTap;
  final bool showStats;

  const ProfilePostGrid({
    super.key,
    required this.posts,
    this.onRefresh,
    this.onPostTap,
    this.showStats = true,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh ?? _defaultRefresh,
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

  Future<void> _defaultRefresh() async {
    // Default refresh does nothing
    await Future.delayed(Duration.zero);
  }

  Widget _buildPostThumbnail(PostModel post) {
    return GestureDetector(
      onTap: () => onPostTap?.call(post),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Post Media
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              image: post.mediaUrl != null && post.mediaUrl!.isNotEmpty
                  ? DecorationImage(
                image: NetworkImage(post.mediaUrl!),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: post.mediaUrl == null || post.mediaUrl!.isEmpty
                ? Container(
              color: Colors.primaries[post.id.hashCode % Colors.primaries.length],
              child: Center(
                child: Text(
                  post.content.isNotEmpty ? post.content[0].toUpperCase() : '?',
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
          if (post.type != PostType.image)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTypeIcon(post.type),
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
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
          if (showStats)
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
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Posts Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you create posts, they will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(PostType type) {
    switch (type) {
      case PostType.video:
        return Icons.videocam;
      case PostType.gif:
        return Icons.gif;
      case PostType.audio:
        return Icons.audiotrack;
      default:
        return Icons.photo;
    }
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
    properties.add(DiagnosticsProperty<bool>('showStats', showStats));
  }
}

// Post Grid with different layout options
class ProfilePostGridWithTabs extends StatefulWidget {
  final List<PostModel> posts;
  final Future<void> Function()? onRefresh;

  const ProfilePostGridWithTabs({
    super.key,
    required this.posts,
    this.onRefresh,
  });

  @override
  State<ProfilePostGridWithTabs> createState() => _ProfilePostGridWithTabsState();
}

class _ProfilePostGridWithTabsState extends State<ProfilePostGridWithTabs>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<List<PostModel>> _filteredPosts;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filterPosts();
  }

  void _filterPosts() {
    _filteredPosts = [
      widget.posts, // All posts
      widget.posts.where((p) => p.type == PostType.image).toList(), // Images
      widget.posts.where((p) => p.type == PostType.video).toList(), // Videos
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.grid_on), text: 'All'),
              Tab(icon: Icon(Icons.photo), text: 'Photos'),
              Tab(icon: Icon(Icons.videocam), text: 'Videos'),
            ],
            indicator: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ProfilePostGrid(
                posts: _filteredPosts[0],
                onRefresh: widget.onRefresh,
              ),
              ProfilePostGrid(
                posts: _filteredPosts[1],
                onRefresh: widget.onRefresh,
              ),
              ProfilePostGrid(
                posts: _filteredPosts[2],
                onRefresh: widget.onRefresh,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}