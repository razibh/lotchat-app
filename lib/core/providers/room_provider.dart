import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../models/user_model.dart';
import '../services/room_service.dart';
import '../services/socket_service.dart';

class RoomProvider extends ChangeNotifier {
  final RoomService _roomService = RoomService();
  final SocketService _socketService = SocketService();
  
  List<RoomModel> _rooms = <RoomModel>[];
  RoomModel? _currentRoom;
  bool _isLoading = false;
  String? _error;

  List<RoomModel> get rooms => _rooms;
  RoomModel? get currentRoom => _currentRoom;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void initSocketListeners() {
    _socketService.onUserJoined(_handleUserJoined);
    _socketService.onUserLeft(_handleUserLeft);
    _socketService.onSeatTaken(_handleSeatTaken);
    _socketService.onSeatLeft(_handleSeatLeft);
    _socketService.onMicToggled(_handleMicToggled);
    _socketService.onNewMessage(_handleNewMessage);
    _socketService.onGiftReceived(_handleGiftReceived);
  }

  void _handleUserJoined(dynamic data) {
    if (_currentRoom != null && _currentRoom!.id == data['roomId']) {
      _currentRoom!.viewerCount++;
      notifyListeners();
    }
  }

  void _handleUserLeft(dynamic data) {
    if (_currentRoom != null && _currentRoom!.id == data['roomId']) {
      _currentRoom!.viewerCount--;
      notifyListeners();
    }
  }

  void _handleSeatTaken(dynamic data) {
    if (_currentRoom != null && _currentRoom!.id == data['roomId']) {
      final seatNumber = data['seatNumber'];
      final userId = data['userId'];
      // Update seat
      notifyListeners();
    }
  }

  void _handleSeatLeft(dynamic data) {
    if (_currentRoom != null && _currentRoom!.id == data['roomId']) {
      final seatNumber = data['seatNumber'];
      // Update seat
      notifyListeners();
    }
  }

  void _handleMicToggled(dynamic data) {
    if (_currentRoom != null && _currentRoom!.id == data['roomId']) {
      final seatNumber = data['seatNumber'];
      final isMuted = data['isMuted'];
      // Update mic status
      notifyListeners();
    }
  }

  void _handleNewMessage(dynamic data) {
    if (_currentRoom != null && _currentRoom!.id == data['roomId']) {
      // Add message to chat
      notifyListeners();
    }
  }

  void _handleGiftReceived(dynamic data) {
    if (_currentRoom != null && _currentRoom!.id == data['roomId']) {
      // Show gift animation
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinRoom(String roomId, UserModel user) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentRoom = await _roomService.getRoom(roomId);
      if (_currentRoom != null) {
        _socketService.joinRoom(roomId);
        _currentRoom!.viewerCount++;
        await _roomService.updateViewerCount(roomId, _currentRoom!.viewerCount);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveRoom() async {
    if (_currentRoom == null) return;

    try {
      _socketService.leaveRoom(_currentRoom!.id);
      _currentRoom!.viewerCount--;
      await _roomService.updateViewerCount(_currentRoom!.id, _currentRoom!.viewerCount);
      _currentRoom = null;
    } catch (e) {
      _error = e.toString();
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