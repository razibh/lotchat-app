import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/call_service.dart';
import '../../core/services/logger_service.dart';
import '../../mixins/pagination_mixin.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../profile/profile_screen.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen>
    with PaginationMixin<Map<String, dynamic>> {

  final CallService _callService = ServiceLocator.instance.get<CallService>();
  final LoggerService _logger = ServiceLocator.instance.get<LoggerService>();

  @override
  void initState() {
    super.initState();
    initPagination();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadFirstPage(setState);
    });
  }

  @override
  void dispose() {
    disposePagination();
    super.dispose();
  }

  @override
  Future<PaginationResult<Map<String, dynamic>>> fetchPage(int page) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    final items = List.generate(20, (index) {
      final int actualIndex = page * 20 + index;
      final String callType = actualIndex % 2 == 0 ? 'video' : 'audio';
      final int callStatus = actualIndex % 3;

      return {
        'id': 'call_$actualIndex',
        'userId': 'user_$actualIndex',
        'name': 'User ${actualIndex + 1}',
        'avatar': null,
        'type': callType,
        'status': callStatus == 0 ? 'missed' : (callStatus == 1 ? 'incoming' : 'outgoing'),
        'duration': 120 + (actualIndex * 30),
        'timestamp': DateTime.now().subtract(Duration(hours: actualIndex)),
      };
    });

    return PaginationResult(
      items: items,
      currentPage: page,
      totalPages: 5,
      totalItems: 100,
    );
  }

  void _onScroll() {
    if (!hasMore || isLoading) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    if (currentScroll >= maxScroll * 0.8) {
      loadMore(setState);
    }
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
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

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
      body: RefreshIndicator(
        onRefresh: () => refreshData(setState),
        color: Colors.teal,
        child: isLoading && items.isEmpty
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
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final call = items[index];
            final timestamp = call['timestamp'] as DateTime;

            return ListTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: call['avatar'] != null
                        ? NetworkImage(call['avatar'] as String)
                        : null,
                    child: call['avatar'] == null
                        ? Text((call['name'] as String)[0].toUpperCase())
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
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
              title: Text(call['name'] as String),
              subtitle: Row(
                children: [
                  Icon(
                    _getStatusIcon(call['status'] as String),
                    size: 12,
                    color: _getStatusColor(call['status'] as String),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    call['status'] == 'missed'
                        ? 'Missed call'
                        : _formatDuration(call['duration'] as int),
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: call['userId'] as String),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}