import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/services/event_service.dart';
import '../../core/models/event_model.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/animation/fade_animation.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with LoadingMixin, ToastMixin {

  final EventService _eventService = ServiceLocator().get<EventService>();

  List<EventModel> _activeEvents = [];
  List<EventModel> _upcomingEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));

      _activeEvents = await _eventService.getActiveEvents();
      _upcomingEvents = await _eventService.getUpcomingEvents();

      setState(() {
        _isLoading = false;
      });
    });
  }

  void _joinEvent(EventModel event) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 50, color: Colors.amber),
            const SizedBox(height: 16),
            Text('Join ${event.title}?'),
            const SizedBox(height: 8),
            Text(
              'Rewards: ${event.rewards['value'] ?? event.rewards.toString()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showSuccess('Joined event!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: event.color,
            ),
            child: const Text('Join Now'),
          ),
        ],
      ),
    );
  }

  String _formatEventDate(DateTime start, DateTime end) {
    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }

  String _getRewardString(Map<String, dynamic> rewards) {
    if (rewards.containsKey('value')) {
      return rewards['value'].toString();
    }
    return 'Special Rewards';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Events'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Events
            const Text(
              '🔥 Active Events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._activeEvents.map((event) => _buildEventCard(event, true)).toList(),

            const SizedBox(height: 24),

            // Upcoming Events
            const Text(
              '📅 Upcoming Events',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._upcomingEvents.map((event) => _buildEventCard(event, false)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(EventModel event, bool isActive) {
    return FadeAnimation(
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                event.color.withOpacity(0.1),
                event.color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: event.color.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getEventIcon(event.type),
                        color: event.color,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                _formatEventDate(event.startDate, event.endDate),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress/Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: event.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.card_giftcard, size: 12, color: event.color),
                              const SizedBox(width: 4),
                              Text(
                                _getRewardString(event.rewards),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: event.color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.people, size: 12, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  '${event.participants}+ joined',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () => _joinEvent(event),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: event.color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(isActive ? 'Join' : 'Remind'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getEventIcon(EventType type) {
    switch (type) {
      case EventType.holiday:
        return Icons.celebration;
      case EventType.promotion:
        return Icons.weekend;
      case EventType.tournament:
        return Icons.emoji_events;
      case EventType.festival:
        return Icons.park;
      default:
        return Icons.event;
    }
  }
}