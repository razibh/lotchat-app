import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 🟢 debugPrint এর জন্য
import '../models/room_model.dart';
import '../models/user_models.dart' as app; // 🟢 alias ব্যবহার
import '../services/room_service.dart';
import '../services/socket_service.dart';

class RoomProvider extends ChangeNotifier {
  final RoomService _roomService = RoomService();
  final SocketService _socketService = SocketService();

  List<RoomModel> _rooms = [];
  RoomModel? _currentRoom;
  bool _isLoading = false;
  String? _error;

  List<RoomModel> get rooms => _rooms;
  RoomModel? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initSocketListeners() {
    try {
      _socketService.onUserJoined(_handleUserJoined);
      _socketService.onUserLeft(_handleUserLeft);
      _socketService.onSeatTaken(_handleSeatTaken);
      _socketService.onSeatLeft(_handleSeatLeft);
      _socketService.onMicToggled(_handleMicToggled);
      _socketService.onNewMessage(_handleNewMessage);
      _socketService.onGiftReceived(_handleGiftReceived);
    } catch (e) {
      debugPrint('Error initializing socket listeners: $e');
    }
  }

  void _handleUserJoined(dynamic data) {
    if (_currentRoom != null && _currentRoom!.id == data['roomId']) {
      // 🟢 Fix: viewerCount is final, use copyWith
      _currentRoom = _currentRoom!.copyWith(
        viewerCount: (_currentRoom!.viewerCount ?? 0) + 1,
      );
      notifyListeners();
    }
  }

  void _handleUserLeft(dynamic data) {
    if (_currentRoom != null && _currentRoom!.id == data['roomId']) {
      final newCount = (_currentRoom!.viewerCount ?? 1) - 1;
      // 🟢 Fix: viewerCount is final, use copyWith
      _currentRoom = _currentRoom!.copyWith(
        viewerCount: newCount < 0 ? 0 : newCount,
      );
      notifyListeners();
    }
  }

  void _handleSeatTaken(dynamic data) {
    if (_currentRoom != null && _currentRoom!.id == data['roomId']) {
      final seatNumber = data['seatNumber'] as int?;
      final userId = data['userId'] as String?;

      if (seatNumber != null && userId != null) {
        // Update seat logic here
        // You might want to update the seats list in the room
        debugPrint('Seat $seatNumber taken by user $userId');
      }
      notifyListeners();
    }
  }

  void _handleSeatLeft(dynamic data) {
    if (_currentRoom != null && _currentRoom!.id == data['roomId']) {
      final seatNumber = data['seatNumber'] as int?;
      if (seatNumber != null) {
        // Update seat logic here
        debugPrint('Seat $seatNumber left');
      }
      notifyListeners();
    }
  }

  void _handleMicToggled(dynamic data) {
    if (_currentRoom != null && _currentRoom!.id == data['roomId']) {
      final seatNumber = data['seatNumber'] as int?;
      final isMuted = data['isMuted'] as bool?;
      if (seatNumber != null && isMuted != null) {
        // Update mic status
        debugPrint('Seat $seatNumber muted: $isMuted');
      }
      notifyListeners();
    }
  }

  void _handleNewMessage(dynamic data) {
    if (_currentRoom != null && _currentRoom!.id == data['roomId']) {
      // Add message to chat
      debugPrint('New message in room: $data');
      notifyListeners();
    }
  }

  void _handleGiftReceived(dynamic data) {
    if (_currentRoom != null && _currentRoom!.id == data['roomId']) {
      // Show gift animation
      debugPrint('Gift received in room: $data');
      notifyListeners();
    }
  }

  Future<void> loadRooms(String country) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _rooms = await _roomService.getRooms(country);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading rooms: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinRoom(String roomId, app.User user) async { // 🟢 app.User ব্যবহার
    _isLoading = true;
    notifyListeners();

    try {
      _currentRoom = await _roomService.getRoom(roomId);
      if (_currentRoom != null) {
        _socketService.joinRoom(roomId);
        // 🟢 Fix: viewerCount is final, use copyWith
        _currentRoom = _currentRoom!.copyWith(
          viewerCount: (_currentRoom!.viewerCount ?? 0) + 1,
        );
        await _roomService.updateViewerCount(roomId, _currentRoom!.viewerCount ?? 0);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Error joining room: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveRoom() async {
    if (_currentRoom == null) return;

    try {
      _socketService.leaveRoom(_currentRoom!.id);
      // 🟢 Fix: viewerCount is final, use copyWith
      final newCount = (_currentRoom!.viewerCount ?? 1) - 1;
      _currentRoom = _currentRoom!.copyWith(
        viewerCount: newCount < 0 ? 0 : newCount,
      );
      await _roomService.updateViewerCount(_currentRoom!.id, _currentRoom!.viewerCount ?? 0);
      _currentRoom = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error leaving room: $e');
    }
    notifyListeners();
  }

  Future<void> takeSeat(int seatNumber, String userId) async {
    if (_currentRoom == null) return;

    _socketService.takeSeat(
      roomId: _currentRoom!.id,
      seatNumber: seatNumber,
      userId: userId,
    );
  }

  Future<void> leaveSeat(int seatNumber) async {
    if (_currentRoom == null) return;

    _socketService.leaveSeat(
      roomId: _currentRoom!.id,
      seatNumber: seatNumber,
    );
  }

  Future<void> toggleMic(int seatNumber, bool isMuted) async {
    if (_currentRoom == null) return;

    _socketService.toggleMic(
      roomId: _currentRoom!.id,
      seatNumber: seatNumber,
      isMuted: isMuted,
    );
  }

  void clearRoom() {
    _currentRoom = null;
    notifyListeners();
  }
}