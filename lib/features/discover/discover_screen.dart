import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/recommendation_service.dart';
import '../../mixins/pagination_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/animation/fade_animation.dart';
import '../profile/profile_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> 
    with PaginationMixin<Map<String, dynamic>>, ToastMixin {
  
  final _recommendationService = ServiceLocator().get<RecommendationService>();
  String _selectedTab = 'For You';
  final List<String> _tabs = ['For You', 'Popular', 'Nearby', 'New'];

  @override
  void initState() {
    super.initState();
    initPagination();
    loadMore();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPage(int page) async {
    // Fetch posts from service
    await Future.delayed(const Duration(seconds: 1));
    
    return List.generate(10, (index) {
      final isImage = index % 3 != 0;
      return {
        'id': 'post_$index',
        'userId': 'user_$index',
        'username': 'User ${index + 1}',
        'userAvatar': null,
        'content': 'This is post number ${index + 1}. Check out this amazing content!',
        'mediaUrl': isImage ? 'https://picsum.photos/400/300?random=$index' : null,
        'mediaType': isImage ? 'image' : null,
        'likes': 100 + (index * 50),
        'comments': 20 + index,
        'gifts': 5 + index,
        'timestamp': DateTime.now().subtract(Duration(hours: index)),
        'isLiked': false,
        'isSaved': false,
      };
    });
  }

  void _likePost(int index) {
    setState(() {
      final post = items[index];
      if (post['isLiked']) {
        post['likes'] = post['likes'] - 1;
      } else {
        post['likes'] = post['likes'] + 1;
      }
      post['isLiked'] = !post['isLiked'];
    });
  }

  void _showComments(Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
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
      builder: (context) => AlertDialog(
        title: const Text('Send Gift'),
        content: SizedBox(
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
            ),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  showToast('Gift sent!');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        backgroundColor: Colors.purple,
        bottom: TabBar(
          onTap: (index) {
            setState(() {
              _selectedTab = _tabs[index];
              resetPagination();
              loadMore();
            });
          },
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          indicatorColor: Colors.white,
        ),
      ),
      body: items.isEmpty && isLoadingMore
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? EmptyStateWidget(
                  title: 'No Posts Yet',
                  message: 'Be the first to share something!',
                  icon: Icons.post_add,
                  buttonText: 'Create Post',
                  onButtonPressed: () {
                    _createPost();
                  },
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    resetPagination();
                    await loadMore();
                  },
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == items.length) {
                        return buildPaginationLoadingIndicator();
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
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    ? NetworkImage(post['userAvatar'])
                    : null,
                child: post['userAvatar'] == null
                    ? Text(post['username'][0].toUpperCase())
                    : null,
              ),
            ),
            title: Text(
              post['username'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(_formatTime(post['timestamp'])),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(post['content']),
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
                  image: NetworkImage(post['mediaUrl']),
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
                icon: post['isLiked'] ? Icons.favorite : Icons.favorite_border,
                label: 'Like',
                color: post['isLiked'] ? Colors.red : Colors.grey,
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
                icon: post['isSaved'] ? Icons.bookmark : Icons.bookmark_border,
                label: 'Save',
                color: post['isSaved'] ? Colors.blue : Colors.grey,
                onTap: () {
                  setState(() {
                    post['isSaved'] = !post['isSaved'];
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
      builder: (context) => Container(
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