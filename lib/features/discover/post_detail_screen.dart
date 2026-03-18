import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/gift_service.dart';
import '../../core/utils/date_formatters.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../features/profile/profile_screen.dart';
import '../../widgets/gift_panel.dart';


class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailScreen({
    required this.post,
    super.key,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Map<String, dynamic>>('post', post));
  }
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with LoadingMixin, ToastMixin {

  final NotificationService _notificationService = ServiceLocator().get<NotificationService>();
  final GiftService _giftService = ServiceLocator().get<GiftService>();

  late Map<String, dynamic> _post;
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLiked = false;
  int _likeCount = 0;
  bool _showGiftPanel = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _likeCount = _post['likes'] ?? 0;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    // Mock comments
    setState(() {
      _comments = List.generate(10, (index) {
        return {
          'id': 'comment_$index',
          'userId': 'user_$index',
          'username': 'User ${index + 1}',
          'userAvatar': 'https://i.pravatar.cc/150?u=$index',
          'content': 'This is comment number ${index + 1}. Great post!',
          'timestamp': DateTime.now().subtract(Duration(minutes: index * 5)),
          'likes': index * 2,
          'replies': [],
        };
      });
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final newComment = {
      'id': 'comment_new',
      'userId': 'current_user',
      'username': 'You',
      'userAvatar': 'https://i.pravatar.cc/150?u=current',
      'content': _commentController.text,
      'timestamp': DateTime.now(),
      'likes': 0,
      'replies': [],
    };

    setState(() {
      _comments.insert(0, newComment);
      _commentController.clear();
    });

    showSuccess('Comment added');
  }

  void _likeComment(int index) {
    setState(() {
      _comments[index]['likes'] = (_comments[index]['likes'] ?? 0) + 1;
    });
  }

  void _replyToComment(Map<String, dynamic> comment) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(comment['userAvatar']),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Replying to @${comment['username']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Write your reply...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onSubmitted: (String value) {
                Navigator.pop(context);
                showSuccess('Reply added');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sharePost() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Post',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShareOption(
                  icon: Icons.share,
                  label: 'Share',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    showSuccess('Shared successfully');
                  },
                ),
                _buildShareOption(
                  icon: Icons.link,
                  label: 'Copy Link',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    showSuccess('Link copied to clipboard');
                  },
                ),
                _buildShareOption(
                  icon: Icons.bookmark,
                  label: 'Save',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    showSuccess('Post saved');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePost,
          ),
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'report',
                child: Text('Report'),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Text('Block User'),
              ),
            ],
            onSelected: (String value) {
              if (value == 'report') {
                showSuccess('Post reported');
              } else if (value == 'block') {
                showSuccess('User blocked');
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Post Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Post Header
                FadeAnimation(
                  child: _buildPostHeader(),
                ),
                const SizedBox(height: 16),

                // Post Content
                FadeAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: _buildPostContent(),
                ),
                const SizedBox(height: 16),

                // Post Stats
                FadeAnimation(
                  delay: const Duration(milliseconds: 150),
                  child: _buildPostStats(),
                ),
                const Divider(),

                // Post Actions
                FadeAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: _buildPostActions(),
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Comments Header
                const Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Comments List
                ..._comments.map((comment) => FadeAnimation(
                  child: _buildComment(comment),
                )).toList(),
              ],
            ),
          ),

          // Comment Input
          _buildCommentInput(),

          // Gift Panel
          if (_showGiftPanel)
            GiftPanel(
              receiverId: _post['userId'],
              onSendGift: (gift) {
                setState(() {
                  _showGiftPanel = false;
                });
                showSuccess('Gift sent!');
              },
              onClose: () {
                setState(() {
                  _showGiftPanel = false;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: _post['userId']),
            ),
          );
        },
        child: CircleAvatar(
          backgroundImage: _post['userAvatar'] != null
              ? NetworkImage(_post['userAvatar'])
              : null,
          backgroundColor: Colors.grey.shade200,
          child: _post['userAvatar'] == null
              ? Text(_post['username'][0].toUpperCase())
              : null,
        ),
      ),
      title: Text(
        _post['username'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(DateFormatter.timeAgo(_post['timestamp'])),
      trailing: const Icon(Icons.more_vert),
    );
  }

  Widget _buildPostContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Post Text
        Text(
          _post['content'],
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),

        // Post Media
        if (_post['mediaUrl'] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _post['mediaUrl'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPostStats() {
    return Row(
      children: [
        Row(
          children: [
            Icon(
              Icons.favorite,
              size: 16,
              color: _isLiked ? Colors.red : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text('$_likeCount'),
          ],
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            const Icon(Icons.comment, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text('${_comments.length}'),
          ],
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            const Icon(Icons.card_giftcard, size: 16, color: Colors.purple),
            const SizedBox(width: 4),
            Text('${_post['gifts'] ?? 0}'),
          ],
        ),
      ],
    );
  }

  Widget _buildPostActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          label: 'Like',
          color: _isLiked ? Colors.red : Colors.grey,
          onTap: _toggleLike,
        ),
        _buildActionButton(
          icon: Icons.comment,
          label: 'Comment',
          color: Colors.blue,
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
        ),
        _buildActionButton(
          icon: Icons.card_giftcard,
          label: 'Gift',
          color: Colors.purple,
          onTap: () {
            setState(() {
              _showGiftPanel = !_showGiftPanel;
            });
          },
        ),
        _buildActionButton(
          icon: Icons.share,
          label: 'Share',
          color: Colors.green,
          onTap: _sharePost,
        ),
      ],
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

  Widget _buildComment(Map<String, dynamic> comment) {
    final index = _comments.indexOf(comment);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: comment['userId']),
                ),
              );
            },
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(comment['userAvatar']),
              onBackgroundImageError: (exception, stackTrace) {},
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment['username'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(comment['content']),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      DateFormatter.timeAgo(comment['timestamp']),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _likeComment(index),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${comment['likes']}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _replyToComment(comment),
                      child: const Text(
                        'Reply',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=current'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _commentController,
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
            icon: const Icon(Icons.send, color: Colors.purple),
            onPressed: _addComment,
          ),
        ],
      ),
    );
  }
}