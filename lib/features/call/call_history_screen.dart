import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/call_service.dart';
import '../../core/services/logger_service.dart';
import '../../mixins/pagination_mixin.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../profile/profile_screen.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> 
    with PaginationMixin<Map<String, dynamic>> {
  
  final _callService = ServiceLocator().get<CallService>();
  final _logger = ServiceLocator().get<LoggerService>();

  @override
  void initState() {
    super.initState();
    initPagination();
    loadMore();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchPage(int page) async {
    // Fetch from service
    await Future.delayed(const Duration(seconds: 1));
    
    return List.generate(20, (index) {
      final callType = index % 2 == 0 ? 'video' : 'audio';
      final callStatus = index % 3;
      return {
        'id': 'call_$index',
        'userId': 'user_$index',
        'name': 'User ${index + 1}',
        'avatar': null,
        'type': callType,
        'status': callStatus == 0 ? 'missed' : (callStatus == 1 ? 'incoming' : 'outgoing'),
        'duration': 120 + (index * 30),
        'timestamp': DateTime.now().subtract(Duration(hours: index)),
      };
    });
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'incoming':
        return Icons.call_received;
      case 'outgoing':
        return Icons.call_made;
      case 'missed':
        return Icons.call_missed;
      default:
        return Icons.call;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'incoming':
        return Colors.green;
      case 'outgoing':
        return Colors.blue;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              // Clear history
            },
          ),
        ],
      ),
      body: items.isEmpty && isLoadingMore
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const EmptyStateWidget(
                  title: 'No Call History',
                  message: 'Your call history will appear here',
                  icon: Icons.history,
                )
              : ListView.builder(
                  controller: scrollController,
                  itemCount: items.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      return buildPaginationLoadingIndicator();
                    }
                    
                    final call = items[index];
                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundImage: call['avatar'] != null
                                ? NetworkImage(call['avatar'])
                                : null,
                            child: call['avatar'] == null
                                ? Text(call['name'][0].toUpperCase())
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                call['type'] == 'video'
                                    ? Icons.videocam
                                    : Icons.call,
                                size: 12,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Text(call['name']),
                      subtitle: Row(
                        children: [
                          Icon(
                            _getStatusIcon(call['status']),
                            size: 12,
                            color: _getStatusColor(call['status']),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            call['status'] == 'missed'
                                ? 'Missed call'
                                : _formatDuration(call['duration']),
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatDate(call['timestamp']),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${call['timestamp'].hour}:${call['timestamp'].minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to profile
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(userId: call['userId']),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}