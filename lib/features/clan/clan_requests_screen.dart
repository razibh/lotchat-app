import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/clan_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/animation/fade_animation.dart';

class ClanRequestsScreen extends StatefulWidget {

  const ClanRequestsScreen({required this.clanId, super.key});
  final String clanId;

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
  
  List<Map<String, dynamic>> _requests = <Map<String, dynamic>>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
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
    });
  }

  Future<void> _loadRequests() async {
    // Stream will handle loading
  }

  Future<void> _approveRequest(String requestId, String userId) async {
    await runWithLoading(() async {
      final bool success = await _clanService.approveRequest(requestId, widget.clanId);
      if (success) {
        showSuccess('Request approved');
      }
    });
  }

  Future<void> _rejectRequest(String requestId) async {
    await runWithLoading(() async {
      final bool success = await _clanService.rejectRequest(requestId);
      if (success) {
        showSuccess('Request rejected');
      }
    });
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
        title: const Text('Join Requests'),
        backgroundColor: Colors.deepPurple,
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
                    final Map<String, dynamic> request = _requests[index];
                    final timestamp = (request['timestamp'] as Timestamp).toDate();
                    
                    return FadeAnimation(
                      delay: Duration(milliseconds: index * 100),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: request['avatar'] != null
                                ? NetworkImage(request['avatar'])
                                : null,
                            child: request['avatar'] == null
                                ? Text(request['username'][0].toUpperCase())
                                : null,
                          ),
                          title: Text(request['username']),
                          subtitle: Text('Requested ${_formatTime(timestamp)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <>[
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                onPressed: () => _approveRequest(
                                  request['requestId'],
                                  request['userId'],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red),
                                onPressed: () => _rejectRequest(request['requestId']),
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