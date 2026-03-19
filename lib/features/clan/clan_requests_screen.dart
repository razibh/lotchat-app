import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/di/service_locator.dart';
import '../clan/services/clan_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/animation/fade_animation.dart';

class ClanRequestsScreen extends StatefulWidget {
  final String clanId;

  const ClanRequestsScreen({required this.clanId, super.key});

  @override
  State<ClanRequestsScreen> createState() => _ClanRequestsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('clanId', clanId));
  }
}

class _ClanRequestsScreenState extends State<ClanRequestsScreen>
    with LoadingMixin, ToastMixin {

  final ClanService _clanService = ServiceLocator().get<ClanService>();

  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  void _setupStream() {
    _clanService.getJoinRequests(widget.clanId).listen((List<Map<String, dynamic>> requests) {
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showError('Failed to load requests');
      }
    });
  }

  // FIXED: Removed userId parameter - clanService.approveRequest expects 2 parameters
  Future<void> _approveRequest(String requestId, String userId) async {
    await runWithLoading(() async {
      final bool success = await _clanService.approveRequest(requestId, widget.clanId);
      if (success) {
        showSuccess('Request approved');
      } else {
        showError('Failed to approve request');
      }
    });
  }

  Future<void> _rejectRequest(String requestId) async {
    await runWithLoading(() async {
      final bool success = await _clanService.rejectRequest(requestId);
      if (success) {
        showSuccess('Request rejected');
      } else {
        showError('Failed to reject request');
      }
    });
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    DateTime time;
    if (timestamp is DateTime) {
      time = timestamp;
    } else if (timestamp is String) {
      try {
        time = DateTime.parse(timestamp);
      } catch (e) {
        return 'Unknown';
      }
    } else {
      return 'Unknown';
    }

    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Requests'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _setupStream();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
          ? const EmptyStateWidget(
        title: 'No Requests',
        message: 'No pending join requests',
        icon: Icons.person_add_disabled,
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _requests.length,
        itemBuilder: (BuildContext context, int index) {
          final request = _requests[index];
          final requestId = request['id']?.toString() ?? '';
          final userId = request['user_id']?.toString() ?? request['userId']?.toString() ?? '';
          final username = request['username'] ?? 'Unknown';
          final avatar = request['avatar_url'] ?? request['avatar'] as String?;

          return FadeAnimation(
            delay: Duration(milliseconds: index * 100),
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: avatar != null
                      ? NetworkImage(avatar)
                      : null,
                  backgroundColor: Colors.deepPurple.shade100,
                  child: avatar == null
                      ? Text(
                    username.isNotEmpty ? username[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                      : null,
                ),
                title: Text(
                  username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requested ${_formatTime(request['created_at'] ?? request['timestamp'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (request['message'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Message: ${request['message']}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: requestId.isNotEmpty
                            ? () => _approveRequest(requestId, userId)  // FIXED: Passing 2 parameters
                            : null,
                        tooltip: 'Approve',
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: requestId.isNotEmpty
                            ? () => _rejectRequest(requestId)
                            : null,
                        tooltip: 'Reject',
                      ),
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