import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room_model.dart';
import '../models/user_models.dart' as app;
import '../models/seat_model.dart';
import '../di/service_locator.dart';
import 'notification_service.dart';

class RoomService {
  late final SupabaseClient _supabase;
  late final NotificationService _notificationService;

  RoomService() {
    _initializeServices();
  }

  void _initializeServices() {
    try {
      _supabase = getService<SupabaseClient>();
      _notificationService = ServiceLocator.instance.get<NotificationService>();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  // Helper to get current user
  String? get _currentUserId => _supabase.auth.currentSession?.user.id;

  // Helper methods
  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is String) return DateTime.parse(date);
    if (date is DateTime) return date;
    return DateTime.now();
  }

  // ==================== GET ROOMS ====================

  /// Get rooms by country
  Future<List<RoomModel>> getRooms(String country) async {
    try {
      List<Map<String, dynamic>> response;

      if (country == 'All') {
        response = await _supabase
            .from('rooms')
            .select()
            .eq('status', 'active')
            .order('viewer_count', ascending: false)
            .limit(50);
      } else {
        response = await _supabase
            .from('rooms')
            .select()
            .eq('country', country)
            .eq('status', 'active')
            .order('viewer_count', ascending: false)
            .limit(50);
      }

      return response.map((json) => RoomModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting rooms: $e');
      return _getMockRooms();
    }
  }

  /// Update viewer count
  Future<void> updateViewerCount(String roomId, int count) async {
    try {
      final updateQuery = _supabase
          .from('rooms')
          .update({
        'viewer_count': count,
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', roomId);
    } catch (e) {
      debugPrint('Error updating viewer count: $e');
    }
  }

  // ==================== CREATE ROOM ====================

  /// Create room
  Future<RoomModel?> createRoom({
    required String name,
    required String category,
    String? description,
    String? coverImage,
    bool isPrivate = false,
    String? pinCode,
    int maxSeats = 9,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      // Get current user info
      final userData = await _supabase
          .from('users')
          .select('username, avatar_url')
          .eq('id', userId)
          .maybeSingle();

      final room = RoomModel(
        id: '',
        name: name,
        hostId: userId,
        hostName: userData?['username'] ?? 'User',
        hostAvatar: userData?['avatar_url'],
        category: category,
        description: description,
        coverImage: coverImage,
        viewerCount: 0,
        maxSeats: maxSeats,
        seats: List.generate(maxSeats, (int index) => SeatModel(
          seatNumber: index + 1,
          isEmpty: true,
        )),
        isPrivate: isPrivate,
        pinCode: pinCode,
        createdAt: DateTime.now(),
        status: RoomStatus.active,
      );

      final response = await _supabase
          .from('rooms')
          .insert(room.toJson())
          .select()
          .single();

      return RoomModel.fromJson(response);
    } catch (e) {
      debugPrint('Error creating room: $e');
      return null;
    }
  }

  // ==================== GET ROOM ====================

  /// Get room
  Future<RoomModel?> getRoom(String roomId) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .eq('id', roomId)
          .maybeSingle();

      if (response != null) {
        return RoomModel.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting room: $e');
      return null;
    }
  }

  /// Stream room
  Stream<RoomModel?> streamRoom(String roomId) {
    try {
      final stream = _supabase
          .from('rooms')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        for (var item in data) {
          if (item['id'].toString() == roomId) {
            return RoomModel.fromJson(item);
          }
        }
        return null;
      });
    } catch (e) {
      debugPrint('Error streaming room: $e');
      return Stream.value(null);
    }
  }

  /// Get active rooms stream
  Stream<List<RoomModel>> getActiveRooms({String? category, String? country}) {
    try {
      final stream = _supabase
          .from('rooms')
          .stream(primaryKey: ['id']);

      return stream.map((data) {
        // Manual filtering
        var filteredData = data.where((item) => item['status'] == 'active').toList();

        if (category != null && category != 'All') {
          filteredData = filteredData.where((item) => item['category'] == category).toList();
        }

        if (country != null && country != 'All') {
          filteredData = filteredData.where((item) => item['country'] == country).toList();
        }

        // Sort by viewer count
        filteredData.sort((a, b) {
          final aCount = _toInt(a['viewer_count']);
          final bCount = _toInt(b['viewer_count']);
          return bCount.compareTo(aCount);
        });

        return filteredData.map((json) => RoomModel.fromJson(json)).toList();
      });
    } catch (e) {
      debugPrint('Error getting active rooms stream: $e');
      return Stream.value([]);
    }
  }

  // ==================== GET RECOMMENDED ROOMS ====================

  /// Get recommended rooms
  Future<List<RoomModel>> getRecommendedRooms(String userId, {int limit = 10}) async {
    try {
      // Get user's room history
      final historyResponse = await _supabase
          .from('room_history')
          .select('room_id')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(20);

      final Set<String> visitedRoomIds = historyResponse
          .map<String>((item) => item['room_id'] as String)
          .toSet();

      // Get active rooms
      final roomsResponse = await _supabase
          .from('rooms')
          .select()
          .eq('status', 'active')
          .limit(50);

      final rooms = roomsResponse
          .map((json) => RoomModel.fromJson(json))
          .where((RoomModel r) => !visitedRoomIds.contains(r.id))
          .toList();

      // Score rooms
      final List<Map<String, dynamic>> scoredRooms = rooms.map((RoomModel room) {
        double score = 0;

        // Popularity
        score += (room.viewerCount / 100).clamp(0, 30).toDouble();

        // Freshness
        final int ageHours = DateTime.now().difference(room.createdAt).inHours;
        score += (24 - ageHours).clamp(0, 20).toDouble();

        return {'room': room, 'score': score};
      }).toList();

      // Sort by score
      scoredRooms.sort((Map<String, dynamic> a, Map<String, dynamic> b) => b['score'].compareTo(a['score']));

      return scoredRooms.take(limit).map((Map<String, dynamic> item) => item['room'] as RoomModel).toList();
    } catch (e) {
      debugPrint('Error getting recommended rooms: $e');
      return [];
    }
  }

  // ==================== UPDATE ROOM ====================

  /// Update room
  Future<bool> updateRoom(String roomId, Map<String, dynamic> updates) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      final room = await getRoom(roomId);
      if (room == null) throw Exception('Room not found');

      // Check if user is host or moderator
      if (room.hostId != userId && !room.moderators.contains(userId)) {
        throw Exception('Not authorized');
      }

      // Add updated_at
      updates['updated_at'] = DateTime.now().toIso8601String();

      final updateQuery = _supabase
          .from('rooms')
          .update(updates);
      await updateQuery.eq('id', roomId);

      return true;
    } catch (e) {
      debugPrint('Error updating room: $e');
      return false;
    }
  }

  // ==================== JOIN ROOM ====================

  /// Join room
  Future<bool> joinRoom(String roomId, String userId) async {
    try {
      // Check if room exists and is active
      final room = await getRoom(roomId);
      if (room == null) throw Exception('Room not found');
      if (room.status != RoomStatus.active) throw Exception('Room is not active');

      // Update viewer count
      await updateViewerCount(roomId, room.viewerCount + 1);

      // Add to room history
      await _supabase.from('room_history').insert({
        'room_id': roomId,
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      debugPrint('Error joining room: $e');
      return false;
    }
  }

  // ==================== LEAVE ROOM ====================

  /// Leave room
  Future<bool> leaveRoom(String roomId) async {
    try {
      final room = await getRoom(roomId);
      if (room == null) throw Exception('Room not found');

      // Update viewer count (ensure it doesn't go below 0)
      final newCount = max(0, room.viewerCount - 1);
      await updateViewerCount(roomId, newCount);

      return true;
    } catch (e) {
      debugPrint('Error leaving room: $e');
      return false;
    }
  }

  // ==================== SEAT MANAGEMENT ====================

  /// Take seat
  Future<bool> takeSeat(String roomId, int seatNumber, String userId) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    try {
      final room = await getRoom(roomId);
      if (room == null) throw Exception('Room not found');

      if (seatNumber < 1 || seatNumber > room.maxSeats) {
        throw Exception('Invalid seat number');
      }

      final seat = room.seats.firstWhere((s) => s.seatNumber == seatNumber);

      if (!seat.isEmpty) {
        throw Exception('Seat is already taken');
      }

      // Update seat
      final updatedSeats = room.seats.map((s) {
        if (s.seatNumber == seatNumber) {
          return SeatModel(
            seatNumber: s.seatNumber,
            userId: userId,
            userName: currentUser.userMetadata?['full_name'] ?? currentUser.email ?? 'User',
            userAvatar: currentUser.userMetadata?['avatar_url'],
            isMuted: false,
            isSpeaking: false,
            isEmpty: false,
          );
        }
        return s;
      }).toList();

      final updateQuery = _supabase
          .from('rooms')
          .update({
        'seats': updatedSeats.map((s) => s.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', roomId);

      return true;
    } catch (e) {
      debugPrint('Error taking seat: $e');
      return false;
    }
  }

  /// Leave seat
  Future<bool> leaveSeat(String roomId, int seatNumber) async {
    try {
      final room = await getRoom(roomId);
      if (room == null) throw Exception('Room not found');

      // Update seat
      final updatedSeats = room.seats.map((s) {
        if (s.seatNumber == seatNumber) {
          return SeatModel(
            seatNumber: s.seatNumber,
            isEmpty: true,
          );
        }
        return s;
      }).toList();

      final updateQuery = _supabase
          .from('rooms')
          .update({
        'seats': updatedSeats.map((s) => s.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', roomId);

      return true;
    } catch (e) {
      debugPrint('Error leaving seat: $e');
      return false;
    }
  }

  /// Toggle mute
  Future<bool> toggleMute(String roomId, int seatNumber, bool isMuted) async {
    try {
      final room = await getRoom(roomId);
      if (room == null) throw Exception('Room not found');

      // Update seat mute status
      final updatedSeats = room.seats.map((s) {
        if (s.seatNumber == seatNumber && s.userId != null) {
          return SeatModel(
            seatNumber: s.seatNumber,
            userId: s.userId,
            userName: s.userName,
            userAvatar: s.userAvatar,
            isMuted: isMuted,
            isSpeaking: s.isSpeaking,
            isEmpty: s.isEmpty,
          );
        }
        return s;
      }).toList();

      final updateQuery = _supabase
          .from('rooms')
          .update({
        'seats': updatedSeats.map((s) => s.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', roomId);

      return true;
    } catch (e) {
      debugPrint('Error toggling mute: $e');
      return false;
    }
  }

  /// Update speaking status
  Future<bool> updateSpeaking(String roomId, int seatNumber, bool isSpeaking) async {
    try {
      final room = await getRoom(roomId);
      if (room == null) throw Exception('Room not found');

      // Update seat speaking status
      final updatedSeats = room.seats.map((s) {
        if (s.seatNumber == seatNumber && s.userId != null) {
          return SeatModel(
            seatNumber: s.seatNumber,
            userId: s.userId,
            userName: s.userName,
            userAvatar: s.userAvatar,
            isMuted: s.isMuted,
            isSpeaking: isSpeaking,
            isEmpty: s.isEmpty,
          );
        }
        return s;
      }).toList();

      final updateQuery = _supabase
          .from('rooms')
          .update({
        'seats': updatedSeats.map((s) => s.toJson()).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', roomId);

      return true;
    } catch (e) {
      debugPrint('Error updating speaking status: $e');
      return false;
    }
  }

  // ==================== CLOSE ROOM ====================

  /// Close room
  Future<bool> closeRoom(String roomId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not logged in');

    try {
      final room = await getRoom(roomId);
      if (room == null) throw Exception('Room not found');

      if (room.hostId != userId) {
        throw Exception('Only host can close the room');
      }

      final updateQuery = _supabase
          .from('rooms')
          .update({
        'status': 'ended',
        'closed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      await updateQuery.eq('id', roomId);

      return true;
    } catch (e) {
      debugPrint('Error closing room: $e');
      return false;
    }
  }

  // ==================== GET USER ====================

  Future<app.User?> _getUser(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return app.User.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  // ==================== MOCK ROOMS ====================

  /// Mock rooms for testing
  List<RoomModel> _getMockRooms() {
    return List.generate(5, (index) {
      return RoomModel(
        id: 'room_$index',
        name: 'Room ${index + 1}',
        hostId: 'host_$index',
        hostName: 'Host ${index + 1}',
        category: 'Chat',
        createdAt: DateTime.now().subtract(Duration(hours: index)),
        viewerCount: 100 + (index * 50),
        maxSeats: 9,
        seats: List.generate(9, (i) => SeatModel(
          seatNumber: i + 1,
          isEmpty: true,
        )),
        isPKActive: false,
        isPrivate: false,
        status: RoomStatus.active,
      );
    });
  }

  // ==================== GET CATEGORIES ====================

  /// Get room categories
  static List<String> getCategories() {
    return [
      'All',
      'Chat',
      'Music',
      'Games',
      'Dating',
      'Study',
      'Work',
      'Friends',
      'Party',
      'Chill',
    ];
  }

  // ==================== GET POPULAR ROOMS ====================

  /// Get popular rooms by category - FIXED
  Future<List<RoomModel>> getPopularRooms({String? category, int limit = 10}) async {
    try {
      List<Map<String, dynamic>> response;

      if (category != null && category != 'All') {
        // FIXED: আলাদা কোয়েরি
        response = await _supabase
            .from('rooms')
            .select()
            .eq('status', 'active')
            .eq('category', category)
            .order('viewer_count', ascending: false)
            .limit(limit);
      } else {
        response = await _supabase
            .from('rooms')
            .select()
            .eq('status', 'active')
            .order('viewer_count', ascending: false)
            .limit(limit);
      }

      return response.map((json) => RoomModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting popular rooms: $e');
      return [];
    }
  }

  // ==================== ROOM STATISTICS ====================

  /// Get room statistics
  Future<Map<String, dynamic>> getRoomStatistics(String roomId) async {
    try {
      final room = await getRoom(roomId);
      if (room == null) return {};

      // Get peak viewers
      final peakViewers = room.viewerCount; // You might want to track this historically

      // Get average session duration
      final historyResponse = await _supabase
          .from('room_history')
          .select('created_at')
          .eq('room_id', roomId);

      return {
        'currentViewers': room.viewerCount,
        'peakViewers': peakViewers,
        'totalVisits': historyResponse.length,
        'occupiedSeats': room.seats.where((s) => !s.isEmpty).length,
        'totalSeats': room.maxSeats,
        'createdAt': room.createdAt.toIso8601String(),
        'status': room.status.toString(),
      };
    } catch (e) {
      debugPrint('Error getting room statistics: $e');
      return {};
    }
  }
}