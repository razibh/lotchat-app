import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';

class SocketService {
  factory SocketService() => _instance;
  SocketService._internal();
  static final SocketService _instance = SocketService._internal();

  late IO.Socket socket;
  bool _isConnected = false;

  Future<void> initSocket() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      socket = IO.io(ApiConstants.socketUrl, <String, dynamic>{
        'transports': <String>['websocket'],
        'autoConnect': true,
        'query': <String, String?>{'token': token},
      });

      socket.onConnect((_) {
        debugPrint('✅ Socket connected');
        _isConnected = true;
      });

      socket.onDisconnect((_) {
        debugPrint('❌ Socket disconnected');
        _isConnected = false;
      });

      socket.onError((data) {
        debugPrint('⚠️ Socket error: $data');
      });

      socket.connect();
    } catch (e) {
      debugPrint('❌ Error initializing socket: $e');
    }
  }

  // 🟢 NEW: disconnect method (for ServiceLocator)
  Future<void> disconnect() async {
    debugPrint('🔌 Disconnecting socket...');
    try {
      if (_isConnected) {
        socket.disconnect();
        socket.dispose();
        _isConnected = false;
        debugPrint('✅ Socket disconnected successfully');
      }
    } catch (e) {
      debugPrint('❌ Error disconnecting socket: $e');
    }
  }

  // Join room
  void joinRoom(String roomId) {
    if (!_isConnected) return;
    socket.emit('join-room', <String, String>{
      'roomId': roomId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Leave room
  void leaveRoom(String roomId) {
    if (!_isConnected) return;
    socket.emit('leave-room', <String, String>{
      'roomId': roomId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Send message
  void sendMessage({
    required String roomId,
    required String message,
    required String senderId,
    required String senderName,
  }) {
    if (!_isConnected) return;
    socket.emit('send-message', <String, String>{
      'roomId': roomId,
      'message': message,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Send gift
  void sendGift({
    required String roomId,
    required String giftId,
    required String senderId,
    required String receiverId,
    required int amount,
  }) {
    if (!_isConnected) return;
    socket.emit('send-gift', <String, Object>{
      'roomId': roomId,
      'giftId': giftId,
      'senderId': senderId,
      'receiverId': receiverId,
      'amount': amount,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Take seat
  void takeSeat({
    required String roomId,
    required int seatNumber,
    required String userId,
  }) {
    if (!_isConnected) return;
    socket.emit('take-seat', <String, Object>{
      'roomId': roomId,
      'seatNumber': seatNumber,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Leave seat
  void leaveSeat({
    required String roomId,
    required int seatNumber,
  }) {
    if (!_isConnected) return;
    socket.emit('leave-seat', <String, Object>{
      'roomId': roomId,
      'seatNumber': seatNumber,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Mic toggle
  void toggleMic({
    required String roomId,
    required int seatNumber,
    required bool isMuted,
  }) {
    if (!_isConnected) return;
    socket.emit('toggle-mic', <String, Object>{
      'roomId': roomId,
      'seatNumber': seatNumber,
      'isMuted': isMuted,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // PK Battle actions
  void joinPKBattle(String battleId) {
    if (!_isConnected) return;
    socket.emit('join-pk', <String, String>{
      'battleId': battleId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void updatePKScore({
    required String battleId,
    required String roomId,
    required int points,
  }) {
    if (!_isConnected) return;
    socket.emit('update-pk-score', <String, Object>{
      'battleId': battleId,
      'roomId': roomId,
      'points': points,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Listeners
  void on(String event, Function(dynamic) callback) {
    socket.on(event, (data) {
      debugPrint('📩 Socket event: $event');
      callback(data);
    });
  }

  void off(String event) {
    socket.off(event);
  }

  // Event-specific listeners
  void onNewMessage(Function(dynamic) callback) => on('new-message', callback);
  void onGiftReceived(Function(dynamic) callback) => on('gift-received', callback);
  void onSeatTaken(Function(dynamic) callback) => on('seat-taken', callback);
  void onSeatLeft(Function(dynamic) callback) => on('seat-left', callback);
  void onMicToggled(Function(dynamic) callback) => on('mic-toggled', callback);
  void onUserJoined(Function(dynamic) callback) => on('user-joined', callback);
  void onUserLeft(Function(dynamic) callback) => on('user-left', callback);
  void onPKScoreUpdate(Function(dynamic) callback) => on('pk-score-update', callback);
  void onPKBattleEnd(Function(dynamic) callback) => on('pk-battle-end', callback);

  // Emit method
  void emit(String event, Map<String, dynamic> data) {
    if (!_isConnected) {
      debugPrint('Cannot emit $event: Socket not connected');
      return;
    }
    debugPrint('📤 Emitting: $event');
    socket.emit(event, data);
  }

  // Check connection
  bool get isConnected => _isConnected;

  // Reconnect
  void reconnect() {
    if (!_isConnected) {
      socket.connect();
    }
  }
}