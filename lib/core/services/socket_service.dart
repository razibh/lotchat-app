import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;
  bool _isConnected = false;

  Future<void> initSocket() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    socket = IO.io(ApiConstants.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'query': {
        'token': token,
      },
    });

    socket.onConnect((_) {
      print('Socket connected');
      _isConnected = true;
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
      _isConnected = false;
    });

    socket.onError((data) {
      print('Socket error: $data');
    });

    socket.connect();
  }

  // Join room
  void joinRoom(String roomId) {
    socket.emit('join-room', {
      'roomId': roomId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Leave room
  void leaveRoom(String roomId) {
    socket.emit('leave-room', {
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
    socket.emit('send-message', {
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
    socket.emit('send-gift', {
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
    socket.emit('take-seat', {
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
    socket.emit('leave-seat', {
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
    socket.emit('toggle-mic', {
      'roomId': roomId,
      'seatNumber': seatNumber,
      'isMuted': isMuted,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // PK Battle actions
  void joinPKBattle(String battleId) {
    socket.emit('join-pk', {
      'battleId': battleId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void updatePKScore({
    required String battleId,
    required String roomId,
    required int points,
  }) {
    socket.emit('update-pk-score', {
      'battleId': battleId,
      'roomId': roomId,
      'points': points,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Listeners
  void onNewMessage(Function(dynamic) callback) {
    socket.on('new-message', callback);
  }

  void onGiftReceived(Function(dynamic) callback) {
    socket.on('gift-received', callback);
  }

  void onSeatTaken(Function(dynamic) callback) {
    socket.on('seat-taken', callback);
  }

  void onSeatLeft(Function(dynamic) callback) {
    socket.on('seat-left', callback);
  }

  void onMicToggled(Function(dynamic) callback) {
    socket.on('mic-toggled', callback);
  }

  void onUserJoined(Function(dynamic) callback) {
    socket.on('user-joined', callback);
  }

  void onUserLeft(Function(dynamic) callback) {
    socket.on('user-left', callback);
  }

  void onPKScoreUpdate(Function(dynamic) callback) {
    socket.on('pk-score-update', callback);
  }

  void onPKBattleEnd(Function(dynamic) callback) {
    socket.on('pk-battle-end', callback);
  }

  // Disconnect
  void disconnect() {
    if (_isConnected) {
      socket.disconnect();
      socket.dispose();
    }
  }

  // Check connection
  bool get isConnected => _isConnected;
}