import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 🟢 সঠিক imports
import '../../chat/models/chat_model.dart';
import '../../chat/models/room_model.dart';
import '../../chat/models/gift_model.dart';
import '../models/user_models.dart' as app; // 🟢 alias ব্যবহার
import '../constants/firestore_constants.dart';
import '../di/service_locator.dart';

class DatabaseService {
  final SupabaseClient _supabase = getService<SupabaseClient>();

  // ==================== CHAT OPERATIONS ====================

  Future<void> saveChat(ChatModel chat) async {
    try {
      debugPrint('📝 Saving chat: ${chat.id}');

      await _supabase.from('chats').upsert({
        'id': chat.id,
        'type': chat.type,
        'group_name': chat.groupName,
        'group_avatar': chat.groupAvatar,
        'participants': chat.participants,
        'last_message': chat.lastMessage,
        'last_message_time': chat.lastMessageTime?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint('✅ Chat saved successfully: ${chat.id}');
    } catch (e) {
      debugPrint('❌ Error saving chat: $e');
      rethrow;
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      debugPrint('📝 Deleting chat: $chatId');
      await _supabase.from('chats').delete().eq('id', chatId);
      debugPrint('✅ Chat deleted successfully: $chatId');
    } catch (e) {
      debugPrint('❌ Error deleting chat: $e');
      rethrow;
    }
  }

  Future<ChatModel?> getChat(String chatId) async {
    try {
      final response = await _supabase
          .from('chats')
          .select()
          .eq('id', chatId)
          .maybeSingle();

      if (response == null) return null;

      return ChatModel(
        id: response['id'],
        type: response['type'] ?? 'private',
        groupName: response['group_name'],
        groupAvatar: response['group_avatar'],
        participants: List<String>.from(response['participants'] ?? []),
        lastMessage: response['last_message'],
        lastMessageTime: response['last_message_time'] != null
            ? DateTime.parse(response['last_message_time'])
            : null,
      );
    } catch (e) {
      debugPrint('Error getting chat: $e');
      return null;
    }
  }

  // ✅ Fixed: Get chats without stream
  Future<List<ChatModel>> getChats(String userId) async {
    try {
      final response = await _supabase
          .from('chats')
          .select()
          .contains('participants', [userId]);

      return response.map((json) {
        return ChatModel(
          id: json['id'],
          type: json['type'] ?? 'private',
          groupName: json['group_name'],
          groupAvatar: json['group_avatar'],
          participants: List<String>.from(json['participants'] ?? []),
          lastMessage: json['last_message'],
          lastMessageTime: json['last_message_time'] != null
              ? DateTime.parse(json['last_message_time'])
              : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting chats: $e');
      return [];
    }
  }

  // ✅ Alternative: Stream version
  Stream<List<ChatModel>> streamChats(String userId) {
    return _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .map((data) {
      return data
          .where((chat) {
        final participants = List<String>.from(chat['participants'] ?? []);
        return participants.contains(userId);
      })
          .map((json) {
        return ChatModel(
          id: json['id'],
          type: json['type'] ?? 'private',
          groupName: json['group_name'],
          groupAvatar: json['group_avatar'],
          participants: List<String>.from(json['participants'] ?? []),
          lastMessage: json['last_message'],
          lastMessageTime: json['last_message_time'] != null
              ? DateTime.parse(json['last_message_time'])
              : null,
        );
      })
          .toList();
    });
  }

  // ==================== USER OPERATIONS ====================

  Future<void> createUser(app.User user) async {
    try {
      await _supabase.from('users').insert(user.toJson());
      debugPrint('✅ User created: ${user.id}');
    } catch (e) {
      debugPrint('❌ Error creating user: $e');
      rethrow;
    }
  }

  Future<app.User?> getUser(String uid) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (response == null) return null;

      return app.User.fromJson(response);
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from('users')
          .update(data)
          .eq('id', uid);
      debugPrint('✅ User updated: $uid');
    } catch (e) {
      debugPrint('❌ Error updating user: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _supabase
          .from('users')
          .delete()
          .eq('id', uid);
      debugPrint('✅ User deleted: $uid');
    } catch (e) {
      debugPrint('❌ Error deleting user: $e');
      rethrow;
    }
  }

  // ✅ Fixed: Stream user without eq()
  Stream<app.User?> streamUser(String uid) {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .map((data) {
      final filtered = data.where((user) => user['id'] == uid).toList();
      if (filtered.isEmpty) return null;
      return app.User.fromJson(filtered.first);
    });
  }

  Future<List<app.User>> getUsersByCountry(String country) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('country_id', country)
          .limit(50);

      return response.map((json) => app.User.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting users by country: $e');
      return [];
    }
  }

  // ==================== ROOM OPERATIONS ====================

  Future<void> createRoom(RoomModel room) async {
    try {
      await _supabase.from('rooms').insert(room.toJson());
      debugPrint('✅ Room created: ${room.id}');
    } catch (e) {
      debugPrint('❌ Error creating room: $e');
      rethrow;
    }
  }

  Future<RoomModel?> getRoom(String roomId) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select()
          .eq('id', roomId)
          .maybeSingle();

      if (response == null) return null;

      return RoomModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting room: $e');
      return null;
    }
  }

  Future<void> updateRoom(String roomId, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from('rooms')
          .update(data)
          .eq('id', roomId);
      debugPrint('✅ Room updated: $roomId');
    } catch (e) {
      debugPrint('❌ Error updating room: $e');
      rethrow;
    }
  }

  // ✅ Fixed: Stream rooms without eq()
  Stream<List<RoomModel>> streamActiveRooms(String country) {
    return _supabase
        .from('rooms')
        .stream(primaryKey: ['id'])
        .map((data) {
      var filtered = data.where((room) => room['status'] == 'active').toList();

      if (country != 'All') {
        filtered = filtered.where((room) => room['country'] == country).toList();
      }

      return filtered.map((json) => RoomModel.fromJson(json)).toList();
    });
  }

  // ==================== GIFT OPERATIONS ====================

  Future<void> sendGift({
    required String senderId,
    required String receiverId,
    required String giftId,
    required int amount,
    String? roomId,
  }) async {
    try {
      // Start a transaction in Supabase
      await _supabase.rpc('send_gift', params: {
        'p_sender_id': senderId,
        'p_receiver_id': receiverId,
        'p_gift_id': giftId,
        'p_amount': amount,
        'p_room_id': roomId,
      });

      debugPrint('✅ Gift sent successfully');
    } catch (e) {
      debugPrint('❌ Error sending gift: $e');
      rethrow;
    }
  }

  Future<List<GiftModel>> getAvailableGifts() async {
    try {
      final response = await _supabase
          .from('gifts')
          .select()
          .eq('is_available', true);

      return response.map((json) {
        json['id'] = json['id'];
        return GiftModel.fromJson(json);
      }).toList();
    } catch (e) {
      debugPrint('Error getting gifts: $e');
      return [];
    }
  }

  // ==================== FRIEND OPERATIONS ====================

  Future<void> sendFriendRequest(String fromId, String toId) async {
    try {
      await _supabase.from('friend_requests').insert({
        'from_id': fromId,
        'to_id': toId,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Friend request sent');
    } catch (e) {
      debugPrint('❌ Error sending friend request: $e');
      rethrow;
    }
  }

  Future<void> acceptFriendRequest(String requestId) async {
    try {
      // Update request status
      await _supabase
          .from('friend_requests')
          .update({'status': 'accepted', 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', requestId);

      // Get request details
      final request = await _supabase
          .from('friend_requests')
          .select('from_id, to_id')
          .eq('id', requestId)
          .single();

      // Add to friends list for both users
      await _supabase.from('friends').insert([
        {'user_id': request['from_id'], 'friend_id': request['to_id']},
        {'user_id': request['to_id'], 'friend_id': request['from_id']},
      ]);

      debugPrint('✅ Friend request accepted');
    } catch (e) {
      debugPrint('❌ Error accepting friend request: $e');
      rethrow;
    }
  }

  // ==================== TRANSACTION OPERATIONS ====================

  Future<void> addCoins(String userId, int amount, String reason) async {
    try {
      await _supabase.rpc('add_coins', params: {
        'p_user_id': userId,
        'p_amount': amount,
        'p_reason': reason,
      });
      debugPrint('✅ Coins added: $amount');
    } catch (e) {
      debugPrint('❌ Error adding coins: $e');
      rethrow;
    }
  }

  // ==================== REPORT OPERATIONS ====================

  Future<void> submitReport({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    String? description,
    List<String>? evidence,
  }) async {
    try {
      await _supabase.from('reports').insert({
        'reporter_id': reporterId,
        'reported_user_id': reportedUserId,
        'reason': reason,
        'description': description,
        'evidence': evidence,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ Report submitted');
    } catch (e) {
      debugPrint('❌ Error submitting report: $e');
      rethrow;
    }
  }

  // ==================== SEARCH OPERATIONS ====================

  Future<List<app.User>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      final response = await _supabase
          .from('users')
          .select()
          .or('username.ilike.%$query%,name.ilike.%$query%')
          .limit(20);

      return response.map((json) => app.User.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  // ==================== CLEANUP ====================

  Future<void> clearAllData() async {
    try {
      // Implement your cleanup logic here
      debugPrint('Clearing all database data');
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }
}