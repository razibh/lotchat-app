import 'package:flutter/material.dart'; // Color এর জন্য এই import যোগ করুন
import '../models/event_model.dart';

class EventService {
  // Singleton pattern
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  // Get active events
  Future<List<EventModel>> getActiveEvents() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    return [
      EventModel(
        id: 'e1',
        title: "Valentine's Day Special",
        description: 'Double hearts on all gifts!',
        type: EventType.holiday,
        status: EventStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 6)),
        rewards: {'type': 'points', 'value': '2x'},
        participants: 15420,
        image: 'valentine',
        color: const Color(0xFFFF69B4), // Pink
      ),
      EventModel(
        id: 'e2',
        title: 'Weekend Bonus',
        description: 'Earn 50% more coins on all activities',
        type: EventType.promotion,
        status: EventStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 1)),
        rewards: {'type': 'coins', 'value': '+50%'},
        participants: 8320,
        image: 'weekend',
        color: const Color(0xFF2196F3), // Blue
      ),
      EventModel(
        id: 'e3',
        title: 'PK Championship',
        description: 'Compete for the ultimate prize',
        type: EventType.tournament,
        status: EventStatus.active,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 3)),
        rewards: {'type': 'coins', 'value': '10000', 'badge': 'champion'},
        participants: 1250,
        image: 'tournament',
        color: const Color(0xFF9C27B0), // Purple
      ),
    ];
  }

  // Get upcoming events
  Future<List<EventModel>> getUpcomingEvents() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      EventModel(
        id: 'e4',
        title: 'New Year Celebration',
        description: 'Welcome the new year with special gifts',
        type: EventType.holiday,
        status: EventStatus.upcoming,
        startDate: DateTime.now().add(const Duration(days: 25)),
        endDate: DateTime.now().add(const Duration(days: 32)),
        rewards: {'type': 'frames', 'badges': 'special'},
        participants: 0,
        image: 'newyear',
        color: const Color(0xFFFFC107), // Amber
      ),
      EventModel(
        id: 'e5',
        title: 'Spring Festival',
        description: 'Spring themed gifts and effects',
        type: EventType.festival,
        status: EventStatus.upcoming,
        startDate: DateTime.now().add(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 45)),
        rewards: {'type': 'limited', 'items': 'spring'},
        participants: 0,
        image: 'spring',
        color: const Color(0xFF4CAF50), // Green
      ),
    ];
  }

  // Get event by ID
  Future<EventModel?> getEventById(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final allEvents = await getAllEvents();
    try {
      return allEvents.firstWhere((event) => event.id == eventId);
    } catch (e) {
      return null;
    }
  }

  // Get all events
  Future<List<EventModel>> getAllEvents() async {
    final active = await getActiveEvents();
    final upcoming = await getUpcomingEvents();
    return [...active, ...upcoming];
  }

  // Join event
  Future<bool> joinEvent(String eventId, String userId) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}