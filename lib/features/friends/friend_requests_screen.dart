import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/friend_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/animation/fade_animation.dart';
import 'widgets/request_tile.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({Key? key}) : super(key: key);

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> 
    with LoadingMixin, ToastMixin, DialogMixin {
  
  final FriendService _friendService = ServiceLocator().get<FriendService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();
  
  List<FriendRequestModel> _incomingRequests = <>[];
  List<FriendRequestModel> _outgoingRequests = <>[];
  String _selectedTab = 'Incoming';
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
      _setupStreams();
    }
  }

  void _setupStreams() {
    if (_currentUserId == null) return;

    _friendService.getIncomingRequests(_currentUserId!).listen((requests) {
      if (mounted) {
        setState(() {
          _incomingRequests = requests;
        });
      }
    });

    _friendService.getOutgoingRequests(_currentUserId!).listen((requests) {
      if (mounted) {
        setState(() {
          _outgoingRequests = requests;
        });
      }
    });
  }

  Future<void> _acceptRequest(FriendRequestModel request) async {
    await runWithLoading(() async {
      final bool success = await _friendService.acceptFriendRequest(
        request.requestId,
        request.userId,
      );
      
      if (success) {
        showSuccess('Friend request accepted');
      }
    });
  }

  Future<void> _rejectRequest(FriendRequestModel request) async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Reject Request',
      message: 'Are you sure you want to reject this request?',
    );

    if (confirmed ?? false) {
      await runWithLoading(() async {
        final bool success = await _friendService.rejectFriendRequest(request.requestId);
        if (success) {
          showSuccess('Request rejected');
        }
      });
    }
  }

  Future<void> _cancelRequest(FriendRequestModel request) async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Cancel Request',
      message: 'Are you sure you want to cancel this request?',
    );

    if (confirmed ?? false) {
      await runWithLoading(() async {
        final bool success = await _friendService.cancelFriendRequest(request.requestId);
        if (success) {
          showSuccess('Request cancelled');
        }
      });
    }
  }

  String _formatTime(DateTime time) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final requests = _selectedTab == 'Incoming'
        ? _incomingRequests
        : _outgoingRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          onTap: (index) {
            setState(() {
              _selectedTab = index == 0 ? 'Incoming' : 'Outgoing';
            });
          },
          tabs: const <>[
            Tab(text: 'Incoming'),
            Tab(text: 'Outgoing'),
          ],
          indicatorColor: Colors.white,
        ),
      ),
      body: requests.isEmpty
          ? EmptyStateWidget(
              title: _selectedTab == 'Incoming'
                  ? 'No Incoming Requests'
                  : 'No Outgoing Requests',
              message: _selectedTab == 'Incoming'
                  ? 'When someone sends you a friend request, it will appear here'
                  : 'When you send friend requests, they will appear here',
              icon: Icons.person_add_disabled,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return FadeAnimation(
                  delay: Duration(milliseconds: index * 50),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: <>[
                          // Avatar
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: request.avatar != null
                                ? NetworkImage(request.avatar!)
                                : null,
                            child: request.avatar == null
                                ? Text(request.username[0].toUpperCase())
                                : null,
                          ),
                          const SizedBox(width: 12),
                          
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <>[
                                Text(
                                  request.username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (request.message != null) ...<>[
                                  const SizedBox(height: 2),
                                  Text(
                                    request.message!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Row(
                                  children: <>[
                                    Icon(Icons.people, size: 12, color: Colors.grey.shade600),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${request.mutualFriends} mutual friends',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatTime(request.timestamp),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Actions
                          if (_selectedTab == 'Incoming')
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <>[
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () => _acceptRequest(request),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () => _rejectRequest(request),
                                ),
                              ],
                            )
                          else
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _cancelRequest(request),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}