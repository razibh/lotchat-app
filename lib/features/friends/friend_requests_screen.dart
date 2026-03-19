import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;  // ✅ Supabase User hide

import '../../core/di/service_locator.dart';
import '../../core/services/friend_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/animation/fade_animation.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen>
    with LoadingMixin, ToastMixin, DialogMixin {

  final FriendService _friendService = ServiceLocator().get<FriendService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();

  List<Map<String, dynamic>> _incomingRequests = [];
  List<Map<String, dynamic>> _outgoingRequests = [];
  String _selectedTab = 'Incoming';
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    // ✅ Firebase Auth → Supabase Auth
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      setState(() {
        _currentUserId = session.user.id;
      });
      _setupStreams();
    }
  }

  void _setupStreams() {
    if (_currentUserId == null) return;

    // Mock data for now - in real app, these would be service calls
    setState(() {
      _incomingRequests = _generateMockRequests(5, isIncoming: true);
      _outgoingRequests = _generateMockRequests(3, isIncoming: false);
    });
  }

  List<Map<String, dynamic>> _generateMockRequests(int count, {required bool isIncoming}) {
    return List.generate(count, (index) {
      return {
        'requestId': 'req_$index',
        'userId': 'user_$index',
        'username': isIncoming ? 'Sender ${index + 1}' : 'Receiver ${index + 1}',
        'avatar': 'https://i.pravatar.cc/150?u=$index',
        'message': index % 2 == 0 ? 'Hey, let\'s connect!' : null,
        'timestamp': DateTime.now().subtract(Duration(hours: index * 3)),
        'mutualFriends': index * 2,
      };
    });
  }

  Future<void> _acceptRequest(Map<String, dynamic> request) async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _incomingRequests.removeWhere((r) => r['requestId'] == request['requestId']);
      });
      showSuccess('Friend request accepted');
    });
  }

  Future<void> _rejectRequest(Map<String, dynamic> request) async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Reject Request',
      message: 'Are you sure you want to reject this request?',
    );

    if (confirmed ?? false) {
      await runWithLoading(() async {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          _incomingRequests.removeWhere((r) => r['requestId'] == request['requestId']);
        });
        showSuccess('Request rejected');
      });
    }
  }

  Future<void> _cancelRequest(Map<String, dynamic> request) async {
    final bool? confirmed = await showConfirmDialog(
      context,
      title: 'Cancel Request',
      message: 'Are you sure you want to cancel this request?',
    );

    if (confirmed ?? false) {
      await runWithLoading(() async {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {
          _outgoingRequests.removeWhere((r) => r['requestId'] == request['requestId']);
        });
        showSuccess('Request cancelled');
      });
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friend Requests'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          bottom: TabBar(
            onTap: (int index) {
              setState(() {
                _selectedTab = index == 0 ? 'Incoming' : 'Outgoing';
              });
            },
            tabs: const [
              Tab(text: 'Incoming'),
              Tab(text: 'Outgoing'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
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
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: request['avatar'] != null
                            ? NetworkImage(request['avatar'])
                            : null,
                        backgroundColor: Colors.grey.shade200,
                        child: request['avatar'] == null
                            ? Text(
                          request['username']?[0]?.toUpperCase() ?? '?',
                          style: const TextStyle(fontSize: 20),
                        )
                            : null,
                      ),
                      const SizedBox(width: 12),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request['username'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (request['message'] != null && request['message'].toString().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                request['message'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.people, size: 12, color: Colors.grey.shade600),
                                const SizedBox(width: 2),
                                Text(
                                  '${request['mutualFriends'] ?? 0} mutual friends',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatTime(request['timestamp']),
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
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () => _acceptRequest(request),
                              tooltip: 'Accept',
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () => _rejectRequest(request),
                              tooltip: 'Reject',
                            ),
                          ],
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _cancelRequest(request),
                          tooltip: 'Cancel',
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}