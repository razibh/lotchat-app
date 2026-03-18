import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/socket_service.dart';

class MessageProvider extends ChangeNotifier {
  late final SocketService _socketService;

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _error;
  bool _hasMore = true;

  MessageProvider() {
    _initializeServices();
  }

  void _initializeServices() {
    try {
      _socketService = ServiceLocator.instance.get<SocketService>();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  // Getters
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Load messages
  Future<void> loadMessages(String chatId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      _messages = List.generate(10, (index) {
        return MessageModel(
          id: 'msg_$index',
          chatId: chatId,
          senderId: index % 2 == 0 ? 'current_user' : 'other_user',
          senderName: index % 2 == 0 ? 'You' : 'User $index',
          type: MessageType.text,
          status: MessageStatus.read,
          content: 'Message $index',
          timestamp: DateTime.now().subtract(Duration(minutes: index)),
          readBy: [],
          reactions: [],
        );
      });

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required String content,
  }) async {
    final newMessage = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: 'current_user',
      senderName: 'You',
      type: MessageType.text,
      status: MessageStatus.sending,
      content: content,
      timestamp: DateTime.now(),
      readBy: [],
      reactions: [],
    );

    _messages.add(newMessage);
    notifyListeners();

    try {
      _socketService.emit('send-message', newMessage.toJson());

      await Future.delayed(const Duration(seconds: 1));

      final index = _messages.indexWhere((m) => m.id == newMessage.id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(status: MessageStatus.sent);
        notifyListeners();
      }
    } catch (e) {
      final index = _messages.indexWhere((m) => m.id == newMessage.id);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(status: MessageStatus.failed);
        notifyListeners();
      }
    }
  }

  // Add message from socket
  void addMessage(Map<String, dynamic> data) {
    try {
      final message = MessageModel.fromJson(data);
      if (!_messages.any((m) => m.id == message.id)) {
        _messages.add(message);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding message: $e');
    }
  }

  // Delete message
  void deleteMessage(String messageId) {
    _messages.removeWhere((m) => m.id == messageId);
    notifyListeners();
  }

  // Add reaction
  void addReaction(String messageId, String reaction) {
    final index = _messages.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final reactions = List<MessageReaction>.from(_messages[index].reactions);
      reactions.add(MessageReaction(
        userId: 'current_user',
        reaction: reaction,
        timestamp: DateTime.now(),
      ));

      _messages[index] = _messages[index].copyWith(reactions: reactions);
      notifyListeners();
    }
  }
}