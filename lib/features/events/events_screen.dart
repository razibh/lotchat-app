import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/event_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../widgets/common/custom_button.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> 
    with LoadingMixin, ToastMixin {
  
  final _eventService = ServiceLocator().get<EventService>();
  
  List<EventModel> _activeEvents = <EventModel>[];
  List<EventModel> _upcomingEvents = <EventModel>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));
      
      _activeEvents = <EventModel>[
        EventModel(
          id: 'e1',
          title: "Valentine's Day Special",
          description: 'Double hearts on all gifts!',
          type: 'holiday',
          startDate: DateTime.now().subtract(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 6)),
          rewards: '2x Gift Points',
          participants: 15420,
          image: 'valentine',
          color: Colors.pink,
        ),
        EventModel(
          id: 'e2',
          title: 'Weekend Bonus',
          description: 'Earn 50% more coins on all activities',
          type: 'weekend',
          startDate: DateTime.now().subtract(const Duration(days: 2)),
          endDate: DateTime.now().add(const Duration(days: 1)),
          rewards: '+50% Coins',
          participants: 8320,
          image: 'weekend',
          color: Colors.blue,
        ),
        EventModel(
          id: 'e3',
          title: 'PK Championship',
          description: 'Compete for the ultimate prize',
          type: 'tournament',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 3)),
          rewards: '10,000 Coins + Badge',
          participants: 1250,
          image: 'tournament',
          color: Colors.purple,
        ),
      ];

      _upcomingEvents = <EventModel>[
        EventModel(
          id: 'e4',
          title: 'New Year Celebration',
          description: 'Welcome the new year with special gifts',
          type: 'holiday',
          startDate: DateTime.now().add(const Duration(days: 25)),
          endDate: DateTime.now().add(const Duration(days: 32)),
          rewards: 'Special Frames & Badges',
          participants: 0,
          image: 'newyear',
          color: Colors.amber,
        ),
        EventModel(
          id: 'e5',
          title: 'Spring Festival',
          description: 'Spring themed gifts and effects',
          type: 'seasonal',
          startDate: DateTime.now().add(const Duration(days: 15)),
          endDate: DateTime.now().add(const Duration(days: 45)),
          rewards: 'Limited Edition Items',
          participants: 0,
          image: 'spring',
          color: Colors.green,
        ),
      ];
      
      _isLoading = false;
    });
  }

  void _joinEvent(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            const Icon(Icons.celebration, size: 50, color: Colors.amber),
            const SizedBox(height: 16),
            Text('Join ${event.title}?'),
            const SizedBox(height: 8),
            Text(
              'Rewards: ${event.rewards}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: <>[
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Special Events'),
        backgroundColor: Colors.amber,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <>[
                  // Active Events
                  const Text(
                    '🔥 Active Events',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._activeEvents.map((EventModel event) => _buildEventCard(event, true)),

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
                  ..._upcomingEvents.map((EventModel event) => _buildEventCard(event, false)),
                ],
              ),
            ),
    );
  }

  Widget _buildEventCard(EventModel event, bool isActive) {
    return FadeAnimation(
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <>[
                event.color.withOpacity(0.1),
                event.color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <>[
                Row(
                  children: <>[
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
                        children: <>[
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
                            children: <>[
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
                  children: <>[
                    Row(
                      children: <>[
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
                            children: <>[
                              Icon(Icons.card_giftcard, size: 12, color: event.color),
                              const SizedBox(width: 4),
                              Text(
                                event.rewards,
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
                              children: <>[
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
                    
                    CustomButton(
                      text: isActive ? 'Join' : 'Remind',
                      onPressed: () => _joinEvent(event),
                      color: event.color,
                      height: 36,
                      isFullWidth: false,
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

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'holiday':
        return Icons.celebration;
      case 'weekend':
        return Icons.weekend;
      case 'tournament':
        return Icons.emoji_events;
      case 'seasonal':
        return Icons.park;
      default:
        return Icons.event;
    }
  }
}

class EventModel {

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.rewards,
    required this.participants,
    required this.image,
    required this.color,
  });
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String rewards;
  final int participants;
  final String image;
  final Color color;
}