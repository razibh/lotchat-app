import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/recommendation_service.dart';
import '../../mixins/pagination_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/animation/fade_animation.dart';
import '../profile/profile_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with PaginationMixin<Map<String, dynamic>>, ToastMixin {

  final RecommendationService _recommendationService = ServiceLocator.instance.get<RecommendationService>();
  String _selectedTab = 'For You';
  final List<String> _tabs = ['For You', 'Popular', 'Nearby', 'New'];

  @override
  void initState() {
    super.initState();
    initPagination(); // PaginationMixin এর initPagination কল
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadFirstPage(setState); // setState প্যারামিটার সহ
    });
  }

  @override
  void dispose() {
    disposePagination(); // PaginationMixin এর disposePagination কল
    super.dispose();
  }

  @override
  Future<PaginationResult<Map<String, dynamic>>> fetchPage(int page) async {
    // Simulate API call with different data based on selected tab
    await Future.delayed(const Duration(seconds: 1));

    final items = List.generate(10, (index) {
      final int actualIndex = page * 10 + index;
      final bool isImage = actualIndex % 3 != 0;

      // Different content based on tab
      String content = '';
      if (_selectedTab == 'Popular') {
        content = '🔥 Popular post #${actualIndex + 1} with many likes!';
      } else if (_selectedTab == 'Nearby') {
        content = '📍 Nearby post #${actualIndex + 1} from your area';
      } else if (_selectedTab == 'New') {
        content = '🆕 New post #${actualIndex + 1} just now';
      } else {
        content = '✨ Recommended for you #${actualIndex + 1}';
      }

      return {
        'id': 'post_$actualIndex',
        'userId': 'user_$actualIndex',
        'username': 'User ${actualIndex + 1}',
        'userAvatar': actualIndex % 4 == 0 ? 'https://i.pravatar.cc/150?u=$actualIndex' : null,
        'content': content,
        'mediaUrl': isImage ? 'https://picsum.photos/400/300?random=$actualIndex' : null,
        'mediaType': isImage ? 'image' : null,
        'likes': 100 + (actualIndex * 50),
        'comments': 20 + actualIndex,
        'gifts': 5 + actualIndex,
        'timestamp': DateTime.now().subtract(Duration(hours: actualIndex)),
        'isLiked': false,
        'isSaved': false,
      };
    });

    return PaginationResult<Map<String, dynamic>>(
      items: items,
      totalPages: 10,
      totalItems: 100,
      currentPage: page,
    );
  }

  void _likePost(int index) {
    setState(() {
      final post = items[index];
      if (post['isLiked'] == true) {
        post['likes'] = (post['likes'] as int) - 1;
      } else {
        post['likes'] = (post['likes'] as int) + 1;
      }
      post['isLiked'] = !(post['isLiked'] ?? false);
    });
  }

  void _showComments(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Comments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person, size: 20),
                    ),
                    title: Text('User ${index + 1}'),
                    subtitle: Text('Great post! ${index + 1}'),
                    trailing: Text(
                      '${index + 1}h',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _sendGift(Map<String, dynamic> post) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Send Gift'),
        content: SizedBox(
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  showSuccess('Gift sent!');
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.card_giftcard, color: Colors.purple),
                      const SizedBox(height: 4),
                      Text('${100 * (index + 1)}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          bottom: TabBar(
            onTap: (int index) {
              setState(() {
                _selectedTab = _tabs[index];
                loadFirstPage(setState); // setState প্যারামিটার সহ
              });
            },
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        body: isLoading && items.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty && !isLoading
            ? EmptyStateWidget(
          title: 'No Posts Yet',
          message: 'Be the first to share something!',
          icon: Icons.post_add,
          buttonText: 'Create Post',
          onButtonPressed: _createPost,
        )
            : RefreshIndicator(
          onRefresh: () async {
            return loadFirstPage(setState);
          },
          child: ListView.builder(
            controller: scrollController,
            itemCount: items.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == items.length) {
                return _buildLoadingIndicator();
              }
              return FadeAnimation(
                delay: Duration(milliseconds: index * 100),
                child: _buildPostCard(items[index]),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _createPost,
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: post['userId']),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundImage: post['userAvatar'] != null
                    ? NetworkImage(post['userAvatar'] as String)
                    : null,
                backgroundColor: Colors.grey.shade200,
                child: post['userAvatar'] == null
                    ? Text((post['username'] as String)[0].toUpperCase())
                    : null,
              ),
            ),
            title: Text(
              post['username'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_formatTime(post['timestamp'] as DateTime)),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(post['content'] as String),
          ),
          const SizedBox(height: 8),

          // Media
          if (post['mediaUrl'] != null)
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                image: DecorationImage(
                  image: NetworkImage(post['mediaUrl'] as String),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 8),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('${post['likes']} likes'),
                const SizedBox(width: 16),
                Text('${post['comments']} comments'),
                const SizedBox(width: 16),
                Text('${post['gifts']} gifts'),
              ],
            ),
          ),
          const Divider(),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: post['isLiked'] == true ? Icons.favorite : Icons.favorite_border,
                label: 'Like',
                color: post['isLiked'] == true ? Colors.red : Colors.grey,
                onTap: () => _likePost(items.indexOf(post)),
              ),
              _buildActionButton(
                icon: Icons.comment,
                label: 'Comment',
                color: Colors.grey,
                onTap: () => _showComments(post),
              ),
              _buildActionButton(
                icon: Icons.card_giftcard,
                label: 'Gift',
                color: Colors.purple,
                onTap: () => _sendGift(post),
              ),
              _buildActionButton(
                icon: post['isSaved'] == true ? Icons.bookmark : Icons.bookmark_border,
                label: 'Save',
                color: post['isSaved'] == true ? Colors.blue : Colors.grey,
                onTap: () {
                  setState(() {
                    post['isSaved'] = !(post['isSaved'] ?? false);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _createPost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create Post',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "What's on your mind?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo, color: Colors.green),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.videocam, color: Colors.red),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.emoji_emotions, color: Colors.orange),
                  onPressed: () {},
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showSuccess('Post created!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text('Post'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}