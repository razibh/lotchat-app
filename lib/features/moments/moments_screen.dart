import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/moments_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../widgets/common/custom_button.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class MomentsScreen extends StatefulWidget {
  const MomentsScreen({Key? key}) : super(key: key);

  @override
  State<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends State<MomentsScreen> 
    with LoadingMixin, ToastMixin {
  
  final _momentsService = ServiceLocator().get<MomentsService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();
  
  final List<Moment> _moments = <Moment>[];
  List<Moment> _myStory = <Moment>[];
  Map<String, List<Moment>> _friendsStories = <String, List<Moment>>{};
  int _currentStoryIndex = 0;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadMoments();
  }

  Future<void> _getCurrentUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUserId = user?.uid;
    });
  }

  Future<void> _loadMoments() async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _myStory = List.generate(3, (int index) => Moment(
        id: 'my_$index',
        userId: _currentUserId ?? 'user1',
        username: 'You',
        type: index == 0 ? 'image' : 'video',
        mediaUrl: index == 0 ? 'https://picsum.photos/400/800?random=$index' : null,
        caption: <String>['Good morning!', 'My day', 'Fun time'][index],
        timestamp: DateTime.now().subtract(Duration(hours: index)),
        views: 120 + (index * 50),
        likes: 45 + (index * 20),
        comments: 12 + index,
      ));

      _friendsStories = <String, List<Moment>>{
        'user2': List.generate(4, (int index) => Moment(
          id: 'u2_$index',
          userId: 'user2',
          username: 'Alice',
          type: 'image',
          mediaUrl: 'https://picsum.photos/400/800?random=${index + 10}',
          caption: <String>['Vacation!', 'Beach day', 'Sunset', 'Good vibes'][index],
          timestamp: DateTime.now().subtract(Duration(hours: index * 2)),
          views: 200 + (index * 30),
          likes: 80 + (index * 15),
          comments: 20 + index,
        )),
        'user3': List.generate(2, (int index) => Moment(
          id: 'u3_$index',
          userId: 'user3',
          username: 'Bob',
          type: 'image',
          mediaUrl: 'https://picsum.photos/400/800?random=${index + 20}',
          caption: <String>['Workout', 'Coffee time'][index],
          timestamp: DateTime.now().subtract(Duration(hours: index * 3)),
          views: 150 + (index * 20),
          likes: 60 + (index * 10),
          comments: 10 + index,
        )),
        'user4': List.generate(5, (int index) => Moment(
          id: 'u4_$index',
          userId: 'user4',
          username: 'Charlie',
          type: index == 2 ? 'video' : 'image',
          mediaUrl: index == 2 ? null : 'https://picsum.photos/400/800?random=${index + 30}',
          caption: <String>['Gaming', 'Music', 'Dance video', 'Food', 'Night out'][index],
          timestamp: DateTime.now().subtract(Duration(hours: index)),
          views: 300 + (index * 50),
          likes: 120 + (index * 25),
          comments: 30 + index,
        )),
      };
    });
  }

  void _viewStory(String userId, List<Moment> story) {
    setState(() {
      _currentStoryIndex = 0;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        child: StoryViewer(
          userId: userId,
          story: story,
          onClose: () => Navigator.pop(context),
          onNext: () {
            // Navigate to next story
          },
          onPrevious: () {
            // Navigate to previous story
          },
        ),
      ),
    );
  }

  void _createMoment() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            const Text(
              'Add to Story',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.blue),
              title: const Text('Upload Photo'),
              onTap: () {
                Navigator.pop(context);
                // Pick image
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam, color: Colors.red),
              title: const Text('Record Video'),
              onTap: () {
                Navigator.pop(context);
                // Record video
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields, color: Colors.green),
              title: const Text('Text Post'),
              onTap: () {
                Navigator.pop(context);
                _showTextPostDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTextPostDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Text Post'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: "What's on your mind?",
            border: OutlineInputBorder(),
          ),
        ),
        actions: <>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showSuccess('Post created!');
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moments'),
        backgroundColor: Colors.pink,
        actions: <>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createMoment,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <>[
                  // Your Story
                  const Text(
                    'Your Story',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <>[
                        // Add Story Button
                        Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: _createMoment,
                            child: Column(
                              children: <>[
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: <>[Colors.pink, Colors.purple],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Add Story',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // My Story Items
                        ..._myStory.map((Moment moment) => Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => _viewStory(_currentUserId ?? '', _myStory),
                            child: Column(
                              children: <>[
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: <>[Colors.orange, Colors.pink],
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.pink,
                                      width: 3,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: moment.type == 'image' && moment.mediaUrl != null
                                        ? Image.network(
                                            moment.mediaUrl!,
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(
                                            Icons.video_library,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(moment.timestamp),
                                  style: const TextStyle(fontSize: 8, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Friends Stories
                  const Text(
                    'Friends Stories',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._friendsStories.entries.map((MapEntry<String, List<Moment>> entry) {
                    final String userId = entry.key;
                    final List<Moment> story = entry.value;
                    final Moment firstMoment = story.first;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: <>[
                          GestureDetector(
                            onTap: () => _viewStory(userId, story),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: <>[Colors.pink, Colors.purple],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.pink,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: firstMoment.userAvatar != null
                                    ? Image.network(
                                        firstMoment.userAvatar!,
                                        fit: BoxFit.cover,
                                      )
                                    : Center(
                                        child: Text(
                                          firstMoment.username[0].toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <>[
                                Text(
                                  firstMoment.username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${story.length} stories • ${_formatTime(story.last.timestamp)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CustomButton(
                            text: 'View',
                            onPressed: () => _viewStory(userId, story),
                            color: Colors.pink,
                            height: 36,
                            isFullWidth: false,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}

class StoryViewer extends StatefulWidget {

  const StoryViewer({
    Key? key,
    required this.userId,
    required this.story,
    required this.onClose,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);
  final String userId;
  final List<Moment> story;
  final VoidCallback onClose;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  int _currentIndex = 0;
  bool _isPaused = false;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextStory();
      }
    });

    _loadCurrentStory();
  }

  void _loadCurrentStory() {
    final moment = widget.story[_currentIndex];
    if (moment.type == 'video') {
      _initializeVideo();
    } else {
      _progressController.forward();
    }
  }

  void _initializeVideo() {
    // Initialize video player
  }

  void _nextStory() {
    if (_currentIndex < widget.story.length - 1) {
      setState(() {
        _currentIndex++;
        _progressController.reset();
        _loadCurrentStory();
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onClose();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _progressController.reset();
        _loadCurrentStory();
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _progressController.stop();
        if (_videoController != null) {
          _videoController!.pause();
        }
      } else {
        _progressController.forward();
        if (_videoController != null) {
          _videoController!.play();
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moment = widget.story[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <>[
          // Story Content
          PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.story.length,
            itemBuilder: (context, index) {
              final m = widget.story[index];
              return GestureDetector(
                onTapDown: (details) {
                  final width = MediaQuery.of(context).size.width;
                  if (details.globalPosition.dx < width / 3) {
                    _previousStory();
                  } else if (details.globalPosition.dx > 2 * width / 3) {
                    _nextStory();
                  } else {
                    _togglePause();
                  }
                },
                onLongPress: _togglePause,
                onLongPressUp: _togglePause,
                child: Container(
                  color: Colors.black,
                  child: m.type == 'image' && m.mediaUrl != null
                      ? Image.network(
                          m.mediaUrl!,
                          fit: BoxFit.contain,
                        )
                      : Container(
                          color: Colors.grey.shade900,
                          child: const Center(
                            child: Icon(
                              Icons.video_library,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                ),
              );
            },
          ),

          // Progress Bars
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Row(
              children: widget.story.asMap().entries.map((entry) {
                final index = entry.key;
                final bool isCurrent = index == _currentIndex;
                final isPast = index < _currentIndex;
                
                return Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Stack(
                      children: <>[
                        Container(
                          color: Colors.white.withOpacity(0.3),
                        ),
                        if (isCurrent)
                          AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                widthFactor: _progressController.value,
                                child: Container(
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        if (isPast)
                          Container(
                            color: Colors.white,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Header
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Row(
              children: <>[
                CircleAvatar(
                  radius: 16,
                  backgroundImage: moment.userAvatar != null
                      ? NetworkImage(moment.userAvatar!)
                      : null,
                  child: moment.userAvatar == null
                      ? Text(moment.username[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <>[
                      Text(
                        moment.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTime(moment.timestamp),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),

          // Caption
          if (moment.caption != null)
            Positioned(
              bottom: 100,
              left: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  moment.caption!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

          // Actions
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <>[
                _buildActionButton(
                  icon: Icons.favorite_border,
                  label: '${moment.likes}',
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.comment,
                  label: '${moment.comments}',
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.card_giftcard,
                  label: 'Gift',
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: <>[
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
}

class Moment {

  Moment({
    required this.id,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.type,
    this.mediaUrl,
    this.caption,
    required this.timestamp,
    required this.views,
    required this.likes,
    required this.comments,
  });
  final String id;
  final String userId;
  final String username;
  final String? userAvatar;
  final String type; // 'image', 'video', 'text'
  final String? mediaUrl;
  final String? caption;
  final DateTime timestamp;
  final int views;
  final int likes;
  final int comments;
}